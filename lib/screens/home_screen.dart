import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../core/theme.dart';
import '../widgets/section_header.dart';
import '../widgets/status_chip.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const List<_StubEvent> _todayEvents = <_StubEvent>[
    _StubEvent('Boda Rivera', '15:00 - 23:00', 6, 2, 1),
    _StubEvent('Cena corporativa', '19:30 - 01:00', 4, 1, 0),
  ];

  static const List<_StubWeekEvent> _weekEvents = <_StubWeekEvent>[
    _StubWeekEvent('Mar 14', 'Conferencia Atlas', '10:00', 'Hotel Central'),
    _StubWeekEvent('Mie 15', 'Gala nocturna', '20:00', 'Finca Aurora'),
    _StubWeekEvent('Vie 17', 'Evento privado', '18:30', 'Casa del Lago'),
  ];

  @override
  Widget build(BuildContext context) {
    final String todayLabel = DateFormat('EEEE d MMMM', 'es').format(DateTime.now());

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.xl, AppSpacing.md, AppSpacing.lg),
        children: <Widget>[
          Text('Hola ðŸ‘‹', style: Theme.of(context).textTheme.displayLarge),
          const SizedBox(height: AppSpacing.xs),
          Text(
            todayLabel,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppTheme.onSurfaceVariant),
          ),
          const SizedBox(height: AppSpacing.lg),
          const SectionHeader(title: 'Acciones rapidas'),
          Row(
            children: <Widget>[
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => context.go('/events/add'),
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('Anadir evento'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => context.go('/availability'),
                  icon: const Icon(Icons.person_search_outlined),
                  label: const Text('Buscar personal'),
                ),
              ),
            ],
          ),
          const SectionHeader(title: 'Eventos de hoy'),
          if (_todayEvents.isEmpty)
            const _WarmEmptyCard(
              title: 'No hay eventos para hoy',
              subtitle: 'Todo esta tranquilo por ahora.',
              icon: Icons.event_outlined,
            )
          else
            SizedBox(
              height: 176,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _todayEvents.length,
                separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
                itemBuilder: (BuildContext context, int index) {
                  return _EventSummaryCard(event: _todayEvents[index]);
                },
              ),
            ),
          const SectionHeader(title: 'Esta semana', actionLabel: 'Ver todo'),
          ..._weekEvents.map(
            (_StubWeekEvent event) => Card(
              child: ListTile(
                minVerticalPadding: 10,
                title: Text(event.title),
                subtitle: Text(
                  '${event.dayLabel} Â· ${event.time} Â· ${event.venue}',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: AppTheme.onSurfaceVariant),
                ),
                trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.onSurfaceVariant),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EventSummaryCard extends StatelessWidget {
  const _EventSummaryCard({required this.event});

  final _StubEvent event;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                event.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                event.time,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppTheme.onSurfaceVariant),
              ),
              const Spacer(),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: <Widget>[
                  StatusChip(label: '${event.confirmed} confirmados', color: AppTheme.statusGreen),
                  StatusChip(label: '${event.pending} pendientes', color: AppTheme.statusAmber),
                  StatusChip(label: '${event.uncovered} sin cubrir', color: AppTheme.statusRed),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WarmEmptyCard extends StatelessWidget {
  const _WarmEmptyCard({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedCardPainter(
        color: AppTheme.outline,
        radius: 16,
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 34, color: AppTheme.secondary),
            const SizedBox(height: AppSpacing.sm),
            Text(title, style: Theme.of(context).textTheme.titleMedium, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.xs),
            Text(
              subtitle,
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
}

class _DashedCardPainter extends CustomPainter {
  const _DashedCardPainter({
    required this.color,
    required this.radius,
  });

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final RRect rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );

    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    const double dash = 6;
    const double gap = 4;
    final Path source = Path()..addRRect(rrect);

    for (final metric in source.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final double next = (distance + dash).clamp(0, metric.length);
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedCardPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.radius != radius;
  }
}

class _StubEvent {
  const _StubEvent(this.title, this.time, this.confirmed, this.pending, this.uncovered);

  final String title;
  final String time;
  final int confirmed;
  final int pending;
  final int uncovered;
}

class _StubWeekEvent {
  const _StubWeekEvent(this.dayLabel, this.title, this.time, this.venue);

  final String dayLabel;
  final String title;
  final String time;
  final String venue;
}

