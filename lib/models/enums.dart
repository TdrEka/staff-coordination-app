import 'package:hive/hive.dart';

part 'enums.g.dart';

@HiveType(typeId: 10)
enum PreferredContact {
  @HiveField(0)
  phone,
  @HiveField(1)
  whatsapp,
  @HiveField(2)
  email,
}

@HiveType(typeId: 11)
enum ContractType {
  @HiveField(0)
  freelance,
  @HiveField(1)
  staff,
  @HiveField(2)
  agency,
}

@HiveType(typeId: 12)
enum EmployeeStatus {
  @HiveField(0)
  active,
  @HiveField(1)
  inactive,
}

@HiveType(typeId: 13)
enum SlotStatus {
  @HiveField(0)
  confirmed,
  @HiveField(1)
  pending,
  @HiveField(2)
  uncovered,
}

@HiveType(typeId: 14)
enum SlotPriority {
  @HiveField(0)
  critical,
  @HiveField(1)
  normal,
}

@HiveType(typeId: 15)
enum EventStatus {
  @HiveField(0)
  draft,
  @HiveField(1)
  confirmed,
  @HiveField(2)
  completed,
  @HiveField(3)
  cancelled,
}

@HiveType(typeId: 16)
enum ShiftOutcome {
  @HiveField(0)
  showed_up,
  @HiveField(1)
  late,
  @HiveField(2)
  no_show,
  @HiveField(3)
  cancelled_advance,
  @HiveField(4)
  manual_override,
}

// Run: flutter pub run build_runner build
