/// SVG Chart Parser Service
/// Extracts planet positions, ascendant sign, and nakshatras
/// from South Indian style SVG charts — fully client-side.
///
/// Usage:
/// ```dart
/// final result = SvgChartParser.extractPositions(svgString);
/// print(result.ascendantSign);   // 4 (Cancer)
/// print(result.planetSigns);     // {Su: 8, Mo: 4, ...}
/// print(result.planetsInHouses); // {1: [Mo], 5: [Su], ...}
/// ```
class SvgChartParser {
  // ===========================================================
  // SOUTH INDIAN GRID LAYOUT (Fixed)
  // ===========================================================

  /// South Indian chart grid layout (4x4)
  /// Each cell maps to a zodiac sign (1-12), 0 = center (unused)
  ///
  /// Visual layout:
  /// [Pisces(12)] [Aries(1)]  [Taurus(2)]  [Gemini(3)]
  /// [Aqua(11)]   [  center  ]              [Cancer(4)]
  /// [Capri(10)]  [  center  ]              [Leo(5)]
  /// [Sagi(9)]    [Scorp(8)]  [Libra(7)]   [Virgo(6)]
  static const List<List<int>> southSignGrid = [
    [12, 1, 2, 3], // Row 0
    [11, 0, 0, 4], // Row 1
    [10, 0, 0, 5], // Row 2
    [9, 8, 7, 6], // Row 3
  ];

  /// Valid planet abbreviations from Free Astrology API
  static const List<String> validPlanets = [
    'Su',
    'Mo',
    'Ma',
    'Me',
    'Ju',
    'Ve',
    'Sa',
    'Ra',
    'Ke',
  ];

  /// Zodiac sign names (index 0 = Aries)
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

  /// 27 Nakshatra names
  static const List<String> nakshatraNames = [
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

  /// Nakshatra lords (Vimshottari order)
  static const List<String> nakshatraLords = [
    'Ketu',
    'Venus',
    'Sun',
    'Moon',
    'Mars',
    'Rahu',
    'Jupiter',
    'Saturn',
    'Mercury',
    'Ketu',
    'Venus',
    'Sun',
    'Moon',
    'Mars',
    'Rahu',
    'Jupiter',
    'Saturn',
    'Mercury',
    'Ketu',
    'Venus',
    'Sun',
    'Moon',
    'Mars',
    'Rahu',
    'Jupiter',
    'Saturn',
    'Mercury',
  ];

  // ===========================================================
  // MAIN EXTRACTION METHOD
  // ===========================================================

  /// Extract planet positions, ascendant, and house mappings from SVG.
  ///
  /// This is the primary method for client-side SVG parsing.
  /// It replaces the need for the Flask backend's `extract_positions_from_svg`.
  ///
  /// Algorithm:
  /// 1. Detect chart dimensions from viewBox or width attribute.
  /// 2. Parse all `<text x="X" y="Y">ABBR</text>` elements.
  /// 3. Map (x, y) → grid cell (col, row) using `cellSize = chartWidth / 4`.
  /// 4. Map grid cell → zodiac sign (South Indian fixed layout).
  /// 5. "Asc" text element → identifies ascendant sign.
  /// 6. Planet abbreviations → mapped to their signs.
  /// 7. Calculate houses relative to ascendant.
  static SvgExtractionResult extractPositions(String svg) {
    if (svg.isEmpty || !svg.contains('<svg')) {
      return SvgExtractionResult.empty();
    }

    // 1. Detect chart dimensions
    final chartWidth = _detectChartWidth(svg);
    final cellSize = chartWidth / 4.0;

    // 2. Parse text elements
    final textRegex = RegExp(
      r'<text[^>]*x="([^"]+)"[^>]*y="([^"]+)"[^>]*>([^<]+)</text>',
      caseSensitive: false,
    );

    int ascendantSign = 0;
    final planetSigns = <String, int>{};

    for (final match in textRegex.allMatches(svg)) {
      final x = double.tryParse(match.group(1) ?? '');
      final y = double.tryParse(match.group(2) ?? '');
      final rawText = match.group(3);

      if (x == null || y == null || rawText == null) continue;

      // Clean text: remove parentheses and whitespace
      final text = rawText.replaceAll(RegExp('[()\\s]'), '').trim();

      // 3. Map coordinates to grid cell
      final col = (x / cellSize).floor().clamp(0, 3);
      final row = (y / cellSize).floor().clamp(0, 3);

      // 4. Get sign from grid
      final sign = southSignGrid[row][col];
      if (sign == 0) continue; // Center cells, skip

      // 5. Detect Ascendant
      if (text == 'Asc' ||
          text == 'As' ||
          text == 'ASC' ||
          text == 'Ascendant') {
        ascendantSign = sign;
        continue;
      }

      // 6. Detect planets
      if (validPlanets.contains(text)) {
        planetSigns[text] = sign;
      }
    }

    // 7. Build house-planet mapping
    final planetsInHouses = <int, List<String>>{
      for (int i = 1; i <= 12; i++) i: [],
    };

    if (ascendantSign > 0) {
      for (final entry in planetSigns.entries) {
        final house = signToHouse(entry.value, ascendantSign);
        planetsInHouses[house]!.add(entry.key);
      }
    }

    return SvgExtractionResult(
      ascendantSign: ascendantSign,
      ascendantName:
          ascendantSign > 0 ? signNames[ascendantSign - 1] : 'Unknown',
      planetSigns: planetSigns,
      planetsInHouses: planetsInHouses,
    );
  }

  // ===========================================================
  // LEGACY METHOD (kept for backward compatibility)
  // ===========================================================

  /// Extract house-to-planets mapping from SVG (legacy API).
  ///
  /// Prefer [extractPositions] for new code.
  static Map<int, List<String>> extractHousePlanetsFromSvg(
    String svg,
    int ascendantSign,
  ) {
    final result = extractPositions(svg);

    // If the SVG-detected ascendant differs, recalculate with provided one
    if (ascendantSign > 0 && ascendantSign != result.ascendantSign) {
      final houses = <int, List<String>>{
        for (int i = 1; i <= 12; i++) i: [],
      };
      for (final entry in result.planetSigns.entries) {
        final house = signToHouse(entry.value, ascendantSign);
        houses[house]!.add(entry.key);
      }
      return houses;
    }

    return result.planetsInHouses;
  }

  // ===========================================================
  // NAKSHATRA CALCULATION
  // ===========================================================

  /// Calculate Nakshatra, Pada, and Lord from full degree (0-360).
  ///
  /// Each nakshatra spans 13°20' = 13.3333°
  /// Each pada spans 3°20' = 3.3333°
  ///
  /// Example:
  /// ```dart
  /// final nak = SvgChartParser.calculateNakshatra(216.5);
  /// print(nak.nakshatra);  // "Vishakha"
  /// print(nak.pada);       // 3
  /// print(nak.lord);       // "Jupiter"
  /// ```
  static NakshatraResult calculateNakshatra(double fullDegree) {
    final degree = fullDegree % 360;
    final nakshatraSpan = 360.0 / 27.0; // 13.3333°
    final padaSpan = nakshatraSpan / 4.0; // 3.3333°

    int index = (degree / nakshatraSpan).floor();
    index = index.clamp(0, 26);

    int pada = ((degree % nakshatraSpan) / padaSpan).floor() + 1;
    pada = pada.clamp(1, 4);

    return NakshatraResult(
      nakshatra: nakshatraNames[index],
      pada: pada,
      lord: nakshatraLords[index],
      index: index,
    );
  }

  /// Calculate nakshatras for all planets given their degrees.
  ///
  /// Input: `{'Sun': 216.5, 'Moon': 45.2, ...}`
  /// Output: `{'Sun': NakshatraResult(...), 'Moon': NakshatraResult(...), ...}`
  static Map<String, NakshatraResult> calculateAllNakshatras(
    Map<String, double> planetDegrees,
  ) {
    return planetDegrees.map(
      (planet, degree) => MapEntry(planet, calculateNakshatra(degree)),
    );
  }

  // ===========================================================
  // HELPER METHODS
  // ===========================================================

  /// Detect chart width from SVG viewBox or width attribute.
  static double _detectChartWidth(String svg) {
    // Try viewBox first
    final viewBoxMatch = RegExp(
      r'viewBox="[\d.]+\s+[\d.]+\s+([\d.]+)\s+[\d.]+"',
    ).firstMatch(svg);
    if (viewBoxMatch != null) {
      return double.tryParse(viewBoxMatch.group(1) ?? '') ?? 400.0;
    }

    // Fallback to width attribute
    final widthMatch = RegExp(r'width="([\d.]+)"').firstMatch(svg);
    if (widthMatch != null) {
      return double.tryParse(widthMatch.group(1) ?? '') ?? 400.0;
    }

    return 400.0; // Default
  }

  /// Convert zodiac sign to house number based on ascendant.
  ///
  /// Formula: `house = ((sign - ascSign + 12) % 12) + 1`
  ///
  /// Example: If Ascendant is Cancer (4):
  ///   - Cancer (4) → House 1
  ///   - Leo (5) → House 2
  ///   - Scorpio (8) → House 5
  static int signToHouse(int sign, int ascendantSign) {
    return ((sign - ascendantSign + 12) % 12) + 1;
  }

  /// Convert house number to zodiac sign based on ascendant.
  static int houseToSign(int house, int ascendantSign) {
    return ((house - 1 + ascendantSign - 1) % 12) + 1;
  }

  /// Get sign name from number (1-12).
  static String getSignName(int signNumber) {
    return signNames[(signNumber - 1).clamp(0, 11)];
  }

  /// Get full planet name from abbreviation.
  static String getPlanetName(String abbrev) {
    const planetNameMap = {
      'Su': 'Sun',
      'Mo': 'Moon',
      'Ma': 'Mars',
      'Me': 'Mercury',
      'Ju': 'Jupiter',
      'Ve': 'Venus',
      'Sa': 'Saturn',
      'Ra': 'Rahu',
      'Ke': 'Ketu',
      'Ur': 'Uranus',
      'Pl': 'Pluto',
      'Ne': 'Neptune',
      'Asc': 'Ascendant',
    };
    return planetNameMap[abbrev] ?? abbrev;
  }

  /// Validate SVG chart structure.
  static bool isValidSvgChart(String svg) {
    if (svg.isEmpty) return false;
    if (!svg.contains('<svg')) return false;
    if (!svg.contains('<text')) return false;
    return true;
  }

  /// Extract chart metadata from SVG (if embedded).
  static Map<String, String> extractMetadata(String svg) {
    final metadata = <String, String>{};

    final titleMatch = RegExp(r'<title>([^<]+)</title>').firstMatch(svg);
    if (titleMatch != null) {
      metadata['title'] = titleMatch.group(1) ?? '';
    }

    final descMatch = RegExp(r'<desc>([^<]+)</desc>').firstMatch(svg);
    if (descMatch != null) {
      metadata['description'] = descMatch.group(1) ?? '';
    }

    return metadata;
  }

  // ===========================================================
  // BATCH EXTRACTION (Multiple Divisions)
  // ===========================================================

  /// Extract positions from multiple SVGs (one per divisional chart).
  ///
  /// Input: `{'d1': '<svg>...</svg>', 'd9': '<svg>...</svg>', ...}`
  /// Output: `{'d1': SvgExtractionResult(...), 'd9': SvgExtractionResult(...), ...}`
  static Map<String, SvgExtractionResult> extractAllDivisions(
    Map<String, String> svgsByDivision,
  ) {
    return svgsByDivision.map(
      (division, svg) => MapEntry(division, extractPositions(svg)),
    );
  }

  /// Build a complete kundali data map from SVGs and planet degrees.
  ///
  /// This is the all-in-one client-side method that replaces what
  /// the Flask `/kundali/full` endpoint does.
  ///
  /// [svgsByDivision]: SVG strings keyed by division (e.g. 'd1', 'd9')
  /// [d1PlanetDegrees]: Full degrees from API for D1 planets
  ///
  /// Returns a map ready for `KundaliRecordModel` construction.
  static Map<String, dynamic> buildKundaliData({
    required Map<String, String> svgsByDivision,
    required Map<String, double> d1PlanetDegrees,
  }) {
    // 1. Extract positions from all SVGs
    final extractions = extractAllDivisions(svgsByDivision);

    // 2. Build ascendants map
    final ascendants = <String, int>{};
    for (final entry in extractions.entries) {
      ascendants[entry.key] = entry.value.ascendantSign;
    }

    // 3. Build per-division planet signs
    final planetSignsMap = <String, Map<String, int>>{};
    for (final entry in extractions.entries) {
      planetSignsMap[entry.key] = entry.value.planetSigns;
    }

    // 4. Calculate nakshatras from D1 degrees
    final nakshatras = calculateAllNakshatras(d1PlanetDegrees);
    final planetNakshatras = <String, String>{};
    final planetNakshatraPadas = <String, int>{};
    final planetNakshatraLords = <String, String>{};

    for (final entry in nakshatras.entries) {
      planetNakshatras[entry.key] = entry.value.nakshatra;
      planetNakshatraPadas[entry.key] = entry.value.pada;
      planetNakshatraLords[entry.key] = entry.value.lord;
    }

    return {
      'ascendants': ascendants,
      'planetSigns': planetSignsMap,
      'planetNakshatras': planetNakshatras,
      'planetNakshatraPadas': planetNakshatraPadas,
      'planetNakshatraLords': planetNakshatraLords,
      'extractions': extractions,
    };
  }
}

// ===========================================================
// DATA CLASSES
// ===========================================================

/// Result of extracting positions from a single SVG chart.
class SvgExtractionResult {
  /// Ascendant zodiac sign (1-12, 0 if not detected)
  final int ascendantSign;

  /// Ascendant sign name
  final String ascendantName;

  /// Planet abbreviation → zodiac sign number
  final Map<String, int> planetSigns;

  /// House number → list of planet abbreviations
  final Map<int, List<String>> planetsInHouses;

  const SvgExtractionResult({
    required this.ascendantSign,
    required this.ascendantName,
    required this.planetSigns,
    required this.planetsInHouses,
  });

  factory SvgExtractionResult.empty() => SvgExtractionResult(
        ascendantSign: 0,
        ascendantName: 'Unknown',
        planetSigns: const {},
        planetsInHouses: {for (int i = 1; i <= 12; i++) i: []},
      );

  /// Whether extraction found any data
  bool get hasData => ascendantSign > 0 || planetSigns.isNotEmpty;

  /// Number of planets detected
  int get planetCount => planetSigns.length;

  Map<String, dynamic> toJson() => {
        'ascendant_sign': ascendantSign,
        'ascendant_name': ascendantName,
        'planet_signs': planetSigns,
        'planets_in_houses': planetsInHouses.map(
          (k, v) => MapEntry(k.toString(), v),
        ),
      };

  @override
  String toString() =>
      'SvgExtractionResult(asc=$ascendantName($ascendantSign), '
      'planets=${planetSigns.length})';
}

/// Result of nakshatra calculation for a single degree.
class NakshatraResult {
  /// Nakshatra name (e.g. "Ashwini", "Bharani")
  final String nakshatra;

  /// Pada (1-4)
  final int pada;

  /// Nakshatra lord (e.g. "Ketu", "Venus")
  final String lord;

  /// Nakshatra index (0-26)
  final int index;

  const NakshatraResult({
    required this.nakshatra,
    required this.pada,
    required this.lord,
    required this.index,
  });

  Map<String, dynamic> toJson() => {
        'nakshatra': nakshatra,
        'pada': pada,
        'lord': lord,
        'index': index,
      };

  @override
  String toString() => '$nakshatra Pada $pada (Lord: $lord)';
}
