/// Cosmic Pet — Data Models
///
/// All models for the Cosmic Pet system:
/// Temperament, SWOT, Vitality, Alignment, Mood, Evolution, Micro-Actions.

// ════════════════════════════════════════════════════════════
// ENUMS
// ════════════════════════════════════════════════════════════

/// Pet mood states (visual + gameplay effect)
enum PetMood {
  energized, // High alignment → bright aura, bonus XP
  calm, // Normal → neutral colors
  focused, // Active task → sharp animations
  playful, // Creative day → bouncy idle
  reflective, // Retrograde/combust → meditative
  fatigued, // Low alignment → slower movement, reduced buffs
  dormant, // Repeated neglect → resting posture, abilities locked
  reviving, // Recovery action taken → light pulse animation
}

extension PetMoodExt on PetMood {
  String get label {
    switch (this) {
      case PetMood.energized:
        return 'Energized';
      case PetMood.calm:
        return 'Calm';
      case PetMood.focused:
        return 'Focused';
      case PetMood.playful:
        return 'Playful';
      case PetMood.reflective:
        return 'Reflective';
      case PetMood.fatigued:
        return 'Fatigued';
      case PetMood.dormant:
        return 'Dormant';
      case PetMood.reviving:
        return 'Reviving';
    }
  }

  String get emoji {
    switch (this) {
      case PetMood.energized:
        return '✨';
      case PetMood.calm:
        return '🌙';
      case PetMood.focused:
        return '🎯';
      case PetMood.playful:
        return '🎨';
      case PetMood.reflective:
        return '🪷';
      case PetMood.fatigued:
        return '😴';
      case PetMood.dormant:
        return '💤';
      case PetMood.reviving:
        return '🌅';
    }
  }

  String get description {
    switch (this) {
      case PetMood.energized:
        return 'Your pet is glowing with cosmic energy!';
      case PetMood.calm:
        return 'Your pet is at peace with the day\'s flow.';
      case PetMood.focused:
        return 'Your pet is locked in — sharp and determined.';
      case PetMood.playful:
        return 'Your pet feels creative and light today.';
      case PetMood.reflective:
        return 'Your pet invites quiet introspection.';
      case PetMood.fatigued:
        return 'Your pet feels low-energy. A small action could help.';
      case PetMood.dormant:
        return 'Your pet is resting deeply. One gentle step to revive.';
      case PetMood.reviving:
        return 'Your pet is slowly regaining strength!';
    }
  }
}

/// Evolution stages (unlocked by level)
enum EvolutionStage {
  hatchling, // Level 1-5
  explorer, // Level 6-15
  guide, // Level 16-30
  mentor, // Level 31+
}

extension EvolutionStageExt on EvolutionStage {
  String get label {
    switch (this) {
      case EvolutionStage.hatchling:
        return 'Hatchling';
      case EvolutionStage.explorer:
        return 'Explorer';
      case EvolutionStage.guide:
        return 'Guide';
      case EvolutionStage.mentor:
        return 'Mentor';
    }
  }

  String get emoji {
    switch (this) {
      case EvolutionStage.hatchling:
        return '🥚';
      case EvolutionStage.explorer:
        return '🌟';
      case EvolutionStage.guide:
        return '🔮';
      case EvolutionStage.mentor:
        return '👑';
    }
  }

  String get description {
    switch (this) {
      case EvolutionStage.hatchling:
        return 'A newborn cosmic companion, curious about the world.';
      case EvolutionStage.explorer:
        return 'Growing bolder, venturing into new territories.';
      case EvolutionStage.guide:
        return 'Wise enough to lead and illuminate the path.';
      case EvolutionStage.mentor:
        return 'A master of cosmic energies, radiating wisdom.';
    }
  }

  /// Level range for this stage
  String get levelRange {
    switch (this) {
      case EvolutionStage.hatchling:
        return 'Lv 1–5';
      case EvolutionStage.explorer:
        return 'Lv 6–15';
      case EvolutionStage.guide:
        return 'Lv 16–30';
      case EvolutionStage.mentor:
        return 'Lv 31+';
    }
  }

  static EvolutionStage fromLevel(int level) {
    if (level >= 31) return EvolutionStage.mentor;
    if (level >= 16) return EvolutionStage.guide;
    if (level >= 6) return EvolutionStage.explorer;
    return EvolutionStage.hatchling;
  }
}

// ════════════════════════════════════════════════════════════
// TEMPERAMENT (from Lagna)
// ════════════════════════════════════════════════════════════

/// Lagna-based immutable baseline temperament
class PetTemperament {
  final String name;
  final String coreTraits;
  final String petEmoji;
  final String element;

  const PetTemperament({
    required this.name,
    required this.coreTraits,
    required this.petEmoji,
    required this.element,
  });

  /// 12 Lagna → Temperament mappings
  static const Map<String, PetTemperament> lagnaMap = {
    'Aries': PetTemperament(
      name: 'Energetic Scout',
      coreTraits: 'Bold, quick-start',
      petEmoji: '🐉',
      element: 'Fire',
    ),
    'Taurus': PetTemperament(
      name: 'Grounded Gardener',
      coreTraits: 'Steady, patient',
      petEmoji: '🦌',
      element: 'Earth',
    ),
    'Gemini': PetTemperament(
      name: 'Curious Spark',
      coreTraits: 'Communicative, agile',
      petEmoji: '🦅',
      element: 'Air',
    ),
    'Cancer': PetTemperament(
      name: 'Nurturing Tide',
      coreTraits: 'Caring, reflective',
      petEmoji: '🐍',
      element: 'Water',
    ),
    'Leo': PetTemperament(
      name: 'Radiant Leader',
      coreTraits: 'Confident, expressive',
      petEmoji: '🦁',
      element: 'Fire',
    ),
    'Virgo': PetTemperament(
      name: 'Thoughtful Analyst',
      coreTraits: 'Organized, precise',
      petEmoji: '🦉',
      element: 'Earth',
    ),
    'Libra': PetTemperament(
      name: 'Harmonizer',
      coreTraits: 'Diplomatic, fair',
      petEmoji: '🦋',
      element: 'Air',
    ),
    'Scorpio': PetTemperament(
      name: 'Deep Diver',
      coreTraits: 'Intense, transformative',
      petEmoji: '🦂',
      element: 'Water',
    ),
    'Sagittarius': PetTemperament(
      name: 'Explorer',
      coreTraits: 'Optimistic, growth-seeking',
      petEmoji: '🦄',
      element: 'Fire',
    ),
    'Capricorn': PetTemperament(
      name: 'Strategist',
      coreTraits: 'Disciplined, goal-driven',
      petEmoji: '🐺',
      element: 'Earth',
    ),
    'Aquarius': PetTemperament(
      name: 'Innovator',
      coreTraits: 'Original, community-minded',
      petEmoji: '🦊',
      element: 'Air',
    ),
    'Pisces': PetTemperament(
      name: 'Dream Weaver',
      coreTraits: 'Empathic, imaginative',
      petEmoji: '🐬',
      element: 'Water',
    ),
  };

  static PetTemperament fromLagna(String lagna) {
    return lagnaMap[lagna] ??
        const PetTemperament(
          name: 'Cosmic Wanderer',
          coreTraits: 'Mysterious, adaptive',
          petEmoji: '✨',
          element: 'Ether',
        );
  }
}

// ════════════════════════════════════════════════════════════
// HOUSE BEHAVIORAL THEMES
// ════════════════════════════════════════════════════════════

/// Planet-in-house → behavioral nudge for the day
class HouseBehavior {
  final int house;
  final String theme;
  final String nudge;
  final String emoji;

  const HouseBehavior({
    required this.house,
    required this.theme,
    required this.nudge,
    required this.emoji,
  });

  static const List<HouseBehavior> all = [
    HouseBehavior(
        house: 1,
        theme: 'Identity',
        nudge: 'Pet mirrors confidence & self-care',
        emoji: '🪞'),
    HouseBehavior(
        house: 2,
        theme: 'Values',
        nudge: 'Pet nudges budgeting & voice',
        emoji: '💎'),
    HouseBehavior(
        house: 3,
        theme: 'Communication',
        nudge: 'Pet promotes writing & learning',
        emoji: '✍️'),
    HouseBehavior(
        house: 4,
        theme: 'Home',
        nudge: 'Pet suggests grounding rituals',
        emoji: '🏠'),
    HouseBehavior(
        house: 5,
        theme: 'Creativity',
        nudge: 'Pet invites play & creation',
        emoji: '🎨'),
    HouseBehavior(
        house: 6,
        theme: 'Habits',
        nudge: 'Pet encourages micro-habits',
        emoji: '💪'),
    HouseBehavior(
        house: 7,
        theme: 'Relationships',
        nudge: 'Pet prompts empathy',
        emoji: '🤝'),
    HouseBehavior(
        house: 8,
        theme: 'Transformation',
        nudge: 'Pet supports letting go',
        emoji: '🔥'),
    HouseBehavior(
        house: 9,
        theme: 'Meaning',
        nudge: 'Pet offers reflection & learning',
        emoji: '📚'),
    HouseBehavior(
        house: 10, theme: 'Career', nudge: 'Pet nudges planning', emoji: '🎯'),
    HouseBehavior(
        house: 11,
        theme: 'Community',
        nudge: 'Pet suggests reach-outs',
        emoji: '🌐'),
    HouseBehavior(
        house: 12,
        theme: 'Rest',
        nudge: 'Pet invites rest & spirituality',
        emoji: '🧘'),
  ];

  static HouseBehavior forHouse(int house) {
    final idx = (house - 1).clamp(0, 11);
    return all[idx];
  }
}

// ════════════════════════════════════════════════════════════
// DAILY SWOT
// ════════════════════════════════════════════════════════════

/// A single SWOT item with its Panchang source
class SWOTItem {
  final String text;
  final String source; // e.g. "Tithi: Ekadashi", "Nakshatra: Pushya"
  final String sourceEmoji;

  const SWOTItem({
    required this.text,
    required this.source,
    required this.sourceEmoji,
  });
}

/// Daily SWOT analysis from Panchang
class DailySWOT {
  final List<SWOTItem> strengths;
  final List<SWOTItem> weaknesses;
  final List<SWOTItem> opportunities;
  final List<SWOTItem> threats;
  final DateTime date;

  const DailySWOT({
    required this.strengths,
    required this.weaknesses,
    required this.opportunities,
    required this.threats,
    required this.date,
  });
}

// ════════════════════════════════════════════════════════════
// MICRO-ACTIONS
// ════════════════════════════════════════════════════════════

/// Small, Panchang-aligned daily task (5-10 min)
class MicroAction {
  final String id;
  final String title;
  final String description;
  final String source; // Panchang factor that suggested this
  final int xpReward;
  final bool isCompleted;

  const MicroAction({
    required this.id,
    required this.title,
    required this.description,
    required this.source,
    this.xpReward = 10,
    this.isCompleted = false,
  });

  MicroAction copyWith({bool? isCompleted}) {
    return MicroAction(
      id: id,
      title: title,
      description: description,
      source: source,
      xpReward: xpReward,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

// ════════════════════════════════════════════════════════════
// PET VITALITY & ALIGNMENT
// ════════════════════════════════════════════════════════════

/// Daily alignment score tracking
class DailyAlignment {
  final int score; // 0-100
  final List<String> completedActions;
  final List<String> avoidedThreats;
  final bool checkedIn;
  final bool reflected;
  final DateTime date;

  const DailyAlignment({
    required this.score,
    this.completedActions = const [],
    this.avoidedThreats = const [],
    this.checkedIn = false,
    this.reflected = false,
    required this.date,
  });

  /// Calculate score from components
  static int calculateScore({
    required int actionsCompleted,
    required bool checkedIn,
    required bool reflected,
  }) {
    int score = 0;
    if (actionsCompleted >= 1) score += 40;
    if (actionsCompleted >= 2) score += 20;
    if (checkedIn) score += 20;
    if (reflected) score += 20;
    return score.clamp(0, 100);
  }
}

/// Pet vitality state
class PetVitality {
  final int vitality; // 0-100
  final PetMood mood;
  final List<String> lockedAbilities;
  final DateTime? lastRecovery;
  final int consecutiveLowDays; // Days with alignment < 30

  const PetVitality({
    this.vitality = 70,
    this.mood = PetMood.calm,
    this.lockedAbilities = const [],
    this.lastRecovery,
    this.consecutiveLowDays = 0,
  });

  /// Determine mood from alignment score
  static PetMood moodFromAlignment(int alignmentScore, int vitality) {
    if (vitality <= 19) return PetMood.dormant;
    if (vitality <= 49) return PetMood.fatigued;
    if (alignmentScore >= 80) return PetMood.energized;
    if (alignmentScore >= 50) return PetMood.calm;
    return PetMood.fatigued;
  }
}

// ════════════════════════════════════════════════════════════
// COSMIC PET (composite)
// ════════════════════════════════════════════════════════════

/// The full Cosmic Pet profile
class CosmicPet {
  final String name;
  final PetTemperament temperament;
  final List<HouseBehavior> activeHouseThemes; // Houses with planets
  final String planetaryTone; // encouraging / grounding / reflective
  final String toneExplanation;
  final PetVitality vitality;
  final EvolutionStage evolutionStage;
  final int level;
  final int totalXP;
  final DailySWOT? todaySWOT;
  final List<MicroAction> todayActions;

  const CosmicPet({
    required this.name,
    required this.temperament,
    this.activeHouseThemes = const [],
    this.planetaryTone = 'balanced',
    this.toneExplanation = '',
    this.vitality = const PetVitality(),
    this.evolutionStage = EvolutionStage.hatchling,
    this.level = 1,
    this.totalXP = 0,
    this.todaySWOT,
    this.todayActions = const [],
  });
}

// ════════════════════════════════════════════════════════════
// "WHY TODAY" EXPLAINABILITY
// ════════════════════════════════════════════════════════════

/// Single explainability cue
class WhyTodayCue {
  final String factor; // e.g. "Lagna", "Moon in 4th House", "Tithi"
  final String effect; // e.g. "Your pet feels nurturing today"
  final String emoji;

  const WhyTodayCue({
    required this.factor,
    required this.effect,
    required this.emoji,
  });
}
