// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'role_slot.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RoleSlotAdapter extends TypeAdapter<RoleSlot> {
  @override
  final int typeId = 2;

  @override
  RoleSlot read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RoleSlot(
      id: fields[0] as String,
      eventId: fields[1] as String,
      roleType: fields[2] as String,
      assignedEmployeeId: fields[3] as String?,
      status: fields[4] as SlotStatus,
      priority: fields[5] as SlotPriority,
      callTime: fields[6] as String?,
      notes: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, RoleSlot obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.eventId)
      ..writeByte(2)
      ..write(obj.roleType)
      ..writeByte(3)
      ..write(obj.assignedEmployeeId)
      ..writeByte(4)
      ..write(obj.status)
      ..writeByte(5)
      ..write(obj.priority)
      ..writeByte(6)
      ..write(obj.callTime)
      ..writeByte(7)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RoleSlotAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
