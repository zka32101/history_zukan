# Firestore Gacha Masters Upload Guide

## Overview

このガイドでは、`gacha_master.json` に保存された300人の歴史上の人物を Firestore の `gacha_persons` コレクションにアップロードする手順を説明します。

**スクリプト名**: `upload_gacha_persons.js`  
**データソース**: `../lib/data/gacha_master.json` (300人)  
**ターゲット**: Firebase プロジェクト `petit-works-education`  
**機能**:
- 自動バッチ処理（10人ごとに進捗出力）
- エラーハンドリング（失敗時はスキップして続行）
- サマリーレポート出力

---

## Prerequisites (前提条件)

### 1. Node.js のインストール
- Node.js 14.x 以上
- npm または yarn

### 2. Firebase サービスアカウントキーの取得

Firebase Console から JSON キーをダウンロード:

1. [Firebase Console](https://console.firebase.google.com) にアクセス
2. **petit-works-education** プロジェクトを選択
3. 左側メニュー → **プロジェクト設定** → **サービスアカウント** タブ
4. **新しい秘密鍵を生成** をクリック
5. ダウンロードされた JSON ファイルを以下のいずれかに配置:

**オプション A**: スクリプトと同じディレクトリに配置
```
H:\マイドライブ\apps\history_zukan\scripts\service-account-key.json
```

**オプション B**: 環境変数で指定
```powershell
$env:GOOGLE_APPLICATION_CREDENTIALS = "C:\path\to\service-account-key.json"
```

---

## Setup (セットアップ)

### Step 1. 依存パッケージをインストール

```bash
cd H:\マイドライブ\apps\history_zukan\scripts
npm install firebase-admin dotenv
```

### Step 2. Firebase サービスアカウントキーを配置

上記の「Prerequisites」セクションを参照してください。

### Step 3. gacha_master.json の確認

```bash
# スクリプトディレクトリから確認
ls -la ../lib/data/gacha_master.json
```

---

## Usage (実行方法)

### 基本的な実行

```bash
cd H:\マイドライブ\apps\history_zukan\scripts
node upload_gacha_persons.js
```

### Expected Output (期待される出力)

```
✓ Firebase initialized with project: petit-works-education
✓ Loaded 300 persons from gacha_master.json

=== Uploading 300 Persons to Firestore ===

✓ Uploaded 10 / 300 persons...
✓ Uploaded 20 / 300 persons...
✓ Uploaded 30 / 300 persons...
...
✓ Uploaded 300 / 300 persons...

=== Upload Summary ===

Total processed: 300
Successfully uploaded: 300
Failed: 0

✓ Successfully uploaded all 300 persons to Firestore!
```

---

## Error Handling (エラー処理)

### サービスアカウントキーが見つからない場合

```
✗ Service account key not found at: ./service-account-key.json
  Please set GOOGLE_APPLICATION_CREDENTIALS or place service-account-key.json in scripts/
```

**対応**: Prerequisites の Step 2 に従ってキーを配置してください。

### gacha_master.json が見つからない場合

```
✗ Gacha master file not found at: ../lib/data/gacha_master.json
```

**対応**: ファイルパスが正しいか確認してください。

### Firebase 接続エラー

```
✗ Failed to initialize Firebase: <エラーメッセージ>
```

**対応**:
- サービスアカウントキーが有効か確認
- Firebase プロジェクト ID が `petit-works-education` で正しいか確認
- ネットワーク接続を確認

### アップロード失敗（データ検証エラー）

```
✗ Failed to upload person_j001: Missing required field: name
```

**対応**:
- gacha_master.json のデータ形式を確認
- 必須フィールド: `personId`, `name`, `country`, `rarity`, `weight`
- スクリプトは失敗したレコードをスキップして続行します

---

## Data Structure (データ構造)

### Firestore ドキュメント フィールド

各人物は以下のフィールドで Firestore に保存されます:

| フィールド | 型 | 説明 |
|---|---|---|
| `personId` | String | 一意識別子 (例: `person_j001`) |
| `name` | String | 人物名 (例: `聖徳太子`) |
| `country` | String | 出身国/時代 (例: `日本（飛鳥時代）`) |
| `rarity` | Number | レアリティ (1-5) |
| `weight` | Number | ガチャ重み (0-40) |
| `createdAt` | Timestamp | 作成日時 (自動) |
| `updatedAt` | Timestamp | 更新日時 (自動) |
| `description` | String (optional) | 説明 |
| `birthYear` | Number (optional) | 生年 |
| `deathYear` | Number (optional) | 没年 |

### Firestore コレクション

```
petit-works-education (Project)
  └── gacha_persons (Collection)
       ├── person_j001 (Document)
       │    ├── personId: "person_j001"
       │    ├── name: "聖徳太子"
       │    ├── country: "日本（飛鳥時代）"
       │    ├── rarity: 4
       │    ├── weight: 5
       │    ├── createdAt: 2026-07-03T12:34:56Z
       │    └── updatedAt: 2026-07-03T12:34:56Z
       ├── person_j002 (Document)
       │    └── ...
       └── ...
```

---

## Advanced Usage (応用)

### PowerShell で実行 (Windows)

```powershell
cd "H:\マイドライブ\apps\history_zukan\scripts"
node upload_gacha_persons.js
```

### 環境変数でサービスアカウントキーを指定

```bash
# macOS / Linux / Git Bash
export GOOGLE_APPLICATION_CREDENTIALS="/path/to/service-account-key.json"
node upload_gacha_persons.js

# PowerShell (Windows)
$env:GOOGLE_APPLICATION_CREDENTIALS = "C:\path\to\service-account-key.json"
node upload_gacha_persons.js
```

### Node.js スクリプトから呼び出し

```javascript
const { uploadAllPersons } = require('./upload_gacha_persons');

(async () => {
  const results = await uploadAllPersons();
  console.log(`Uploaded: ${results.successful.length}, Failed: ${results.failed.length}`);
})();
```

---

## Monitoring (監視)

### Firestore Console で確認

1. [Firebase Console](https://console.firebase.google.com) → petit-works-education
2. 左側メニュー → **Firestore Database**
3. **gacha_persons** コレクションを選択
4. ドキュメント一覧で 300 件のレコードを確認

### 統計情報

```bash
# アップロード前にコレクション内のドキュメント数を確認
firebase firestore:list-documents gacha_persons --project=petit-works-education
```

---

## Troubleshooting (トラブルシューティング)

| 問題 | 原因 | 解決策 |
|---|---|---|
| `PERMISSION_DENIED` | Firestore セキュリティルール | Firebase Console でルールを確認・修正 |
| `UNAUTHENTICATED` | サービスアカウントキーが無効 | キーを再生成してダウンロード |
| `RESOURCE_EXHAUSTED` | レート制限 | 少し待機してから再実行 |
| メモリ不足 | 大量データ | バッチサイズを調整 (スクリプト内の `BATCH_SIZE`) |

---

## Best Practices (ベストプラクティス)

1. **本番環境での実行前に テスト**
   - 小規模なデータセットでテスト実行
   - ドキュメントが正しく保存されたか確認

2. **サービスアカウントキーの管理**
   - Git に含めない (.gitignore に追加)
   - 本番環境では環境変数を使用

3. **エラーログの確認**
   - Failed Records を確認してデータ品質を検証

4. **定期的なバックアップ**
   - Firestore Export を定期実行

---

## Support

問題が発生した場合:

1. エラーメッセージの全文を確認
2. このガイドの「Troubleshooting」を参照
3. Firebase Console のログを確認 (`Cloud Logging`)

---

**Last Updated**: 2026-07-03  
**Version**: 1.0.0  
**Status**: Production Ready
