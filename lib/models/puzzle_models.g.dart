// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'puzzle_models.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PersonRelationPuzzleRecordAdapter
    extends TypeAdapter<PersonRelationPuzzleRecord> {
  @override
  final int typeId = 24;

  @override
  PersonRelationPuzzleRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PersonRelationPuzzleRecord(
      puzzleId: fields[0] as String,
      date: fields[1] as String,
      solved: fields[2] as bool,
      attemptCount: fields[3] as int,
      usedHint: fields[4] as bool,
      solvedAt: fields[5] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, PersonRelationPuzzleRecord obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.puzzleId)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.solved)
      ..writeByte(3)
      ..write(obj.attemptCount)
      ..writeByte(4)
      ..write(obj.usedHint)
      ..writeByte(5)
      ..write(obj.solvedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PersonRelationPuzzleRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
