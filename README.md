# Staff Coordination App

A Flutter app for managing event staffing — built for a real hospitality business operating in Spain.

---

## What it does

- **Employee management** — add staff with roles, availability, contact details, and contract type. Track reliability with an auto-calculated score that updates based on shift history.
- **Event management** — create events with full venue details, dress code, call times, and client info. Attach role slots and assign staff with conflict detection.
- **Assignment flow** — tap any uncovered slot → see who's available and conflict-free → assign in two taps.
- **Calendar view** — monthly overview with per-day event badges colour-coded by slot coverage status.
- **Shift logging** — post-event logging flow that records outcomes (showed up / late / no-show / cancelled) and adjusts reliability scores accordingly.
- **PDF roster export** — shareable A4 roster with role table, venue info, and client contact. Shared via system share sheet.
- **Backup & restore** — full JSON export/import via system share sheet. 30-day backup reminder built in.
- **Local notifications** — optional 48h reminders before events with uncovered slots.

---

## Tech stack

| Concern | Choice |
|---|---|
| Framework | Flutter (Dart) |
| Local storage | Hive |
| State management | Riverpod |
| Navigation | go_router |
| PDF export | `pdf` + `printing` |
| File sharing | `share_plus` |
| Notifications | `flutter_local_notifications` |
| Fonts | Google Fonts — Nunito |

**Fully offline. No backend. No login. No cloud.**

---

## Design

Dark mode only. Warm earthy palette — deep brown backgrounds, gold accents, terracotta secondary tones. Rounded Material 3 components throughout. Built for non-technical users: large tap targets, colour-coded status chips everywhere, three-tap maximum to assign a staff member.

---

## Project structure

```
lib/
├── core/
│   ├── theme.dart
│   ├── router.dart
│   ├── hive_boxes.dart
│   └── utils/
│       ├── conflict_checker.dart
│       ├── score_calculator.dart
│       ├── notification_scheduler.dart
│       └── pdf_exporter.dart
├── models/          # Hive models + generated adapters
├── repositories/    # Hive box wrappers
├── providers/       # Riverpod state
├── screens/         # One folder per feature
├── widgets/         # Shared components
└── l10n/            # Spanish ARB strings
```

---

## Localisation

Spanish only (`es`). Device locale is ignored — the app always runs in Spanish. All UI strings go through `AppLocalizations`. PDF exports are hardcoded in Spanish directly in `pdf_exporter.dart` (no BuildContext available there).

---

## Reliability score

Each employee starts at 5.0 (range 0.0–10.0). Score is nudged after each logged shift:

| Outcome | Delta |
|---|---|
| Showed up | +0.1 |
| Late < 15 min | −0.1 |
| Late ≥ 15 min | −0.3 |
| Cancelled with 48h+ notice | 0 |
| Cancelled with < 48h notice | −0.5 |
| No-show | −1.5 |

Manual override is available with a required reason note. Score is colour-coded throughout the app: green ≥ 7, amber 4–7, red < 4.

---

## Backup format

```json
{
  "version": 2,
  "exportedAt": "2026-04-12T14:27:13.706841",
  "employees": [...],
  "events": [...],
  "roleSlots": [...],
  "shiftLogs": [...],
  "clients": [...]
}
```

Export filename: `staffing_backup_YYYY-MM-DD.json`

Import validates structure fully before touching any stored data. The clear + write sequence is wrapped in a try/catch — if import fails mid-write, the user is informed and told to re-import.

---

## Build

```bash
# Debug (emulator or connected device)
flutter run

# Release APK (sideload)
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

> **Note:** Release builds currently use debug signing. Suitable for sideloading only — not Play Store distribution.

---

## Android permissions

| Permission | Reason |
|---|---|
| `POST_NOTIFICATIONS` | Showing event reminders (Android 13+) |
| `SCHEDULE_EXACT_ALARM` | Exact 48h reminder scheduling (Android 12+) |

No internet permission. The app is entirely offline.

---

## Known limitations

- Single-device only — no sync between devices. Use the backup/restore feature to move data.
- No biometric or encryption on stored data. Suitable for a personal device with screen lock.
- `com.example` app ID — change before any Play Store submission.