/// Static data repository for Vedic yoga combinations
/// 
/// This file contains traditional Vedic astrology combination tables that define
/// when each yoga occurs based on:
/// - Tithi: Lunar day (1-30, where 1-15 are Shukla Paksha, 16-30 are Krishna Paksha)
/// - Nakshatra: Lunar constellation (1-27)
/// - Vara: Weekday (0=Sunday, 1=Monday, 2=Tuesday, 3=Wednesday, 4=Thursday, 5=Friday, 6=Saturday)

/// Represents a combination of Tithi, Vara, and Nakshatra
class YogaCombination {
  final int tithi;
  final int vara;
  final int? nakshatra; // Optional for combinations that don't require nakshatra
  
  const YogaCombination({
    required this.tithi,
    required this.vara,
    this.nakshatra,
  });
  
  /// Check if this combination matches the given panchang values
  bool matches(int tithiValue, int varaValue, int? nakshatraValue) {
    if (tithi != tithiValue || vara != varaValue) {
      return false;
    }
    if (nakshatra != null && nakshatra != nakshatraValue) {
      return false;
    }
    return true;
  }
}

/// Repository class containing all yoga combination tables
class YogaCombinationsData {
  // Cache for indexed lookups (lazy initialization)
  static Map<String, Set<String>>? _amritSiddhiIndex;
  static Map<String, Set<String>>? _siddhaIndex;
  static Map<String, Set<String>>? _mahasiddhiIndex;
  static Map<String, Set<String>>? _sarvarthaSiddhiIndex;
  static Map<String, Set<String>>? _dagdhaIndex;
  static Map<String, Set<String>>? _hutashanaIndex;
  static Map<String, Set<String>>? _vishaIndex;
  
  /// Generate a lookup key from tithi, vara, and optional nakshatra
  static String _makeKey(int tithi, int vara, int? nakshatra) {
    return nakshatra != null 
        ? '$tithi:$vara:$nakshatra' 
        : '$tithi:$vara';
  }
  
  /// Build an index for fast lookups
  static Map<String, Set<String>> _buildIndex(List<YogaCombination> combinations) {
    final index = <String, Set<String>>{};
    
    for (final combo in combinations) {
      final key = _makeKey(combo.tithi, combo.vara, combo.nakshatra);
      
      // Add to tithi-vara index
      final tithiVaraKey = '${combo.tithi}:${combo.vara}';
      index.putIfAbsent(tithiVaraKey, () => <String>{}).add(key);
      
      // Add to full key index
      index.putIfAbsent(key, () => <String>{}).add(key);
    }
    
    return index;
  }
  
  /// Fast lookup using index
  static bool _indexedLookup(
    Map<String, Set<String>>? index,
    List<YogaCombination> combinations,
    int tithi,
    int vara,
    int? nakshatra,
  ) {
    // Build index on first use
    if (index == null) {
      return combinations.any((combo) => combo.matches(tithi, vara, nakshatra));
    }
    
    final key = _makeKey(tithi, vara, nakshatra);
    final tithiVaraKey = '$tithi:$vara';
    
    // Check if combination exists in index
    return index[key]?.isNotEmpty == true || 
           index[tithiVaraKey]?.any((k) => k.startsWith(tithiVaraKey)) == true;
  }
  
  /// Initialize all indexes for optimal performance
  /// Call this once at app startup for best performance
  static void initializeIndexes() {
    _amritSiddhiIndex = _buildIndex(amritSiddhiCombinations);
    _siddhaIndex = _buildIndex(siddhaCombinations);
    _mahasiddhiIndex = _buildIndex(mahasiddhiCombinations);
    _sarvarthaSiddhiIndex = _buildIndex(sarvarthaSiddhiCombinations);
    _dagdhaIndex = _buildIndex(dagdhaCombinations);
    _hutashanaIndex = _buildIndex(hutashanaCombinations);
    _vishaIndex = _buildIndex(vishaCombinations);
  }
  
  // ============================================================================
  // AMRIT SIDDHI YOGA COMBINATIONS
  // ============================================================================
  // Amrit Siddhi is formed by specific Tithi-Vara-Nakshatra triplets
  // These are highly auspicious combinations
  
  static const List<YogaCombination> amritSiddhiCombinations = [
    // Sunday combinations
    YogaCombination(tithi: 1, vara: 0, nakshatra: 11),  // Pratipada + Sunday + Hasta
    YogaCombination(tithi: 2, vara: 0, nakshatra: 13),  // Dwitiya + Sunday + Swati
    YogaCombination(tithi: 3, vara: 0, nakshatra: 8),   // Tritiya + Sunday + Pushya
    YogaCombination(tithi: 7, vara: 0, nakshatra: 21),  // Saptami + Sunday + Uttara Ashadha
    YogaCombination(tithi: 12, vara: 0, nakshatra: 27), // Dwadashi + Sunday + Revati
    
    // Monday combinations
    YogaCombination(tithi: 2, vara: 1, nakshatra: 4),   // Dwitiya + Monday + Rohini
    YogaCombination(tithi: 3, vara: 1, nakshatra: 7),   // Tritiya + Monday + Punarvasu
    YogaCombination(tithi: 7, vara: 1, nakshatra: 13),  // Saptami + Monday + Swati
    YogaCombination(tithi: 11, vara: 1, nakshatra: 22), // Ekadashi + Monday + Shravana
    YogaCombination(tithi: 13, vara: 1, nakshatra: 27), // Trayodashi + Monday + Revati
    
    // Tuesday combinations
    YogaCombination(tithi: 1, vara: 2, nakshatra: 2),   // Pratipada + Tuesday + Bharani
    YogaCombination(tithi: 8, vara: 2, nakshatra: 11),  // Ashtami + Tuesday + Hasta
    YogaCombination(tithi: 13, vara: 2, nakshatra: 3),  // Trayodashi + Tuesday + Krittika
    YogaCombination(tithi: 14, vara: 2, nakshatra: 14), // Chaturdashi + Tuesday + Vishakha
    
    // Wednesday combinations
    YogaCombination(tithi: 4, vara: 3, nakshatra: 9),   // Chaturthi + Wednesday + Ashlesha
    YogaCombination(tithi: 6, vara: 3, nakshatra: 27),  // Shashthi + Wednesday + Revati
    YogaCombination(tithi: 8, vara: 3, nakshatra: 17),  // Ashtami + Wednesday + Anuradha
    YogaCombination(tithi: 12, vara: 3, nakshatra: 10), // Dwadashi + Wednesday + Magha
    
    // Thursday combinations
    YogaCombination(tithi: 4, vara: 4, nakshatra: 8),   // Chaturthi + Thursday + Pushya
    YogaCombination(tithi: 5, vara: 4, nakshatra: 27),  // Panchami + Thursday + Revati
    YogaCombination(tithi: 7, vara: 4, nakshatra: 11),  // Saptami + Thursday + Hasta
    YogaCombination(tithi: 10, vara: 4, nakshatra: 8),  // Dashami + Thursday + Pushya
    YogaCombination(tithi: 13, vara: 4, nakshatra: 8),  // Trayodashi + Thursday + Pushya
    
    // Friday combinations
    YogaCombination(tithi: 2, vara: 5, nakshatra: 27),  // Dwitiya + Friday + Revati
    YogaCombination(tithi: 4, vara: 5, nakshatra: 4),   // Chaturthi + Friday + Rohini
    YogaCombination(tithi: 11, vara: 5, nakshatra: 27), // Ekadashi + Friday + Revati
    YogaCombination(tithi: 12, vara: 5, nakshatra: 27), // Dwadashi + Friday + Revati
    
    // Saturday combinations
    YogaCombination(tithi: 1, vara: 6, nakshatra: 8),   // Pratipada + Saturday + Pushya
    YogaCombination(tithi: 6, vara: 6, nakshatra: 4),   // Shashthi + Saturday + Rohini
    YogaCombination(tithi: 9, vara: 6, nakshatra: 11),  // Navami + Saturday + Hasta
    YogaCombination(tithi: 14, vara: 6, nakshatra: 27), // Chaturdashi + Saturday + Revati
  ];
  
  // ============================================================================
  // SIDDHA YOGA COMBINATIONS
  // ============================================================================
  // Siddha yoga is formed by specific Tithi-Vara-Nakshatra combinations
  
  static const List<YogaCombination> siddhaCombinations = [
    // Sunday combinations
    YogaCombination(tithi: 1, vara: 0, nakshatra: 11),  // Pratipada + Sunday + Hasta
    YogaCombination(tithi: 4, vara: 0, nakshatra: 13),  // Chaturthi + Sunday + Swati
    YogaCombination(tithi: 6, vara: 0, nakshatra: 8),   // Shashthi + Sunday + Pushya
    YogaCombination(tithi: 7, vara: 0, nakshatra: 21),  // Saptami + Sunday + Uttara Ashadha
    
    // Monday combinations
    YogaCombination(tithi: 2, vara: 1, nakshatra: 4),   // Dwitiya + Monday + Rohini
    YogaCombination(tithi: 5, vara: 1, nakshatra: 7),   // Panchami + Monday + Punarvasu
    YogaCombination(tithi: 7, vara: 1, nakshatra: 22),  // Saptami + Monday + Shravana
    YogaCombination(tithi: 13, vara: 1, nakshatra: 27), // Trayodashi + Monday + Revati
    
    // Tuesday combinations
    YogaCombination(tithi: 3, vara: 2, nakshatra: 2),   // Tritiya + Tuesday + Bharani
    YogaCombination(tithi: 8, vara: 2, nakshatra: 14),  // Ashtami + Tuesday + Vishakha
    YogaCombination(tithi: 13, vara: 2, nakshatra: 3),  // Trayodashi + Tuesday + Krittika
    
    // Wednesday combinations
    YogaCombination(tithi: 4, vara: 3, nakshatra: 9),   // Chaturthi + Wednesday + Ashlesha
    YogaCombination(tithi: 8, vara: 3, nakshatra: 17),  // Ashtami + Wednesday + Anuradha
    YogaCombination(tithi: 12, vara: 3, nakshatra: 10), // Dwadashi + Wednesday + Magha
    
    // Thursday combinations
    YogaCombination(tithi: 5, vara: 4, nakshatra: 27),  // Panchami + Thursday + Revati
    YogaCombination(tithi: 7, vara: 4, nakshatra: 11),  // Saptami + Thursday + Hasta
    YogaCombination(tithi: 10, vara: 4, nakshatra: 8),  // Dashami + Thursday + Pushya
    
    // Friday combinations
    YogaCombination(tithi: 2, vara: 5, nakshatra: 27),  // Dwitiya + Friday + Revati
    YogaCombination(tithi: 11, vara: 5, nakshatra: 4),  // Ekadashi + Friday + Rohini
    
    // Saturday combinations
    YogaCombination(tithi: 1, vara: 6, nakshatra: 8),   // Pratipada + Saturday + Pushya
    YogaCombination(tithi: 9, vara: 6, nakshatra: 11),  // Navami + Saturday + Hasta
  ];
  
  // ============================================================================
  // MAHASIDDHI YOGA COMBINATIONS
  // ============================================================================
  // Mahasiddhi is a rare and powerful yoga
  
  static const List<YogaCombination> mahasiddhiCombinations = [
    // Sunday combinations
    YogaCombination(tithi: 3, vara: 0, nakshatra: 8),   // Tritiya + Sunday + Pushya
    YogaCombination(tithi: 12, vara: 0, nakshatra: 27), // Dwadashi + Sunday + Revati
    
    // Monday combinations
    YogaCombination(tithi: 3, vara: 1, nakshatra: 7),   // Tritiya + Monday + Punarvasu
    YogaCombination(tithi: 11, vara: 1, nakshatra: 22), // Ekadashi + Monday + Shravana
    
    // Tuesday combinations
    YogaCombination(tithi: 1, vara: 2, nakshatra: 2),   // Pratipada + Tuesday + Bharani
    YogaCombination(tithi: 14, vara: 2, nakshatra: 14), // Chaturdashi + Tuesday + Vishakha
    
    // Wednesday combinations
    YogaCombination(tithi: 6, vara: 3, nakshatra: 27),  // Shashthi + Wednesday + Revati
    
    // Thursday combinations
    YogaCombination(tithi: 4, vara: 4, nakshatra: 8),   // Chaturthi + Thursday + Pushya
    YogaCombination(tithi: 13, vara: 4, nakshatra: 8),  // Trayodashi + Thursday + Pushya
    
    // Friday combinations
    YogaCombination(tithi: 4, vara: 5, nakshatra: 4),   // Chaturthi + Friday + Rohini
    YogaCombination(tithi: 12, vara: 5, nakshatra: 27), // Dwadashi + Friday + Revati
    
    // Saturday combinations
    YogaCombination(tithi: 6, vara: 6, nakshatra: 4),   // Shashthi + Saturday + Rohini
    YogaCombination(tithi: 14, vara: 6, nakshatra: 27), // Chaturdashi + Saturday + Revati
  ];

  // ============================================================================
  // SARVARTHA SIDDHI YOGA COMBINATIONS
  // ============================================================================
  // Sarvartha Siddhi means "Success in All Endeavors"
  
  static const List<YogaCombination> sarvarthaSiddhiCombinations = [
    // Sunday combinations
    YogaCombination(tithi: 1, vara: 0, nakshatra: 11),  // Pratipada + Sunday + Hasta
    YogaCombination(tithi: 3, vara: 0, nakshatra: 8),   // Tritiya + Sunday + Pushya
    YogaCombination(tithi: 6, vara: 0, nakshatra: 13),  // Shashthi + Sunday + Swati
    YogaCombination(tithi: 7, vara: 0, nakshatra: 21),  // Saptami + Sunday + Uttara Ashadha
    YogaCombination(tithi: 13, vara: 0, nakshatra: 11), // Trayodashi + Sunday + Hasta
    
    // Monday combinations
    YogaCombination(tithi: 2, vara: 1, nakshatra: 4),   // Dwitiya + Monday + Rohini
    YogaCombination(tithi: 3, vara: 1, nakshatra: 7),   // Tritiya + Monday + Punarvasu
    YogaCombination(tithi: 7, vara: 1, nakshatra: 13),  // Saptami + Monday + Swati
    YogaCombination(tithi: 8, vara: 1, nakshatra: 22),  // Ashtami + Monday + Shravana
    YogaCombination(tithi: 11, vara: 1, nakshatra: 22), // Ekadashi + Monday + Shravana
    YogaCombination(tithi: 13, vara: 1, nakshatra: 27), // Trayodashi + Monday + Revati
    
    // Tuesday combinations
    YogaCombination(tithi: 1, vara: 2, nakshatra: 2),   // Pratipada + Tuesday + Bharani
    YogaCombination(tithi: 3, vara: 2, nakshatra: 2),   // Tritiya + Tuesday + Bharani
    YogaCombination(tithi: 8, vara: 2, nakshatra: 11),  // Ashtami + Tuesday + Hasta
    YogaCombination(tithi: 12, vara: 2, nakshatra: 14), // Dwadashi + Tuesday + Vishakha
    YogaCombination(tithi: 13, vara: 2, nakshatra: 3),  // Trayodashi + Tuesday + Krittika
    
    // Wednesday combinations
    YogaCombination(tithi: 4, vara: 3, nakshatra: 9),   // Chaturthi + Wednesday + Ashlesha
    YogaCombination(tithi: 6, vara: 3, nakshatra: 27),  // Shashthi + Wednesday + Revati
    YogaCombination(tithi: 8, vara: 3, nakshatra: 17),  // Ashtami + Wednesday + Anuradha
    YogaCombination(tithi: 10, vara: 3, nakshatra: 10), // Dashami + Wednesday + Magha
    YogaCombination(tithi: 12, vara: 3, nakshatra: 10), // Dwadashi + Wednesday + Magha
    
    // Thursday combinations
    YogaCombination(tithi: 4, vara: 4, nakshatra: 8),   // Chaturthi + Thursday + Pushya
    YogaCombination(tithi: 5, vara: 4, nakshatra: 27),  // Panchami + Thursday + Revati
    YogaCombination(tithi: 7, vara: 4, nakshatra: 11),  // Saptami + Thursday + Hasta
    YogaCombination(tithi: 10, vara: 4, nakshatra: 8),  // Dashami + Thursday + Pushya
    YogaCombination(tithi: 13, vara: 4, nakshatra: 8),  // Trayodashi + Thursday + Pushya
    YogaCombination(tithi: 14, vara: 4, nakshatra: 27), // Chaturdashi + Thursday + Revati
    
    // Friday combinations
    YogaCombination(tithi: 2, vara: 5, nakshatra: 27),  // Dwitiya + Friday + Revati
    YogaCombination(tithi: 4, vara: 5, nakshatra: 4),   // Chaturthi + Friday + Rohini
    YogaCombination(tithi: 6, vara: 5, nakshatra: 27),  // Shashthi + Friday + Revati
    YogaCombination(tithi: 11, vara: 5, nakshatra: 27), // Ekadashi + Friday + Revati
    YogaCombination(tithi: 12, vara: 5, nakshatra: 27), // Dwadashi + Friday + Revati
    
    // Saturday combinations
    YogaCombination(tithi: 1, vara: 6, nakshatra: 8),   // Pratipada + Saturday + Pushya
    YogaCombination(tithi: 3, vara: 6, nakshatra: 4),   // Tritiya + Saturday + Rohini
    YogaCombination(tithi: 6, vara: 6, nakshatra: 4),   // Shashthi + Saturday + Rohini
    YogaCombination(tithi: 9, vara: 6, nakshatra: 11),  // Navami + Saturday + Hasta
    YogaCombination(tithi: 11, vara: 6, nakshatra: 8),  // Ekadashi + Saturday + Pushya
    YogaCombination(tithi: 14, vara: 6, nakshatra: 27), // Chaturdashi + Saturday + Revati
  ];
  
  // ============================================================================
  // GURU PUSHYA YOGA
  // ============================================================================
  // Guru Pushya is formed when Thursday (Vara 4) coincides with Pushya nakshatra (8)
  // This is a simple rule-based yoga, not a table
  
  /// Check if Guru Pushya yoga is present
  static bool isGuruPushya(int vara, int nakshatra) {
    return vara == 4 && nakshatra == 8; // Thursday + Pushya
  }
  
  // ============================================================================
  // RAVI PUSHYA YOGA
  // ============================================================================
  // Ravi Pushya is formed when Sunday (Vara 0) coincides with Pushya nakshatra (8)
  
  /// Check if Ravi Pushya yoga is present
  static bool isRaviPushya(int vara, int nakshatra) {
    return vara == 0 && nakshatra == 8; // Sunday + Pushya
  }
  
  // ============================================================================
  // DAGDHA TITHI (BURNT) COMBINATIONS
  // ============================================================================
  // Dagdha yoga is formed by specific Tithi-Vara pairs (inauspicious)
  // Nakshatra is not considered for Dagdha
  
  static const List<YogaCombination> dagdhaCombinations = [
    // Sunday combinations
    YogaCombination(tithi: 12, vara: 0), // Dwadashi + Sunday
    
    // Monday combinations
    YogaCombination(tithi: 11, vara: 1), // Ekadashi + Monday
    
    // Tuesday combinations
    YogaCombination(tithi: 5, vara: 2),  // Panchami + Tuesday
    
    // Wednesday combinations
    YogaCombination(tithi: 3, vara: 3),  // Tritiya + Wednesday
    
    // Thursday combinations
    YogaCombination(tithi: 6, vara: 4),  // Shashthi + Thursday
    
    // Friday combinations
    YogaCombination(tithi: 8, vara: 5),  // Ashtami + Friday
    
    // Saturday combinations
    YogaCombination(tithi: 9, vara: 6),  // Navami + Saturday
  ];
  
  // ============================================================================
  // HUTASHANA YOGA COMBINATIONS
  // ============================================================================
  // Hutashana (Fire God) yoga - inauspicious combinations
  
  static const List<YogaCombination> hutashanaCombinations = [
    // Sunday combinations
    YogaCombination(tithi: 4, vara: 0, nakshatra: 3),   // Chaturthi + Sunday + Krittika
    YogaCombination(tithi: 9, vara: 0, nakshatra: 9),   // Navami + Sunday + Ashlesha
    
    // Monday combinations
    YogaCombination(tithi: 5, vara: 1, nakshatra: 14),  // Panchami + Monday + Vishakha
    YogaCombination(tithi: 10, vara: 1, nakshatra: 17), // Dashami + Monday + Anuradha
    
    // Tuesday combinations
    YogaCombination(tithi: 2, vara: 2, nakshatra: 6),   // Dwitiya + Tuesday + Ardra
    YogaCombination(tithi: 7, vara: 2, nakshatra: 9),   // Saptami + Tuesday + Ashlesha
    YogaCombination(tithi: 11, vara: 2, nakshatra: 19), // Ekadashi + Tuesday + Moola
    
    // Wednesday combinations
    YogaCombination(tithi: 1, vara: 3, nakshatra: 5),   // Pratipada + Wednesday + Mrigashira
    YogaCombination(tithi: 9, vara: 3, nakshatra: 14),  // Navami + Wednesday + Vishakha
    
    // Thursday combinations
    YogaCombination(tithi: 3, vara: 4, nakshatra: 6),   // Tritiya + Thursday + Ardra
    YogaCombination(tithi: 8, vara: 4, nakshatra: 19),  // Ashtami + Thursday + Moola
    
    // Friday combinations
    YogaCombination(tithi: 7, vara: 5, nakshatra: 9),   // Saptami + Friday + Ashlesha
    YogaCombination(tithi: 12, vara: 5, nakshatra: 14), // Dwadashi + Friday + Vishakha
    
    // Saturday combinations
    YogaCombination(tithi: 5, vara: 6, nakshatra: 17),  // Panchami + Saturday + Anuradha
    YogaCombination(tithi: 13, vara: 6, nakshatra: 19), // Trayodashi + Saturday + Moola
  ];
  
  // ============================================================================
  // VISHA YOGA COMBINATIONS
  // ============================================================================
  // Visha (Poison) yoga - highly inauspicious combinations
  
  static const List<YogaCombination> vishaCombinations = [
    // Sunday combinations
    YogaCombination(tithi: 8, vara: 0, nakshatra: 9),   // Ashtami + Sunday + Ashlesha
    YogaCombination(tithi: 14, vara: 0, nakshatra: 19), // Chaturdashi + Sunday + Moola
    
    // Monday combinations
    YogaCombination(tithi: 6, vara: 1, nakshatra: 6),   // Shashthi + Monday + Ardra
    YogaCombination(tithi: 12, vara: 1, nakshatra: 9),  // Dwadashi + Monday + Ashlesha
    
    // Tuesday combinations
    YogaCombination(tithi: 4, vara: 2, nakshatra: 19),  // Chaturthi + Tuesday + Moola
    YogaCombination(tithi: 9, vara: 2, nakshatra: 6),   // Navami + Tuesday + Ardra
    
    // Wednesday combinations
    YogaCombination(tithi: 2, vara: 3, nakshatra: 14),  // Dwitiya + Wednesday + Vishakha
    YogaCombination(tithi: 7, vara: 3, nakshatra: 9),   // Saptami + Wednesday + Ashlesha
    YogaCombination(tithi: 13, vara: 3, nakshatra: 19), // Trayodashi + Wednesday + Moola
    
    // Thursday combinations
    YogaCombination(tithi: 1, vara: 4, nakshatra: 6),   // Pratipada + Thursday + Ardra
    YogaCombination(tithi: 11, vara: 4, nakshatra: 14), // Ekadashi + Thursday + Vishakha
    
    // Friday combinations
    YogaCombination(tithi: 3, vara: 5, nakshatra: 9),   // Tritiya + Friday + Ashlesha
    YogaCombination(tithi: 9, vara: 5, nakshatra: 19),  // Navami + Friday + Moola
    
    // Saturday combinations
    YogaCombination(tithi: 2, vara: 6, nakshatra: 14),  // Dwitiya + Saturday + Vishakha
    YogaCombination(tithi: 10, vara: 6, nakshatra: 6),  // Dashami + Saturday + Ardra
    YogaCombination(tithi: 14, vara: 6, nakshatra: 9),  // Chaturdashi + Saturday + Ashlesha
  ];
  
  // ============================================================================
  // VISHTI KARANA (BHADRA) DETECTION
  // ============================================================================
  // Vishti Karana (also called Bhadra) is one of the 11 Karanas
  // It occurs during specific half-tithis and is considered inauspicious
  // 
  // Karana calculation: Each Tithi is divided into 2 Karanas (half-tithis)
  // There are 11 Karanas total: 4 fixed (Shakuni, Chatushpada, Naga, Kimstughna)
  // and 7 movable (Bava, Balava, Kaulava, Taitila, Gara, Vanija, Vishti/Bhadra)
  // 
  // The 7 movable Karanas repeat 8 times in a lunar month (56 half-tithis)
  // Vishti/Bhadra is the 7th in the sequence, so it occurs at:
  // - 2nd half of Chaturthi (4th Tithi)
  // - 2nd half of Ekadashi (11th Tithi)
  // - 2nd half of Ashtadashi (18th Tithi, which is 3rd in Krishna Paksha)
  // - 2nd half of Panchami Krishna (25th Tithi, which is 10th in Krishna Paksha)
  
  /// Tithis where Vishti Karana occurs in the second half
  static const List<int> vishtiKaranaTithis = [
    4,  // Chaturthi (2nd half)
    11, // Ekadashi (2nd half)
    18, // Ashtadashi / Krishna Tritiya (2nd half)
    25, // Krishna Dashami (2nd half)
  ];
  
  /// Check if Vishti Karana (Bhadra) is present
  /// This requires checking if we're in the second half of specific tithis
  /// Note: The actual implementation in the service will need to check
  /// the tithi progress percentage to determine if it's in the 2nd half
  static bool isVishtiKaranaTithi(int tithi) {
    return vishtiKaranaTithis.contains(tithi);
  }
  
  // ============================================================================
  // HELPER METHODS
  // ============================================================================
  
  /// Get all combinations for a specific yoga type
  static List<YogaCombination>? getCombinations(String yogaType) {
    switch (yogaType) {
      case 'amritSiddhi':
        return amritSiddhiCombinations;
      case 'siddha':
        return siddhaCombinations;
      case 'mahasiddhi':
        return mahasiddhiCombinations;
      case 'sarvarthaSiddhi':
        return sarvarthaSiddhiCombinations;
      case 'dagdha':
        return dagdhaCombinations;
      case 'hutashana':
        return hutashanaCombinations;
      case 'visha':
        return vishaCombinations;
      default:
        return null;
    }
  }
  
  /// Check if a combination exists in a list
  static bool hasCombination(
    List<YogaCombination> combinations,
    int tithi,
    int vara,
    int? nakshatra,
  ) {
    return combinations.any((combo) => combo.matches(tithi, vara, nakshatra));
  }
}
