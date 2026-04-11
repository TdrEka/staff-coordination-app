// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'enums.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PreferredContactAdapter extends TypeAdapter<PreferredContact> {
  @override
  final int typeId = 10;

  @override
  PreferredContact read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return PreferredContact.phone;
      case 1:
        return PreferredContact.whatsapp;
      case 2:
        return PreferredContact.email;
      default:
        return PreferredContact.phone;
    }
  }

  @override
  void write(BinaryWriter writer, PreferredContact obj) {
    switch (obj) {
      case PreferredContact.phone:
        writer.writeByte(0);
        break;
      case PreferredContact.whatsapp:
        writer.writeByte(1);
        break;
      case PreferredContact.email:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PreferredContactAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ContractTypeAdapter extends TypeAdapter<ContractType> {
  @override
  final int typeId = 11;

  @override
  ContractType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ContractType.freelance;
      case 1:
        return ContractType.staff;
      case 2:
        return ContractType.agency;
      default:
        return ContractType.freelance;
    }
  }

  @override
  void write(BinaryWriter writer, ContractType obj) {
    switch (obj) {
      case ContractType.freelance:
        writer.writeByte(0);
        break;
      case ContractType.staff:
        writer.writeByte(1);
        break;
      case ContractType.agency:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContractTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class EmployeeStatusAdapter extends TypeAdapter<EmployeeStatus> {
  @override
  final int typeId = 12;

  @override
  EmployeeStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return EmployeeStatus.active;
      case 1:
        return EmployeeStatus.inactive;
      default:
        return EmployeeStatus.active;
    }
  }

  @override
  void write(BinaryWriter writer, EmployeeStatus obj) {
    switch (obj) {
      case EmployeeStatus.active:
        writer.writeByte(0);
        break;
      case EmployeeStatus.inactive:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EmployeeStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SlotStatusAdapter extends TypeAdapter<SlotStatus> {
  @override
  final int typeId = 13;

  @override
  SlotStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SlotStatus.confirmed;
      case 1:
        return SlotStatus.pending;
      case 2:
        return SlotStatus.uncovered;
      default:
        return SlotStatus.confirmed;
    }
  }

  @override
  void write(BinaryWriter writer, SlotStatus obj) {
    switch (obj) {
      case SlotStatus.confirmed:
        writer.writeByte(0);
        break;
      case SlotStatus.pending:
        writer.writeByte(1);
        break;
      case SlotStatus.uncovered:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SlotStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SlotPriorityAdapter extends TypeAdapter<SlotPriority> {
  @override
  final int typeId = 14;

  @override
  SlotPriority read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SlotPriority.critical;
      case 1:
        return SlotPriority.normal;
      default:
        return SlotPriority.critical;
    }
  }

  @override
  void write(BinaryWriter writer, SlotPriority obj) {
    switch (obj) {
      case SlotPriority.critical:
        writer.writeByte(0);
        break;
      case SlotPriority.normal:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SlotPriorityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class EventStatusAdapter extends TypeAdapter<EventStatus> {
  @override
  final int typeId = 15;

  @override
  EventStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return EventStatus.draft;
      case 1:
        return EventStatus.confirmed;
      case 2:
        return EventStatus.completed;
      case 3:
        return EventStatus.cancelled;
      default:
        return EventStatus.draft;
    }
  }

  @override
  void write(BinaryWriter writer, EventStatus obj) {
    switch (obj) {
      case EventStatus.draft:
        writer.writeByte(0);
        break;
      case EventStatus.confirmed:
        writer.writeByte(1);
        break;
      case EventStatus.completed:
        writer.writeByte(2);
        break;
      case EventStatus.cancelled:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EventStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ShiftOutcomeAdapter extends TypeAdapter<ShiftOutcome> {
  @override
  final int typeId = 16;

  @override
  ShiftOutcome read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ShiftOutcome.showed_up;
      case 1:
        return ShiftOutcome.late;
      case 2:
        return ShiftOutcome.no_show;
      case 3:
        return ShiftOutcome.cancelled_advance;
      case 4:
        return ShiftOutcome.manual_override;
      default:
        return ShiftOutcome.showed_up;
    }
  }

  @override
  void write(BinaryWriter writer, ShiftOutcome obj) {
    switch (obj) {
      case ShiftOutcome.showed_up:
        writer.writeByte(0);
        break;
      case ShiftOutcome.late:
        writer.writeByte(1);
        break;
      case ShiftOutcome.no_show:
        writer.writeByte(2);
        break;
      case ShiftOutcome.cancelled_advance:
        writer.writeByte(3);
        break;
      case ShiftOutcome.manual_override:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShiftOutcomeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
