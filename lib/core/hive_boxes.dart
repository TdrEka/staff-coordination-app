import 'dart:developer' as developer;
import 'dart:io';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

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

Future<Box<T>> _openBoxSafe<T>(String name) async {
  try {
    return await Hive.openBox<T>(name);
  } catch (error, stackTrace) {
    final bool corruption = _isCorruptionError(error);

    developer.log(
      'Failed to open Hive box "$name" (corruption=$corruption): $error',
      name: 'hive_boxes',
      error: error,
      stackTrace: stackTrace,
    );

    if (!corruption) {
      // Non-corruption failures (e.g. temporary I/O or storage full) must not
      // delete user data. Bubble up so startup can show a controlled error.
      rethrow;
    }

    await _backupBoxFiles(name);

    // Corruption confirmed: recreate the affected box so app can continue.
    await Hive.deleteBoxFromDisk(name);
    return await Hive.openBox<T>(name);
  }
}

bool _isCorruptionError(Object error) {
  final String message = error.toString().toLowerCase();
  const List<String> corruptionSignals = <String>[
    'corrupt',
    'corrupted',
    'checksum',
    'invalid frame',
    'failed to read',
    'cannot read',
    'unexpected eof',
    'bad state: read',
    'format exception',
  ];

  for (final String signal in corruptionSignals) {
    if (message.contains(signal)) {
      return true;
    }
  }
  return false;
}

Future<void> _backupBoxFiles(String name) async {
  try {
    final int stamp = DateTime.now().millisecondsSinceEpoch;
    final Directory dir = await getApplicationDocumentsDirectory();
    if (!await dir.exists()) {
      return;
    }

    final List<String> candidates = <String>[
      '$name.hive',
      '$name.lock',
    ];

    for (final String fileName in candidates) {
      final File source = File(
        '${dir.path}${Platform.pathSeparator}$fileName',
      );
      if (!await source.exists()) {
        continue;
      }
      final File target = File(
        '${source.path}.bak.$stamp',
      );
      await source.copy(target.path);
    }
  } catch (error, stackTrace) {
    // Backup is best-effort; never block recovery if backup copy fails.
    developer.log(
      'Failed to back up Hive box files for "$name": $error',
      name: 'hive_boxes',
      error: error,
      stackTrace: stackTrace,
    );
  }
}

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
    await _openBoxSafe<Employee>(employeesBoxName);
  }
  if (!Hive.isBoxOpen(eventsBoxName)) {
    await _openBoxSafe<Event>(eventsBoxName);
  }
  if (!Hive.isBoxOpen(roleSlotsBoxName)) {
    await _openBoxSafe<RoleSlot>(roleSlotsBoxName);
  }
  if (!Hive.isBoxOpen(shiftLogsBoxName)) {
    await _openBoxSafe<ShiftLog>(shiftLogsBoxName);
  }
  if (!Hive.isBoxOpen(clientsBoxName)) {
    await _openBoxSafe<Client>(clientsBoxName);
  }
  if (!Hive.isBoxOpen(settingsBoxName)) {
    await _openBoxSafe<String>(settingsBoxName);
  }
}
