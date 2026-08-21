# 引き継ぎ書：画像調達フローの移行（Leonardo.ai生成 → Wikipedia/Wikimedia Commons取得）

**作成日**: 2026-08-09
**対象プロジェクト**: history_zukan（歴史図鑑アプリ）
**引き継ぎ内容**: 人物・イベントの画像を、AI生成（Leonardo.ai）ではなく Wikipedia / Wikimedia Commons の実写真・実画像から取得する方式に切り替える作業一式
**現時点のステータス**: 未着手（本書は着手前の方針・手順の整理のみ。実装・データ収集はまだ行っていない）

---

## 1. 背景・目的

- `FEATURE_CONTENT_LIST.md` のロードマップに、Phase 2+ の「コンテンツ拡張」として「関連メディア（Wikipediaリンク、画像）」が既に記載されている（L207-212）。本書はこれを具体的な作業として前倒しで整理したもの。
- 現状、歴史人物・歴史イベントの `imageUrl` はすべて `via.placeholder.com` の仮画像（グレー背景にテキストのみ）で、実際の画像は一切設定されていない。
- 一方、アプリアイコンやマスコットなどの装飾系アセットは Leonardo.ai で生成済み・生成予定（`FEATURE_CONTENT_LIST.md` L326-342）。今回の移行は**歴史人物・歴史イベントのコンテンツ画像のみ**が対象で、装飾系アセットの方針は変えない。

## 2. 現状整理（As-Is）

### 2-1. コンテンツ画像（今回の対象）
- `lib/models/history_event.dart` … `imageUrl`（必須, String）, `subImageUrl`（任意, String?）
- `lib/models/history_person.dart` … `imageUrl`（必須, String）
- `lib/utils/seed_data.dart` … 40イベント + 300人物、`imageUrl` は全件 `https://via.placeholder.com/400x300?text=...` 形式（実測で本文中に800箇所出現＝件数×imageUrl・searchKeywords等の重複含む）
- 表示側は `Image.network(event.imageUrl, ..., errorBuilder: ...)` の形でそのまま描画（`card_detail_screen.dart`, `person_card.dart` など）。取得失敗時は簡易的なアイコン/テキスト表示にフォールバック。

### 2-2. 装飾系アセット（今回の対象外）
- Leonardo.ai生成、`assets/images/` 配下にローカル同梱：
  - `era_icons/`（15時代アイコン）
  - `gacha_frames/`（レア度別フレーム）
  - `diagnosis_backgrounds/`（診断テーマ背景）
  - `mascot/`（マスコット4種）
  - `person_placeholders/`（人物画像が読み込めない時の6カテゴリ別フォールバック画像）
- `lib/utils/person_image_resolver.dart` が、`imageUrl` が取得できない場合に「日本×時代」「西洋×時代」「その他」で6カテゴリのどれを出すか判定するロジックを既に持っている。**今回の移行後もこのフォールバック機構はそのまま維持する**（Wikipedia側に適切な画像が無い人物・イベントの受け皿として使う）。
- ガチャ機能（`GachaPerson` モデル）は現状 `imageUrl` 相当のフィールドを持たず、`Icons.person` のアイコン表示のみ。今回は対象外。

## 3. 今回の変更範囲（To-Be）

| 対象 | 範囲 |
|---|---|
| `HistoryEvent.imageUrl` / `subImageUrl` | 40件（将来500+件に拡張予定） |
| `HistoryPerson.imageUrl` | 300件 |
| 装飾系アセット・ガチャ画像 | **対象外**（現行のLeonardo.ai運用を継続） |

## 4. 画像取得方針

優先順位をつけて機械的に判定できる順に並べる。

1. **Wikidata の P18（image）プロパティ**からWikimedia Commonsのファイルを取得（人物・出来事ともにWikidata項目が存在すればここが最も確実）
2. **Wikipedia記事のREST Summary API**（`GET /api/rest_v1/page/summary/{title}`）の `thumbnail` / `originalimage` を取得（日本語版優先、なければ英語版）
3. 上記で見つからない場合は **Wikimedia Commonsのカテゴリ・検索**から手動で妥当な画像を選定
4. どれでも適切な画像が見つからない・権利的に採用できない場合は、**現行の `person_image_resolver.dart` によるカテゴリ別プレースホルダーを維持**（無理に不適切な画像を当てない）

## 5. ライセンス・著作権の注意点（重要）

本アプリは ¥300 の買い切り有償アプリであるため、**非営利限定（NC）ライセンスの画像は使用不可**。以下を必ず遵守すること。

### 5-1. 使用可否の基準
- ✅ 使用可: パブリックドメイン（PD）、CC0、CC-BY、CC-BY-SA（いずれも表示義務・継承義務に注意）
- ❌ 使用不可: CC-BY-NC / CC-BY-NC-SA 等の非営利限定ライセンス、「フェアユース」根拠のみで掲載されている画像、権利関係が不明瞭な画像
- Wikimedia Commons上のファイルページには必ずライセンス欄があるため、**採用前に個別に確認**すること（記事のサムネイルだからといって自動的に商用利用可とは限らない）

### 5-2. クレジット表記
- CC-BY / CC-BY-SA の画像は**作者名・ライセンス種別・出典URLの表示が利用条件上必須**。
- 現行の `HistoryEvent` / `HistoryPerson` モデルにはこれらを保持するフィールドが無いため、**データモデルの拡張が必須**（詳細は6章）。
- CC-BY-SA画像を加工（トリミング等）して使う場合、継承ライセンス（同じくCC-BY-SA）での再配布義務がある点にも留意。

### 5-3. 内容面の配慮
- 子ども向けアプリ（CLAUDE.md記載：小学1年生から対応）のため、戦争・処刑・遺体等のセンシティブな史実画像は、採用可否・トリミング要否を個別に判断すること。
- 近現代（明治以降〜存命に近い時代）の人物は、肖像権・実演家人格権的な配慮も含めて慎重に確認すること。単にライセンスがCC-BYだから即採用、とはしない。

### 5-4. 技術的な利用規約
- Wikimedia REST API / Commons への直接アクセスには **User-Agentヘッダーの明示が必須**（規約違反はブロック対象）。
- クライアントアプリから `upload.wikimedia.org` 等への恒常的なホットリンクはレート制限・利用規約上推奨されない。**取得した画像は一度ダウンロードし、自前のストレージ（Firebase Storage等）にキャッシュして配信する**運用を前提とすること。

## 6. データモデルへの影響（実装時の設計方針）

以下のフィールド追加を推奨する（実装自体は次工程、本書では方針のみ提示）。

- `imageAttribution: String?` … 画面表示用のクレジット文字列（例: `"© 作者名 / CC BY-SA 4.0"`）
- `imageSourceUrl: String?` … 出典のWikimedia Commonsファイルページ / Wikipedia記事URL
- `imageLicense: String?` … ライセンス種別コード（`PD`, `CC0`, `CC-BY-4.0`, `CC-BY-SA-4.0` 等）

実装時の注意点：
- `json_serializable` / Hive の `.g.dart` 再生成が必要（本セッションの環境にはFlutter/Dart SDKが無く、コード生成・`flutter analyze` による検証ができなかった。実装担当者は必ず自分の環境で `flutter pub run build_runner build --delete-conflicting-outputs` と `flutter analyze` を実行して確認すること）。
- Firestore Security Rules・スキーマ説明（`CLAUDE.md` のデータモデル節）にも反映すること。

## 7. 作業手順（推奨フロー）

1. **対象リストの作成**：40イベント＋300人物のID・名称一覧をエクスポート（`lib/utils/seed_data.dart` から機械的に抽出可能）
2. **Wikidata / Wikipedia照合**：各項目について該当記事の有無を確認。**同姓同名・同名イベントの取り違えに注意**（特に戦国武将などは複数の同名人物が存在しうる。生没年・国・略歴で必ず照合すること）
3. **画像・ライセンス情報の記録**：スプレッドシート等で `id / 記事URL / 画像URL / ライセンス / 作者 / 採用可否 / 備考` を一元管理し、レビュー可能な状態にする
4. **画像のダウンロード・自前ホスティング**：採用可能な画像のみ取得し、Firebase Storage等にアップロードして配信用URLを発行（Wikimediaへの直リンクはしない）
5. **データモデル拡張・反映**：6章のフィールドを追加した上で、`scripts/` 配下に**管理者専用スクリプト**（`scripts/upload_gacha_persons.js` と同様、サービスアカウントキーを用いたFirebase Admin SDK方式）を用意し、Firestoreへ一括反映する
   - クライアントアプリから直接Firestoreへ書き込む形にしないこと。過去に `main.dart` にあった「初回起動時にクライアントからseedデータを一括書き込みする」処理は、Firestore Security Rulesが管理者権限を要求するため実質機能しておらず、かつ不要な攻撃面だったため既に削除済み（`SECURITY_AUDIT.md` 参照）。同じ轍を踏まないこと。
6. **見つからない項目の扱い**：画像が見つからない／採用できない項目は、既存のフォールバック（`person_image_resolver.dart`）をそのまま利用する。無理に不適切な画像を割り当てない。
7. **表示側の対応検討**：クレジット表記UI（人物詳細画面・イベント詳細画面への出典表示）を追加するかどうかを判断し、必要であれば実装する。

## 8. QA・チェックリスト

- [ ] 人物・イベントの同定が正しいか（取り違えがないか）
- [ ] ライセンスが商用利用可能なものか（NC系を使っていないか）
- [ ] CC-BY / CC-BY-SA画像に出典・作者表記が保存され、画面上でも参照可能になっているか
- [ ] 子ども向けとして表現が適切か（過度に暴力的・グロテスクな史実画像を無配慮に採用していないか）
- [ ] 画像が縦横比・解像度的にUIで破綻しないか（`Image.network` + `BoxFit.cover` での見え方を実機/エミュレータで確認）
- [ ] 見つからない項目にフォールバック（カテゴリ別プレースホルダー）が正しく適用されるか
- [ ] Firestoreへの反映が管理者専用スクリプト経由で行われており、クライアントからの直接書き込みになっていないか
- [ ] `flutter analyze` / `flutter test` がグリーンであること（モデル変更を伴うため必須）

## 9. 次の担当者へ

- 本書作成時点で、データ収集・実装は**一切未着手**。`imageUrl` は全件 `via.placeholder.com` のまま。
- まずは 7章 手順1「対象リストの作成」から着手すること。
- 装飾系アセット（アイコン・マスコット等）とガチャ機能の画像は対象外であり、Leonardo.aiでの運用をそのまま継続してよい。

## 10. 参考資料

- `FEATURE_CONTENT_LIST.md`（既存ロードマップ「関連メディア（Wikipediaリンク、画像）」記載箇所、および Leonardo.ai 画像リスト）
- `SECURITY_AUDIT.md`（クライアントからのFirestore直接書き込みを避けるべき理由の経緯）
- Wikimedia REST API: https://www.mediawiki.org/wiki/API:REST_API
- Wikidata Query Service（P18プロパティでの画像取得に利用）
- Commons:Reusing content outside Wikimedia（ライセンス別の利用条件ガイド）
