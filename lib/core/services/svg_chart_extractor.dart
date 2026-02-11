/// SVG Chart Data Extractor - Production-Grade Architecture
/// 
/// CORE PRINCIPLES:
/// ✔ Planet house comes from MATH, not SVG
/// ✔ SVG shows result, never computes it
/// ✔ Signs rotate, houses never rotate
/// ✔ Engine/API is ALWAYS authoritative
/// ✔ Nakshatra computed from degree, not SVG
/// 
/// DATA FLOW:
/// Birth Data → Engine/API → ChartState → SVG Renderer
///                            ↑
///                    Single Source of Truth

/// =============================================================
/// CHART STATE MODEL - Single Source of Truth
/// =============================================================
class ChartState {
  /// Ascendant sign number (1-12, where 1=Aries)
  final int ascSign;
  
  /// House → Sign mapping (House 1 = ascSign, etc.)
  final Map<int, int> houseSigns;
  
  /// Planet → Sign mapping (e.g., 'Su' → 8 for Sun in Scorpio)
  final Map<String, int> planetSigns;
  
  /// Planet → House mapping (computed from signs)
  final Map<String, int> planetHouses;
  
  /// House → List of planets (for rendering)
  final Map<int, List<String>> housePlanets;
  
  /// Detailed planet data
  final List<ExtractedPlanet> planets;
  
  /// Chart type (D1, D9, D10, etc.)
  final String chartType;
  
  /// Extraction timestamp
  final DateTime? extractedAt;

  const ChartState({
    required this.ascSign,
    required this.houseSigns,
    required this.planetSigns,
    required this.planetHouses,
    required this.housePlanets,
    required this.planets,
    this.chartType = 'D1',
    this.extractedAt,
  });

  /// Get sign name for ascendant
  String get ascSignName => ChartConstants.signs[(ascSign - 1).clamp(0, 11)];

  /// Get planets in a specific house
  List<ExtractedPlanet> getPlanetsInHouse(int house) {
    return planets.where((p) => p.houseNumber == house).toList();
  }

  /// Get planet by name or abbreviation
  ExtractedPlanet? getPlanet(String name) {
    final lowerName = name.toLowerCase();
    return planets.cast<ExtractedPlanet?>().firstWhere(
      (p) => p?.name.toLowerCase() == lowerName || 
             p?.abbreviation.toLowerCase() == lowerName,
      orElse: () => null,
    );
  }

  /// Get sign for a house
  String getSignForHouse(int house) {
    final signNum = houseSigns[house] ?? 1;
    return ChartConstants.signs[(signNum - 1).clamp(0, 11)];
  }

  Map<String, dynamic> toMap() => {
    'ascSign': ascSign,
    'ascSignName': ascSignName,
    'chartType': chartType,
    'houseSigns': houseSigns,
    'planetSigns': planetSigns,
    'planetHouses': planetHouses,
    'housePlanets': housePlanets.map((k, v) => MapEntry(k.toString(), v)),
    'planets': planets.map((p) => p.toMap()).toList(),
    'extractedAt': extractedAt?.toIso8601String(),
  };

  @override
  String toString() => 'ChartState $chartType: Asc=$ascSignName, ${planets.length} planets';
}

/// =============================================================
/// EXTRACTED PLANET MODEL
/// =============================================================
class ExtractedPlanet {
  final String name;
  final String abbreviation;
  final String sign;
  final int signNumber;
  final int houseNumber;
  final double fullDegree;
  final double signDegree;
  final bool isRetrograde;
  final String? nakshatra;
  final int? nakshatraPada;
  final String? nakshatraLord;

  const ExtractedPlanet({
    required this.name,
    required this.abbreviation,
    required this.sign,
    required this.signNumber,
    required this.houseNumber,
    required this.fullDegree,
    required this.signDegree,
    this.isRetrograde = false,
    this.nakshatra,
    this.nakshatraPada,
    this.nakshatraLord,
  });

  Map<String, dynamic> toMap() => {
    'name': name,
    'abbreviation': abbreviation,
    'sign': sign,
    'signNumber': signNumber,
    'houseNumber': houseNumber,
    'fullDegree': fullDegree,
    'signDegree': signDegree,
    'isRetrograde': isRetrograde,
    'nakshatra': nakshatra,
    'nakshatraPada': nakshatraPada,
    'nakshatraLord': nakshatraLord,
  };

  @override
  String toString() => '$name in $sign (House $houseNumber)${isRetrograde ? " (R)" : ""}';
}

/// =============================================================
/// CHART CONSTANTS
/// =============================================================
class ChartConstants {
  ChartConstants._();

  static const List<String> signs = [
    'Aries', 'Taurus', 'Gemini', 'Cancer', 'Leo', 'Virgo',
    'Libra', 'Scorpio', 'Sagittarius', 'Capricorn', 'Aquarius', 'Pisces'
  ];

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

  static const Map<String, String> nameToAbbr = {
    'Sun': 'Su',
    'Moon': 'Mo',
    'Mars': 'Ma',
    'Mercury': 'Me',
    'Jupiter': 'Ju',
    'Venus': 'Ve',
    'Saturn': 'Sa',
    'Rahu': 'Ra',
    'Ketu': 'Ke',
    'Ascendant': 'As',
  };

  static const List<String> nakshatras = [
    'Ashwini', 'Bharani', 'Krittika', 'Rohini', 'Mrigashira', 'Ardra',
    'Punarvasu', 'Pushya', 'Ashlesha', 'Magha', 'Purva Phalguni', 'Uttara Phalguni',
    'Hasta', 'Chitra', 'Swati', 'Vishakha', 'Anuradha', 'Jyeshtha',
    'Mula', 'Purva Ashadha', 'Uttara Ashadha', 'Shravana', 'Dhanishta', 'Shatabhisha',
    'Purva Bhadrapada', 'Uttara Bhadrapada', 'Revati'
  ];

  static const List<String> nakshatraLords = [
    'Ketu', 'Venus', 'Sun', 'Moon', 'Mars', 'Rahu',
    'Jupiter', 'Saturn', 'Mercury', 'Ketu', 'Venus', 'Sun',
    'Moon', 'Mars', 'Rahu', 'Jupiter', 'Saturn', 'Mercury',
    'Ketu', 'Venus', 'Sun', 'Moon', 'Mars', 'Rahu',
    'Jupiter', 'Saturn', 'Mercury'
  ];
}

/// =============================================================
/// CHART STATE BUILDER - Deterministic House-Sign Mapping
/// =============================================================
class ChartStateBuilder {
  ChartStateBuilder._();

  /// Build complete chart state from ascendant and planet signs
  /// THIS IS THE AUTHORITATIVE METHOD - No SVG involvement
  static ChartState buildChartState({
    required int ascSign,
    required Map<String, int> planetSigns,
    required List<ExtractedPlanet> planets,
    String chartType = 'D1',
  }) {
    final houseSigns = buildHouseSignMap(ascSign);
    final planetHouses = mapPlanetsToHouses(planetSigns, ascSign);
    final housePlanets = groupPlanetsByHouse(planetHouses);

    return ChartState(
      ascSign: ascSign,
      houseSigns: houseSigns,
      planetSigns: planetSigns,
      planetHouses: planetHouses,
      housePlanets: housePlanets,
      planets: planets,
      chartType: chartType,
      extractedAt: DateTime.now(),
    );
  }

  /// Deterministic House–Sign Mapping (Whole Sign System)
  /// House 1 = Ascendant Sign, House 2 = Next Sign, etc.
  static Map<int, int> buildHouseSignMap(int ascSign) {
    final map = <int, int>{};
    for (int h = 1; h <= 12; h++) {
      // House h has sign = (ascSign + h - 2) % 12 + 1
      map[h] = ((ascSign + h - 2) % 12) + 1;
    }
    return map;
  }

  /// Planet → House Resolver (Computed from Signs, NOT SVG)
  /// This is the ONLY correct way to determine planet houses
  static Map<String, int> mapPlanetsToHouses(
    Map<String, int> planetSigns,
    int ascSign,
  ) {
    final out = <String, int>{};
    planetSigns.forEach((planet, sign) {
      out[planet] = calculateHouseFromSigns(
        planetSign: sign,
        ascSign: ascSign,
      );
    });
    return out;
  }

  /// Calculate house from planet sign and ascendant sign
  /// THIS IS THE ONLY CORRECT FORMULA
  static int calculateHouseFromSigns({
    required int planetSign,
    required int ascSign,
  }) {
    return ((planetSign - ascSign + 12) % 12) + 1;
  }

  /// Group planets by house for rendering
  static Map<int, List<String>> groupPlanetsByHouse(Map<String, int> planetHouses) {
    final houses = <int, List<String>>{
      for (int i = 1; i <= 12; i++) i: <String>[]
    };

    planetHouses.forEach((planet, house) {
      houses[house]!.add(planet);
    });

    return houses;
  }

  /// Get sign number (1-12) from absolute degree (0-360)
  static int getSignFromDegree(double degree) {
    return ((degree % 360) / 30).floor() + 1;
  }

  /// Calculate Nakshatra from degree
  static Map<String, dynamic> calculateNakshatra(double fullDegree) {
    final nakshatraIndex = ((fullDegree % 360) / (360 / 27)).floor();
    final pada = (((fullDegree % (360 / 27)) / (360 / 27 / 4)).floor() + 1).clamp(1, 4);
    
    return {
      'nakshatra': ChartConstants.nakshatras[nakshatraIndex.clamp(0, 26)],
      'pada': pada,
      'lord': ChartConstants.nakshatraLords[nakshatraIndex.clamp(0, 26)],
    };
  }
}

/// =============================================================
/// API DATA EXTRACTOR - Extract from Engine/API Response
/// =============================================================
class ApiChartExtractor {
  ApiChartExtractor._();

  /// Extract ChartState from API planets response
  /// THIS IS THE PRIMARY DATA SOURCE - Always use this
  static ChartState extractFromApiResponse(
    List<dynamic> planetsOutput, {
    String chartType = 'D1',
    int? ascendantSign,
  }) {
    final List<ExtractedPlanet> planets = [];
    final Map<String, int> planetSigns = {};
    int detectedAscSign = ascendantSign ?? 1;

    for (final item in planetsOutput) {
      if (item is! Map) continue;

      item.forEach((key, value) {
        if (value is! Map) return;

        final planetData = value as Map<String, dynamic>;
        final name = planetData['name'] as String? ?? 'Unknown';
        
        // Extract Ascendant sign
        if (name == 'Ascendant' || key == 'ascendant') {
          final signNum = planetData['current_sign'] as int? ?? 
                          planetData['sign_num'] as int? ?? 1;
          detectedAscSign = signNum;
          return;
        }

        // Extract planet details
        final fullDegree = (planetData['fullDegree'] ?? 
                           planetData['full_degree'] ?? 
                           planetData['longitude'] ?? 0.0) as num;
        final normDegree = (planetData['normDegree'] ?? 
                           planetData['sign_degree'] ?? 
                           planetData['norm_degree'] ?? 0.0) as num;
        final signNum = planetData['current_sign'] as int? ?? 
                        planetData['sign_num'] as int? ?? 
                        ChartStateBuilder.getSignFromDegree(fullDegree.toDouble());
        final isRetro = planetData['isRetro'] as bool? ?? 
                        planetData['is_retro'] as bool? ?? false;

        // Get abbreviation
        final abbr = ChartConstants.nameToAbbr[name] ?? name.substring(0, 2);

        // Store planet sign for house calculation
        planetSigns[abbr] = signNum;

        // Calculate nakshatra from degree (NEVER from SVG)
        final nakshatraData = ChartStateBuilder.calculateNakshatra(fullDegree.toDouble());

        // Calculate house (ALWAYS from math)
        final houseNum = ChartStateBuilder.calculateHouseFromSigns(
          planetSign: signNum,
          ascSign: detectedAscSign,
        );

        final planet = ExtractedPlanet(
          name: name,
          abbreviation: abbr,
          sign: ChartConstants.signs[(signNum - 1).clamp(0, 11)],
          signNumber: signNum,
          houseNumber: houseNum,
          fullDegree: fullDegree.toDouble(),
          signDegree: normDegree.toDouble(),
          isRetrograde: isRetro,
          nakshatra: nakshatraData['nakshatra'],
          nakshatraPada: nakshatraData['pada'],
          nakshatraLord: nakshatraData['lord'],
        );

        planets.add(planet);
      });
    }

    // Build complete chart state
    return ChartStateBuilder.buildChartState(
      ascSign: detectedAscSign,
      planetSigns: planetSigns,
      planets: planets,
      chartType: chartType,
    );
  }
}

/// =============================================================
/// SVG RENDERER - Inject Data into SVG (Display Only)
/// =============================================================
class SvgChartRenderer {
  SvgChartRenderer._();

  /// Inject planets into SVG template
  /// SVG MUST have <g id="house-N"> elements
  static String injectPlanetsIntoSvg(
    String svgTemplate,
    Map<int, List<String>> housePlanets,
  ) {
    String result = svgTemplate;

    housePlanets.forEach((house, planets) {
      final content = planets.map((p) => 
        '<text class="planet" fill="#FFD700">$p</text>'
      ).join('\n');

      // Replace house group content
      result = result.replaceAllMapped(
        RegExp(r'<g\s+id="house-' + house.toString() + r'"[^>]*>([\s\S]*?)</g>'),
        (match) => '<g id="house-$house">$content</g>',
      );
    });

    return result;
  }

  /// Inject signs into SVG template
  static String injectSignsIntoSvg(
    String svg,
    Map<int, int> houseSigns,
  ) {
    houseSigns.forEach((house, signNum) {
      final signName = ChartConstants.signs[(signNum - 1).clamp(0, 11)];
      svg = svg.replaceAllMapped(
        RegExp(r'<text\s+id="sign-' + house.toString() + r'"[^>]*>.*?</text>'),
        (match) => '<text id="sign-$house" fill="#FFFFFF">$signName</text>',
      );
    });
    return svg;
  }

  /// Complete SVG rendering with planets and signs
  static String renderChart(String svgTemplate, ChartState chartState) {
    var svg = injectPlanetsIntoSvg(svgTemplate, chartState.housePlanets);
    svg = injectSignsIntoSvg(svg, chartState.houseSigns);
    return svg;
  }
}

/// =============================================================
/// SVG PARSER - For Debug/Validation Only
/// =============================================================
class SvgChartParser {
  SvgChartParser._();

  /// Extract planets from SVG for VALIDATION ONLY
  /// This should NEVER be used to determine actual planet positions
  /// Use this only for debugging or validating SVG rendering
  static Map<int, List<String>> extractPlanetsFromSvg(String svg) {
    final Map<int, List<String>> housePlanets = {
      for (int i = 1; i <= 12; i++) i: [],
    };

    // Look for house groups with proper IDs
    final houseBlockPattern = RegExp(
      r'<g[^>]*id="house-(\d+)"[^>]*>([\s\S]*?)</g>',
      caseSensitive: false,
    );

    final planetPattern = RegExp(r'>(Su|Mo|Ma|Me|Ju|Ve|Sa|Ra|Ke)<');

    for (final houseMatch in houseBlockPattern.allMatches(svg)) {
      final house = int.tryParse(houseMatch.group(1) ?? '0') ?? 0;
      if (house < 1 || house > 12) continue;
      
      final content = houseMatch.group(2) ?? '';

      for (final p in planetPattern.allMatches(content)) {
        final planet = p.group(1);
        if (planet != null) {
          housePlanets[house]!.add(planet);
        }
      }
    }

    return housePlanets;
  }

  /// Validate that SVG matches chart state
  /// Returns list of mismatches for debugging
  static List<String> validateSvgAgainstState(String svg, ChartState state) {
    final svgPlanets = extractPlanetsFromSvg(svg);
    final mismatches = <String>[];

    state.housePlanets.forEach((house, expectedPlanets) {
      final actualPlanets = svgPlanets[house] ?? [];
      
      for (final planet in expectedPlanets) {
        if (!actualPlanets.contains(planet)) {
          mismatches.add('$planet missing from house $house in SVG');
        }
      }
      
      for (final planet in actualPlanets) {
        if (!expectedPlanets.contains(planet)) {
          mismatches.add('$planet unexpectedly in house $house in SVG');
        }
      }
    });

    return mismatches;
  }
}

/// =============================================================
/// LEGACY COMPATIBILITY - Wrapper for existing code
/// =============================================================
class SvgChartDataExtractor {
  SvgChartDataExtractor._();

  // Expose constants for backward compatibility
  static const List<String> signs = ChartConstants.signs;
  static const Map<String, String> planetAbbreviations = ChartConstants.planetNames;
  static const List<String> nakshatras = ChartConstants.nakshatras;
  static const List<String> nakshatraLords = ChartConstants.nakshatraLords;

  /// Extract from API response (legacy wrapper)
  static ExtractedChartData extractFromApiResponse(
    List<dynamic> planetsOutput, {
    String chartType = 'D1',
    int? ascendantSign,
  }) {
    final chartState = ApiChartExtractor.extractFromApiResponse(
      planetsOutput,
      chartType: chartType,
      ascendantSign: ascendantSign,
    );

    return ExtractedChartData(
      chartType: chartState.chartType,
      ascendantSign: chartState.ascSign,
      ascendantSignName: chartState.ascSignName,
      planets: chartState.planets,
      housePlanets: chartState.housePlanets,
      extractedAt: chartState.extractedAt,
    );
  }

  /// Extract from SVG (DEPRECATED - for debug only)
  @Deprecated('SVG should never determine planet positions. Use API data.')
  static Map<int, List<String>> extractPlanetsFromSvg(String svgContent) {
    return SvgChartParser.extractPlanetsFromSvg(svgContent);
  }

  /// Extract complete data (legacy wrapper)
  static ExtractedChartData extractComplete({
    required String svgContent,
    required List<dynamic> apiPlanetsOutput,
    String chartType = 'D1',
  }) {
    // ALWAYS use API data as authoritative source
    return extractFromApiResponse(
      apiPlanetsOutput,
      chartType: chartType,
    );
  }
}

/// Legacy ExtractedChartData for backward compatibility
class ExtractedChartData {
  final String chartType;
  final int ascendantSign;
  final String ascendantSignName;
  final List<ExtractedPlanet> planets;
  final Map<int, List<String>> housePlanets;
  final DateTime? extractedAt;

  ExtractedChartData({
    required this.chartType,
    required this.ascendantSign,
    required this.ascendantSignName,
    required this.planets,
    required this.housePlanets,
    this.extractedAt,
  });

  List<ExtractedPlanet> getPlanetsInHouse(int house) {
    return planets.where((p) => p.houseNumber == house).toList();
  }

  ExtractedPlanet? getPlanet(String name) {
    final lowerName = name.toLowerCase();
    return planets.cast<ExtractedPlanet?>().firstWhere(
      (p) => p?.name.toLowerCase() == lowerName || 
             p?.abbreviation.toLowerCase() == lowerName,
      orElse: () => null,
    );
  }

  Map<String, dynamic> toMap() => {
    'chartType': chartType,
    'ascendantSign': ascendantSign,
    'ascendantSignName': ascendantSignName,
    'planets': planets.map((p) => p.toMap()).toList(),
    'housePlanets': housePlanets.map((k, v) => MapEntry(k.toString(), v)),
    'extractedAt': extractedAt?.toIso8601String(),
  };

  @override
  String toString() => 'Chart $chartType: Asc=$ascendantSignName, ${planets.length} planets';
}

/// =============================================================
/// EXTENSION FOR EASY ACCESS FROM CHART DATA MAP
/// =============================================================
extension ChartDataExtraction on Map<String, dynamic> {
  /// Extract chart state from this map
  ChartState? extractChartState() {
    if (!containsKey('apiPlanets') && !containsKey('planets')) {
      return null;
    }

    final planetsData = this['apiPlanets'] ?? this['planets'];
    if (planetsData == null) return null;

    List<dynamic> planetsList;
    if (planetsData is List) {
      planetsList = planetsData;
    } else if (planetsData is Map) {
      planetsList = planetsData.entries.map((e) => {e.key: e.value}).toList();
    } else {
      return null;
    }

    final ascSign = this['ascSignIndex'] as int? ?? 0;

    return ApiChartExtractor.extractFromApiResponse(
      planetsList,
      chartType: 'D1',
      ascendantSign: ascSign + 1,
    );
  }

  /// Legacy wrapper
  ExtractedChartData? extractChartData() {
    final state = extractChartState();
    if (state == null) return null;

    return ExtractedChartData(
      chartType: state.chartType,
      ascendantSign: state.ascSign,
      ascendantSignName: state.ascSignName,
      planets: state.planets,
      housePlanets: state.housePlanets,
      extractedAt: state.extractedAt,
    );
  }

  /// Get planets in a specific house (1-12)
  List<String> getPlanetsInHouse(int house) {
    final state = extractChartState();
    return state?.housePlanets[house] ?? [];
  }

  /// Get sign for a house
  String getSignForHouse(int house) {
    final ascIndex = this['ascSignIndex'] as int? ?? 0;
    final signIndex = (ascIndex + house - 1) % 12;
    return ChartConstants.signs[signIndex];
  }
}
