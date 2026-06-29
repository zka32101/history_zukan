// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QuizPoint _$QuizPointFromJson(Map<String, dynamic> json) => QuizPoint(
      characterOffset: (json['characterOffset'] as num).toInt(),
      question: json['question'] as String,
      choices:
          (json['choices'] as List<dynamic>).map((e) => e as String).toList(),
      correctAnswer: json['correctAnswer'] as String,
      explanation: json['explanation'] as String,
      countAsCorrect: json['countAsCorrect'] as bool? ?? true,
    );

Map<String, dynamic> _$QuizPointToJson(QuizPoint instance) => <String, dynamic>{
      'characterOffset': instance.characterOffset,
      'question': instance.question,
      'choices': instance.choices,
      'correctAnswer': instance.correctAnswer,
      'explanation': instance.explanation,
      'countAsCorrect': instance.countAsCorrect,
    };

HistoryEvent _$HistoryEventFromJson(Map<String, dynamic> json) => HistoryEvent(
      id: json['id'] as String,
      title: json['title'] as String,
      titleReading: json['titleReading'] as String,
      description: json['description'] as String,
      year: (json['year'] as num).toInt(),
      yearDisplay: json['yearDisplay'] as String,
      era: json['era'] as String,
      periodEnd: (json['periodEnd'] as num?)?.toInt(),
      regionJp: json['regionJp'] as String,
      regionWorld: json['regionWorld'] as String,
      country: json['country'] as String,
      locationName: json['locationName'] as String,
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
      themeIds:
          (json['themeIds'] as List<dynamic>).map((e) => e as String).toList(),
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
      relatedEventIds: (json['relatedEventIds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      relatedPersonIds: (json['relatedPersonIds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      imageUrl: json['imageUrl'] as String,
      subImageUrl: json['subImageUrl'] as String?,
      historyType: json['historyType'] as String,
      isPremium: json['isPremium'] as bool? ?? false,
      createdAt: _timestampFromJson(json['createdAt']),
      updatedAt: _timestampFromJson(json['updatedAt']),
      searchKeywords: (json['searchKeywords'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      source: json['source'] as String,
      isVerified: json['isVerified'] as bool? ?? false,
      causalChainIds: (json['causalChainIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      quizPoints: (json['quizPoints'] as List<dynamic>?)
          ?.map((e) => QuizPoint.fromJson(e as Map<String, dynamic>))
          .toList(),
      duration: (json['duration'] as num?)?.toInt(),
      locationCategory: json['locationCategory'] as String?,
      modernAddress: json['modernAddress'] as String?,
      eraId: json['eraId'] as String?,
      month: (json['month'] as num?)?.toInt(),
      day: (json['day'] as num?)?.toInt(),
      relatedQuestions: (json['relatedQuestions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      wowFactor: json['wowFactor'] as String?,
      howItChanged: json['howItChanged'] as String?,
    );

Map<String, dynamic> _$HistoryEventToJson(HistoryEvent instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'titleReading': instance.titleReading,
      'description': instance.description,
      'year': instance.year,
      'yearDisplay': instance.yearDisplay,
      'era': instance.era,
      'periodEnd': instance.periodEnd,
      'regionJp': instance.regionJp,
      'regionWorld': instance.regionWorld,
      'country': instance.country,
      'locationName': instance.locationName,
      'lat': instance.lat,
      'lng': instance.lng,
      'themeIds': instance.themeIds,
      'tags': instance.tags,
      'relatedEventIds': instance.relatedEventIds,
      'relatedPersonIds': instance.relatedPersonIds,
      'imageUrl': instance.imageUrl,
      'subImageUrl': instance.subImageUrl,
      'historyType': instance.historyType,
      'isPremium': instance.isPremium,
      'createdAt': _timestampToJson(instance.createdAt),
      'updatedAt': _timestampToJson(instance.updatedAt),
      'searchKeywords': instance.searchKeywords,
      'source': instance.source,
      'isVerified': instance.isVerified,
      'causalChainIds': instance.causalChainIds,
      'quizPoints': instance.quizPoints,
      'duration': instance.duration,
      'locationCategory': instance.locationCategory,
      'modernAddress': instance.modernAddress,
      'eraId': instance.eraId,
      'month': instance.month,
      'day': instance.day,
      'relatedQuestions': instance.relatedQuestions,
      'wowFactor': instance.wowFactor,
      'howItChanged': instance.howItChanged,
    };
