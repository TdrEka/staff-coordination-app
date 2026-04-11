import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:staff_coordination_app/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';

import '../../core/hive_boxes.dart';
import '../../core/utils/notification_scheduler.dart';
import '../../models/client.dart';
import '../../models/employee.dart';
import '../../models/enums.dart';
import '../../models/event.dart';
import '../../models/role_slot.dart';
import '../../models/shift_log.dart';
import '../../providers/employee_provider.dart';
import '../../providers/event_provider.dart';
import '../../widgets/confirm_dialog.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _busy = false;
  bool _remindersEnabled = false;

  @override
  void initState() {
    super.initState();
    final Box<String> settingsBox = Hive.box<String>(settingsBoxName);
    _remindersEnabled = settingsBox.get(remindersEnabledKey) == 'true';
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          _sectionCard(
            context,
            title: l10n.settingsTitle,
            children: <Widget>[
              SwitchListTile(
                title: Text(l10n.settingsNotificationToggle),
                value: _remindersEnabled,
                onChanged: _busy ? null : _onReminderToggle,
              ),
            ],
          ),
          const SizedBox(height: 12),
          _sectionCard(
            context,
            title: l10n.employeesReliabilityScore,
            children: <Widget>[
              const ListTile(
                dense: false,
                title: Text('asistio: +0.1'),
              ),
              const ListTile(
                dense: false,
                title: Text('tarde (<15m): -0.1'),
              ),
              const ListTile(
                dense: false,
                title: Text('tarde (>=15m): -0.3'),
              ),
              const ListTile(
                dense: false,
                title: Text('cancelacion_anticipada (48h+): 0.0'),
              ),
              const ListTile(
                dense: false,
                title: Text('cancelacion_anticipada (<48h): -0.5'),
              ),
              const ListTile(
                dense: false,
                title: Text('ausente: -1.5'),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _busy ? null : _resetAllScores,
                    icon: const Icon(Icons.refresh),
                    label: Text(l10n.settingsReliabilityReset),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _sectionCard(
            context,
            title: 'Copia de seguridad y restauración',
            children: <Widget>[
              Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: const Text('Exporta o importa todos los datos de la aplicación.'),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _busy ? null : _exportBackup,
                        icon: const Icon(Icons.upload_file),
                        label: Text(l10n.settingsExport),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _busy ? null : _importBackup,
                        icon: const Icon(Icons.download),
                        label: Text(l10n.settingsImport),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _sectionCard(
            context,
            title: 'Datos',
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton.tonalIcon(
                    onPressed: _busy ? null : _clearAllData,
                    icon: const Icon(Icons.delete_forever),
                    label: Text(l10n.settingsClearData),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _sectionCard(
            context,
            title: l10n.settingsAbout,
            children: <Widget>[
              FutureBuilder<PackageInfo>(
                future: PackageInfo.fromPlatform(),
                builder: (BuildContext context, AsyncSnapshot<PackageInfo> snapshot) {
                  final String version = snapshot.data?.version ?? '-';
                  final String build = snapshot.data?.buildNumber ?? '-';
                  return ListTile(
                    title: const Text('Versión'),
                    subtitle: Text('v$version ($build)'),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sectionCard(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text(title, style: Theme.of(context).textTheme.titleMedium),
          ),
          ...children,
        ],
      ),
    );
  }

  Future<void> _onReminderToggle(bool value) async {
    setState(() {
      _busy = true;
      _remindersEnabled = value;
    });

    try {
      final Box<String> settingsBox = Hive.box<String>(settingsBoxName);
      await settingsBox.put(remindersEnabledKey, value ? 'true' : 'false');

      if (value) {
        await NotificationScheduler.refreshAllEventReminders();
      } else {
        await NotificationScheduler.cancelAllReminders();
      }
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
        });
      }
    }
  }

  Future<void> _resetAllScores() async {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final bool confirmed = await ConfirmDialog.ask(
      context,
      title: l10n.warning,
      message: l10n.settingsResetScoresConfirm,
      confirmLabel: l10n.settingsReliabilityReset,
    );
    if (!confirmed) {
      return;
    }

    setState(() {
      _busy = true;
    });

    try {
      final EmployeeNotifier employeeNotifier = ref.read(employeesProvider.notifier);
      final List<Employee> employees = ref.read(employeesProvider);

      for (final Employee employee in employees) {
        employee.reliabilityScore = 5.0;
        await employeeNotifier.update(employee);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Puntuaciones restablecidas.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
        });
      }
    }
  }

  Future<void> _exportBackup() async {
    setState(() {
      _busy = true;
    });

    try {
      final Box<Employee> employeesBox = Hive.box<Employee>(employeesBoxName);
      final Box<Event> eventsBox = Hive.box<Event>(eventsBoxName);
      final Box<RoleSlot> slotsBox = Hive.box<RoleSlot>(roleSlotsBoxName);
      final Box<ShiftLog> logsBox = Hive.box<ShiftLog>(shiftLogsBoxName);
      final Box<Client> clientsBox = Hive.box<Client>(clientsBoxName);
      final Box<String> settingsBox = Hive.box<String>(settingsBoxName);

      final DateTime now = DateTime.now();
      final String nowIso = now.toIso8601String();
      final String day = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      final Map<String, dynamic> payload = <String, dynamic>{
        'version': 2,
        'exportedAt': nowIso,
        'employees': employeesBox.values.map(_employeeToMap).toList(),
        'events': eventsBox.values.map(_eventToMap).toList(),
        'roleSlots': slotsBox.values.map(_roleSlotToMap).toList(),
        'shiftLogs': logsBox.values.map(_shiftLogToMap).toList(),
        'clients': clientsBox.values.map(_clientToMap).toList(),
      };

      final String jsonText = const JsonEncoder.withIndent('  ').convert(payload);
      final Directory tempDir = await getTemporaryDirectory();
      final String fileName = 'staffing_backup_$day.json';
      final File file = File('${tempDir.path}/$fileName');
      await file.writeAsString(jsonText);

      await settingsBox.put(lastBackupDateKey, nowIso);

      await Printing.sharePdf(
        bytes: utf8.encode(jsonText),
        filename: fileName,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Copia exportada correctamente.')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al exportar la copia.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
        });
      }
    }
  }

  Future<void> _importBackup() async {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    setState(() {
      _busy = true;
    });

    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: <String>['json'],
      );

      if (result == null || result.files.isEmpty) {
        return;
      }

      final PlatformFile picked = result.files.first;
      String raw;
      if (picked.path != null) {
        raw = await File(picked.path!).readAsString();
      } else if (picked.bytes != null) {
        raw = utf8.decode(picked.bytes!);
      } else {
        throw const FormatException('Invalid file');
      }

      final dynamic decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Malformed JSON');
      }

      if (!decoded.containsKey('version')) {
        throw const FormatException('Missing version field');
      }
      if (decoded['employees'] is! List ||
          decoded['events'] is! List ||
          decoded['roleSlots'] is! List ||
          decoded['shiftLogs'] is! List ||
          decoded['clients'] is! List) {
        throw const FormatException('Missing required arrays');
      }

      final List<dynamic> employeesRaw = decoded['employees'] as List<dynamic>;
      final List<dynamic> eventsRaw = decoded['events'] as List<dynamic>;
      final List<dynamic> slotsRaw = decoded['roleSlots'] as List<dynamic>;
      final List<dynamic> logsRaw = decoded['shiftLogs'] as List<dynamic>;
      final List<dynamic> clientsRaw = decoded['clients'] as List<dynamic>;

      final bool proceed = await ConfirmDialog.ask(
        context,
        title: l10n.importWarningTitle,
        message: l10n.importSummary(
          employeesRaw.length,
          eventsRaw.length,
          logsRaw.length,
        ),
        confirmLabel: l10n.settingsImport,
      );
      if (!proceed) {
        return;
      }

      final List<Employee> employees = employeesRaw
          .map((dynamic e) => _employeeFromMap(e as Map<String, dynamic>))
          .toList();
      final List<Event> events = eventsRaw
          .map((dynamic e) => _eventFromMap(e as Map<String, dynamic>))
          .toList();
      final List<RoleSlot> slots = slotsRaw
          .map((dynamic e) => _roleSlotFromMap(e as Map<String, dynamic>))
          .toList();
      final List<ShiftLog> logs = logsRaw
          .map((dynamic e) => _shiftLogFromMap(e as Map<String, dynamic>))
          .toList();
      final List<Client> clients = clientsRaw
          .map((dynamic e) => _clientFromMap(e as Map<String, dynamic>))
          .toList();

      final Box<Employee> employeesBox = Hive.box<Employee>(employeesBoxName);
      final Box<Event> eventsBox = Hive.box<Event>(eventsBoxName);
      final Box<RoleSlot> slotsBox = Hive.box<RoleSlot>(roleSlotsBoxName);
      final Box<ShiftLog> logsBox = Hive.box<ShiftLog>(shiftLogsBoxName);
      final Box<Client> clientsBox = Hive.box<Client>(clientsBoxName);

      await employeesBox.clear();
      await eventsBox.clear();
      await slotsBox.clear();
      await logsBox.clear();
      await clientsBox.clear();

      for (final Employee employee in employees) {
        await employeesBox.put(employee.id, employee);
      }
      for (final Event event in events) {
        await eventsBox.put(event.id, event);
      }
      for (final RoleSlot slot in slots) {
        await slotsBox.put(slot.id, slot);
      }
      for (final ShiftLog log in logs) {
        await logsBox.put(log.id, log);
      }
      for (final Client client in clients) {
        await clientsBox.put(client.id, client);
      }

      ref.invalidate(employeesProvider);
      ref.invalidate(eventsProvider);
      await NotificationScheduler.refreshAllEventReminders();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Copia importada correctamente.')),
        );
      }
    } on FormatException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('El archivo no tiene un formato válido.')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al importar la copia.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
        });
      }
    }
  }

  Future<void> _clearAllData() async {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final bool confirmed = await ConfirmDialog.ask(
      context,
      title: l10n.warning,
      message: l10n.confirmDeleteMessage,
      confirmLabel: l10n.confirm,
    );
    if (!confirmed) {
      return;
    }

    final bool typedConfirm = await _askTypedDeleteConfirmation();
    if (!typedConfirm) {
      return;
    }

    setState(() {
      _busy = true;
    });

    try {
      await Hive.box<Employee>(employeesBoxName).clear();
      await Hive.box<Event>(eventsBoxName).clear();
      await Hive.box<RoleSlot>(roleSlotsBoxName).clear();
      await Hive.box<ShiftLog>(shiftLogsBoxName).clear();
      await Hive.box<Client>(clientsBoxName).clear();
      await Hive.box<String>(settingsBoxName).clear();
      await NotificationScheduler.cancelAllReminders();

      setState(() {
        _remindersEnabled = false;
      });

      ref.invalidate(employeesProvider);
      ref.invalidate(eventsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Datos eliminados.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
        });
      }
    }
  }

  Future<bool> _askTypedDeleteConfirmation() async {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final TextEditingController controller = TextEditingController();
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmación adicional'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'Escribe DELETE para confirmar'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(controller.text.trim() == 'DELETE'),
              child: Text(l10n.delete),
            ),
          ],
        );
      },
    );
    controller.dispose();
    return confirmed ?? false;
  }

  Map<String, dynamic> _employeeToMap(Employee value) {
    return <String, dynamic>{
      'id': value.id,
      'name': value.name,
      'age': value.age,
      'phone': value.phone,
      'email': value.email,
      'location': value.location,
      'preferredContact': value.preferredContact.name,
      'languages': value.languages,
      'availability': value.availability,
      'reliabilityScore': value.reliabilityScore,
      'roles': value.roles,
      'contractType': value.contractType.name,
      'hourlyRate': value.hourlyRate,
      'status': value.status.name,
      'notes': value.notes,
      'emergencyContact': value.emergencyContact,
      'createdAt': value.createdAt,
      'documents': value.documents,
    };
  }

  Map<String, dynamic> _eventToMap(Event value) {
    return <String, dynamic>{
      'id': value.id,
      'title': value.title,
      'date': value.date,
      'startTime': value.startTime,
      'endTime': value.endTime,
      'callTime': value.callTime,
      'venue': value.venue,
      'address': value.address,
      'parkingNotes': value.parkingNotes,
      'accessNotes': value.accessNotes,
      'clientId': value.clientId,
      'clientName': value.clientName,
      'clientContact': value.clientContact,
      'eventType': value.eventType,
      'dresscode': value.dresscode,
      'status': value.status.name,
      'internalNotes': value.internalNotes,
      'exportNotes': value.exportNotes,
      'payRate': value.payRate,
      'createdAt': value.createdAt,
    };
  }

  Map<String, dynamic> _roleSlotToMap(RoleSlot value) {
    return <String, dynamic>{
      'id': value.id,
      'eventId': value.eventId,
      'roleType': value.roleType,
      'assignedEmployeeId': value.assignedEmployeeId,
      'status': value.status.name,
      'priority': value.priority.name,
      'callTime': value.callTime,
      'notes': value.notes,
    };
  }

  Map<String, dynamic> _shiftLogToMap(ShiftLog value) {
    return <String, dynamic>{
      'id': value.id,
      'employeeId': value.employeeId,
      'eventId': value.eventId,
      'outcome': value.outcome.name,
      'minutesLate': value.minutesLate,
      'notes': value.notes,
      'scoreDelta': value.scoreDelta,
      'loggedAt': value.loggedAt,
    };
  }

  Map<String, dynamic> _clientToMap(Client value) {
    return <String, dynamic>{
      'id': value.id,
      'name': value.name,
      'phone': value.phone,
      'email': value.email,
      'notes': value.notes,
      'eventIds': value.eventIds,
    };
  }

  Employee _employeeFromMap(Map<String, dynamic> map) {
    return Employee(
      id: map['id'] as String,
      name: map['name'] as String,
      age: map['age'] as int?,
      phone: map['phone'] as String,
      email: map['email'] as String?,
      location: map['location'] as String,
      preferredContact: _preferredContactFromName(map['preferredContact'] as String?),
      languages: (map['languages'] as List<dynamic>? ?? <dynamic>[]).cast<String>(),
      availability: map['availability'] as String? ?? '',
      reliabilityScore: (map['reliabilityScore'] as num?)?.toDouble() ?? 5.0,
      roles: (map['roles'] as List<dynamic>? ?? <dynamic>[]).cast<String>(),
      contractType: _contractTypeFromName(map['contractType'] as String?),
      hourlyRate: (map['hourlyRate'] as num?)?.toDouble(),
      status: _employeeStatusFromName(map['status'] as String?),
      notes: map['notes'] as String? ?? '',
      emergencyContact: map['emergencyContact'] as String?,
      createdAt: map['createdAt'] as String? ?? DateTime.now().toIso8601String(),
      documents: (map['documents'] as List<dynamic>?)?.cast<String>(),
    );
  }

  Event _eventFromMap(Map<String, dynamic> map) {
    return Event(
      id: map['id'] as String,
      title: map['title'] as String,
      date: map['date'] as String,
      startTime: map['startTime'] as String,
      endTime: map['endTime'] as String,
      callTime: map['callTime'] as String?,
      venue: map['venue'] as String,
      address: map['address'] as String?,
      parkingNotes: map['parkingNotes'] as String?,
      accessNotes: map['accessNotes'] as String?,
      clientId: map['clientId'] as String?,
      clientName: map['clientName'] as String? ?? '',
      clientContact: map['clientContact'] as String?,
      eventType: map['eventType'] as String?,
      dresscode: map['dresscode'] as String?,
      status: _eventStatusFromName(map['status'] as String?),
      internalNotes: map['internalNotes'] as String? ?? '',
      exportNotes: map['exportNotes'] as String? ?? '',
      payRate: (map['payRate'] as num?)?.toDouble(),
      createdAt: map['createdAt'] as String? ?? DateTime.now().toIso8601String(),
    );
  }

  RoleSlot _roleSlotFromMap(Map<String, dynamic> map) {
    return RoleSlot(
      id: map['id'] as String,
      eventId: map['eventId'] as String,
      roleType: map['roleType'] as String,
      assignedEmployeeId: map['assignedEmployeeId'] as String?,
      status: _slotStatusFromName(map['status'] as String?),
      priority: _slotPriorityFromName(map['priority'] as String?),
      callTime: map['callTime'] as String?,
      notes: map['notes'] as String?,
    );
  }

  ShiftLog _shiftLogFromMap(Map<String, dynamic> map) {
    return ShiftLog(
      id: map['id'] as String,
      employeeId: map['employeeId'] as String,
      eventId: map['eventId'] as String,
      outcome: _shiftOutcomeFromName(map['outcome'] as String?),
      minutesLate: map['minutesLate'] as int?,
      notes: map['notes'] as String?,
      scoreDelta: (map['scoreDelta'] as num?)?.toDouble() ?? 0.0,
      loggedAt: map['loggedAt'] as String? ?? DateTime.now().toIso8601String(),
    );
  }

  Client _clientFromMap(Map<String, dynamic> map) {
    return Client(
      id: map['id'] as String,
      name: map['name'] as String,
      phone: map['phone'] as String,
      email: map['email'] as String?,
      notes: map['notes'] as String?,
      eventIds: (map['eventIds'] as List<dynamic>? ?? <dynamic>[]).cast<String>(),
    );
  }

  PreferredContact _preferredContactFromName(String? value) {
    return PreferredContact.values.firstWhere(
      (PreferredContact e) => e.name == value,
      orElse: () => PreferredContact.phone,
    );
  }

  ContractType _contractTypeFromName(String? value) {
    return ContractType.values.firstWhere(
      (ContractType e) => e.name == value,
      orElse: () => ContractType.freelance,
    );
  }

  EmployeeStatus _employeeStatusFromName(String? value) {
    return EmployeeStatus.values.firstWhere(
      (EmployeeStatus e) => e.name == value,
      orElse: () => EmployeeStatus.active,
    );
  }

  EventStatus _eventStatusFromName(String? value) {
    return EventStatus.values.firstWhere(
      (EventStatus e) => e.name == value,
      orElse: () => EventStatus.draft,
    );
  }

  SlotStatus _slotStatusFromName(String? value) {
    return SlotStatus.values.firstWhere(
      (SlotStatus e) => e.name == value,
      orElse: () => SlotStatus.uncovered,
    );
  }

  SlotPriority _slotPriorityFromName(String? value) {
    return SlotPriority.values.firstWhere(
      (SlotPriority e) => e.name == value,
      orElse: () => SlotPriority.normal,
    );
  }

  ShiftOutcome _shiftOutcomeFromName(String? value) {
    return ShiftOutcome.values.firstWhere(
      (ShiftOutcome e) => e.name == value,
      orElse: () => ShiftOutcome.showed_up,
    );
  }
}
