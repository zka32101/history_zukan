# 歴史図鑑 — 児童向けキャラクター画像 自動生成ツール

Card Crown (`tools/seed_card_image_gen/`) の Leonardo.ai 自動生成の仕組みを移植。
`assets_list.js` に定義した **34枚**（マスコット4 / 人物プレースホルダー6 / ガチャ枠4 /
時代アイコン15 / 診断背景5）を一括生成する。

プロンプトの元ネタ: `H:\マイドライブ\images\歴史図鑑\leonardo_prompts.md`
（セクション 3・4・7・11・12・13）

---

## 実行手順

### Step 1: Leonardo.ai の API キーを取得

1. https://cloud.leonardo.ai/ にログイン
2. **API Access** メニューで API キーを発行（`leonardo_prompts.md` の推奨プランを参照）

### Step 2: PowerShell で環境変数を設定して実行

```powershell
cd "H:\マイドライブ\apps\history_zukan\tools\history_zukan_image_gen"
$env:LEONARDO_API_KEY="ここに取得したキーを貼り付け"

# サンプル2枚だけ試す（品質確認）
node generate_leonardo.js --count 2

# 問題なければ残り全部（既存分は自動スキップ）
node generate_leonardo.js --all
```

### カテゴリ単位で生成したい場合

```powershell
node generate_leonardo.js --category mascot              # マスコット4枚のみ
node generate_leonardo.js --category era_icons            # 時代アイコン15枚のみ
node generate_leonardo.js --category person_placeholders  # 人物プレースホルダー6枚のみ
node generate_leonardo.js --category gacha_frames         # ガチャ枠4枚のみ
node generate_leonardo.js --category diagnosis_backgrounds # 診断背景5枚のみ
```

### 個別に指定したい場合

```powershell
node generate_leonardo.js --ids mascot_standing,era_jomon
```

### 既存分も含めて作り直したい場合

```powershell
node generate_leonardo.js --all --force
```

---

## 出力

- 保存先: `tools/history_zukan_image_gen/output/*.png`（512×512固定）
- `output/manifest.json` に各画像のプロンプト・生成日時を記録

## 生成後の作業

1. `output/*.png` を確認し、気に入らないものは対象IDだけ `--force` で再生成
2. 用途別の最終サイズ（400x300、200x200、1080x600など。`assets_list.js` の
   `width`/`height` に記載）へリサイズ・クロップ
3. `H:\マイドライブ\images\歴史図鑑\` の該当フォルダへ配置
   （person_placeholders/, mascot/, gacha_frames/, era_icons/, diagnosis_backgrounds/）
4. Flutter 側の `assets/` に配置し `pubspec.yaml` に登録、
   各画面（gacha_screen.dart / login_streak_screen.dart / diagnosis_screen.dart 等）を
   `Image.asset` 参照に差し替え

---

## コスト目安

- 512×512, alchemy:false, photoReal:false の最小設定
- 34枚 ×（Leonardoのクレジット消費量は契約プランに依存、通常設定なら1枚あたり数クレジット程度）
- 既存ファイルは自動スキップされるため、`--all` を何度実行しても未生成分のみ課金される
