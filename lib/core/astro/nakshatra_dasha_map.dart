/// Nakshatra to Dasha Lord mapping for Vimshottari system
/// 
/// Each of the 27 Nakshatras is ruled by one of the 9 planets in a repeating cycle.
/// This determines the starting Mahadasha at birth based on Moon's Nakshatra.

class NakshatraDashaMap {
  /// Planet codes used in the Dasha system
  /// Ke = Ketu, Ve = Venus, Su = Sun, Mo = Moon, Ma = Mars
  /// Ra = Rahu, Ju = Jupiter, Sa = Saturn, Me = Mercury
  static const List<String> nakshatraDashaLord = [
    // Ashwini to Magha (1-9)
    "Ke", "Ve", "Su", "Mo", "Ma", "Ra", "Ju", "Sa", "Me",
    
    // Purva Phalguni to Jyeshtha (10-18)
    "Ke", "Ve", "Su", "Mo", "Ma", "Ra", "Ju", "Sa", "Me",
    
    // Mula to Revati (19-27)
    "Ke", "Ve", "Su", "Mo", "Ma", "Ra", "Ju", "Sa", "Me",
  ];
  
  /// Full planet names for display
  static const Map<String, String> planetFullNames = {
    "Ke": "Ketu",
    "Ve": "Venus",
    "Su": "Sun",
    "Mo": "Moon",
    "Ma": "Mars",
    "Ra": "Rahu",
    "Ju": "Jupiter",
    "Sa": "Saturn",
    "Me": "Mercury",
  };
  
  /// Get Dasha lord for a given Nakshatra index (0-26)
  static String getDashaLord(int nakshatraIndex) {
    if (nakshatraIndex < 0 || nakshatraIndex > 26) {
      throw ArgumentError('Nakshatra index must be between 0 and 26');
    }
    return nakshatraDashaLord[nakshatraIndex];
  }
  
  /// Get full planet name from code
  static String getFullName(String code) {
    return planetFullNames[code] ?? code;
  }
}
