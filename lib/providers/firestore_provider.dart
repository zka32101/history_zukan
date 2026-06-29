import 'package:history_zukan/services/firestore_service.dart';
import 'package:history_zukan/services/notification_service.dart';
import 'package:riverpod/riverpod.dart';

/// Singleton provider for FirestoreService
final firestoreServiceProvider = Provider((ref) {
  return FirestoreService();
});

/// Singleton provider for NotificationService (C2)
final notificationServiceProvider = Provider((ref) {
  return NotificationService();
});

/// A1: Get events for world synchronous panorama
final synchronousWorldProvider = FutureProvider.family<List, int>(
  (ref, year) async {
    final service = ref.watch(firestoreServiceProvider);
    return service.getEventsByYearAndRegion(year);
  },
);

/// A2: Get causal chain
final causalChainProvider = FutureProvider.family<dynamic, String>(
  (ref, chainId) async {
    final service = ref.watch(firestoreServiceProvider);
    return service.getCausalChain(chainId);
  },
);

/// B1: Get coincident events for my timeline
final myTimelineEventsProvider = FutureProvider.family<List, DateTime>(
  (ref, birthDate) async {
    final service = ref.watch(firestoreServiceProvider);
    return service.getCoincidentEvents(birthDate);
  },
);

/// B3: Get nearby events
final nearbyEventsProvider = FutureProvider.family<List, (double, double, double)>(
  (ref, params) async {
    final service = ref.watch(firestoreServiceProvider);
    final (lat, lng, radiusKm) = params;
    return service.getEventsByRadiusClientSide(lat, lng, radiusKm);
  },
);

/// Get all events with pagination
final allEventsProvider = FutureProvider<List>(
  (ref) async {
    final service = ref.watch(firestoreServiceProvider);
    return service.getAllEvents(limit: 50);
  },
);

/// Get single event
final eventProvider = FutureProvider.family<dynamic, String>(
  (ref, eventId) async {
    final service = ref.watch(firestoreServiceProvider);
    return service.getEvent(eventId);
  },
);

/// Search events
final searchEventsProvider = FutureProvider.family<List, String>(
  (ref, keyword) async {
    final service = ref.watch(firestoreServiceProvider);
    return service.searchEvents(keyword);
  },
);

/// Get events by era
final eventsByEraProvider = FutureProvider.family<List, String>(
  (ref, era) async {
    final service = ref.watch(firestoreServiceProvider);
    return service.getEventsByEra(era);
  },
);

/// Get events by theme
final eventsByThemeProvider = FutureProvider.family<List, String>(
  (ref, themeId) async {
    final service = ref.watch(firestoreServiceProvider);
    return service.getEventsByTheme(themeId);
  },
);

/// C2: Get events for daily notifications
final dailyNotificationEventsProvider = FutureProvider.family<List, (int, int)>(
  (ref, params) async {
    final service = ref.watch(firestoreServiceProvider);
    final (month, day) = params;
    return service.getEventsByMonthDay(month, day);
  },
);

/// Get all events with date info for notification scheduling
final allEventsWithDateProvider = FutureProvider<List>(
  (ref) async {
    final service = ref.watch(firestoreServiceProvider);
    return service.getAllEventsWithDateInfo();
  },
);

/// Get person
final personProvider = FutureProvider.family<dynamic, String>(
  (ref, personId) async {
    final service = ref.watch(firestoreServiceProvider);
    return service.getPerson(personId);
  },
);

/// Get all persons with AI chat (Phase 2)
final aiChatPersonsProvider = FutureProvider<List>(
  (ref) async {
    final service = ref.watch(firestoreServiceProvider);
    return service.getAiChatPersons();
  },
);

/// Get event count by year
final eventCountByYearProvider = FutureProvider.family<int, int>(
  (ref, year) async {
    final service = ref.watch(firestoreServiceProvider);
    return service.getEventCountByYear(year);
  },
);

/// Get all causal chains
final allCausalChainsProvider = FutureProvider<List>(
  (ref) async {
    final service = ref.watch(firestoreServiceProvider);
    return service.getAllCausalChains();
  },
);
