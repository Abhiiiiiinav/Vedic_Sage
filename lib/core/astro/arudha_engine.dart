/// Arudha Pada Calculation Engine
/// 
/// Calculates all 12 Arudha Padas from a birth chart.
/// Arudha represents the "reflected image" - how the world perceives
/// each area of your life based on house lord placement.
/// 
/// Formula:
/// 1. Find lord of house N
/// 2. Count houses from house N to lord's position = X
/// 3. Count X houses from lord's position = Arudha
/// 4. Special Rule: If result is house 1 or 7 from original, use 10 houses from lord instead

import 'house_sign_map.dart';

class ArudhaPada {
  final int houseNumber;      // Which house this is the Arudha of (1-12)
  final String name;          // e.g., "Arudha Lagna", "Dhana Pada"
  final String abbreviation;  // e.g., "AL", "A2"
  final int signNumber;       // Which sign the Arudha falls in (1-12)
  final String signName;      // e.g., "Aries", "Taurus"
  final int housePosition;    // Which house the Arudha occupies (1-12)

  const ArudhaPada({
    required this.houseNumber,
    required this.name,
    required this.abbreviation,
    required this.signNumber,
    required this.signName,
    required this.housePosition,
  });
  
  @override
  String toString() => '$abbreviation: $signName (House $housePosition)';
}

class ArudhaEngine {
  /// Sign lords mapping (1-indexed: sign 1 = Aries)
  /// Each sign has a planetary lord
  static const Map<int, String> signLords = {
    1: 'Ma',   // Aries - Mars
    2: 'Ve',   // Taurus - Venus
    3: 'Me',   // Gemini - Mercury
    4: 'Mo',   // Cancer - Moon
    5: 'Su',   // Leo - Sun
    6: 'Me',   // Virgo - Mercury
    7: 'Ve',   // Libra - Venus
    8: 'Ma',   // Scorpio - Mars
    9: 'Ju',   // Sagittarius - Jupiter
    10: 'Sa',  // Capricorn - Saturn
    11: 'Sa',  // Aquarius - Saturn
    12: 'Ju',  // Pisces - Jupiter
  };
  
  /// Arudha names for each house
  static const Map<int, Map<String, String>> arudhaNames = {
    1: {'name': 'Arudha Lagna', 'abbr': 'AL'},
    2: {'name': 'Dhana Pada', 'abbr': 'A2'},
    3: {'name': 'Vikrama Pada', 'abbr': 'A3'},
    4: {'name': 'Sukha Pada', 'abbr': 'A4'},
    5: {'name': 'Mantra Pada', 'abbr': 'A5'},
    6: {'name': 'Roga Pada', 'abbr': 'A6'},
    7: {'name': 'Dara Pada', 'abbr': 'A7'},
    8: {'name': 'Mrityu Pada', 'abbr': 'A8'},
    9: {'name': 'Bhagya Pada', 'abbr': 'A9'},
    10: {'name': 'Karma Pada', 'abbr': 'A10'},
    11: {'name': 'Labha Pada', 'abbr': 'A11'},
    12: {'name': 'Vyaya Pada', 'abbr': 'A12'},
  };

  /// Calculate single Arudha Pada
  /// 
  /// [houseNumber] - House to calculate Arudha for (1-12)
  /// [houseSign] - Sign of that house (1-12)
  /// [planetPositions] - Map of planet abbreviations to their sign numbers
  /// [houseSigns] - List of signs for each house (from Ascendant)
  /// 
  /// Returns: Sign number where Arudha falls (1-12)
  static int calculateArudha({
    required int houseNumber,
    required int houseSign,
    required Map<String, int> planetPositions,
    required List<int> houseSigns,
  }) {
    // Step 1: Find the lord of the house's sign
    final lord = signLords[houseSign]!;
    
    // Step 2: Find which sign the lord is placed in
    final lordSign = planetPositions[lord];
    if (lordSign == null) {
      // If we don't have this planet's position, return the house sign itself
      return houseSign;
    }
    
    // Step 3: Count houses from house to lord's sign
    // Formula: (lordSign - houseSign + 12) % 12
    // But we need to count "houses", which is the same as sign difference
    int countFromHouseToLord = ((lordSign - houseSign) % 12);
    if (countFromHouseToLord < 0) countFromHouseToLord += 12;
    if (countFromHouseToLord == 0) countFromHouseToLord = 12; // Same sign = 12th from next
    
    // Step 4: Count same number from lord's sign
    int arudhaSign = ((lordSign - 1 + countFromHouseToLord) % 12) + 1;
    
    // Step 5: Apply exception rules
    // If Arudha falls in the original house (1st from original) or 7th from original,
    // count 10 houses from lord instead
    final distanceFromOriginal = ((arudhaSign - houseSign) % 12);
    if (distanceFromOriginal == 0 || distanceFromOriginal == 6) {
      // Apply 10th house rule
      arudhaSign = ((lordSign - 1 + 9) % 12) + 1; // 10th from lord (0-indexed = +9)
    }
    
    return arudhaSign;
  }
  
  /// Calculate all 12 Arudha Padas
  /// 
  /// [ascendantSign] - Ascendant sign number (1-12)
  /// [planetPositions] - Map of planet abbreviations to their sign numbers
  /// 
  /// Returns: List of 12 ArudhaPada objects
  static List<ArudhaPada> calculateAllArudhas({
    required int ascendantSign,
    required Map<String, int> planetPositions,
  }) {
    final houseSigns = HouseSignMap.buildHouseToSign(ascendantSign);
    final arudhas = <ArudhaPada>[];
    
    for (int house = 1; house <= 12; house++) {
      final houseSign = houseSigns[house - 1];
      
      final arudhaSign = calculateArudha(
        houseNumber: house,
        houseSign: houseSign,
        planetPositions: planetPositions,
        houseSigns: houseSigns,
      );
      
      // Find which house the Arudha sign falls in
      final arudhaHouse = HouseSignMap.signToHouse(arudhaSign, houseSigns);
      
      final names = arudhaNames[house]!;
      arudhas.add(ArudhaPada(
        houseNumber: house,
        name: names['name']!,
        abbreviation: names['abbr']!,
        signNumber: arudhaSign,
        signName: HouseSignMap.getSignName(arudhaSign),
        housePosition: arudhaHouse,
      ));
    }
    
    return arudhas;
  }
  
  /// Calculate Arudhas from chart data
  /// 
  /// [chartData] - Full chart data from ChartProvider
  /// Returns: List of ArudhaPada objects
  static List<ArudhaPada> calculateFromChart(Map<String, dynamic> chartData) {
    // Extract ascendant sign
    final ascDegree = chartData['ascendant'] as double? ?? 0.0;
    final ascendantSign = ((ascDegree / 30).floor() % 12) + 1;
    
    // Extract planet positions (sign numbers)
    final planets = chartData['planets'] as Map<String, dynamic>? ?? {};
    final planetPositions = <String, int>{};
    
    planets.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        final degree = value['longitude'] as double? ?? value['degree'] as double? ?? 0.0;
        planetPositions[key] = ((degree / 30).floor() % 12) + 1;
      }
    });
    
    return calculateAllArudhas(
      ascendantSign: ascendantSign,
      planetPositions: planetPositions,
    );
  }
  
  /// Get Arudha Lagna specifically
  static ArudhaPada? getArudhaLagna(List<ArudhaPada> arudhas) {
    try {
      return arudhas.firstWhere((a) => a.houseNumber == 1);
    } catch (_) {
      return null;
    }
  }
  
  /// Get specific Arudha Pada by house number
  static ArudhaPada? getArudhaPada(List<ArudhaPada> arudhas, int houseNumber) {
    try {
      return arudhas.firstWhere((a) => a.houseNumber == houseNumber);
    } catch (_) {
      return null;
    }
  }
  
  /// Get important Arudhas (commonly used subset)
  static List<ArudhaPada> getImportantArudhas(List<ArudhaPada> arudhas) {
    const importantHouses = [1, 2, 4, 5, 7, 9, 10, 11];
    return arudhas.where((a) => importantHouses.contains(a.houseNumber)).toList();
  }
}
