import 'package:hive/hive.dart';

import '../core/hive_boxes.dart';
import '../models/role_slot.dart';

class RoleSlotRepository {
  Box<RoleSlot> get _box => Hive.box<RoleSlot>(roleSlotsBoxName);

  List<RoleSlot> getAll() {
    return _box.values.toList();
  }

  List<RoleSlot> getByEventId(String eventId) {
    return _box.values.where((RoleSlot slot) => slot.eventId == eventId).toList();
  }

  Future<void> save(RoleSlot slot) async {
    await _box.put(slot.id, slot);
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }
}
