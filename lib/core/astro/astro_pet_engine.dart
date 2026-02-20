/// Astro Pet RPG Engine
///
/// Generates unique RPG-style pets from birth charts.
/// Pet species, stats, abilities, and personality are all derived
/// from planetary positions and dignity.

import 'kundali_engine.dart';

// ════════════════════════════════════════════════════════════
// MODELS
// ════════════════════════════════════════════════════════════

/// The pet species, determined by the Ascendant element
enum PetSpecies {
  cosmicDragon, // Fire (Aries, Leo, Sagittarius)
  crystalStag, // Earth (Taurus, Virgo, Capricorn)
  stormPhoenix, // Air  (Gemini, Libra, Aquarius)
  mysticSerpent, // Water (Cancer, Scorpio, Pisces)
}

extension PetSpeciesExt on PetSpecies {
  String get displayName {
    switch (this) {
      case PetSpecies.cosmicDragon:
        return 'Cosmic Dragon';
      case PetSpecies.crystalStag:
        return 'Crystal Stag';
      case PetSpecies.stormPhoenix:
        return 'Storm Phoenix';
      case PetSpecies.mysticSerpent:
        return 'Mystic Serpent';
    }
  }

  String get emoji {
    switch (this) {
      case PetSpecies.cosmicDragon:
        return '🐉';
      case PetSpecies.crystalStag:
        return '🦌';
      case PetSpecies.stormPhoenix:
        return '🦅';
      case PetSpecies.mysticSerpent:
        return '🐍';
    }
  }

  String get lore {
    switch (this) {
      case PetSpecies.cosmicDragon:
        return 'Born from celestial fire, this dragon channels raw creative energy and fearless ambition.';
      case PetSpecies.crystalStag:
        return 'Rooted in earth\'s ancient wisdom, this stag embodies patience, loyalty, and unshakable stability.';
      case PetSpecies.stormPhoenix:
        return 'Riding on currents of thought, this phoenix moves with lightning intellect and boundless curiosity.';
      case PetSpecies.mysticSerpent:
        return 'Rising from the deepest emotional waters, this serpent carries ancient intuition and empathic healing.';
    }
  }
}

/// Pet personality trait, derived from Moon Nakshatra Gana
enum PetPersonality {
  gentleNurturer, // Deva gana
  balancedAdaptive, // Manushya gana
  fierceProtector, // Rakshasa gana
}

extension PetPersonalityExt on PetPersonality {
  String get label {
    switch (this) {
      case PetPersonality.gentleNurturer:
        return 'Gentle Nurturer';
      case PetPersonality.balancedAdaptive:
        return 'Balanced Adapter';
      case PetPersonality.fierceProtector:
        return 'Fierce Protector';
    }
  }

  String get emoji {
    switch (this) {
      case PetPersonality.gentleNurturer:
        return '🕊️';
      case PetPersonality.balancedAdaptive:
        return '⚖️';
      case PetPersonality.fierceProtector:
        return '🔥';
    }
  }

  String get description {
    switch (this) {
      case PetPersonality.gentleNurturer:
        return 'Radiates calm, divine energy. Heals through compassion.';
      case PetPersonality.balancedAdaptive:
        return 'Adapts to any situation. Bridges differences with ease.';
      case PetPersonality.fierceProtector:
        return 'Guards fiercely. Transforms challenges into raw power.';
    }
  }
}

/// A single RPG ability the pet possesses
class PetAbility {
  final String name;
  final String planet;
  final String emoji;
  final String description;
  final String effectType; // 'heal', 'boost', 'shield', 'link', 'aura'
  final int power; // 0-100

  const PetAbility({
    required this.name,
    required this.planet,
    required this.emoji,
    required this.description,
    required this.effectType,
    required this.power,
  });
}

/// The 5 RPG stats
class PetStats {
  final int vitality; // Sun
  final int empathy; // Moon
  final int valor; // Mars
  final int wisdom; // Jupiter
  final int resilience; // Saturn

  const PetStats({
    required this.vitality,
    required this.empathy,
    required this.valor,
    required this.wisdom,
    required this.resilience,
  });

  int get total => vitality + empathy + valor + wisdom + resilience;
  int get average => (total / 5).round();

  /// Returns the stat name → value map
  Map<String, int> toMap() => {
        'Vitality': vitality,
        'Empathy': empathy,
        'Valor': valor,
        'Wisdom': wisdom,
        'Resilience': resilience,
      };

  /// Returns the weakest stat name
  String get weakestStat {
    final m = toMap();
    return m.entries.reduce((a, b) => a.value <= b.value ? a : b).key;
  }

  /// Returns the strongest stat name
  String get strongestStat {
    final m = toMap();
    return m.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }
}

/// The full Astro Pet
class AstroPet {
  final String ownerName;
  final PetSpecies species;
  final String petName;
  final PetPersonality personality;
  final PetStats stats;
  final List<PetAbility> abilities; // Top 2
  final String ascendantSign;
  final String moonSign;
  final String sunSign;

  const AstroPet({
    required this.ownerName,
    required this.species,
    required this.petName,
    required this.personality,
    required this.stats,
    required this.abilities,
    required this.ascendantSign,
    required this.moonSign,
    required this.sunSign,
  });
}

/// A single interaction effect between two pets
class InteractionEffect {
  final String giverName; // The friend whose pet helps
  final String receiverName; // The person being helped
  final PetSpecies giverSpecies;
  final PetAbility ability; // The ability used
  final String targetStat; // Which stat is being boosted
  final int giverStrength; // 0-100
  final int receiverWeakness; // 0-100
  final String narrative; // RPG-style story text

  const InteractionEffect({
    required this.giverName,
    required this.receiverName,
    required this.giverSpecies,
    required this.ability,
    required this.targetStat,
    required this.giverStrength,
    required this.receiverWeakness,
    required this.narrative,
  });

  int get boostAmount =>
      ((giverStrength - receiverWeakness) * 0.3).round().clamp(5, 40);
}

/// Full result of two pets interacting
class PetInteractionResult {
  final AstroPet pet1;
  final AstroPet pet2;
  final List<InteractionEffect> effects;
  final String overallNarrative;
  final int synergyScore; // 0-100

  const PetInteractionResult({
    required this.pet1,
    required this.pet2,
    required this.effects,
    required this.overallNarrative,
    required this.synergyScore,
  });
}

// ════════════════════════════════════════════════════════════
// ENGINE
// ════════════════════════════════════════════════════════════

class AstroPetEngine {
  // ── Sign groupings ──
  static const _fireSignIndices = {0, 4, 8}; // Aries, Leo, Sag
  static const _earthSignIndices = {1, 5, 9}; // Tau, Vir, Cap
  static const _airSignIndices = {2, 6, 10}; // Gem, Lib, Aqu
  // Water signs (3, 7, 11) handled as default fallback in _getSpecies

  // ── Exaltation signs (sign index where planet is exalted) ──
  static const _exaltation = <String, int>{
    'Sun': 0, // Aries
    'Moon': 1, // Taurus
    'Mars': 9, // Capricorn
    'Mercury': 5, // Virgo
    'Jupiter': 3, // Cancer
    'Venus': 11, // Pisces
    'Saturn': 6, // Libra
  };

  // ── Debilitation signs ──
  static const _debilitation = <String, int>{
    'Sun': 6, // Libra
    'Moon': 7, // Scorpio
    'Mars': 3, // Cancer
    'Mercury': 11, // Pisces
    'Jupiter': 9, // Capricorn
    'Venus': 5, // Virgo
    'Saturn': 0, // Aries
  };

  // ── Own signs ──
  static const _ownSigns = <String, List<int>>{
    'Sun': [4], // Leo
    'Moon': [3], // Cancer
    'Mars': [0, 7], // Aries, Scorpio
    'Mercury': [2, 5], // Gemini, Virgo
    'Jupiter': [8, 11], // Sagittarius, Pisces
    'Venus': [1, 6], // Taurus, Libra
    'Saturn': [9, 10], // Capricorn, Aquarius
  };

  // ── Friendly signs ──
  static const _friendlySigns = <String, List<int>>{
    'Sun': [0, 3, 8], // Aries, Cancer, Sag (lords: Mars, Moon, Jupiter)
    'Moon': [
      1,
      4,
      2
    ], // Taurus, Leo, Gemini (lords: Venus→neutral, Sun, Mercury)
    'Mars': [4, 8, 11, 3], // Leo, Sag, Pisces, Cancer
    'Mercury': [1, 6, 4], // Taurus, Libra, Leo
    'Jupiter': [0, 4, 7], // Aries, Leo, Scorpio
    'Venus': [2, 9, 10], // Gemini, Capricorn, Aquarius
    'Saturn': [1, 2, 5, 6], // Taurus, Gemini, Virgo, Libra
  };

  // ── Enemy signs ──
  static const _enemySigns = <String, List<int>>{
    'Sun': [1, 6, 9, 10], // Taurus, Libra, Capricorn, Aquarius
    'Moon': [], // Moon has no enemies
    'Mars': [2, 5], // Gemini, Virgo
    'Mercury': [3, 7], // Cancer, Scorpio
    'Jupiter': [1, 2, 5, 6], // Taurus, Gemini, Virgo, Libra
    'Venus': [3, 4, 7], // Cancer, Leo, Scorpio
    'Saturn': [0, 3, 4, 7], // Aries, Cancer, Leo, Scorpio
  };

  // ── Nakshatra Gana (1-indexed nakshatra → gana) ──
  static const _nakshatraGana = [
    0, 1, 2, 1, 0, 1, 0, 0, 2, // 1-9
    2, 1, 0, 0, 2, 0, 2, 0, 2, // 10-18
    2, 1, 1, 0, 2, 2, 1, 1, 0, // 19-27
  ];

  // ── Pet name fragments ──
  static const _namePrefix = <PetSpecies, List<String>>{
    PetSpecies.cosmicDragon: ['Agni', 'Surya', 'Tejas', 'Jvala'],
    PetSpecies.crystalStag: ['Prithvi', 'Dhara', 'Sthira', 'Vajra'],
    PetSpecies.stormPhoenix: ['Vayu', 'Manas', 'Budha', 'Garuda'],
    PetSpecies.mysticSerpent: ['Varuna', 'Chandra', 'Naga', 'Soma'],
  };

  static const _nameSuffix = [
    'Kai',
    'Dev',
    'Mitra',
    'Deva',
    'Raksha',
    'Tara',
    'Veer',
    'Netra'
  ];

  // ════════════════════════════════════════════════════════════
  // GENERATE PET
  // ════════════════════════════════════════════════════════════

  static AstroPet generatePet({
    required KundaliResult chart,
    required String ownerName,
  }) {
    // 1. Species from Ascendant element
    final ascSignIdx = chart.ascendant['signIndex'] as int;
    final species = _getSpecies(ascSignIdx);

    // 2. Pet name (deterministic from chart data)
    final petName = _generateName(species, chart);

    // 3. Personality from Moon Nakshatra Gana
    final moonNakIdx =
        (chart.planets['Moon']?['nakshatraIndex'] as int? ?? 1) - 1;
    final gana = _nakshatraGana[moonNakIdx.clamp(0, 26)];
    final personality = PetPersonality.values[gana];

    // 4. Stats from planetary dignity
    final stats = _calculateStats(chart);

    // 5. Abilities from top 2 strongest planets
    final abilities = _deriveAbilities(chart);

    return AstroPet(
      ownerName: ownerName,
      species: species,
      petName: petName,
      personality: personality,
      stats: stats,
      abilities: abilities,
      ascendantSign: chart.ascendant['signName'] as String? ?? 'Aries',
      moonSign: chart.planets['Moon']?['signName'] as String? ?? '—',
      sunSign: chart.planets['Sun']?['signName'] as String? ?? '—',
    );
  }

  // ════════════════════════════════════════════════════════════
  // INTERACTION
  // ════════════════════════════════════════════════════════════

  static PetInteractionResult interact(AstroPet pet1, AstroPet pet2) {
    final effects = <InteractionEffect>[];

    // Map stat names to their planet source for ability lookup
    const statPlanet = {
      'Vitality': 'Sun',
      'Empathy': 'Moon',
      'Valor': 'Mars',
      'Wisdom': 'Jupiter',
      'Resilience': 'Saturn',
    };

    final stats1 = pet1.stats.toMap();
    final stats2 = pet2.stats.toMap();

    // Find where pet2 can help pet1 (pet2 strong, pet1 weak)
    for (final stat in statPlanet.entries) {
      final val1 = stats1[stat.key]!;
      final val2 = stats2[stat.key]!;
      if (val2 > val1 && val2 >= 55 && val1 < 55) {
        final ability = _findAbilityForPlanet(pet2.abilities, stat.value);
        if (ability != null) {
          effects.add(InteractionEffect(
            giverName: pet2.ownerName,
            receiverName: pet1.ownerName,
            giverSpecies: pet2.species,
            ability: ability,
            targetStat: stat.key,
            giverStrength: val2,
            receiverWeakness: val1,
            narrative: _generateNarrative(
              pet2.species,
              pet2.petName,
              pet1.petName,
              ability,
              stat.key,
              pet1.ownerName,
            ),
          ));
        }
      }
    }

    // Find where pet1 can help pet2
    for (final stat in statPlanet.entries) {
      final val1 = stats1[stat.key]!;
      final val2 = stats2[stat.key]!;
      if (val1 > val2 && val1 >= 55 && val2 < 55) {
        final ability = _findAbilityForPlanet(pet1.abilities, stat.value);
        if (ability != null) {
          effects.add(InteractionEffect(
            giverName: pet1.ownerName,
            receiverName: pet2.ownerName,
            giverSpecies: pet1.species,
            ability: ability,
            targetStat: stat.key,
            giverStrength: val1,
            receiverWeakness: val2,
            narrative: _generateNarrative(
              pet1.species,
              pet1.petName,
              pet2.petName,
              ability,
              stat.key,
              pet2.ownerName,
            ),
          ));
        }
      }
    }

    // Synergy score: how complementary are they?
    int synergy = 50;
    for (final stat in statPlanet.keys) {
      final diff = (stats1[stat]! - stats2[stat]!).abs();
      if (diff > 30) synergy += 5; // Complementary
      if (diff < 10) synergy += 3; // Harmonious
    }
    synergy = synergy.clamp(0, 100);

    final overallNarrative = _generateOverallNarrative(pet1, pet2, effects);

    return PetInteractionResult(
      pet1: pet1,
      pet2: pet2,
      effects: effects,
      overallNarrative: overallNarrative,
      synergyScore: synergy,
    );
  }

  // ════════════════════════════════════════════════════════════
  // PRIVATE HELPERS
  // ════════════════════════════════════════════════════════════

  static PetSpecies _getSpecies(int signIdx) {
    if (_fireSignIndices.contains(signIdx)) return PetSpecies.cosmicDragon;
    if (_earthSignIndices.contains(signIdx)) return PetSpecies.crystalStag;
    if (_airSignIndices.contains(signIdx)) return PetSpecies.stormPhoenix;
    return PetSpecies.mysticSerpent;
  }

  static String _generateName(PetSpecies species, KundaliResult chart) {
    final prefixes = _namePrefix[species]!;
    final moonDeg = (chart.planets['Moon']?['degree'] as num?)?.toDouble() ?? 0;
    final prefixIdx = (moonDeg ~/ 90).clamp(0, prefixes.length - 1);
    final suffixIdx = ((chart.ascendant['degree'] as num?)?.toInt() ?? 0) %
        _nameSuffix.length;
    return '${prefixes[prefixIdx]}${_nameSuffix[suffixIdx]}';
  }

  /// Calculate dignity score for a planet (0-100)
  static int _dignity(String planet, int signIdx, bool isRetrograde) {
    int score;

    if (_exaltation[planet] == signIdx) {
      score = 90;
    } else if (_ownSigns[planet]?.contains(signIdx) ?? false) {
      score = 75;
    } else if (_debilitation[planet] == signIdx) {
      score = 15;
    } else if (_friendlySigns[planet]?.contains(signIdx) ?? false) {
      score = 60;
    } else if (_enemySigns[planet]?.contains(signIdx) ?? false) {
      score = 35;
    } else {
      score = 50; // Neutral
    }

    // Retrograde modifier (malefics weaker, benefics complex — simplified)
    if (isRetrograde) {
      if (planet == 'Mars' || planet == 'Saturn') {
        score -= 8;
      } else {
        score += 5; // Retrograde benefics can be stronger in some traditions
      }
    }

    return score.clamp(0, 100);
  }

  static PetStats _calculateStats(KundaliResult chart) {
    int dg(String planet) {
      final data = chart.planets[planet];
      if (data == null) return 50;
      return _dignity(
        planet,
        data['signIndex'] as int? ?? 0,
        data['isRetrograde'] as bool? ?? false,
      );
    }

    return PetStats(
      vitality: dg('Sun'),
      empathy: dg('Moon'),
      valor: dg('Mars'),
      wisdom: dg('Jupiter'),
      resilience: dg('Saturn'),
    );
  }

  static List<PetAbility> _deriveAbilities(KundaliResult chart) {
    // All possible abilities
    final allAbilities = <PetAbility>[];

    void tryAdd(
        String planet, String name, String emoji, String desc, String type) {
      final data = chart.planets[planet];
      if (data == null) return;
      final power = _dignity(
        planet,
        data['signIndex'] as int? ?? 0,
        data['isRetrograde'] as bool? ?? false,
      );
      allAbilities.add(PetAbility(
        name: name,
        planet: planet,
        emoji: emoji,
        description: desc,
        effectType: type,
        power: power,
      ));
    }

    tryAdd('Sun', 'Solar Flare', '☀️',
        'Ignites inner fire, boosting vitality and confidence', 'boost');
    tryAdd(
        'Moon',
        'Lunar Embrace',
        '🌙',
        'Wraps in healing moonlight, soothing emotions and restoring inner peace',
        'heal');
    tryAdd(
        'Mars',
        'War Cry',
        '⚔️',
        'Unleashes a fierce battle cry, surging courage and fighting spirit',
        'boost');
    tryAdd(
        'Mercury',
        'Mind Link',
        '💬',
        'Opens a telepathic channel, sharpening communication and clarity',
        'link');
    tryAdd(
        'Jupiter',
        'Wisdom Aura',
        '📚',
        'Radiates ancient knowledge, expanding understanding and insight',
        'aura');
    tryAdd(
        'Venus',
        'Charm Wave',
        '💖',
        'Emanates irresistible grace, attracting harmony and creative beauty',
        'heal');
    tryAdd('Saturn', 'Iron Shield', '🛡️',
        'Forges an unbreakable barrier of discipline and endurance', 'shield');

    // Sort by power descending, take top 2
    allAbilities.sort((a, b) => b.power.compareTo(a.power));
    return allAbilities.take(2).toList();
  }

  static PetAbility? _findAbilityForPlanet(
      List<PetAbility> abilities, String planet) {
    try {
      return abilities.firstWhere((a) => a.planet == planet);
    } catch (_) {
      // The planet's ability may not be in the top 2 — generate one on the fly
      return _fallbackAbility(planet);
    }
  }

  static PetAbility _fallbackAbility(String planet) {
    const map = {
      'Sun': PetAbility(
          name: 'Solar Flare',
          planet: 'Sun',
          emoji: '☀️',
          description: 'Boosts vitality and life force',
          effectType: 'boost',
          power: 60),
      'Moon': PetAbility(
          name: 'Lunar Embrace',
          planet: 'Moon',
          emoji: '🌙',
          description: 'Soothes emotions and restores peace',
          effectType: 'heal',
          power: 60),
      'Mars': PetAbility(
          name: 'War Cry',
          planet: 'Mars',
          emoji: '⚔️',
          description: 'Surges courage and fighting spirit',
          effectType: 'boost',
          power: 60),
      'Jupiter': PetAbility(
          name: 'Wisdom Aura',
          planet: 'Jupiter',
          emoji: '📚',
          description: 'Expands knowledge and insight',
          effectType: 'aura',
          power: 60),
      'Saturn': PetAbility(
          name: 'Iron Shield',
          planet: 'Saturn',
          emoji: '🛡️',
          description: 'Strengthens discipline and endurance',
          effectType: 'shield',
          power: 60),
    };
    return map[planet] ??
        const PetAbility(
          name: 'Cosmic Touch',
          planet: 'Unknown',
          emoji: '✨',
          description: 'A gentle cosmic nudge',
          effectType: 'boost',
          power: 50,
        );
  }

  static String _generateNarrative(
    PetSpecies giverSpecies,
    String giverPetName,
    String receiverPetName,
    PetAbility ability,
    String stat,
    String receiverOwner,
  ) {
    final speciesName = giverSpecies.displayName;
    final statEffect = _statEffectPhrase(stat);

    switch (ability.effectType) {
      case 'heal':
        return '$giverPetName the $speciesName channels its ${ability.name}, '
            'enveloping $receiverPetName in ${ability.emoji} healing light. '
            '$receiverOwner\'s $stat surges as $statEffect';
      case 'boost':
        return '$giverPetName the $speciesName unleashes ${ability.name}! '
            '${ability.emoji} A wave of energy rushes through $receiverPetName. '
            '$receiverOwner feels $statEffect';
      case 'shield':
        return '$giverPetName the $speciesName raises its ${ability.name} ${ability.emoji}, '
            'shielding $receiverPetName from weakness. '
            '$receiverOwner\'s $stat stabilizes as $statEffect';
      case 'aura':
        return '$giverPetName the $speciesName glows with ${ability.name} ${ability.emoji}. '
            'Ancient wisdom flows into $receiverPetName. '
            '$receiverOwner absorbs the knowledge as $statEffect';
      default:
        return '$giverPetName uses ${ability.name} ${ability.emoji} to help $receiverPetName! '
            '$receiverOwner\'s $stat improves as $statEffect';
    }
  }

  static String _statEffectPhrase(String stat) {
    switch (stat) {
      case 'Vitality':
        return 'inner fire reignites and life force strengthens.';
      case 'Empathy':
        return 'emotional turbulence calms and heart opens to peace.';
      case 'Valor':
        return 'courage swells and fears dissolve like morning mist.';
      case 'Wisdom':
        return 'mental fog lifts and clarity of purpose returns.';
      case 'Resilience':
        return 'bones strengthen and the will to endure becomes unbreakable.';
      default:
        return 'cosmic energy rebalances.';
    }
  }

  static String _generateOverallNarrative(
    AstroPet pet1,
    AstroPet pet2,
    List<InteractionEffect> effects,
  ) {
    if (effects.isEmpty) {
      return '${pet1.petName} and ${pet2.petName} circle each other curiously. '
          'Their energies are balanced — neither needs the other\'s aid right now. '
          'A harmonious cosmic truce.';
    }

    final helpCount1 =
        effects.where((e) => e.giverName == pet1.ownerName).length;
    final helpCount2 =
        effects.where((e) => e.giverName == pet2.ownerName).length;

    if (helpCount1 > 0 && helpCount2 > 0) {
      return '${pet1.petName} and ${pet2.petName} form a powerful cosmic bond! '
          'Each brings strength where the other has vulnerability. '
          'Together, they create a balanced force greater than either alone. ✨';
    } else if (helpCount2 > 0) {
      return '${pet2.petName} becomes a guardian for ${pet1.petName}, '
          'channeling its celestial strengths to shore up ${pet1.ownerName}\'s challenges. '
          'A protective alliance forms. 🛡️';
    } else {
      return '${pet1.petName} takes on a mentor role for ${pet2.petName}, '
          'sharing its cosmic gifts to strengthen ${pet2.ownerName}\'s weaker areas. '
          'A guiding light appears. 🌟';
    }
  }
}
