import 'package:flutter/material.dart';
import 'package:staff_coordination_app/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../core/theme.dart';
import '../../models/enums.dart';
import '../../models/event.dart';
import '../../models/role_slot.dart';
import '../../providers/event_provider.dart';
import '../../repositories/role_slot_repository.dart';
import '../../widgets/empty_state_panel.dart';
import '../../widgets/status_chip.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  final RoleSlotRepository _roleSlotRepository = RoleSlotRepository();

  @override
  Widget build(BuildContext context) {
    final List<Event> allEvents = ref.watch(eventsProvider);

    List<Event> eventsForDay(DateTime day) {
      final DateTime target = DateTime(day.year, day.month, day.day);
      return allEvents.where((Event event) {
        final DateTime eventDate = DateTime.tryParse(event.date) ?? DateTime.fromMillisecondsSinceEpoch(0);
        final DateTime eventDay = DateTime(eventDate.year, eventDate.month, eventDate.day);
        return eventDay == target;
      }).toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Calendario', style: Theme.of(context).textTheme.titleLarge),
        actions: <Widget>[
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search, color: AppTheme.primary),
          ),
        ],
      ),
      body: TableCalendar<Event>(
        firstDay: DateTime(2020, 1, 1),
        lastDay: DateTime(2035, 12, 31),
        focusedDay: _focusedDay,
        calendarFormat: CalendarFormat.month,
        selectedDayPredicate: (DateTime day) => isSameDay(day, _selectedDay),
        eventLoader: eventsForDay,
        onDaySelected: (DateTime selectedDay, DateTime focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });

          _showDayDetailBottomSheet(context, selectedDay);
        },
        onPageChanged: (DateTime focusedDay) {
          _focusedDay = focusedDay;
        },
        headerStyle: HeaderStyle(
          titleTextStyle: Theme.of(context).textTheme.titleMedium ?? const TextStyle(),
          formatButtonVisible: false,
          titleCentered: true,
          decoration: const BoxDecoration(),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle:
              Theme.of(context).textTheme.labelLarge?.copyWith(color: AppTheme.onSurfaceVariant) ??
              const TextStyle(color: AppTheme.onSurfaceVariant),
          weekendStyle:
              Theme.of(context).textTheme.labelLarge?.copyWith(color: AppTheme.onSurfaceVariant) ??
              const TextStyle(color: AppTheme.onSurfaceVariant),
        ),
        calendarStyle: CalendarStyle(
          defaultTextStyle:
              Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.onSurface) ??
              const TextStyle(color: AppTheme.onSurface),
          weekendTextStyle:
              Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.secondary) ??
              const TextStyle(color: AppTheme.secondary),
          selectedDecoration: BoxDecoration(
            color: AppTheme.primary,
            shape: BoxShape.circle,
          ),
          todayDecoration: BoxDecoration(
            color: AppTheme.primaryContainer,
            shape: BoxShape.circle,
          ),
          markerDecoration: const BoxDecoration(
            color: AppTheme.statusAmber,
            shape: BoxShape.circle,
          ),
        ),
        calendarBuilders: CalendarBuilders<Event>(
          markerBuilder: (BuildContext context, DateTime date, List<Event> events) {
            if (events.isEmpty) {
              return const SizedBox.shrink();
            }

            return Positioned(
              bottom: 4,
              child: Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(color: AppTheme.statusAmber, shape: BoxShape.circle),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showDayDetailBottomSheet(BuildContext rootContext, DateTime day) {
    showModalBottomSheet<void>(
      context: rootContext,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return DayDetailBottomSheet(
          date: day,
          roleSlotRepository: _roleSlotRepository,
        );
      },
    );
  }
}

class DayDetailBottomSheet extends ConsumerWidget {
  const DayDetailBottomSheet({
    super.key,
    required this.date,
    required this.roleSlotRepository,
  });

  final DateTime date;
  final RoleSlotRepository roleSlotRepository;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<Event> dayEvents = ref.watch(eventsByDateProvider(date));

    return SafeArea(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.65,
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      _formatDate(date),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: dayEvents.isEmpty
                  ? _emptyState(context)
                  : ListView.builder(
                      itemCount: dayEvents.length,
                      itemBuilder: (BuildContext context, int index) {
                        final Event event = dayEvents[index];
                        final List<RoleSlot> slots = roleSlotRepository.getByEventId(event.id);
                        final int confirmed =
                            slots.where((RoleSlot s) => s.status == SlotStatus.confirmed).length;
                        final int pending =
                            slots.where((RoleSlot s) => s.status == SlotStatus.pending).length;
                        final int uncovered =
                            slots.where((RoleSlot s) => s.status == SlotStatus.uncovered).length;

                        return ListTile(
                          title: Text(event.title),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text('${event.startTime} - ${event.endTime} | ${event.venue}'),
                              const SizedBox(height: 4),
                              Text('Confirmados: $confirmed / Pendientes: $pending / Sin cubrir: $uncovered'),
                            ],
                          ),
                          trailing: StatusChip.event(eventStatus: event.status),
                          onTap: () {
                            context.pop();
                            context.go('/events/${event.id}');
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState(BuildContext context) {
    final String isoDay = DateTime(date.year, date.month, date.day).toIso8601String();

    return EmptyStatePanel(
      title: AppLocalizations.of(context)!.calendarNoEvents,
      subtitle: 'No hay eventos para este día.',
      actionLabel: AppLocalizations.of(context)!.calendarAddEvent,
      icon: Icons.event_note_outlined,
      onAction: () {
        context.pop();
        context.go('/events/add?date=$isoDay');
      },
    );
  }

  static String _formatDate(DateTime value) {
    return '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
  }

}
