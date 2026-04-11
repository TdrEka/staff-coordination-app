import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/employee.dart';
import '../models/enums.dart';
import '../repositories/employee_repository.dart';

final Provider<EmployeeRepository> employeeRepositoryProvider = Provider<EmployeeRepository>((
  Ref<EmployeeRepository> ref,
) {
  return EmployeeRepository();
});

final StateNotifierProvider<EmployeeNotifier, List<Employee>> employeesProvider =
    StateNotifierProvider<EmployeeNotifier, List<Employee>>((Ref ref) {
      return EmployeeNotifier(ref.read(employeeRepositoryProvider));
    });

class EmployeeNotifier extends StateNotifier<List<Employee>> {
  EmployeeNotifier(this._repository) : super(<Employee>[]) {
    _load();
  }

  final EmployeeRepository _repository;

  void _load() {
    state = _repository.getAllIncludingInactive();
  }

  Employee? getById(String id) {
    for (final Employee employee in state) {
      if (employee.id == id) {
        return employee;
      }
    }
    return null;
  }

  Future<void> add(Employee employee) async {
    await _repository.save(employee);
    _load();
  }

  Future<void> update(Employee employee) async {
    await _repository.save(employee);
    _load();
  }

  Future<void> softDelete(String id) async {
    final Employee? employee = _repository.getById(id);
    if (employee == null) {
      return;
    }
    employee.status = EmployeeStatus.inactive;
    await _repository.save(employee);
    _load();
  }

  Future<void> reactivate(String id) async {
    final Employee? employee = _repository.getById(id);
    if (employee == null) {
      return;
    }
    employee.status = EmployeeStatus.active;
    await _repository.save(employee);
    _load();
  }
}
