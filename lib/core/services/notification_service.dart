import 'dart:math';
import 'package:flutter/material.dart';

/// Duolingo-style notification & engagement service.
/// Manages in-app engagement nudges, streak protection, ability tease,
/// and comeback hooks without requiring a backend.
class NotificationService {
  // Singleton
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

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
    String msg = _xpMilestoneMessages[_random.nextInt(_xpMilestoneMessages.length)];
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
        message: getAbilityTeaseMessage(nearestAbilityTitle, nearestAbilityChapter),
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
