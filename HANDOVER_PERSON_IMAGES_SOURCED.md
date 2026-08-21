# 引き継ぎ書：人物画像300人分の取得結果（画像ファイルのみ・実装未着手）

**作成日**: 2026-08-21
**対象**: `HistoryPerson.imageUrl`（300人）
**前提資料**: `HANDOVER_WIKI_IMAGE_SOURCING.md`（PR #3, 方針書）
**このセッションでやったこと**: 方針書の手順1〜4（対象リスト作成〜画像ダウンロード）を、Wikidata優先の自動パイプラインで実施。**イベント500件・データモデル拡張・Firestore反映は未着手**（次工程）。

---

## 1. 結果サマリー

| ステータス | 件数 | 内容 |
|---|---|---|
| ✅ **OK（採用）** | **276人** | Wikidata P18画像を取得・ライセンス確認済み・`assets/images/person_photos_staging/{id}.jpg`に保存 |
| ⚠️ NO_CANDIDATE | 15人 | Wikidata検索で候補が見つからず |
| ⚠️ LICENSE_REJECTED | 4人 | ライセンスが不明瞭（`copyrighted free use`, `no restrictions`, `attribution`のみ表記）で商用利用可否を機械判定できず見送り |
| ⚠️ NO_P18_IMAGE | 3人 | Wikidata項目はあるが画像プロパティ(P18)が未登録 |
| ⚠️ NO_YEAR_MATCH | 2人 | 生没年が一致する候補が見つからず（同名人物との誤認防止のため見送り） |

**取得率: 276/300（92%）**

未取得の24人は、既存の`person_image_resolver.dart`によるカテゴリ別プレースホルダー表示のままで問題なし（方針書どおり、無理に不適切な画像は割り当てていない）。

## 2. 取得方法（方針書の手順1〜3を機械化）

1. Wikidata `wbsearchentities`（日本語）で人物名から候補QIDを検索
2. 各候補の生年(P569)・没年(P570)を取得し、`seed_data.dart`の`birthYear`/`deathYear`と照合（誤差±2年、「頃」表記は±8年）。**一致する候補が複数ある場合はスキップ**（同姓同名の取り違え防止。今回は実際にゼロ件だった）
3. 一致した候補のP18（画像）をWikimedia Commonsのライセンス情報とともに取得
4. ライセンスが `CC0` / `Public Domain` / `CC-BY` / `CC-BY-SA` のいずれかの場合のみダウンロード → JPEG変換（最大900px）→ `assets/images/person_photos_staging/{id}.jpg`に保存

スクリプト: `scripts/image_sourcing/wikidata_person_sourcing.py`
（再実行すると`docs/person_image_sourcing_report.json`にステータス、`docs/person_image_credits.csv`にクレジット情報が出力される）

## 3. 内容面の確認（子ども向けアプリとしての配慮）

方針書5-3の要請どおり、全276件のうち代表サンプル約20件（時代・国・生存年代を分散させて選定、存命に近い人物・第二次大戦関連人物を含む）を目視確認。

- ✅ すべて肖像画・人物写真のみ（戦争・処刑等のセンシティブな史実画像は含まれない）
- ✅ 同姓同名の取り違えなし（サンプル内で生没年・肖像とも人物と整合）

**注意**: 残り約256件は目視確認していない。本番投入前に、少なくとも近現代（明治以降）の人物と、内容に不安が残る人物については追加確認を推奨する。

## 4. ライセンス・クレジット情報

`docs/person_image_credits.csv` に全300人分（未取得含む）のステータス・Wikidata QID・ライセンス・作者・出典URLを記録済み。

CC-BY / CC-BY-SA画像（クレジット表記義務あり）は、方針書6章で提案されている`imageAttribution` / `imageSourceUrl` / `imageLicense`フィールドをデータモデルに追加した際、このCSVから機械的に反映できる。

## 5. 次の担当者へ（未着手の作業）

1. **データモデル拡張**（方針書6章）: `HistoryPerson`に`imageAttribution`, `imageSourceUrl`, `imageLicense`を追加し、`build_runner`で`.g.dart`再生成
2. **Firebase Storageへのアップロード**（方針書5-4・7章手順4）: `assets/images/person_photos_staging/`の276枚をFirebase Storageにアップロードし、配信用URLを発行。**Wikimediaへの直接ホットリンクはしない**方針を維持
3. **管理者専用スクリプトでFirestore反映**（方針書7章手順5）: クライアント直接書き込みは`SECURITY_AUDIT.md`の経緯により禁止。Firebase Admin SDK方式のスクリプトを`scripts/`に用意すること
4. **未取得24人の個別対応**: NO_CANDIDATE/LICENSE_REJECTED等の一覧は本書2章・CSV参照。個別にCommons手動検索するか、プレースホルダー維持のままにするか判断
5. **残り約256件の内容面サンプル拡大確認**（本書3章）
6. **イベント500件分の画像取得**: 今回は人物のみ。イベント画像は方針書の対象だが、件数が想定(40件)の12倍以上に増えているため、着手前にスコープを再度確認すること
7. **表示側のクレジット表記UI**（方針書7章手順7）: 人物詳細画面への出典表示の要否判断

## 6. ファイル一覧

- `assets/images/person_photos_staging/*.jpg` … 取得した276枚（ステージング、未配線）
- `docs/person_image_credits.csv` … 300人分のステータス・クレジット一覧
- `docs/person_image_sourcing_report.json` … スクリプトの生出力（再実行時の差分比較用）
- `scripts/image_sourcing/wikidata_person_sourcing.py` … 取得スクリプト本体（再実行・拡張可能）
