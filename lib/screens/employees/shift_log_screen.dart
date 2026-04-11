import 'package:flutter/material.dart';
import 'package:staff_coordination_app/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../core/utils/localization_utils.dart';
import '../../core/utils/score_calculator.dart';
import '../../models/employee.dart';
import '../../models/enums.dart';
import '../../models/event.dart';
import '../../models/role_slot.dart';
import '../../models/shift_log.dart';
import '../../providers/employee_provider.dart';
import '../../providers/event_provider.dart';
import '../../repositories/event_repository.dart';
import '../../repositories/role_slot_repository.dart';
import '../../repositories/shift_log_repository.dart';
import '../../widgets/empty_state_panel.dart';
import '../../widgets/reliability_badge.dart';
import '../../widgets/status_chip.dart';

class ShiftLogScreen extends ConsumerStatefulWidget {
  const ShiftLogScreen.forEvent({
    super.key,
    required this.eventId,
  })  : employeeId = null,
        historyMode = false;

  const ShiftLogScreen.forEmployee({
    super.key,
    required this.employeeId,
  })  : eventId = null,
        historyMode = true;

  final String? eventId;
  final String? employeeId;
  final bool historyMode;

  @override
  ConsumerState<ShiftLogScreen> createState() => _ShiftLogScreenState();
}

class _ShiftLogScreenState extends ConsumerState<ShiftLogScreen> {
  final ShiftLogRepository _shiftLogRepository = ShiftLogRepository();
  final RoleSlotRepository _roleSlotRepository = RoleSlotRepository();
  final EventRepository _eventRepository = EventRepository();
  final Uuid _uuid = const Uuid();

  List<ShiftLog> _historyLogs = <ShiftLog>[];

  @override
  void initState() {
    super.initState();
    if (widget.historyMode) {
      _loadHistory();
    }
  }

  void _loadHistory() {
    final String employeeId = widget.employeeId ?? '';
    _historyLogs = _shiftLogRepository.getByEmployeeId(employeeId)
      ..sort((ShiftLog a, ShiftLog b) =>
          (DateTime.tryParse(b.loggedAt) ?? DateTime.fromMillisecondsSinceEpoch(0)).compareTo(
            DateTime.tryParse(a.loggedAt) ?? DateTime.fromMillisecondsSinceEpoch(0),
          ));
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    assert(() {
      l10n.toString();
      return true;
    }());
    if (widget.historyMode) {
      return _buildHistoryMode(context);
    }
    return _buildPostEventMode(context);
  }

  Widget _buildPostEventMode(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final String eventId = widget.eventId ?? '';
    final Event? event = ref.read(eventsProvider.notifier).getById(eventId);

    if (event == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.shiftLogTitle)),
        body: const Center(child: Text('Evento no encontrado')),
      );
    }

    final List<Employee> allEmployees = ref.watch(employeesProvider);
    final Map<String, Employee> byId = <String, Employee>{
      for (final Employee employee in allEmployees) employee.id: employee,
    };

    final List<RoleSlot> assignedSlots = _roleSlotRepository
        .getByEventId(eventId)
        .where((RoleSlot slot) => (slot.assignedEmployeeId ?? '').trim().isNotEmpty)
        .toList();

    final Map<String, _PostLogDraft> drafts = <String, _PostLogDraft>{};
    for (final RoleSlot slot in assignedSlots) {
      final String employeeId = slot.assignedEmployeeId!.trim();
      if (drafts.containsKey(employeeId)) {
        continue;
      }
      drafts[employeeId] = _PostLogDraft();
    }

    final List<String> assignedEmployeeIds = drafts.keys.toList();

    return _PostEventBody(
      event: event,
      assignedEmployeeIds: assignedEmployeeIds,
      employeeById: byId,
      onLogAll: (Map<String, _PostLogDraft> values) async {
        if (assignedEmployeeIds.isEmpty) {
          return;
        }

        for (final String employeeId in assignedEmployeeIds) {
          final Employee? employee = byId[employeeId];
          if (employee == null) {
            continue;
          }

          final _PostLogDraft draft = values[employeeId] ?? _PostLogDraft();
          final double delta = computeScoreDelta(
            draft.outcome,
            draft.minutesLate,
            advanceNotice: draft.advanceNotice,
          );

          String? notes = draft.notes?.trim().isEmpty ?? true ? null : draft.notes!.trim();
          if (draft.outcome == ShiftOutcome.cancelled_advance && draft.advanceNotice) {
            notes = notes == null ? '48h+' : '48h+ | $notes';
          }

          final ShiftLog log = ShiftLog(
            id: _uuid.v4(),
            employeeId: employee.id,
            eventId: event.id,
            outcome: draft.outcome,
            minutesLate: draft.outcome == ShiftOutcome.late ? draft.minutesLate : null,
            notes: notes,
            scoreDelta: delta,
            loggedAt: DateTime.now().toIso8601String(),
          );

          await _shiftLogRepository.save(log);

          employee.reliabilityScore = applyDelta(employee.reliabilityScore, delta);
          await ref.read(employeesProvider.notifier).update(employee);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registros guardados')),
          );
          context.pop();
        }
      },
    );
  }

  Widget _buildHistoryMode(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final String employeeId = widget.employeeId ?? '';
    final Employee? employee = ref.read(employeesProvider.notifier).getById(employeeId);

    if (employee == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.shiftLogHistory)),
        body: const Center(child: Text('No se encontró la persona')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.shiftLogHistory)),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: <Widget>[
                ReliabilityBadge(score: employee.reliabilityScore, size: 62),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(employee.name, style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 4),
                      Text('Puntuación actual: ${employee.reliabilityScore.toStringAsFixed(1)}'),
                      Text('Turnos registrados: ${_historyLogs.length}'),
                    ],
                  ),
                ),
                FilledButton.tonal(
                  onPressed: () => _showManualAdjustDialog(context, employee),
                  child: Text(l10n.employeesAdjustScore),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _historyLogs.isEmpty
                ? EmptyStatePanel(
                    title: 'Aún no hay registros de turno',
                    subtitle: 'Cuando registres turnos, aparecerán aquí.',
                    actionLabel: 'Volver al perfil',
                    icon: Icons.history_toggle_off,
                    onAction: () => context.pop(),
                  )
                : ListView.builder(
                    itemCount: _historyLogs.length,
                    itemBuilder: (BuildContext context, int index) {
                      final ShiftLog log = _historyLogs[index];
                      final Event? event = _eventRepository.getById(log.eventId);
                        final String title = event?.title ?? (log.outcome == ShiftOutcome.manual_override
                          ? 'Ajuste manual'
                          : 'Evento desconocido');
                      final String date = _formatDate(event?.date ?? log.loggedAt);

                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: ListTile(
                          title: Text(title),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              const SizedBox(height: 2),
                              Text(date),
                              const SizedBox(height: 4),
                              Text(_deltaLabel(log.scoreDelta), style: const TextStyle(fontWeight: FontWeight.w700)),
                              if ((log.notes ?? '').trim().isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(log.notes!),
                                ),
                            ],
                          ),
                          trailing: StatusChip(
                            label: shiftOutcomeLabel(l10n, log.outcome),
                            color: _outcomeColor(log.outcome),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _showManualAdjustDialog(BuildContext context, Employee employee) async {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final TextEditingController scoreController = TextEditingController(
      text: employee.reliabilityScore.toStringAsFixed(1),
    );
    final TextEditingController reasonController = TextEditingController();

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.employeesAdjustScore),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: scoreController,
                decoration: const InputDecoration(labelText: 'Nueva puntuación'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: reasonController,
                decoration: InputDecoration(labelText: l10n.shiftLogOverrideReason),
                maxLines: 2,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(l10n.cancel)),
            FilledButton(onPressed: () => Navigator.of(context).pop(true), child: Text(l10n.save)),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    final double? requested = double.tryParse(scoreController.text.trim());
    final String reason = reasonController.text.trim();

    if (requested == null || reason.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Introduce una puntuación válida y un motivo.')),
        );
      }
      return;
    }

    final double clamped = double.parse(requested.clamp(0.0, 10.0).toStringAsFixed(1));
    final double delta = double.parse((clamped - employee.reliabilityScore).toStringAsFixed(1));

    final ShiftLog log = ShiftLog(
      id: _uuid.v4(),
      employeeId: employee.id,
      eventId: 'manual-override',
      outcome: ShiftOutcome.manual_override,
      notes: 'Ajuste manual: $reason',
      scoreDelta: delta,
      loggedAt: DateTime.now().toIso8601String(),
    );

    await _shiftLogRepository.save(log);
    employee.reliabilityScore = clamped;
    await ref.read(employeesProvider.notifier).update(employee);

    setState(_loadHistory);
  }

  static String _deltaLabel(double value) {
    if (value > 0) {
      return '+${value.toStringAsFixed(1)}';
    }
    return value.toStringAsFixed(1);
  }

  static Color _outcomeColor(ShiftOutcome outcome) {
    switch (outcome) {
      case ShiftOutcome.showed_up:
        return Colors.green;
      case ShiftOutcome.late:
        return Colors.amber.shade800;
      case ShiftOutcome.no_show:
        return Colors.red;
      case ShiftOutcome.cancelled_advance:
        return Colors.orange;
      case ShiftOutcome.manual_override:
        return Colors.blueGrey;
    }
  }

  static String _formatDate(String raw) {
    final DateTime date = DateTime.tryParse(raw) ?? DateTime.fromMillisecondsSinceEpoch(0);
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

class _PostEventBody extends StatefulWidget {
  const _PostEventBody({
    required this.event,
    required this.assignedEmployeeIds,
    required this.employeeById,
    required this.onLogAll,
  });

  final Event event;
  final List<String> assignedEmployeeIds;
  final Map<String, Employee> employeeById;
  final Future<void> Function(Map<String, _PostLogDraft> values) onLogAll;

  @override
  State<_PostEventBody> createState() => _PostEventBodyState();
}

class _PostEventBodyState extends State<_PostEventBody> {
  late final Map<String, _PostLogDraft> _drafts = <String, _PostLogDraft>{
    for (final String id in widget.assignedEmployeeIds) id: _PostLogDraft(),
  };

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.shiftLogTitle)),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${widget.event.title} • ${_formatDate(widget.event.date)}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: widget.assignedEmployeeIds.isEmpty
                ? EmptyStatePanel(
                    title: 'No hay personal asignado',
                    subtitle: 'Asigna personal al evento para registrar turnos.',
                    actionLabel: 'Abrir evento',
                    icon: Icons.group_off,
                    onAction: () => context.go('/events/${widget.event.id}'),
                  )
                : ListView.builder(
                    itemCount: widget.assignedEmployeeIds.length,
                    itemBuilder: (BuildContext context, int index) {
                      final String employeeId = widget.assignedEmployeeIds[index];
                      final Employee? employee = widget.employeeById[employeeId];
                      if (employee == null) {
                        return const SizedBox.shrink();
                      }
                      final _PostLogDraft draft = _drafts[employeeId] ?? _PostLogDraft();

                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(employee.name, style: Theme.of(context).textTheme.titleMedium),
                              const SizedBox(height: 8),
                              DropdownButtonFormField<ShiftOutcome>(
                                value: draft.outcome,
                                decoration: const InputDecoration(labelText: 'Resultado'),
                                items: <DropdownMenuItem<ShiftOutcome>>[
                                  DropdownMenuItem(
                                    value: ShiftOutcome.showed_up,
                                    child: Text(l10n.shiftLogOutcomeShowedUp),
                                  ),
                                  DropdownMenuItem(
                                    value: ShiftOutcome.late,
                                    child: Text(l10n.shiftLogOutcomeLate),
                                  ),
                                  DropdownMenuItem(
                                    value: ShiftOutcome.no_show,
                                    child: Text(l10n.shiftLogOutcomeNoShow),
                                  ),
                                  DropdownMenuItem(
                                    value: ShiftOutcome.cancelled_advance,
                                    child: Text(l10n.shiftLogOutcomeCancelledAdvance),
                                  ),
                                ],
                                onChanged: (ShiftOutcome? value) {
                                  if (value == null) {
                                    return;
                                  }
                                  setState(() {
                                    draft.outcome = value;
                                  });
                                },
                              ),
                              if (draft.outcome == ShiftOutcome.late) ...<Widget>[
                                const SizedBox(height: 8),
                                TextFormField(
                                  initialValue: draft.minutesLate?.toString() ?? '',
                                  decoration: InputDecoration(labelText: l10n.shiftLogMinutesLate),
                                  keyboardType: TextInputType.number,
                                  onChanged: (String value) {
                                    draft.minutesLate = int.tryParse(value);
                                  },
                                ),
                              ],
                              if (draft.outcome == ShiftOutcome.cancelled_advance) ...<Widget>[
                                const SizedBox(height: 8),
                                SwitchListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(l10n.shiftLogAdvanceNotice),
                                  value: draft.advanceNotice,
                                  onChanged: (bool value) {
                                    setState(() {
                                      draft.advanceNotice = value;
                                    });
                                  },
                                ),
                              ],
                              const SizedBox(height: 8),
                              TextFormField(
                                initialValue: draft.notes ?? '',
                                decoration: InputDecoration(labelText: l10n.shiftLogNotes),
                                maxLines: 2,
                                onChanged: (String value) {
                                  draft.notes = value;
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => widget.onLogAll(_drafts),
                  icon: const Icon(Icons.save),
                  label: Text(l10n.shiftLogAll),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PostLogDraft {
  ShiftOutcome outcome = ShiftOutcome.showed_up;
  int? minutesLate;
  bool advanceNotice = false;
  String? notes;
}

String _formatDate(String raw) {
  final DateTime date = DateTime.tryParse(raw) ?? DateTime.fromMillisecondsSinceEpoch(0);
  return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}
