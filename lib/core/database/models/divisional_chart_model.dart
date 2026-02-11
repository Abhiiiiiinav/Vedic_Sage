import 'package:hive/hive.dart';

/// Divisional Chart Model for Hive storage
/// Stores complete chart data including SVG, planets, houses, and metadata
/// 
/// This model follows the CORRECT architecture:
/// Birth Data → Engine/API → Planet Data → Hive → SVG Renderer
@HiveType(typeId: 10) // New type ID for divisional charts
class DivisionalChartModel extends HiveObject {
  /// Chart type (d1, d2, d3, d9, d10, etc.)
  @HiveField(0)
  String chartType;

  /// Ascendant sign number (1-12)
  @HiveField(1)
  int ascendantSign;

  /// House to planets mapping
  /// Key: House number (1-12)
  /// Value: List of planet abbreviations in that house
  @HiveField(2)
  Map<int, List<String>> housePlanets;

  /// Raw SVG string from API
  @HiveField(3)
  String svg;

  /// Profile ID this chart belongs to
  @HiveField(4)
  String profileId;

  /// Chart name (e.g., "Rasi Chart", "Navamsa Chart")
  @HiveField(5)
  String chartName;

  /// Creation timestamp
  @HiveField(6)
  DateTime createdAt;

  /// Last updated timestamp
  @HiveField(7)
  DateTime updatedAt;

  /// Optional: Planet positions (degrees)
  /// Key: Planet name
  /// Value: Longitude in degrees (0-360)
  @HiveField(8)
  Map<String, double>? planetDegrees;

  /// Optional: Additional metadata
  @HiveField(9)
  Map<String, dynamic>? metadata;

  DivisionalChartModel({
    required this.chartType,
    required this.ascendantSign,
    required this.housePlanets,
    required this.svg,
    required this.profileId,
    required this.chartName,
    required this.createdAt,
    required this.updatedAt,
    this.planetDegrees,
    this.metadata,
  });

  /// Get chart display name
  String get displayName {
    const chartNames = {
      'd1': 'Rasi Chart (Birth Chart)',
      'd2': 'Hora Chart',
      'd3': 'Drekkana Chart',
      'd4': 'Chaturthamsa Chart',
      'd7': 'Saptamsa Chart',
      'd9': 'Navamsa Chart',
      'd10': 'Dasamsa Chart',
      'd12': 'Dwadasamsa Chart',
      'd16': 'Shodasamsa Chart',
      'd20': 'Vimsamsa Chart',
      'd24': 'Siddhamsa Chart',
      'd27': 'Nakshatramsa Chart',
      'd30': 'Trimsamsa Chart',
      'd40': 'Khavedamsa Chart',
      'd45': 'Akshavedamsa Chart',
      'd60': 'Shashtyamsa Chart',
    };
    return chartNames[chartType] ?? chartName;
  }

  /// Get ascendant sign name
  String get ascendantSignName {
    const signs = [
      'Aries', 'Taurus', 'Gemini', 'Cancer', 'Leo', 'Virgo',
      'Libra', 'Scorpio', 'Sagittarius', 'Capricorn', 'Aquarius', 'Pisces'
    ];
    return signs[(ascendantSign - 1).clamp(0, 11)];
  }

  /// Get planets in a specific house
  List<String> getPlanetsInHouse(int houseNumber) {
    return housePlanets[houseNumber] ?? [];
  }

  /// Check if a planet is in a specific house
  bool isPlanetInHouse(String planetAbbrev, int houseNumber) {
    return housePlanets[houseNumber]?.contains(planetAbbrev) ?? false;
  }

  /// Get house number for a planet
  int? getHouseForPlanet(String planetAbbrev) {
    for (var entry in housePlanets.entries) {
      if (entry.value.contains(planetAbbrev)) {
        return entry.key;
      }
    }
    return null;
  }

  /// Get zodiac sign for a planet
  /// Converts house to sign using ascendant
  /// Returns sign number (1-12): Aries=1, Taurus=2, ..., Pisces=12
  int? getSignForPlanet(String planetAbbrev) {
    final house = getHouseForPlanet(planetAbbrev);
    if (house == null) return null;
    
    // Convert house to sign
    // Formula: sign = (ascendantSign + house - 2) % 12 + 1
    // Example: If Asc=Aries(1) and planet in House 1, sign=Aries(1)
    //          If Asc=Aries(1) and planet in House 2, sign=Taurus(2)
    //          If Asc=Taurus(2) and planet in House 1, sign=Taurus(2)
    final sign = (ascendantSign + house - 2) % 12 + 1;
    return sign;
  }

  /// Get zodiac sign name for a planet
  String? getSignNameForPlanet(String planetAbbrev) {
    final sign = getSignForPlanet(planetAbbrev);
    if (sign == null) return null;
    
    const signs = [
      'Aries', 'Taurus', 'Gemini', 'Cancer', 'Leo', 'Virgo',
      'Libra', 'Scorpio', 'Sagittarius', 'Capricorn', 'Aquarius', 'Pisces'
    ];
    return signs[(sign - 1).clamp(0, 11)];
  }

  /// Get all planets in the chart
  List<String> getAllPlanets() {
    final allPlanets = <String>{};
    for (var planets in housePlanets.values) {
      allPlanets.addAll(planets);
    }
    return allPlanets.toList();
  }

  /// Get empty houses
  List<int> getEmptyHouses() {
    return housePlanets.entries
        .where((entry) => entry.value.isEmpty)
        .map((entry) => entry.key)
        .toList();
  }

  /// Get occupied houses
  List<int> getOccupiedHouses() {
    return housePlanets.entries
        .where((entry) => entry.value.isNotEmpty)
        .map((entry) => entry.key)
        .toList();
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'chartType': chartType,
      'ascendantSign': ascendantSign,
      'ascendantSignName': ascendantSignName,
      'housePlanets': housePlanets.map((k, v) => MapEntry(k.toString(), v)),
      'svg': svg,
      'profileId': profileId,
      'chartName': chartName,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'planetDegrees': planetDegrees,
      'metadata': metadata,
    };
  }

  /// Create from JSON
  factory DivisionalChartModel.fromJson(Map<String, dynamic> json) {
    return DivisionalChartModel(
      chartType: json['chartType'] as String,
      ascendantSign: json['ascendantSign'] as int,
      housePlanets: (json['housePlanets'] as Map<String, dynamic>).map(
        (k, v) => MapEntry(int.parse(k), List<String>.from(v as List)),
      ),
      svg: json['svg'] as String,
      profileId: json['profileId'] as String,
      chartName: json['chartName'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      planetDegrees: json['planetDegrees'] != null
          ? Map<String, double>.from(json['planetDegrees'] as Map)
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Create a copy with updated fields
  DivisionalChartModel copyWith({
    String? chartType,
    int? ascendantSign,
    Map<int, List<String>>? housePlanets,
    String? svg,
    String? profileId,
    String? chartName,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, double>? planetDegrees,
    Map<String, dynamic>? metadata,
  }) {
    return DivisionalChartModel(
      chartType: chartType ?? this.chartType,
      ascendantSign: ascendantSign ?? this.ascendantSign,
      housePlanets: housePlanets ?? this.housePlanets,
      svg: svg ?? this.svg,
      profileId: profileId ?? this.profileId,
      chartName: chartName ?? this.chartName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      planetDegrees: planetDegrees ?? this.planetDegrees,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  String toString() {
    return 'DivisionalChartModel(type: $chartType, asc: $ascendantSignName, planets: ${getAllPlanets().length})';
  }
}
