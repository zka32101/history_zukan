import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'history_person.g.dart';

@JsonSerializable()
class HistoryPerson {
  // v1.0-v1.1 fields
  final String id;
  final String name;
  final String nameReading;
  final String? birthYear;
  final String? deathYear;
  final String description;
  final String country;
  final List<String> themeIds;
  final List<String> relatedEventIds;
  final String imageUrl;
  final String historyType;
  final bool isPremium;
  final List<String> searchKeywords;

  // v1.2 extensions: D1 AI chat
  final String? personality;
  final List<String>? famousQuotes;
  final Map<String, String>? lifeTimeline;
  final bool hasAiChat;

  // Person card enhancements
  final String? whatTheyDid;                   // 「何をした人？」(1-2文)
  final Map<String, String>? keyRelationships; // 「誰と関わった？」{人名: 関係の説明}
  final String? extendedDescription;           // 詳しく知りたい人向け追記

  HistoryPerson({
    required this.id,
    required this.name,
    required this.nameReading,
    this.birthYear,
    this.deathYear,
    required this.description,
    required this.country,
    required this.themeIds,
    required this.relatedEventIds,
    required this.imageUrl,
    required this.historyType,
    this.isPremium = false,
    required this.searchKeywords,
    this.personality,
    this.famousQuotes,
    this.lifeTimeline,
    this.hasAiChat = false,
    this.whatTheyDid,
    this.keyRelationships,
    this.extendedDescription,
  });

  factory HistoryPerson.fromJson(Map<String, dynamic> json) =>
      _$HistoryPersonFromJson(json);

  Map<String, dynamic> toJson() => _$HistoryPersonToJson(this);

  factory HistoryPerson.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    return HistoryPerson.fromJson(doc.data() ?? {}).copyWith(id: doc.id);
  }

  HistoryPerson copyWith({
    String? id,
    String? name,
    String? nameReading,
    String? birthYear,
    String? deathYear,
    String? description,
    String? country,
    List<String>? themeIds,
    List<String>? relatedEventIds,
    String? imageUrl,
    String? historyType,
    bool? isPremium,
    List<String>? searchKeywords,
    String? personality,
    List<String>? famousQuotes,
    Map<String, String>? lifeTimeline,
    bool? hasAiChat,
    String? whatTheyDid,
    Map<String, String>? keyRelationships,
    String? extendedDescription,
  }) {
    return HistoryPerson(
      id: id ?? this.id,
      name: name ?? this.name,
      nameReading: nameReading ?? this.nameReading,
      birthYear: birthYear ?? this.birthYear,
      deathYear: deathYear ?? this.deathYear,
      description: description ?? this.description,
      country: country ?? this.country,
      themeIds: themeIds ?? this.themeIds,
      relatedEventIds: relatedEventIds ?? this.relatedEventIds,
      imageUrl: imageUrl ?? this.imageUrl,
      historyType: historyType ?? this.historyType,
      isPremium: isPremium ?? this.isPremium,
      searchKeywords: searchKeywords ?? this.searchKeywords,
      personality: personality ?? this.personality,
      famousQuotes: famousQuotes ?? this.famousQuotes,
      lifeTimeline: lifeTimeline ?? this.lifeTimeline,
      hasAiChat: hasAiChat ?? this.hasAiChat,
      whatTheyDid: whatTheyDid ?? this.whatTheyDid,
      keyRelationships: keyRelationships ?? this.keyRelationships,
      extendedDescription: extendedDescription ?? this.extendedDescription,
    );
  }

  @override
  String toString() =>
      'HistoryPerson(id: $id, name: $name, birthYear: $birthYear, deathYear: $deathYear)';
}
