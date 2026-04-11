import 'package:flutter/material.dart';
import 'package:staff_coordination_app/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/employee.dart';
import '../../models/event.dart';
import '../../models/role_slot.dart';
import '../../providers/employee_provider.dart';
import '../../providers/availability_provider.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/empty_state_panel.dart';
import '../../widgets/employee_card.dart';

class AvailabilityLookupScreen extends ConsumerStatefulWidget {
  const AvailabilityLookupScreen({super.key})
      : targetEvent = null,
        allSlots = const <RoleSlot>[],
        initialRole = null,
        asBottomSheet = false,
        onAssignSelected = null;

  const AvailabilityLookupScreen.assignment({
    super.key,
    required this.targetEvent,
    required this.allSlots,
    this.initialRole,
    this.asBottomSheet = true,
    this.onAssignSelected,
  });

  final Event? targetEvent;
  final List<RoleSlot> allSlots;
  final String? initialRole;
  final bool asBottomSheet;
  final Future<void> Function(Employee employee)? onAssignSelected;

  @override
  ConsumerState<AvailabilityLookupScreen> createState() => _AvailabilityLookupScreenState();
}

class _AvailabilityLookupScreenState extends ConsumerState<AvailabilityLookupScreen> {
  static const List<String> _roleFilterSuggestions = <String>[
    'Camarero',
    'Barman',
    'Coordinador',
    'Chef',
    'Auxiliar',
    'Anfitrión',
  ];

  @override
  void initState() {
    super.initState();
    final DateTime now = DateTime.now();
    final DateTime initialDate = widget.targetEvent == null
        ? DateTime(now.year, now.month, now.day)
        : DateTime.tryParse(widget.targetEvent!.date) ?? DateTime(now.year, now.month, now.day);
    final TimeOfDay initialStart = widget.targetEvent == null
        ? const TimeOfDay(hour: 9, minute: 0)
        : _parseTime(widget.targetEvent!.startTime) ?? const TimeOfDay(hour: 9, minute: 0);
    final TimeOfDay initialEnd = widget.targetEvent == null
        ? const TimeOfDay(hour: 17, minute: 0)
        : _parseTime(widget.targetEvent!.endTime) ?? const TimeOfDay(hour: 17, minute: 0);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      ref.read(availabilityLookupProvider.notifier).resetCriteria(
            selectedDate: initialDate,
            startTime: initialStart,
            endTime: initialEnd,
            roleFilter: widget.initialRole,
          );
      _runSearch();
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final AvailabilityLookupState state = ref.watch(availabilityLookupProvider);
    final List<EmployeeAvailabilityResult> results = state.results;

    final Widget content = Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: _pickerTile(
                      title: l10n.availabilityDate,
                      value: _formatDate(state.selectedDate),
                      onTap: _pickDate,
                    ),
                  ),
                  Expanded(
                    child: _pickerTile(
                      title: l10n.availabilityTimeRange,
                      value: '${_formatTime(state.startTime)} - ${_formatTime(state.endTime)}',
                      onTap: _pickTimeRange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: <Widget>[
                    InputChip(
                      label: Text(
                        state.roleFilter == null
                            ? 'Todas las funciones'
                            : '${l10n.slotRole}: ${state.roleFilter!}',
                      ),
                      onDeleted: state.roleFilter == null
                          ? null
                          : () => ref.read(availabilityLookupProvider.notifier).setRoleFilter(null),
                    ),
                    ..._roleFilterSuggestions.map(
                      (String role) => FilterChip(
                        label: Text(role),
                        selected: (state.roleFilter ?? '').toLowerCase() == role.toLowerCase(),
                        onSelected: (_) {
                          ref.read(availabilityLookupProvider.notifier).setRoleFilter(role);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _runSearch,
                  icon: const Icon(Icons.search),
                  label: Text(l10n.availabilitySearch),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: state.searched && results.isEmpty
              ? EmptyStatePanel(
                  title: l10n.availabilityEmpty,
                  subtitle: 'Prueba con otra fecha, horario o función.',
                  actionLabel: l10n.availabilitySearch,
                  icon: Icons.person_search_outlined,
                  onAction: _runSearch,
                )
              : ListView.builder(
                  itemCount: results.length,
                  itemBuilder: (BuildContext context, int index) {
                    final EmployeeAvailabilityResult result = results[index];
                    return _candidateTile(result);
                  },
                ),
        ),
      ],
    );

    if (widget.asBottomSheet) {
      return SafeArea(
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.8,
          child: content,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.availabilityTitle)),
      body: content,
    );
  }

  Widget _candidateTile(EmployeeAvailabilityResult result) {
    final Employee employee = result.employee;
    final bool conflicted = result.hasConflict;

    return Opacity(
      opacity: conflicted ? 0.58 : 1,
      child: EmployeeCard(
        employee: employee,
        onTap: () => _handleSelectCandidate(result),
        trailing: conflicted
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 18),
                  const SizedBox(width: 2),
                  Text(
                    AppLocalizations.of(context)!.availabilityConflict,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                  ),
                ],
              )
            : null,
      ),
    );
  }

  Future<void> _handleSelectCandidate(EmployeeAvailabilityResult result) async {
    final bool conflicted = result.hasConflict;
    final Employee employee = result.employee;

    if (widget.onAssignSelected == null) {
      if (mounted) {
        context.go('/employees/${employee.id}');
      }
      return;
    }

    if (conflicted) {
      final String conflictEventTitle =
          result.conflictingEvent?.title ?? 'Otro evento';
      final bool proceed = await ConfirmDialog.ask(
        context,
        title: AppLocalizations.of(context)!.availabilityConflict,
        message: '${employee.name} coincide con "$conflictEventTitle". ¿Asignar igualmente?',
        confirmLabel: AppLocalizations.of(context)!.slotAssign,
        cancelLabel: AppLocalizations.of(context)!.cancel,
      );
      if (!proceed) {
        return;
      }
    }

    await widget.onAssignSelected!(employee);

    if (mounted && widget.asBottomSheet) {
      Navigator.of(context).pop();
    }
  }

  Widget _pickerTile({
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      height: 56,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(value),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final DateTime initial = ref.read(availabilityLookupProvider).selectedDate;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(initial.year - 2),
      lastDate: DateTime(initial.year + 2),
    );
    if (picked == null) {
      return;
    }
    ref.read(availabilityLookupProvider.notifier).setDate(picked);
  }

  Future<void> _pickTimeRange() async {
    final AvailabilityLookupState state = ref.read(availabilityLookupProvider);
    final TimeOfDay? start = await showTimePicker(
      context: context,
      initialTime: state.startTime,
    );
    if (start == null || !mounted) {
      return;
    }
    final TimeOfDay? end = await showTimePicker(
      context: context,
      initialTime: state.endTime,
    );
    if (end == null) {
      return;
    }
    final AvailabilityLookupNotifier notifier = ref.read(availabilityLookupProvider.notifier);
    notifier.setStartTime(start);
    notifier.setEndTime(end);
  }

  void _runSearch() {
    final List<Employee> employees = ref.read(employeesProvider);
    ref.read(availabilityLookupProvider.notifier).search(
          employees: employees,
          allSlots: widget.allSlots,
          targetEvent: widget.targetEvent,
        );
  }

  static TimeOfDay? _parseTime(String hhmm) {
    if (!hhmm.contains(':')) {
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

  static String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  static String _formatTime(TimeOfDay value) {
    final String hh = value.hour.toString().padLeft(2, '0');
    final String mm = value.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }
}
