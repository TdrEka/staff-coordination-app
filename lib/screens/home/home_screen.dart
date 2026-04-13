import 'package:flutter/material.dart';
import 'package:staff_coordination_app/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/theme.dart';
import '../../models/enums.dart';
import '../../models/event.dart';
import '../../models/role_slot.dart';
import '../../providers/dashboard_provider.dart';
import '../../repositories/role_slot_repository.dart';
import '../../widgets/empty_state_panel.dart';
import '../../widgets/section_header.dart';
import '../../widgets/status_chip.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _backupBannerDismissed = false;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final String todayLabel = DateFormat("EEEE, d 'de' MMMM", 'es').format(DateTime.now());
    final WidgetRef ref = this.ref;
    final List<Event> todayEvents = ref.watch(todaysEventsProvider);
    final List<Event> weekEvents = ref.watch(thisWeekEventsProvider);
    final List<Event> overdueShiftLogs = ref.watch(overdueShiftLogEventsProvider);
    final bool showBackupReminder = ref.watch(backupReminderDueProvider) && !_backupBannerDismissed;
    final RoleSlotRepository roleSlotRepository = RoleSlotRepository();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Hola 👋',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(color: AppTheme.onSurface),
              ),
              const SizedBox(height: 4),
              Text(
                todayLabel,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppTheme.onSurfaceVariant),
              ),
              if (showBackupReminder) ...<Widget>[
                const SizedBox(height: 16),
                Dismissible(
                  key: const ValueKey<String>('backup-reminder-banner'),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) {
                    setState(() {
                      _backupBannerDismissed = true;
                    });
                  },
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.close),
                  ),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: <Widget>[
                        const Icon(Icons.save_outlined, size: 18),
                        const SizedBox(width: 10),
                        Expanded(child: Text(l10n.homeBackupReminder)),
                        TextButton(
                          onPressed: () => context.go('/settings'),
                          child: Text(l10n.navSettings),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const SectionHeader(title: 'Acciones rápidas'),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => context.go('/events/add'),
                      icon: const Icon(Icons.add, size: 18),
                      label: Text(
                        l10n.homeAddEvent,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => context.go('/availability'),
                      icon: const Icon(Icons.person_search, size: 18),
                      label: Text(
                        l10n.homeFindStaff,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
              SectionHeader(
                title: l10n.homeTodayEvents,
                actionLabel: l10n.seeAll,
                onAction: () => context.go('/events'),
              ),
              if (todayEvents.isEmpty)
                EmptyStatePanel(
                  title: l10n.homeNoEventsToday,
                  subtitle: 'No hay eventos programados para hoy.',
                  actionLabel: l10n.homeAddEvent,
                  icon: Icons.event_available_outlined,
                  onAction: () => context.go('/events/add'),
                )
              else
                SizedBox(
                  height: 160,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: todayEvents.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (BuildContext context, int index) {
                      final Event event = todayEvents[index];
                      final _SlotSummary summary = _slotSummary(roleSlotRepository.getByEventId(event.id));
                      return _TodayEventCard(
                        event: event,
                        summary: summary,
                        onTap: () => context.go('/events/${event.id}'),
                      );
                    },
                  ),
                ),
              SectionHeader(
                title: l10n.homeThisWeek,
                actionLabel: l10n.navCalendar,
                onAction: () => context.go('/calendar'),
              ),
              if (weekEvents.isEmpty)
                EmptyStatePanel(
                  title: 'No hay eventos esta semana',
                  subtitle: 'Añade un evento para completar la agenda semanal.',
                  actionLabel: l10n.homeAddEvent,
                  icon: Icons.calendar_today_outlined,
                  onAction: () => context.go('/events/add'),
                )
              else
                _WeekGroupedList(
                  events: weekEvents,
                  roleSlotRepository: roleSlotRepository,
                ),
              SectionHeader(title: l10n.homeOverdueShiftLogs),
              if (overdueShiftLogs.isEmpty)
                EmptyStatePanel(
                  title: 'Todo al día',
                  subtitle: 'No hay registros de turno pendientes.',
                  actionLabel: l10n.eventsTitle,
                  icon: Icons.task_alt_outlined,
                  onAction: () => context.go('/events'),
                )
              else
                ...overdueShiftLogs.map(
                  (Event event) => Card(
                    child: ListTile(
                      title: Text(event.title),
                      subtitle: Text('${_formatDate(_safeDate(event.date))} - ${event.venue}'),
                      trailing: FilledButton(
                        onPressed: () => context.go('/events/${event.id}/shift-logs'),
                        child: Text(l10n.homeLogShifts),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  static _SlotSummary _slotSummary(List<RoleSlot> slots) {
    int confirmed = 0;
    int pending = 0;
    int uncovered = 0;

    for (final RoleSlot slot in slots) {
      if (slot.status == SlotStatus.confirmed) {
        confirmed += 1;
      } else if (slot.status == SlotStatus.pending) {
        pending += 1;
      } else {
        uncovered += 1;
      }
    }
    return _SlotSummary(confirmed: confirmed, pending: pending, uncovered: uncovered);
  }
}

class _WeekGroupedList extends StatelessWidget {
  const _WeekGroupedList({required this.events, required this.roleSlotRepository});

  final List<Event> events;
  final RoleSlotRepository roleSlotRepository;

  @override
  Widget build(BuildContext context) {
    final Map<String, List<Event>> grouped = <String, List<Event>>{};
    for (final Event event in events) {
      final String key = _formatDate(_safeDate(event.date));
      grouped.putIfAbsent(key, () => <Event>[]).add(event);
    }

    return Column(
      children: grouped.entries.map((MapEntry<String, List<Event>> entry) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    entry.key,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  ...entry.value.map((Event event) {
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      minVerticalPadding: 10,
                      onTap: () => context.go('/events/${event.id}'),
                      title: Text(event.title),
                      subtitle: Text('${event.startTime} - ${event.endTime} | ${event.venue}'),
                      trailing: StatusChip.event(eventStatus: event.status),
                    );
                  }),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _TodayEventCard extends StatelessWidget {
  const _TodayEventCard({
    required this.event,
    required this.summary,
    required this.onTap,
  });

  final Event event;
  final _SlotSummary summary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
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
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(width: 6),
                    StatusChip.event(eventStatus: event.status),
                  ],
                ),
                const SizedBox(height: 8),
                Text('${event.startTime} - ${event.endTime}'),
                const SizedBox(height: 4),
                Text(
                  event.venue,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.onSurfaceVariant),
                ),
                const Spacer(),
                Row(
                  children: <Widget>[
                    _SlotDot(color: AppTheme.statusGreen, count: summary.confirmed),
                    const SizedBox(width: 6),
                    _SlotDot(color: AppTheme.statusAmber, count: summary.pending),
                    const SizedBox(width: 6),
                    _SlotDot(color: AppTheme.statusRed, count: summary.uncovered),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SlotDot extends StatelessWidget {
  const _SlotDot({required this.color, required this.count});

  final Color color;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          '$count',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppTheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _SlotSummary {
  const _SlotSummary({
    required this.confirmed,
    required this.pending,
    required this.uncovered,
  });

  final int confirmed;
  final int pending;
  final int uncovered;
}

DateTime _safeDate(String value) {
  return DateTime.tryParse(value) ?? DateTime.fromMillisecondsSinceEpoch(0);
}

String _formatDate(DateTime value) {
  return '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
}
