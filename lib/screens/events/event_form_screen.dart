import 'package:flutter/material.dart';
import 'package:staff_coordination_app/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../models/enums.dart';
import '../../models/event.dart';
import '../../providers/event_provider.dart';

class EventFormScreen extends ConsumerStatefulWidget {
  const EventFormScreen({
    super.key,
    this.event,
    this.eventId,
    this.initialDate,
  });

  final Event? event;
  final String? eventId;
  final DateTime? initialDate;

  @override
  ConsumerState<EventFormScreen> createState() => _EventFormScreenState();
}

class _EventFormScreenState extends ConsumerState<EventFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final Uuid _uuid = const Uuid();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _venueController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _parkingController = TextEditingController();
  final TextEditingController _accessController = TextEditingController();
  final TextEditingController _clientNameController = TextEditingController();
  final TextEditingController _clientContactController = TextEditingController();
  final TextEditingController _dresscodeController = TextEditingController();
  final TextEditingController _internalNotesController = TextEditingController();
  final TextEditingController _exportNotesController = TextEditingController();
  final TextEditingController _payRateController = TextEditingController();

  DateTime? _date;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  TimeOfDay? _callTime;
  EventStatus _status = EventStatus.draft;
  String? _eventType;

  bool _initialized = false;
  bool _notFoundConfirmed = false;
  Event? _editingEvent;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_initialized) {
        setState(() {
          _notFoundConfirmed = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _venueController.dispose();
    _addressController.dispose();
    _parkingController.dispose();
    _accessController.dispose();
    _clientNameController.dispose();
    _clientContactController.dispose();
    _dresscodeController.dispose();
    _internalNotesController.dispose();
    _exportNotesController.dispose();
    _payRateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final Event? fromState = widget.eventId == null
        ? null
        : ref.watch(
            eventsProvider.select((List<Event> events) {
              for (final Event candidate in events) {
                if (candidate.id == widget.eventId) {
                  return candidate;
                }
              }
              return null;
            }),
          );

    final Event? source = widget.event ?? fromState;

    if (!_initialized && widget.eventId == null) {
      _seed(source);
      _editingEvent = source;
      _initialized = true;
    }

    if (!_initialized && source != null) {
      _seed(source);
      _editingEvent = source;
      _initialized = true;
    }

    // If we're in edit mode but the event can't be found, show a recovery screen.
    if (widget.eventId != null && !_initialized && source == null) {
      // Give Riverpod one frame to populate state before declaring not found.
      if (_notFoundConfirmed) {
        return Scaffold(
          appBar: AppBar(title: const Text('Editar evento')),
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Icon(Icons.event_busy_outlined, size: 48),
                const SizedBox(height: 16),
                const Text('Evento no encontrado'),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => context.pop(),
                  child: const Text('Volver'),
                ),
              ],
            ),
          ),
        );
      }
    }

    if (!_initialized && widget.eventId != null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.edit)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_editingEvent == null ? l10n.eventsAdd : l10n.edit),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            _sectionHeader(context, 'Información básica'),
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(labelText: l10n.eventsName),
              validator: (String? value) => (value ?? '').trim().isEmpty ? l10n.validationRequired : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _eventType,
              decoration: InputDecoration(labelText: l10n.eventsType),
              items: <DropdownMenuItem<String>>[
                DropdownMenuItem<String>(value: 'wedding', child: Text(l10n.eventsTypeWedding)),
                DropdownMenuItem<String>(value: 'corporate', child: Text(l10n.eventsTypeCorporate)),
                DropdownMenuItem<String>(value: 'private dinner', child: Text(l10n.eventsTypePrivateDinner)),
                DropdownMenuItem<String>(value: 'other', child: Text(l10n.eventsTypeOther)),
              ],
              onChanged: (String? value) {
                setState(() {
                  _eventType = value;
                });
              },
            ),
            const SizedBox(height: 16),
            _sectionHeader(context, 'Horario'),
            _pickerTile(
              context,
              title: l10n.eventsDate,
              value: _date == null ? 'Seleccionar fecha' : _formatDate(_date!),
              onTap: _pickDate,
            ),
            _pickerTile(
              context,
              title: l10n.eventsStartTime,
              value: _startTime == null ? 'Seleccionar hora' : _formatTime(_startTime!),
              onTap: () => _pickTime(_TimeTarget.start),
            ),
            _pickerTile(
              context,
              title: l10n.eventsEndTime,
              value: _endTime == null ? 'Seleccionar hora' : _formatTime(_endTime!),
              onTap: () => _pickTime(_TimeTarget.end),
            ),
            _pickerTile(
              context,
              title: l10n.eventsCallTime,
              value: _callTime == null ? 'Opcional' : _formatTime(_callTime!),
              onTap: () => _pickTime(_TimeTarget.call),
            ),
            const SizedBox(height: 16),
            _sectionHeader(context, 'Lugar y acceso'),
            TextFormField(
              controller: _venueController,
              decoration: InputDecoration(labelText: l10n.eventsVenue),
              validator: (String? value) => (value ?? '').trim().isEmpty ? l10n.validationRequired : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _addressController,
              decoration: InputDecoration(labelText: l10n.eventsAddress),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _parkingController,
              decoration: InputDecoration(labelText: l10n.eventsParkingNotes),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _accessController,
              decoration: InputDecoration(labelText: l10n.eventsAccessNotes),
            ),
            const SizedBox(height: 16),
            _sectionHeader(context, l10n.eventsClient),
            TextFormField(
              controller: _clientNameController,
              decoration: InputDecoration(labelText: l10n.eventsClient),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _clientContactController,
              decoration: InputDecoration(labelText: l10n.eventsClientContact),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _dresscodeController,
              decoration: InputDecoration(labelText: l10n.eventsDresscode),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<EventStatus>(
              value: _status,
              decoration: const InputDecoration(labelText: 'Estado'),
              items: EventStatus.values
                  .map(
                    (EventStatus status) => DropdownMenuItem<EventStatus>(
                      value: status,
                      child: Text(_statusLabel(l10n, status)),
                    ),
                  )
                  .toList(),
              onChanged: (EventStatus? value) {
                if (value == null) {
                  return;
                }
                setState(() {
                  _status = value;
                });
              },
            ),
            const SizedBox(height: 16),
            _sectionHeader(context, 'Exportación'),
            TextFormField(
              controller: _internalNotesController,
              decoration: InputDecoration(labelText: l10n.eventsInternalNotes),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _exportNotesController,
              decoration: InputDecoration(labelText: l10n.eventsExportNotes),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _payRateController,
              decoration: InputDecoration(labelText: l10n.eventsPayRate),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save),
              label: Text(l10n.save),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _sectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title, style: Theme.of(context).textTheme.titleMedium),
    );
  }

  Widget _pickerTile(
    BuildContext context, {
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      subtitle: Text(value),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Future<void> _pickDate() async {
    final DateTime now = DateTime.now();
    final DateTime initial = _date ?? now;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );
    if (picked == null) {
      return;
    }
    setState(() {
      _date = picked;
    });
  }

  Future<void> _pickTime(_TimeTarget target) async {
    TimeOfDay initial = const TimeOfDay(hour: 9, minute: 0);
    switch (target) {
      case _TimeTarget.start:
        initial = _startTime ?? initial;
        break;
      case _TimeTarget.end:
        initial = _endTime ?? const TimeOfDay(hour: 17, minute: 0);
        break;
      case _TimeTarget.call:
        initial = _callTime ?? const TimeOfDay(hour: 8, minute: 30);
        break;
    }
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initial,
    );
    if (picked == null) {
      return;
    }
    setState(() {
      if (target == _TimeTarget.start) {
        _startTime = picked;
      } else if (target == _TimeTarget.end) {
        _endTime = picked;
      } else {
        _callTime = picked;
      }
    });
  }

  Future<void> _save() async {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_date == null || _startTime == null || _endTime == null) {
      _showSnack(l10n.validationRequired);
      return;
    }

    final int startMinutes = _startTime!.hour * 60 + _startTime!.minute;
    final int endMinutes = _endTime!.hour * 60 + _endTime!.minute;
    if (startMinutes >= endMinutes) {
      _showSnack(l10n.validationTimeOrder);
      return;
    }

    final DateTime today = DateTime.now();
    final DateTime todayDate = DateTime(today.year, today.month, today.day);
    final DateTime chosenDate = DateTime(_date!.year, _date!.month, _date!.day);
    if (chosenDate.isBefore(todayDate)) {
      final bool continueSave = await _confirmPastDateWarning();
      if (!continueSave) {
        return;
      }
    }

    final Event event = Event(
      id: _editingEvent?.id ?? _uuid.v4(),
      title: _titleController.text.trim(),
      date: chosenDate.toIso8601String(),
      startTime: _formatTime(_startTime!),
      endTime: _formatTime(_endTime!),
      callTime: _callTime == null ? null : _formatTime(_callTime!),
      venue: _venueController.text.trim(),
      address: _nullable(_addressController.text),
      parkingNotes: _nullable(_parkingController.text),
      accessNotes: _nullable(_accessController.text),
      clientId: _editingEvent?.clientId,
      clientName: _clientNameController.text.trim(),
      clientContact: _nullable(_clientContactController.text),
      eventType: _eventType,
      dresscode: _nullable(_dresscodeController.text),
      status: _status,
      internalNotes: _internalNotesController.text.trim(),
      exportNotes: _exportNotesController.text.trim(),
      payRate: double.tryParse(_payRateController.text.trim()),
      createdAt: _editingEvent?.createdAt ?? DateTime.now().toIso8601String(),
    );

    if (_editingEvent == null) {
      await ref.read(eventsProvider.notifier).add(event);
    } else {
      await ref.read(eventsProvider.notifier).update(event);
    }

    if (mounted) {
      context.go('/events/${event.id}');
    }
  }

  Future<bool> _confirmPastDateWarning() async {
    final bool? response = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.warning),
          content: Text(AppLocalizations.of(context)!.validationPastDateWarning),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(AppLocalizations.of(context)!.confirm),
            ),
          ],
        );
      },
    );
    return response ?? false;
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  static String? _nullable(String value) {
    final String trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  void _seed(Event? event) {
    if (event == null) {
      final DateTime seeded = widget.initialDate ?? DateTime.now();
      _date = DateTime(seeded.year, seeded.month, seeded.day);
      _startTime = const TimeOfDay(hour: 9, minute: 0);
      _endTime = const TimeOfDay(hour: 17, minute: 0);
      return;
    }

    _titleController.text = event.title;
    _venueController.text = event.venue;
    _addressController.text = event.address ?? '';
    _parkingController.text = event.parkingNotes ?? '';
    _accessController.text = event.accessNotes ?? '';
    _clientNameController.text = event.clientName;
    _clientContactController.text = event.clientContact ?? '';
    _dresscodeController.text = event.dresscode ?? '';
    _internalNotesController.text = event.internalNotes;
    _exportNotesController.text = event.exportNotes;
    _payRateController.text = event.payRate?.toString() ?? '';
    _status = event.status;
    _eventType = event.eventType;

    _date = DateTime.tryParse(event.date);
    _startTime = _parseTime(event.startTime);
    _endTime = _parseTime(event.endTime);
    _callTime = _parseTime(event.callTime);
  }

  static String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  static String _formatTime(TimeOfDay value) {
    final String hh = value.hour.toString().padLeft(2, '0');
    final String mm = value.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  static TimeOfDay? _parseTime(String? value) {
    if (value == null || !value.contains(':')) {
      return null;
    }
    final List<String> parts = value.split(':');
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

  static String _statusLabel(AppLocalizations l10n, EventStatus status) {
    switch (status) {
      case EventStatus.draft:
        return l10n.eventsStatusDraft;
      case EventStatus.confirmed:
        return l10n.eventsStatusConfirmed;
      case EventStatus.completed:
        return l10n.eventsStatusCompleted;
      case EventStatus.cancelled:
        return l10n.eventsStatusCancelled;
    }
  }
}

enum _TimeTarget {
  start,
  end,
  call,
}
