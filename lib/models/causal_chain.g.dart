// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'causal_chain.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CausalChain _$CausalChainFromJson(Map<String, dynamic> json) => CausalChain(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      eventIdsInOrder: (json['eventIdsInOrder'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      explanations: (json['explanations'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      estimatedReadMinutes: (json['estimatedReadMinutes'] as num).toInt(),
      isPremium: json['isPremium'] as bool? ?? false,
    );

Map<String, dynamic> _$CausalChainToJson(CausalChain instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'eventIdsInOrder': instance.eventIdsInOrder,
      'explanations': instance.explanations,
      'estimatedReadMinutes': instance.estimatedReadMinutes,
      'isPremium': instance.isPremium,
    };
