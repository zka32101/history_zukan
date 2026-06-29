import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'history_event.g.dart';

@JsonSerializable()
class QuizPoint {
  final int characterOffset;
  final String question;
  final List<String> choices;
  final String correctAnswer;
  final String explanation;
  final bool countAsCorrect;

  QuizPoint({
    required this.characterOffset,
    required this.question,
    required this.choices,
    required this.correctAnswer,
    required this.explanation,
    this.countAsCorrect = true,
  });

  factory QuizPoint.fromJson(Map<String, dynamic> json) =>
      _$QuizPointFromJson(json);

  Map<String, dynamic> toJson() => _$QuizPointToJson(this);
}

@JsonSerializable()
class HistoryEvent {
  // v1.0-v1.1 fields
  final String id;
  final String title;
  final String titleReading;
  final String description;
  final int year;
  final String yearDisplay;
  final String era;
  final int? periodEnd;
  final String regionJp;
  final String regionWorld;
  final String country;
  final String locationName;
  final double? lat;
  final double? lng;
  final List<String> themeIds;
  final List<String> tags;
  final List<String> relatedEventIds;
  final List<String> relatedPersonIds;
  final String imageUrl;
  final String? subImageUrl;
  final String historyType;
  final bool isPremium;
  @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
  final DateTime createdAt;
  @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
  final DateTime updatedAt;
  final List<String> searchKeywords;
  final String source;
  final bool isVerified;

  // v1.2 extensions

  // A2: Causal chains
  final List<String>? causalChainIds;

  // A3: Result prediction
  final List<QuizPoint>? quizPoints;

  // B2: Duration scale
  final int? duration;

  // B3: Nearby history
  final String? locationCategory;
  final String? modernAddress;

  // C1: Progress tracking
  final String? eraId;

  // C2: Daily notification
  final int? month;
  final int? day;

  // D1: AI chat related (Phase 2)
  final List<String>? relatedQuestions;

  // Card display enhancements
  final String? wowFactor;    // 「これがすごい！」
  final String? howItChanged; // 「どう変わった？」

  HistoryEvent({
    required this.id,
    required this.title,
    required this.titleReading,
    required this.description,
    required this.year,
    required this.yearDisplay,
    required this.era,
    this.periodEnd,
    required this.regionJp,
    required this.regionWorld,
    required this.country,
    required this.locationName,
    this.lat,
    this.lng,
    required this.themeIds,
    required this.tags,
    required this.relatedEventIds,
    required this.relatedPersonIds,
    required this.imageUrl,
    this.subImageUrl,
    required this.historyType,
    this.isPremium = false,
    required this.createdAt,
    required this.updatedAt,
    required this.searchKeywords,
    required this.source,
    this.isVerified = false,
    this.causalChainIds,
    this.quizPoints,
    this.duration,
    this.locationCategory,
    this.modernAddress,
    this.eraId,
    this.month,
    this.day,
    this.relatedQuestions,
    this.wowFactor,
    this.howItChanged,
  });

  factory HistoryEvent.fromJson(Map<String, dynamic> json) =>
      _$HistoryEventFromJson(json);

  Map<String, dynamic> toJson() => _$HistoryEventToJson(this);

  factory HistoryEvent.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    return HistoryEvent.fromJson(doc.data() ?? {}).copyWith(id: doc.id);
  }

  HistoryEvent copyWith({
    String? id,
    String? title,
    String? titleReading,
    String? description,
    int? year,
    String? yearDisplay,
    String? era,
    int? periodEnd,
    String? regionJp,
    String? regionWorld,
    String? country,
    String? locationName,
    double? lat,
    double? lng,
    List<String>? themeIds,
    List<String>? tags,
    List<String>? relatedEventIds,
    List<String>? relatedPersonIds,
    String? imageUrl,
    String? subImageUrl,
    String? historyType,
    bool? isPremium,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? searchKeywords,
    String? source,
    bool? isVerified,
    List<String>? causalChainIds,
    List<QuizPoint>? quizPoints,
    int? duration,
    String? locationCategory,
    String? modernAddress,
    String? eraId,
    int? month,
    int? day,
    List<String>? relatedQuestions,
    String? wowFactor,
    String? howItChanged,
  }) {
    return HistoryEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      titleReading: titleReading ?? this.titleReading,
      description: description ?? this.description,
      year: year ?? this.year,
      yearDisplay: yearDisplay ?? this.yearDisplay,
      era: era ?? this.era,
      periodEnd: periodEnd ?? this.periodEnd,
      regionJp: regionJp ?? this.regionJp,
      regionWorld: regionWorld ?? this.regionWorld,
      country: country ?? this.country,
      locationName: locationName ?? this.locationName,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      themeIds: themeIds ?? this.themeIds,
      tags: tags ?? this.tags,
      relatedEventIds: relatedEventIds ?? this.relatedEventIds,
      relatedPersonIds: relatedPersonIds ?? this.relatedPersonIds,
      imageUrl: imageUrl ?? this.imageUrl,
      subImageUrl: subImageUrl ?? this.subImageUrl,
      historyType: historyType ?? this.historyType,
      isPremium: isPremium ?? this.isPremium,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      searchKeywords: searchKeywords ?? this.searchKeywords,
      source: source ?? this.source,
      isVerified: isVerified ?? this.isVerified,
      causalChainIds: causalChainIds ?? this.causalChainIds,
      quizPoints: quizPoints ?? this.quizPoints,
      duration: duration ?? this.duration,
      locationCategory: locationCategory ?? this.locationCategory,
      modernAddress: modernAddress ?? this.modernAddress,
      eraId: eraId ?? this.eraId,
      month: month ?? this.month,
      day: day ?? this.day,
      relatedQuestions: relatedQuestions ?? this.relatedQuestions,
      wowFactor: wowFactor ?? this.wowFactor,
      howItChanged: howItChanged ?? this.howItChanged,
    );
  }

  @override
  String toString() =>
      'HistoryEvent(id: $id, title: $title, year: $year, era: $era)';
}

DateTime _timestampFromJson(dynamic value) {
  if (value is Timestamp) {
    return value.toDate();
  } else if (value is int) {
    return DateTime.fromMillisecondsSinceEpoch(value);
  } else if (value is String) {
    return DateTime.parse(value);
  }
  throw ArgumentError('Invalid timestamp: $value');
}

dynamic _timestampToJson(DateTime date) => Timestamp.fromDate(date);
