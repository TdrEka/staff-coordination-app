import 'package:hive/hive.dart';

import 'enums.dart';

part 'shift_log.g.dart';

@HiveType(typeId: 3)
class ShiftLog {
  ShiftLog({
    required this.id,
    required this.employeeId,
    required this.eventId,
    required this.outcome,
    this.minutesLate,
    this.notes,
    required this.scoreDelta,
    required this.loggedAt,
  });

  @HiveField(0)
  String id;

  @HiveField(1)
  String employeeId;

  @HiveField(2)
  String eventId;

  @HiveField(3)
  ShiftOutcome outcome;

  @HiveField(4)
  int? minutesLate;

  @HiveField(5)
  String? notes;

  @HiveField(6)
  double scoreDelta;

  // ISO-8601 DateTime string.
  @HiveField(7)
  String loggedAt;
}

// Run: flutter pub run build_runner build
