import '../../models/employee.dart';
import '../../models/enums.dart';
import '../../models/event.dart';
import '../../models/role_slot.dart';

bool hasConflict(
  Employee employee,
  Event targetEvent,
  List<RoleSlot> allSlots,
  List<Event> allEvents, {
  String? excludeSlotId,
}) {
  return getConflictingEvent(
        employee,
        targetEvent,
        allSlots,
        allEvents,
        excludeSlotId: excludeSlotId,
      ) !=
      null;
}

Event? getConflictingEvent(
  Employee employee,
  Event targetEvent,
  List<RoleSlot> allSlots,
  List<Event> allEvents, {
  String? excludeSlotId,
}) {
  final Map<String, Event> eventsById = <String, Event>{
    for (final Event event in allEvents) event.id: event,
  };

  final DateTime targetDate = _dateOnly(_safeDate(targetEvent.date));
  final int targetStart = _toMinutes(targetEvent.startTime);
  final int targetEnd = _toMinutes(targetEvent.endTime);

  for (final RoleSlot slot in allSlots) {
    if (excludeSlotId != null && slot.id == excludeSlotId) {
      continue;
    }
    if (slot.assignedEmployeeId != employee.id) {
      continue;
    }
    if (slot.status != SlotStatus.confirmed && slot.status != SlotStatus.pending) {
      continue;
    }

    final Event? slotEvent = eventsById[slot.eventId];
    if (slotEvent == null) {
      continue;
    }

    final DateTime slotDate = _dateOnly(_safeDate(slotEvent.date));
    if (slotDate != targetDate) {
      continue;
    }

    final int slotStart = _toMinutes(slot.callTime ?? slotEvent.startTime);
    final int slotEnd = _toMinutes(slotEvent.endTime);
    if (_overlaps(targetStart, targetEnd, slotStart, slotEnd)) {
      return slotEvent;
    }
  }

  return null;
}

DateTime _safeDate(String value) {
  return DateTime.tryParse(value) ?? DateTime.fromMillisecondsSinceEpoch(0);
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}

int _toMinutes(String hhmm) {
  final List<String> parts = hhmm.split(':');
  if (parts.length != 2) {
    return 0;
  }
  final int hour = int.tryParse(parts[0]) ?? 0;
  final int minute = int.tryParse(parts[1]) ?? 0;
  return (hour * 60) + minute;
}

bool _overlaps(int aStart, int aEnd, int bStart, int bEnd) {
  return aStart < bEnd && bStart < aEnd;
}
