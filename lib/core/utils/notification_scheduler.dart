import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../hive_boxes.dart';
import '../../models/enums.dart';
import '../../models/event.dart';
import '../../models/role_slot.dart';
import '../../repositories/event_repository.dart';
import '../../repositories/role_slot_repository.dart';

class NotificationScheduler {
  NotificationScheduler._();

  static final NotificationScheduler instance = NotificationScheduler._();

  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static final RoleSlotRepository _roleSlotRepository = RoleSlotRepository();
  static final EventRepository _eventRepository = EventRepository();
  static bool _timezoneInitialized = false;

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'event_reminders',
    'Event reminders',
    description: 'Staffing reminders for events with uncovered slots',
    importance: Importance.high,
  );

  Future<void> initNotifications() async {
    if (kIsWeb) {
      return;
    }

    await _ensureTimezoneInitialized();

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
    );

    try {
      await _notificationsPlugin.initialize(initSettings);
    } catch (_) {
      // Saved schedule payload may be incompatible after upgrades; wipe and retry.
      try {
        await _notificationsPlugin.cancelAll();
      } catch (_) {}
      await _notificationsPlugin.initialize(initSettings);
    }

    final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.createNotificationChannel(_channel);

    // Request notification permission on Android 13+.
    await androidPlugin?.requestNotificationsPermission();
  }

  static Future<void> _ensureTimezoneInitialized() async {
    if (_timezoneInitialized) {
      return;
    }

    tz.initializeTimeZones();

    final String deviceTz = DateTime.now().timeZoneName.trim();
    final String resolved = _resolveTimezoneName(deviceTz);
    try {
      tz.setLocalLocation(tz.getLocation(resolved));
    } catch (_) {
      // Fallback to UTC if the device timezone name is unknown.
      tz.setLocalLocation(tz.getLocation('UTC'));
    }

    _timezoneInitialized = true;
  }

  static String _resolveTimezoneName(String raw) {
    if (raw.isEmpty) {
      return 'UTC';
    }

    // Some platforms expose abbreviations that are not IANA IDs.
    switch (raw.toUpperCase()) {
      case 'CET':
      case 'CEST':
        return 'Europe/Madrid';
      case 'GMT':
      case 'UTC':
        return 'UTC';
      default:
        return raw;
    }
  }

  static Future<void> scheduleEventReminder(Event event) async {
    if (kIsWeb) {
      return;
    }

    await instance.initNotifications();

    final bool enabled = _areRemindersEnabled();
    final int notificationId = _eventNotificationId(event.id);
    if (!enabled) {
      await _notificationsPlugin.cancel(notificationId);
      return;
    }

    final List<RoleSlot> slots = _roleSlotRepository.getByEventId(event.id);
    final int uncoveredCount = slots
        .where((RoleSlot slot) => slot.status == SlotStatus.uncovered)
        .length;
    if (uncoveredCount <= 0) {
      await _notificationsPlugin.cancel(notificationId);
      return;
    }

    final DateTime eventDate = DateTime.tryParse(event.date) ?? DateTime.now();
    final tz.TZDateTime triggerAt = tz.TZDateTime(
      tz.local,
      eventDate.year,
      eventDate.month,
      eventDate.day,
      9,
    ).subtract(const Duration(days: 2));

    if (triggerAt.isBefore(tz.TZDateTime.now(tz.local))) {
      await _notificationsPlugin.cancel(notificationId);
      return;
    }

    await _notificationsPlugin.zonedSchedule(
      notificationId,
      'Event tomorrow: ${event.title}',
      '$uncoveredCount uncovered slots — check the roster',
      triggerAt,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'event_reminders',
          'Event reminders',
          channelDescription: 'Staffing reminders for events with uncovered slots',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: event.id,
    );
  }

  static Future<void> cancelEventReminder(String eventId) async {
    if (kIsWeb) {
      return;
    }

    await instance.initNotifications();
    await _notificationsPlugin.cancel(_eventNotificationId(eventId));
  }

  static Future<void> cancelAllReminders() async {
    if (kIsWeb) {
      return;
    }

    await instance.initNotifications();
    await _notificationsPlugin.cancelAll();
  }

  static Future<void> refreshAllEventReminders() async {
    if (kIsWeb) {
      return;
    }

    await instance.initNotifications();

    if (!_areRemindersEnabled()) {
      await cancelAllReminders();
      return;
    }

    final List<Event> events = _eventRepository.getAll();
    for (final Event event in events) {
      await scheduleEventReminder(event);
    }
  }

  static bool _areRemindersEnabled() {
    final Box<String> settings = Hive.box<String>(settingsBoxName);
    final String? rawValue = settings.get(remindersEnabledKey);
    return rawValue == 'true';
  }

  static int _eventNotificationId(String eventId) {
    int hash = 2166136261;
    for (final int unit in eventId.codeUnits) {
      hash ^= unit;
      hash = (hash * 16777619) & 0x7fffffff;
    }
    return hash;
  }
}
