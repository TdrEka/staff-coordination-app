import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/hive_boxes.dart';
import 'core/utils/notification_scheduler.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initHive();
  await NotificationScheduler.initNotifications();
  await NotificationScheduler.refreshAllEventReminders();

  runApp(
    const ProviderScope(
      child: StaffCoordinationApp(),
    ),
  );
}
