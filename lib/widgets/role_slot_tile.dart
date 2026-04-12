import 'package:flutter/material.dart';
import 'package:staff_coordination_app/l10n/app_localizations.dart';

import '../core/ui/app_colors.dart';
import '../core/theme.dart';
import '../models/enums.dart';
import '../models/role_slot.dart';
import 'status_chip.dart';

class RoleSlotTile extends StatelessWidget {
  const RoleSlotTile({
    super.key,
    required this.slot,
    required this.assignedEmployeeName,
    this.onAssign,
    this.onConfirm,
    this.onTap,
    this.onLongPress,
  });

  final RoleSlot slot;
  final String assignedEmployeeName;
  final VoidCallback? onAssign;
  final VoidCallback? onConfirm;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final Color statusColor = AppColors.slotStatus(slot.status);
    final bool criticalUncovered =
        slot.priority == SlotPriority.critical && slot.status == SlotStatus.uncovered;

    Widget card = Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      color: AppTheme.surfaceVariant,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(color: statusColor, width: 3),
            ),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 72),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          slot.roleType,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          assignedEmployeeName.trim().isEmpty ? 'Sin asignar' : assignedEmployeeName,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppTheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      StatusChip.slot(slotStatus: slot.status),
                      const SizedBox(height: 8),
                      if (slot.status == SlotStatus.pending &&
                          slot.assignedEmployeeId != null &&
                          slot.assignedEmployeeId!.isNotEmpty)
                        FilledButton.tonalIcon(
                          onPressed: onConfirm,
                          icon: const Icon(Icons.check_circle_outline, size: 18),
                          label: Text(l10n.slotConfirm),
                        )
                      else
                        OutlinedButton.icon(
                          onPressed: onAssign,
                          icon: const Icon(Icons.person_add_alt_1, size: 18),
                          label: Text(l10n.slotAssign),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if (criticalUncovered) {
      card = Container(
        decoration: BoxDecoration(
          color: AppTheme.error.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: card,
      );
    }

    return card;
  }
}
