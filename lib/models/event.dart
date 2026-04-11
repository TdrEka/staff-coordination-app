import 'package:hive/hive.dart';

import 'enums.dart';

part 'event.g.dart';

@HiveType(typeId: 1)
class Event {
  Event({
    required this.id,
    required this.title,
    required this.date,
    required this.startTime,
    required this.endTime,
    this.callTime,
    required this.venue,
    this.address,
    this.parkingNotes,
    this.accessNotes,
    this.clientId,
    required this.clientName,
    this.clientContact,
    this.eventType,
    this.dresscode,
    required this.status,
    required this.internalNotes,
    required this.exportNotes,
    this.payRate,
    required this.createdAt,
  });

  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  // ISO-8601 DateTime string.
  @HiveField(2)
  String date;

  // 24-hour HH:mm format.
  @HiveField(3)
  String startTime;

  // 24-hour HH:mm format.
  @HiveField(4)
  String endTime;

  // 24-hour HH:mm format.
  @HiveField(5)
  String? callTime;

  @HiveField(6)
  String venue;

  @HiveField(7)
  String? address;

  @HiveField(8)
  String? parkingNotes;

  @HiveField(9)
  String? accessNotes;

  @HiveField(10)
  String? clientId;

  @HiveField(11)
  String clientName;

  @HiveField(12)
  String? clientContact;

  @HiveField(13)
  String? eventType;

  @HiveField(14)
  String? dresscode;

  @HiveField(15)
  EventStatus status;

  @HiveField(16)
  String internalNotes;

  @HiveField(17)
  String exportNotes;

  @HiveField(18)
  double? payRate;

  // ISO-8601 DateTime string.
  @HiveField(19)
  String createdAt;
}

// Run: flutter pub run build_runner build
