/// Pet State Service
///
/// Manages persistent pet state:
/// - Vitality (0-100)
/// - Mood (energized/calm/focused/playful/reflective/fatigued/dormant/reviving)
/// - Daily Alignment Score (0-100)
/// - XP & Levels (integrates with GamificationService)
/// - Evolution stage tracking
/// - Consecutive low-day tracking for decay
/// - Recovery mechanics
///
/// Persists via SharedPreferences (lightweight, no Hive dependency).

import 'package:shared_preferences/shared_preferences.dart';
import '../models/cosmic_pet_models.dart';
import 'gamification_service.dart';

class PetStateService {
  static final PetStateService _instance = PetStateService._();
  factory PetStateService() => _instance;
  PetStateService._();

  SharedPreferences? _prefs;

  // SharedPreferences keys
  static const _keyVitality = 'pet_vitality';
  static const _keyMood = 'pet_mood';
  static const _keyConsecutiveLowDays = 'pet_consecutive_low_days';
  static const _keyLastAlignmentDate = 'pet_last_alignment_date';
  static const _keyLastAlignmentScore = 'pet_last_alignment_score';
  static const _keyLockedAbilities = 'pet_locked_abilities';
  static const _keyLastRecoveryMs = 'pet_last_recovery_ms';
  static const _keyCheckedInToday = 'pet_checked_in_today';
  static const _keyCheckedInDate = 'pet_checked_in_date';
  static const _keyCompletedActionsToday = 'pet_completed_actions_today';
  static const _keyReflectedToday = 'pet_reflected_today';
  static const _keyTotalPetXP = 'pet_total_xp';
  static const _keyPetLevel = 'pet_level';

  /// Initialize — call once at app start
  Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
    await _checkDayRollover();
  }

  // ════════════════════════════════════════════════════════════
  // VITALITY
  // ════════════════════════════════════════════════════════════

  int get vitality => _prefs?.getInt(_keyVitality) ?? 70;

  Future<void> _setVitality(int value) async {
    await _prefs?.setInt(_keyVitality, value.clamp(0, 100));
  }

  /// Get current PetVitality state
  PetVitality get currentVitality {
    return PetVitality(
      vitality: vitality,
      mood: currentMood,
      lockedAbilities: lockedAbilities,
      lastRecovery: lastRecovery,
      consecutiveLowDays: consecutiveLowDays,
    );
  }

  // ════════════════════════════════════════════════════════════
  // MOOD
  // ════════════════════════════════════════════════════════════

  PetMood get currentMood {
    final idx = _prefs?.getInt(_keyMood) ?? PetMood.calm.index;
    return PetMood.values[idx.clamp(0, PetMood.values.length - 1)];
  }

  Future<void> _setMood(PetMood mood) async {
    await _prefs?.setInt(_keyMood, mood.index);
  }

  /// Update mood based on current alignment and vitality
  Future<void> _recalculateMood() async {
    final mood = PetVitality.moodFromAlignment(lastAlignmentScore, vitality);
    await _setMood(mood);
  }

  // ════════════════════════════════════════════════════════════
  // DAILY ALIGNMENT
  // ════════════════════════════════════════════════════════════

  int get lastAlignmentScore => _prefs?.getInt(_keyLastAlignmentScore) ?? 0;
  int get consecutiveLowDays => _prefs?.getInt(_keyConsecutiveLowDays) ?? 0;
  bool get hasCheckedInToday => _isToday(_keyCheckedInDate);

  int get completedActionsToday =>
      _prefs?.getInt(_keyCompletedActionsToday) ?? 0;

  bool get hasReflectedToday => _prefs?.getBool(_keyReflectedToday) ?? false;

  /// Calculate current alignment score
  int get currentAlignmentScore {
    return DailyAlignment.calculateScore(
      actionsCompleted: completedActionsToday,
      checkedIn: hasCheckedInToday,
      reflected: hasReflectedToday,
    );
  }

  /// Record a daily check-in
  Future<void> checkIn() async {
    final today = _todayString();
    await _prefs?.setBool(_keyCheckedInToday, true);
    await _prefs?.setString(_keyCheckedInDate, today);
    await _updateAlignmentScore();
  }

  /// Record a micro-action completion
  Future<void> completeAction(String actionId) async {
    final count = completedActionsToday + 1;
    await _prefs?.setInt(_keyCompletedActionsToday, count);
    await _addPetXP(15); // XP for completing an action
    await _updateAlignmentScore();
  }

  /// Record a reflection
  Future<void> recordReflection() async {
    await _prefs?.setBool(_keyReflectedToday, true);
    await _addPetXP(10); // XP for reflection
    await _updateAlignmentScore();
  }

  /// Update alignment score and apply effects
  Future<void> _updateAlignmentScore() async {
    final score = currentAlignmentScore;
    await _prefs?.setInt(_keyLastAlignmentScore, score);
    await _prefs?.setString(_keyLastAlignmentDate, _todayString());

    // Update vitality based on alignment
    if (score >= 80) {
      await _setVitality((vitality + 10).clamp(0, 100));
    } else if (score >= 50) {
      await _setVitality((vitality + 5).clamp(0, 100));
    }

    // Reset consecutive low days if alignment is decent
    if (score >= 30) {
      await _prefs?.setInt(_keyConsecutiveLowDays, 0);
    }

    await _recalculateMood();
  }

  // ════════════════════════════════════════════════════════════
  // RECOVERY
  // ════════════════════════════════════════════════════════════

  DateTime? get lastRecovery {
    final ms = _prefs?.getInt(_keyLastRecoveryMs);
    return ms != null ? DateTime.fromMillisecondsSinceEpoch(ms) : null;
  }

  List<String> get lockedAbilities =>
      _prefs?.getStringList(_keyLockedAbilities) ?? [];

  /// Perform recovery action — instantly boosts vitality
  Future<void> performRecovery() async {
    await _setVitality((vitality + 30).clamp(0, 100));
    await _prefs?.setInt(
        _keyLastRecoveryMs, DateTime.now().millisecondsSinceEpoch);

    // Unlock one ability if locked
    final locked = lockedAbilities;
    if (locked.isNotEmpty) {
      locked.removeLast();
      await _prefs?.setStringList(_keyLockedAbilities, locked);
    }

    await _setMood(PetMood.reviving);
    await _addPetXP(5);
  }

  // ════════════════════════════════════════════════════════════
  // XP & LEVELS
  // ════════════════════════════════════════════════════════════

  int get petXP => _prefs?.getInt(_keyTotalPetXP) ?? 0;
  int get petLevel => _prefs?.getInt(_keyPetLevel) ?? 1;

  EvolutionStage get evolutionStage => EvolutionStageExt.fromLevel(petLevel);

  Future<void> _addPetXP(int amount) async {
    final newXP = petXP + amount;
    await _prefs?.setInt(_keyTotalPetXP, newXP);

    // Also add to global gamification XP
    GamificationService().addXP(amount);

    // Check level up
    await _checkLevelUp(newXP);
  }

  Future<void> _checkLevelUp(int totalXP) async {
    int level = 1;
    int threshold = 100;
    int remaining = totalXP;
    while (remaining >= threshold) {
      remaining -= threshold;
      level++;
      threshold += 50; // Each level needs 50 more XP
    }
    await _prefs?.setInt(_keyPetLevel, level);
  }

  /// XP needed for next level
  int get xpForNextLevel {
    int threshold = 100;
    for (int i = 1; i < petLevel; i++) {
      threshold += 50;
    }
    return threshold;
  }

  /// XP progress in current level (0.0 to 1.0)
  double get levelProgress {
    int totalForPreviousLevels = 0;
    int threshold = 100;
    for (int i = 1; i < petLevel; i++) {
      totalForPreviousLevels += threshold;
      threshold += 50;
    }
    final xpInCurrentLevel = petXP - totalForPreviousLevels;
    return (xpInCurrentLevel / threshold).clamp(0.0, 1.0);
  }

  // ════════════════════════════════════════════════════════════
  // DAY ROLLOVER & DECAY
  // ════════════════════════════════════════════════════════════

  /// Check if a new day has started and apply decay if needed
  Future<void> _checkDayRollover() async {
    final lastDate = _prefs?.getString(_keyLastAlignmentDate);
    final today = _todayString();

    if (lastDate != null && lastDate != today) {
      // New day — check if previous day had low alignment
      final prevScore = lastAlignmentScore;

      if (prevScore < 30) {
        // Low alignment — increment consecutive low days
        final lowDays = consecutiveLowDays + 1;
        await _prefs?.setInt(_keyConsecutiveLowDays, lowDays);

        // Apply vitality decay
        if (lowDays >= 2) {
          await _setVitality((vitality - 20).clamp(0, 100));
          // Lock an ability
          final locked = lockedAbilities;
          if (locked.length < 3) {
            locked.add('ability_${locked.length}');
            await _prefs?.setStringList(_keyLockedAbilities, locked);
          }
        } else {
          await _setVitality((vitality - 5).clamp(0, 100));
        }
      }

      // Reset daily trackers
      await _prefs?.setInt(_keyCompletedActionsToday, 0);
      await _prefs?.setBool(_keyCheckedInToday, false);
      await _prefs?.setBool(_keyReflectedToday, false);
      await _prefs?.setInt(_keyLastAlignmentScore, 0);

      await _recalculateMood();
    }
  }

  // ════════════════════════════════════════════════════════════
  // HELPERS
  // ════════════════════════════════════════════════════════════

  String _todayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  bool _isToday(String key) {
    final stored = _prefs?.getString(key);
    return stored == _todayString();
  }

  /// Reset all pet state (for testing)
  Future<void> reset() async {
    await _prefs?.remove(_keyVitality);
    await _prefs?.remove(_keyMood);
    await _prefs?.remove(_keyConsecutiveLowDays);
    await _prefs?.remove(_keyLastAlignmentDate);
    await _prefs?.remove(_keyLastAlignmentScore);
    await _prefs?.remove(_keyLockedAbilities);
    await _prefs?.remove(_keyLastRecoveryMs);
    await _prefs?.remove(_keyCheckedInToday);
    await _prefs?.remove(_keyCheckedInDate);
    await _prefs?.remove(_keyCompletedActionsToday);
    await _prefs?.remove(_keyReflectedToday);
    await _prefs?.remove(_keyTotalPetXP);
    await _prefs?.remove(_keyPetLevel);
  }
}
