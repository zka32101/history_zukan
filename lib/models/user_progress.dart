import 'package:json_annotation/json_annotation.dart';

part 'user_progress.g.dart';

@JsonSerializable()
class UserProgress {
  final String uid;
  final List<String> viewedEventIds;
  final Map<String, int> eraProgress;
  final Map<String, int> themeProgress;
  final Map<String, bool> unlockedMedals;
  final DateTime lastUpdated;

  UserProgress({
    required this.uid,
    this.viewedEventIds = const [],
    this.eraProgress = const {},
    this.themeProgress = const {},
    this.unlockedMedals = const {},
    required this.lastUpdated,
  });

  factory UserProgress.fromJson(Map<String, dynamic> json) =>
      _$UserProgressFromJson(json);

  Map<String, dynamic> toJson() => _$UserProgressToJson(this);

  factory UserProgress.initial(String uid) {
    return UserProgress(
      uid: uid,
      lastUpdated: DateTime.now(),
    );
  }

  UserProgress copyWith({
    String? uid,
    List<String>? viewedEventIds,
    Map<String, int>? eraProgress,
    Map<String, int>? themeProgress,
    Map<String, bool>? unlockedMedals,
    DateTime? lastUpdated,
  }) {
    return UserProgress(
      uid: uid ?? this.uid,
      viewedEventIds: viewedEventIds ?? this.viewedEventIds,
      eraProgress: eraProgress ?? this.eraProgress,
      themeProgress: themeProgress ?? this.themeProgress,
      unlockedMedals: unlockedMedals ?? this.unlockedMedals,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  int get totalViewedEvents => viewedEventIds.length;

  double getEraCompletion(String eraId, int totalEventsInEra) {
    final viewed = eraProgress[eraId] ?? 0;
    return totalEventsInEra > 0 ? viewed / totalEventsInEra : 0;
  }

  @override
  String toString() =>
      'UserProgress(uid: $uid, totalViewed: $totalViewedEvents, medals: ${unlockedMedals.length})';
}
