# 人物画像デプロイメント完全ガイド

**状態**: 306人分の画像メタデータ完成 → 本ドキュメントに従いFirestore + Firebase Storageに一括デプロイ

---

## 📋 概要

このプロセスは、Wikimedia Commonsから取得した306人分の歴史人物の画像を、**Firebase Storage にホストし、Firestore のメタデータと連携**させるものです。

### 処理の流れ
```
person_image_sourcing_report.json（OK ステータス 約240人）
          ↓
    [スクリプト実行]
          ↓
  Wikimedia Commons から画像をダウンロード
          ↓
  Firebase Storage にアップロード
          ↓
  Firestore persons/{id} を更新（URL + クレジット情報）
```

---

## 🔧 前提条件

### 1. 環境設定

```bash
# Firebase Admin SDK 認証用のサービスアカウントキーを取得
# → Firebase Console > プロジェクト設定 > サービスアカウント > 新しい秘密鍵を生成
# → JSON ファイルをダウンロード（`service-account-key.json` と命名推奨）

# キーファイルをプロジェクトルートに配置（.gitignore に追加済み）
cp /path/to/service-account-key.json ./

# 環境変数を設定
export GOOGLE_APPLICATION_CREDENTIALS="$(pwd)/service-account-key.json"
export FIREBASE_STORAGE_BUCKET="your-project.appspot.com"  # Firebase Console から確認
export HZ_WIKIMEDIA_CONTACT="your-email@example.com"      # Wikimedia API ToS 要件
```

### 2. Python 依存関係

```bash
pip install firebase-admin requests pillow
```

### 3. Firestore Security Rules の確認

`firestore.rules` に以下が設定されていること（サービスアカウント = 自動的に admin == true で許可）：

```firestore
match /persons/{document=**} {
  allow read: if true;                                    # 誰でも読取可
  allow write: if request.auth != null &&
                  request.auth.token.admin == true;       # 管理者のみ書込
}
```

---

## 🚀 実行手順

### ステップ 1: ドライラン（シミュレーション）

実際に書き込む前に、処理の流れを確認します：

```bash
# リポジトリルートで実行
python scripts/deploy_person_images.py --dry-run --limit 5
```

**出力例**:
```
[2026-09-01 14:30:00] INFO     Starting person image deployment (dry_run=True)
[2026-09-01 14:30:00] INFO     Found 243 people with OK status (out of 306 total)
[2026-09-01 14:30:01] INFO     [1/243] Processing person_j001: 聖徳太子
[2026-09-01 14:30:02] INFO       Downloading person_j001 from https://commons.wikimedia.org/wiki/File:...
[2026-09-01 14:30:02] DEBUG     [DRY RUN] Would upload person_j001 (45678 bytes)
[2026-09-01 14:30:02] DEBUG     [DRY RUN] Would update Firestore: {...}
[2026-09-01 14:30:02] INFO       Result: OK_DRY (45678 bytes)
```

問題なければ進めます。

### ステップ 2: 本実行（段階的）

一度に全員処理するのはリスクなため、最初は少量からテストします：

```bash
# 最初の10人をデプロイ（実際の書き込み）
python scripts/deploy_person_images.py --limit 10
```

**成功確認**:
1. Firestore Console で `persons/person_j001` の `imageUrl`, `imageAttribution` が更新されているか確認
2. `imageUrl` をブラウザで開き、画像が表示されるか確認

### ステップ 3: 全員デプロイ

テストが成功したら、全240人をデプロイします：

```bash
python scripts/deploy_person_images.py
```

⏱️ **所要時間の目安**:
- ネットワーク・サーバー性能に依存
- 目安: 240人 × 1秒/人 ≈ 4分程度
- 中断時は再実行可（既にアップロード済みのレコードはスキップ）

---

## 📊 モニタリング

### リアルタイムログ確認

```bash
# ログファイルをリアルタイムで監視
tail -f docs/person_image_deploy.log
```

### 完了後のレポート確認

```bash
# 処理結果サマリー
cat docs/person_image_deploy_report.json | jq '.summary'
```

**成功例**:
```json
{
  "OK": 240,
  "SKIPPED": 60,
  "DOWNLOAD_FAILED": 2,
  "FIRESTORE_UPDATE_FAILED": 0
}
```

---

## 🔍 トラブルシューティング

### 認証エラー: `"credentials.Certificate() missing file"`

**原因**: `GOOGLE_APPLICATION_CREDENTIALS` の環境変数が設定されていない、またはファイルパスが不正

**対応**:
```bash
export GOOGLE_APPLICATION_CREDENTIALS="/absolute/path/to/service-account-key.json"
ls $GOOGLE_APPLICATION_CREDENTIALS  # ファイルが存在するか確認
```

### ダウンロード失敗: `"requests.exceptions.HTTPError: 404"`

**原因**: Wikimedia Commons のファイルが削除された、または URL が不正

**対応**:
- `person_image_sourcing_report.json` の該当レコードを確認
- `descriptionUrl` を手動で Wikimedia Commons で検索し、画像が存在するか確認
- 見つからない場合は、そのレコードは処理をスキップ（フォールバック画像が表示される）

### Firestore 書き込み失敗: `"Permission denied"`

**原因**: サービスアカウントのトークンに admin フラグがない

**対応**:
1. Firebase Console > Firestore > Security Rules を確認
2. サービスアカウントキーを再生成し、トークンを更新

### Firebase Storage アップロード失敗: `"PERMISSION_DENIED"`

**原因**: ストレージの書き込み権限不足

**対応**:
```firestore
// firebase.storage.rules
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /person_photos/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null && 
                      request.auth.token.admin == true;
    }
  }
}
```

---

## ✅ 検証チェックリスト

デプロイ完了後、以下を確認してください：

- [ ] `docs/person_image_deploy_report.json` の `summary.OK` が 240 付近（ほぼ全員成功）
- [ ] Firestore Console で任意の人物（e.g., `person_j001`）を開く
  - [ ] `imageUrl` が `https://storage.googleapis.com/...` 形式で設定されているか
  - [ ] `imageAttribution` に作者名が入っているか
  - [ ] `imageSourceUrl` が Wikimedia Commons のリンクか
  - [ ] `imageLicense` が "public domain" / "CC-BY" 等か
- [ ] `imageUrl` をブラウザで開き、画像が正常に表示されるか
- [ ] Firebase Storage Console で `person_photos/` フォルダに約240個の `.jpg` ファイルが存在するか

---

## 🎯 次のステップ

### 1. UI側でクレジット表示を追加

人物詳細画面 (`lib/screens/person_detail_screen.dart` など) に以下を追加：

```dart
// 画像の下にクレジット表示
if (person.imageAttribution != null || person.imageLicense != null)
  Padding(
    padding: EdgeInsets.only(top: 8),
    child: Text(
      '© ${person.imageAttribution ?? 'Unknown'} / ${person.imageLicense ?? 'License unknown'}',
      style: TextStyle(fontSize: 10, color: Colors.grey),
    ),
  ),
```

### 2. 画像キャッシング最適化

Firebase Storage の画像をローカルキャッシュ（Hive）して、オフライン対応を強化：

```dart
// Image.network のキャッシング機構を有効化
Image.network(
  person.imageUrl,
  cacheWidth: 500,
  cacheHeight: 500,
  // ...
)
```

### 3. イベント画像の同様処理

`HistoryEvent` の画像についても、同じフローで Wikimedia Commons から取得・デプロイ

---

## 📝 参考資料

- **引き継ぎ書**: `HANDOVER_WIKI_IMAGE_SOURCING.md` （方針・ライセンス注意点）
- **スクリプト**: `scripts/image_sourcing/wikidata_person_sourcing.py` （画像取得）
- **レポート**: `docs/person_image_sourcing_report.json` （取得結果）
- **Firestore Rules**: `firestore.rules` （セキュリティ定義）
- **モデル**: `lib/models/history_person.dart` （データ構造）

---

**最終更新**: 2026-09-01  
**作成者**: Claude Code  
**ステータス**: 実装済み・本番環境への展開準備完了
