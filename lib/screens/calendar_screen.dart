import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';

import '../core/theme.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendario'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Buscar personal',
            onPressed: () => context.go('/availability'),
            icon: const Icon(Icons.search, color: AppTheme.primary),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: <Widget>[
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: TableCalendar<void>(
                  firstDay: DateTime(2022, 1, 1),
                  lastDay: DateTime(2032, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (DateTime day) => isSameDay(day, _selectedDay),
                  onDaySelected: (DateTime selectedDay, DateTime focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  headerStyle: HeaderStyle(
                    titleTextStyle: Theme.of(context).textTheme.titleMedium!,
                    formatButtonVisible: false,
                    leftChevronIcon: const Icon(Icons.chevron_left, color: AppTheme.primary),
                    rightChevronIcon: const Icon(Icons.chevron_right, color: AppTheme.primary),
                    titleCentered: true,
                  ),
                  daysOfWeekStyle: DaysOfWeekStyle(
                    weekdayStyle: Theme.of(context)
                            .textTheme
                            .labelLarge
                            ?.copyWith(color: AppTheme.onSurfaceVariant) ??
                        const TextStyle(),
                    weekendStyle: Theme.of(context)
                            .textTheme
                            .labelLarge
                            ?.copyWith(color: AppTheme.onSurfaceVariant) ??
                        const TextStyle(),
                  ),
                  calendarStyle: CalendarStyle(
                    defaultTextStyle: Theme.of(context).textTheme.bodyMedium!,
                    weekendTextStyle: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: AppTheme.secondary) ??
                        const TextStyle(),
                    selectedDecoration: const BoxDecoration(
                      color: AppTheme.primary,
                      shape: BoxShape.circle,
                    ),
                    todayDecoration: const BoxDecoration(
                      color: AppTheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    markerDecoration: const BoxDecoration(
                      color: AppTheme.statusAmber,
                      shape: BoxShape.circle,
                    ),
                    markersMaxCount: 1,
                    markerSize: 6,
                    outsideTextStyle: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: AppTheme.onSurfaceVariant) ??
                        const TextStyle(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    _selectedDay == null
                        ? 'Toca un dia para ver sus eventos'
                        : 'Sin eventos para ${_selectedDay!.day}/${_selectedDay!.month}',
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(color: AppTheme.onSurfaceVariant),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

