import 'package:hive_flutter/hive_flutter.dart';

import '../models/client.dart';
import '../models/employee.dart';
import '../models/enums.dart';
import '../models/event.dart';
import '../models/role_slot.dart';
import '../models/shift_log.dart';

const String employeesBoxName = 'employees';
const String eventsBoxName = 'events';
const String roleSlotsBoxName = 'roleSlots';
const String shiftLogsBoxName = 'shiftLogs';
const String clientsBoxName = 'clients';
const String settingsBoxName = 'settings';
const String lastBackupDateKey = 'lastBackupDate';
const String remindersEnabledKey = 'remindersEnabled';

bool _hiveInitialized = false;

Future<void> initHive() async {
  if (!_hiveInitialized) {
    await Hive.initFlutter();
    _hiveInitialized = true;
  }

  if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(EmployeeAdapter());
  if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(EventAdapter());
  if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(RoleSlotAdapter());
  if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(ShiftLogAdapter());
  if (!Hive.isAdapterRegistered(4)) Hive.registerAdapter(ClientAdapter());
  if (!Hive.isAdapterRegistered(10)) {
    Hive.registerAdapter(PreferredContactAdapter());
  }
  if (!Hive.isAdapterRegistered(11)) Hive.registerAdapter(ContractTypeAdapter());
  if (!Hive.isAdapterRegistered(12)) {
    Hive.registerAdapter(EmployeeStatusAdapter());
  }
  if (!Hive.isAdapterRegistered(13)) Hive.registerAdapter(SlotStatusAdapter());
  if (!Hive.isAdapterRegistered(14)) {
    Hive.registerAdapter(SlotPriorityAdapter());
  }
  if (!Hive.isAdapterRegistered(15)) Hive.registerAdapter(EventStatusAdapter());
  if (!Hive.isAdapterRegistered(16)) {
    Hive.registerAdapter(ShiftOutcomeAdapter());
  }

  if (!Hive.isBoxOpen(employeesBoxName)) {
    await Hive.openBox<Employee>(employeesBoxName);
  }
  if (!Hive.isBoxOpen(eventsBoxName)) {
    await Hive.openBox<Event>(eventsBoxName);
  }
  if (!Hive.isBoxOpen(roleSlotsBoxName)) {
    await Hive.openBox<RoleSlot>(roleSlotsBoxName);
  }
  if (!Hive.isBoxOpen(shiftLogsBoxName)) {
    await Hive.openBox<ShiftLog>(shiftLogsBoxName);
  }
  if (!Hive.isBoxOpen(clientsBoxName)) {
    await Hive.openBox<Client>(clientsBoxName);
  }
  if (!Hive.isBoxOpen(settingsBoxName)) {
    await Hive.openBox<String>(settingsBoxName);
  }
}
