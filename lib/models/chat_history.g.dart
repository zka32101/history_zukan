// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_history.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ChatHistoryAdapter extends TypeAdapter<ChatHistory> {
  @override
  final int typeId = 1;

  @override
  ChatHistory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChatHistory(
      personId: fields[0] as String,
      personName: fields[1] as String,
      messages: (fields[2] as List).cast<ChatMessage>(),
      totalConversations: fields[3] as int,
      maxConversations: fields[4] as int,
      lastUpdated: fields[5] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, ChatHistory obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.personId)
      ..writeByte(1)
      ..write(obj.personName)
      ..writeByte(2)
      ..write(obj.messages)
      ..writeByte(3)
      ..write(obj.totalConversations)
      ..writeByte(4)
      ..write(obj.maxConversations)
      ..writeByte(5)
      ..write(obj.lastUpdated);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatHistoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatHistory _$ChatHistoryFromJson(Map<String, dynamic> json) => ChatHistory(
      personId: json['personId'] as String,
      personName: json['personName'] as String,
      messages: (json['messages'] as List<dynamic>?)
              ?.map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      totalConversations: (json['totalConversations'] as num?)?.toInt() ?? 0,
      maxConversations: (json['maxConversations'] as num?)?.toInt() ?? 100,
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );

Map<String, dynamic> _$ChatHistoryToJson(ChatHistory instance) =>
    <String, dynamic>{
      'personId': instance.personId,
      'personName': instance.personName,
      'messages': instance.messages,
      'totalConversations': instance.totalConversations,
      'maxConversations': instance.maxConversations,
      'lastUpdated': instance.lastUpdated.toIso8601String(),
    };
