import 'package:flutter/widgets.dart';
import 'package:staff_coordination_app/l10n/app_localizations.dart';

import '../../models/enums.dart';

AppLocalizations tr(BuildContext context) => AppLocalizations.of(context)!;

String eventStatusLabel(AppLocalizations l10n, EventStatus status) {
  switch (status) {
    case EventStatus.draft:
      return l10n.eventsStatusDraft;
    case EventStatus.confirmed:
      return l10n.eventsStatusConfirmed;
    case EventStatus.completed:
      return l10n.eventsStatusCompleted;
    case EventStatus.cancelled:
      return l10n.eventsStatusCancelled;
  }
}

String slotStatusLabel(AppLocalizations l10n, SlotStatus status) {
  switch (status) {
    case SlotStatus.uncovered:
      return l10n.slotStatusUncovered;
    case SlotStatus.pending:
      return l10n.slotStatusPending;
    case SlotStatus.confirmed:
      return l10n.slotStatusConfirmed;
  }
}

String slotPriorityLabel(AppLocalizations l10n, SlotPriority priority) {
  switch (priority) {
    case SlotPriority.critical:
      return l10n.slotPriorityCritical;
    case SlotPriority.normal:
      return l10n.slotPriorityNormal;
  }
}

String preferredContactLabel(AppLocalizations l10n, PreferredContact contact) {
  switch (contact) {
    case PreferredContact.phone:
      return 'Teléfono';
    case PreferredContact.whatsapp:
      return 'WhatsApp';
    case PreferredContact.email:
      return 'Email';
  }
}

String contractTypeLabel(AppLocalizations l10n, ContractType contract) {
  switch (contract) {
    case ContractType.freelance:
      return l10n.employeesContractFreelance;
    case ContractType.staff:
      return l10n.employeesContractStaff;
    case ContractType.agency:
      return l10n.employeesContractAgency;
  }
}

String employeeStatusLabel(AppLocalizations l10n, EmployeeStatus status) {
  switch (status) {
    case EmployeeStatus.active:
      return l10n.employeesStatusActive;
    case EmployeeStatus.inactive:
      return l10n.employeesStatusInactive;
  }
}

String dayLabel(AppLocalizations l10n, String key) {
  switch (key) {
    case 'mon':
      return l10n.monday;
    case 'tue':
      return l10n.tuesday;
    case 'wed':
      return l10n.wednesday;
    case 'thu':
      return l10n.thursday;
    case 'fri':
      return l10n.friday;
    case 'sat':
      return l10n.saturday;
    case 'sun':
      return l10n.sunday;
    default:
      return key;
  }
}

String shiftOutcomeLabel(AppLocalizations l10n, ShiftOutcome outcome) {
  switch (outcome) {
    case ShiftOutcome.showed_up:
      return l10n.shiftLogOutcomeShowedUp;
    case ShiftOutcome.late:
      return l10n.shiftLogOutcomeLate;
    case ShiftOutcome.no_show:
      return l10n.shiftLogOutcomeNoShow;
    case ShiftOutcome.cancelled_advance:
      return l10n.shiftLogOutcomeCancelledAdvance;
    case ShiftOutcome.manual_override:
      return l10n.employeesAdjustScore;
  }
}
