import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'causal_chain.g.dart';

@JsonSerializable()
class CausalChain {
  final String id;
  final String title;
  final String description;
  final List<String> eventIdsInOrder;
  final List<String> explanations;
  final int estimatedReadMinutes;
  final bool isPremium;

  CausalChain({
    required this.id,
    required this.title,
    required this.description,
    required this.eventIdsInOrder,
    required this.explanations,
    required this.estimatedReadMinutes,
    this.isPremium = false,
  });

  factory CausalChain.fromJson(Map<String, dynamic> json) =>
      _$CausalChainFromJson(json);

  Map<String, dynamic> toJson() => _$CausalChainToJson(this);

  factory CausalChain.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    return CausalChain.fromJson(doc.data() ?? {}).copyWith(id: doc.id);
  }

  CausalChain copyWith({
    String? id,
    String? title,
    String? description,
    List<String>? eventIdsInOrder,
    List<String>? explanations,
    int? estimatedReadMinutes,
    bool? isPremium,
  }) {
    return CausalChain(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      eventIdsInOrder: eventIdsInOrder ?? this.eventIdsInOrder,
      explanations: explanations ?? this.explanations,
      estimatedReadMinutes: estimatedReadMinutes ?? this.estimatedReadMinutes,
      isPremium: isPremium ?? this.isPremium,
    );
  }

  @override
  String toString() =>
      'CausalChain(id: $id, title: $title, steps: ${eventIdsInOrder.length})';
}
