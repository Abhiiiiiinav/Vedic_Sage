import '../models/yoga_models.dart';
import '../data/yoga_combinations_data.dart';
import 'panchang_service.dart';
import 'yoga_cache_service.dart';

/// Service for detecting Vedic special combinations (yogas)
/// 
/// This service integrates with PanchangService to get Tithi, Nakshatra, and Vara
/// values, then matches them against yoga combination tables to detect active yogas.
/// Results are cached to avoid redundant calculations.
class YogaDetectionService {
  final YogaCacheService _cache = YogaCacheService();
  
  /// Detect all yogas for a given date and location
  /// 
  /// Parameters:
  /// - [date]: The date and time to check for yogas
  /// - [latitude]: Geographic latitude
  /// - [longitude]: Geographic longitude
  /// - [timezone]: Timezone offset in hours
  /// - [useCache]: Whether to use cached results (default: true)
  /// 
  /// Returns a list of all detected yogas for the given date/time
  /// 
  /// Throws:
  /// - [ArgumentError] if date, latitude, longitude, or timezone are invalid
  /// - [Exception] if panchang data cannot be retrieved
  Future<List<YogaResult>> detectYogas({
    required DateTime date,
    required double latitude,
    required double longitude,
    required double timezone,
    bool useCache = true,
  }) async {
    // Validate inputs
    _validateInputs(date, latitude, longitude, timezone);
    
    // Check cache first
    if (useCache) {
      try {
        final cached = _cache.get(
          date: date,
          latitude: latitude,
          longitude: longitude,
          timezone: timezone,
        );
        
        if (cached != null) {
          return cached;
        }
      } catch (e) {
        // Cache errors should not prevent detection, just log and continue
        print('Cache retrieval error: $e');
      }
    }
    
    final List<YogaResult> detectedYogas = [];
    
    try {
      // Get panchang data from PanchangService
      final panchang = PanchangService.getLocalPanchang(
        date: date,
        latitude: latitude,
        longitude: longitude,
        timezone: timezone,
      );
      
      // Validate panchang data structure
      if (!_isValidPanchangData(panchang)) {
        throw Exception('Invalid panchang data structure received');
      }
      
      // Extract values needed for yoga detection with null safety
      final tithiData = panchang['tithi'] as Map<String, dynamic>?;
      final nakshatraData = panchang['nakshatra'] as Map<String, dynamic>?;
      final varaName = panchang['vara'] as String?;
      
      if (tithiData == null || nakshatraData == null || varaName == null) {
        throw Exception('Missing required panchang data (tithi, nakshatra, or vara)');
      }
      
      // Convert to numeric indices (1-based for tithi/nakshatra, 0-based for vara)
      final tithiNumber = tithiData['lunarDay'] as int?;
      final nakshatraNumber = nakshatraData['number'] as int?;
      
      if (tithiNumber == null || nakshatraNumber == null) {
        throw Exception('Invalid tithi or nakshatra number in panchang data');
      }
      
      // Validate ranges
      if (tithiNumber < 1 || tithiNumber > 30) {
        throw Exception('Tithi number out of valid range (1-30): $tithiNumber');
      }
      
      if (nakshatraNumber < 1 || nakshatraNumber > 27) {
        throw Exception('Nakshatra number out of valid range (1-27): $nakshatraNumber');
      }
      
      final varaNumber = _getVaraNumber(varaName); // 0-6 (0=Sunday)
      
      // Get string names for YogaResult with fallback
      final tithiName = tithiData['name'] as String? ?? 'Unknown Tithi';
      final nakshatraName = nakshatraData['name'] as String? ?? 'Unknown Nakshatra';
    
    // Check each yoga type
    
    // 1. Amrit Siddhi Yoga
    if (_checkCombination(
      YogaCombinationsData.amritSiddhiCombinations,
      tithiNumber,
      varaNumber,
      nakshatraNumber,
    )) {
      detectedYogas.add(_createYogaResult(
        YogaType.amritSiddhi,
        date,
        tithiName,
        nakshatraName,
        varaName,
      ));
    }
    
    // 2. Siddha Yoga
    if (_checkCombination(
      YogaCombinationsData.siddhaCombinations,
      tithiNumber,
      varaNumber,
      nakshatraNumber,
    )) {
      detectedYogas.add(_createYogaResult(
        YogaType.siddha,
        date,
        tithiName,
        nakshatraName,
        varaName,
      ));
    }
    
    // 3. Mahasiddhi Yoga
    if (_checkCombination(
      YogaCombinationsData.mahasiddhiCombinations,
      tithiNumber,
      varaNumber,
      nakshatraNumber,
    )) {
      detectedYogas.add(_createYogaResult(
        YogaType.mahasiddhi,
        date,
        tithiName,
        nakshatraName,
        varaName,
      ));
    }
    
    // 4. Sarvartha Siddhi Yoga
    if (_checkCombination(
      YogaCombinationsData.sarvarthaSiddhiCombinations,
      tithiNumber,
      varaNumber,
      nakshatraNumber,
    )) {
      detectedYogas.add(_createYogaResult(
        YogaType.sarvarthaSiddhi,
        date,
        tithiName,
        nakshatraName,
        varaName,
      ));
    }
    
    // 5. Guru Pushya Yoga (Thursday + Pushya nakshatra)
    if (YogaCombinationsData.isGuruPushya(varaNumber, nakshatraNumber)) {
      detectedYogas.add(_createYogaResult(
        YogaType.guruPushya,
        date,
        tithiName,
        nakshatraName,
        varaName,
      ));
    }
    
    // 6. Ravi Pushya Yoga (Sunday + Pushya nakshatra)
    if (YogaCombinationsData.isRaviPushya(varaNumber, nakshatraNumber)) {
      detectedYogas.add(_createYogaResult(
        YogaType.raviPushya,
        date,
        tithiName,
        nakshatraName,
        varaName,
      ));
    }
    
    // 7. Dagdha Yoga (inauspicious)
    if (_checkCombination(
      YogaCombinationsData.dagdhaCombinations,
      tithiNumber,
      varaNumber,
      null, // Dagdha doesn't require nakshatra
    )) {
      detectedYogas.add(_createYogaResult(
        YogaType.dagdha,
        date,
        tithiName,
        nakshatraName,
        varaName,
      ));
    }
    
    // 8. Hutashana Yoga (inauspicious)
    if (_checkCombination(
      YogaCombinationsData.hutashanaCombinations,
      tithiNumber,
      varaNumber,
      nakshatraNumber,
    )) {
      detectedYogas.add(_createYogaResult(
        YogaType.hutashana,
        date,
        tithiName,
        nakshatraName,
        varaName,
      ));
    }
    
    // 9. Visha Yoga (inauspicious)
    if (_checkCombination(
      YogaCombinationsData.vishaCombinations,
      tithiNumber,
      varaNumber,
      nakshatraNumber,
    )) {
      detectedYogas.add(_createYogaResult(
        YogaType.visha,
        date,
        tithiName,
        nakshatraName,
        varaName,
      ));
    }
    
    // 10. Vishti Karana (Bhadra) - inauspicious
    // Note: This is a simplified check. Full implementation would need
    // to check if we're in the second half of the tithi
    if (YogaCombinationsData.isVishtiKaranaTithi(tithiNumber)) {
      detectedYogas.add(_createYogaResult(
        YogaType.vishtiKarana,
        date,
        tithiName,
        nakshatraName,
        varaName,
      ));
    }
    
    // Cache the results before returning
    if (useCache) {
      try {
        _cache.put(
          date: date,
          latitude: latitude,
          longitude: longitude,
          timezone: timezone,
          results: detectedYogas,
        );
      } catch (e) {
        // Cache errors should not prevent returning results
        print('Cache storage error: $e');
      }
    }
    
    return detectedYogas;
    } catch (e) {
      // Wrap any errors with context
      throw Exception('Failed to detect yogas: ${e.toString()}');
    }
  }
  
  /// Validate input parameters
  void _validateInputs(DateTime date, double latitude, double longitude, double timezone) {
    // Validate date range (reasonable range for astronomical calculations)
    final minDate = DateTime(1900, 1, 1);
    final maxDate = DateTime(2100, 12, 31);
    
    if (date.isBefore(minDate) || date.isAfter(maxDate)) {
      throw ArgumentError(
        'Date must be between ${minDate.year} and ${maxDate.year}',
      );
    }
    
    // Validate latitude (-90 to +90)
    if (latitude < -90 || latitude > 90) {
      throw ArgumentError(
        'Latitude must be between -90 and +90 degrees, got: $latitude',
      );
    }
    
    // Validate longitude (-180 to +180)
    if (longitude < -180 || longitude > 180) {
      throw ArgumentError(
        'Longitude must be between -180 and +180 degrees, got: $longitude',
      );
    }
    
    // Validate timezone (-12 to +14)
    if (timezone < -12 || timezone > 14) {
      throw ArgumentError(
        'Timezone must be between -12 and +14 hours, got: $timezone',
      );
    }
  }
  
  /// Validate panchang data structure
  bool _isValidPanchangData(Map<String, dynamic> panchang) {
    // Check for required keys
    if (!panchang.containsKey('tithi') || 
        !panchang.containsKey('nakshatra') || 
        !panchang.containsKey('vara')) {
      return false;
    }
    
    // Check that tithi and nakshatra are maps
    if (panchang['tithi'] is! Map || panchang['nakshatra'] is! Map) {
      return false;
    }
    
    // Check that vara is a string
    if (panchang['vara'] is! String) {
      return false;
    }
    
    return true;
  }
  
  /// Check if a combination exists in the given list
  bool _checkCombination(
    List<YogaCombination> combinations,
    int tithi,
    int vara,
    int? nakshatra,
  ) {
    return combinations.any((combo) => combo.matches(tithi, vara, nakshatra));
  }
  
  /// Create a YogaResult object
  YogaResult _createYogaResult(
    YogaType type,
    DateTime date,
    String tithi,
    String nakshatra,
    String vara,
  ) {
    return YogaResult(
      type: type,
      definition: YogaDefinitions.getDefinition(type),
      activeDate: date,
      tithi: tithi,
      nakshatra: nakshatra,
      vara: vara,
    );
  }
  
  /// Convert weekday name to numeric index (0=Sunday, 6=Saturday)
  int _getVaraNumber(String varaName) {
    const varaMap = {
      'Sunday': 0,
      'Monday': 1,
      'Tuesday': 2,
      'Wednesday': 3,
      'Thursday': 4,
      'Friday': 5,
      'Saturday': 6,
    };
    return varaMap[varaName] ?? 0;
  }
}
