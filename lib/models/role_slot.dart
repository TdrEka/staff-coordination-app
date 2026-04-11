import 'package:hive/hive.dart';

import 'enums.dart';

part 'role_slot.g.dart';

@HiveType(typeId: 2)
class RoleSlot {
  RoleSlot({
    required this.id,
    required this.eventId,
    required this.roleType,
    this.assignedEmployeeId,
    required this.status,
    required this.priority,
    this.callTime,
    this.notes,
  });

  @HiveField(0)
  String id;

  @HiveField(1)
  String eventId;

  @HiveField(2)
  String roleType;

  @HiveField(3)
  String? assignedEmployeeId;

  @HiveField(4)
  SlotStatus status;

  @HiveField(5)
  SlotPriority priority;

  // 24-hour HH:mm format.
  @HiveField(6)
  String? callTime;

  @HiveField(7)
  String? notes;
}

// Run: flutter pub run build_runner build
