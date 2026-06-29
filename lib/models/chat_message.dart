import 'package:json_annotation/json_annotation.dart';

part 'chat_message.g.dart';

@JsonSerializable()
class ChatMessage {
  final String id;
  final String role; // 'user' or 'assistant'
  final String content;
  final DateTime timestamp;
  final int? tokenCount; // For budget tracking

  ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
    this.tokenCount,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageFromJson(json);

  Map<String, dynamic> toJson() => _$ChatMessageToJson(this);

  @override
  String toString() =>
      'ChatMessage(role: $role, content: ${content.substring(0, 30)}...)';
}
