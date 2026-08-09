import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:history_zukan/models/index.dart';
import 'package:riverpod/riverpod.dart';

/// State notifier for user progress tracking (C1)
class ProgressNotifier extends StateNotifier<UserProgress> {
  static const String _boxName = 'userProgress';

  ProgressNotifier(String uid)
      : super(UserProgress.initial(uid)) {
    _loadProgress();
  }

  /// Load progress from Hive.
  /// NOTE: stored as a JSON string (Box<String>), not a typed Box<UserProgress>
  /// — UserProgress has no @HiveType/registered TypeAdapter, so writing it
  /// directly to a typed box would throw `HiveError: Cannot write, unknown
  /// type UserProgress` the first time progress is saved (i.e. on every
  /// first card view). This mirrors the pattern already used by
  /// ChatHistoryStorage.
  Future<void> _loadProgress() async {
    try {
      final box = await Hive.openBox<String>(_boxName);
      final raw = box.get('progress_${state.uid}');
      if (raw != null) {
        state = UserProgress.fromJson(
          Map<String, dynamic>.from(jsonDecode(raw) as Map),
        );
      }
    } catch (e) {
      print('Error loading progress: $e');
    }
  }

  /// Save progress to Hive
  Future<void> _saveProgress() async {
    try {
      final box = await Hive.openBox<String>(_boxName);
      await box.put('progress_${state.uid}', jsonEncode(state.toJson()));
    } catch (e) {
      print('Error saving progress: $e');
    }
  }

  /// Mark an event as viewed and update era/theme progress
  Future<void> addViewedEvent(
    String eventId,
    String eraId,
    List<String> themeIds,
  ) async {
    final viewedIds = List<String>.from(state.viewedEventIds);
    if (viewedIds.contains(eventId)) return; // Already viewed

    viewedIds.add(eventId);

    // Update era progress
    final eraProgress = Map<String, int>.from(state.eraProgress);
    eraProgress[eraId] = (eraProgress[eraId] ?? 0) + 1;

    // Update theme progress
    final themeProgress = Map<String, int>.from(state.themeProgress);
    for (final themeId in themeIds) {
      themeProgress[themeId] = (themeProgress[themeId] ?? 0) + 1;
    }

    state = state.copyWith(
      viewedEventIds: viewedIds,
      eraProgress: eraProgress,
      themeProgress: themeProgress,
      lastUpdated: DateTime.now(),
    );

    await _saveProgress();
    await _checkAndUnlockMedals();
  }

  /// Check and unlock medals based on progress
  Future<void> _checkAndUnlockMedals() async {
    final medals = Map<String, bool>.from(state.unlockedMedals);

    // Complete era medal
    for (final entry in state.eraProgress.entries) {
      if (entry.value >= 10) {
        // Arbitrary threshold: 10 events per era
        medals['complete_era_${entry.key}'] = true;
      }
    }

    // Find 100 cards
    if (state.viewedEventIds.length >= 100) {
      medals['find_100_cards'] = true;
    }

    // Find 200 cards (full encyclopedia)
    if (state.viewedEventIds.length >= 200) {
      medals['complete_encyclopedia'] = true;
    }

    // Theme mastery
    for (final entry in state.themeProgress.entries) {
      if (entry.value >= 20) {
        medals['theme_master_${entry.key}'] = true;
      }
    }

    if (!_mapEquals(medals, state.unlockedMedals)) {
      state = state.copyWith(unlockedMedals: medals);
      await _saveProgress();
    }
  }

  /// Value-equality for Map<String, bool> — `Map` doesn't override `==`,
  /// so `medals != state.unlockedMedals` above always compared object
  /// identity and was always true (a fresh Map is built every call),
  /// causing every event view to trigger an unconditional rebuild + Hive
  /// write even when no medal actually changed.
  bool _mapEquals(Map<String, bool> a, Map<String, bool> b) {
    if (a.length != b.length) return false;
    for (final entry in a.entries) {
      if (b[entry.key] != entry.value) return false;
    }
    return true;
  }

  /// Get completion percentage for an era
  double getEraCompletion(String eraId) {
    final viewed = state.eraProgress[eraId] ?? 0;
    return viewed / 20.0; // Assume 20 events per era goal
  }

  /// Get all unlocked medals
  List<String> getUnlockedMedals() {
    return state.unlockedMedals.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();
  }

  /// Reset progress (for testing)
  Future<void> resetProgress() async {
    state = UserProgress.initial(state.uid);
    await _saveProgress();
  }
}

/// Riverpod provider for user progress
final progressProvider = StateNotifierProvider<ProgressNotifier, UserProgress>(
  (ref) {
    // In real app, get uid from auth provider
    const uid = 'anonymous_user'; // TODO: replace with actual uid
    return ProgressNotifier(uid);
  },
);

/// Get completion % for a specific era
final eraCompletionProvider =
    Provider.family<double, String>((ref, eraId) {
  final progress = ref.watch(progressProvider);
  final viewed = progress.eraProgress[eraId] ?? 0;
  return viewed / 20.0;
});

/// Get all unlocked medals
final unlockedMedalsProvider = Provider<List<String>>((ref) {
  final progress = ref.watch(progressProvider);
  return progress.unlockedMedals.entries
      .where((e) => e.value)
      .map((e) => e.key)
      .toList();
});

/// Get total discovery percentage
final discoveryPercentageProvider = Provider<double>((ref) {
  final progress = ref.watch(progressProvider);
  return progress.totalViewedEvents / 200.0; // 200 events as target
});
