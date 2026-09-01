#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
歴史図鑑: 人物画像のメタデータ + 画像ファイルをFirestore + Firebase Storageに一括デプロイ

使い方:
  $ export GOOGLE_APPLICATION_CREDENTIALS=/path/to/service-account-key.json
  $ python scripts/deploy_person_images.py [--dry-run] [--limit N]

フロー:
  1. docs/person_image_sourcing_report.json から "OK" ステータスの人物を抽出
  2. docs/person_image_credits.csv からメタデータ（artist, license, descriptionUrl）を取得
  3. Wikimedia CommonsのURLから画像をダウンロード
  4. Firebase Storageに <personId>.jpg として保存
  5. Firestore の persons/{personId} を更新：
     - imageUrl: Firebase Storage の公開URL
     - imageAttribution: 作者名
     - imageSourceUrl: Wikimedia Commons ファイルページURL
     - imageLicense: ライセンス情報
  6. 結果をレポートとして保存

注意:
  - この処理は本来「管理者専用」であり、サービスアカウントキー（Admin SDK）を使用
  - Firebase Security Rules では persons/{id} への write を admin == true のみに制限
  - 失敗時の再実行に対応（既にアップロード済みの人物はスキップ）
"""

import json
import csv
import os
import sys
import requests
import time
from pathlib import Path
from typing import Optional, Dict, List, Tuple

import firebase_admin
from firebase_admin import credentials, firestore, storage

# ===== CONFIG =====
_REPO_ROOT = Path(__file__).parent.parent
REPORT_PATH = _REPO_ROOT / "docs" / "person_image_sourcing_report.json"
CREDITS_PATH = _REPO_ROOT / "docs" / "person_image_credits.json"
DEPLOY_REPORT_PATH = _REPO_ROOT / "docs" / "person_image_deploy_report.json"
DEPLOY_LOG_PATH = _REPO_ROOT / "docs" / "person_image_deploy.log"

# Firebase Storage bucket name (set via .env or environment)
STORAGE_BUCKET = os.environ.get("FIREBASE_STORAGE_BUCKET", "history-zukan.appspot.com")

# Wikimedia User-Agent (required by API ToS)
_CONTACT = os.environ.get("HZ_WIKIMEDIA_CONTACT", "image-deployment@history-zukan.local")
HEADERS = {"User-Agent": f"history-zukan-image-deployment/1.0 (educational app; contact: {_CONTACT})"}

# ===== INIT FIREBASE =====
if not firebase_admin.get_app():
    creds = credentials.Certificate(os.environ.get("GOOGLE_APPLICATION_CREDENTIALS"))
    firebase_admin.initialize_app(creds, {"storageBucket": STORAGE_BUCKET})

db = firestore.client()
bucket = storage.bucket()


def log_msg(msg: str, level: str = "INFO") -> None:
    """ログ出力（コンソール＋ファイル）"""
    timestamp = time.strftime("%Y-%m-%d %H:%M:%S")
    formatted = f"[{timestamp}] {level:8} {msg}"
    print(formatted)
    with open(DEPLOY_LOG_PATH, "a", encoding="utf-8") as f:
        f.write(formatted + "\n")


def load_report() -> Dict[str, dict]:
    """person_image_sourcing_report.json を読み込む"""
    with open(REPORT_PATH, encoding="utf-8") as f:
        data = json.load(f)
    # id -> record マッピング
    return {r["id"]: r for r in data}


def load_credits() -> Dict[str, dict]:
    """person_image_credits.json を読み込む（詳細な作者情報用）"""
    try:
        with open(CREDITS_PATH, encoding="utf-8") as f:
            return json.load(f)
    except FileNotFoundError:
        log_msg(f"Credits file not found: {CREDITS_PATH}", "WARN")
        return {}


def download_image(commons_url: str) -> Optional[bytes]:
    """Wikimedia Commons の URL から画像をダウンロード"""
    try:
        resp = requests.get(commons_url, headers=HEADERS, timeout=30)
        resp.raise_for_status()
        return resp.content
    except Exception as e:
        log_msg(f"Failed to download {commons_url}: {e}", "ERROR")
        return None


def upload_to_storage(person_id: str, image_bytes: bytes) -> Optional[str]:
    """Firebase Storage に画像をアップロード。返り値は公開URL"""
    try:
        blob = bucket.blob(f"person_photos/{person_id}.jpg")
        blob.upload_from_string(image_bytes, content_type="image/jpeg")
        blob.make_public()
        return blob.public_url
    except Exception as e:
        log_msg(f"Failed to upload to Storage {person_id}: {e}", "ERROR")
        return None


def update_firestore(person_id: str, updates: dict) -> bool:
    """Firestore の persons/{person_id} を更新"""
    try:
        db.collection("persons").document(person_id).update(updates)
        return True
    except Exception as e:
        log_msg(f"Failed to update Firestore {person_id}: {e}", "ERROR")
        return False


def process_person(
    person_id: str,
    record: dict,
    credits: dict,
    dry_run: bool = False,
) -> Tuple[str, Optional[str]]:
    """
    1人の人物に対する処理：ダウンロード → Storage アップロード → Firestore 更新
    返り値: (status, detail)
    """
    if record["status"] != "OK":
        return "SKIPPED", f"Status is {record['status']}"

    credit = record.get("credit", {})
    if not credit:
        return "NO_CREDIT", "Missing credit info in report"

    commons_url = credit.get("descriptionUrl")
    if not commons_url:
        return "NO_URL", "Missing descriptionUrl"

    # 画像をダウンロード
    log_msg(f"Downloading {person_id} from {commons_url}")
    image_bytes = download_image(commons_url)
    if not image_bytes:
        return "DOWNLOAD_FAILED", commons_url

    if dry_run:
        log_msg(f"  [DRY RUN] Would upload {person_id} ({len(image_bytes)} bytes)", "DEBUG")
        storage_url = f"gs://{STORAGE_BUCKET}/person_photos/{person_id}.jpg"
    else:
        # Storage にアップロード
        log_msg(f"Uploading to Storage: {person_id}")
        storage_url = upload_to_storage(person_id, image_bytes)
        if not storage_url:
            return "UPLOAD_FAILED", "See error log"

    # Firestore を更新
    attribution = credit.get("artist", "Unknown")
    license_info = credit.get("license", "unknown")

    updates = {
        "imageUrl": storage_url,
        "imageAttribution": attribution,
        "imageSourceUrl": commons_url,
        "imageLicense": license_info,
    }

    if dry_run:
        log_msg(f"  [DRY RUN] Would update Firestore: {updates}", "DEBUG")
        return "OK_DRY", f"{len(image_bytes)} bytes"
    else:
        log_msg(f"Updating Firestore: {person_id}")
        if update_firestore(person_id, updates):
            return "OK", storage_url
        else:
            return "FIRESTORE_UPDATE_FAILED", "See error log"


def main():
    import argparse

    parser = argparse.ArgumentParser(description="Deploy person images to Firestore + Storage")
    parser.add_argument("--dry-run", action="store_true", help="Simulate without actual writes")
    parser.add_argument("--limit", type=int, default=None, help="Process only first N people")
    args = parser.parse_args()

    log_msg("=" * 80)
    log_msg(f"Starting person image deployment (dry_run={args.dry_run})")
    log_msg(f"Report: {REPORT_PATH}")
    log_msg(f"Storage Bucket: {STORAGE_BUCKET}")
    log_msg("=" * 80)

    # JSON ロード
    report = load_report()
    credits = load_credits()

    # 処理対象（"OK" ステータスのみ）
    ok_records = {pid: r for pid, r in report.items() if r["status"] == "OK"}
    log_msg(f"Found {len(ok_records)} people with OK status (out of {len(report)} total)")

    # 処理実行
    results = {}
    for i, (person_id, record) in enumerate(list(ok_records.items())[: args.limit]):
        log_msg(f"\n[{i+1}/{len(ok_records)}] Processing {person_id}: {record.get('name', '?')}")
        status, detail = process_person(person_id, record, credits, dry_run=args.dry_run)
        results[person_id] = {"status": status, "detail": detail, "name": record.get("name")}
        log_msg(f"  Result: {status} ({detail})")

        # API スロットリング
        time.sleep(0.2)

    # 結果レポート
    summary = {}
    for status in set(r["status"] for r in results.values()):
        count = sum(1 for r in results.values() if r["status"] == status)
        summary[status] = count

    log_msg("\n" + "=" * 80)
    log_msg("DEPLOYMENT SUMMARY")
    for status, count in sorted(summary.items()):
        log_msg(f"  {status:30} {count:4}")
    log_msg("=" * 80)

    # レポート保存
    report_data = {
        "timestamp": time.strftime("%Y-%m-%dT%H:%M:%SZ"),
        "dry_run": args.dry_run,
        "summary": summary,
        "details": results,
    }
    with open(DEPLOY_REPORT_PATH, "w", encoding="utf-8") as f:
        json.dump(report_data, f, ensure_ascii=False, indent=2)
    log_msg(f"\nReport saved to {DEPLOY_REPORT_PATH}")
    log_msg(f"Log saved to {DEPLOY_LOG_PATH}")


if __name__ == "__main__":
    main()
