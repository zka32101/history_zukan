import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:history_zukan/models/index.dart';
import 'package:history_zukan/services/firestore_service.dart';

// =========================================
// Login Streak Providers
// =========================================

/// Hive login_streaks ボックスプロバイダー
final loginStreakBoxProvider = Provider<Box<LoginStreak>>((ref) {
  return Hive.box<LoginStreak>('login_streaks');
});

/// 現在のログインストリーク状態
final currentLoginStreakProvider = FutureProvider<LoginStreak?>((ref) async {
  final box = ref.watch(loginStreakBoxProvider);

  // Hive から取得（キー: 'current'）
  if (box.containsKey('current')) {
    return box.get('current') as LoginStreak?;
  }

  return null;
});

/// ログイン日数チェック結果
final loginCheckResultProvider = FutureProvider<LoginCheckResult>((ref) async {
  final box = ref.watch(loginStreakBoxProvider);
  final currentStreak = await ref.watch(currentLoginStreakProvider.future);

  final today = DateTime.now();
  final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

  if (currentStreak == null) {
    // 初回ログイン
    final newEra = ERAS_JOURNEY[0]; // 縄文
    return LoginCheckResult(
      isNewDay: true,
      consecutiveDays: 1,
      totalLoginDays: 1,
      eraChanged: true,
      newEra: newEra,
    );
  }

  final lastLoginStr = '${currentStreak.lastLoginDate.year}-${currentStreak.lastLoginDate.month.toString().padLeft(2, '0')}-${currentStreak.lastLoginDate.day.toString().padLeft(2, '0')}';

  final isNewDay = todayStr != lastLoginStr;

  if (!isNewDay) {
    // 同じ日に既にログイン
    return LoginCheckResult(
      isNewDay: false,
      consecutiveDays: currentStreak.consecutiveDays,
      totalLoginDays: currentStreak.totalLoginDays,
      eraChanged: false,
    );
  }

  // 新しい日のログイン
  final yesterday = today.subtract(Duration(days: 1));
  final yesterdayStr = '${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}';

  final newConsecutiveDays = lastLoginStr == yesterdayStr
      ? currentStreak.consecutiveDays + 1
      : 1; // ストリーク途切れ（リセット）

  final newTotalLoginDays = currentStreak.totalLoginDays + 1;

  // 新しい時代に到達したかチェック
  final previousEra = getEraByDays(currentStreak.consecutiveDays);
  final newEra = getEraByDays(newConsecutiveDays);
  final eraChanged = previousEra.id != newEra.id;

  return LoginCheckResult(
    isNewDay: true,
    consecutiveDays: newConsecutiveDays,
    totalLoginDays: newTotalLoginDays,
    eraChanged: eraChanged,
    newEra: eraChanged ? newEra : null,
  );
});

/// 現在の時代プロバイダー
final currentEraProvider = FutureProvider<EraJourney>((ref) async {
  final streak = await ref.watch(currentLoginStreakProvider.future);
  if (streak == null) return ERAS_JOURNEY[0];
  return getEraByDays(streak.consecutiveDays);
});

/// 全時代進捗プロバイダー
final eraProgressProvider = FutureProvider<List<EraProgress>>((ref) async {
  final streak = await ref.watch(currentLoginStreakProvider.future);
  final currentDays = streak?.consecutiveDays ?? 0;

  return ERAS_JOURNEY.map((era) {
    final reached = currentDays >= era.daysToReach;
    return EraProgress(
      era: era,
      reached: reached,
      reachedDate: reached ? DateTime.now() : null,
    );
  }).toList();
});

/// 次の時代までの残り日数プロバイダー
final daysUntilNextEraProvider = FutureProvider<int>((ref) async {
  final streak = await ref.watch(currentLoginStreakProvider.future);
  final currentDays = streak?.consecutiveDays ?? 0;

  final currentEra = getEraByDays(currentDays);
  final currentIndex = ERAS_JOURNEY.indexOf(currentEra);

  if (currentIndex >= ERAS_JOURNEY.length - 1) {
    return 0; // 最後の時代
  }

  final nextEra = ERAS_JOURNEY[currentIndex + 1];
  return (nextEra.daysToReach - currentDays).clamp(0, 365);
});

/// ログイン処理StateNotifier
class LoginProcessor extends StateNotifier<AsyncValue<LoginCheckResult>> {
  final Ref ref;

  LoginProcessor(this.ref) : super(const AsyncValue.loading());

  Future<void> processLogin() async {
    try {
      state = const AsyncValue.loading();

      final checkResult = await ref.read(loginCheckResultProvider.future);

      if (!checkResult.isNewDay) {
        state = AsyncValue.data(checkResult);
        return;
      }

      // Hive にログイン状態を保存
      final box = ref.read(loginStreakBoxProvider);
      final newStreak = LoginStreak(
        consecutiveDays: checkResult.consecutiveDays,
        lastLoginDate: DateTime.now(),
        totalLoginDays: checkResult.totalLoginDays,
        currentEra: checkResult.newEra?.id ?? ERAS_JOURNEY[0].id,
      );

      await box.put('current', newStreak);

      // Firestore にも同期（async、エラーは無視）
      final service = FirestoreService();
      await service.updateLoginStreak('anonymous', newStreak).catchError(
            (_) => print('Firestore sync failed, but Hive is updated'),
          );

      state = AsyncValue.data(checkResult);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

/// ログイン処理プロバイダー
final loginProcessorProvider =
    StateNotifierProvider<LoginProcessor, AsyncValue<LoginCheckResult>>((ref) {
  return LoginProcessor(ref);
});
