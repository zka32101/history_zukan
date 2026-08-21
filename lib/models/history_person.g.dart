// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history_person.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HistoryPerson _$HistoryPersonFromJson(Map<String, dynamic> json) =>
    HistoryPerson(
      id: json['id'] as String,
      name: json['name'] as String,
      nameReading: json['nameReading'] as String,
      birthYear: json['birthYear'] as String?,
      deathYear: json['deathYear'] as String?,
      description: json['description'] as String,
      country: json['country'] as String,
      themeIds:
          (json['themeIds'] as List<dynamic>).map((e) => e as String).toList(),
      relatedEventIds: (json['relatedEventIds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      imageUrl: json['imageUrl'] as String,
      historyType: json['historyType'] as String,
      isPremium: json['isPremium'] as bool? ?? false,
      searchKeywords: (json['searchKeywords'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      personality: json['personality'] as String?,
      famousQuotes: (json['famousQuotes'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      lifeTimeline: (json['lifeTimeline'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
      hasAiChat: json['hasAiChat'] as bool? ?? false,
      whatTheyDid: json['whatTheyDid'] as String?,
      keyRelationships:
          (json['keyRelationships'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
      extendedDescription: json['extendedDescription'] as String?,
      imageAttribution: json['imageAttribution'] as String?,
      imageSourceUrl: json['imageSourceUrl'] as String?,
      imageLicense: json['imageLicense'] as String?,
    );

Map<String, dynamic> _$HistoryPersonToJson(HistoryPerson instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'nameReading': instance.nameReading,
      'birthYear': instance.birthYear,
      'deathYear': instance.deathYear,
      'description': instance.description,
      'country': instance.country,
      'themeIds': instance.themeIds,
      'relatedEventIds': instance.relatedEventIds,
      'imageUrl': instance.imageUrl,
      'historyType': instance.historyType,
      'isPremium': instance.isPremium,
      'searchKeywords': instance.searchKeywords,
      'personality': instance.personality,
      'famousQuotes': instance.famousQuotes,
      'lifeTimeline': instance.lifeTimeline,
      'hasAiChat': instance.hasAiChat,
      'whatTheyDid': instance.whatTheyDid,
      'keyRelationships': instance.keyRelationships,
      'extendedDescription': instance.extendedDescription,
      'imageAttribution': instance.imageAttribution,
      'imageSourceUrl': instance.imageSourceUrl,
      'imageLicense': instance.imageLicense,
    };
