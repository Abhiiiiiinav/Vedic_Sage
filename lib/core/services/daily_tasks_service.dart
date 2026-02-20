import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'panchang_service.dart';
import 'gamification_service.dart';
import 'user_session.dart';

/// Model for a single daily task
class DailyTask {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String category; // spiritual, learning, wellness, social
  bool isCompleted;

  DailyTask({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.category,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'iconCodePoint': icon.codePoint,
        'iconFontFamily': icon.fontFamily,
        'colorValue': color.value,
        'category': category,
        'isCompleted': isCompleted,
      };

  factory DailyTask.fromJson(Map<String, dynamic> json) => DailyTask(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        icon: IconData(
          json['iconCodePoint'] as int,
          fontFamily: json['iconFontFamily'] as String?,
          fontPackage: null,
        ),
        color: Color(json['colorValue'] as int),
        category: json['category'] as String,
        isCompleted: json['isCompleted'] as bool? ?? false,
      );
}

/// Service that generates and manages 5 personalized daily astrological tasks.
///
/// Tasks are generated from:
/// - Day Lord (Vara) → spiritual & action tasks
/// - Current Nakshatra → creative/mindset tasks
/// - Streak status → learning motivation tasks
/// - Learning progress → chapter continuation tasks
/// - General wellness → based on planetary day energy
///
/// Cached daily via SharedPreferences — regenerates on a new calendar day.
class DailyTasksService {
  static final DailyTasksService _instance = DailyTasksService._();
  factory DailyTasksService() => _instance;
  DailyTasksService._();

  SharedPreferences? _prefs;

  static const _keyTasks = 'daily_tasks_json_v2';
  static const _keyTaskDate = 'daily_tasks_date_v2';

  List<DailyTask> _tasks = [];

  List<DailyTask> get tasks => List.unmodifiable(_tasks);
  int get completedCount => _tasks.where((t) => t.isCompleted).length;
  int get totalCount => _tasks.length;
  double get progress => totalCount == 0 ? 0 : completedCount / totalCount;

  /// Initialize — call once at app start
  Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
    await _loadOrGenerate();
  }

  Future<void> _loadOrGenerate() async {
    final storedDate = _prefs?.getString(_keyTaskDate);
    final today = _todayString();

    if (storedDate == today) {
      // Load cached tasks
      final json = _prefs?.getString(_keyTasks);
      if (json != null) {
        try {
          final List<dynamic> decoded = jsonDecode(json);
          _tasks = decoded
              .map((e) => DailyTask.fromJson(e as Map<String, dynamic>))
              .toList();
          return;
        } catch (_) {}
      }
    }

    // Generate new tasks for today
    _tasks = _generateTasks();
    await _save();
  }

  /// Toggle a task's completion status
  Future<void> toggleTask(String taskId) async {
    final idx = _tasks.indexWhere((t) => t.id == taskId);
    if (idx == -1) return;

    _tasks[idx].isCompleted = !_tasks[idx].isCompleted;

    // Award XP when completing a task
    if (_tasks[idx].isCompleted) {
      await GamificationService().addXP(15);
      await GamificationService().recordActivity();
    }

    await _save();
  }

  Future<void> _save() async {
    final json = jsonEncode(_tasks.map((t) => t.toJson()).toList());
    await _prefs?.setString(_keyTasks, json);
    await _prefs?.setString(_keyTaskDate, _todayString());
  }

  String _todayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  // ─── Task Generation Engine ───

  List<DailyTask> _generateTasks() {
    final now = DateTime.now();
    final session = UserSession();

    // Get panchang data
    double lat = 28.6139, lon = 77.2090, tz = 5.5;
    if (session.hasData && session.birthDetails != null) {
      lat = session.birthDetails!.latitude;
      lon = session.birthDetails!.longitude;
      tz = session.birthDetails!.timezoneOffset;
    }

    Map<String, dynamic>? panchang;
    try {
      panchang = PanchangService.getLocalPanchang(
        date: now,
        latitude: lat,
        longitude: lon,
        timezone: tz,
      );
    } catch (_) {}

    final varaLord =
        panchang?['varaLord']?.toString() ?? PanchangService.getVaraLord(now);
    final nakshatra = panchang?['nakshatra']?['name']?.toString() ?? '';
    final nakshatraLord = panchang?['nakshatra']?['lord']?.toString() ?? '';
    final tithiName = panchang?['tithi']?['name']?.toString() ?? '';
    final tithiPaksha = panchang?['tithi']?['paksha']?.toString() ?? '';
    final gamification = GamificationService();
    final streakDays = gamification.currentStreak;
    final isStreakAtRisk = gamification.isStreakAtRisk;

    final tasks = <DailyTask>[];

    // Task 1: Day Lord spiritual task
    tasks.add(_dayLordTask(varaLord));

    // Task 2: Nakshatra-based mindset task
    tasks.add(_nakshatraTask(nakshatra));

    // Task 3: Nakshatra Lord energy task
    tasks.add(_nakshatraLordTask(nakshatraLord, nakshatra));

    // Task 4: Tithi-based task
    tasks.add(_tithiTask(tithiName, tithiPaksha));

    // Task 5: Learning / streak task
    tasks.add(_learningTask(streakDays, isStreakAtRisk));

    // Task 6: Wellness task based on planetary energy
    tasks.add(_wellnessTask(varaLord));

    // Task 7: Social / reflection task
    tasks.add(_socialTask(varaLord, nakshatra));

    return tasks;
  }

  DailyTask _dayLordTask(String varaLord) {
    final dayTasks = {
      'Sun': DailyTask(
        id: 'day_lord',
        title: 'Shine Your Inner Light',
        description:
            'Sunday is ruled by Surya. Take a moment of self-reflection and set a clear intention for the week ahead.',
        icon: Icons.wb_sunny_rounded,
        color: const Color(0xFFff9500),
        category: 'spiritual',
      ),
      'Moon': DailyTask(
        id: 'day_lord',
        title: 'Nurture Your Mind',
        description:
            'Monday is ruled by Chandra. Practice mindfulness or connect emotionally with someone you care about.',
        icon: Icons.nightlight_round,
        color: const Color(0xFFc7c7cc),
        category: 'spiritual',
      ),
      'Mars': DailyTask(
        id: 'day_lord',
        title: 'Channel Your Energy',
        description:
            'Tuesday is ruled by Mangal. Do something physically active — exercise, walk, or tackle a bold task.',
        icon: Icons.fitness_center_rounded,
        color: const Color(0xFFff3b30),
        category: 'wellness',
      ),
      'Mercury': DailyTask(
        id: 'day_lord',
        title: 'Sharpen Your Intellect',
        description:
            'Wednesday is ruled by Budha. Read, write, or learn something new. Communication flows easily today.',
        icon: Icons.auto_stories_rounded,
        color: const Color(0xFF34c759),
        category: 'learning',
      ),
      'Jupiter': DailyTask(
        id: 'day_lord',
        title: 'Teach or Mentor',
        description:
            'Thursday is ruled by Guru. Share wisdom with someone or study a spiritual text. Generosity brings blessings.',
        icon: Icons.school_rounded,
        color: const Color(0xFFffcc00),
        category: 'spiritual',
      ),
      'Venus': DailyTask(
        id: 'day_lord',
        title: 'Embrace Beauty & Harmony',
        description:
            'Friday is ruled by Shukra. Appreciate art, music, or nature. Nurture your relationships.',
        icon: Icons.favorite_rounded,
        color: const Color(0xFFff2d55),
        category: 'social',
      ),
      'Saturn': DailyTask(
        id: 'day_lord',
        title: 'Practice Discipline',
        description:
            'Saturday is ruled by Shani. Focus on responsibilities and long-term goals. Patience is your superpower today.',
        icon: Icons.architecture_rounded,
        color: const Color(0xFF5856d6),
        category: 'spiritual',
      ),
    };

    return dayTasks[varaLord] ??
        DailyTask(
          id: 'day_lord',
          title: 'Set a Daily Intention',
          description: 'Take a quiet moment to set your intention for today.',
          icon: Icons.self_improvement_rounded,
          color: const Color(0xFFf5a623),
          category: 'spiritual',
        );
  }

  DailyTask _nakshatraTask(String nakshatra) {
    // Map Nakshatras to task categories
    final creativeNakshatras = [
      'Rohini',
      'Purva Phalguni',
      'Purva Ashadha',
      'Revati',
      'Bharani',
      'Chitra',
      'Swati',
    ];
    final actionNakshatras = [
      'Ashwini',
      'Mrigashira',
      'Pushya',
      'Hasta',
      'Anuradha',
      'Uttara Ashadha',
      'Dhanishtha',
    ];
    final reflectiveNakshatras = [
      'Krittika',
      'Ardra',
      'Ashlesha',
      'Magha',
      'Vishakha',
      'Jyeshtha',
      'Moola',
      'Shatabhisha',
    ];

    if (creativeNakshatras.any((n) => nakshatra.contains(n))) {
      return DailyTask(
        id: 'nakshatra',
        title: 'Express Creatively',
        description:
            '$nakshatra Nakshatra favors creative expression. Write, draw, sing, or work on a passion project today.',
        icon: Icons.palette_rounded,
        color: const Color(0xFFff6b9d),
        category: 'wellness',
      );
    } else if (actionNakshatras.any((n) => nakshatra.contains(n))) {
      return DailyTask(
        id: 'nakshatra',
        title: 'Take Bold Action',
        description:
            '$nakshatra Nakshatra supports initiative. Start something you\'ve been putting off or make a decisive move.',
        icon: Icons.rocket_launch_rounded,
        color: const Color(0xFF00d4ff),
        category: 'wellness',
      );
    } else if (reflectiveNakshatras.any((n) => nakshatra.contains(n))) {
      return DailyTask(
        id: 'nakshatra',
        title: 'Reflect & Introspect',
        description:
            '$nakshatra Nakshatra invites inner work. Journal your thoughts or meditate on what you want to transform.',
        icon: Icons.psychology_rounded,
        color: const Color(0xFF7B61FF),
        category: 'spiritual',
      );
    }

    return DailyTask(
      id: 'nakshatra',
      title: 'Align With the Stars',
      description:
          'Connect with today\'s cosmic energy. Spend a minute observing the sky or reading about your Nakshatra.',
      icon: Icons.stars_rounded,
      color: const Color(0xFFf5a623),
      category: 'spiritual',
    );
  }

  DailyTask _learningTask(int streak, bool isAtRisk) {
    if (isAtRisk && streak > 0) {
      return DailyTask(
        id: 'learning',
        title: 'Protect Your 🔥 $streak-Day Streak!',
        description:
            'Your streak is at risk! Complete any lesson in the roadmap to keep your momentum alive.',
        icon: Icons.local_fire_department_rounded,
        color: const Color(0xFFff9500),
        category: 'learning',
      );
    }

    if (streak >= 7) {
      return DailyTask(
        id: 'learning',
        title: 'Keep the $streak-Day Streak Going ⚡',
        description:
            'You\'re on a roll! Dive into your next chapter and earn XP to maintain your stellar streak.',
        icon: Icons.bolt_rounded,
        color: const Color(0xFFffcc00),
        category: 'learning',
      );
    }

    return DailyTask(
      id: 'learning',
      title: 'Learn Something Cosmic',
      description:
          'Open the roadmap and complete a lesson. Each step deepens your Jyotish understanding and earns XP.',
      icon: Icons.menu_book_rounded,
      color: const Color(0xFF34c759),
      category: 'learning',
    );
  }

  DailyTask _wellnessTask(String varaLord) {
    final wellnessTasks = {
      'Sun': DailyTask(
        id: 'wellness',
        title: 'Morning Sun Gratitude',
        description:
            'Step outside and greet the morning sun. A few minutes of natural light boosts vitality and Vitamin D.',
        icon: Icons.light_mode_rounded,
        color: const Color(0xFFff9500),
        category: 'wellness',
      ),
      'Moon': DailyTask(
        id: 'wellness',
        title: 'Hydrate & Rest Well',
        description:
            'Moon day favors water. Drink extra water today and aim for quality sleep tonight.',
        icon: Icons.water_drop_rounded,
        color: const Color(0xFF00d4ff),
        category: 'wellness',
      ),
      'Mars': DailyTask(
        id: 'wellness',
        title: '15-Minute Movement',
        description:
            'Mars energy demands physical release. Do 15 minutes of exercise, yoga, or a brisk walk.',
        icon: Icons.directions_run_rounded,
        color: const Color(0xFFff3b30),
        category: 'wellness',
      ),
      'Mercury': DailyTask(
        id: 'wellness',
        title: 'Brain Workout',
        description:
            'Mercury day sharpens the mind. Solve a puzzle, learn a new word, or practice mental arithmetic.',
        icon: Icons.psychology_alt_rounded,
        color: const Color(0xFF34c759),
        category: 'wellness',
      ),
      'Jupiter': DailyTask(
        id: 'wellness',
        title: 'Gratitude Practice',
        description:
            'Jupiter blesses abundance. Write down 3 things you\'re grateful for today.',
        icon: Icons.volunteer_activism_rounded,
        color: const Color(0xFFffcc00),
        category: 'wellness',
      ),
      'Venus': DailyTask(
        id: 'wellness',
        title: 'Self-Care Ritual',
        description:
            'Venus day favors beauty and comfort. Do something luxurious — a long bath, skincare, or your favorite meal.',
        icon: Icons.spa_rounded,
        color: const Color(0xFFff2d55),
        category: 'wellness',
      ),
      'Saturn': DailyTask(
        id: 'wellness',
        title: 'Digital Detox Hour',
        description:
            'Saturn rewards restraint. Spend one hour away from screens — read, walk, or simply sit in silence.',
        icon: Icons.phone_disabled_rounded,
        color: const Color(0xFF5856d6),
        category: 'wellness',
      ),
    };

    return wellnessTasks[varaLord] ??
        DailyTask(
          id: 'wellness',
          title: 'Mindful Breathing',
          description:
              'Take 5 deep breaths to center yourself. Inhale for 4 counts, hold for 4, exhale for 6.',
          icon: Icons.air_rounded,
          color: const Color(0xFF0d9488),
          category: 'wellness',
        );
  }

  DailyTask _socialTask(String varaLord, String nakshatra) {
    final socialTasks = {
      'Sun': DailyTask(
        id: 'social',
        title: 'Inspire Someone',
        description:
            'Share an uplifting thought or compliment with a friend or family member today.',
        icon: Icons.emoji_people_rounded,
        color: const Color(0xFFff9500),
        category: 'social',
      ),
      'Moon': DailyTask(
        id: 'social',
        title: 'Check On a Loved One',
        description:
            'Moon energy is about connection. Send a heartfelt message to someone you haven\'t spoken to recently.',
        icon: Icons.chat_bubble_rounded,
        color: const Color(0xFF00d4ff),
        category: 'social',
      ),
      'Mars': DailyTask(
        id: 'social',
        title: 'Stand Up for Something',
        description:
            'Mars gives courage. Speak up for what you believe in, or help someone who needs support.',
        icon: Icons.shield_rounded,
        color: const Color(0xFFff3b30),
        category: 'social',
      ),
      'Mercury': DailyTask(
        id: 'social',
        title: 'Share Knowledge',
        description:
            'Mercury loves exchange. Share an interesting fact or article with a friend today.',
        icon: Icons.share_rounded,
        color: const Color(0xFF34c759),
        category: 'social',
      ),
      'Jupiter': DailyTask(
        id: 'social',
        title: 'Be Generous',
        description:
            'Jupiter expands giving. Offer your time, advice, or a small gift to someone who could use it.',
        icon: Icons.card_giftcard_rounded,
        color: const Color(0xFFffcc00),
        category: 'social',
      ),
      'Venus': DailyTask(
        id: 'social',
        title: 'Express Appreciation',
        description:
            'Venus values relationships. Tell someone how much they mean to you — be specific and genuine.',
        icon: Icons.favorite_border_rounded,
        color: const Color(0xFFff2d55),
        category: 'social',
      ),
      'Saturn': DailyTask(
        id: 'social',
        title: 'Serve Quietly',
        description:
            'Saturn honors humble service. Do a kind act without seeking recognition today.',
        icon: Icons.handshake_rounded,
        color: const Color(0xFF5856d6),
        category: 'social',
      ),
    };

    return socialTasks[varaLord] ??
        DailyTask(
          id: 'social',
          title: 'Connect With Others',
          description:
              'Reach out to someone today. A simple conversation can brighten both your days.',
          icon: Icons.people_rounded,
          color: const Color(0xFF667eea),
          category: 'social',
        );
  }

  // ─── Nakshatra Lord Task ───

  DailyTask _nakshatraLordTask(String lord, String nakshatra) {
    final lordTasks = {
      'Ketu': DailyTask(
        id: 'nakshatra_lord',
        title: 'Let Go of One Attachment',
        description:
            '$nakshatra is ruled by Ketu — the liberator. Identify one thing you\'re clinging to and consciously release it today.',
        icon: Icons.air_rounded,
        color: const Color(0xFF9ca3af),
        category: 'spiritual',
      ),
      'Venus': DailyTask(
        id: 'nakshatra_lord',
        title: 'Appreciate Something Beautiful',
        description:
            '$nakshatra is ruled by Venus — planet of beauty. Visit art, listen to music, or adorn your space with something lovely.',
        icon: Icons.palette_rounded,
        color: const Color(0xFFff6b9d),
        category: 'wellness',
      ),
      'Sun': DailyTask(
        id: 'nakshatra_lord',
        title: 'Lead With Confidence',
        description:
            '$nakshatra is ruled by the Sun — planet of authority. Take initiative today, speak up, and own your decisions.',
        icon: Icons.wb_sunny_rounded,
        color: const Color(0xFFff9500),
        category: 'spiritual',
      ),
      'Moon': DailyTask(
        id: 'nakshatra_lord',
        title: 'Nurture Your Emotions',
        description:
            '$nakshatra is ruled by the Moon. Be gentle with yourself — rest, hydrate, and connect emotionally with a loved one.',
        icon: Icons.nightlight_round,
        color: const Color(0xFFc7c7cc),
        category: 'wellness',
      ),
      'Mars': DailyTask(
        id: 'nakshatra_lord',
        title: 'Tackle a Challenge Head-On',
        description:
            '$nakshatra is ruled by Mars — planet of action. Take on the hardest task first and channel your warrior energy.',
        icon: Icons.fitness_center_rounded,
        color: const Color(0xFFff3b30),
        category: 'wellness',
      ),
      'Rahu': DailyTask(
        id: 'nakshatra_lord',
        title: 'Explore the Unconventional',
        description:
            '$nakshatra is ruled by Rahu — the innovator. Try something outside your comfort zone or explore a new perspective today.',
        icon: Icons.explore_rounded,
        color: const Color(0xFF667eea),
        category: 'learning',
      ),
      'Jupiter': DailyTask(
        id: 'nakshatra_lord',
        title: 'Expand Your Knowledge',
        description:
            '$nakshatra is ruled by Jupiter — the guru. Read a scripture, take a mini-course, or share wisdom with someone today.',
        icon: Icons.school_rounded,
        color: const Color(0xFFffcc00),
        category: 'learning',
      ),
      'Saturn': DailyTask(
        id: 'nakshatra_lord',
        title: 'Practice Patient Discipline',
        description:
            '$nakshatra is ruled by Saturn — the taskmaster. Focus on a long-term goal — slow, steady progress wins the race.',
        icon: Icons.architecture_rounded,
        color: const Color(0xFF5856d6),
        category: 'spiritual',
      ),
      'Mercury': DailyTask(
        id: 'nakshatra_lord',
        title: 'Sharpen Your Communication',
        description:
            '$nakshatra is ruled by Mercury — the communicator. Write clearly, speak mindfully, or learn something analytical today.',
        icon: Icons.chat_rounded,
        color: const Color(0xFF34c759),
        category: 'learning',
      ),
    };

    return lordTasks[lord] ??
        DailyTask(
          id: 'nakshatra_lord',
          title: 'Tune Into Cosmic Energy',
          description:
              'Today\'s Nakshatra carries unique energy. Take a moment to observe how you feel and align your actions.',
          icon: Icons.auto_awesome_rounded,
          color: const Color(0xFFf5a623),
          category: 'spiritual',
        );
  }

  // ─── Tithi Task ───

  DailyTask _tithiTask(String tithiName, String paksha) {
    final pakshaLabel = paksha.contains('Shukla') ? 'Waxing' : 'Waning';

    // Special tithis get unique tasks
    switch (tithiName) {
      case 'Purnima':
        return DailyTask(
          id: 'tithi',
          title: 'Full Moon Celebration 🌕',
          description:
              'Purnima — the full moon! Emotions and intuition peak today. Meditate, express gratitude, or perform a small puja.',
          icon: Icons.brightness_7_rounded,
          color: const Color(0xFFffd700),
          category: 'spiritual',
        );
      case 'Amavasya':
        return DailyTask(
          id: 'tithi',
          title: 'New Moon Introspection 🌑',
          description:
              'Amavasya — the new moon. Turn inward today. Journal, rest, and prepare seeds of intention for the next cycle.',
          icon: Icons.dark_mode_rounded,
          color: const Color(0xFF4a4a6a),
          category: 'spiritual',
        );
      case 'Ekadashi':
        return DailyTask(
          id: 'tithi',
          title: 'Ekadashi Discipline 🙏',
          description:
              'Ekadashi is sacred for fasting and devotion. Practice restraint — skip a meal, avoid screen time, or read a spiritual text.',
          icon: Icons.self_improvement_rounded,
          color: const Color(0xFF7B61FF),
          category: 'spiritual',
        );
      case 'Chaturthi':
        return DailyTask(
          id: 'tithi',
          title: 'Honor Lord Ganesha 🙏',
          description:
              'Chaturthi is Ganesha\'s day. Remove an obstacle in your life — organize, clean, or forgive a grudge.',
          icon: Icons.auto_awesome_rounded,
          color: const Color(0xFFff9500),
          category: 'spiritual',
        );
      case 'Navami':
        return DailyTask(
          id: 'tithi',
          title: 'Channel Warrior Spirit ⚔️',
          description:
              'Navami carries Mars energy. Be courageous today — assert boundaries, tackle difficult conversations, or start a bold project.',
          icon: Icons.shield_rounded,
          color: const Color(0xFFff3b30),
          category: 'wellness',
        );
    }

    // Paksha-based tasks for other tithis
    if (paksha.contains('Shukla')) {
      return DailyTask(
        id: 'tithi',
        title: '$tithiName — Grow & Build ($pakshaLabel)',
        description:
            'The $pakshaLabel moon phase favors new beginnings and growth. Start something, plant a seed, or expand an existing project.',
        icon: Icons.trending_up_rounded,
        color: const Color(0xFF34c759),
        category: 'wellness',
      );
    }

    return DailyTask(
      id: 'tithi',
      title: '$tithiName — Release & Simplify ($pakshaLabel)',
      description:
          'The $pakshaLabel moon phase supports letting go. Declutter, finish pending work, or release what no longer serves you.',
      icon: Icons.trending_down_rounded,
      color: const Color(0xFF8e8e93),
      category: 'wellness',
    );
  }
}
