import 'package:flutter/material.dart';

import '../theme.dart';
import '../../models/enums.dart';
import '../../models/role_slot.dart';

class AppColors {
  const AppColors._();

  static Color slotStatus(SlotStatus status) {
    switch (status) {
      case SlotStatus.confirmed:
        return AppTheme.statusGreen;
      case SlotStatus.pending:
        return AppTheme.statusAmber;
      case SlotStatus.uncovered:
        return AppTheme.statusRed;
    }
  }

  static Color eventStatus(EventStatus status) {
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

  static Color reliability(double score) {
    if (score >= 7) {
      return AppTheme.statusGreen;
    }
    if (score >= 4) {
      return AppTheme.statusAmber;
    }
    return AppTheme.statusRed;
  }

  static Color calendarDayDot(List<RoleSlot> slots) {
    if (slots.isEmpty) {
      return AppTheme.statusGreen;
    }

    final bool hasCriticalUncovered = slots.any(
      (RoleSlot slot) => slot.priority == SlotPriority.critical && slot.status == SlotStatus.uncovered,
    );
    if (hasCriticalUncovered) {
      return AppTheme.statusRed;
    }

    final bool hasPending = slots.any((RoleSlot slot) => slot.status == SlotStatus.pending);
    if (hasPending) {
      return AppTheme.statusAmber;
    }

    final bool allConfirmed = slots.every((RoleSlot slot) => slot.status == SlotStatus.confirmed);
    return allConfirmed ? AppTheme.statusGreen : AppTheme.statusAmber;
  }
}

