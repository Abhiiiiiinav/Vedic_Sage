import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'app/app.dart';
import 'core/database/hive_database_service.dart';
import 'core/services/user_session.dart';
import 'core/services/gamification_service.dart';
import 'core/services/friends_service.dart';
import 'core/services/daily_tasks_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/local_notification_service.dart';
import 'core/services/app_update_service.dart';
import 'core/services/push_notification_service.dart';
import 'core/services/firebase_service.dart';
import 'core/services/home_widget_service.dart';

/// Background message handler for Firebase Messaging
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (!kIsWeb) {
    await Firebase.initializeApp();
    print('📨 Handling background message: ${message.messageId}');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase (mobile only — web needs flutterfire configure)
  bool firebaseReady = false;
  if (!kIsWeb) {
    try {
      await Firebase.initializeApp();
      await FirebaseService().initialize();
      FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler);
      firebaseReady = true;
      print('✅ Firebase initialized successfully');
    } catch (e) {
      print('⚠️ Firebase initialization failed: $e');
      print('📱 App will continue without push notifications');
      print(
          '💡 To enable push notifications, add google-services.json to android/app/');
    }
  } else {
    print('🌐 Running on web — Firebase features disabled');
  }

  try {
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
      // Only initialize push notifications on mobile and if Firebase is available
      if (!kIsWeb && firebaseReady)
        PushNotificationService().initialize().catchError((e) {
          print('⚠️ Push notification service failed to initialize: $e');
          return null;
        }),
    ]);

    // Phase 4: Schedule daily device notifications (after all services ready)
    LocalNotificationService().scheduleDailyNotifications();

    // Subscribe to default topics (only if push service initialized)
    if (!kIsWeb && PushNotificationService().isInitialized) {
      try {
        await PushNotificationService().subscribeToTopic('all_users');
        await PushNotificationService().subscribeToTopic('daily_updates');
        print('✅ Subscribed to notification topics');
      } catch (e) {
        print('⚠️ Topic subscription failed: $e');
      }
    }

    // Phase 5: Push data to native home screen widgets (mobile only)
    if (!kIsWeb) {
      await HomeWidgetService().initialize();
      await HomeWidgetService().updateAllWidgets();
    }

    print('✅ All services initialized successfully');
  } catch (e, stackTrace) {
    print('❌ Critical initialization error: $e');
    print('Stack trace: $stackTrace');
    // App will still try to run, but some features may not work
  }

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
