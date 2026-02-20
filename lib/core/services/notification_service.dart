import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'local_notification_service.dart';

/// Model for an in-app notification
class AppNotification {
  final String id;
  final String title;
  final String message;
  final int iconCodePoint;
  final String? iconFontFamily;
  final int colorValue;
  final DateTime timestamp;
  final String type; // streak, learning, cosmic, social
  bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.iconCodePoint,
    this.iconFontFamily,
    required this.colorValue,
    required this.timestamp,
    required this.type,
    this.isRead = false,
  });

  IconData get icon => IconData(iconCodePoint, fontFamily: iconFontFamily);
  Color get color => Color(colorValue);

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'message': message,
        'iconCodePoint': iconCodePoint,
        'iconFontFamily': iconFontFamily,
        'colorValue': colorValue,
        'timestamp': timestamp.millisecondsSinceEpoch,
        'type': type,
        'isRead': isRead,
      };

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      AppNotification(
        id: json['id'] as String,
        title: json['title'] as String,
        message: json['message'] as String,
        iconCodePoint: json['iconCodePoint'] as int,
        iconFontFamily: json['iconFontFamily'] as String?,
        colorValue: json['colorValue'] as int,
        timestamp:
            DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int),
        type: json['type'] as String,
        isRead: json['isRead'] as bool? ?? false,
      );
}

/// Duolingo-style notification & engagement service.
/// Manages in-app engagement nudges, streak protection, ability tease,
/// comeback hooks, and notification history.
class NotificationService {
  // Singleton
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  SharedPreferences? _prefs;
  List<AppNotification> _notifications = [];

  static const _keyNotifications = 'notification_history_json';
  static const _maxNotifications = 20;

  // ─── Notification Message Templates ───

  static const List<String> _streakMessages = [
    "🔥 Your streak is at risk! Complete a lesson to keep it alive",
    "⚡ Don't break the chain! A quick lesson keeps the streak going",
    "🪐 The stars aligned for you today — keep your streak alive!",
    "💫 Your dedication is cosmic! One lesson to protect your streak",
    "🌙 Chandra is watching — maintain your learning momentum!",
  ];

  static const List<String> _comebackMessages = [
    "🪐 Saturn rewards patience, but consistency matters too. Come back!",
    "🌟 Your birth chart hasn't changed, but your knowledge can! Resume learning",
    "✨ New cosmic insights await — your next lesson is ready",
    "🔮 The Nakshatras miss you. Pick up where you left off!",
    "⏳ Your Dasha period is evolving — learn what it means for you",
  ];

  static const List<String> _dailyNudgeMessages = [
    "🌅 Good morning! Start your day with Vedic wisdom",
    "☀️ Surya is rising — perfect time to learn something new",
    "🌙 Today's a great day to explore your cosmic blueprint",
    "⭐ Your daily dose of Jyotish awaits",
    "🪐 The planets are aligned for learning today!",
  ];

  static const List<String> _xpMilestoneMessages = [
    "🎉 Amazing! You earned {xp} XP this week! Keep climbing",
    "🏆 Level up! You're now a Level {level} Jyotish student",
    "💎 You've collected {xp} total XP — you're a dedicated learner!",
    "🌟 Stellar progress! {xp} XP earned and counting",
  ];

  final _random = Random();

  // ─── Initialize ───

  Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
    _loadNotifications();
    _generateStartupNotifications();
  }

  void _loadNotifications() {
    final json = _prefs?.getString(_keyNotifications);
    if (json != null) {
      try {
        final List<dynamic> decoded = jsonDecode(json);
        _notifications = decoded
            .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (_) {
        _notifications = [];
      }
    }
  }

  Future<void> _saveNotifications() async {
    // Keep only the most recent N
    if (_notifications.length > _maxNotifications) {
      _notifications = _notifications.sublist(
        _notifications.length - _maxNotifications,
      );
    }
    final json = jsonEncode(_notifications.map((n) => n.toJson()).toList());
    await _prefs?.setString(_keyNotifications, json);
  }

  void _generateStartupNotifications() {
    // Only generate if we haven't already today
    final todayKey = _todayString();
    final lastGenDate = _prefs?.getString('notif_last_gen_date');
    if (lastGenDate == todayKey) return;

    // Add daily nudge
    addNotification(
      title: 'Daily Cosmic Update',
      message: getDailyNudgeMessage(),
      icon: Icons.wb_sunny_rounded,
      color: const Color(0xFF00d4ff),
      type: 'cosmic',
    );

    // Add tasks reminder
    addNotification(
      title: 'Tasks of the Day Ready ✨',
      message:
          'Your personalized daily tasks are ready! Tap to view and start completing them.',
      icon: Icons.task_alt_rounded,
      color: const Color(0xFF34c759),
      type: 'learning',
    );

    _prefs?.setString('notif_last_gen_date', todayKey);
  }

  String _todayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  // ─── Notification Management ───

  List<AppNotification> get notifications => List.unmodifiable(
        _notifications.reversed.toList(),
      );

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  Future<void> addNotification({
    required String title,
    required String message,
    required IconData icon,
    required Color color,
    required String type,
  }) async {
    final notif = AppNotification(
      id: '${DateTime.now().millisecondsSinceEpoch}_${_random.nextInt(9999)}',
      title: title,
      message: message,
      iconCodePoint: icon.codePoint,
      iconFontFamily: icon.fontFamily,
      colorValue: color.value,
      timestamp: DateTime.now(),
      type: type,
    );
    _notifications.add(notif);
    await _saveNotifications();

    // Also fire a device notification (Android/iOS)
    LocalNotificationService().showNow(
      title: title,
      body: message,
      payload: type,
    );
  }

  Future<void> markAllRead() async {
    for (final n in _notifications) {
      n.isRead = true;
    }
    await _saveNotifications();
  }

  Future<void> markRead(String id) async {
    final idx = _notifications.indexWhere((n) => n.id == id);
    if (idx != -1) {
      _notifications[idx].isRead = true;
      await _saveNotifications();
    }
  }

  Future<void> removeNotification(String id) async {
    _notifications.removeWhere((n) => n.id == id);
    await _saveNotifications();
  }

  // ─── Get Engagement Messages ───

  /// Get a streak-at-risk message for in-app display
  String getStreakRiskMessage() {
    return _streakMessages[_random.nextInt(_streakMessages.length)];
  }

  /// Get a comeback hook message for users who haven't been active
  String getComebackMessage() {
    return _comebackMessages[_random.nextInt(_comebackMessages.length)];
  }

  /// Get a daily learning nudge
  String getDailyNudgeMessage() {
    return _dailyNudgeMessages[_random.nextInt(_dailyNudgeMessages.length)];
  }

  /// Get an XP milestone message
  String getXpMilestoneMessage({required int xp, int? level}) {
    String msg =
        _xpMilestoneMessages[_random.nextInt(_xpMilestoneMessages.length)];
    msg = msg.replaceAll('{xp}', xp.toString());
    if (level != null) msg = msg.replaceAll('{level}', level.toString());
    return msg;
  }

  /// Get ability tease message when user is close to unlocking
  String getAbilityTeaseMessage(String abilityTitle, String chapterTitle) {
    final messages = [
      "⭐ You're close to unlocking '$abilityTitle'! Complete '$chapterTitle' to reveal it",
      "🔓 Almost there! '$abilityTitle' awaits — finish '$chapterTitle'",
      "🧠 '$abilityTitle' is within reach. Just one chapter away!",
      "✨ Keep going! '$abilityTitle' will reveal a new layer of your personality",
    ];
    return messages[_random.nextInt(messages.length)];
  }

  // ─── Engagement State Checks ───

  /// Check if streak is at risk (no activity today)
  bool isStreakAtRisk(DateTime? lastActivityDate) {
    if (lastActivityDate == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastActivity = DateTime(
      lastActivityDate.year,
      lastActivityDate.month,
      lastActivityDate.day,
    );
    return today.difference(lastActivity).inDays >= 1;
  }

  /// Check if user needs a comeback hook (2+ days inactive)
  bool needsComebackHook(DateTime? lastActivityDate) {
    if (lastActivityDate == null) return true;
    final now = DateTime.now();
    return now.difference(lastActivityDate).inDays >= 2;
  }

  /// Determine which engagement banner to show on home screen
  EngagementBanner? getEngagementBanner({
    required DateTime? lastActivityDate,
    required int currentStreak,
    required int totalXP,
    String? nearestAbilityTitle,
    String? nearestAbilityChapter,
  }) {
    // Priority 1: Comeback hook (2+ days away)
    if (needsComebackHook(lastActivityDate)) {
      return EngagementBanner(
        message: getComebackMessage(),
        type: BannerType.comeback,
        icon: Icons.rocket_launch,
        color: const Color(0xFFff6b9d),
      );
    }

    // Priority 2: Streak at risk
    if (isStreakAtRisk(lastActivityDate) && currentStreak > 0) {
      return EngagementBanner(
        message: getStreakRiskMessage(),
        type: BannerType.streakRisk,
        icon: Icons.local_fire_department,
        color: const Color(0xFFff9500),
      );
    }

    // Priority 3: Ability tease
    if (nearestAbilityTitle != null && nearestAbilityChapter != null) {
      return EngagementBanner(
        message:
            getAbilityTeaseMessage(nearestAbilityTitle, nearestAbilityChapter),
        type: BannerType.abilityTease,
        icon: Icons.auto_awesome,
        color: const Color(0xFF7B61FF),
      );
    }

    // Priority 4: Daily nudge (if active today, show encouragement)
    return EngagementBanner(
      message: getDailyNudgeMessage(),
      type: BannerType.dailyNudge,
      icon: Icons.wb_sunny,
      color: const Color(0xFF00d4ff),
    );
  }
}

/// Types of engagement banners
enum BannerType {
  streakRisk,
  comeback,
  abilityTease,
  dailyNudge,
  xpMilestone,
}

/// Data class for engagement banner display
class EngagementBanner {
  final String message;
  final BannerType type;
  final IconData icon;
  final Color color;

  const EngagementBanner({
    required this.message,
    required this.type,
    required this.icon,
    required this.color,
  });
}
