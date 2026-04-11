# Staffing App — Full Development Roadmap

---

## Data Models

### Employee
| Field | Type | Notes |
|---|---|---|
| `id` | UUID | Auto-generated |
| `name` | String | Full name |
| `age` | int | Optional |
| `phone` | String | Primary contact |
| `email` | String | Optional |
| `location` | String | City/area — used for proximity filtering |
| `preferredContact` | Enum | `phone` / `whatsapp` / `email` |
| `languages` | List\<String\> | Useful for multilingual events |
| `availability` | Map\<Weekday, List\<TimeRange\>\> | Mon–Sun, multiple time windows allowed per day |
| `reliabilityScore` | double (0–10) | Manually editable; auto-nudged by ShiftLog history |
| `roles` | List\<String\> | e.g. `["waiter", "bartender", "coordinator"]` |
| `contractType` | Enum | `freelance` / `staff` / `agency` |
| `hourlyRate` | double? | Optional, for reference — no payroll calculated |
| `status` | Enum | `active` / `inactive` (soft delete) |
| `notes` | String | Freeform |
| `emergencyContact` | String? | Name + phone, single field |
| `createdAt` | DateTime | For record-keeping |
| `documents` | List\<String\>? | File paths or notes (e.g. "Contract signed 2024") |

---

### Event
| Field | Type | Notes |
|---|---|---|
| `id` | UUID | Auto-generated |
| `title` | String | Event name |
| `date` | DateTime | Date of event |
| `startTime` | TimeOfDay | |
| `endTime` | TimeOfDay | |
| `callTime` | TimeOfDay? | When staff should arrive (often before startTime) |
| `venue` | String | Location name |
| `address` | String? | Full address — tappable to open Maps |
| `parkingNotes` | String? | Useful for staff |
| `accessNotes` | String? | Entry instructions, gate codes, etc. |
| `clientId` | UUID? | Links to a Client record |
| `clientName` | String | Denormalised for easy display if no Client record |
| `clientContact` | String? | Phone/WhatsApp of client contact on the day |
| `eventType` | String? | e.g. `wedding`, `corporate`, `private dinner` |
| `dresscode` | String? | e.g. `black tie`, `smart casual` |
| `status` | Enum | `draft` / `confirmed` / `completed` / `cancelled` |
| `roles` | List\<RoleSlot\> | The staffing slots for this event |
| `internalNotes` | String | Visible only in the app, not on exports |
| `exportNotes` | String | Printed on the PDF roster |
| `payRate` | double? | Reference flat rate for the event (optional) |
| `createdAt` | DateTime | |

---

### RoleSlot
| Field | Type | Notes |
|---|---|---|
| `id` | UUID | |
| `roleType` | String | e.g. `Head Waiter`, `Bartender`, `Chef` |
| `assignedEmployeeId` | UUID? | Nullable until filled |
| `status` | Enum | `confirmed` / `pending` / `uncovered` |
| `priority` | Enum | `critical` / `normal` — critical slots shown first, flagged louder |
| `callTime` | TimeOfDay? | Override per slot if different from event call time |
| `notes` | String? | Slot-specific instructions |

---

### Client *(new)*
| Field | Type | Notes |
|---|---|---|
| `id` | UUID | |
| `name` | String | Company or person name |
| `phone` | String | |
| `email` | String? | |
| `notes` | String? | Preferences, past event history notes |
| `eventIds` | List\<UUID\> | History of events |

---

### ShiftLog *(new — feeds reliability score)*
| Field | Type | Notes |
|---|---|---|
| `id` | UUID | |
| `employeeId` | UUID | |
| `eventId` | UUID | |
| `outcome` | Enum | `showed_up` / `late` / `no_show` / `cancelled_advance` |
| `minutesLate` | int? | If `late` |
| `notes` | String? | e.g. "Called in sick same morning" |
| `scoreDelta` | double | Applied to reliabilityScore (+/−) |
| `loggedAt` | DateTime | |

**Reliability score nudge logic (suggested):**
- `showed_up` → +0.1 (capped at 10)
- `late` (< 15 min) → −0.1
- `late` (> 15 min) → −0.3
- `cancelled_advance` (48h+) → 0 (neutral — professional)
- `cancelled_advance` (< 48h) → −0.5
- `no_show` → −1.5

---

## Feature Set by Phase

---

### Phase 1 — Core MVP

**Employee Management**
- Employee list screen — sortable by name, role, reliability
- Add/Edit employee form — all fields, with validation
- Employee profile card — at-a-glance view: roles, score, contact, availability summary
- Soft-delete with inactive archive (filtered out of scheduling, kept in records)
- Quick contact bar — tap to call, tap to WhatsApp (via `url_launcher`)

**Event Management**
- Event list screen — sorted by date, with status chip per event
- Add/Edit event form — all fields
- Event detail screen — role slots with assignment status, color-coded
- Role slot management — add/remove slots, set role type, mark priority

**Assignment Flow**
- From any uncovered role slot → one-tap to open "Who's available?" sheet
- Sheet shows filtered list: employees with matching role, no conflict that day
- One-tap to assign → slot status updates to `pending`
- Mark slot as `confirmed` once employee verbally confirms

**Persistence**
- `hive` for all data — fast, no SQL, works offline entirely
- All data lives on-device
- No login, no backend, no network required

**UI Principles**
- Minimum 48dp tap targets throughout
- Color chips on every list row: green = confirmed, amber = pending, red = uncovered
- Consistent card-based layout matching existing task app
- Large readable font defaults (16–18pt body)

---

### Phase 2 — Scheduling Intelligence

**Calendar View**
- Monthly overview via `table_calendar` — each day with event count badge
- Day detail view — all events that day, slot summary per event
- Tap event from calendar → goes to Event Detail

**Conflict Detection**
- On assignment: check if employee already has a confirmed/pending slot on same date with overlapping times
- Warn with a dismissible dialog — don't hard-block (manager may override)
- Visual indicator on employee in the "Who's available?" sheet (greyed out + icon if conflicted)

**Gap Warnings**
- Events with any `uncovered` critical slot → banner warning on Event Detail and on Event List row
- Dashboard badge: "X events have uncovered roles this week"

**"Who's Available?" Lookup**
- Accessible from Home and from Calendar day view
- Inputs: date, time range, role filter
- Returns: list of employees with matching availability and role, sorted by reliability score
- Shows conflict status inline

**Local Notifications** *(via `flutter_local_notifications`)*
- Optional reminder: 48h before an event → "Event tomorrow: X uncovered slots"
- Opt-in per event or globally in Settings

---

### Phase 3 — People Management

**Reliability Score System**
- ShiftLog entry screen — quick post-event logging: pick outcome, optional notes
- History screen per employee — timeline of all logged shifts and score changes
- Score displayed prominently on profile; color-coded (green ≥ 7, amber 4–7, red < 4)
- Manual override with a note (e.g. "Adjusted — exceptional circumstances")

**Advanced Employee Filtering**
- Filter bar: role, location, reliability range, availability on a specific date
- Sort: by name, score, location, date added
- Saved filter presets (e.g. "London bartenders, score ≥ 7")

**Client Management** *(light)*
- Client list — name, phone, event count
- Link events to a client
- Tap client → see all their past/upcoming events

**Inactive Archive**
- One tap to deactivate — removed from all scheduling views
- Separate "Archive" tab in Employee list
- Reactivate with one tap
- All shift history and reliability score preserved

---

### Phase 4 — Polish & Export

**Event Roster PDF Export**
- Generated via `pdf` + `printing` packages
- Contents: event title, date/time, venue, address, client contact, dresscode
- Role slot table: role, employee name, phone, status
- Export notes field printed at bottom
- Share via system share sheet → WhatsApp, email, print, AirDrop
- Clean, readable layout — suitable for printing on A4 or sharing as image

**Dashboard Home Screen**
- Today's events with slot summary (X confirmed, Y pending, Z uncovered)
- Upcoming week at a glance — compact scrollable list
- Quick action buttons: "Add Event", "Find Available Staff"
- Overdue items: events in the past with uncompleted shift logs

**Color Coding — Global**
- Green / amber / red applied consistently across: event list, role slots, employee score, calendar day badges
- Status chips on every list row — never just text

**Data Backup & Restore**
- Export all data to a single JSON file → saved to device Downloads or shared via share sheet
- Import from JSON — validates structure before overwriting
- Accessible from Settings
- Warn user before import: "This will replace all current data"
- Suggested: manual backup reminder prompt every 30 days

**CSV Export** *(bonus)*
- Employee list → CSV (for sharing with a payroll contact)
- Event roster → CSV (for external coordinators)

---

## Tech Stack

| Concern | Choice | Reason |
|---|---|---|
| Framework | Flutter (Dart) | Already established; consistent with existing app |
| Local DB | `hive` | Fast, no SQL overhead, easy Flutter integration, offline-first |
| Calendar | `table_calendar` | Feature-rich, well-maintained, Flutter-native |
| State management | `riverpod` | Cleaner than `provider` for larger feature sets; easy async |
| Navigation | `go_router` | Declarative, deep-linkable, handles nested navigation cleanly |
| PDF export | `pdf` + `printing` | Best Flutter PDF stack; printing package handles share sheet |
| Phone/SMS/WhatsApp | `url_launcher` | Simple, no permissions needed for tel:/sms:/https: |
| Local notifications | `flutter_local_notifications` | Scheduling reminders without any backend |
| UUID generation | `uuid` | For all model IDs |
| File picking (import) | `file_picker` | For JSON backup import |
| Build target | Android APK (primary) | iOS can be added later with no code changes |

---

## Project Folder Structure

```
lib/
├── main.dart
├── app.dart                  # MaterialApp, theme, GoRouter setup
│
├── core/
│   ├── theme.dart            # Color scheme, text styles, spacing constants
│   ├── router.dart           # All route definitions (go_router)
│   ├── hive_boxes.dart       # Box names + type adapter registration
│   └── utils/
│       ├── date_utils.dart
│       ├── conflict_checker.dart
│       └── score_calculator.dart
│
├── models/
│   ├── employee.dart         # + Hive TypeAdapter
│   ├── event.dart
│   ├── role_slot.dart
│   ├── shift_log.dart
│   ├── client.dart
│   └── enums.dart            # SlotStatus, ContractType, ShiftOutcome, etc.
│
├── repositories/
│   ├── employee_repository.dart
│   ├── event_repository.dart
│   ├── shift_log_repository.dart
│   └── client_repository.dart
│
├── providers/                # Riverpod providers
│   ├── employee_provider.dart
│   ├── event_provider.dart
│   ├── availability_provider.dart
│   └── dashboard_provider.dart
│
├── screens/
│   ├── home/
│   │   └── home_screen.dart
│   ├── employees/
│   │   ├── employee_list_screen.dart
│   │   ├── employee_profile_screen.dart
│   │   ├── employee_form_screen.dart
│   │   └── shift_log_screen.dart
│   ├── events/
│   │   ├── event_list_screen.dart
│   │   ├── event_detail_screen.dart
│   │   └── event_form_screen.dart
│   ├── calendar/
│   │   └── calendar_screen.dart
│   ├── availability/
│   │   └── availability_lookup_screen.dart
│   └── settings/
│       └── settings_screen.dart
│
└── widgets/                  # Shared, reusable components
    ├── status_chip.dart
    ├── employee_card.dart
    ├── role_slot_tile.dart
    ├── reliability_badge.dart
    ├── section_header.dart
    └── confirm_dialog.dart
```

---

## Screen Structure

```
Home (Dashboard)
├── Events
│   ├── Event List
│   ├── Event Detail
│   │   └── Role Slot Assignment Sheet (bottom sheet)
│   └── Add / Edit Event
├── Employees
│   ├── Employee List
│   │   └── Archive (tab)
│   ├── Employee Profile
│   │   └── Shift Log History
│   └── Add / Edit Employee
├── Calendar
│   └── Day Detail (bottom sheet)
├── Availability Lookup (tab or modal)
└── Settings
    ├── Backup / Restore
    ├── Reliability Score Config
    └── Notification Preferences
```

---

## Key UX Principles

**Built for a non-technical user managing a fast-moving operation:**

- **Big tap targets everywhere** — 48dp minimum; list items at least 64dp tall
- **Status at a glance** — color chips on every list row; no hunting for info
- **Minimal taps to assign** — Event Detail → uncovered slot → one tap → filtered staff list → one tap to assign. Three taps maximum
- **Destructive actions always confirm** — delete, deactivate, import (restore) all require a confirmation dialog
- **No dead ends** — every empty state has a clear primary action ("No events yet — Add your first event")
- **No cloud, no login** — fully offline; data lives on device; backup is manual and explicit
- **Graceful conflict warnings** — warn, never hard-block; manager always has final say
- **WhatsApp-first contact** — given the target industry, WhatsApp deep links (`https://wa.me/...`) prioritised over SMS

---

## Data Validation Rules

- Employee name: required, 2–80 characters
- Phone: required, basic format check (digits, +, spaces — no strict regex to avoid false rejections of international numbers)
- Reliability score: 0.0–10.0, 1 decimal place
- Event date: cannot be in the past when creating (warn, don't block — editing old records is valid)
- Start time must be before end time; call time must be before start time
- Role slot roleType: required, non-empty string; suggested from a pre-defined list but freeform allowed
- Hive TypeAdapters: all enums stored as int index; add new values only at the end of enum declaration to avoid breaking stored data

---

## Backup & Restore — Technical Detail

**Export format:** Single JSON file structured as:
```json
{
  "version": 2,
  "exportedAt": "2025-04-10T14:30:00Z",
  "employees": [...],
  "events": [...],
  "roleSlots": [...],
  "shiftLogs": [...],
  "clients": [...]
}
```

- Version field allows migration logic on import
- Export filename: `staffing_backup_YYYY-MM-DD.json`
- Shared via system share sheet (save to Files, Google Drive, WhatsApp to self, etc.)
- Import: user picks the JSON file via `file_picker`, app validates version + structure, shows summary ("112 employees, 47 events"), asks for confirmation, then replaces all Hive boxes

---

## Hive Setup Notes

- Register all TypeAdapters in `main()` before `runApp()`
- Use named boxes: `'employees'`, `'events'`, `'roleSlots'`, `'shiftLogs'`, `'clients'`
- TypeAdapter field IDs are permanent — never reuse a deleted field ID
- Avoid storing `DateTime` as String; use `DateTime.toIso8601String()` and parse on read, or use a custom adapter
- For the `availability` map (Weekday → List\<TimeRange\>): serialize as JSON string within Hive for simplicity, deserialize on read

---

## Phase Delivery Order (Suggested)

| Sprint | Deliverable |
|---|---|
| 1 | Data models + Hive setup + basic navigation skeleton |
| 2 | Employee CRUD (list, add, edit, profile) |
| 3 | Event CRUD (list, add, edit, detail) |
| 4 | Role slot management + assignment flow |
| 5 | "Who's Available?" lookup + conflict detection |
| 6 | Calendar view + day detail |
| 7 | Dashboard home screen + color coding polish |
| 8 | Reliability score + ShiftLog entry |
| 9 | PDF export + backup/restore |
| 10 | Notifications + settings screen + final QA |
