// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quiz_models.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class QuizNotificationRecordAdapter
    extends TypeAdapter<QuizNotificationRecord> {
  @override
  final int typeId = 23;

  @override
  QuizNotificationRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return QuizNotificationRecord(
      eventId: fields[0] as String,
      date: fields[1] as String,
      answered: fields[2] as bool,
      selectedAnswer: fields[3] as String?,
      isCorrect: fields[4] as bool,
      answeredAt: fields[5] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, QuizNotificationRecord obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.eventId)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.answered)
      ..writeByte(3)
      ..write(obj.selectedAnswer)
      ..writeByte(4)
      ..write(obj.isCorrect)
      ..writeByte(5)
      ..write(obj.answeredAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuizNotificationRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
