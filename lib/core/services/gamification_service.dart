import 'package:shared_preferences/shared_preferences.dart';
import '../constants/learning_roadmap.dart';
import '../models/gamification_models.dart';

/// Service for tracking XP, streaks, abilities, and learning progress.
/// Uses SharedPreferences for lightweight persistence.
class GamificationService {
  static final GamificationService _instance = GamificationService._();
  factory GamificationService() => _instance;
  GamificationService._();

  SharedPreferences? _prefs;

  // SharedPreferences keys
  static const _keyTotalXP = 'gamification_total_xp';
  static const _keyCurrentStreak = 'gamification_streak';
  static const _keyLastActivityDate = 'gamification_last_activity';
  static const _keyUnlockedAbilities = 'gamification_unlocked_abilities';
  static const _keyCompletedChapters = 'gamification_completed_chapters';
  static const _keyCompletedLessons = 'gamification_completed_lessons';

  /// Initialize — call once at app start
  Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // ─── XP ───

  int get totalXP => _prefs?.getInt(_keyTotalXP) ?? 0;

  int get currentLevel {
    int xp = totalXP;
    int level = 1;
    int threshold = 200;
    while (xp >= threshold) {
      xp -= threshold;
      level++;
      threshold += 100;
    }
    return level;
  }

  Future<void> addXP(int amount) async {
    await _prefs?.setInt(_keyTotalXP, totalXP + amount);
  }

  /// XP earned within the current level
  int get xpInCurrentLevel {
    int xp = totalXP;
    int threshold = 200;
    while (xp >= threshold) {
      xp -= threshold;
      threshold += 100;
    }
    return xp;
  }

  /// XP needed to reach the next level
  int get xpForNextLevel {
    int xp = totalXP;
    int threshold = 200;
    while (xp >= threshold) {
      xp -= threshold;
      threshold += 100;
    }
    return threshold;
  }

  // ─── Streak ───

  int get currentStreak => _prefs?.getInt(_keyCurrentStreak) ?? 0;

  DateTime? get lastActivityDate {
    final ms = _prefs?.getInt(_keyLastActivityDate);
    return ms != null ? DateTime.fromMillisecondsSinceEpoch(ms) : null;
  }

  /// Call when user completes any learning activity
  Future<void> recordActivity() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final last = lastActivityDate;

    if (last != null) {
      final lastDay = DateTime(last.year, last.month, last.day);
      final diff = today.difference(lastDay).inDays;

      if (diff == 1) {
        // Consecutive day — increment streak
        await _prefs?.setInt(_keyCurrentStreak, currentStreak + 1);
      } else if (diff > 1) {
        // Missed a day — reset streak to 1
        await _prefs?.setInt(_keyCurrentStreak, 1);
      }
      // diff == 0 means same day — no change
    } else {
      // First ever activity
      await _prefs?.setInt(_keyCurrentStreak, 1);
    }

    await _prefs?.setInt(_keyLastActivityDate, now.millisecondsSinceEpoch);
  }

  bool get isStreakAtRisk {
    final last = lastActivityDate;
    if (last == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastDay = DateTime(last.year, last.month, last.day);
    return today.difference(lastDay).inDays >= 1;
  }

  // ─── Completed Chapters ───

  List<String> get completedChapters =>
      _prefs?.getStringList(_keyCompletedChapters) ?? [];

  Future<void> completeChapter(String chapterId) async {
    final chapters = completedChapters;
    if (!chapters.contains(chapterId)) {
      chapters.add(chapterId);
      await _prefs?.setStringList(_keyCompletedChapters, chapters);

      // Check for ability unlock
      final ability = AbilityRegistry.getAbilityForChapter(chapterId);
      if (ability != null) {
        await unlockAbility(ability.id);
      }
    }
  }

  int get completedChapterCount => completedChapters.length;

  // ─── Completed Lessons ───

  List<String> get completedLessons =>
      _prefs?.getStringList(_keyCompletedLessons) ?? [];

  Future<void> completeLesson(String lessonId) async {
    final lessons = completedLessons;
    if (!lessons.contains(lessonId)) {
      lessons.add(lessonId);
      await _prefs?.setStringList(_keyCompletedLessons, lessons);
    }
  }

  // ─── Abilities ───

  List<String> get unlockedAbilities =>
      _prefs?.getStringList(_keyUnlockedAbilities) ?? [];

  bool hasAbility(String abilityId) => unlockedAbilities.contains(abilityId);

  Future<void> unlockAbility(String abilityId) async {
    final abilities = unlockedAbilities;
    if (!abilities.contains(abilityId)) {
      abilities.add(abilityId);
      await _prefs?.setStringList(_keyUnlockedAbilities, abilities);
    }
  }

  /// Find the nearest ability the user can unlock next
  Ability? get nearestUnlockableAbility {
    final unlocked = unlockedAbilities;
    final completed = completedChapters;

    for (final ability in AbilityRegistry.coreAbilities) {
      if (unlocked.contains(ability.id)) continue; // Already unlocked

      // Check if prerequisites of the unlock chapter are mostly done
      final chapter = LearningRoadmap.getChapterById(ability.unlockChapterId);
      if (chapter == null) continue;

      // If the chapter is not yet completed but could be next
      if (!completed.contains(ability.unlockChapterId)) {
        return ability;
      }
    }
    return null;
  }

  // ─── Full Progress Snapshot ───

  UserProgress getProgress() {
    return UserProgress(
      totalXP: totalXP,
      currentLevel: currentLevel,
      chapterProgress: {},
      unlockedBadges: [],
      completedAchievements: [],
      lastActivityDate: lastActivityDate ?? DateTime.now(),
      currentStreak: currentStreak,
      unlockedAbilities: unlockedAbilities,
    );
  }
}
