import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:history_zukan/models/index.dart';


class FirestoreService {
  final FirebaseFirestore _firestore;

  FirestoreService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // ============================================
  // A1: World Synchronous Panorama queries
  // ============================================

  /// Get events for a specific year, grouping by world region
  /// Used for A1: 世界同時パノラマ (World Synchronous Panorama)
  Future<List<HistoryEvent>> getEventsByYearAndRegion(
    int year, {
    int windowDays = 365,
  }) async {
    final startYear = year - (windowDays ~/ 365);
    final endYear = year + (windowDays ~/ 365);

    final snapshot = await _firestore
        .collection('events')
        .where('year', isGreaterThanOrEqualTo: startYear)
        .where('year', isLessThanOrEqualTo: endYear)
        .orderBy('year')
        .orderBy('regionWorld')
        .limit(50)
        .get();

    return snapshot.docs
        .map((doc) => HistoryEvent.fromFirestore(doc))
        .toList();
  }

  /// Get count of events in a specific year
  Future<int> getEventCountByYear(int year) async {
    final snapshot = await _firestore
        .collection('events')
        .where('year', isEqualTo: year)
        .count()
        .get();

    return snapshot.count ?? 0;
  }

  // ============================================
  // A2: Causal Chain queries
  // ============================================

  /// Get a causal chain by ID
  /// Used for A2: 歴史の連鎖モード (Causal Chain Mode)
  Future<CausalChain?> getCausalChain(String chainId) async {
    try {
      final doc =
          await _firestore.collection('causalChains').doc(chainId).get();
      if (!doc.exists) return null;
      return CausalChain.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>);
    } catch (e) {
      print('Error fetching causal chain: $e');
      return null;
    }
  }

  /// Get all causal chains (with pagination)
  Future<List<CausalChain>> getAllCausalChains({int limit = 20}) async {
    final snapshot = await _firestore
        .collection('causalChains')
        .limit(limit)
        .get();

    return snapshot.docs
        .map((doc) => CausalChain.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>))
        .toList();
  }

  // ============================================
  // B1: My Timeline (自分年表) queries
  // ============================================

  /// Get events that occurred at a specific user age
  /// Used for B1: 自分年表 (My Timeline)
  Future<List<HistoryEvent>> getCoincidentEvents(DateTime birthDate) async {
    final currentYear = DateTime.now().year;
    final birthYear = birthDate.year;

    final snapshot = await _firestore
        .collection('events')
        .where('year', isGreaterThanOrEqualTo: birthYear)
        .where('year', isLessThanOrEqualTo: currentYear)
        .limit(100)
        .get();

    return snapshot.docs
        .map((doc) => HistoryEvent.fromFirestore(doc))
        .toList();
  }

  // ============================================
  // B3: Nearby History (ここ歴史) queries
  // ============================================

  /// Get events within a radius of user's location
  /// NOTE: Location data is filtered client-side for privacy
  /// Used for B3: ここ歴史 (Nearby History)
  Future<List<HistoryEvent>> getEventsByRadiusClientSide(
    double userLat,
    double userLng,
    double radiusKm,
  ) async {
    // Fetch all events with location data
    // Client-side filtering to avoid sending exact location to Firestore
    final snapshot = await _firestore
        .collection('events')
        .where('lat', isNotEqualTo: null)
        .where('lng', isNotEqualTo: null)
        .limit(200)
        .get();

    final allEvents = snapshot.docs
        .map((doc) => HistoryEvent.fromFirestore(doc))
        .toList();

    // Filter by radius (Haversine formula)
    return allEvents
        .where((event) {
          if (event.lat == null || event.lng == null) return false;
          final distance = _calculateDistance(
            userLat,
            userLng,
            event.lat!,
            event.lng!,
          );
          return distance <= radiusKm;
        })
        .toList();
  }

  // ============================================
  // Basic Event queries
  // ============================================

  /// Get a single event by ID
  Future<HistoryEvent?> getEvent(String eventId) async {
    try {
      final doc = await _firestore.collection('events').doc(eventId).get();
      if (!doc.exists) return null;
      return HistoryEvent.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>);
    } catch (e) {
      print('Error fetching event: $e');
      return null;
    }
  }

  /// Get all events with pagination
  Future<List<HistoryEvent>> getAllEvents({
    int limit = 50,
    DocumentSnapshot? startAfter,
  }) async {
    Query<Map<String, dynamic>> query =
        _firestore.collection('events').orderBy('year').limit(limit);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    final snapshot = await query.get();

    return snapshot.docs
        .map((doc) => HistoryEvent.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>))
        .toList();
  }

  /// Search events by keyword
  Future<List<HistoryEvent>> searchEvents(String keyword) async {
    final snapshot = await _firestore
        .collection('events')
        .where('searchKeywords', arrayContains: keyword)
        .limit(30)
        .get();

    return snapshot.docs
        .map((doc) => HistoryEvent.fromFirestore(doc))
        .toList();
  }

  /// Get events by era
  Future<List<HistoryEvent>> getEventsByEra(String era) async {
    final snapshot = await _firestore
        .collection('events')
        .where('era', isEqualTo: era)
        .orderBy('year')
        .get();

    return snapshot.docs
        .map((doc) => HistoryEvent.fromFirestore(doc))
        .toList();
  }

  /// Get events by theme
  Future<List<HistoryEvent>> getEventsByTheme(String themeId) async {
    final snapshot = await _firestore
        .collection('events')
        .where('themeIds', arrayContains: themeId)
        .limit(50)
        .get();

    return snapshot.docs
        .map((doc) => HistoryEvent.fromFirestore(doc))
        .toList();
  }

  // ============================================
  // Person queries
  // ============================================

  /// Get a person by ID
  Future<HistoryPerson?> getPerson(String personId) async {
    try {
      final doc = await _firestore.collection('persons').doc(personId).get();
      if (!doc.exists) return null;
      return HistoryPerson.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>);
    } catch (e) {
      print('Error fetching person: $e');
      return null;
    }
  }

  /// Get all persons with AI chat capability (for D1: Phase 2)
  Future<List<HistoryPerson>> getAiChatPersons({int limit = 20}) async {
    final snapshot = await _firestore
        .collection('persons')
        .where('hasAiChat', isEqualTo: true)
        .limit(limit)
        .get();

    return snapshot.docs
        .map((doc) => HistoryPerson.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>))
        .toList();
  }

  // ============================================
  // Notification setup (C2: 今日は何の日)
  // ============================================

  /// Get events for a specific month and day
  /// Used for C2: 今日は何の日 (Daily Notification)
  Future<List<HistoryEvent>> getEventsByMonthDay(int month, int day) async {
    final snapshot = await _firestore
        .collection('events')
        .where('month', isEqualTo: month)
        .where('day', isEqualTo: day)
        .get();

    return snapshot.docs
        .map((doc) => HistoryEvent.fromFirestore(doc))
        .toList();
  }

  /// Get all events with month and day (for scheduling notifications)
  Future<List<HistoryEvent>> getAllEventsWithDateInfo({int limit = 500}) async {
    final snapshot = await _firestore
        .collection('events')
        .where('month', isNotEqualTo: null)
        .where('day', isNotEqualTo: null)
        .limit(limit)
        .get();

    return snapshot.docs
        .map((doc) => HistoryEvent.fromFirestore(doc))
        .toList();
  }

  // ============================================
  // Utility methods
  // ============================================

  /// Calculate distance between two coordinates using Haversine formula
  /// Returns distance in kilometers
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadiusKm = 6371.0;
    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);
    final a = (sin(dLat / 2) * sin(dLat / 2)) +
        (cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2));
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadiusKm * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * 3.141592653589793 / 180.0;
  }

  // ============================================
  // Seed Data Upload (初回セットアップ用)
  // ============================================

  /// 300人の歴史人物を Firestore にアップロード
  Future<void> seedPersonsToFirestore() async {
    print('📚 Firestore に人物データをアップロード中...');

    final persons = SeedData.getPersons();
    int count = 0;
    int failed = 0;

    for (final person in persons) {
      try {
        await _firestore
            .collection('persons')
            .doc(person.id)
            .set(person.toJson());
        count++;

        // 進捗表示（10人ごと）
        if (count % 10 == 0) {
          print('✓ $count / ${persons.length} 人登録完了');
        }
      } catch (e) {
        print('✗ エラー（${person.id}：${person.name}）: $e');
        failed++;
      }
    }

    print('✅ 完了！');
    print('  登録成功: $count 人');
    if (failed > 0) {
      print('  登録失敗: $failed 人');
    }
  }

  /// 歴史イベントを Firestore にアップロード
  Future<void> seedEventsToFirestore() async {
    print('📅 Firestore にイベントデータをアップロード中...');

    final events = SeedData.getEvents();
    int count = 0;
    int failed = 0;

    for (final event in events) {
      try {
        await _firestore
            .collection('events')
            .doc(event.id)
            .set(event.toJson());
        count++;

        if (count % 10 == 0) {
          print('✓ $count / ${events.length} イベント登録完了');
        }
      } catch (e) {
        print('✗ エラー（${event.id}）: $e');
        failed++;
      }
    }

    print('✅ 完了！');
    print('  登録成功: $count イベント');
    if (failed > 0) {
      print('  登録失敗: $failed イベント');
    }
  }

  /// 全ての seed data を一括アップロード
  Future<void> seedAllData() async {
    print('🚀 全データの Firestore アップロードを開始します...\n');

    try {
      await seedPersonsToFirestore();
      print('');
      await seedEventsToFirestore();

      print('\n✨ 全データのアップロードが完了しました！');
    } catch (e) {
      print('❌ アップロード中にエラーが発生しました: $e');
    }
  }
}

// Uses dart:math for trig functions
