import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../widgets/status_chip.dart';

class EventListScreen extends StatelessWidget {
  const EventListScreen({super.key});

  static const List<_EventRow> _upcoming = <_EventRow>[
    _EventRow('Boda Rivera', '2026-04-18', 'Finca Aurora', 'confirmado', AppTheme.statusBlue, 6, 2, 1),
    _EventRow('Cena de marca', '2026-04-22', 'Hotel Central', 'borrador', AppTheme.statusGrey, 3, 1, 2),
  ];

  static const List<_EventRow> _past = <_EventRow>[
    _EventRow('Evento privado', '2026-04-02', 'Casa del Lago', 'completado', AppTheme.statusGreen, 5, 0, 0),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Eventos', style: Theme.of(context).textTheme.titleLarge),
          bottom: TabBar(
            indicatorColor: AppTheme.primary,
            labelStyle: Theme.of(context).textTheme.labelLarge,
            unselectedLabelColor: AppTheme.onSurfaceVariant,
            tabs: const <Tab>[
              Tab(text: 'Proximos'),
              Tab(text: 'Pasados'),
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            _EventTab(events: _upcoming),
            _EventTab(events: _past),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {},
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: AppTheme.primary,
          foregroundColor: AppTheme.onPrimary,
          label: const Text('+ Anadir evento'),
        ),
      ),
    );
  }
}

class _EventTab extends StatelessWidget {
  const _EventTab({required this.events});

  final List<_EventRow> events;

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(Icons.event_outlined, size: 56, color: AppTheme.secondary),
              const SizedBox(height: AppSpacing.sm),
              Text('No hay eventos', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Pulsa + Anadir evento para crear el primero.',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppTheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: AppSpacing.sm, bottom: 88),
      itemCount: events.length,
      itemBuilder: (BuildContext context, int index) {
        final _EventRow event = events[index];
        return Card(
          child: SizedBox(
            height: 82,
            child: Row(
              children: <Widget>[
                Container(
                  width: 6,
                  decoration: BoxDecoration(
                    color: event.statusColor,
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
                      children: <Widget>[
                        Text(event.title, style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 4),
                        Text(
                          '${event.date} Â· ${event.venue}',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: AppTheme.onSurfaceVariant),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          children: <Widget>[
                            StatusChip(label: '${event.confirmed} conf', color: AppTheme.statusGreen),
                            StatusChip(label: '${event.pending} pend', color: AppTheme.statusAmber),
                            StatusChip(label: '${event.uncovered} sin cubrir', color: AppTheme.statusRed),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: StatusChip(label: event.statusText, color: event.statusColor),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _EventRow {
  const _EventRow(
    this.title,
    this.date,
    this.venue,
    this.statusText,
    this.statusColor,
    this.confirmed,
    this.pending,
    this.uncovered,
  );

  final String title;
  final String date;
  final String venue;
  final String statusText;
  final Color statusColor;
  final int confirmed;
  final int pending;
  final int uncovered;
}

