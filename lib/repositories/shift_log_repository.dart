import 'package:hive/hive.dart';

import '../core/hive_boxes.dart';
import '../models/shift_log.dart';

class ShiftLogRepository {
  Box<ShiftLog> get _box => Hive.box<ShiftLog>(shiftLogsBoxName);

  List<ShiftLog> getAll() {
    return _box.values.toList();
  }

  List<ShiftLog> getByEmployeeId(String id) {
    return _box.values.where((ShiftLog log) => log.employeeId == id).toList();
  }

  List<ShiftLog> getByEventId(String id) {
    return _box.values.where((ShiftLog log) => log.eventId == id).toList();
  }

  List<ShiftLog> getByEmployeeAndEvent(String employeeId, String eventId) {
    final List<ShiftLog> matches = _box.values
        .where((ShiftLog log) => log.employeeId == employeeId && log.eventId == eventId)
        .toList();

    matches.sort((ShiftLog a, ShiftLog b) {
      final DateTime aTime = DateTime.tryParse(a.loggedAt) ?? DateTime.fromMillisecondsSinceEpoch(0);
      final DateTime bTime = DateTime.tryParse(b.loggedAt) ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bTime.compareTo(aTime);
    });
    return matches;
  }

  ShiftLog? getMostRecentByEmployeeAndEvent(String employeeId, String eventId) {
    final List<ShiftLog> matches = getByEmployeeAndEvent(employeeId, eventId);
    if (matches.isEmpty) {
      return null;
    }
    return matches.first;
  }

  Future<void> save(ShiftLog log) async {
    await _box.put(log.id, log);
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }
}
