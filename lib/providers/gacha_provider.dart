import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:history_zukan/models/index.dart';
import 'package:history_zukan/services/firestore_service.dart';

// =========================================
// Gacha Providers
// =========================================

/// Hive gacha_records ボックスプロバイダー
final gachaRecordBoxProvider = Provider<Box<GachaRecord>>((ref) {
  return Hive.box<GachaRecord>('gacha_records');
});

/// Firestore gacha マスタデータプロバイダー
final gachaMasterProvider = FutureProvider<List<GachaPerson>>((ref) async {
  final service = FirestoreService();
  return service.getGachaPersons();
});

/// 今日のガチャ利用可能状態
final todayGachaAvailableProvider = FutureProvider<GachaAvailability>((ref) async {
  final box = ref.watch(gachaRecordBoxProvider);
  final today = DateTime.now();
  final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

  // 今日のガチャ記録があるかチェック
  final hasGachaToday = box.values.any(
    (record) => record.obtainedDate.toString().startsWith(todayStr),
  );

  if (hasGachaToday) {
    return GachaAvailability(canGacha: false, remainingTime: 0);
  }

  // 次のガチャまでの時間計算（24時間）
  GachaRecord? lastGacha;
  for (final record in box.values) {
    if (lastGacha == null || record.obtainedDate.isAfter(lastGacha.obtainedDate)) {
      lastGacha = record;
    }
  }
  if (lastGacha != null) {
    final nextGacha = lastGacha.obtainedDate.add(Duration(days: 1));
    final now = DateTime.now();
    if (now.isBefore(nextGacha)) {
      final remaining = nextGacha.difference(now).inMilliseconds;
      return GachaAvailability(canGacha: false, remainingTime: remaining);
    }
  }

  return GachaAvailability(canGacha: true, remainingTime: 0);
});

/// コレクション図鑑プロバイダー
final collectionProvider = FutureProvider<List<CollectionCard>>((ref) async {
  final records = ref.watch(gachaRecordBoxProvider).values.toList();
  final master = await ref.watch(gachaMasterProvider.future);

  // 重複カウント（同じ personId を複数回取得した場合）
  final obtainedMap = <String, GachaRecord>{};
  for (final record in records) {
    obtainedMap[record.personId] = record;
  }

  return master.map((m) {
    final obtained = obtainedMap[m.personId];
    return CollectionCard(
      personId: m.personId,
      name: m.name,
      country: m.country,
      rarity: m.rarity,
      isObtained: obtained != null,
      obtainedDate: obtained?.obtainedDate,
    );
  }).toList();
});

/// ガチャコレクション統計プロバイダー
final gachaStatisticsProvider = FutureProvider<GachaStatistics>((ref) async {
  final collection = await ref.watch(collectionProvider.future);
  final records = ref.watch(gachaRecordBoxProvider).values.toList();

  final rarityCount = <int, int>{
    4: 0, // SSR
    3: 0, // SR
    2: 0, // R
    1: 0, // N
  };

  for (final card in collection) {
    if (card.isObtained) {
      rarityCount[card.rarity] = (rarityCount[card.rarity] ?? 0) + 1;
    }
  }

  final duplicates = records.where((r) => r.isDuplicate).length;

  return GachaStatistics(
    totalObtained: records.length,
    totalDuplicates: duplicates,
    rarityCount: rarityCount,
  );
});

/// ガチャ実行StateNotifier
class GachaExecutor extends StateNotifier<AsyncValue<GachaResult>> {
  final Ref ref;

  GachaExecutor(this.ref) : super(const AsyncValue.loading());

  Future<void> executeGacha() async {
    try {
      state = const AsyncValue.loading();

      final available = await ref.read(todayGachaAvailableProvider.future);
      if (!available.canGacha) {
        state = AsyncValue.error(
          Exception('今日のガチャは既に実施済みです'),
          StackTrace.current,
        );
        return;
      }

      // マスタデータから確率に応じて人物を選択
      final master = await ref.read(gachaMasterProvider.future);
      final selectedPerson = _selectPersonByWeight(master);

      // 重複チェック
      final box = ref.read(gachaRecordBoxProvider);
      final isDuplicate = box.values.any((r) => r.personId == selectedPerson.personId);

      // Hive に記録
      final record = GachaRecord(
        id: '${selectedPerson.personId}_${DateTime.now().millisecondsSinceEpoch}',
        personId: selectedPerson.personId,
        rarity: selectedPerson.rarity,
        obtainedDate: DateTime.now(),
        isDuplicate: isDuplicate,
      );

      await box.add(record);

      // Firestore にもログ
      final service = FirestoreService();
      await service.logGachaResult('anonymous', record); // TODO: uid を取得

      state = AsyncValue.data(
        GachaResult(
          person: selectedPerson,
          isDuplicate: isDuplicate,
          rarityLabel: selectedPerson.rarityLabel,
        ),
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// 確率重み付けに基づいて人物を選択
  GachaPerson _selectPersonByWeight(List<GachaPerson> persons) {
    final random = (DateTime.now().millisecondsSinceEpoch % 1000) / 1000.0;
    double totalWeight = 0;
    double cumulativeWeight = 0;

    // 総重みを計算
    for (final person in persons) {
      totalWeight += person.weight;
    }

    // 確率に従って選択
    double threshold = random * totalWeight;
    for (final person in persons) {
      cumulativeWeight += person.weight;
      if (threshold <= cumulativeWeight) {
        return person;
      }
    }

    return persons.last; // フォールバック
  }
}

/// ガチャ実行プロバイダー
final gachaExecutorProvider =
    StateNotifierProvider<GachaExecutor, AsyncValue<GachaResult>>((ref) {
  return GachaExecutor(ref);
});
