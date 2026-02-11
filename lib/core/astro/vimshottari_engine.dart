import 'nakshatra_dasha_map.dart';

/// Vimshottari Dasha calculation engine
/// 
/// Calculates Mahadasha and Antardasha periods based on Moon's Nakshatra position.
/// Total cycle = 120 years divided among 9 planets.

class VimshottariEngine {
  /// Dasha duration for each planet in years
  static const Map<String, int> dashaYears = {
    "Ke": 7,   // Ketu
    "Ve": 20,  // Venus
    "Su": 6,   // Sun
    "Mo": 10,  // Moon
    "Ma": 7,   // Mars
    "Ra": 18,  // Rahu
    "Ju": 16,  // Jupiter
    "Sa": 19,  // Saturn
    "Me": 17,  // Mercury
  };
  
  /// Sequence of Dasha lords (fixed order)
  static const List<String> dashaOrder = [
    "Ke", "Ve", "Su", "Mo", "Ma", "Ra", "Ju", "Sa", "Me"
  ];
  
  /// Each Nakshatra spans 13°20' = 13.333 degrees
  static const double nakshatraSpan = 13.333333;
  
  /// Calculate starting Mahadasha and remaining years
  /// 
  /// [moonDegree] - Moon's degree in zodiac (0-360)
  /// Returns: {lord: String, remainingYears: double}
  static Map<String, dynamic> getStartingMahadasha(double moonDegree) {
    // Find Nakshatra index (0-26)
    final nakshatraIndex = (moonDegree / nakshatraSpan).floor();
    
    // Get Dasha lord for this Nakshatra
    final lord = NakshatraDashaMap.getDashaLord(nakshatraIndex);
    
    // Calculate degree within Nakshatra
    final degreeInNakshatra = moonDegree % nakshatraSpan;
    
    // Calculate remaining portion of Nakshatra
    final remainingDegrees = nakshatraSpan - degreeInNakshatra;
    
    // Calculate remaining Dasha years
    final fullYears = dashaYears[lord]!.toDouble();
    final remainingYears = fullYears * (remainingDegrees / nakshatraSpan);
    
    return {
      'lord': lord,
      'remainingYears': remainingYears,
      'fullYears': fullYears,
    };
  }
  
  /// Generate complete Mahadasha timeline from birth
  /// 
  /// [startLord] - Starting Mahadasha lord
  /// [startRemainingYears] - Remaining years in starting MD
  /// Returns list of Mahadasha periods with start and end dates
  static List<Map<String, dynamic>> generateMahadashas({
    required String startLord,
    required double startRemainingYears,
    required DateTime birthDate,
  }) {
    final result = <Map<String, dynamic>>[];
    var currentDate = birthDate;
    
    // Find starting index in the sequence
    int index = dashaOrder.indexOf(startLord);
    
    // Add first (partial) Mahadasha
    final daysInFirst = (startRemainingYears * 365.25).toInt();
    result.add({
      'lord': startLord,
      'fullName': NakshatraDashaMap.getFullName(startLord),
      'years': startRemainingYears,
      'startDate': currentDate,
      'endDate': currentDate.add(Duration(days: daysInFirst)),
      'isPartial': true,
    });
    currentDate = currentDate.add(Duration(days: daysInFirst));
    
    // Add remaining 8 Mahadashas
    for (int i = 1; i < 9; i++) {
      final lord = dashaOrder[(index + i) % 9];
      final years = dashaYears[lord]!.toDouble();
      final days = (years * 365.25).toInt();
      
      result.add({
        'lord': lord,
        'fullName': NakshatraDashaMap.getFullName(lord),
        'years': years,
        'startDate': currentDate,
        'endDate': currentDate.add(Duration(days: days)),
        'isPartial': false,
      });
      currentDate = currentDate.add(Duration(days: days));
    }
    
    return result;
  }
  
  /// Generate Antardashas for a given Mahadasha
  /// 
  /// [mdLord] - Mahadasha lord
  /// [mdYears] - Total years of this Mahadasha
  /// [mdStartDate] - Start date of this Mahadasha
  /// Returns list of Antardasha periods
  static List<Map<String, dynamic>> generateAntardashas({
    required String mdLord,
    required double mdYears,
    required DateTime mdStartDate,
  }) {
    final result = <Map<String, dynamic>>[];
    var currentDate = mdStartDate;
    
    // Find MD lord's index
    int index = dashaOrder.indexOf(mdLord);
    
    // AD starts with MD lord, then cycles through all 9
    for (int i = 0; i < 9; i++) {
      final lord = dashaOrder[(index + i) % 9];
      
      // AD years = MD years × (Planet AD Years / 120)
      final years = mdYears * (dashaYears[lord]! / 120.0);
      final days = (years * 365.25).toInt();
      
      result.add({
        'lord': lord,
        'fullName': NakshatraDashaMap.getFullName(lord),
        'years': years,
        'days': days,
        'startDate': currentDate,
        'endDate': currentDate.add(Duration(days: days)),
      });
      currentDate = currentDate.add(Duration(days: days));
    }
    
    return result;
  }
  
  /// Find current Mahadasha and Antardasha for a given date
  /// 
  /// [mahadashas] - List of all Mahadasha periods
  /// [currentDate] - Date to find Dasha for
  /// Returns: {md: Map, ad: Map, mdIndex: int, adIndex: int}
  static Map<String, dynamic>? getCurrentDasha({
    required List<Map<String, dynamic>> mahadashas,
    required DateTime currentDate,
  }) {
    // Find current Mahadasha
    for (int mdIndex = 0; mdIndex < mahadashas.length; mdIndex++) {
      final md = mahadashas[mdIndex];
      final mdStart = md['startDate'] as DateTime;
      final mdEnd = md['endDate'] as DateTime;
      
      if (currentDate.isAfter(mdStart) && currentDate.isBefore(mdEnd)) {
        // Found current MD, now find AD
        final antardashas = generateAntardashas(
          mdLord: md['lord'],
          mdYears: md['years'],
          mdStartDate: mdStart,
        );
        
        for (int adIndex = 0; adIndex < antardashas.length; adIndex++) {
          final ad = antardashas[adIndex];
          final adStart = ad['startDate'] as DateTime;
          final adEnd = ad['endDate'] as DateTime;
          
          if (currentDate.isAfter(adStart) && currentDate.isBefore(adEnd)) {
            return {
              'md': md,
              'ad': ad,
              'mdIndex': mdIndex,
              'adIndex': adIndex,
              'allAntardashas': antardashas,
            };
          }
        }
      }
    }
    
    return null;
  }
}
