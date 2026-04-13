import 'package:flutter/material.dart';
import 'package:staff_coordination_app/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:printing/printing.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

import '../../core/utils/pdf_exporter.dart';
import '../../core/utils/notification_scheduler.dart';
import '../../core/ui/app_colors.dart';
import '../../core/utils/localization_utils.dart';
import '../../models/employee.dart';
import '../../models/enums.dart';
import '../../models/event.dart';
import '../../models/role_slot.dart';
import '../../models/shift_log.dart';
import '../../providers/employee_provider.dart';
import '../../providers/event_provider.dart';
import '../../repositories/role_slot_repository.dart';
import '../../repositories/shift_log_repository.dart';
import '../availability/availability_lookup_screen.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/empty_state_panel.dart';
import '../../widgets/role_slot_tile.dart';
import '../../widgets/status_chip.dart';

class EventDetailScreen extends ConsumerStatefulWidget {
  const EventDetailScreen({super.key, required this.eventId});

  final String eventId;

  @override
  ConsumerState<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends ConsumerState<EventDetailScreen> {
  static const List<String> _roleSuggestions = <String>[
    'Camarero',
    'Barman',
    'Coordinador',
    'Chef',
    'Auxiliar',
    'Anfitrión',
    'Seguridad',
  ];

  final RoleSlotRepository _roleSlotRepository = RoleSlotRepository();
  final ShiftLogRepository _shiftLogRepository = ShiftLogRepository();
  final Uuid _uuid = const Uuid();
  List<RoleSlot> _slots = <RoleSlot>[];

  @override
  void initState() {
    super.initState();
    _loadSlots();
  }

  void _loadSlots() {
    _slots = _roleSlotRepository.getByEventId(widget.eventId);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final Event? event = ref.watch(
      eventsProvider.select((List<Event> events) {
        for (final Event candidate in events) {
          if (candidate.id == widget.eventId) {
            return candidate;
          }
        }
        return null;
      }),
    );

    if (event == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.eventsTitle),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
        ),
        body: const Center(child: Text('Evento no encontrado')),
      );
    }

    final List<Employee> employees = ref.watch(employeesProvider);
    _loadSlots();
    _slots.sort((RoleSlot a, RoleSlot b) {
      final bool aCritical = a.priority == SlotPriority.critical && a.status == SlotStatus.uncovered;
      final bool bCritical = b.priority == SlotPriority.critical && b.status == SlotStatus.uncovered;
      if (aCritical == bCritical) {
        return a.roleType.compareTo(b.roleType);
      }
      return aCritical ? -1 : 1;
    });

    final bool hasCriticalUncovered = _slots.any(
      (RoleSlot s) => s.priority == SlotPriority.critical && s.status == SlotStatus.uncovered,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(event.title),
        actions: <Widget>[
          IconButton(
            tooltip: l10n.eventsExportRoster,
            onPressed: () => _shareRosterPdf(event, employees),
            icon: const Icon(Icons.share),
          ),
          IconButton(
            tooltip: l10n.edit,
            onPressed: () => context.go('/events/${event.id}/edit'),
            icon: const Icon(Icons.edit),
          ),
          IconButton(
            tooltip: l10n.delete,
            onPressed: () => _deleteEvent(event),
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          _headerCard(context, event),
          if (hasCriticalUncovered)
            Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.red),
              ),
              child: const Text(
                '⚠',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.w700),
              ),
            ),
          if (hasCriticalUncovered)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                l10n.eventsUncoveredCritical,
                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w700),
              ),
            ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Expanded(
                child: Text(l10n.eventsRoleSlots, style: Theme.of(context).textTheme.titleMedium),
              ),
              TextButton.icon(
                onPressed: () => _showRoleSlotEditor(event.id),
                icon: const Icon(Icons.add),
                label: Text(l10n.eventsAddSlot),
              ),
            ],
          ),
          if (_slots.isEmpty)
            EmptyStatePanel(
              title: 'Aún no hay puestos',
              subtitle: 'Añade un puesto para empezar a asignar personal.',
              actionLabel: l10n.eventsAddSlot,
              icon: Icons.playlist_add_check_circle_outlined,
              onAction: () => _showRoleSlotEditor(event.id),
            ),
          ..._slots.map((RoleSlot slot) {
            final String assignedName = _assignedEmployeeName(slot.assignedEmployeeId, employees);
            return RoleSlotTile(
              slot: slot,
              assignedEmployeeName: assignedName,
              onAssign: () => _showAssignBottomSheet(event, slot),
              onConfirm: () => _confirmPendingSlot(slot, assignedName),
              onTap: () => _showRoleSlotEditor(event.id, existing: slot),
              onLongPress: () => _tryClearAssignment(slot),
            );
          }),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(l10n.eventsInternalNotes, style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  Text(event.internalNotes.isEmpty ? '-' : event.internalNotes),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showRoleSlotEditor(event.id),
        icon: const Icon(Icons.add),
        label: Text(l10n.eventsAddSlot),
      ),
    );
  }

  Widget _headerCard(BuildContext context, Event event) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final String date = _formatDate(event.date);
    final String timeRange = '${event.startTime} - ${event.endTime}';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    event.title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                StatusChip(
                  label: eventStatusLabel(AppLocalizations.of(context)!, event.status),
                  color: AppColors.eventStatus(event.status),
                ),
                
              ],
            ),
            const SizedBox(height: 8),
            Text('$date - $timeRange'),
            const SizedBox(height: 4),
            Text(event.venue),
            if ((event.address ?? '').isNotEmpty)
              InkWell(
                onTap: () => _openMap(event.address!),
                child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    event.address!,
                    style: TextStyle(color: Theme.of(context).colorScheme.primary),
                  ),
                ),
              ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                if ((event.dresscode ?? '').isNotEmpty)
                  StatusChip(
                    label: '${l10n.eventsDresscode}: ${event.dresscode!}',
                    color: Colors.blueGrey,
                  ),
                if ((event.callTime ?? '').isNotEmpty)
                  StatusChip(
                    label: '${l10n.eventsCallTime}: ${event.callTime!}',
                    color: Colors.deepPurple,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${l10n.eventsClient}: ${event.clientName.isEmpty ? '-' : event.clientName}',
            ),
            Text('${l10n.eventsClientContact}: ${event.clientContact ?? '-'}'),
          ],
        ),
      ),
    );
  }

  Future<void> _openMap(String address) async {
    final Uri uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}',
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _shareRosterPdf(Event event, List<Employee> employees) async {
    final Map<String, Employee> employeeMap = <String, Employee>{
      for (final Employee employee in employees) employee.id: employee,
    };

    final List<RoleSlot> slots = _roleSlotRepository.getByEventId(event.id);
    final bytes = await generateRosterPdf(event, slots, employeeMap);
    await Printing.sharePdf(bytes: bytes, filename: '${event.title}_roster.pdf');
  }

  String _assignedEmployeeName(String? id, List<Employee> employees) {
    if (id == null || id.isEmpty) {
      return AppLocalizations.of(context)!.slotUnassigned;
    }
    for (final Employee employee in employees) {
      if (employee.id == id) {
        return employee.name;
      }
    }
    return AppLocalizations.of(context)!.slotUnassigned;
  }

  Future<void> _showRoleSlotEditor(String eventId, {RoleSlot? existing}) async {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final bool isEditing = existing != null;
    final TextEditingController roleController =
        TextEditingController(text: existing?.roleType ?? '');
    final TextEditingController notesController =
        TextEditingController(text: existing?.notes ?? '');
    SlotPriority selectedPriority = existing?.priority ?? SlotPriority.normal;
    TimeOfDay? selectedCallTime = _parseTime(existing?.callTime);
    int quantity = 1;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, void Function(void Function()) setLocalState) {
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 16,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      isEditing
                          ? 'Editar puesto'
                          : (quantity == 1 ? 'Añadir puesto' : 'Añadir $quantity puestos'),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    if (!isEditing) ...<Widget>[
                      Text('Cantidad', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 6),
                      Row(
                        children: <Widget>[
                          IconButton(
                            onPressed: quantity > 1
                                ? () {
                                    setLocalState(() {
                                      quantity -= 1;
                                    });
                                  }
                                : null,
                            icon: const Icon(Icons.remove),
                          ),
                          SizedBox(
                            width: 32,
                            child: Text(
                              '$quantity',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          IconButton(
                            onPressed: quantity < 30
                                ? () {
                                    setLocalState(() {
                                      quantity += 1;
                                    });
                                  }
                                : null,
                            icon: const Icon(Icons.add),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],
                    Autocomplete<String>(
                      optionsBuilder: (TextEditingValue value) {
                        if (value.text.isEmpty) {
                          return _roleSuggestions;
                        }
                        return _roleSuggestions.where(
                          (String role) => role.toLowerCase().contains(value.text.toLowerCase()),
                        );
                      },
                      fieldViewBuilder: (
                        BuildContext context,
                        TextEditingController textController,
                        FocusNode focusNode,
                        VoidCallback onFieldSubmitted,
                      ) {
                        textController.value = roleController.value;
                        return TextField(
                          controller: textController,
                          focusNode: focusNode,
                          decoration: InputDecoration(
                            labelText: l10n.slotRole,
                          ),
                          onChanged: (String value) {
                            roleController.text = value;
                          },
                        );
                      },
                      onSelected: (String value) {
                        roleController.text = value;
                      },
                    ),
                    const SizedBox(height: 12),
                    SegmentedButton<SlotPriority>(
                      segments: <ButtonSegment<SlotPriority>>[
                        ButtonSegment<SlotPriority>(
                          value: SlotPriority.critical,
                          label: Text(l10n.slotPriorityCritical),
                        ),
                        ButtonSegment<SlotPriority>(
                          value: SlotPriority.normal,
                          label: Text(l10n.slotPriorityNormal),
                        ),
                      ],
                      selected: <SlotPriority>{selectedPriority},
                      onSelectionChanged: (Set<SlotPriority> value) {
                        setLocalState(() {
                          selectedPriority = value.first;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      minVerticalPadding: 10,
                        title: Text(l10n.eventsCallTime),
                        subtitle: Text(selectedCallTime == null
                          ? 'Opcional'
                          : _formatTime(selectedCallTime!)),
                      trailing: const Icon(Icons.schedule),
                      onTap: () async {
                        final TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime: selectedCallTime ?? const TimeOfDay(hour: 9, minute: 0),
                        );
                        if (picked == null) {
                          return;
                        }
                        setLocalState(() {
                          selectedCallTime = picked;
                        });
                      },
                    ),
                    TextField(
                      controller: notesController,
                      maxLines: 2,
                      decoration: InputDecoration(labelText: l10n.shiftLogNotes),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => context.pop(),
                            child: Text(l10n.cancel),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: FilledButton(
                            onPressed: () async {
                              if (roleController.text.trim().isEmpty) {
                                return;
                              }
                              if (isEditing) {
                                final RoleSlot slot = RoleSlot(
                                  id: existing!.id,
                                  eventId: eventId,
                                  roleType: roleController.text.trim(),
                                  assignedEmployeeId: existing.assignedEmployeeId,
                                  status: existing.status,
                                  priority: selectedPriority,
                                  callTime: selectedCallTime == null ? null : _formatTime(selectedCallTime!),
                                  notes: notesController.text.trim().isEmpty
                                      ? null
                                      : notesController.text.trim(),
                                );
                                await _roleSlotRepository.save(slot);
                              } else {
                                for (int i = 0; i < quantity; i += 1) {
                                  final RoleSlot slot = RoleSlot(
                                    id: _uuid.v4(),
                                    eventId: eventId,
                                    roleType: roleController.text.trim(),
                                    assignedEmployeeId: null,
                                    status: SlotStatus.uncovered,
                                    priority: selectedPriority,
                                    callTime: selectedCallTime == null ? null : _formatTime(selectedCallTime!),
                                    notes: notesController.text.trim().isEmpty
                                        ? null
                                        : notesController.text.trim(),
                                  );
                                  await _roleSlotRepository.save(slot);
                                }
                              }
                              final Event? currentEvent =
                                  ref.read(eventsProvider.notifier).getById(eventId);
                              if (currentEvent != null) {
                                await NotificationScheduler.scheduleEventReminder(currentEvent);
                              }
                              if (mounted) {
                                setState(_loadSlots);
                              }
                              if (context.mounted) {
                                context.pop();
                              }
                            },
                            child: Text(isEditing ? l10n.save : l10n.eventsAdd),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    roleController.dispose();
    notesController.dispose();
  }

  Future<void> _showAssignBottomSheet(Event event, RoleSlot slot) async {
    final List<RoleSlot> allSlots = _roleSlotRepository.getAll();
    final List<Event> allEvents = ref.read(eventsProvider);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return AvailabilityLookupScreen.assignment(
          targetEvent: event,
          initialRole: slot.roleType,
          allSlots: allSlots,
          allEvents: allEvents,
          excludeSlotId: slot.id,
          onAssignSelected: (Employee employee) async {
            final RoleSlot updated = RoleSlot(
              id: slot.id,
              eventId: slot.eventId,
              roleType: slot.roleType,
              assignedEmployeeId: employee.id,
              status: SlotStatus.pending,
              priority: slot.priority,
              callTime: slot.callTime,
              notes: slot.notes,
            );
            await _roleSlotRepository.save(updated);
            await NotificationScheduler.scheduleEventReminder(event);
            if (mounted) {
              setState(_loadSlots);
            }
          },
        );
      },
    );
  }

  Future<void> _confirmPendingSlot(RoleSlot slot, String assignedName) async {
    final bool proceed = await ConfirmDialog.ask(
      context,
      title: 'Confirmar asignación',
      message: '¿Confirmar $assignedName para ${slot.roleType}?',
      confirmLabel: AppLocalizations.of(context)!.confirm,
    );
    if (!proceed) {
      return;
    }

    final RoleSlot updated = RoleSlot(
      id: slot.id,
      eventId: slot.eventId,
      roleType: slot.roleType,
      assignedEmployeeId: slot.assignedEmployeeId,
      status: SlotStatus.confirmed,
      priority: slot.priority,
      callTime: slot.callTime,
      notes: slot.notes,
    );
    await _roleSlotRepository.save(updated);
    final Event? event = ref.read(eventsProvider.notifier).getById(slot.eventId);
    if (event != null) {
      await NotificationScheduler.scheduleEventReminder(event);
    }
    if (mounted) {
      setState(_loadSlots);
    }
  }

  Future<void> _tryClearAssignment(RoleSlot slot) async {
    if (slot.assignedEmployeeId == null || slot.assignedEmployeeId!.isEmpty) {
      return;
    }
    final bool proceed = await ConfirmDialog.ask(
      context,
      title: 'Quitar asignación',
      message: '¿Quitar asignación del puesto ${slot.roleType}?',
      confirmLabel: AppLocalizations.of(context)!.slotRemoveAssignment,
    );
    if (!proceed) {
      return;
    }

    final RoleSlot updated = RoleSlot(
      id: slot.id,
      eventId: slot.eventId,
      roleType: slot.roleType,
      assignedEmployeeId: null,
      status: SlotStatus.uncovered,
      priority: slot.priority,
      callTime: slot.callTime,
      notes: slot.notes,
    );
    await _roleSlotRepository.save(updated);
    final Event? event = ref.read(eventsProvider.notifier).getById(slot.eventId);
    if (event != null) {
      await NotificationScheduler.scheduleEventReminder(event);
    }
    if (mounted) {
      setState(_loadSlots);
    }
  }

  Future<void> _deleteEvent(Event event) async {
    final bool proceed = await ConfirmDialog.ask(
      context,
      title: AppLocalizations.of(context)!.confirmDeleteTitle,
      message: AppLocalizations.of(context)!.confirmDeleteMessage,
      confirmLabel: AppLocalizations.of(context)!.delete,
    );
    if (!proceed) {
      return;
    }

    final List<RoleSlot> slots = _roleSlotRepository.getByEventId(event.id);
    final List<ShiftLog> logs = _shiftLogRepository.getByEventId(event.id);

    for (final RoleSlot slot in slots) {
      await _roleSlotRepository.delete(slot.id);
    }
    for (final ShiftLog log in logs) {
      await _shiftLogRepository.delete(log.id);
    }

    await ref.read(eventsProvider.notifier).delete(event.id);

    if (mounted) {
      context.go('/events');
    }
  }

  static String _formatDate(String value) {
    final DateTime d = DateTime.tryParse(value) ?? DateTime.fromMillisecondsSinceEpoch(0);
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  static TimeOfDay? _parseTime(String? hhmm) {
    if (hhmm == null || !hhmm.contains(':')) {
      return null;
    }
    final List<String> parts = hhmm.split(':');
    if (parts.length != 2) {
      return null;
    }
    final int? hour = int.tryParse(parts[0]);
    final int? minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) {
      return null;
    }
    return TimeOfDay(hour: hour, minute: minute);
  }

  static String _formatTime(TimeOfDay value) {
    final String hh = value.hour.toString().padLeft(2, '0');
    final String mm = value.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }
}
