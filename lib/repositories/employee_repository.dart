import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../core/hive_boxes.dart';
import '../models/employee.dart';
import '../models/enums.dart';

class EmployeeRepository {
  EmployeeRepository({Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  final Uuid _uuid;

  Box<Employee> get _box => Hive.box<Employee>(employeesBoxName);

  List<Employee> getAll() {
    return _box.values.where((Employee e) => e.status == EmployeeStatus.active).toList();
  }

  List<Employee> getAllIncludingInactive() {
    return _box.values.toList();
  }

  Employee? getById(String id) {
    return _box.get(id);
  }

  Future<void> save(Employee employee) async {
    if (employee.id.trim().isEmpty) {
      employee.id = _uuid.v4();
    }
    await _box.put(employee.id, employee);
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }
}
