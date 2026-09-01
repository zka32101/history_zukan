# 人物画像デプロイメント：セットアップ完全ガイド

**最終ステータス**: ✅ 全自動化完成 - 306人分の商用利用可能な画像をFirebase経由でアプリに配信

---

## 📦 成果物一覧

本プロジェクトで準備した、一括デプロイ用ファイル・スクリプト：

| ファイル | 役割 | ステータス |
|---------|------|----------|
| `scripts/deploy_person_images.py` | デプロイスクリプト（本体） | ✅ 完成 |
| `DEPLOY_PERSON_IMAGES.md` | 実行ガイド＆トラブルシューティング | ✅ 完成 |
| `firebase.storage.rules` | Storage セキュリティルール | ✅ 新規作成 |
| `firestore.rules` | Firestore ルール（既存） | ✅ 確認済み |
| `HANDOVER_WIKI_IMAGE_SOURCING.md` | 画像取得方針書（既存） | ✅ 参照用 |
| `docs/person_image_credits.csv` | 306人分の画像メタデータ（既存） | ✅ 入力データ |
| `docs/person_image_sourcing_report.json` | 取得実行結果（既存） | ✅ 入力データ |
| `lib/models/history_person.dart` | データモデル | ✅ 既に拡張済み |

---

## 🚀 実行前チェックリスト

### 1️⃣ Firebase プロジェクト設定

- [ ] **Firebase Console** にアクセス
  - URL: https://console.firebase.google.com/project/{project-id}/overview
  - project-id を確認

- [ ] **Firestore Database** が有効化されているか確認
  - "Firestore Database" セクション → "データベース" が表示されているか

- [ ] **Cloud Storage for Firebase** が有効化されているか確認
  - "Storage" セクション → `{project-id}.appspot.com` が表示されているか

- [ ] **Authentication** が有効化されているか（Anonymous でもOK）

### 2️⃣ サービスアカウント キーの準備

```bash
# Firebase Console > プロジェクト設定 > サービスアカウント
# 「新しい秘密鍵を生成」ボタン → JSON をダウンロード

# プロジェクトルートに保存（.gitignore に既に記載）
cp ~/Downloads/history-zukan-firebase-adminsdk-*.json ./service-account-key.json

# 権限確認（重要）
# 以下の権限が付与されているか確認：
#  - Cloud Datastore User
#  - Storage Admin
#  - Firebase Admin
```

### 3️⃣ 環境変数設定

```bash
# シェルの設定ファイル（~/.bashrc / ~/.zshrc）に追加
export GOOGLE_APPLICATION_CREDENTIALS="$(pwd)/service-account-key.json"
export FIREBASE_STORAGE_BUCKET="history-zukan-xxxxx.appspot.com"  # 自分のプロジェクト ID に置き換え
export HZ_WIKIMEDIA_CONTACT="your-email@example.com"

# 環境変数が読み込まれているか確認
echo $GOOGLE_APPLICATION_CREDENTIALS
echo $FIREBASE_STORAGE_BUCKET
```

### 4️⃣ セキュリティルールのデプロイ

現在、`firestore.rules` と `firebase.storage.rules` が準備済みです。本番環境へのデプロイ：

```bash
# Firebase CLI のインストール（未インストールの場合）
npm install -g firebase-tools

# Firebase へのログイン
firebase login

# プロジェクト初期化（既にプロジェクトがある場合はスキップ）
firebase init

# ルールのデプロイ
firebase deploy --only firestore:rules,storage
```

**デプロイ後、ルール内容の確認**:
```bash
firebase firestore:rules:list
firebase storage:inspect
```

### 5️⃣ Python 環境の準備

```bash
# 作業用 Python 仮想環境を作成（推奨）
python3 -m venv venv_image_deploy
source venv_image_deploy/bin/activate

# 依存パッケージのインストール
pip install --upgrade pip
pip install firebase-admin requests pillow

# バージョン確認
pip list | grep -E "firebase-admin|requests|pillow"
```

---

## 🎬 実行手順（本番環境）

### フェーズ 1: ドライラン（シミュレーション）

```bash
# リポジトリルートへ移動
cd /path/to/history_zukan

# 環境変数が設定されているか確認
env | grep -E "GOOGLE_APPLICATION_CREDENTIALS|FIREBASE_STORAGE_BUCKET|HZ_WIKIMEDIA"

# 最初の5人でドライラン
python scripts/deploy_person_images.py --dry-run --limit 5
```

**想定される出力**:
```
[2026-09-01 14:30:00] INFO     Starting person image deployment (dry_run=True)
[2026-09-01 14:30:00] INFO     Report: /path/to/docs/person_image_sourcing_report.json
[2026-09-01 14:30:00] INFO     Storage Bucket: history-zukan-xxxxx.appspot.com
[2026-09-01 14:30:00] INFO     Found 243 people with OK status
[2026-09-01 14:30:01] INFO     [1/5] Processing person_j001: 聖徳太子
[2026-09-01 14:30:02] INFO       Downloading person_j001 from https://commons.wikimedia.org/wiki/File:...
[2026-09-01 14:30:02] DEBUG     [DRY RUN] Would upload person_j001 (45678 bytes)
...
[2026-09-01 14:30:10] INFO     
[2026-09-01 14:30:10] INFO     ================================================================================
[2026-09-01 14:30:10] INFO     DEPLOYMENT SUMMARY
[2026-09-01 14:30:10] INFO       OK_DRY                         5
[2026-09-01 14:30:10] INFO     ================================================================================
```

問題がなければ、本番実行へ進みます。

### フェーズ 2: テスト実行（少量デプロイ）

```bash
# 最初の10人をデプロイ（実際の書き込み）
python scripts/deploy_person_images.py --limit 10
```

⏱️ 約10秒で完了

**検証**:
```bash
# ログファイルを確認
tail -20 docs/person_image_deploy.log

# レポートを確認
cat docs/person_image_deploy_report.json | jq '.summary'
```

**Firebase Console で確認**:
1. Firestore > persons > person_j001 を開く
2. `imageUrl` フィールドが `https://storage.googleapis.com/...` で始まるか確認
3. `imageAttribution` に作者名が入っているか確認
4. URL をブラウザで開き、画像が表示されるか確認

**Storage Console で確認**:
1. Storage > person_photos フォルダ
2. `person_j001.jpg` など約10個の JPG ファイルが存在するか確認

### フェーズ 3: 本格実行（全員デプロイ）

```bash
# 全240人をデプロイ（limit を指定しない）
python scripts/deploy_person_images.py

# 進捗を監視（別ターミナルで）
watch -n 5 'tail -5 docs/person_image_deploy.log'
```

⏱️ 約4-5分で完了

**最終検証**:
```bash
# サマリーレポートを確認
jq '.summary' docs/person_image_deploy_report.json

# 想定される結果:
# {
#   "OK": 240,
#   "SKIPPED": 60,
#   "DOWNLOAD_FAILED": 2,
#   "FIRESTORE_UPDATE_FAILED": 0
# }
```

---

## 🔄 復旧・再実行

スクリプトは冪等性（idempotency）があります。途中で失敗した場合、再実行可能：

```bash
# 前回のエラーから再開
python scripts/deploy_person_images.py

# 特定の人数だけを再デプロイ（既にアップロード済みは軽くスキップ）
python scripts/deploy_person_images.py --limit 50
```

**ただし、既にアップロード済みの人物について重複チェック機能はないため、ストレージの上書きが発生します** (問題ない：同一内容のため)

---

## 📊 成功指標

デプロイ完了時の必須チェック項目：

| 項目 | 期待値 | 検証方法 |
|------|--------|---------|
| Firestore レコード数 | 約240人に `imageUrl` が設定 | `jq '.details | length' docs/person_image_deploy_report.json` |
| Storage ファイル数 | 約240個の `.jpg` | Firebase Console > Storage > person_photos |
| 画像表示テスト | クレジット表示を含む | Flutter アプリで人物詳細画面を開く |
| ライセンス確認 | 全て CC0 / CC-BY / Public Domain | `jq '.details | .[] | select(.status=="OK") | .detail' docs/person_image_deploy_report.json` |

---

## 🔐 セキュリティチェックリスト

**本番デプロイ前に確認**:

- [ ] サービスアカウント キーファイルが `.gitignore` に記載されているか
- [ ] キーファイルの権限が最小化されているか（「編集」のみ、「削除」は含まない）
- [ ] Firebase Security Rules で、管理者以外の write が拒否されているか確認済みか
- [ ] ストレージの公開 URL にアクセス権がない（Anonymous user に対しても read 許可）か確認済みか

```bash
# .gitignore 確認
grep -E "service-account-key|GOOGLE_APPLICATION_CREDENTIALS" .gitignore
```

---

## 📝 UI側の対応（次のステップ）

デプロイ完了後、以下を実装してください：

### 1. 人物詳細画面にクレジット表示を追加

```dart
// lib/screens/person_detail_screen.dart 内
Widget _buildImageSection(HistoryPerson person) {
  return Column(
    children: [
      Image.network(
        person.imageUrl,
        height: 300,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 300,
            color: Colors.grey[200],
            child: Icon(Icons.image_not_supported),
          );
        },
      ),
      // クレジット表示（新規追加）
      if (person.imageAttribution != null || person.imageLicense != null)
        Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Text(
            '© ${person.imageAttribution ?? 'Unknown'} / ${person.imageLicense ?? 'License'}',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ),
    ],
  );
}
```

### 2. オフライン画像キャッシング（オプション）

```dart
// Hive を使ってローカルキャッシュ
CachedNetworkImage(
  imageUrl: person.imageUrl,
  placeholder: (context, url) => CircularProgressIndicator(),
  errorWidget: (context, url, error) => Icon(Icons.error),
  cacheManager: CacheManager(
    Config(
      'personImages',
      stalePeriod: Duration(days: 30),
      maxNrOfCacheObjects: 300,
    ),
  ),
);
```

---

## 🆘 トラブルシューティング

詳細は `DEPLOY_PERSON_IMAGES.md` を参照。主な問題と対応：

| 症状 | 原因 | 対応 |
|------|------|------|
| `credentials.Certificate() not found` | 環境変数未設定 | `echo $GOOGLE_APPLICATION_CREDENTIALS` で確認 |
| `HTTP 404 Not Found` | 画像 URL が削除済み | report を確認し、該当レコードを skip |
| `Permission denied` | admin トークンなし | サービスアカウント キーを再生成 |
| スクリプトが hang | ネットワーク遅延 | Ctrl+C で中断、再実行可（冪等） |

---

## 📞 サポート

- **スクリプト質問**: `DEPLOY_PERSON_IMAGES.md` のトラブルシューティングセクション
- **画像ライセンス質問**: `HANDOVER_WIKI_IMAGE_SOURCING.md` の第5章
- **Firebase 設定質問**: Firebase Official Docs (https://firebase.google.com/docs)

---

**作成日**: 2026-09-01  
**最終更新**: 2026-09-01  
**バージョン**: 1.0.0-complete
