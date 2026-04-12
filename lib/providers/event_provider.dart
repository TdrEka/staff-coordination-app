import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';

import '../core/utils/notification_scheduler.dart';
import '../models/enums.dart';
import '../models/event.dart';
import '../repositories/event_repository.dart';

final Provider<EventRepository> eventRepositoryProvider = Provider<EventRepository>((
  Ref<EventRepository> ref,
) {
  return EventRepository();
});

final StateNotifierProvider<EventNotifier, List<Event>> eventsProvider =
    StateNotifierProvider<EventNotifier, List<Event>>((Ref ref) {
      return EventNotifier(ref.read(eventRepositoryProvider));
    });

final ProviderFamily<List<Event>, DateTime> eventsByDateProvider =
  Provider.family<List<Event>, DateTime>((Ref ref, DateTime date) {
      final DateTime target = DateTime(date.year, date.month, date.day);
      final List<Event> events = ref.watch(eventsProvider);
      return events.where((Event event) {
        final DateTime eventDate = DateTime.tryParse(event.date) ?? DateTime.fromMillisecondsSinceEpoch(0);
        final DateTime day = DateTime(eventDate.year, eventDate.month, eventDate.day);
        return day == target;
      }).toList()
        ..sort((Event a, Event b) {
          final DateTime da = DateTime.tryParse(a.date) ?? DateTime.fromMillisecondsSinceEpoch(0);
          final DateTime db = DateTime.tryParse(b.date) ?? DateTime.fromMillisecondsSinceEpoch(0);
          return da.compareTo(db);
        });
    });

final Provider<List<Event>> eventsThisWeekProvider = Provider<List<Event>>((Ref ref) {
  final List<Event> events = ref.watch(eventsProvider);
  final DateTime now = DateTime.now();
  final DateTime start = DateTime(now.year, now.month, now.day);
  final DateTime end = start.add(const Duration(days: 7));

  return events.where((Event event) {
    final DateTime eventDate = DateTime.tryParse(event.date) ?? DateTime.fromMillisecondsSinceEpoch(0);
    final DateTime day = DateTime(eventDate.year, eventDate.month, eventDate.day);
    return day.compareTo(start) >= 0 && day.compareTo(end) < 0;
  }).toList()
    ..sort((Event a, Event b) {
      final DateTime da = DateTime.tryParse(a.date) ?? DateTime.fromMillisecondsSinceEpoch(0);
      final DateTime db = DateTime.tryParse(b.date) ?? DateTime.fromMillisecondsSinceEpoch(0);
      return da.compareTo(db);
    });
});

class EventNotifier extends StateNotifier<List<Event>> {
  EventNotifier(this._repository) : super(<Event>[]) {
    _load();
  }

  final EventRepository _repository;

  void _load() {
    state = _repository.getAll();
  }

  Event? getById(String id) {
    for (final Event event in state) {
      if (event.id == id) {
        return event;
      }
    }
    return _repository.getById(id);
  }

  Future<void> add(Event event) async {
    await _repository.save(event);
    _load();
    try {
      await NotificationScheduler.scheduleEventReminder(event);
    } catch (error, stackTrace) {
      debugPrint('Failed to schedule reminder for ${event.id}: $error\n$stackTrace');
    }
  }

  Future<void> update(Event event) async {
    await _repository.save(event);
    _load();
    try {
      await NotificationScheduler.scheduleEventReminder(event);
    } catch (error, stackTrace) {
      debugPrint('Failed to schedule reminder for ${event.id}: $error\n$stackTrace');
    }
  }

  Future<void> updateStatus(String eventId, EventStatus status) async {
    final Event? event = _repository.getById(eventId);
    if (event == null) {
      return;
    }
    event.status = status;
    await _repository.save(event);
    _load();
    try {
      if (status == EventStatus.cancelled) {
        await NotificationScheduler.cancelEventReminder(eventId);
      } else {
        await NotificationScheduler.scheduleEventReminder(event);
      }
    } catch (error, stackTrace) {
      debugPrint('Failed to update reminder for $eventId: $error\n$stackTrace');
    }
  }

  Future<void> delete(String eventId) async {
    await _repository.delete(eventId);
    _load();
    try {
      await NotificationScheduler.cancelEventReminder(eventId);
    } catch (error, stackTrace) {
      debugPrint('Failed to cancel reminder for $eventId: $error\n$stackTrace');
    }
  }
}
