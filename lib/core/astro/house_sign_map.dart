/// House to Sign mapping (Rashi-based system)
/// 
/// In Vedic astrology, once the Ascendant sign is known,
/// all 12 houses map to signs in sequential order.
/// This is the "Rashi Chart" or "Rasi Chakra".

class HouseSignMap {
  /// Build house-to-sign mapping from Ascendant
  /// 
  /// In Vedic astrology:
  /// - House 1 = Ascendant sign
  /// - House 2 = Next sign
  /// - House 3 = Sign after that
  /// ... and so on in zodiac order
  /// 
  /// [ascSign] - Ascendant sign number (1-12)
  /// Returns: List of 12 sign numbers, where index 0 = House 1
  /// 
  /// Example: If Ascendant  = Leo (5)
  /// Houses: [5, 6, 7, 8, 9, 10, 11, 12, 1, 2, 3, 4]
  static List<int> buildHouseToSign(int ascSign) {
    final houses = List<int>.filled(12, 0);

    for (int i = 0; i < 12; i++) {
      // Calculate sign for each house
      // Wraps around after 12 (Pisces → Aries)
      houses[i] = ((ascSign - 1 + i) % 12) + 1;
    }

    return houses;
  }
  
  /// Find which house a planet is in based on its sign
  /// 
  /// [planetSign] - The sign the planet is in (1-12)
  /// [houseSigns] - The house-to-sign mapping from buildHouseToSign()
  /// Returns: House number (1-12)
  /// 
  /// Example: If Venus is in Libra (7), and Libra is the 3rd house,
  /// this returns 3
  static int signToHouse(int planetSign, List<int> houseSigns) {
    final index = houseSigns.indexOf(planetSign);
    return index + 1; // Convert 0-based index to 1-based house number
  }
  
  /// Get all houses for a specific sign
  /// (Used for checking sign lordships)
  static List<int> getHousesForSign(int signNumber, List<int> houseSigns) {
    final houses = <int>[];
    for (int i = 0; i < houseSigns.length; i++) {
      if (houseSigns[i] == signNumber) {
        houses.add(i + 1);
      }
    }
    return houses;
  }
  
  /// Get sign name
  static String getSignName(int signNumber) {
    const signs = [
      'Aries', 'Taurus', 'Gemini', 'Cancer',
      'Leo', 'Virgo', 'Libra', 'Scorpio',
      'Sagittarius', 'Capricorn', 'Aquarius', 'Pisces'
    ];
    return signs[(signNumber - 1) % 12];
  }
  
  /// Get house name (Sanskrit)
  static String getHouseName(int houseNumber) {
    const houseNames = [
      'Tanu Bhava', 'Dhana Bhava', 'Sahaja Bhava', 'Sukha Bhava',
      'Putra Bhava', 'Ripu Bhava', 'Yuvati Bhava', 'Ayu Bhava',
      'Dharma Bhava', 'Karma Bhava', 'Labha Bhava', 'Vyaya Bhava'
    ];
    return houseNames[(houseNumber - 1) % 12];
  }
}
