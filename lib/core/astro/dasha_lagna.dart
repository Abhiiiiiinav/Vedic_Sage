/// Dasha Lagna calculator - Temporary Ascendant concept
/// 
/// During a Mahadasha, the MD lord's house becomes the temporary ascendant (Dasha Lagna).
/// This shifts how we interpret houses and events during that period.

class DashaLagna {
  /// Get Dasha Lagna house number for current Mahadasha
  /// 
  /// [mdLord] - Mahadasha lord planet code (e.g., "Sa" for Saturn)
  /// [planetHouseMap] - Map of planets to their house positions
  /// Returns: House number (1-12) that becomes Dasha Lagna
  static int getDashaLagnaHouse({
    required String mdLord,
    required Map<String, int> planetHouseMap,
  }) {
    // MD lord's house becomes Dasha Lagna
    return planetHouseMap[mdLord] ?? 1;
  }
  
  /// Count house position from Dasha Lagna
  /// 
  /// [dashaLagna] - The Dasha Lagna house (1-12)
  /// [targetHouse] - The house to count to (1-12)
  /// Returns: House number from Dasha Lagna perspective
  /// 
  /// Example: If Dasha Lagna is 10, and target is 4:
  /// → From 10th, 4th house is 7 houses away → returns 7
  static int countFromDashaLagna(int dashaLagna, int targetHouse) {
    // Calculate relative position
    int relativeHouse = ((targetHouse - dashaLagna + 12) % 12);
    
    // Convert 0-11 range to 1-12 range
    return relativeHouse == 0 ? 12 : relativeHouse;
  }
  
  /// Get planet's house position from Dasha Lagna
  /// 
  /// [dashaLagna] - The Dasha Lagna house
  /// [planetCode] - Planet code (e.g., "Ve" for Venus)
  /// [planetHouseMap] - Map of planets to their house positions
  /// Returns: House from Dasha Lagna perspective
  static int getPlanetHouseFromDashaLagna({
    required int dashaLagna,
    required String planetCode,
    required Map<String, int> planetHouseMap,
  }) {
    final originalHouse = planetHouseMap[planetCode] ?? 1;
    return countFromDashaLagna(dashaLagna, originalHouse);
  }
  
  /// Analyze what each house represents from Dasha Lagna perspective
  /// 
  /// [dashaLagna] - The Dasha Lagna house
  /// Returns: Map of original houses to their Dasha Lagna meanings
  static Map<int, String> getHouseMeaningsFromDashaLagna(int dashaLagna) {
    const houseSignifications = {
      1: "Self, identity, health",
      2: "Wealth, family, speech",
      3: "Courage, siblings, skills",
      4: "Home, mother, peace",
      5: "Intelligence, children, creativity",
      6: "Enemies, disease, service",
      7: "Relationships, partnerships",
      8: "Transformation, secrets",
      9: "Fortune, father, dharma",
      10: "Career, status, authority",
      11: "Gains, friendships, ambitions",
      12: "Loss, foreign lands, spirituality",
    };
    
    final result = <int, String>{};
    
    for (int originalHouse = 1; originalHouse <= 12; originalHouse++) {
      final dashaLagnaHouse = countFromDashaLagna(dashaLagna, originalHouse);
      result[originalHouse] = houseSignifications[dashaLagnaHouse]!;
    }
    
    return result;
  }
  
  /// Get interpretation context for MD + AD combination
  /// 
  /// [mdLord] - Mahadasha lord
  /// [adLord] - Antardasha lord
  /// [planetHouseMap] - Planet positions
  /// Returns: Analysis context for interpretation
  static Map<String, dynamic> getDashaContext({
    required String mdLord,
    required String adLord,
    required Map<String, int> planetHouseMap,
  }) {
    final dashaLagna = getDashaLagnaHouse(
      mdLord: mdLord,
      planetHouseMap: planetHouseMap,
    );
    
    final mdHouseFromBirth = planetHouseMap[mdLord] ?? 1;
    final adHouseFromBirth = planetHouseMap[adLord] ?? 1;
    
    final adHouseFromDashaLagna = getPlanetHouseFromDashaLagna(
      dashaLagna: dashaLagna,
      planetCode: adLord,
      planetHouseMap: planetHouseMap,
    );
    
    return {
      'dashaLagna': dashaLagna,
      'mdHouseFromBirth': mdHouseFromBirth,
      'adHouseFromBirth': adHouseFromBirth,
      'adHouseFromDashaLagna': adHouseFromDashaLagna,
      'houseMeanings': getHouseMeaningsFromDashaLagna(dashaLagna),
    };
  }
}
