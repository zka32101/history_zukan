// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_models.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LoginStreakAdapter extends TypeAdapter<LoginStreak> {
  @override
  final int typeId = 21;

  @override
  LoginStreak read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LoginStreak(
      consecutiveDays: fields[0] as int,
      lastLoginDate: fields[1] as DateTime,
      totalLoginDays: fields[2] as int,
      currentEra: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, LoginStreak obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.consecutiveDays)
      ..writeByte(1)
      ..write(obj.lastLoginDate)
      ..writeByte(2)
      ..write(obj.totalLoginDays)
      ..writeByte(3)
      ..write(obj.currentEra);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoginStreakAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
