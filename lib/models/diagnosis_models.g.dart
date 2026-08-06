// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diagnosis_models.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PersonalityDiagnosisResultAdapter
    extends TypeAdapter<PersonalityDiagnosisResult> {
  @override
  final int typeId = 22;

  @override
  PersonalityDiagnosisResult read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PersonalityDiagnosisResult(
      resultPersonId: fields[0] as String,
      resultName: fields[1] as String,
      weekNumber: fields[2] as int,
      theme: fields[3] as String,
      scoreBreakdown: (fields[4] as Map).cast<String, int>(),
      completedDate: fields[5] as DateTime,
      shareToken: fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, PersonalityDiagnosisResult obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.resultPersonId)
      ..writeByte(1)
      ..write(obj.resultName)
      ..writeByte(2)
      ..write(obj.weekNumber)
      ..writeByte(3)
      ..write(obj.theme)
      ..writeByte(4)
      ..write(obj.scoreBreakdown)
      ..writeByte(5)
      ..write(obj.completedDate)
      ..writeByte(6)
      ..write(obj.shareToken);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PersonalityDiagnosisResultAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
