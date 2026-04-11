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

  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  static final RoleSlotRepository _roleSlotRepository = RoleSlotRepository();
  static final EventRepository _eventRepository = EventRepository();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'event_reminders',
    'Event reminders',
    description: 'Staffing reminders for events with uncovered slots',
    importance: Importance.high,
  );

  static bool _initialized = false;

  static Future<void> initNotifications() async {
    if (kIsWeb) {
      _initialized = true;
      return;
    }

    if (_initialized) {
      return;
    }

    tz.initializeTimeZones();

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
    );

    await _notifications.initialize(initSettings);

    final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
        _notifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.createNotificationChannel(_channel);
    await androidPlugin?.requestNotificationsPermission();

    _initialized = true;
  }

  static Future<void> scheduleEventReminder(Event event) async {
    if (kIsWeb) {
      return;
    }

    await initNotifications();

    final bool enabled = _areRemindersEnabled();
    final int notificationId = _eventNotificationId(event.id);
    if (!enabled) {
      await _notifications.cancel(notificationId);
      return;
    }

    final List<RoleSlot> slots = _roleSlotRepository.getByEventId(event.id);
    final int uncoveredCount = slots
        .where((RoleSlot slot) => slot.status == SlotStatus.uncovered)
        .length;
    if (uncoveredCount <= 0) {
      await _notifications.cancel(notificationId);
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
      await _notifications.cancel(notificationId);
      return;
    }

    await _notifications.zonedSchedule(
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

    await initNotifications();
    await _notifications.cancel(_eventNotificationId(eventId));
  }

  static Future<void> cancelAllReminders() async {
    if (kIsWeb) {
      return;
    }

    await initNotifications();
    await _notifications.cancelAll();
  }

  static Future<void> refreshAllEventReminders() async {
    if (kIsWeb) {
      return;
    }

    await initNotifications();

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
