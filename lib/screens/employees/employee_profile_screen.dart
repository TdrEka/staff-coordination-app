import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:staff_coordination_app/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils/localization_utils.dart';
import '../../models/employee.dart';
import '../../repositories/shift_log_repository.dart';
import '../../providers/employee_provider.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/reliability_badge.dart';

class EmployeeProfileScreen extends ConsumerWidget {
  const EmployeeProfileScreen({super.key, required this.employeeId});

  final String employeeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final List<Employee> employees = ref.watch(employeesProvider);
    Employee? employee;
    for (final Employee candidate in employees) {
      if (candidate.id == employeeId) {
        employee = candidate;
        break;
      }
    }

    if (employee == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.employeesTitle)),
        body: const Center(child: Text('No se encontró la persona.')),
      );
    }

    final Employee currentEmployee = employee;
  final ShiftLogRepository shiftLogRepository = ShiftLogRepository();
  final int shiftLogCount = shiftLogRepository.getByEmployeeId(currentEmployee.id).length;

    final List<String> availableDays = _availableDays(currentEmployee.availability, l10n);

    return Scaffold(
      appBar: AppBar(
        title: Text(currentEmployee.name),
        actions: <Widget>[
          IconButton(
            tooltip: l10n.edit,
            onPressed: () => context.go('/employees/${currentEmployee.id}/edit'),
            icon: const Icon(Icons.edit),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Row(
            children: <Widget>[
              ReliabilityBadge(score: currentEmployee.reliabilityScore, size: 64),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      currentEmployee.name,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${l10n.employeesReliabilityScore}: ${currentEmployee.reliabilityScore.toStringAsFixed(1)}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text('Turnos registrados: $shiftLogCount'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FilledButton.tonalIcon(
            onPressed: () => context.go('/employees/${currentEmployee.id}/shifts'),
            icon: const Icon(Icons.history),
            label: Text(l10n.employeesShiftHistory),
          ),
          const SizedBox(height: 16),
          _section(
            context,
            title: 'Contacto',
            rows: <Widget>[
              _row(l10n.employeesPhone, currentEmployee.phone),
              _row(l10n.employeesEmail, currentEmployee.email ?? '-'),
              _row(l10n.employeesPreferredContact, preferredContactLabel(l10n, currentEmployee.preferredContact)),
              _row('Contacto de emergencia', currentEmployee.emergencyContact ?? '-'),
            ],
          ),
          const SizedBox(height: 12),
          _section(
            context,
            title: 'Trabajo',
            rows: <Widget>[
              _row(l10n.employeesRoles, currentEmployee.roles.join(', ')),
              _row(l10n.employeesContractType, contractTypeLabel(l10n, currentEmployee.contractType)),
              _row(l10n.employeesHourlyRate, currentEmployee.hourlyRate?.toStringAsFixed(2) ?? '-'),
              _row('Idiomas', currentEmployee.languages.join(', ')),
              _row('Estado', employeeStatusLabel(l10n, currentEmployee.status)),
            ],
          ),
          const SizedBox(height: 12),
          _section(
            context,
            title: 'Disponibilidad',
            rows: <Widget>[
              _row(
                'Días disponibles',
                availableDays.isEmpty ? 'Sin días configurados' : availableDays.join(', '),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _section(
            context,
            title: 'Notas',
            rows: <Widget>[
              _row(l10n.employeesNotes, currentEmployee.notes.isEmpty ? '-' : currentEmployee.notes),
              _row(l10n.employeesLocation, currentEmployee.location),
              _row('Edad', currentEmployee.age?.toString() ?? '-'),
              _row('Creado', currentEmployee.createdAt),
              _row('Documentos', currentEmployee.documents?.join(', ') ?? '-'),
            ],
          ),
          const SizedBox(height: 20),
          FilledButton.tonalIcon(
            onPressed: () async {
              final bool confirmed = await _confirmDeactivate(context);
              if (!confirmed) {
                return;
              }
              await ref.read(employeesProvider.notifier).softDelete(currentEmployee.id);
              if (context.mounted) {
                context.go('/employees');
              }
            },
            icon: const Icon(Icons.archive_outlined),
            label: Text(l10n.employeesDeactivate),
          ),
        ],
      ),
    );
  }

  static Widget _section(
    BuildContext context, {
    required String title,
    required List<Widget> rows,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ...rows,
          ],
        ),
      ),
    );
  }

  static Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 140,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  static List<String> _availableDays(String rawAvailability, AppLocalizations l10n) {
    if (rawAvailability.trim().isEmpty) {
      return <String>[];
    }
    try {
      final Object? decoded = jsonDecode(rawAvailability);
      if (decoded is! Map<String, dynamic>) {
        return <String>[];
      }
      final List<String> days = <String>[];
      decoded.forEach((String key, dynamic value) {
        if (value is List && value.isNotEmpty) {
          days.add(dayLabel(l10n, key));
        }
      });
      return days;
    } catch (_) {
      return <String>[];
    }
  }

  static Future<bool> _confirmDeactivate(BuildContext context) async {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    return ConfirmDialog.ask(
      context,
      title: l10n.confirmDeleteTitle,
      message: l10n.confirmDeleteMessage,
      confirmLabel: l10n.employeesDeactivate,
    );
  }
}
