# -*- coding: utf-8 -*-
"""
history_zukan 人物300人の肖像画をWikidata(P18)経由で機械的に取得・検証する。

手順（1人につき）:
 1. Wikidata wbsearchentities (ja, 人間限定ではなく緩め)で候補QIDを検索
 2. 各候補のP569(生年)/P570(没年)を取得し、seed_dataのbirthYear/deathYearと
    照合（誤差許容つき）。一致する候補だけを採用する（同姓同名の取り違え防止）
 3. 採用候補にP18(画像)があれば、Wikimedia CommonsのファイルのライセンスをAPIで確認
 4. PD/CC0/CC-BY/CC-BY-SAのみ採用してダウンロード→JPEG変換→保存
 5. 全件の結果(採用/スキップ理由)をレポートJSONに記録
"""
import json
import re
import time
import io
import os
import requests
from PIL import Image

WD_API = "https://www.wikidata.org/w/api.php"
COMMONS_API = "https://commons.wikimedia.org/w/api.php"
HEADERS = {"User-Agent": "history-zukan-image-sourcing/1.0 (educational app; contact: funvestment1@gmail.com)"}
ALLOWED_LICENSE_KEYWORDS = ["cc0", "cc-by-sa", "cc-by", "public domain", "pd-"]

PEOPLE_JSON = "C:/Users/zka32/AppData/Local/Temp/claude/H---------apps/e85277eb-3196-4ff0-8e84-39b9826af1d0/scratchpad/hz_people.json"
OUT_DIR = "H:/マイドライブ/apps/history_zukan/assets/images/person_photos_staging"
REPORT_PATH = "C:/Users/zka32/AppData/Local/Temp/claude/H---------apps/e85277eb-3196-4ff0-8e84-39b9826af1d0/scratchpad/hz_sourcing_report.json"
CREDITS_PATH = "C:/Users/zka32/AppData/Local/Temp/claude/H---------apps/e85277eb-3196-4ff0-8e84-39b9826af1d0/scratchpad/hz_person_image_credits.json"

os.makedirs(OUT_DIR, exist_ok=True)


def parse_year(s):
    """'574' '紀元前300年頃' '1868' 'BC 100' 等からおおよその西暦年(int)を推定"""
    if not s:
        return None, False
    approx = "頃" in s or "ごろ" in s or "?" in s
    bc = ("紀元前" in s) or ("BC" in s.upper())
    m = re.search(r"-?\d+", s)
    if not m:
        return None, approx
    year = int(m.group())
    if bc and year > 0:
        year = -year
    return year, approx


def wd_search(name, limit=6):
    params = {
        "action": "wbsearchentities", "search": name, "language": "ja",
        "uselang": "ja", "format": "json", "limit": limit, "type": "item",
    }
    r = requests.get(WD_API, params=params, headers=HEADERS, timeout=20)
    r.raise_for_status()
    return r.json().get("search", [])


def wd_get_entity(qid):
    params = {
        "action": "wbgetentities", "ids": qid, "format": "json",
        "props": "claims|labels", "languages": "ja",
    }
    r = requests.get(WD_API, params=params, headers=HEADERS, timeout=20)
    r.raise_for_status()
    return r.json().get("entities", {}).get(qid)


def get_claim_year(entity, prop):
    claims = entity.get("claims", {}).get(prop)
    if not claims:
        return None
    try:
        dv = claims[0]["mainsnak"]["datavalue"]["value"]
        time_str = dv["time"]  # e.g. '+1543-01-01T00:00:00Z' or '-0300-...'
        sign = -1 if time_str.startswith("-") else 1
        year = int(time_str[1:5]) * sign
        return year
    except Exception:
        return None


def get_claim_image(entity):
    claims = entity.get("claims", {}).get("P18")
    if not claims:
        return None
    try:
        return claims[0]["mainsnak"]["datavalue"]["value"]  # filename
    except Exception:
        return None


def strip_html(s):
    return re.sub("<[^<]+?>", "", s or "").strip()


def commons_imageinfo(filename):
    params = {
        "action": "query", "titles": f"File:{filename}", "prop": "imageinfo",
        "iiprop": "url|extmetadata|size|mime", "format": "json",
    }
    r = requests.get(COMMONS_API, params=params, headers=HEADERS, timeout=20)
    r.raise_for_status()
    pages = r.json().get("query", {}).get("pages", {})
    for _, page in pages.items():
        infos = page.get("imageinfo")
        if infos:
            return infos[0]
    return None


def to_jpeg(src_bytes, max_dim=900):
    img = Image.open(io.BytesIO(src_bytes)).convert("RGB")
    img.thumbnail((max_dim, max_dim))
    buf = io.BytesIO()
    img.save(buf, format="JPEG", quality=85)
    return buf.getvalue()


def match_candidate(person, candidates):
    target_birth, birth_approx = parse_year(person["birthYear"])
    target_death, death_approx = parse_year(person["deathYear"])
    tol_birth = 8 if birth_approx else 2
    tol_death = 8 if death_approx else 2

    scored = []
    for c in candidates:
        qid = c["id"]
        try:
            entity = wd_get_entity(qid)
        except Exception:
            continue
        if not entity:
            continue
        b = get_claim_year(entity, "P569")
        d = get_claim_year(entity, "P570")

        ok = True
        matched_on = []
        if target_birth is not None and b is not None:
            if abs(b - target_birth) > tol_birth:
                ok = False
            else:
                matched_on.append("birth")
        if target_death is not None and d is not None:
            if abs(d - target_death) > tol_death:
                ok = False
            else:
                matched_on.append("death")

        # 生没年どちらも取れなかった場合は、検索1位のみ・名前完全一致のときだけ許容
        if not matched_on:
            if c.get("label") == person["name"] and c is candidates[0]:
                ok = True
                matched_on.append("name_exact_top1")
            else:
                ok = False

        if ok:
            scored.append((qid, entity, matched_on))
    return scored


def process_person(person):
    result = {"id": person["id"], "name": person["name"], "status": None, "detail": None}
    try:
        candidates = wd_search(person["name"])
    except Exception as e:
        result["status"] = "SEARCH_ERROR"
        result["detail"] = str(e)
        return result

    if not candidates:
        result["status"] = "NO_CANDIDATE"
        return result

    matches = match_candidate(person, candidates)
    if not matches:
        result["status"] = "NO_YEAR_MATCH"
        return result
    if len(matches) > 1:
        # 複数一致 → 曖昧なので安全側でスキップ（同姓同名リスク）
        result["status"] = "AMBIGUOUS"
        result["detail"] = [q for q, _, _ in matches]
        return result

    qid, entity, matched_on = matches[0]
    result["qid"] = qid
    result["matchedOn"] = matched_on

    filename = get_claim_image(entity)
    if not filename:
        result["status"] = "NO_P18_IMAGE"
        return result

    try:
        info = commons_imageinfo(filename)
    except Exception as e:
        result["status"] = "IMAGEINFO_ERROR"
        result["detail"] = str(e)
        return result
    if not info:
        result["status"] = "IMAGEINFO_NOT_FOUND"
        return result

    ext = info.get("extmetadata", {})
    lic = (ext.get("LicenseShortName", {}).get("value")
           or ext.get("License", {}).get("value") or "unknown").lower()
    lic_normalized = lic.replace(" ", "-")
    if not any(k in lic_normalized for k in ALLOWED_LICENSE_KEYWORDS):
        result["status"] = "LICENSE_REJECTED"
        result["detail"] = lic
        return result

    try:
        resp = requests.get(info["url"], headers=HEADERS, timeout=40)
        resp.raise_for_status()
        jpeg_bytes = to_jpeg(resp.content)
    except Exception as e:
        result["status"] = "DOWNLOAD_ERROR"
        result["detail"] = str(e)
        return result

    out_path = f"{OUT_DIR}/{person['id']}.jpg"
    with open(out_path, "wb") as f:
        f.write(jpeg_bytes)

    result["status"] = "OK"
    result["credit"] = {
        "wikidataQid": qid,
        "commonsFile": filename,
        "license": lic,
        "artist": strip_html(ext.get("Artist", {}).get("value", "")),
        "descriptionUrl": info.get("descriptionurl", ""),
    }
    return result


def main():
    people = json.load(open(PEOPLE_JSON, encoding="utf-8"))

    results = []
    credits = {}
    counts = {}
    for i, p in enumerate(people):
        r = process_person(p)
        results.append(r)
        counts[r["status"]] = counts.get(r["status"], 0) + 1
        if r["status"] == "OK":
            credits[p["id"]] = r["credit"]
        if (i + 1) % 20 == 0:
            print(f"[{i+1}/{len(people)}] running counts: {counts}")
            # 途中経過を都度保存(中断耐性)
            json.dump(results, open(REPORT_PATH, "w", encoding="utf-8"), ensure_ascii=False, indent=2)
            json.dump(credits, open(CREDITS_PATH, "w", encoding="utf-8"), ensure_ascii=False, indent=2)
        time.sleep(0.15)

    json.dump(results, open(REPORT_PATH, "w", encoding="utf-8"), ensure_ascii=False, indent=2)
    json.dump(credits, open(CREDITS_PATH, "w", encoding="utf-8"), ensure_ascii=False, indent=2)
    print("=== FINAL COUNTS ===")
    print(counts)


if __name__ == "__main__":
    main()
