/// Cosmic Pet Personality Engine
///
/// Generates a CosmicPet from the user's birth chart:
/// 1. Lagna → Base Temperament (immutable)
/// 2. Planets in Houses → Active behavioral themes
/// 3. Planetary Strength/Affliction → Tone (encouraging / grounding / reflective)
/// 4. "Why Today" explainability cues

import '../models/cosmic_pet_models.dart';

class CosmicPetPersonalityEngine {
  /// Generate a Cosmic Pet from the user's chart data
  ///
  /// [chartData] is the Map from UserSession.birthChart containing:
  ///   - 'ascSign': String (e.g. 'Aries')
  ///   - 'planetHouses': Map<String, int> (planet → house number)
  ///   - 'planetSigns': Map<String, int> (planet → sign index 1-12)
  ///   - 'planetPositions': Map<String, dynamic> (planet → {isRetrograde, ...})
  /// [ownerName] is the user's name
  static CosmicPet generatePet({
    required Map<String, dynamic> chartData,
    required String ownerName,
  }) {
    // 1. Lagna → Temperament
    final ascSign = chartData['ascSign'] as String? ?? 'Aries';
    final temperament = PetTemperament.fromLagna(ascSign);

    // 2. Planets in Houses → Active themes
    final activeThemes = _getActiveHouseThemes(chartData);

    // 3. Planetary tone
    final toneResult = _calculatePlanetaryTone(chartData);

    // 4. Generate pet name from temperament + owner
    final petName = _generatePetName(temperament, ownerName);

    return CosmicPet(
      name: petName,
      temperament: temperament,
      activeHouseThemes: activeThemes,
      planetaryTone: toneResult.tone,
      toneExplanation: toneResult.explanation,
    );
  }

  /// Generate "Why Today" explainability cues
  static List<WhyTodayCue> generateWhyToday({
    required CosmicPet pet,
    required Map<String, dynamic> panchangData,
  }) {
    final cues = <WhyTodayCue>[];

    // 1. Lagna influence (always present)
    cues.add(WhyTodayCue(
      factor: '${pet.temperament.name} (${pet.temperament.element})',
      effect: 'Your pet\'s core nature: ${pet.temperament.coreTraits}',
      emoji: pet.temperament.petEmoji,
    ));

    // 2. Active house themes (top 3 most relevant)
    for (final theme in pet.activeHouseThemes.take(3)) {
      cues.add(WhyTodayCue(
        factor: 'House ${theme.house}: ${theme.theme}',
        effect: theme.nudge,
        emoji: theme.emoji,
      ));
    }

    // 3. Planetary tone
    cues.add(WhyTodayCue(
      factor: 'Planetary Tone',
      effect: pet.toneExplanation,
      emoji: _toneEmoji(pet.planetaryTone),
    ));

    // 4. Panchang context
    final tithi = panchangData['tithi'] as Map<String, dynamic>?;
    if (tithi != null) {
      cues.add(WhyTodayCue(
        factor: 'Tithi: ${tithi['name'] ?? 'Unknown'}',
        effect: _tithiInfluence(tithi['name'] as String? ?? ''),
        emoji: '🌓',
      ));
    }

    final nakshatra = panchangData['nakshatra'] as Map<String, dynamic>?;
    if (nakshatra != null) {
      cues.add(WhyTodayCue(
        factor: 'Nakshatra: ${nakshatra['name'] ?? 'Unknown'}',
        effect: _nakshatraInfluence(nakshatra['name'] as String? ?? ''),
        emoji: '⭐',
      ));
    }

    final varaLord = panchangData['varaLord'] as String?;
    if (varaLord != null) {
      cues.add(WhyTodayCue(
        factor: 'Day Ruler: $varaLord',
        effect: _varaInfluence(varaLord),
        emoji: '📅',
      ));
    }

    return cues;
  }

  // ──────────────────────────────────────────────────────
  // INTERNAL: House themes
  // ──────────────────────────────────────────────────────

  static List<HouseBehavior> _getActiveHouseThemes(
      Map<String, dynamic> chartData) {
    final planetHouses = chartData['planetHouses'] as Map<String, dynamic>?;
    if (planetHouses == null) return [];

    // Collect unique houses that have planets
    final activeHouseNumbers = <int>{};
    planetHouses.forEach((planet, house) {
      if (house is int && house >= 1 && house <= 12) {
        // Skip Rahu/Ketu for behavioral themes (shadow planets)
        if (planet != 'Rahu' && planet != 'Ketu') {
          activeHouseNumbers.add(house);
        }
      }
    });

    // Sort by house number and get behaviors
    final sortedHouses = activeHouseNumbers.toList()..sort();
    return sortedHouses.map((h) => HouseBehavior.forHouse(h)).toList();
  }

  // ──────────────────────────────────────────────────────
  // INTERNAL: Planetary tone
  // ──────────────────────────────────────────────────────

  static _ToneResult _calculatePlanetaryTone(Map<String, dynamic> chartData) {
    final planetSigns = chartData['planetSigns'] as Map<String, dynamic>?;
    final planetPositions =
        chartData['planetPositions'] as Map<String, dynamic>?;

    if (planetSigns == null) {
      return const _ToneResult(
        tone: 'balanced',
        explanation: 'Your pet maintains a balanced outlook today.',
      );
    }

    int beneficStrength = 0;
    int maleficStrength = 0;
    bool hasRetrograde = false;
    bool hasCombust = false;
    List<String> strongBenefics = [];
    List<String> strongMalefics = [];

    const benefics = {'Jupiter', 'Venus', 'Moon', 'Mercury'};
    const malefics = {'Mars', 'Saturn', 'Rahu', 'Ketu', 'Sun'};

    // Check for exalted / own-sign benefics vs malefics
    planetSigns.forEach((planet, signIdx) {
      final idx = (signIdx is int) ? signIdx : 1;
      final dignity = _getDignity(planet, idx);

      if (benefics.contains(planet)) {
        beneficStrength += dignity;
        if (dignity >= 3) strongBenefics.add(planet);
      } else if (malefics.contains(planet)) {
        maleficStrength += dignity;
        if (dignity >= 3) strongMalefics.add(planet);
      }
    });

    // Check retrograde/combust from planet positions
    if (planetPositions != null) {
      planetPositions.forEach((planet, data) {
        if (data is Map<String, dynamic>) {
          if (data['isRetrograde'] == true) hasRetrograde = true;
        }
      });
    }

    // Determine tone
    if (hasRetrograde || hasCombust) {
      final retroPlanets = <String>[];
      if (planetPositions != null) {
        planetPositions.forEach((planet, data) {
          if (data is Map<String, dynamic> && data['isRetrograde'] == true) {
            retroPlanets.add(planet);
          }
        });
      }
      return _ToneResult(
        tone: 'reflective',
        explanation: retroPlanets.isNotEmpty
            ? '${retroPlanets.join(", ")} retrograde invites review over rush.'
            : 'Planetary alignments suggest introspection today.',
      );
    }

    if (beneficStrength > maleficStrength + 2) {
      return _ToneResult(
        tone: 'encouraging',
        explanation: strongBenefics.isNotEmpty
            ? 'Strong ${strongBenefics.join(", ")} energy supports expansion.'
            : 'Benefic planets bring an encouraging, expansive tone.',
      );
    }

    if (maleficStrength > beneficStrength + 2) {
      return _ToneResult(
        tone: 'grounding',
        explanation: strongMalefics.isNotEmpty
            ? '${strongMalefics.join(", ")} energy calls for grounding & discipline.'
            : 'Malefic influence encourages caution and steady effort.',
      );
    }

    return const _ToneResult(
      tone: 'balanced',
      explanation: 'Planetary energies are balanced — steady progress today.',
    );
  }

  /// Simple dignity score: exalted=4, own=3, friendly=2, neutral=1, enemy=0
  static int _getDignity(String planet, int signIdx) {
    // Exaltation signs (1-indexed)
    const exaltation = {
      'Sun': 1,
      'Moon': 2,
      'Mars': 10,
      'Mercury': 6,
      'Jupiter': 4,
      'Venus': 12,
      'Saturn': 7,
    };
    // Own signs
    const ownSigns = {
      'Sun': [5],
      'Moon': [4],
      'Mars': [1, 8],
      'Mercury': [3, 6],
      'Jupiter': [9, 12],
      'Venus': [2, 7],
      'Saturn': [10, 11],
    };
    // Debilitation signs
    const debilitation = {
      'Sun': 7,
      'Moon': 8,
      'Mars': 4,
      'Mercury': 12,
      'Jupiter': 10,
      'Venus': 6,
      'Saturn': 1,
    };

    if (exaltation[planet] == signIdx) return 4;
    if (ownSigns[planet]?.contains(signIdx) == true) return 3;
    if (debilitation[planet] == signIdx) return 0;

    // Default: neutral-friendly
    return 2;
  }

  // ──────────────────────────────────────────────────────
  // INTERNAL: Pet naming
  // ──────────────────────────────────────────────────────

  static String _generatePetName(PetTemperament temperament, String ownerName) {
    const prefixes = {
      'Fire': ['Agni', 'Surya', 'Tejas', 'Jwala'],
      'Earth': ['Bhumi', 'Dhara', 'Prithvi', 'Ratna'],
      'Air': ['Vayu', 'Marut', 'Pavan', 'Neel'],
      'Water': ['Varuna', 'Jala', 'Sindhu', 'Amrit'],
    };

    final elementPrefixes = prefixes[temperament.element] ?? ['Cosmic'];
    // Hash owner name to pick a consistent prefix
    final hash = ownerName.codeUnits.fold<int>(0, (a, b) => a + b);
    final prefix = elementPrefixes[hash % elementPrefixes.length];

    return prefix;
  }

  // ──────────────────────────────────────────────────────
  // INTERNAL: Panchang influence descriptions
  // ──────────────────────────────────────────────────────

  static String _toneEmoji(String tone) {
    switch (tone) {
      case 'encouraging':
        return '🌈';
      case 'grounding':
        return '🛡️';
      case 'reflective':
        return '🪷';
      default:
        return '⚖️';
    }
  }

  static String _tithiInfluence(String tithiName) {
    final lower = tithiName.toLowerCase();
    if (lower.contains('pratipada'))
      return 'Fresh starts and new beginnings favored.';
    if (lower.contains('dwitiya')) return 'Steady resource planning energy.';
    if (lower.contains('tritiya'))
      return 'Skill practice and social connection.';
    if (lower.contains('chaturthi'))
      return 'Obstacle removal — tackle blockers.';
    if (lower.contains('panchami'))
      return 'Learning and creative energy peaks.';
    if (lower.contains('shashthi'))
      return 'Physical discipline and routine building.';
    if (lower.contains('saptami')) return 'Leadership and initiative energy.';
    if (lower.contains('ashtami')) return 'Shadow work — face what\'s hidden.';
    if (lower.contains('navami'))
      return 'Courage tasks — step outside comfort zone.';
    if (lower.contains('dashami'))
      return 'Execution energy — complete pending work.';
    if (lower.contains('ekadashi')) return 'Mental clarity — detox and fast.';
    if (lower.contains('dwadashi')) return 'Review and consolidate progress.';
    if (lower.contains('trayodashi')) return 'Refinement — polish what exists.';
    if (lower.contains('chaturdashi')) return 'Closure — wrap up loose ends.';
    if (lower.contains('purnima')) return 'Full moon reflection and gratitude.';
    if (lower.contains('amavasya'))
      return 'Rest and reset — plant inner seeds.';
    return 'Lunar energy shapes today\'s rhythm.';
  }

  static String _nakshatraInfluence(String nakshatraName) {
    const influences = {
      'Ashwini': 'Quick-start energy — act on instinct.',
      'Bharani': 'Time to end a pending task.',
      'Krittika': 'Clean up chaos and purify.',
      'Rohini': 'Nurture growth and beauty.',
      'Mrigashira': 'Explore options with curiosity.',
      'Ardra': 'Emotional clarity needed.',
      'Punarvasu': 'Restart gently — second chances.',
      'Pushya': 'Nourish routines and care.',
      'Ashlesha': 'Detox old patterns.',
      'Magha': 'Honor roots and traditions.',
      'Purva Phalguni': 'Creative joy and celebration.',
      'Uttara Phalguni': 'Commitment and follow-through.',
      'Hasta': 'Hands-on productive work.',
      'Chitra': 'Redesign something fresh.',
      'Swati': 'Independence and flexibility.',
      'Vishakha': 'Focused competitive drive.',
      'Anuradha': 'Collaboration and teamwork.',
      'Jyeshtha': 'Responsibility and leadership.',
      'Mula': 'Root cause analysis — go deep.',
      'Purva Ashadha': 'Assert boundaries clearly.',
      'Uttara Ashadha': 'Long-term goals in focus.',
      'Shravana': 'Learn and listen deeply.',
      'Dhanishta': 'Teamwork and collective effort.',
      'Shatabhisha': 'Healing and restoration.',
      'Purva Bhadrapada': 'Vision setting and idealism.',
      'Uttara Bhadrapada': 'Spiritual grounding.',
      'Revati': 'Completion and compassion.',
    };
    return influences[nakshatraName] ?? 'Stellar energy influences today.';
  }

  static String _varaInfluence(String varaLord) {
    switch (varaLord) {
      case 'Sun':
        return 'Sun\'s day: confidence, authority, vitality.';
      case 'Moon':
        return 'Moon\'s day: emotions, nurturing, intuition.';
      case 'Mars':
        return 'Mars\' day: action, courage, physical energy.';
      case 'Mercury':
        return 'Mercury\'s day: communication, learning, trade.';
      case 'Jupiter':
        return 'Jupiter\'s day: wisdom, growth, generosity.';
      case 'Venus':
        return 'Venus\' day: beauty, harmony, relationships.';
      case 'Saturn':
        return 'Saturn\'s day: discipline, patience, structure.';
      default:
        return 'Today\'s ruling planet shapes the daily mood.';
    }
  }
}

/// Internal tone result
class _ToneResult {
  final String tone;
  final String explanation;
  const _ToneResult({required this.tone, required this.explanation});
}
