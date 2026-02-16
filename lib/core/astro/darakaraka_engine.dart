/// Jaimini Karaka System - Darakaraka Engine
///
/// Calculates the Darakaraka (DK) - the planet with the lowest degree in the chart.
/// DK represents: spouse psychology, relationship karma, partner attraction patterns.
///
/// Jaimini System uses 7 or 8 Charakarakas based on planetary degrees.
/// For relationship analysis, Darakaraka is the most critical.

class JaiminiKaraka {
  final String planet;
  final String karakaName;
  final double degree;
  final int signNumber;
  final String signName;
  final int houseNumber;
  final int? nakshatraIndex;
  final String? nakshatraName;

  const JaiminiKaraka({
    required this.planet,
    required this.karakaName,
    required this.degree,
    required this.signNumber,
    required this.signName,
    required this.houseNumber,
    this.nakshatraIndex,
    this.nakshatraName,
  });

  @override
  String toString() =>
      '$karakaName: $planet at ${degree.toStringAsFixed(2)}° in $signName (House $houseNumber)';
}

class DarakarakaEngine {
  /// Planet abbreviations to full names
  static const Map<String, String> planetNames = {
    'Su': 'Sun',
    'Mo': 'Moon',
    'Ma': 'Mars',
    'Me': 'Mercury',
    'Ju': 'Jupiter',
    'Ve': 'Venus',
    'Sa': 'Saturn',
    'Ra': 'Rahu',
    'Ke': 'Ketu',
  };

  /// Full planet names to abbreviations (reverse mapping)
  static const Map<String, String> planetAbbreviations = {
    'Sun': 'Su', 'Moon': 'Mo', 'Mars': 'Ma', 'Mercury': 'Me',
    'Jupiter': 'Ju', 'Venus': 'Ve', 'Saturn': 'Sa',
    'Rahu': 'Ra', 'Ketu': 'Ke',
    // Also handle lowercase
    'sun': 'Su', 'moon': 'Mo', 'mars': 'Ma', 'mercury': 'Me',
    'jupiter': 'Ju', 'venus': 'Ve', 'saturn': 'Sa',
    'rahu': 'Ra', 'ketu': 'Ke',
  };

  /// Nakshatra names
  static const List<String> nakshatras = [
    'Ashwini',
    'Bharani',
    'Krittika',
    'Rohini',
    'Mrigashira',
    'Ardra',
    'Punarvasu',
    'Pushya',
    'Ashlesha',
    'Magha',
    'Purva Phalguni',
    'Uttara Phalguni',
    'Hasta',
    'Chitra',
    'Swati',
    'Vishakha',
    'Anuradha',
    'Jyeshtha',
    'Mula',
    'Purva Ashadha',
    'Uttara Ashadha',
    'Shravana',
    'Dhanishta',
    'Shatabhisha',
    'Purva Bhadrapada',
    'Uttara Bhadrapada',
    'Revati',
  ];

  /// Sign names
  static const List<String> signNames = [
    'Aries',
    'Taurus',
    'Gemini',
    'Cancer',
    'Leo',
    'Virgo',
    'Libra',
    'Scorpio',
    'Sagittarius',
    'Capricorn',
    'Aquarius',
    'Pisces',
  ];

  /// Karaka names in order (highest to lowest degree)
  static const List<String> karakaOrder = [
    'Atmakaraka', // AK - Soul, Self
    'Amatyakaraka', // AmK - Career, Advisors
    'Bhratrikaraka', // BK - Siblings, Courage
    'Matrikaraka', // MK - Mother, Property
    'Pitrikaraka', // PiK - Father, Guidance
    'Putrakaraka', // PuK - Children, Creativity
    'Gnatikaraka', // GK - Obstacles, Relatives
    'Darakaraka', // DK - Spouse, Partners
  ];

  /// Calculate degree within sign (0-30)
  static double getDegreeInSign(double longitude) {
    return longitude % 30;
  }

  /// Get sign number from longitude (1-12)
  static int getSignNumber(double longitude) {
    return ((longitude / 30).floor() % 12) + 1;
  }

  /// Get nakshatra index from longitude (0-26)
  static int getNakshatraIndex(double longitude) {
    return ((longitude / (360 / 27)).floor() % 27);
  }

  /// Calculate all Jaimini Charakarakas from chart data
  ///
  /// [chartData] - Full chart data from ChartProvider
  /// [includeRahuKetu] - Whether to include Rahu/Ketu in calculation (8-karaka system)
  ///
  /// Returns: List of JaiminiKaraka sorted from highest degree (AK) to lowest (DK)
  static List<JaiminiKaraka> calculateCharakarakas({
    required Map<String, dynamic> chartData,
    bool includeRahuKetu = false,
  }) {
    // Support both API format ('planets') and local format ('planetDegrees')
    final planets = chartData['planets'] as Map<String, dynamic>?;
    final planetDegreesMap =
        chartData['planetDegrees'] as Map<String, dynamic>?;

    // Support both 'ascendant' and 'ascDegree'
    final ascDegree = (chartData['ascendant'] as double?) ??
        (chartData['ascDegree'] as double?) ??
        0.0;
    final ascSign = getSignNumber(ascDegree);

    // Build list of planets with their degrees in sign
    final planetDegreesList = <Map<String, dynamic>>[];

    final includePlanets = includeRahuKetu
        ? ['Su', 'Mo', 'Ma', 'Me', 'Ju', 'Ve', 'Sa', 'Ra']
        : ['Su', 'Mo', 'Ma', 'Me', 'Ju', 'Ve', 'Sa'];

    for (final abbr in includePlanets) {
      double? longitude;
      final fullName =
          planetNames[abbr] ?? abbr; // Get full name like "Sun" from "Su"

      // Try API format first (planets as Map with longitude)
      if (planets != null) {
        // Try abbreviation first, then full name
        var planetData = planets[abbr] ?? planets[fullName];
        if (planetData is Map<String, dynamic>) {
          longitude = planetData['longitude'] as double? ??
              planetData['degree'] as double?;
        }
      }

      // Try local format (planetDegrees as Map with direct values)
      // API returns full names like "Sun", "Moon", etc.
      if (longitude == null && planetDegreesMap != null) {
        // Try abbreviation first
        var degreeValue = planetDegreesMap[abbr];
        // Then try full name
        degreeValue ??= planetDegreesMap[fullName];
        // Also try lowercase
        degreeValue ??= planetDegreesMap[fullName.toLowerCase()];

        if (degreeValue is double) {
          longitude = degreeValue;
        } else if (degreeValue is int) {
          longitude = degreeValue.toDouble();
        } else if (degreeValue is num) {
          longitude = degreeValue.toDouble();
        }
      }

      if (longitude != null) {
        final degreeInSign = getDegreeInSign(longitude);
        final signNum = getSignNumber(longitude);
        final nakIndex = getNakshatraIndex(longitude);

        // Calculate house position
        final houseNum = ((signNum - ascSign + 12) % 12) + 1;

        planetDegreesList.add({
          'planet': abbr,
          'longitude': longitude,
          'degreeInSign': degreeInSign,
          'signNumber': signNum,
          'signName': signNames[signNum - 1],
          'houseNumber': houseNum,
          'nakshatraIndex': nakIndex,
          'nakshatraName': nakshatras[nakIndex],
        });
      }
    }

    // Sort by degree in sign (highest first)
    planetDegreesList.sort((a, b) =>
        (b['degreeInSign'] as double).compareTo(a['degreeInSign'] as double));

    // Assign Karaka names
    final karakas = <JaiminiKaraka>[];
    for (int i = 0;
        i < planetDegreesList.length && i < karakaOrder.length;
        i++) {
      final pd = planetDegreesList[i];
      karakas.add(JaiminiKaraka(
        planet: pd['planet'],
        karakaName: karakaOrder[i],
        degree: pd['degreeInSign'],
        signNumber: pd['signNumber'],
        signName: pd['signName'],
        houseNumber: pd['houseNumber'],
        nakshatraIndex: pd['nakshatraIndex'],
        nakshatraName: pd['nakshatraName'],
      ));
    }

    return karakas;
  }

  /// Get Darakaraka specifically (planet with lowest degree)
  static JaiminiKaraka? getDarakaraka(Map<String, dynamic> chartData) {
    final karakas = calculateCharakarakas(chartData: chartData);
    try {
      return karakas.firstWhere((k) => k.karakaName == 'Darakaraka');
    } catch (_) {
      return karakas.isNotEmpty ? karakas.last : null;
    }
  }

  /// Get Atmakaraka (planet with highest degree)
  static JaiminiKaraka? getAtmakaraka(Map<String, dynamic> chartData) {
    final karakas = calculateCharakarakas(chartData: chartData);
    return karakas.isNotEmpty ? karakas.first : null;
  }

  /// Get specific Karaka by name
  static JaiminiKaraka? getKarakaByName(
      List<JaiminiKaraka> karakas, String name) {
    try {
      return karakas.firstWhere((k) => k.karakaName == name);
    } catch (_) {
      return null;
    }
  }

  /// Calculate relationship between DK and Lagna Lord
  static Map<String, dynamic> analyzeDKLagnaRelation(
      Map<String, dynamic> chartData) {
    final dk = getDarakaraka(chartData);
    if (dk == null) return {'hasData': false};

    // Support both 'ascendant' and 'ascDegree'
    final ascDegree = (chartData['ascendant'] as double?) ??
        (chartData['ascDegree'] as double?) ??
        0.0;
    final ascSign = getSignNumber(ascDegree);

    // Get Lagna Lord
    final lagnaLord = _getSignLord(ascSign);

    // Check if DK is in trine to Lagna
    final dkFromLagna = dk.houseNumber;
    final isInTrine = [1, 5, 9].contains(dkFromLagna);
    final isInKendra = [1, 4, 7, 10].contains(dkFromLagna);
    final isInDustana = [6, 8, 12].contains(dkFromLagna);

    String relation;
    String interpretation;

    if (isInTrine) {
      relation = 'Harmonious';
      interpretation =
          'Partner naturally supports your life path and identity. Relationship flows with dharmic alignment.';
    } else if (isInKendra) {
      relation = 'Significant';
      interpretation =
          'Partner has major influence on your life direction. Strong karmic connection with active engagement.';
    } else if (isInDustana) {
      relation = 'Challenging';
      interpretation =
          'Relationship requires conscious effort. Growth through working through difficulties together.';
    } else {
      relation = 'Moderate';
      interpretation =
          'Partner influence is present but not overwhelming. Balance of support and independence.';
    }

    return {
      'hasData': true,
      'dk': dk,
      'lagnaLord': lagnaLord,
      'dkHouseFromLagna': dkFromLagna,
      'relation': relation,
      'interpretation': interpretation,
      'isInTrine': isInTrine,
      'isInKendra': isInKendra,
      'isInDustana': isInDustana,
    };
  }

  /// Get sign lord
  static String _getSignLord(int signNumber) {
    const signLords = {
      1: 'Ma',
      2: 'Ve',
      3: 'Me',
      4: 'Mo',
      5: 'Su',
      6: 'Me',
      7: 'Ve',
      8: 'Ma',
      9: 'Ju',
      10: 'Sa',
      11: 'Sa',
      12: 'Ju',
    };
    return signLords[signNumber] ?? 'Unknown';
  }

  // ============================================================
  // NAISARGIKA KARAKAS (Fixed Natural Significators)
  // ============================================================

  /// Fixed natural significators - never change based on chart
  static const Map<String, Map<String, String>> naisargikaKarakas = {
    'Su': {
      'karaka': 'Soul/Self',
      'houses': '1, 9, 10',
      'domain': 'Soul, father, authority, government'
    },
    'Mo': {
      'karaka': 'Mind/Mother',
      'houses': '4',
      'domain': 'Mind, mother, emotions, public'
    },
    'Ma': {
      'karaka': 'Siblings/Courage',
      'houses': '3, 6',
      'domain': 'Courage, siblings, property, energy'
    },
    'Me': {
      'karaka': 'Speech/Intelligence',
      'houses': '4, 10',
      'domain': 'Speech, intelligence, trade, education'
    },
    'Ju': {
      'karaka': 'Wisdom/Children',
      'houses': '2, 5, 9, 11',
      'domain': 'Wisdom, children, dharma, wealth'
    },
    'Ve': {
      'karaka': 'Spouse/Luxury',
      'houses': '7, 12',
      'domain': 'Spouse, luxury, arts, pleasure'
    },
    'Sa': {
      'karaka': 'Sorrow/Longevity',
      'houses': '6, 8, 12',
      'domain': 'Sorrow, longevity, service, discipline'
    },
    'Ra': {
      'karaka': 'Obsession',
      'houses': '',
      'domain': 'Worldly desires, foreign, unconventional'
    },
    'Ke': {
      'karaka': 'Liberation',
      'houses': '',
      'domain': 'Spiritual liberation, past life, detachment'
    },
  };

  /// Get Naisargika Karaka for a planet
  static Map<String, String>? getNaisargikaKaraka(String planet) {
    final abbr = planetAbbreviations[planet] ?? planet;
    return naisargikaKarakas[abbr];
  }

  // ============================================================
  // STHIRA KARAKAS (Fixed Relationship Significators)
  // ============================================================

  /// Fixed relationship-based significators
  static const Map<String, String> sthiraKarakas = {
    'Su': 'Father',
    'Mo': 'Mother',
    'Ma': 'Younger siblings',
    'Me': 'Maternal relatives',
    'Ju': 'Children, Husband (for females)',
    'Ve': 'Wife (for males), Partner',
    'Sa': 'Elder siblings, Servants',
  };

  /// Get Sthira Karaka for a planet
  static String? getSthiraKaraka(String planet) {
    final abbr = planetAbbreviations[planet] ?? planet;
    return sthiraKarakas[abbr];
  }

  // ============================================================
  // COMBINED KARAKA LOOKUP
  // ============================================================

  /// Calculate Chara Karakas from a degree map
  /// Input: {'Sun': 216.5, 'Moon': 45.2, ...} or {'Su': 216.5, 'Mo': 45.2, ...}
  static List<JaiminiKaraka> calculateCharakarakasFromDegrees({
    required Map<String, double> planetDegrees,
    double ascendantDegree = 0.0,
    bool includeRahuKetu = false,
  }) {
    final chartData = {
      'planetDegrees': planetDegrees,
      'ascDegree': ascendantDegree,
    };
    return calculateCharakarakas(
      chartData: chartData,
      includeRahuKetu: includeRahuKetu,
    );
  }

  /// Get all three Karaka systems for a planet
  /// Returns: { 'chara': 'Darakaraka', 'naisargika': {...}, 'sthira': 'Mother' }
  static Map<String, dynamic> getAllKarakasForPlanet({
    required String planet,
    required List<JaiminiKaraka> charaKarakas,
  }) {
    final abbr = planetAbbreviations[planet] ?? planet;

    // Find Chara Karaka
    String? charaKarakaName;
    try {
      final match = charaKarakas.firstWhere((k) => k.planet == abbr);
      charaKarakaName = match.karakaName;
    } catch (_) {}

    return {
      'planet': abbr,
      'planetName': planetNames[abbr] ?? planet,
      'chara': charaKarakaName,
      'naisargika': naisargikaKarakas[abbr],
      'sthira': sthiraKarakas[abbr],
    };
  }

  /// Get comprehensive Karaka analysis for a set of planet degrees
  static Map<String, dynamic> getFullKarakaAnalysis({
    required Map<String, double> planetDegrees,
    double ascendantDegree = 0.0,
  }) {
    final charaKarakas = calculateCharakarakasFromDegrees(
      planetDegrees: planetDegrees,
      ascendantDegree: ascendantDegree,
    );

    final analysis = <String, dynamic>{};
    for (final abbr in ['Su', 'Mo', 'Ma', 'Me', 'Ju', 'Ve', 'Sa']) {
      analysis[abbr] = getAllKarakasForPlanet(
        planet: abbr,
        charaKarakas: charaKarakas,
      );
    }

    return {
      'charaKarakas': charaKarakas
          .map((k) => {
                'planet': k.planet,
                'karakaName': k.karakaName,
                'degree': k.degree,
                'signName': k.signName,
                'houseNumber': k.houseNumber,
                'nakshatraName': k.nakshatraName,
              })
          .toList(),
      'perPlanet': analysis,
      'atmakaraka': charaKarakas.isNotEmpty ? charaKarakas.first.planet : null,
      'darakaraka': charaKarakas.length >= 7 ? charaKarakas.last.planet : null,
    };
  }
}
