/// Trinal Planetary Compatibility Engine (1-5-9 Axis)
/// 
/// Analyzes the natural harmony between planets in trine houses.
/// Trines (1st, 5th, 9th) represent Dharma - destiny supportive energy flow.
/// 
/// Key Principle: Planets in trine naturally support each other's themes,
/// creating evolutionary pathways for growth.

class TrineAnalysis {
  final String house1Planet;  // Planet in 1st house (Identity)
  final String house5Planet;  // Planet in 5th house (Creativity/Love)
  final String house9Planet;  // Planet in 9th house (Beliefs/Destiny)
  final String harmonyLevel;
  final String interpretation;
  final List<String> strengths;
  final List<String> challenges;

  const TrineAnalysis({
    required this.house1Planet,
    required this.house5Planet,
    required this.house9Planet,
    required this.harmonyLevel,
    required this.interpretation,
    required this.strengths,
    required this.challenges,
  });
}

class PlanetaryRelation {
  final String planet1;
  final String planet2;
  final int houseDifference;
  final String relationType;
  final String harmonyLevel;
  final String interpretation;
  final bool isTrinal;

  const PlanetaryRelation({
    required this.planet1,
    required this.planet2,
    required this.houseDifference,
    required this.relationType,
    required this.harmonyLevel,
    required this.interpretation,
    required this.isTrinal,
  });
}

class TrineCompatibilityEngine {
  /// Planet natures
  static const Map<String, String> planetNature = {
    'Su': 'Malefic',   // Natural malefic but Sattvic
    'Mo': 'Benefic',   // Natural benefic
    'Ma': 'Malefic',   // Natural malefic
    'Me': 'Neutral',   // Takes color of association
    'Ju': 'Benefic',   // Greatest benefic
    'Ve': 'Benefic',   // Natural benefic
    'Sa': 'Malefic',   // Natural malefic
    'Ra': 'Malefic',   // Shadow malefic
    'Ke': 'Malefic',   // Shadow malefic
  };

  /// Planet friendships (natural)
  static const Map<String, List<String>> planetFriends = {
    'Su': ['Mo', 'Ma', 'Ju'],
    'Mo': ['Su', 'Me'],
    'Ma': ['Su', 'Mo', 'Ju'],
    'Me': ['Su', 'Ve'],
    'Ju': ['Su', 'Mo', 'Ma'],
    'Ve': ['Me', 'Sa'],
    'Sa': ['Me', 'Ve'],
    'Ra': ['Ve', 'Sa'],
    'Ke': ['Ma', 'Ju'],
  };

  /// Planet enemies (natural)
  static const Map<String, List<String>> planetEnemies = {
    'Su': ['Sa', 'Ve'],
    'Mo': ['Ra', 'Ke'],
    'Ma': ['Me'],
    'Me': ['Mo'],
    'Ju': ['Me', 'Ve'],
    'Ve': ['Su', 'Mo'],
    'Sa': ['Su', 'Mo', 'Ma'],
    'Ra': ['Su', 'Mo'],
    'Ke': ['Su', 'Mo'],
  };

  /// Full planet names to abbreviations (for normalization)
  static const Map<String, String> _planetAbbreviations = {
    'Sun': 'Su', 'Moon': 'Mo', 'Mars': 'Ma', 'Mercury': 'Me',
    'Jupiter': 'Ju', 'Venus': 'Ve', 'Saturn': 'Sa',
    'Rahu': 'Ra', 'Ketu': 'Ke',
  };

  /// Normalize planet name to abbreviation
  static String _normalizePlanetName(String name) {
    // If already abbreviated, return as is
    if (['Su', 'Mo', 'Ma', 'Me', 'Ju', 'Ve', 'Sa', 'Ra', 'Ke'].contains(name)) {
      return name;
    }
    // Try direct lookup
    if (_planetAbbreviations.containsKey(name)) {
      return _planetAbbreviations[name]!;
    }
    // Try with first letter capitalized
    final capitalized = name.isNotEmpty 
        ? name[0].toUpperCase() + name.substring(1).toLowerCase()
        : name;
    return _planetAbbreviations[capitalized] ?? name;
  }

  /// Get planets in each house from chart
  static Map<int, List<String>> getPlanetsInHouses(Map<String, dynamic> chartData) {
    final result = <int, List<String>>{};
    for (int i = 1; i <= 12; i++) {
      result[i] = [];
    }

    // Support both API format ('planets') and local format ('planetDegrees')
    final planets = chartData['planets'] as Map<String, dynamic>?;
    final planetDegreesMap = chartData['planetDegrees'] as Map<String, dynamic>?;
    
    // Support both 'ascendant' and 'ascDegree'
    final ascDegree = (chartData['ascendant'] as double?) ?? 
                      (chartData['ascDegree'] as double?) ?? 0.0;
    final ascSign = ((ascDegree / 30).floor() % 12) + 1;

    // Also try 'planetHouseMap' which may already have planets mapped to houses
    final planetHouseMap = chartData['planetHouseMap'] as Map<String, dynamic>?;
    if (planetHouseMap != null && planetHouseMap.isNotEmpty) {
      planetHouseMap.forEach((planetName, houseNum) {
        if (houseNum is int && houseNum >= 1 && houseNum <= 12) {
          // Normalize to abbreviation
          final abbr = _normalizePlanetName(planetName);
          result[houseNum]!.add(abbr);
        }
      });
      return result;
    }

    // Try API format
    if (planets != null) {
      planets.forEach((planetName, data) {
        if (data is Map<String, dynamic>) {
          final longitude = data['longitude'] as double? ?? data['degree'] as double? ?? 0.0;
          final int signNum = ((longitude / 30).floor() % 12) + 1;
          final int houseNum = ((signNum - ascSign + 12) % 12) + 1;
          if (houseNum >= 1 && houseNum <= 12) {
             final abbr = _normalizePlanetName(planetName);
             result[houseNum]!.add(abbr);
          }
        }
      });
    }
    
    // Try local format with planetDegrees (API returns full names like "Sun", "Moon")
    if (planets == null && planetDegreesMap != null) {
      planetDegreesMap.forEach((planetName, degreeValue) {
        double? longitude;
        if (degreeValue is double) {
          longitude = degreeValue;
        } else if (degreeValue is int) {
          longitude = degreeValue.toDouble();
        } else if (degreeValue is num) {
          longitude = degreeValue.toDouble();
        }
        
        if (longitude != null) {
          final int signNum = ((longitude / 30).floor() % 12) + 1;
          final int houseNum = ((signNum - ascSign + 12) % 12) + 1;
          if (houseNum >= 1 && houseNum <= 12) {
            final abbr = _normalizePlanetName(planetName);
            result[houseNum]!.add(abbr);
          }
        }
      });
    }

    return result;
  }

  /// Analyze Dharma Trine (1-5-9) compatibility
  static TrineAnalysis analyzeDharmaTrine(Map<String, dynamic> chartData) {
    final houseMap = getPlanetsInHouses(chartData);

    final h1 = houseMap[1]!.isNotEmpty ? houseMap[1]!.first : 'Empty';
    final h5 = houseMap[5]!.isNotEmpty ? houseMap[5]!.first : 'Empty';
    final h9 = houseMap[9]!.isNotEmpty ? houseMap[9]!.first : 'Empty';

    String harmonyLevel;
    String interpretation;
    List<String> strengths = [];
    List<String> challenges = [];

    // Analyze harmony
    final beneficCount = _countBenefics([h1, h5, h9]);
    final maleficCount = _countMalefics([h1, h5, h9]);
    final emptyCount = [h1, h5, h9].where((p) => p == 'Empty').length;

    if (beneficCount >= 2) {
      harmonyLevel = 'High';
      interpretation = 'Strong dharmic support. Life purpose, creativity, and philosophy align naturally. '
          'Relationships formed tend to be supportive of growth.';
      strengths = [
        'Natural talent recognition',
        'Supportive mentors and guides appear',
        'Creative expression flows easily',
        'Spiritual inclination develops naturally',
      ];
      challenges = [
        'May take ease for granted',
        'Complacency risk in self-development',
      ];
    } else if (maleficCount >= 2) {
      harmonyLevel = 'Effort-Based';
      interpretation = 'Dharmic path requires conscious effort. Growth comes through overcoming challenges. '
          'Relationships may initially feel difficult but teach important lessons.';
      strengths = [
        'Strong will develops',
        'Resilience through adversity',
        'Depth of character',
        'Hard-earned wisdom',
      ];
      challenges = [
        'Self-doubt periods',
        'Need for patience',
        'May attract intense relationships',
      ];
    } else if (emptyCount >= 2) {
      harmonyLevel = 'Latent';
      interpretation = 'Dharmic potential awaits activation. Life purpose and creativity may take time to manifest. '
          'Relationships help crystallize identity.';
      strengths = [
        'Flexibility in life direction',
        'Open to new experiences',
        'Less karmic baggage',
      ];
      challenges = [
        'May feel lack of direction initially',
        'Need external triggers for growth',
      ];
    } else {
      harmonyLevel = 'Mixed';
      interpretation = 'Balanced dharmic influence with both support and challenges. '
          'Some areas flow easily while others require work.';
      strengths = [
        'Balanced development',
        'Variety of life experiences',
        'Adaptability',
      ];
      challenges = [
        'Inconsistent energy levels',
        'Need to prioritize consciously',
      ];
    }

    return TrineAnalysis(
      house1Planet: h1,
      house5Planet: h5,
      house9Planet: h9,
      harmonyLevel: harmonyLevel,
      interpretation: interpretation,
      strengths: strengths,
      challenges: challenges,
    );
  }

  /// Analyze specific planet-to-planet trine relationship
  static PlanetaryRelation analyzePlanetaryTrine({
    required String planet1,
    required String planet2,
    required int houseDifference,
  }) {
    final nature1 = planetNature[planet1] ?? 'Neutral';
    final nature2 = planetNature[planet2] ?? 'Neutral';
    final isFriend = _areFriends(planet1, planet2);
    final isEnemy = _areEnemies(planet1, planet2);
    final isTrinal = houseDifference == 4 || houseDifference == 8; // 5th or 9th from

    String relationType;
    String harmonyLevel;
    String interpretation;

    if (nature1 == 'Benefic' && nature2 == 'Benefic') {
      relationType = 'Benefic-Benefic';
      harmonyLevel = isFriend ? 'Excellent' : (isEnemy ? 'Good' : 'Very Good');
      interpretation = 'Natural flow of positive energy. Support, grace, and growth. '
          'Relationships here are nurturing and expansive.';
    } else if ((nature1 == 'Benefic' && nature2 == 'Malefic') ||
               (nature1 == 'Malefic' && nature2 == 'Benefic')) {
      relationType = 'Benefic-Malefic';
      harmonyLevel = isFriend ? 'Constructive' : (isEnemy ? 'Challenging' : 'Growth-Oriented');
      interpretation = 'Constructive tension creates growth. Challenges lead to strength. '
          'Relationships here teach through contrast.';
    } else if (nature1 == 'Malefic' && nature2 == 'Malefic') {
      relationType = 'Malefic-Malefic';
      harmonyLevel = isFriend ? 'Intense' : (isEnemy ? 'Difficult' : 'Demanding');
      interpretation = 'Powerful karmic energy. Transformation through pressure. '
          'Relationships here are intense but potentially deeply transformative.';
    } else {
      relationType = 'Mixed';
      harmonyLevel = 'Variable';
      interpretation = 'Adaptable energy that takes color from circumstances. '
          'Relationships here depend heavily on conscious choices.';
    }

    return PlanetaryRelation(
      planet1: planet1,
      planet2: planet2,
      houseDifference: houseDifference,
      relationType: relationType,
      harmonyLevel: harmonyLevel,
      interpretation: interpretation,
      isTrinal: isTrinal,
    );
  }

  /// Analyze DK position relative to trines
  static Map<String, dynamic> analyzeDKTrinePosition({
    required Map<String, dynamic> chartData,
    required int dkHouse,
    required String dkPlanet,
  }) {
    final houseMap = getPlanetsInHouses(chartData);

    // Check if DK is in trine houses
    final isIn1stTrine = dkHouse == 1;
    final isIn5thTrine = dkHouse == 5;
    final isIn9thTrine = dkHouse == 9;
    final isInDharmaTrine = isIn1stTrine || isIn5thTrine || isIn9thTrine;

    String connectionType;
    String interpretation;
    List<String> implications = [];

    if (isIn1stTrine) {
      connectionType = 'Identity Fusion';
      interpretation = 'Partner deeply influences your sense of self. '
          'Relationship becomes central to identity.';
      implications = [
        'Strong mutual identification',
        'Partner becomes mirror for self-understanding',
        'Risk: Over-dependence on partner for identity',
        'Gift: Complete integration possible',
      ];
    } else if (isIn5thTrine) {
      connectionType = 'Creative-Romantic Bond';
      interpretation = 'Partner activates creativity and romance. '
          'Love expressed through playfulness and creative projects.';
      implications = [
        'Romance remains alive long-term',
        'Creative collaboration flourishes',
        'Children bring couple closer',
        'Risk: May need constant novelty',
        'Gift: Joyful, expressive partnership',
      ];
    } else if (isIn9thTrine) {
      connectionType = 'Philosophical Alignment';
      interpretation = 'Partner shares spiritual/philosophical worldview. '
          'Relationship supports dharmic growth.';
      implications = [
        'Shared belief systems',
        'Travel and learning together',
        'Guru-like qualities in partner or self',
        'Risk: May become preachy together',
        'Gift: Wisdom-based partnership',
      ];
    } else {
      // Check which trine houses have planets
      final h1Planets = houseMap[1] ?? [];
      final h5Planets = houseMap[5] ?? [];
      final h9Planets = houseMap[9] ?? [];

      // Check DK relationship to trine planets
      final trineRelations = <String>[];
      for (final p in [...h1Planets, ...h5Planets, ...h9Planets]) {
        if (_areFriends(dkPlanet, p)) {
          trineRelations.add('friendly');
        } else if (_areEnemies(dkPlanet, p)) {
          trineRelations.add('challenging');
        }
      }

      if (trineRelations.where((r) => r == 'friendly').length >= 2) {
        connectionType = 'Indirect Dharmic Support';
        interpretation = 'Partner supports your purpose indirectly. '
            'Relationship facilitates life mission achievement.';
      } else if (trineRelations.where((r) => r == 'challenging').length >= 2) {
        connectionType = 'Karmic Training Zone';
        interpretation = 'Partner challenges you to grow. '
            'Relationship is a school for development.';
      } else {
        connectionType = 'Independent Path';
        interpretation = 'Partner influence on dharma is moderate. '
            'Relationship and life purpose are somewhat separate tracks.';
      }

      implications = [
        'Partner influence varies by life area',
        'Need conscious effort to align relationship with purpose',
        'Opportunity for complementary growth paths',
      ];
    }

    return {
      'dkHouse': dkHouse,
      'dkPlanet': dkPlanet,
      'connectionType': connectionType,
      'interpretation': interpretation,
      'implications': implications,
      'isInDharmaTrine': isInDharmaTrine,
    };
  }

  static int _countBenefics(List<String> planets) {
    return planets.where((p) => planetNature[p] == 'Benefic').length;
  }

  static int _countMalefics(List<String> planets) {
    return planets.where((p) => planetNature[p] == 'Malefic').length;
  }

  static bool _areFriends(String p1, String p2) {
    return planetFriends[p1]?.contains(p2) ?? false;
  }

  static bool _areEnemies(String p1, String p2) {
    return planetEnemies[p1]?.contains(p2) ?? false;
  }
}
