# 歴史図鑑 — Flutter Education App

## Project Overview

**たくさん知りたくなる歴史事例・図鑑** - A Flutter mobile app that makes history learning engaging through 10 innovative features (A1-D1) across 3 content axes.

**Status**: Phase 1 MVP development (Week 1-6)  
**Target**: Buy-once ¥300 (iOS/Android)  
**Phase 2**: AI Chat addon (¥120, Claude Haiku integration)

---

## Architecture

### Folder Structure
```
lib/
├── main.dart                    # App entry, Firebase init, Riverpod scope
├── firebase_options.dart        # Firebase config (env-based)
├── models/                      # Data classes (json_serializable)
│   ├── history_event.dart       # Main event model (v1.2 extensions)
│   ├── history_person.dart      # Historical figures
│   ├── causal_chain.dart        # A2: Story chains
│   ├── user_progress.dart       # C1: Progress tracking
│   ├── user_profile.dart        # B1: Birth date (Hive local-only)
│   └── index.dart
├── services/                    # Business logic
│   ├── firestore_service.dart   # Firestore queries (A1-C2)
│   └── index.dart
├── providers/                   # Riverpod providers
│   ├── firestore_provider.dart  # Family providers for each query
│   └── index.dart
├── screens/                     # UI screens (7 tabs + detail)
│   ├── home_screen.dart         # Tab navigation hub
│   └── ...
├── widgets/                     # Reusable UI components
├── constants/                   # App-wide constants
│   ├── app_constants.dart
│   └── index.dart
├── utils/                       # Helpers, extensions
└── config/                      # App configuration
```

### Key Technologies

| Component | Choice | Why |
|-----------|--------|-----|
| State Management | **Riverpod 2.x** | Type-safe, testable, family providers for pagination |
| Backend | **Firestore** | Real-time, geo-queries (B3), offline-first via Hive |
| Local Storage | **Hive** | Fast, non-relational, UserProfile birthDate (privacy) |
| Routing | **GoRouter 12.x** | Deep links, nested navigation, A2 chain viewing |
| Serialization | **json_serializable** | Code generation, type-safe |
| Localization | **intl + flutter_localizations** | Ruby support (小1から対応) |
| Notifications | **flutter_local_notifications** | C2: Annual event reminders (no server needed) |
| TTS | **flutter_tts** (Phase 1.5) | C3: Device-side synthesis, 0.8x slow |
| Location | **geolocator** (Phase 1.5) | B3: Nearby history (client-side privacy filtering) |

---

## Data Model

### HistoryEvent (events collection)

**v1.0-v1.1 fields:**
- `id, title, titleReading, description, year, yearDisplay, era, regionJp, regionWorld, country, locationName`
- `lat, lng` (for B3 queries)
- `themeIds, tags, relatedEventIds, relatedPersonIds`
- `imageUrl, subImageUrl, historyType, isPremium, createdAt, updatedAt`

**v1.2 extensions:**
- `causalChainIds` — A2 chain references
- `quizPoints` — A3 inline prediction points
- `duration` — B2 era length calculation
- `locationCategory, modernAddress` — B3 categorization
- `eraId` — C1 progress tracking
- `month, day` — C2 notification scheduling
- `relatedQuestions` — D1 AI chat context (Phase 2)

### HistoryPerson (persons collection)

- Standard fields: id, name, birthYear, deathYear, description, country
- `hasAiChat` — D1 Phase 2 flag
- `personality, famousQuotes, lifeTimeline` — AI personality data

### CausalChain (causalChains collection)

- `eventIdsInOrder` — Ordered step-by-step chain
- `explanations` — Causal links between steps
- `estimatedReadMinutes` — UX hint

### UserProgress (Firestore + Hive sync)

- `viewedEventIds` — Discovery list
- `eraProgress, themeProgress` — Per-category completion %
- `unlockedMedals` — Achievement tracking

### UserProfile (Hive local-only)

- `uid, birthDate` — **NOT sent to Firestore** (privacy-first)
- `recentlyViewed` — Quick access

---

## Riverpod Providers

**Data Fetching** (`FutureProvider.family`):
- `synchronousWorldProvider(year)` — A1
- `causalChainProvider(chainId)` — A2
- `myTimelineEventsProvider(birthDate)` — B1
- `nearbyEventsProvider((lat, lng, radiusKm))` — B3 (client-side geo)
- `dailyNotificationEventsProvider((month, day))` — C2

**State** (`StateNotifierProvider`):
- `userProgressProvider` — Hive + Firestore sync

---

## Firestore Security Rules

```
match /events/{document=**} {
  allow read: if resource.data.isVerified == true 
              || (!resource.data.isPremium || hasPurchased());
}

match /causalChains/{document=**} {
  allow read: if !resource.data.isPremium || hasPurchased();
}

match /persons/{document=**} {
  allow read: if true;
}

match /userProgress/{uid=**} {
  allow read, write: if request.auth.uid == uid;
}
```

---

## Phase 1 Features (¥300 buy-once)

| Week | Feature | Code | Status |
|------|---------|------|--------|
| 1-2 | **A1: World Sync Panorama** | A1 time slider UI | Task #8 |
| 1-2 | **A2: Causal Chain** | A2 step-by-step navigator | Task #9 |
| 1-3 | **A3: Result Prediction** | A3 inline quiz points | Task #7 |
| 2-5 | **B1: My Timeline** | B1 birth date → coincident events | Task #10 |
| 2-5 | **B2: Duration Scale** | B2 virtual scroll era visualization | Task #11 |
| 2-5 | **B3: Nearby History** | B3 location + 5km radius filter | Task #12 |
| 5-6 | **C1: Progress + Medals** | C1 era completion % + unlock UI | Task #13 |
| 5-6 | **C2: Daily Notification** | C2 local notification schedule | Task #14 |
| 6 | **C3: Bedtime TTS** | C3 slow read-aloud + dark UI | Task #15 |

---

## Setup Instructions

### Prerequisites
- Flutter 3.12+ (SDK in pubspec.yaml)
- Dart 3.12+
- Firebase project (create at console.firebase.google.com)

### Local Development

1. **Create `.env` file:**
   ```
   FIREBASE_API_KEY=your-api-key
   FIREBASE_APP_ID=your-app-id
   FIREBASE_PROJECT_ID=your-project-id
   FIREBASE_AUTH_DOMAIN=your-auth-domain
   FIREBASE_STORAGE_BUCKET=your-storage-bucket
   FIREBASE_MESSAGING_SENDER_ID=your-sender-id
   ```

2. **Get dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run code generation:**
   ```bash
   flutter pub run build_runner build
   ```

4. **Run app:**
   ```bash
   flutter run
   ```

### Android Build (APK)

```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### iOS Build

```bash
flutter build ios --release
# Then open in Xcode to code sign and distribute
```

---

## Implementation Notes

### A1: World Synchronous Panorama
- Query: `getEventsByYearAndRegion(year, windowDays=365)`
- Group events by `regionWorld` on UI
- Caching: Riverpod family with year key
- **⚠️ Avoid**: N+1 queries per region — batch fetch by year window

### A2: Causal Chain
- Store `eventIdsInOrder` array (maintain order, not by timestamp)
- Fetch full event objects in sequence
- **⚠️ Avoid**: Circular chains — validate on Firestore write

### A3: Result Prediction
- `quizPoints` array: characterOffset → position in text
- No scoring/points tracking (avoid Binova failure)
- All responses treated as "learning" with explanation
- **⚠️ Avoid**: Competitive gamification

### B1: My Timeline
- `birthDate` stored **Hive-only**, never to Firestore
- Query: `getCoincidentEvents(birthDate)` → year range
- Support sharing (screenshot, link)
- **⚠️ Avoid**: Sending location/age data to backend

### B2: Duration Scale
- Use `virtual_scrolling` to handle 10,000+ year spans
- Calculate `duration = endYear - startYear` on Era model
- Distribute events proportionally
- **⚠️ Avoid**: Rendering all events at once

### B3: Nearby History
- Fetch events with `lat/lng` (client-side filter only)
- Client calculates distance (Haversine formula, see `firestore_service.dart`)
- Never send user lat/lng to Firestore
- Show radius: 500m, 2km, 5km tiers
- **⚠️ Avoid**: Firestore geoHash queries (complex, privacy risk)

### C1: Progress Tracking
- Increment `eraProgress[eraId]` when event viewed
- Calculate % = viewed / total per era
- Medals unlock at thresholds: complete_era, find_100_cards, etc.
- **⚠️ Avoid**: Real-time collection.count() (expensive)

### C2: Daily Notification
- On app launch, schedule local notifications for all events with `month/day`
- Use `matchDateTimeComponents: DateTimeComponents.dayOfYearTime`
- Annual repeat, no server cost
- Deep link: `event/{eventId}`
- **⚠️ Avoid**: Rescheduling every day

### C3: Bedtime Mode
- `flutter_tts.speak(event.description)` at 0.8x speed
- Dark theme filter (orange-tinted overlay, brightness -40%)
- Auto-stop after 10 min or manual stop
- **⚠️ Avoid**: Cloud TTS (cost, latency); use device

### D1: AI Chat (Phase 2)
- **NOT in Phase 1** — cost/quality gatekeeping
- Will use Claude Haiku (¥120 buy-once, max 100 conversations)
- System prompt: personality, famous quotes, life timeline
- Sync conversation history locally

---

## Testing Strategy

### Unit Tests
- Firestore query mocking (fake_cloud_firestore)
- Riverpod provider caching (ProviderContainer)

### Integration Tests
- 30-50 sample events seed (see Task #16)
- Full user journey per feature

### Manual QA Checklist (Task #17)
- [ ] A1: Slider responds, events update
- [ ] A2: Chain navigation smooth, steps ordered
- [ ] A3: Quiz points appear inline, no scoring bugs
- [ ] B1: Birth date input → timeline populated
- [ ] B2: Scrolling responsive, events positioned correctly
- [ ] B3: Nearby events within 5km (test with mock location)
- [ ] C1: Progress % increments, medal unlocks work
- [ ] C2: Notification fires at correct date/time
- [ ] C3: TTS plays, dark mode readable
- [ ] Offline: Hive cache works, no crashes

---

## Deployment

### Google Play (Android)
1. Build APK/AAB (`flutter build appbundle`)
2. Upload to Play Console
3. Screenshots (6), description, privacy policy
4. **Budget**: ¥300 price, 30% store fee → ¥210 per sale

### App Store (iOS)
1. Export via Xcode (code sign with Apple cert)
2. Upload via Transporter or App Store Connect
3. Screenshots (5 sizes), description, privacy
4. **Budget**: Same 30% fee

### Pre-Launch Checklist
- [ ] Firebase Security Rules deployed
- [ ] Sample data seeded (30-50 events)
- [ ] Notification scheduling tested
- [ ] Offline behavior verified
- [ ] GDPR/privacy policy ready
- [ ] App description + keywords finalized

---

## Code Generation

Run after modifying models:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

Watches:
```bash
flutter pub run build_runner watch
```

Generated files (ignored in git):
- `*.g.dart` (json_serializable)
- `.hive/` (Hive cache)

---

## Future Enhancements (Phase 2+)

- **D1**: Claude Haiku AI chat (¥120)
- **i18n**: English, Chinese translations
- **AR**: Camera overlay for location history
- **Social**: Friend comparison, leaderboard
- **Content**: World history expansion (500+ events)

---

**Last Updated**: 2026-06-14  
**Author**: Claude Code  
**Version**: 1.0.0-phase1-dev
