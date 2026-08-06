# 歴史図鑑 — ユーザー実施手順書

**状態**: Week 1-2 実装完成  
**実施日**: 2026-06-27 以降  
**所要時間**: 約 30 分

---

## 📋 実施内容

ユーザーが実施すべき作業は以下の 3 つです：

| # | 作業 | 所要時間 | 難易度 |
|---|------|--------|-------|
| 1 | Firebase サービスアカウント設定 | 5分 | ⭐ 簡単 |
| 2 | ガチャマスタデータ投入 | 10分 | ⭐ 簡単 |
| 3 | APK インストール & テスト | 15分 | ⭐ 簡単 |

---

## ✅ 作業 1: Firebase サービスアカウント設定

### Step 1.1: Firebase Console にアクセス

ブラウザで以下 URL を開きます：
```
https://console.firebase.google.com/project/petit-works-education/settings/serviceaccounts/adminsdk
```

**ログイン情報**:
- **メール**: funvestment1@gmail.com （または petitworksdev@gmail.com）
- **パスワード**: [個人で管理]

### Step 1.2: JSON キーをダウンロード

1. Firebase Console で **Settings → Service Accounts** タブを開く
2. **Python** タブの下部にある **「新しい秘密鍵を生成」** ボタンをクリック
3. **「キーペアを新規作成」** ダイアログで **「作成」** をクリック
4. JSON ファイルが自動ダウンロードされます
   - ファイル名: `petit-works-education-*.json`

### Step 1.3: ファイルを配置

ダウンロードした JSON ファイルを以下のフォルダに配置します：

```
H:\マイドライブ\apps\history_zukan\scripts\service-account-key.json
```

**⚠️ 重要**: このファイルは **機密情報** です。GitHub などに commit しないでください。

---

## ✅ 作業 2: ガチャマスタデータ投入

### Step 2.1: PowerShell/Terminal を開く

Windows の場合：
```
Windows キー + R → powershell を入力 → Enter
```

Mac/Linux の場合：
```
ターミナルアプリを開く
```

### Step 2.2: scripts フォルダに移動

```bash
cd "H:\マイドライブ\apps\history_zukan\scripts"
```

### Step 2.3: 依存パッケージをインストール

```bash
npm install
```

**期待される出力:**
```
added XX packages in X.XXs
```

### Step 2.4: ガチャマスタデータを投入

```bash
node upload_gacha_persons.js
```

**期待される出力:**
```
✓ Firebase initialized with project: petit-works-education
✓ Loaded 300 persons from gacha_master.json

=== Uploading 300 Persons to Firestore ===

✓ Uploaded 10 / 300 persons...
✓ Uploaded 20 / 300 persons...
...
✓ Uploaded 300 / 300 persons...
✓ Successfully uploaded all 300 persons to Firestore!
```

**所要時間**: 2-5 分（Firestore の処理時間）

### トラブルシューティング

| エラー | 対処 |
|--------|------|
| `Cannot find module 'firebase-admin'` | `npm install` を再実行 |
| `ENOENT: no such file or directory, open 'service-account-key.json'` | JSON ファイルが配置されていない。Step 1.3 を確認 |
| `Error: Failed to initialize Firebase` | Firebase プロジェクト ID が正しいか確認。`petit-works-education` であることを確認 |
| `Firestore admin request failed` | Firebase インターネット接続を確認。VPN を無効化してみる |

---

## ✅ 作業 3: APK インストール & テスト

### Step 3.1: Android デバイスを USB 接続

1. **Android スマートフォン** を USB ケーブルで PC に接続
2. スマートフォンで **USB デバッグを有効化** します：
   ```
   設定 → 開発者向けオプション → USB デバッグ (ON)
   ```
   ※ 開発者向けオプションが見当たらない場合：
   ```
   設定 → 端末情報 → ビルド番号を 7 回タップ
   → 開発者向けオプションが表示されます
   ```

### Step 3.2: ADB で接続確認

```bash
adb devices
```

**期待される出力:**
```
List of attached devices
XXXXXXXXXXXXX    device
```

デバイスが `device` と表示されていれば OK です。

### Step 3.3: APK をインストール

```bash
adb install -r "H:\マイドライブ\apk\history_zukan-app-release.apk"
```

**期待される出力:**
```
Success
```

**所要時間**: 1-2 分

### Step 3.4: アプリを起動

スマートフォンのホーム画面で **「たくさん知りたくなる歴史図鑑」** をタップして起動します。

### Step 3.5: テストチェックリスト

| # | テスト項目 | 確認 |
|---|-----------|------|
| 1 | アプリが起動してホーム画面が表示される | ✓ |
| 2 | BottomNavigationBar に 7 つのタブが表示される（🌍世界同時、👤自分年表、📍近場、🎴ガチャ、🔥ストリーク、📚図鑑、🎨テーマ） | ✓ |
| 3 | 🎴 ガチャタブをタップ → 「今日の偉人」スクリーン表示 | ✓ |
| 4 | 🎴 ガチャボタンをタップ → スピン → 人物カード表示 | ✓ |
| 5 | ガチャボタンが「明日また来てね」に変更（1 日 1 回限定） | ✓ |
| 6 | 🔥 ストリークタブをタップ → 連続ログイン日数表示 | ✓ |
| 7 | ストリークタイムライン（15 時代）が表示される | ✓ |
| 8 | テーマモード切り替え（AppBar の 🌙/☀️ ボタン） | ✓ |
| 9 | ダークモード切り替えで UI が暗くなる | ✓ |
| 10 | 💾 アプリを閉じて再起動 → ガチャの 1 日 1 回が保持されている | ✓ |

### Step 3.6: トラブルシューティング

| 症状 | 対処 |
|------|------|
| `adb: command not found` | Android SDK をインストール。または Flutter をインストール直後は PATH を再設定 |
| `device not found` | USB デバッグを有効化。USB ケーブルを再接続。別の USB ポートを試す |
| `INSTALL_FAILED_INVALID_APK` | APK ファイルが破損している。APK ビルドをやり直し |
| アプリが起動しない / 真っ白になる | デバイスの logcat を確認：`adb logcat` でエラーメッセージを確認 |

---

## 🎯 テスト完了チェックリスト

作業 1-3 が完了したら、以下をユーザーが確認してください：

- ✓ Firestore に `gacha_persons` コレクションが作成された（300 ドキュメント）
- ✓ APK がスマートフォンにインストールされた
- ✓ アプリが起動してホーム画面が表示された
- ✓ ガチャボタンが機能した
- ✓ ストリークが記録された（1 日 1 回）

---

## 📞 トラブルサポート

作業中にエラーが出た場合は、以下を確認してください：

### Firebase エラー
- 「No matching client found for package name」
  → google-services.json の package name が正しいか確認
  
- 「Project not found」
  → Firebase プロジェクト ID が `petit-works-education` か確認

### npm エラー
- 「npm: command not found」
  → Node.js をインストール
  → PATH に `npm` が登録されているか確認

### adb エラー
- 「adb: command not found」
  → Android SDK Platform-tools をインストール
  → または Flutter SDK に付属の adb を使用：`flutter install`

---

## 📝 完了報告

すべてのテストが完了したら、以下の情報を報告してください：

```
✅ Firebase gacha_persons データ投入完了（300 人）
✅ APK インストール & テスト完了
✅ ガチャ機能動作確認
✅ ストリーク機能動作確認
```

この情報により、AI が次のステップ（診断・クイズ・パズル機能の本格実装）に進むことができます。

---

**所要時間合計**: 約 30 分  
**難易度**: ⭐ 簡単  
**コマンド数**: 5 個

**Last Updated**: 2026-06-27  
**Next Step**: AI による Phase 3 実装（診断・クイズ・パズル Firestore データ投入）
