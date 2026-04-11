// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'employee.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EmployeeAdapter extends TypeAdapter<Employee> {
  @override
  final int typeId = 0;

  @override
  Employee read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Employee(
      id: fields[0] as String,
      name: fields[1] as String,
      age: fields[2] as int?,
      phone: fields[3] as String,
      email: fields[4] as String?,
      location: fields[5] as String,
      preferredContact: fields[6] as PreferredContact,
      languages: (fields[7] as List).cast<String>(),
      availability: fields[8] as String,
      reliabilityScore: fields[9] as double,
      roles: (fields[10] as List).cast<String>(),
      contractType: fields[11] as ContractType,
      hourlyRate: fields[12] as double?,
      status: fields[13] as EmployeeStatus,
      notes: fields[14] as String,
      emergencyContact: fields[15] as String?,
      createdAt: fields[16] as String,
      documents: (fields[17] as List?)?.cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, Employee obj) {
    writer
      ..writeByte(18)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.age)
      ..writeByte(3)
      ..write(obj.phone)
      ..writeByte(4)
      ..write(obj.email)
      ..writeByte(5)
      ..write(obj.location)
      ..writeByte(6)
      ..write(obj.preferredContact)
      ..writeByte(7)
      ..write(obj.languages)
      ..writeByte(8)
      ..write(obj.availability)
      ..writeByte(9)
      ..write(obj.reliabilityScore)
      ..writeByte(10)
      ..write(obj.roles)
      ..writeByte(11)
      ..write(obj.contractType)
      ..writeByte(12)
      ..write(obj.hourlyRate)
      ..writeByte(13)
      ..write(obj.status)
      ..writeByte(14)
      ..write(obj.notes)
      ..writeByte(15)
      ..write(obj.emergencyContact)
      ..writeByte(16)
      ..write(obj.createdAt)
      ..writeByte(17)
      ..write(obj.documents);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EmployeeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
