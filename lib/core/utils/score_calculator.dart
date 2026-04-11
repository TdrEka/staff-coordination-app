import '../../models/enums.dart';

double computeScoreDelta(
  ShiftOutcome outcome,
  int? minutesLate, {
  bool advanceNotice = false,
}) {
  switch (outcome) {
    case ShiftOutcome.showed_up:
      return 0.1;
    case ShiftOutcome.late:
      if ((minutesLate ?? 0) < 15) {
        return -0.1;
      }
      return -0.3;
    case ShiftOutcome.cancelled_advance:
      return advanceNotice ? 0.0 : -0.5;
    case ShiftOutcome.no_show:
      return -1.5;
    case ShiftOutcome.manual_override:
      return 0.0;
  }
}

double applyDelta(double currentScore, double delta) {
  final double next = currentScore + delta;
  final double clamped = next.clamp(0.0, 10.0);
  return double.parse(clamped.toStringAsFixed(1));
}
