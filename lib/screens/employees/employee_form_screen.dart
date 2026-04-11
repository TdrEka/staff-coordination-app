import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:staff_coordination_app/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils/localization_utils.dart';
import '../../models/employee.dart';
import '../../models/enums.dart';
import '../../providers/employee_provider.dart';

class EmployeeFormScreen extends ConsumerStatefulWidget {
  const EmployeeFormScreen({
    super.key,
    this.employee,
    this.employeeId,
  });

  final Employee? employee;
  final String? employeeId;

  @override
  ConsumerState<EmployeeFormScreen> createState() => _EmployeeFormScreenState();
}

class _EmployeeFormScreenState extends ConsumerState<EmployeeFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _languagesController = TextEditingController();
  final TextEditingController _scoreController = TextEditingController();
  final TextEditingController _hourlyRateController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _emergencyController = TextEditingController();
  final TextEditingController _documentsController = TextEditingController();
  final TextEditingController _customRoleController = TextEditingController();

  static const List<String> _weekdays = <String>[
    'mon',
    'tue',
    'wed',
    'thu',
    'fri',
    'sat',
    'sun',
  ];

  static const List<String> _defaultRoles = <String>[
    'Camarero',
    'Barman',
    'Coordinador',
    'Chef',
    'Auxiliar',
    'Anfitrión',
  ];

  final Map<String, _DayAvailability> _availability = <String, _DayAvailability>{};
  final Set<String> _roles = <String>{};

  PreferredContact _preferredContact = PreferredContact.phone;
  ContractType _contractType = ContractType.freelance;
  bool _dirty = false;
  Employee? _editingEmployee;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    for (final String day in _weekdays) {
      _availability[day] = _DayAvailability();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _locationController.dispose();
    _languagesController.dispose();
    _scoreController.dispose();
    _hourlyRateController.dispose();
    _notesController.dispose();
    _emergencyController.dispose();
    _documentsController.dispose();
    _customRoleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final List<Employee> employees = ref.watch(employeesProvider);

    Employee? source = widget.employee;
    if (source == null && widget.employeeId != null) {
      for (final Employee candidate in employees) {
        if (candidate.id == widget.employeeId) {
          source = candidate;
          break;
        }
      }
    }

    if (!_initialized) {
      _editingEmployee = source;
      _seedForm(source);
      _initialized = true;
    }

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_editingEmployee == null ? l10n.employeesAdd : l10n.edit),
          actions: <Widget>[
            TextButton(
              onPressed: _onCancelPressed,
              child: Text(l10n.cancel),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: l10n.employeesName),
                onChanged: (_) => _setDirty(),
                validator: (String? value) {
                  final String v = (value ?? '').trim();
                  if (v.length < 2 || v.length > 80) {
                    return l10n.validationNameLength;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: l10n.employeesPhone),
                keyboardType: TextInputType.phone,
                onChanged: (_) => _setDirty(),
                validator: (String? value) {
                  final String v = (value ?? '').trim();
                  if (v.isEmpty) {
                    return l10n.validationRequired;
                  }
                  if (!RegExp(r'^[0-9+\s]+$').hasMatch(v)) {
                    return l10n.validationPhoneFormat;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: l10n.employeesEmail),
                keyboardType: TextInputType.emailAddress,
                onChanged: (_) => _setDirty(),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<PreferredContact>(
                value: _preferredContact,
                decoration: InputDecoration(labelText: l10n.employeesPreferredContact),
                items: PreferredContact.values
                    .map(
                      (PreferredContact c) => DropdownMenuItem<PreferredContact>(
                        value: c,
                        child: Text(preferredContactLabel(l10n, c)),
                      ),
                    )
                    .toList(),
                onChanged: (PreferredContact? value) {
                  if (value == null) {
                    return;
                  }
                  setState(() {
                    _preferredContact = value;
                    _dirty = true;
                  });
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(labelText: l10n.employeesLocation),
                onChanged: (_) => _setDirty(),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _ageController,
                decoration: const InputDecoration(labelText: 'Edad'),
                keyboardType: TextInputType.number,
                onChanged: (_) => _setDirty(),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _languagesController,
                decoration: const InputDecoration(labelText: 'Idiomas'),
                onChanged: (_) => _setDirty(),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _scoreController,
                decoration: InputDecoration(labelText: l10n.employeesReliabilityScore),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onChanged: (_) => _setDirty(),
                validator: (String? value) {
                  final double? score = double.tryParse((value ?? '').trim());
                  if (score == null || score < 0 || score > 10) {
                    return l10n.validationScoreRange;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<ContractType>(
                value: _contractType,
                decoration: InputDecoration(labelText: l10n.employeesContractType),
                items: ContractType.values
                    .map(
                      (ContractType c) => DropdownMenuItem<ContractType>(
                        value: c,
                        child: Text(contractTypeLabel(l10n, c)),
                      ),
                    )
                    .toList(),
                onChanged: (ContractType? value) {
                  if (value == null) {
                    return;
                  }
                  setState(() {
                    _contractType = value;
                    _dirty = true;
                  });
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _hourlyRateController,
                decoration: InputDecoration(labelText: l10n.employeesHourlyRate),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onChanged: (_) => _setDirty(),
              ),
              const SizedBox(height: 20),
              Text(l10n.employeesRoles, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _defaultRoles.map((String role) {
                  return FilterChip(
                    label: Text(role),
                    selected: _roles.contains(role),
                    onSelected: (bool selected) {
                      setState(() {
                        if (selected) {
                          _roles.add(role);
                        } else {
                          _roles.remove(role);
                        }
                        _dirty = true;
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 10),
              Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _customRoleController,
                      decoration: const InputDecoration(labelText: 'Añadir función personalizada'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _addCustomRole,
                    child: const Text('Añadir'),
                  ),
                ],
              ),
              if (_roles.isNotEmpty) ...<Widget>[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: _roles
                      .map(
                        (String role) => InputChip(
                          label: Text(role),
                          onDeleted: () {
                            setState(() {
                              _roles.remove(role);
                              _dirty = true;
                            });
                          },
                        ),
                      )
                      .toList(),
                ),
              ],
              const SizedBox(height: 20),
              Text(l10n.employeesAvailability, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              ..._weekdays.map((String day) => _buildAvailabilityRow(context, day)),
              const SizedBox(height: 20),
              TextFormField(
                controller: _notesController,
                decoration: InputDecoration(labelText: l10n.employeesNotes),
                maxLines: 3,
                onChanged: (_) => _setDirty(),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emergencyController,
                decoration: const InputDecoration(labelText: 'Contacto de emergencia'),
                onChanged: (_) => _setDirty(),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _documentsController,
                decoration: const InputDecoration(labelText: 'Documentos'),
                onChanged: (_) => _setDirty(),
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
      ),
    );
  }

  Widget _buildAvailabilityRow(BuildContext context, String day) {
    final _DayAvailability model = _availability[day]!;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: <Widget>[
            Expanded(child: Text(dayLabel(tr(context), day))),
            Switch(
              value: model.enabled,
              onChanged: (bool enabled) {
                setState(() {
                  model.enabled = enabled;
                  if (enabled && model.start == null) {
                    model.start = const TimeOfDay(hour: 9, minute: 0);
                    model.end = const TimeOfDay(hour: 17, minute: 0);
                  }
                  _dirty = true;
                });
              },
            ),
            if (model.enabled)
              TextButton(
                onPressed: () => _pickTimeRange(context, model),
                child: Text(_formatRange(model)),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickTimeRange(BuildContext context, _DayAvailability model) async {
    final TimeOfDay? start = await showTimePicker(
      context: context,
      initialTime: model.start ?? const TimeOfDay(hour: 9, minute: 0),
    );
    if (start == null || !mounted) {
      return;
    }
    final TimeOfDay? end = await showTimePicker(
      context: context,
      initialTime: model.end ?? const TimeOfDay(hour: 17, minute: 0),
    );
    if (end == null) {
      return;
    }
    setState(() {
      model.start = start;
      model.end = end;
      _dirty = true;
    });
  }

  Future<bool> _onWillPop() async {
    if (!_dirty) {
      return true;
    }
    return _confirmDiscard();
  }

  Future<void> _onCancelPressed() async {
    if (!_dirty || await _confirmDiscard()) {
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  Future<bool> _confirmDiscard() async {
    final bool? response = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('¿Descartar cambios?'),
          content: const Text('Tienes cambios sin guardar.'),
          actions: <Widget>[
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Seguir editando')),
            FilledButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Descartar')),
          ],
        );
      },
    );
    return response ?? false;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final Employee employee = Employee(
      id: _editingEmployee?.id ?? '',
      name: _nameController.text.trim(),
      age: int.tryParse(_ageController.text.trim()),
      phone: _phoneController.text.trim(),
      email: _nullable(_emailController.text),
      location: _locationController.text.trim(),
      preferredContact: _preferredContact,
      languages: _splitCsv(_languagesController.text),
      availability: jsonEncode(_toAvailabilityMap()),
      reliabilityScore: double.parse(_scoreController.text.trim()),
      roles: _roles.toList(),
      contractType: _contractType,
      hourlyRate: double.tryParse(_hourlyRateController.text.trim()),
      status: _editingEmployee?.status ?? EmployeeStatus.active,
      notes: _notesController.text.trim(),
      emergencyContact: _nullable(_emergencyController.text),
      createdAt: _editingEmployee?.createdAt ?? DateTime.now().toIso8601String(),
      documents: _splitCsv(_documentsController.text).isEmpty ? null : _splitCsv(_documentsController.text),
    );

    final EmployeeNotifier notifier = ref.read(employeesProvider.notifier);
    if (_editingEmployee == null) {
      await notifier.add(employee);
    } else {
      await notifier.update(employee);
    }

    if (mounted) {
      context.go('/employees/${employee.id}');
    }
  }

  void _seedForm(Employee? employee) {
    if (employee == null) {
      _scoreController.text = '5.0';
      return;
    }

    _nameController.text = employee.name;
    _ageController.text = employee.age?.toString() ?? '';
    _phoneController.text = employee.phone;
    _emailController.text = employee.email ?? '';
    _locationController.text = employee.location;
    _languagesController.text = employee.languages.join(', ');
    _scoreController.text = employee.reliabilityScore.toStringAsFixed(1);
    _hourlyRateController.text = employee.hourlyRate?.toString() ?? '';
    _notesController.text = employee.notes;
    _emergencyController.text = employee.emergencyContact ?? '';
    _documentsController.text = employee.documents?.join(', ') ?? '';

    _preferredContact = employee.preferredContact;
    _contractType = employee.contractType;
    _roles
      ..clear()
      ..addAll(employee.roles);

    _decodeAvailability(employee.availability);
  }

  void _decodeAvailability(String rawAvailability) {
    if (rawAvailability.trim().isEmpty) {
      return;
    }
    try {
      final Object? decoded = jsonDecode(rawAvailability);
      if (decoded is! Map<String, dynamic>) {
        return;
      }
      for (final String day in _weekdays) {
        final dynamic value = decoded[day];
        if (value is List && value.isNotEmpty && value.first is Map<String, dynamic>) {
          final Map<String, dynamic> first = value.first as Map<String, dynamic>;
          _availability[day] = _DayAvailability(
            enabled: true,
            start: _parseTime(first['start']?.toString()),
            end: _parseTime(first['end']?.toString()),
          );
        }
      }
    } catch (_) {
      // Keep default availability state if parsing fails.
    }
  }

  Map<String, List<Map<String, String>>> _toAvailabilityMap() {
    final Map<String, List<Map<String, String>>> output = <String, List<Map<String, String>>>{};
    for (final String day in _weekdays) {
      final _DayAvailability model = _availability[day]!;
      if (!model.enabled) {
        output[day] = <Map<String, String>>[];
        continue;
      }
      output[day] = <Map<String, String>>[
        <String, String>{
          'start': _formatTime(model.start ?? const TimeOfDay(hour: 9, minute: 0)),
          'end': _formatTime(model.end ?? const TimeOfDay(hour: 17, minute: 0)),
        },
      ];
    }
    return output;
  }

  static String _formatRange(_DayAvailability model) {
    final String start = _formatTime(model.start ?? const TimeOfDay(hour: 9, minute: 0));
    final String end = _formatTime(model.end ?? const TimeOfDay(hour: 17, minute: 0));
    return '$start - $end';
  }

  static String _formatTime(TimeOfDay value) {
    final String h = value.hour.toString().padLeft(2, '0');
    final String m = value.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  static TimeOfDay? _parseTime(String? value) {
    if (value == null || !value.contains(':')) {
      return null;
    }
    final List<String> pieces = value.split(':');
    if (pieces.length != 2) {
      return null;
    }
    final int? hour = int.tryParse(pieces[0]);
    final int? minute = int.tryParse(pieces[1]);
    if (hour == null || minute == null) {
      return null;
    }
    return TimeOfDay(hour: hour, minute: minute);
  }

  static List<String> _splitCsv(String value) {
    return value
        .split(',')
        .map((String e) => e.trim())
        .where((String e) => e.isNotEmpty)
        .toList();
  }

  static String? _nullable(String value) {
    final String cleaned = value.trim();
    if (cleaned.isEmpty) {
      return null;
    }
    return cleaned;
  }

  void _setDirty() {
    if (_dirty) {
      return;
    }
    setState(() {
      _dirty = true;
    });
  }

  void _addCustomRole() {
    final String role = _customRoleController.text.trim();
    if (role.isEmpty) {
      return;
    }
    setState(() {
      _roles.add(role);
      _customRoleController.clear();
      _dirty = true;
    });
  }
}

class _DayAvailability {
  _DayAvailability({
    this.enabled = false,
    this.start,
    this.end,
  });

  bool enabled;
  TimeOfDay? start;
  TimeOfDay? end;
}
