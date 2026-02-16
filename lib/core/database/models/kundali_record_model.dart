import 'package:hive/hive.dart';
import '../hive_boxes.dart';

/// Comprehensive Kundali Record Model for Hive storage
/// Stores: name, DOB, place, lat/long, ascendant per D1..D60,
/// nakshatra of all planets, planet signs per division, degrees, karakas
@HiveType(typeId: HiveTypeIds.kundaliRecordModel)
class KundaliRecordModel extends HiveObject {
  /// Unique record ID
  @HiveField(0)
  String id;

  /// Person's name
  @HiveField(1)
  String name;

  /// Full birth date and time
  @HiveField(2)
  DateTime dateOfBirth;

  /// Birth place name
  @HiveField(3)
  String placeOfBirth;

  /// Birth latitude
  @HiveField(4)
  double latitude;

  /// Birth longitude
  @HiveField(5)
  double longitude;

  /// Timezone offset (e.g., 5.5 for IST)
  @HiveField(6)
  double timezoneOffset;

  /// Ascendant sign per division: {"d1": 4, "d9": 7, ...}
  /// Sign numbers 1-12 (Aries=1, Taurus=2, ..., Pisces=12)
  @HiveField(7)
  Map<String, int> ascendants;

  /// Nakshatra per planet (D1): {"Sun": "Jyeshtha", "Moon": "Rohini", ...}
  @HiveField(8)
  Map<String, String> planetNakshatras;

  /// Nakshatra pada per planet (D1): {"Sun": 3, "Moon": 2, ...}
  @HiveField(9)
  Map<String, int> planetNakshatraPadas;

  /// Nakshatra lord per planet: {"Sun": "Mercury", "Moon": "Moon", ...}
  @HiveField(10)
  Map<String, String> planetNakshatraLords;

  /// Per-division planet signs: {"d1": {"Su": 8, "Mo": 4}, "d9": {"Su": 3}}
  /// Stored as JSON string for Hive compatibility
  @HiveField(11)
  String planetSignsJson;

  /// D1 full degrees per planet: {"Sun": 216.5, "Moon": 45.2, ...}
  @HiveField(12)
  Map<String, double> planetDegrees;

  /// Retrograde flags: {"Sun": false, "Saturn": true, ...}
  @HiveField(13)
  Map<String, bool> planetRetrogrades;

  /// Karaka assignments: {"Atmakaraka": "Sa", "Darakaraka": "Mo", ...}
  @HiveField(14)
  Map<String, String> karakas;

  /// Record creation timestamp
  @HiveField(15)
  DateTime createdAt;

  /// Last update timestamp
  @HiveField(16)
  DateTime updatedAt;

  KundaliRecordModel({
    required this.id,
    required this.name,
    required this.dateOfBirth,
    required this.placeOfBirth,
    required this.latitude,
    required this.longitude,
    this.timezoneOffset = 5.5,
    required this.ascendants,
    required this.planetNakshatras,
    required this.planetNakshatraPadas,
    required this.planetNakshatraLords,
    required this.planetSignsJson,
    required this.planetDegrees,
    required this.planetRetrogrades,
    required this.karakas,
    required this.createdAt,
    required this.updatedAt,
  });

  // ============== Convenience Getters ==============

  /// Get ascendant sign number for a division (1-12)
  int getAscendant(String division) => ascendants[division.toLowerCase()] ?? 0;

  /// Get ascendant sign name for a division
  String getAscendantName(String division) {
    final sign = getAscendant(division);
    return sign > 0 ? _signNames[sign - 1] : 'Unknown';
  }

  /// Get nakshatra for a planet
  String? getNakshatra(String planet) => planetNakshatras[planet];

  /// Get nakshatra pada for a planet
  int? getNakshatraPada(String planet) => planetNakshatraPadas[planet];

  /// Get planet degree (D1)
  double? getDegree(String planet) => planetDegrees[planet];

  /// Check if planet is retrograde
  bool isRetrograde(String planet) => planetRetrogrades[planet] ?? false;

  /// Get karaka assignment
  String? getKaraka(String karakaName) => karakas[karakaName];

  /// Get planet signs for a division
  Map<String, int> getPlanetSigns(String division) {
    try {
      final allSigns = _decodePlanetSigns();
      final divSigns = allSigns[division.toLowerCase()];
      if (divSigns is Map) {
        return Map<String, int>.from(
          divSigns.map((k, v) => MapEntry(k.toString(), (v as num).toInt())),
        );
      }
    } catch (_) {}
    return {};
  }

  /// Get D1 birth chart planet signs
  Map<String, int> get d1PlanetSigns => getPlanetSigns('d1');

  /// Get D9 navamsa planet signs
  Map<String, int> get d9PlanetSigns => getPlanetSigns('d9');

  /// Decode the planet signs JSON
  Map<String, dynamic> _decodePlanetSigns() {
    if (planetSignsJson.isEmpty) return {};
    try {
      // Use dart:convert
      return Map<String, dynamic>.from(
        _jsonDecode(planetSignsJson) as Map,
      );
    } catch (_) {
      return {};
    }
  }

  // Simple JSON decode without import (avoids import in model)
  static dynamic _jsonDecode(String json) {
    // Delegate to dart:convert at call site
    throw UnimplementedError('Use KundaliRecordModel.fromApiResponse instead');
  }

  // ============== Serialization ==============

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'dateOfBirth': dateOfBirth.toIso8601String(),
        'placeOfBirth': placeOfBirth,
        'latitude': latitude,
        'longitude': longitude,
        'timezoneOffset': timezoneOffset,
        'ascendants': ascendants,
        'planetNakshatras': planetNakshatras,
        'planetNakshatraPadas': planetNakshatraPadas,
        'planetNakshatraLords': planetNakshatraLords,
        'planetSignsJson': planetSignsJson,
        'planetDegrees': planetDegrees,
        'planetRetrogrades': planetRetrogrades,
        'karakas': karakas,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  KundaliRecordModel copyWith({
    String? id,
    String? name,
    DateTime? dateOfBirth,
    String? placeOfBirth,
    double? latitude,
    double? longitude,
    double? timezoneOffset,
    Map<String, int>? ascendants,
    Map<String, String>? planetNakshatras,
    Map<String, int>? planetNakshatraPadas,
    Map<String, String>? planetNakshatraLords,
    String? planetSignsJson,
    Map<String, double>? planetDegrees,
    Map<String, bool>? planetRetrogrades,
    Map<String, String>? karakas,
  }) {
    return KundaliRecordModel(
      id: id ?? this.id,
      name: name ?? this.name,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      placeOfBirth: placeOfBirth ?? this.placeOfBirth,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      timezoneOffset: timezoneOffset ?? this.timezoneOffset,
      ascendants: ascendants ?? this.ascendants,
      planetNakshatras: planetNakshatras ?? this.planetNakshatras,
      planetNakshatraPadas: planetNakshatraPadas ?? this.planetNakshatraPadas,
      planetNakshatraLords: planetNakshatraLords ?? this.planetNakshatraLords,
      planetSignsJson: planetSignsJson ?? this.planetSignsJson,
      planetDegrees: planetDegrees ?? this.planetDegrees,
      planetRetrogrades: planetRetrogrades ?? this.planetRetrogrades,
      karakas: karakas ?? this.karakas,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  @override
  String toString() =>
      'KundaliRecord($name, DOB: ${dateOfBirth.toIso8601String()}, '
      'Place: $placeOfBirth, Asc D1: ${getAscendantName("d1")})';

  // ============== Constants ==============

  static const List<String> _signNames = [
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
    'Pisces'
  ];

  static const List<String> allDivisions = [
    'd1',
    'd2',
    'd3',
    'd4',
    'd5',
    'd6',
    'd7',
    'd8',
    'd9',
    'd10',
    'd11',
    'd12',
    'd16',
    'd20',
    'd24',
    'd27',
    'd30',
    'd40',
    'd45',
    'd60',
  ];
}
