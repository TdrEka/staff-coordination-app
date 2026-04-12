// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shift_log.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ShiftLogAdapter extends TypeAdapter<ShiftLog> {
  @override
  final int typeId = 3;

  @override
  ShiftLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ShiftLog(
      id: fields[0] as String,
      employeeId: fields[1] as String,
      eventId: fields[2] as String,
      outcome: fields[3] as ShiftOutcome,
      minutesLate: fields[4] as int?,
      notes: fields[5] as String?,
      scoreBeforeLog: fields[8] == null ? 0.0 : fields[8] as double,
      scoreDelta: fields[6] as double,
      loggedAt: fields[7] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ShiftLog obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.employeeId)
      ..writeByte(2)
      ..write(obj.eventId)
      ..writeByte(3)
      ..write(obj.outcome)
      ..writeByte(4)
      ..write(obj.minutesLate)
      ..writeByte(5)
      ..write(obj.notes)
      ..writeByte(6)
      ..write(obj.scoreDelta)
      ..writeByte(7)
      ..write(obj.loggedAt)
      ..writeByte(8)
      ..write(obj.scoreBeforeLog);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShiftLogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
