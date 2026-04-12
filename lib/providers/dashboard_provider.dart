import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../core/hive_boxes.dart';
import '../models/enums.dart';
import '../models/event.dart';
import '../models/role_slot.dart';
import '../models/shift_log.dart';
import 'event_provider.dart';

final StreamProvider<List<RoleSlot>> roleSlotsStreamProvider =
    StreamProvider<List<RoleSlot>>((Ref ref) async* {
      final Box<RoleSlot> box = Hive.box<RoleSlot>(roleSlotsBoxName);
      yield box.values.toList();
      await for (final BoxEvent _ in box.watch()) {
        yield box.values.toList();
      }
    });

final StreamProvider<List<ShiftLog>> shiftLogsStreamProvider =
    StreamProvider<List<ShiftLog>>((Ref ref) async* {
      final Box<ShiftLog> box = Hive.box<ShiftLog>(shiftLogsBoxName);
      yield box.values.toList();
      await for (final BoxEvent _ in box.watch()) {
        yield box.values.toList();
      }
    });

final StreamProvider<String?> settingsLastBackupDateProvider =
    StreamProvider<String?>((Ref ref) async* {
      final Box<String> box = Hive.box<String>(settingsBoxName);
      yield box.get(lastBackupDateKey);
      await for (final BoxEvent _ in box.watch()) {
        yield box.get(lastBackupDateKey);
      }
    });

final Provider<bool> backupReminderDueProvider = Provider<bool>((Ref ref) {
  final String? raw = ref.watch(settingsLastBackupDateProvider).value;
  if (raw == null || raw.trim().isEmpty) {
    return true;
  }

  final DateTime? lastBackup = DateTime.tryParse(raw);
  if (lastBackup == null) {
    return true;
  }

  final DateTime now = DateTime.now();
  final int days = now.difference(lastBackup).inDays;
  return days > 30;
});

final Provider<List<Event>> todaysEventsProvider = Provider<List<Event>>((Ref ref) {
  final List<Event> events = ref.watch(eventsProvider);
  final DateTime now = DateTime.now();
  final DateTime today = DateTime(now.year, now.month, now.day);

  return events.where((Event event) {
    final DateTime eventDate = _safeDate(event.date);
    final DateTime day = DateTime(eventDate.year, eventDate.month, eventDate.day);
    return day == today;
  }).toList()
    ..sort((Event a, Event b) {
      final int dayCmp = _safeDate(a.date).compareTo(_safeDate(b.date));
      if (dayCmp != 0) {
        return dayCmp;
      }
      return a.startTime.compareTo(b.startTime);
    });
});

final Provider<List<Event>> thisWeekEventsProvider = Provider<List<Event>>((Ref ref) {
  final List<Event> events = ref.watch(eventsProvider);
  final DateTime now = DateTime.now();
  final DateTime start = DateTime(now.year, now.month, now.day);
  final DateTime end = start.add(const Duration(days: 7));

  return events.where((Event event) {
    final DateTime eventDate = _safeDate(event.date);
    final DateTime day = DateTime(eventDate.year, eventDate.month, eventDate.day);
    return !day.isBefore(start) && day.isBefore(end);
  }).toList()
    ..sort((Event a, Event b) {
      final int dayCmp = _safeDate(a.date).compareTo(_safeDate(b.date));
      if (dayCmp != 0) {
        return dayCmp;
      }
      return a.startTime.compareTo(b.startTime);
    });
});

final Provider<List<Event>> overdueShiftLogEventsProvider = Provider<List<Event>>((Ref ref) {
  final List<Event> events = ref.watch(eventsProvider);
  final List<RoleSlot> allSlots = ref.watch(roleSlotsStreamProvider).value ?? <RoleSlot>[];
  final List<ShiftLog> allLogs = ref.watch(shiftLogsStreamProvider).value ?? <ShiftLog>[];

  final DateTime now = DateTime.now();
  final DateTime today = DateTime(now.year, now.month, now.day);

  final List<Event> overdue = events.where((Event event) {
    if (event.status != EventStatus.completed) {
      return false;
    }

    final DateTime eventDate = _safeDate(event.date);
    final DateTime eventDay = DateTime(eventDate.year, eventDate.month, eventDate.day);
    if (!eventDay.isBefore(today)) {
      return false;
    }

    final List<RoleSlot> assignedSlots = allSlots.where((RoleSlot slot) {
      return slot.eventId == event.id && (slot.assignedEmployeeId ?? '').trim().isNotEmpty;
    }).toList();

    if (assignedSlots.isEmpty) {
      return false;
    }

    for (final RoleSlot slot in assignedSlots) {
      final String employeeId = slot.assignedEmployeeId!;
      final bool hasLog = allLogs.any(
        (ShiftLog log) => log.eventId == event.id && log.employeeId == employeeId,
      );
      if (!hasLog) {
        return true;
      }
    }
    return false;
  }).toList()
    ..sort((Event a, Event b) => _safeDate(a.date).compareTo(_safeDate(b.date)));

  return overdue;
});

DateTime _safeDate(String value) {
  return DateTime.tryParse(value) ?? DateTime.fromMillisecondsSinceEpoch(0);
}
