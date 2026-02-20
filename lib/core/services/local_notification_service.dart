import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'gamification_service.dart';

/// OS-level local notification service.
/// Fires real device notifications on Android/iOS.
/// Gracefully no-ops on Web/Windows/Linux/macOS.
class LocalNotificationService {
  static final LocalNotificationService _instance =
      LocalNotificationService._();
  factory LocalNotificationService() => _instance;
  LocalNotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Whether the current platform supports local notifications.
  /// Web, Windows, Linux, macOS are not supported.
  bool get isSupported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  // ─── Notification Channel ───
  static const _channelId = 'astrolearn_daily';
  static const _channelName = 'AstroLearn Daily';
  static const _channelDesc = 'Daily cosmic reminders and task notifications';

  // ─── Notification IDs ───
  static const _morningTasksId = 1001;
  static const _eveningNudgeId = 1002;
  static const _streakWarningId = 1003;

  /// Initialize the notification plugin and timezone data.
  Future<void> initialize() async {
    if (!isSupported || _initialized) return;

    // Initialize timezone
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));

    // Android settings
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Request permission on Android 13+
    await _requestPermission();

    _initialized = true;
    print('🔔 LocalNotificationService initialized');
  }

  /// Request notification permission (Android 13+ / iOS)
  Future<void> _requestPermission() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.requestNotificationsPermission();
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      final iosPlugin = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      await iosPlugin?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  /// Handle notification tap
  void _onNotificationTap(NotificationResponse response) {
    // The app will open automatically; specific routing can be added later
    print('🔔 Notification tapped: ${response.payload}');
  }

  // ═══════════════════════════════════════════════════
  // IMMEDIATE NOTIFICATIONS
  // ═══════════════════════════════════════════════════

  /// Show a notification immediately (for events like task completion, milestones)
  Future<void> showNow({
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!isSupported || !_initialized) return;

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFF7B61FF),
      enableVibration: true,
      playSound: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: payload,
    );
  }

  // ═══════════════════════════════════════════════════
  // SCHEDULED DAILY NOTIFICATIONS
  // ═══════════════════════════════════════════════════

  /// Schedule all daily recurring notifications
  Future<void> scheduleDailyNotifications() async {
    if (!isSupported || !_initialized) return;

    // Cancel existing scheduled notifications first
    await _plugin.cancelAll();

    // 🌅 Morning tasks reminder — 8:00 AM
    await _scheduleDaily(
      id: _morningTasksId,
      hour: 8,
      minute: 0,
      title: 'Your cosmic tasks are ready! ✨',
      body: 'Start your day aligned with the stars. 5 new tasks await you.',
      payload: 'daily_tasks',
    );

    // 🌙 Evening learning nudge — 6:00 PM
    await _scheduleDaily(
      id: _eveningNudgeId,
      hour: 18,
      minute: 0,
      title: 'Continue your Jyotish journey 🌙',
      body: 'A few minutes of learning keeps your cosmic wisdom growing.',
      payload: 'learning',
    );

    // 🔥 Streak protection — 8:00 PM (only shows if streak > 0)
    final streak = GamificationService().currentStreak;
    if (streak > 0) {
      await _scheduleDaily(
        id: _streakWarningId,
        hour: 20,
        minute: 0,
        title: 'Your ${streak}-day streak is at risk! 🔥',
        body: 'Open AstroLearn to keep your cosmic streak alive.',
        payload: 'streak',
      );
    }

    print('📅 Daily notifications scheduled');
  }

  /// Schedule a daily repeating notification at a specific time
  Future<void> _scheduleDaily({
    required int id,
    required int hour,
    required int minute,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.high,
      priority: Priority.defaultPriority,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFF7B61FF),
      enableVibration: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      _nextInstanceOfTime(hour, minute),
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // repeats daily
      payload: payload,
    );
  }

  /// Get the next instance of a specific time (today or tomorrow)
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    return scheduled;
  }

  // ═══════════════════════════════════════════════════
  // CANCEL
  // ═══════════════════════════════════════════════════

  /// Cancel all scheduled notifications
  Future<void> cancelAll() async {
    if (!isSupported) return;
    await _plugin.cancelAll();
  }

  /// Cancel a specific notification
  Future<void> cancel(int id) async {
    if (!isSupported) return;
    await _plugin.cancel(id);
  }
}
