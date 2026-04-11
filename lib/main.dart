import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import 'app.dart';
import 'core/hive_boxes.dart';
import 'core/utils/notification_scheduler.dart';

Future<void> main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await initHive();
    await NotificationScheduler.initNotifications();
    await NotificationScheduler.refreshAllEventReminders();

    runApp(
      const ProviderScope(
        child: _LifecycleRoot(child: StaffCoordinationApp()),
      ),
    );
  }, (Object error, StackTrace stack) {
    debugPrint('FATAL: $error\n$stack');
  });
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
