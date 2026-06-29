import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'chat_message.dart';

part 'chat_history.g.dart';

@HiveType(typeId: 1)
@JsonSerializable()
class ChatHistory {
  @HiveField(0)
  final String personId;

  @HiveField(1)
  final String personName;

  @HiveField(2)
  final List<ChatMessage> messages;

  @HiveField(3)
  final int totalConversations;

  @HiveField(4)
  final int maxConversations;

  @HiveField(5)
  final DateTime lastUpdated;

  ChatHistory({
    required this.personId,
    required this.personName,
    this.messages = const [],
    this.totalConversations = 0,
    this.maxConversations = 100,
    required this.lastUpdated,
  });

  factory ChatHistory.fromJson(Map<String, dynamic> json) =>
      _$ChatHistoryFromJson(json);

  Map<String, dynamic> toJson() => _$ChatHistoryToJson(this);

  factory ChatHistory.initial(String personId, String personName) {
    return ChatHistory(
      personId: personId,
      personName: personName,
      messages: [],
      totalConversations: 0,
      maxConversations: 100,
      lastUpdated: DateTime.now(),
    );
  }

  ChatHistory copyWith({
    String? personId,
    String? personName,
    List<ChatMessage>? messages,
    int? totalConversations,
    int? maxConversations,
    DateTime? lastUpdated,
  }) {
    return ChatHistory(
      personId: personId ?? this.personId,
      personName: personName ?? this.personName,
      messages: messages ?? this.messages,
      totalConversations: totalConversations ?? this.totalConversations,
      maxConversations: maxConversations ?? this.maxConversations,
      lastUpdated: lastUpdated ?? DateTime.now(),
    );
  }

  bool get hasQuota => totalConversations < maxConversations;

  int get remainingQuota => maxConversations - totalConversations;

  @override
  String toString() =>
      'ChatHistory($personName: ${totalConversations}/${maxConversations} conversations, ${messages.length} messages)';
}
