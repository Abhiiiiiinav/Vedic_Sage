import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notification_service.dart';

/// Firebase Cloud Messaging (FCM) Push Notification Service
/// Handles remote push notifications from Firebase
///
/// IMPORTANT: FirebaseMessaging.instance is accessed LAZILY (not in constructor)
/// to avoid [core/no-app] crashes when Firebase isn't initialized.
class PushNotificationService {
  static final PushNotificationService _instance = PushNotificationService._();
  factory PushNotificationService() => _instance;
  PushNotificationService._();

  // LAZY — only accessed after Firebase.initializeApp() succeeds
  FirebaseMessaging? _fcm;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  SharedPreferences? _prefs;
  String? _fcmToken;
  bool _initialized = false;

  /// Whether the service initialized successfully
  bool get isInitialized => _initialized;

  static const String _keyFcmToken = 'fcm_token';
  static const String _keyNotificationsEnabled = 'notifications_enabled';

  /// Initialize FCM and request permissions
  Future<void> initialize() async {
    if (_initialized) return;

    // Skip initialization on web
    if (kIsWeb) {
      debugPrint('🌐 Push notifications not supported on web');
      return;
    }

    try {
      // Lazily obtain FirebaseMessaging — only after Firebase is initialized
      _fcm = FirebaseMessaging.instance;

      _prefs ??= await SharedPreferences.getInstance();

      // Initialize local notifications for foreground display
      await _initializeLocalNotifications();

      // Request notification permissions
      await _requestPermissions();

      // Get FCM token
      await _getFcmToken();

      // Setup message handlers
      _setupMessageHandlers();

      _initialized = true;
      debugPrint('🔔 PushNotificationService initialized');
      debugPrint('📱 FCM Token: $_fcmToken');
    } catch (e) {
      debugPrint('❌ PushNotificationService initialization failed: $e');
      debugPrint('💡 This is normal if Firebase is not configured yet');
      debugPrint('📖 See PUSH_NOTIFICATIONS_SETUP.md for setup instructions');
      // Don't throw - let the app continue without push notifications
      _fcm = null; // Reset to null if init failed
    }
  }

  /// Initialize local notifications plugin for foreground messages
  Future<void> _initializeLocalNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );
  }

  /// Request notification permissions
  Future<void> _requestPermissions() async {
    if (_fcm == null) return;
    try {
      final settings = await _fcm!.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      final enabled =
          settings.authorizationStatus == AuthorizationStatus.authorized ||
              settings.authorizationStatus == AuthorizationStatus.provisional;

      await _prefs?.setBool(_keyNotificationsEnabled, enabled);

      debugPrint('🔔 Notification permission: ${settings.authorizationStatus}');
    } catch (e) {
      debugPrint('❌ Error requesting notification permissions: $e');
    }
  }

  /// Get FCM token for this device
  Future<void> _getFcmToken() async {
    if (_fcm == null) return;
    try {
      _fcmToken = await _fcm!.getToken();
      if (_fcmToken != null) {
        await _prefs?.setString(_keyFcmToken, _fcmToken!);
        debugPrint('✅ FCM Token obtained: $_fcmToken');
      }

      // Listen for token refresh
      _fcm!.onTokenRefresh.listen((newToken) {
        _fcmToken = newToken;
        _prefs?.setString(_keyFcmToken, newToken);
        debugPrint('🔄 FCM Token refreshed: $newToken');
      });
    } catch (e) {
      debugPrint('❌ Error getting FCM token: $e');
    }
  }

  /// Setup message handlers for different app states
  void _setupMessageHandlers() {
    if (_fcm == null) return;

    // Handle foreground messages (app is open)
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle background messages (app is in background)
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);

    // Handle notification tap when app was terminated
    _fcm!.getInitialMessage().then((message) {
      if (message != null) {
        _handleBackgroundMessage(message);
      }
    });
  }

  /// Handle messages when app is in foreground
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    debugPrint('📨 Foreground message received: ${message.messageId}');

    // Show local notification
    await _showLocalNotification(message);

    // Add to in-app notification center
    await _addToNotificationCenter(message);
  }

  /// Handle messages when app is opened from background
  Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    debugPrint('📨 Background message opened: ${message.messageId}');

    // Add to in-app notification center
    await _addToNotificationCenter(message);

    // Handle navigation based on notification type
    _handleNotificationNavigation(message);
  }

  /// Show local notification for foreground messages
  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    const androidDetails = AndroidNotificationDetails(
      'astrolearn_push',
      'AstroLearn Push Notifications',
      channelDescription: 'Push notifications from AstroLearn',
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

    await _localNotifications.show(
      message.hashCode,
      notification.title,
      notification.body,
      details,
      payload: message.data['type'] ?? 'general',
    );
  }

  /// Add notification to in-app notification center
  Future<void> _addToNotificationCenter(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    final type = message.data['type'] ?? 'general';
    final title = notification.title ?? 'AstroLearn';
    final body = notification.body ?? '';

    // Add to NotificationService
    await NotificationService().addNotification(
      title: title,
      message: body,
      icon: _getIconForType(type),
      color: _getColorForType(type),
      type: type,
    );
  }

  /// Handle notification tap
  void _onNotificationTap(NotificationResponse response) {
    debugPrint('🔔 Notification tapped: ${response.payload}');
    // Navigation logic can be added here
  }

  /// Handle navigation based on notification type
  void _handleNotificationNavigation(RemoteMessage message) {
    final type = message.data['type'];
    debugPrint('🧭 Navigate to: $type');
  }

  /// Get icon based on notification type
  IconData _getIconForType(String type) {
    switch (type) {
      case 'streak':
        return Icons.local_fire_department;
      case 'learning':
        return Icons.menu_book_rounded;
      case 'cosmic':
        return Icons.wb_sunny_rounded;
      case 'social':
        return Icons.people_rounded;
      case 'achievement':
        return Icons.emoji_events_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  /// Get color based on notification type
  Color _getColorForType(String type) {
    switch (type) {
      case 'streak':
        return const Color(0xFFff9500);
      case 'learning':
        return const Color(0xFF34c759);
      case 'cosmic':
        return const Color(0xFF00d4ff);
      case 'social':
        return const Color(0xFF667eea);
      case 'achievement':
        return const Color(0xFFf5a623);
      default:
        return const Color(0xFF7B61FF);
    }
  }

  // ═══════════════════════════════════════════════════
  // PUBLIC API — All guarded by _initialized check
  // ═══════════════════════════════════════════════════

  /// Get the current FCM token
  String? get fcmToken => _fcmToken;

  /// Check if notifications are enabled
  bool get notificationsEnabled =>
      _prefs?.getBool(_keyNotificationsEnabled) ?? false;

  /// Subscribe to a topic (no-op if not initialized)
  Future<void> subscribeToTopic(String topic) async {
    if (!_initialized || _fcm == null) return;
    try {
      await _fcm!.subscribeToTopic(topic);
      debugPrint('✅ Subscribed to topic: $topic');
    } catch (e) {
      debugPrint('❌ Error subscribing to topic: $e');
    }
  }

  /// Unsubscribe from a topic (no-op if not initialized)
  Future<void> unsubscribeFromTopic(String topic) async {
    if (!_initialized || _fcm == null) return;
    try {
      await _fcm!.unsubscribeFromTopic(topic);
      debugPrint('✅ Unsubscribed from topic: $topic');
    } catch (e) {
      debugPrint('❌ Error unsubscribing from topic: $e');
    }
  }

  /// Delete FCM token (for logout, no-op if not initialized)
  Future<void> deleteToken() async {
    if (!_initialized || _fcm == null) return;
    try {
      await _fcm!.deleteToken();
      _fcmToken = null;
      await _prefs?.remove(_keyFcmToken);
      debugPrint('✅ FCM token deleted');
    } catch (e) {
      debugPrint('❌ Error deleting FCM token: $e');
    }
  }

  /// Send test notification (for debugging)
  Future<void> sendTestNotification() async {
    await NotificationService().addNotification(
      title: 'Test Notification',
      message: 'This is a test push notification from AstroLearn!',
      icon: Icons.bug_report,
      color: const Color(0xFF7B61FF),
      type: 'test',
    );
  }
}

/// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('📨 Background message received: ${message.messageId}');
  print('Title: ${message.notification?.title}');
  print('Body: ${message.notification?.body}');
  print('Data: ${message.data}');
}
