import 'package:flutter/material.dart';
import 'package:staff_coordination_app/l10n/app_localizations.dart';

import '../core/utils/localization_utils.dart';
import '../models/enums.dart';
import '../core/theme.dart';

class StatusChip extends StatelessWidget {
  const StatusChip.slot({
    super.key,
    required this.slotStatus,
  })  : eventStatus = null,
        label = null,
        color = null;

  const StatusChip.event({
    super.key,
    required this.eventStatus,
  })  : slotStatus = null,
        label = null,
        color = null;

  const StatusChip.custom({
    super.key,
    required this.label,
    required this.color,
  })  : slotStatus = null,
        eventStatus = null;

  const StatusChip({
    super.key,
    this.label,
    this.color,
    this.slotStatus,
    this.eventStatus,
  });

  final String? label;
  final Color? color;
  final SlotStatus? slotStatus;
  final EventStatus? eventStatus;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    assert(
      (label != null && color != null) || slotStatus != null || eventStatus != null,
      'StatusChip requires slotStatus, eventStatus, or custom label/color.',
    );
    final String resolvedLabel = label ??
        (slotStatus != null
            ? slotStatusLabel(l10n, slotStatus!)
            : eventStatusLabel(l10n, eventStatus!));
    final Color resolvedColor = color ??
        (slotStatus != null
            ? _slotColor(slotStatus!)
            : _eventColor(eventStatus!));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: ShapeDecoration(
        color: resolvedColor.withValues(alpha: 0.15),
        shape: const StadiumBorder(),
      ),
      child: Text(
        resolvedLabel,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: resolvedColor,
            ),
      ),
    );
  }

  Color _slotColor(SlotStatus status) {
    switch (status) {
      case SlotStatus.confirmed:
        return AppTheme.statusGreen;
      case SlotStatus.pending:
        return AppTheme.statusAmber;
      case SlotStatus.uncovered:
        return AppTheme.statusRed;
    }
  }

  Color _eventColor(EventStatus status) {
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
}
