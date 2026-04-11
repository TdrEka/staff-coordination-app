import 'package:flutter/material.dart';
import 'package:staff_coordination_app/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme.dart';
import '../../models/enums.dart';
import '../../models/event.dart';
import '../../models/role_slot.dart';
import '../../providers/event_provider.dart';
import '../../repositories/role_slot_repository.dart';
import '../../widgets/empty_state_panel.dart';
import '../../widgets/status_chip.dart';

class EventListScreen extends ConsumerWidget {
  const EventListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final List<Event> events = ref.watch(eventsProvider);

    final DateTime today = DateTime.now();
    final DateTime dateOnlyToday = DateTime(today.year, today.month, today.day);

    final List<Event> upcoming = events.where((Event event) {
      final DateTime d = _safeDate(event.date);
      final DateTime day = DateTime(d.year, d.month, d.day);
      return day.compareTo(dateOnlyToday) >= 0;
    }).toList()
      ..sort((Event a, Event b) => _safeDate(a.date).compareTo(_safeDate(b.date)));

    final List<Event> past = events.where((Event event) {
      final DateTime d = _safeDate(event.date);
      final DateTime day = DateTime(d.year, d.month, d.day);
      return day.compareTo(dateOnlyToday) < 0;
    }).toList()
      ..sort((Event a, Event b) => _safeDate(b.date).compareTo(_safeDate(a.date)));

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.eventsTitle),
          bottom: TabBar(
            indicatorColor: AppTheme.primary,
            labelColor: AppTheme.primary,
            unselectedLabelColor: AppTheme.onSurfaceVariant,
            labelStyle: Theme.of(context).textTheme.labelLarge,
            tabs: <Tab>[
              Tab(text: l10n.eventsUpcoming),
              Tab(text: l10n.eventsPast),
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            _buildList(context, upcoming, emptyText: l10n.eventsEmpty),
            _buildList(context, past, emptyText: 'No hay eventos pasados'),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => context.go('/events/add'),
          backgroundColor: AppTheme.primary,
          foregroundColor: AppTheme.onPrimary,
          icon: const Icon(Icons.add),
          label: const Text('Añadir evento'),
        ),
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    List<Event> events, {
    required String emptyText,
  }) {
    if (events.isEmpty) {
      final AppLocalizations l10n = AppLocalizations.of(context)!;
      return EmptyStatePanel(
        title: emptyText,
        subtitle: 'Empieza creando un evento.',
        actionLabel: l10n.eventsAdd,
        icon: Icons.event_busy_outlined,
        onAction: () => context.go('/events/add'),
      );
    }

    final RoleSlotRepository roleSlotRepository = RoleSlotRepository();

    return ListView.builder(
      itemCount: events.length,
      itemBuilder: (BuildContext context, int index) {
        final Event event = events[index];
        final List<RoleSlot> slots = roleSlotRepository.getByEventId(event.id);
        final int confirmed = slots.where((RoleSlot s) => s.status == SlotStatus.confirmed).length;
        final int pending = slots.where((RoleSlot s) => s.status == SlotStatus.pending).length;
        final int uncovered = slots.where((RoleSlot s) => s.status == SlotStatus.uncovered).length;
        final bool hasCriticalUncovered = slots.any(
          (RoleSlot s) => s.status == SlotStatus.uncovered && s.priority == SlotPriority.critical,
        );

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 72),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => context.go('/events/${event.id}'),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 4,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      color: _statusColor(event.status),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  event.title,
                                  style: Theme.of(context).textTheme.titleMedium,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (hasCriticalUncovered)
                                const Padding(
                                  padding: EdgeInsets.only(left: 6),
                                  child: Icon(Icons.priority_high, size: 16, color: AppTheme.statusRed),
                                ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${_formatDate(event.date)} - ${event.venue}',
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(color: AppTheme.onSurfaceVariant),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Confirmados: $confirmed · Pendientes: $pending · Sin cubrir: $uncovered',
                            style: Theme.of(
                              context,
                            ).textTheme.labelSmall?.copyWith(color: AppTheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: StatusChip.event(eventStatus: event.status),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Color _statusColor(EventStatus status) {
    switch (status) {
      case EventStatus.draft:
        return AppTheme.statusGrey;
      case EventStatus.confirmed:
        return AppTheme.statusBlue;
      case EventStatus.completed:
        return AppTheme.statusGreen;
      case EventStatus.cancelled:
        return AppTheme.statusRed;
    }
  }

  static DateTime _safeDate(String value) {
    return DateTime.tryParse(value) ?? DateTime.fromMillisecondsSinceEpoch(0);
  }

  static String _formatDate(String value) {
    final DateTime d = _safeDate(value);
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }
}
