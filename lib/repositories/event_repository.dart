import 'package:hive/hive.dart';

import '../core/hive_boxes.dart';
import '../models/enums.dart';
import '../models/event.dart';

class EventRepository {
  Box<Event> get _box => Hive.box<Event>(eventsBoxName);

  List<Event> getAll() {
    final List<Event> events = _box.values
        .where((Event e) => e.status != EventStatus.cancelled)
        .toList();
    events.sort((Event a, Event b) => _safeParseDate(a.date).compareTo(_safeParseDate(b.date)));
    return events;
  }

  List<Event> getAllIncludingCancelled() {
    final List<Event> events = _box.values.toList();
    events.sort((Event a, Event b) => _safeParseDate(a.date).compareTo(_safeParseDate(b.date)));
    return events;
  }

  Event? getById(String id) {
    return _box.get(id);
  }

  List<Event> getUpcoming() {
    final DateTime today = _dateOnly(DateTime.now());
    final List<Event> events = getAll()
        .where((Event event) => _dateOnly(_safeParseDate(event.date)).compareTo(today) >= 0)
        .toList();
    events.sort((Event a, Event b) => _safeParseDate(a.date).compareTo(_safeParseDate(b.date)));
    return events;
  }

  List<Event> getPast() {
    final DateTime today = _dateOnly(DateTime.now());
    final List<Event> events = getAll()
        .where((Event event) => _dateOnly(_safeParseDate(event.date)).compareTo(today) < 0)
        .toList();
    events.sort((Event a, Event b) => _safeParseDate(b.date).compareTo(_safeParseDate(a.date)));
    return events;
  }

  Future<void> save(Event event) async {
    await _box.put(event.id, event);
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  static DateTime _safeParseDate(String value) {
    return DateTime.tryParse(value) ?? DateTime.fromMillisecondsSinceEpoch(0);
  }

  static DateTime _dateOnly(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }
}
