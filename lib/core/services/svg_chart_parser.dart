/// SVG Chart Parser Service
/// Extracts planet positions from South Indian style SVG charts
/// and maps them to houses based on ascendant sign
class SvgChartParser {
  /// South Indian chart grid layout (4x4)
  /// Each cell maps to a zodiac sign (1-12), 0 = center (unused)
  /// 
  /// Visual layout:
  /// [Pisces(12)] [Aries(1)]  [Taurus(2)]  [Gemini(3)]
  /// [Aqua(11)]   [  center  ]              [Cancer(4)]
  /// [Capri(10)]  [  center  ]              [Leo(5)]
  /// [Sagi(9)]    [Scorp(8)]  [Libra(7)]   [Virgo(6)]
  static const List<List<int>> southSignGrid = [
    [12, 1, 2, 3],   // Row 0
    [11, 0, 0, 4],   // Row 1
    [10, 0, 0, 5],   // Row 2
    [9, 8, 7, 6],    // Row 3
  ];

  /// Cell size in SVG (100x100 for 400x400 chart)
  static const double cellSize = 100.0;

  /// Valid planet abbreviations from Free Astrology API
  static const List<String> validPlanets = [
    'Su', 'Mo', 'Ma', 'Me', 'Ju', 'Ve', 'Sa', 'Ra', 'Ke',
    'Ur', 'Pl', 'Ne', 'Asc'
  ];

  /// Extract house-to-planets mapping from SVG
  /// 
  /// This is the CORRECT way to bind SVG to houses:
  /// 1. Parse SVG text elements (x, y coordinates)
  /// 2. Map coordinates to grid cells
  /// 3. Map cells to zodiac signs (fixed)
  /// 4. Convert signs to houses using ascendant (dynamic)
  /// 
  /// Returns: Map<houseNumber, List<planetAbbreviations>>
  static Map<int, List<String>> extractHousePlanetsFromSvg(
    String svg,
    int ascendantSign, // 1..12 (Aries=1, Taurus=2, etc.)
  ) {
    // Initialize empty houses
    final Map<int, List<String>> housePlanets = {
      for (int i = 1; i <= 12; i++) i: []
    };

    // Regex to extract text elements with x, y coordinates
    // Matches: <text x="150" y="50">Su</text>
    final regex = RegExp(
      r'<text[^>]*x="([^"]+)"[^>]*y="([^"]+)"[^>]*>([^<]+)</text>',
      caseSensitive: false,
    );

    for (final match in regex.allMatches(svg)) {
      final x = double.tryParse(match.group(1) ?? '');
      final y = double.tryParse(match.group(2) ?? '');
      final rawText = match.group(3)?.replaceAll(RegExp(r'[()\s]'), '');

      if (x == null || y == null || rawText == null) continue;

      // Only process valid planet abbreviations
      if (!validPlanets.contains(rawText)) continue;

      // Convert SVG coordinates to grid position
      final col = (x / cellSize).floor().clamp(0, 3);
      final row = (y / cellSize).floor().clamp(0, 3);

      // Get zodiac sign from grid
      final sign = southSignGrid[row][col];
      if (sign == 0) continue; // Skip center cells

      // Convert sign to house based on ascendant
      final house = _signToHouse(sign, ascendantSign);

      // Add planet to house
      housePlanets[house]!.add(rawText);
    }

    return housePlanets;
  }

  /// Convert zodiac sign to house number based on ascendant
  /// 
  /// Formula: house = ((sign - ascSign + 12) % 12) + 1
  /// 
  /// Example: If Ascendant is Aries (1):
  ///   - Aries (1) → House 1
  ///   - Taurus (2) → House 2
  ///   - Gemini (3) → House 3
  ///   etc.
  /// 
  /// Example: If Ascendant is Cancer (4):
  ///   - Cancer (4) → House 1
  ///   - Leo (5) → House 2
  ///   - Virgo (6) → House 3
  ///   etc.
  static int _signToHouse(int sign, int ascendantSign) {
    return ((sign - ascendantSign + 12) % 12) + 1;
  }

  /// Get sign name from number
  static String getSignName(int signNumber) {
    const signs = [
      'Aries', 'Taurus', 'Gemini', 'Cancer', 'Leo', 'Virgo',
      'Libra', 'Scorpio', 'Sagittarius', 'Capricorn', 'Aquarius', 'Pisces'
    ];
    return signs[(signNumber - 1).clamp(0, 11)];
  }

  /// Get full planet name from abbreviation
  static String getPlanetName(String abbrev) {
    const planetNames = {
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
    return planetNames[abbrev] ?? abbrev;
  }

  /// Validate SVG chart structure
  static bool isValidSvgChart(String svg) {
    if (svg.isEmpty) return false;
    if (!svg.contains('<svg')) return false;
    if (!svg.contains('<text')) return false;
    return true;
  }

  /// Extract chart metadata from SVG (if embedded)
  static Map<String, String> extractMetadata(String svg) {
    final metadata = <String, String>{};
    
    // Try to extract title/description if present
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
}
