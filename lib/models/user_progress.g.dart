// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_progress.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserProgress _$UserProgressFromJson(Map<String, dynamic> json) => UserProgress(
      uid: json['uid'] as String,
      viewedEventIds: (json['viewedEventIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      eraProgress: (json['eraProgress'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toInt()),
          ) ??
          const {},
      themeProgress: (json['themeProgress'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toInt()),
          ) ??
          const {},
      unlockedMedals: (json['unlockedMedals'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as bool),
          ) ??
          const {},
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );

Map<String, dynamic> _$UserProgressToJson(UserProgress instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'viewedEventIds': instance.viewedEventIds,
      'eraProgress': instance.eraProgress,
      'themeProgress': instance.themeProgress,
      'unlockedMedals': instance.unlockedMedals,
      'lastUpdated': instance.lastUpdated.toIso8601String(),
    };
