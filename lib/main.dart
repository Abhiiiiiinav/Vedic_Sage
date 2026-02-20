import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app/app.dart';
import 'core/database/hive_database_service.dart';
import 'core/services/user_session.dart';
import 'core/services/gamification_service.dart';
import 'core/services/friends_service.dart';
import 'core/services/daily_tasks_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/local_notification_service.dart';
import 'core/services/app_update_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Phase 1: Load env + initialize database in parallel
  await Future.wait([
    dotenv.load(fileName: ".env"),
    HiveDatabaseService().initialize(),
  ]);

  // Phase 2: Session + Gamification depend on DB, so run after Phase 1 — but parallel to each other
  await Future.wait([
    UserSession().initialize(),
    GamificationService().initialize(),
    FriendsService().initialize(),
    AppUpdateService().initialize(),
  ]);

  // Phase 3: Services that depend on user session data
  await Future.wait([
    DailyTasksService().initialize(),
    NotificationService().initialize(),
    LocalNotificationService().initialize(),
  ]);

  // Phase 4: Schedule daily device notifications (after all services ready)
  LocalNotificationService().scheduleDailyNotifications();

  // Set system UI overlay style for immersive experience
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0a0e21),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const AstroLearnApp());
}
