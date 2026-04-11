// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EventAdapter extends TypeAdapter<Event> {
  @override
  final int typeId = 1;

  @override
  Event read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Event(
      id: fields[0] as String,
      title: fields[1] as String,
      date: fields[2] as String,
      startTime: fields[3] as String,
      endTime: fields[4] as String,
      callTime: fields[5] as String?,
      venue: fields[6] as String,
      address: fields[7] as String?,
      parkingNotes: fields[8] as String?,
      accessNotes: fields[9] as String?,
      clientId: fields[10] as String?,
      clientName: fields[11] as String,
      clientContact: fields[12] as String?,
      eventType: fields[13] as String?,
      dresscode: fields[14] as String?,
      status: fields[15] as EventStatus,
      internalNotes: fields[16] as String,
      exportNotes: fields[17] as String,
      payRate: fields[18] as double?,
      createdAt: fields[19] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Event obj) {
    writer
      ..writeByte(20)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.startTime)
      ..writeByte(4)
      ..write(obj.endTime)
      ..writeByte(5)
      ..write(obj.callTime)
      ..writeByte(6)
      ..write(obj.venue)
      ..writeByte(7)
      ..write(obj.address)
      ..writeByte(8)
      ..write(obj.parkingNotes)
      ..writeByte(9)
      ..write(obj.accessNotes)
      ..writeByte(10)
      ..write(obj.clientId)
      ..writeByte(11)
      ..write(obj.clientName)
      ..writeByte(12)
      ..write(obj.clientContact)
      ..writeByte(13)
      ..write(obj.eventType)
      ..writeByte(14)
      ..write(obj.dresscode)
      ..writeByte(15)
      ..write(obj.status)
      ..writeByte(16)
      ..write(obj.internalNotes)
      ..writeByte(17)
      ..write(obj.exportNotes)
      ..writeByte(18)
      ..write(obj.payRate)
      ..writeByte(19)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EventAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
