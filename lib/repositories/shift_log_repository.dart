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

  Future<void> save(ShiftLog log) async {
    await _box.put(log.id, log);
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }
}
