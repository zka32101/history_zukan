// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gacha_models.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GachaRecordAdapter extends TypeAdapter<GachaRecord> {
  @override
  final int typeId = 20;

  @override
  GachaRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GachaRecord(
      id: fields[0] as String,
      personId: fields[1] as String,
      rarity: fields[2] as int,
      obtainedDate: fields[3] as DateTime,
      isDuplicate: fields[4] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, GachaRecord obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.personId)
      ..writeByte(2)
      ..write(obj.rarity)
      ..writeByte(3)
      ..write(obj.obtainedDate)
      ..writeByte(4)
      ..write(obj.isDuplicate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GachaRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
