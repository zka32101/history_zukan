/// Phase 1 QA Checklist for 歴史図鑑 MVP
/// All 10 features (A1-D1, minus D1 Phase 2) must pass

class QAChecklist {
  static const String description = '''
PHASE 1 QA CHECKLIST
====================

Total Features to Test: 9 (A1-C3, excluding D1 Phase 2)
Estimated Time: 45-60 minutes
Test Data: Sample events in lib/utils/seed_data.dart

TEST ENVIRONMENT
================
- Device: Android/iOS emulator or physical device
- App Build: flutter build apk --release (or iOS equivalent)
- Network: Online (Firebase) + Offline (Hive cache)
- Sample Data: 6 historical events + 2 causal chains seeded

═══════════════════════════════════════════════════════════

A1: WORLD SYNCHRONOUS PANORAMA (世界同時パノラマ)
═══════════════════════════════════════════════════════════

□ Time slider responds to touch
  - Slider moves smoothly from -1000 to 2000
  - Year display updates in real-time
  - 1582年を選択して本能寺の変を確認

□ Events by region display correctly
  - Events grouped by regionWorld (Asia, Europe, etc.)
  - Event count updates with year change
  - Sample: 1582年 = 日本・アジア・ヨーロッパのイベント表示

□ Event cards are tappable
  - Tap event → detail screen
  - Event data populated correctly

□ Visual polish
  - Layout responsive (landscape/portrait)
  - No crashes with extreme years (-1000 or 2000)
  - Loading indicator appears during fetch


A2: CAUSAL CHAINS (因果ドミノ)
═══════════════════════════════════════════════════════════

□ Chain navigation works
  - Sample chain: 本能寺 → 秀吉 → 江戸幕府成立
  - Back/Next buttons navigate steps
  - Progress indicator accurate

□ Step explanations display
  - Each step shows event ID + explanation
  - "次に何が起きたか" hint on intermediate steps
  - Final step shows completion message

□ Integration with card detail
  - Card detail has "このストーリーをたどる" button
  - Button only appears if event has causalChainIds
  - Tapping navigates to chain screen

□ User experience
  - No crashes when navigating steps
  - Back to card detail closes chain screen


A3: RESULT PREDICTION (結末よそう)
═══════════════════════════════════════════════════════════

□ Quiz points appear inline
  - Card detail shows 3-choice prediction panels
  - Sample: 本能寺の変「このあと光秀はどうなった？」
  - Questions pause reading flow naturally

□ Answer selection works
  - User can select A/B/C
  - Selection triggers reveal animation

□ Explanation displays after answer
  - ✓/✗ feedback (no scoring, just learning)
  - Correct answer highlighted
  - Explanation text clear and helpful

□ No scoring/ranking
  - Confirm: users are NOT ranked by quiz performance
  - Focus is on "learning from being wrong"


B1: MY TIMELINE (自分年表)
═══════════════════════════════════════════════════════════

□ Birth date input works
  - First-time users see birth date picker
  - Calendar picker allows 1950-2019
  - Selected date displays: 「20XX年Y月Z日生まれ」

□ Timeline display correct
  - Shows user age progression: 0歳 → 5歳 → 15歳 → 現在
  - Current age calculated correctly
  - Timeline entries card-formatted

□ Coincident events displayed
  - 「同じ年: 1603年の歴史イベント」表示
  - Sample: User born 2010 → 関ヶ原(1600)等の歴史表示

□ Share functionality
  - "スクリーンショットをシェア" button present
  - Tapping shows Phase 1.5 note (not yet implemented)

□ Offline state
  - Birth date persists in Hive after app restart
  - No Firebase call needed for timeline


B2: DURATION SCALE (時代の長さ体感)
═══════════════════════════════════════════════════════════

□ Scroll experience mode
  - Slider shows % progress
  - Sample era: 縄文時代（10,000年）
  - Events appear at scroll intervals
  - 「⭐ XXXX年頃」event markers display

□ Comparison mode (Tab 2)
  - Bar chart shows era duration comparison
  - Longest era (縄文) = widest bar
  - Shorter eras (昭和) = much narrower
  - Label shows year count: 「XXX年」

□ Visual clarity
  - Labels readable
  - Bars scale proportionally
  - No overflow on small screens

□ Educational impact
  - After scrolling縄文時代, user feels "this is LONG"
  - Comparison shows contrast vividly


B3: NEARBY HISTORY (ここ歴史)
═══════════════════════════════════════════════════════════

□ Permission flow works
  - AlertDialog appears on first open
  - [許可しない] / [許可する] buttons
  - If denied: disabled screen + "位置情報を有効にする" button

□ Mock location active (for QA)
  - Permission granted → Kyoto location shown
  - 「京都府京都市中京区」displayed
  - Lat/Lng coordinates shown (mock: 34.97, 135.76)

□ Distance filtering works
  - Events grouped by radius: 500m / 2km / 5km
  - Each section shows event count chip
  - Sample events:
    - 本能寺跡 (0.3km) → 500m section
    - 清水寺 (2.1km) → 2km section
    - 伏見稲荷 (3.8km) → 5km section

□ Event cards functional
  - Category chip (Historic Site, Temple, Shrine)
  - Distance badge (「X.Xkm」)
  - [詳細] button navigates to event detail

□ Privacy verified
  - ⚠️ Confirm: user location NOT sent to Firestore
  - Confirm: geoHash filtering is client-side only
  - Distance calculation done locally


C1: ENCYCLOPEDIA PROGRESS (図鑑コンプリート率 + メダル)
═══════════════════════════════════════════════════════════

□ Progress widget displays on home
  - Appears at top of all tabs
  - Shows 「発見度 X% (Y/200)」
  - Progress bar accurate

□ Medal display
  - Medal section shows unlocked badges
  - Sample: 「100カード発見」, 「完全図鑑」
  - Background color (amber) visually distinct

□ Stat tracking
  - Confirm internal structure:
    - viewedEventIds list tracked
    - eraProgress Map incremented on view
    - Hive persistence works after restart

□ Medal unlocking logic
  - No medals visible initially (0 views)
  - Sample unlock: view 10 events in one era → unlock 「時代コンプ」
  - Note: Phase 1 may not unlock organically; seed via code for testing


C2: DAILY NOTIFICATIONS (今日は何の日)
═══════════════════════════════════════════════════════════

□ Initialization on app startup
  - NotificationService initializes in main.dart
  - Sample events with month/day scheduled
  - No crashes during scheduling

□ Local notification scheduling
  - Sample event: 本能寺の変 (6月21日)
  - Notification should fire at 9:00 AM on 6/21 annually
  - Device notification permission granted

□ Deep link on tap
  - Tap notification → card detail screen (or show "Deep link not yet wired")
  - Payload includes event_id

□ No server required
  - Confirm: all scheduling is local, not Firebase Cloud Messaging
  - Works fully offline after initialization


C3: BEDTIME HISTORY (寝る前歴史) [NOTE: flutter_tts removed, DEFER]
═══════════════════════════════════════════════════════════

□ DEFER TO PHASE 1.5 (flutter_tts version compatibility issue)
  - UI placeholder present on Favorites tab
  - [🌙 寝る前に聞く] button visible
  - Tapping shows: 「Task #15: C3 実装予定」

□ Expected Phase 1.5 features (not tested in Phase 1):
  - TTS playback at 0.8x speed
  - Dark mode + warm color filter
  - Auto-stop after 10 minutes


═══════════════════════════════════════════════════════════
INTEGRATION TESTS
═══════════════════════════════════════════════════════════

□ Navigation between screens
  - Home → each tab screen
  - Card detail from A1, B1, B3
  - Back buttons work
  - No navigation crashes

□ State persistence
  - Birth date (B1) persists after app restart
  - Progress/medals (C1) persist after app restart
  - Sample data (seed_data.dart) loads on first run

□ Offline behavior
  - Core features work without Firebase
  - Sample data loads from Hive
  - Notification scheduling works offline

□ Performance
  - App launch time < 3 seconds
  - Screen transitions smooth (no jank)
  - Slider interactions responsive

□ Error handling
  - No unhandled exceptions in console
  - Error screens display gracefully if data missing
  - Null-safety: no red screens from null dereferences

□ Visual consistency
  - Material Design 3 applied
  - Colors match CLAUDE.md theme
  - Font sizes readable
  - Spacing consistent across screens


═══════════════════════════════════════════════════════════
FINAL CHECKLIST
═══════════════════════════════════════════════════════════

□ All 9 features manually tested ✓ or deferred to Phase 1.5
□ Sample data (6 events) seeded and visible
□ No console errors or warnings
□ App runs to completion without crashes
□ Navigation between all screens works
□ State persists across app restarts (Hive)

If all above pass: PHASE 1 MVP IS COMPLETE AND READY FOR GOOGLE PLAY/APP STORE SUBMISSION


═══════════════════════════════════════════════════════════
KNOWN ISSUES / PHASE 1.5 DEFERRED
═══════════════════════════════════════════════════════════

1. firebase_options.dart uses env-based config (needs real Firebase creds for prod)
2. C3 (TTS) deferred: flutter_tts version incompatibility (will resolve in Phase 1.5)
3. D1 (AI Chat) not in Phase 1: Claude Haiku integration Phase 2+
4. Geolocator removed: client-side mock location used for B3 testing
5. AR Camera (B3 future) not implemented
6. Multi-language support: framework ready, content Japanese-only in Phase 1

═══════════════════════════════════════════════════════════
''';
}
