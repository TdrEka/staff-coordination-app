import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/utils/conflict_checker.dart';
import '../models/employee.dart';
import '../models/enums.dart';
import '../models/event.dart';
import '../models/role_slot.dart';

final StateNotifierProvider<AvailabilityLookupNotifier, AvailabilityLookupState>
    availabilityLookupProvider =
    StateNotifierProvider<AvailabilityLookupNotifier, AvailabilityLookupState>((Ref ref) {
      final DateTime now = DateTime.now();
      return AvailabilityLookupNotifier(
        AvailabilityLookupState(
          selectedDate: DateTime(now.year, now.month, now.day),
          startTime: const TimeOfDay(hour: 9, minute: 0),
          endTime: const TimeOfDay(hour: 17, minute: 0),
          roleFilter: null,
          results: const <EmployeeAvailabilityResult>[],
          searched: false,
        ),
      );
    });

class EmployeeAvailabilityResult {
  const EmployeeAvailabilityResult({
    required this.employee,
    required this.hasConflict,
    this.conflictingEvent,
  });

  final Employee employee;
  final bool hasConflict;
  final Event? conflictingEvent;
}

class AvailabilityLookupState {
  const AvailabilityLookupState({
    required this.selectedDate,
    required this.startTime,
    required this.endTime,
    required this.roleFilter,
    required this.results,
    required this.searched,
  });

  final DateTime selectedDate;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final String? roleFilter;
  final List<EmployeeAvailabilityResult> results;
  final bool searched;

  AvailabilityLookupState copyWith({
    DateTime? selectedDate,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    String? roleFilter,
    bool clearRoleFilter = false,
    List<EmployeeAvailabilityResult>? results,
    bool? searched,
  }) {
    return AvailabilityLookupState(
      selectedDate: selectedDate ?? this.selectedDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      roleFilter: clearRoleFilter ? null : (roleFilter ?? this.roleFilter),
      results: results ?? this.results,
      searched: searched ?? this.searched,
    );
  }
}

class AvailabilityLookupNotifier extends StateNotifier<AvailabilityLookupState> {
  AvailabilityLookupNotifier(super.initialState);

  void setDate(DateTime date) {
    state = state.copyWith(selectedDate: DateTime(date.year, date.month, date.day));
  }

  void setStartTime(TimeOfDay time) {
    state = state.copyWith(startTime: time);
  }

  void setEndTime(TimeOfDay time) {
    state = state.copyWith(endTime: time);
  }

  void setRoleFilter(String? role) {
    final String? normalized = role == null || role.trim().isEmpty ? null : role.trim();
    state = state.copyWith(roleFilter: normalized);
  }

  void resetCriteria({
    required DateTime selectedDate,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
    String? roleFilter,
  }) {
    state = AvailabilityLookupState(
      selectedDate: DateTime(selectedDate.year, selectedDate.month, selectedDate.day),
      startTime: startTime,
      endTime: endTime,
      roleFilter: (roleFilter == null || roleFilter.trim().isEmpty) ? null : roleFilter.trim(),
      results: const <EmployeeAvailabilityResult>[],
      searched: false,
    );
  }

  void search({
    required List<Employee> employees,
    required List<RoleSlot> allSlots,
    required List<Event> allEvents,
    Event? targetEvent,
    String? excludeSlotId,
  }) {
    final Event lookupEvent = targetEvent ??
        Event(
          id: '__lookup__',
          title: 'Availability Lookup',
          date: state.selectedDate.toIso8601String(),
          startTime: _formatTime(state.startTime),
          endTime: _formatTime(state.endTime),
          venue: 'N/A',
          clientName: '',
          status: EventStatus.draft,
          internalNotes: '',
          exportNotes: '',
          createdAt: DateTime.now().toIso8601String(),
        );

    final String roleFilter = (state.roleFilter ?? '').toLowerCase();

    final List<EmployeeAvailabilityResult> results = employees
        .where((Employee e) => e.status == EmployeeStatus.active)
        .where((Employee e) => roleFilter.isEmpty || _matchesRole(e, roleFilter))
        .where(
          (Employee e) => _isAvailableOnDay(
            e,
            state.selectedDate,
            state.startTime,
            state.endTime,
          ),
        )
        .map((Employee e) {
          final Event? conflictingEvent = getConflictingEvent(
            e,
            lookupEvent,
            allSlots,
            allEvents,
            excludeSlotId: excludeSlotId,
          );
          return EmployeeAvailabilityResult(
            employee: e,
            hasConflict: conflictingEvent != null,
            conflictingEvent: conflictingEvent,
          );
        })
        .toList()
      ..sort(
        (EmployeeAvailabilityResult a, EmployeeAvailabilityResult b) =>
            b.employee.reliabilityScore.compareTo(a.employee.reliabilityScore),
      );

    state = state.copyWith(results: results, searched: true);
  }

  bool _matchesRole(Employee employee, String roleFilter) {
    for (final String role in employee.roles) {
      if (role.toLowerCase().contains(roleFilter)) {
        return true;
      }
    }
    return false;
  }

  bool _isAvailableOnDay(
    Employee employee,
    DateTime date,
    TimeOfDay start,
    TimeOfDay end,
  ) {
    final String weekdayKey = _weekdayKey(date.weekday);
    final String raw = employee.availability.trim();
    if (raw.isEmpty) {
      return false;
    }

    try {
      final Object? decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return false;
      }

      final dynamic dayValue = decoded[weekdayKey];
      if (dayValue is! List || dayValue.isEmpty) {
        return false;
      }

      final int startMinutes = start.hour * 60 + start.minute;
      final int endMinutes = end.hour * 60 + end.minute;

      for (final dynamic range in dayValue) {
        if (range is! Map<String, dynamic>) {
          continue;
        }
        final int rangeStart = _toMinutes(range['start']?.toString());
        final int rangeEnd = _toMinutes(range['end']?.toString());
        if (startMinutes < rangeEnd && rangeStart < endMinutes) {
          return true;
        }
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  String _weekdayKey(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'mon';
      case DateTime.tuesday:
        return 'tue';
      case DateTime.wednesday:
        return 'wed';
      case DateTime.thursday:
        return 'thu';
      case DateTime.friday:
        return 'fri';
      case DateTime.saturday:
        return 'sat';
      case DateTime.sunday:
        return 'sun';
    }
    return 'mon';
  }

  int _toMinutes(String? hhmm) {
    if (hhmm == null || !hhmm.contains(':')) {
      return 0;
    }
    final List<String> parts = hhmm.split(':');
    if (parts.length != 2) {
      return 0;
    }
    final int hour = int.tryParse(parts[0]) ?? 0;
    final int minute = int.tryParse(parts[1]) ?? 0;
    return hour * 60 + minute;
  }

  static String _formatTime(TimeOfDay value) {
    final String hh = value.hour.toString().padLeft(2, '0');
    final String mm = value.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }
}
