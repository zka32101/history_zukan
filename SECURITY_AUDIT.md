# セキュリティ・バグ監査レポート

**実施日**: 2026-08-07
**対象**: `history_zukan` リポジトリ全体（Flutter アプリ / Cloud Functions / Firestore Security Rules / CI）
**手法**: 4系統の並列コードレビュー（AI チャット・データ保存 / Firestore・バックエンド・CI / ガチャ・クイズ・パズル・診断 / コア画面）+ 手動検証・修正

> **重要な前提**: この実行環境には Flutter/Dart SDK が入っておらず、`flutter analyze` / `flutter pub get` / `flutter test` を実行して機械的に検証することができませんでした。以下の修正はすべて目視でのコード読解と型・シグネチャの突き合わせによるものです。**マージ前に必ず `flutter pub get && flutter analyze && flutter test` を実行して確認してください。**

---

## 1. 総評

監査の結果、**このリポジトリは現状 `flutter build` が通らない状態**でした（存在しないメソッド呼び出し、型不一致、モデルのバレルエクスポート漏れなど、コンパイルを止める不具合が最低 8 箇所）。あわせて、Firestore のセキュリティルールに実質ノーコストで課金コンテンツを解放できる不備、AI チャット用 Cloud Function がクライアントの言いなりで任意のシステムプロンプトを実行してしまう不備、Android のリリースビルドが debug 鍵で署名される設定など、公開前に必ず塞ぐべきセキュリティ上の穴も見つかりました。

このセッションで最優先修正したのは次の 4 分類です。

1. **コンパイルを止める不具合**（最優先。これが直らないと他の修正も検証不能）
2. **クラッシュ・サイレント破損を招く不具合**（Hive アダプタ未登録など）
3. **セキュリティ上の実害があるもの**（課金バイパス、AIプロキシの乗っ取りリスク、debug署名など）
4. **軽微だが実害のあるロジックバグ**（RNG の予測可能性、UI のクラッシュ導線、判定ロジックの欠陥など）

大規模な未実装機能の完成（後述）は、テスト不能な環境でリスクを増やさないためスコープ外とし、既知の課題として本レポートに明記しました。

---

## 2. 修正済み — コンパイルを止めていた不具合

| # | ファイル | 問題 | 対応 |
|---|---|---|---|
| 1 | `lib/models/index.dart` | `gacha_models.dart` / `login_models.dart` / `puzzle_models.dart` / `quiz_models.dart` / `diagnosis_models.dart` が一切エクスポートされておらず、これらを `models/index.dart` 経由で使う全ファイル（gacha/login-streak/puzzle/quiz/diagnosis の provider・screen 一式）が未定義型エラーになっていた | 5 ファイルを追加エクスポート |
| 2 | `lib/providers/index.dart` | 同様に `gacha_provider.dart` / `login_streak_provider.dart` / `puzzle_provider.dart` / `quiz_provider.dart` / `diagnosis_provider.dart` が未エクスポート。`puzzle_screen.dart` / `diagnosis_screen.dart` はバレル経由でこれらを参照しており未定義エラー | 5 ファイルを追加エクスポート |
| 3 | `lib/services/firestore_service.dart` | `gacha_provider.dart` が呼ぶ `getGachaPersons()` / `logGachaResult()`、`login_streak_provider.dart` が呼ぶ `updateLoginStreak()` が存在しなかった | 3 メソッドを実装（Firestore ルールも合わせて追加） |
| 4 | `lib/services/firestore_service.dart`, `lib/screens/person_list_screen.dart` | `SeedData.getPersons()` / `SeedData.getEvents()` を呼んでいるが、実際の定義は `generateSamplePersons()` / `generateSampleEvents()` | 呼び出し側を正しいメソッド名に修正 |
| 5 | `lib/widgets/theme_badge.dart` | `_getThemeInfo()` の戻り値型が `Map<String, dynamic>` 宣言なのに、実体はレコード型 `(icon:, color:, label:)` を返していた（型不一致でコンパイルエラー） | 戻り値型をレコード型 `({IconData icon, Color color, String label})` に修正し、呼び出し側も `info['color']` → `info.color` に統一 |
| 6 | `lib/screens/person_list_screen.dart` | `HistoryPerson.birthYear` は `String?` なのに `int.tryParse(a.birthYear)`（non-nullable 期待）に直接渡していた | `int.tryParse(a.birthYear ?? '0') ?? 0` に修正 |

---

## 3. 修正済み — クラッシュ / サイレント破損

| # | ファイル | 問題 | 対応 |
|---|---|---|---|
| 7 | `lib/main.dart` | `GachaRecord` / `LoginStreak` / `PersonalityDiagnosisResult` / `QuizNotificationRecord` / `PersonRelationPuzzleRecord` / `UserProfile` / `ChatHistory` はすべて `@HiveType` 付きで `.g.dart` にアダプタが生成済みだが、**どのアダプタも `Hive.registerAdapter()` されておらず、対応する Box も一度も `openBox` されていなかった**。ガチャ・ログインストリーク・パズル・クイズ・診断のいずれかの機能に触れた瞬間 `HiveError` になる状態だった | `main()` 内で全アダプタを登録し、対応する型付き Box を起動時に `openBox` するよう追加 |
| 8 | `lib/providers/progress_provider.dart` | `UserProgress` は `@HiveType` が付いておらずアダプタも存在しないのに `Hive.openBox<UserProgress>()` で型付き Box として書き込もうとしていた（`_saveProgress()` が呼ばれるたび＝カードを1枚見るたびに失敗し、try/catch で握りつぶされて進捗が永続化されない） | `ChatHistoryStorage` と同じ「JSON文字列を `Box<String>` に保存」方式に変更（コード生成不要で安全） |
| 9 | `lib/models/chat_message.dart` | `toString()` が無条件に `content.substring(0, 30)` していて、30文字未満のメッセージ（実運用ではほとんど）で `RangeError` になる | 長さチェックを追加 |
| 10 | `lib/screens/gacha_screen.dart`, `person_chat_screen.dart`, `my_timeline_screen.dart` | `await` の後に `mounted` チェックなしで `setState` / コントローラ操作をしており、画面遷移中に呼ばれると `setState() called after dispose()` 等でクラッシュ | 3箇所とも `if (!mounted) return;` を追加 |

---

## 4. 修正済み — セキュリティ

| # | 箇所 | 問題 | 対応 |
|---|---|---|---|
| 11 | `firestore.rules` | `hasPurchased()` が実際には「匿名ログインでない」ことしかチェックしておらず、無料のメール/パスワードアカウントを作るだけで premium コンテンツ（`causalChains`）を無償で読めた | `request.auth.token.premium == true`（購入検証後にサーバー側で付与するカスタムクレーム）に変更。**購入検証ロジック自体は未実装のため、実装時は Cloud Functions 側でレシート/Play Billing検証 → カスタムクレーム付与のフローを作る必要あり** |
| 12 | `firestore.rules` | `events` コレクションが `allow read: if true`（コメント「テスト段階」）になっており、CLAUDE.md が定義する「`isPremium` なら購入必須」という設計と食い違っていた。`isPremium: true` の event が実在する | CLAUDE.md 記載のルール（`isVerified \|\| !isPremium \|\| hasPurchased()`）に修正 |
| 13 | `firestore.rules` | `causalChains/{chainId}/details` サブコレクションのルールで `{chainId}` を変数展開せずリテラル文字列として `get()` していた（常に存在しないパスを参照 = 常にエラー） | `$(chainId)` / `$(database)` に修正 |
| 14 | `functions/index.js`, `lib/services/person_chat_service.dart` | Cloud Function `personChat` がクライアントから送られた `systemPrompt` を検証なしにそのまま Claude に渡していた。ログイン済み（匿名ログイン可）の任意のクライアントが `systemPrompt` を自由に書き換えて呼び出せば、アプリの意図（子ども向け歴史人物ロールプレイ）を無視した任意プロンプトを、開発者の Anthropic API 予算で実行できてしまう | クライアントは `personId` のみ送信し、Cloud Function 側で Firestore の `persons/{personId}` を読んで systemPrompt をサーバー側で構築するよう変更 |
| 15 | `functions/index.js` | 「100会話まで」の課金アドオン上限がクライアント（Hive のローカルカウンタ）だけで管理されており、アプリのストレージを消す/直接 callable を叩くだけで無制限に呼び出せた | `chatQuotas/{uid}` を Firestore トランザクションでサーバー側カウントし、上限到達時は `resource-exhausted` を返すよう追加。対応する Firestore ルール（クライアントからの書き込みを禁止、読み取りのみ許可）も追加 |
| 16 | `android/app/build.gradle.kts` | リリースビルドの署名設定が `signingConfigs.getByName("debug")` に固定されており、`flutter build apk --release` が **常に debug 鍵で署名される**設定だった（このままストアに提出すると危険） | `key.properties`（gitignore 済み）があればそちらを使う release 署名設定を追加し、無い場合のみ debug 鍵にフォールバック（ローカル開発を壊さないため）。`android/key.properties.example` に手順を追加 |
| 17 | `.gitignore` | `scripts/upload_gacha_persons.js` が読み込む Firebase Admin SDK の秘密鍵 `service-account-key.json`（Firestore への無制限読み書き権限）が gitignore 対象外だった | 追加（`service-account-key.json`, `scripts/.env`, `key.properties`） |
| 18 | `.github/workflows/deploy.yml` | ワークフローに `permissions` 指定がなく、リポジトリのデフォルト権限（環境によっては書き込み可）で実行されていた | `permissions: contents: read` を明示（このワークフローはビルドのみで書き込み不要） |
| 19 | `firestore.rules` | 新規追加した `gacha_persons` / `gachaLogs` / `loginStreaks` コレクションに対応するルールが存在しなかった（上記 #3 のメソッド追加に伴い新設） | 適切なルールを追加（マスタデータは公開読み取り、ログ類は本人専用） |

**未対応（要判断/要外部情報のため保留）**:
- GitHub Actions の `actions/checkout@v3` / `subosito/flutter-action@v2` を commit SHA 固定にする件（プロキシ制限で正しい SHA を取得できず、誤ったハッシュを埋め込むリスクの方が高いため見送り）。次回、通常のネット環境で `git ls-remote` 等により正しい SHA を確認のうえ固定してください。

---

## 5. 修正済み — ロジックバグ（セキュリティ以外）

| # | ファイル | 問題 | 対応 |
|---|---|---|---|
| 20 | `lib/providers/gacha_provider.dart` | ガチャの「乱数」が `DateTime.now().millisecondsSinceEpoch % 1000` という時計依存の低エントロピー値で、`dart:math` の `Random` が一切使われていなかった。理論上は実行タイミングを操作すれば結果を誘導できる。またマスタデータが空のとき `persons.last` で無条件クラッシュ | `Random().nextDouble()` に変更、空リストのガード追加 |
| 21 | `lib/services/firestore_service.dart` | `getEventsByRadiusClientSide` / `getAllEventsWithDateInfo` が異なる2フィールドに `!=` フィルタをかけており、Firestore はこれをサポートしないため実行時に `FAILED_PRECONDITION` で落ちる（B3ここ歴史・C2通知機能が実質使用不能） | 片方のフィールドのみ Firestore 側でフィルタし、もう片方はクライアント側で絞り込むよう修正。あわせて try/catch も追加 |
| 22 | `lib/services/firestore_service.dart` | `getAllCausalChains()` が無条件の collection query で、`causalChains` のルールが per-document 判定のため、購入していない/匿名ユーザーでは Firestore 側に拒否される | `isPremium == false` で絞り込み、購入済みユーザー向けの premium チェーンは単一ドキュメント取得（`getCausalChain`）で個別に扱う設計に修正 |
| 23 | `lib/providers/progress_provider.dart` | メダル判定の差分チェック `if (medals != state.unlockedMedals)` が、`Map` が `==` をオーバーライドしないため常に `true`（＝毎回無条件で再描画・Hive書き込みが走る、実質的なデッドコード） | 値の等価性を見る `_mapEquals` ヘルパーに置換 |
| 24 | `lib/providers/puzzle_provider.dart` | パズルの正誤判定が `puzzle.commonTrait.contains(answer)` 等の部分一致で、`answer` が空文字/空白のときに `String.contains('')` が常に `true` を返すため、未入力でも「正解」判定になりうる不具合。加えて `commonTrait.split(' ')[0]` は日本語文（スペースなし）では文全体になり意図と乖離 | トリム＋最低文字数チェックを追加し、スペース除去した文字列同士の包含判定に修正（根本的な自由記述の厳密採点は別課題として残置、コメントに明記） |
| 25 | `lib/screens/puzzle_screen.dart` | 送信ボタンの活性判定が `progress.answer.isEmpty` のみで、半角スペース1文字だと非空扱いになりボタンが押せてしまう | `.trim().isEmpty` に修正 |
| 26 | `lib/widgets/person_card.dart` | `birthYear` が `null` のとき `'null - 現代'` のような文字列がそのまま画面に表示される | `birthYear ?? '不明'` を追加 |
| 27 | `lib/screens/card_detail_screen.dart` | `eventId` が seed データに見つからない場合、無関係な「本能寺の変」のハードコードされたカードにサイレントにフォールバックしていた。因果チェーン経由で不正な ID に遷移した際、ユーザーは全く違う歴史カードを見せられていることに気づけない | 「イベントが見つかりませんでした」の明示的なエラー画面に変更（`PersonDetailScreen` と同じパターン） |
| 28 | `lib/screens/card_detail_screen.dart` | A3クイズポイントの正誤表示が、ユーザーの回答内容に関わらず常に緑のチェックマーク（「正解」）を表示していた | 実際の回答と `correctAnswer` を比較し、不一致時はオレンジの info アイコンに変更（スコアリングは行わない設計は維持） |
| 29 | `lib/screens/causal_chain_screen.dart` | 因果ドミノの各ステップが `イベント ID: event_j001` のような内部IDの生文字列を表示するだけで、実際のイベント内容（タイトル・説明）が一切表示されていなかった | `seedEventByIdProvider` でイベントを解決し、タイトル・年表示・説明を表示するよう修正 |
| 30 | `lib/screens/diagnosis_screen.dart` | 診断クイズが、10問目の選択肢を選んだ瞬間（`progress.isComplete` が true になった時点）に「結果を計算中です...」という戻れないデッドエンド画面へ即座に遷移。実際にはスコア計算・保存（`submitDiagnosisProvider`）が一度も呼ばれておらず、`diagnosisProgressNotifierProvider` のリセットもされないため、次回以降も診断を再開できなかった | 遷移判定を `progress.isComplete` から明示的な `_isSubmitting` フラグに変更し、`_submitAnswers` で実際に `submitDiagnosisProvider` を呼んで結果を保存 → 前回結果プロバイダを invalidate → 進捗をリセット → 結果画面へ pop するよう実装。あわせて「次へ」ボタンの活性判定が「一度でも何か回答したか」だけを見ていた誤りも、「現在の設問に回答済みか」に修正 |

---

## 6. 既知の課題（今回は未対応・スコープ外）

Dart/Flutter のツールチェインが使えない環境で大規模な機能実装を行うと検証不能なリグレッションを埋め込むリスクが高いため、以下は**意図的に未着手**としました。次回、`flutter analyze`/`flutter test` が使える環境で対応することを推奨します。

- **B3 ここ歴史（`nearby_history_screen.dart`）**: UI が完全にハードコードされたモックデータ（固定4件・固定距離）で、実際の `nearbyEventsProvider`（Haversine計算は実装済みで正しい）を一切呼んでいません。「500m/2km/5km」の距離チップも `SnackBar` を出すだけで実際のフィルタリングは行われていません。
- **クイズ／パズル／診断の「日替わり・週替わり」ローテーション**: `todayQuizEventsProvider` / `todayPuzzleProvider` / `currentWeeklyQuizProvider` はいずれも日付に関係なく同一のダミーデータを返す実装のままです（コード内コメントに「暫定版」と明記あり）。
- **診断結果の人物名**: `diagnosisScoreProvider` の `resultName` が `'タイプ $topPersonId'` というプレースホルダーのまま（実際の人物名を Firestore/seed から引く実装が必要）。
- **ガチャの確率非開示**: `gacha_master.json` のレア度別出現率がアプリ内のどこにも表示されていません。子ども向けアプリという性質上、ガチャ的UIを維持するなら確率表示の追加を推奨します（現状は課金と紐付いていないため法規制の対象ではありませんが、将来のベストプラクティスとして）。
- **ガチャ／ログインストリークの日付判定**: すべて `DateTime.now()` をそのまま信頼しており、端末の時計を進める/戻すことで1日1回制限を回避できます（金銭が絡まないため実害は小さいですが、認識のうえ設計してください）。
- **GitHub Actions の SHA 固定**: 上記4章末尾を参照。
- **`applicationId` / Bundle ID が `com.example.history_zukan` のまま**: プレースホルダーのため、ストア申請前に実際のIDへ変更が必要です。
- **本番ビルドでの `print()` 使用**: `firestore_service.dart` 等に多数の `print()` が残っています（機密情報は含みませんが、リリースビルドでも出力されるため `debugPrint`/ロガーへの置き換えを推奨）。
- **LICENSE ファイルが存在しない**: 公開リポジトリとして配布するなら、屋号名義（本名を避ける）での LICENSE 追加を推奨します。

---

## 7. マージ前に必ず行うこと

1. `flutter pub get`
2. `flutter pub run build_runner build --delete-conflicting-outputs`（`.g.dart` の再生成。今回は手動編集のみで `.g.dart` 自体は変更していませんが、依存関係の変化がないか確認してください）
3. `flutter analyze` — このレポートの修正が実際にコンパイルを通すか確認
4. `flutter test`
5. Firestore ルールは `firebase emulators:start --only firestore` 等でスモークテスト
6. Cloud Functions (`functions/index.js`) は `personId` ベースの新しいリクエスト形式にクライアントが追従しているため、デプロイ順序に注意（クライアントを先に更新する場合は Cloud Function 側が旧 `systemPrompt` 形式のリクエストも一時的に受け付けられるようにするなど、後方互換を検討）

---

_このレポートは Claude Code によるコード監査結果です。_
