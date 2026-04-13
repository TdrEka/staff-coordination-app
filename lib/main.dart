import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import 'app.dart';
import 'core/hive_boxes.dart';
import 'core/utils/notification_scheduler.dart';
import 'core/utils/score_calculator.dart';
import 'models/employee.dart';
import 'models/shift_log.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await initHive();
    await _reconcileReliabilityScoresFromShiftLogs();

    runApp(
      const ProviderScope(
        child: _LifecycleRoot(child: StaffCoordinationApp()),
      ),
    );

    // Notifications init after app starts so plugin state issues are non-fatal.
    try {
      await NotificationScheduler.instance.initNotifications();
      await NotificationScheduler.refreshAllEventReminders();
    } catch (_) {
      // Notifications unavailable; app continues without reminders.
    }
  } catch (e) {
    runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: const Color(0xFF1A1612),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Icon(
                    Icons.warning_amber_rounded,
                    size: 56,
                    color: Color(0xFFC9A96E),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Error al iniciar la app',
                    style: TextStyle(
                      color: Color(0xFFEDE0CF),
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Hubo un problema al cargar los datos.\nPor favor cierra la app y vuelve a abrirla.',
                    style: TextStyle(
                      color: Color(0xFFA89880),
                      fontSize: 15,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    e.toString(),
                    style: const TextStyle(
                      color: Color(0xFF7A7068),
                      fontSize: 11,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> _reconcileReliabilityScoresFromShiftLogs() async {
  final Box<Employee> employeesBox = Hive.box<Employee>(employeesBoxName);
  final Box<ShiftLog> shiftLogsBox = Hive.box<ShiftLog>(shiftLogsBoxName);

  final Map<String, List<ShiftLog>> byEmployee = <String, List<ShiftLog>>{};
  for (final ShiftLog log in shiftLogsBox.values) {
    byEmployee.putIfAbsent(log.employeeId, () => <ShiftLog>[]).add(log);
  }

  for (final Employee employee in employeesBox.values) {
    final List<ShiftLog> logs = byEmployee[employee.id] ?? <ShiftLog>[];
    logs.sort((ShiftLog a, ShiftLog b) {
      final DateTime aTime = DateTime.tryParse(a.loggedAt) ?? DateTime.fromMillisecondsSinceEpoch(0);
      final DateTime bTime = DateTime.tryParse(b.loggedAt) ?? DateTime.fromMillisecondsSinceEpoch(0);
      return aTime.compareTo(bTime);
    });

    double nextScore = 5.0;
    for (final ShiftLog log in logs) {
      nextScore = applyDelta(nextScore, log.scoreDelta);
    }

    if (employee.reliabilityScore != nextScore) {
      employee.reliabilityScore = nextScore;
      await employeesBox.put(employee.id, employee);
    }
  }
}

class _LifecycleRoot extends StatefulWidget {
  const _LifecycleRoot({required this.child});

  final Widget child;

  @override
  State<_LifecycleRoot> createState() => _LifecycleRootState();
}

class _LifecycleRootState extends State<_LifecycleRoot>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {
      unawaited(Hive.close());
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
