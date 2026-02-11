import 'dart:convert';
import 'package:http/http.dart' as http;

/// Panchang (Vedic Almanac) Calculation Engine
/// 
/// Calculates:
/// - Tithi (Lunar Day)
/// - Nakshatra (Moon's Constellation)
/// - Yoga (Luni-Solar Combination)
/// - Karana (Half of Tithi)
/// - Vara (Weekday)
/// - Rahu Kalam, Gulika Kalam, Yamaganda (Inauspicious Times)
/// - Abhijit Muhurta (Most Auspicious Time)

class PanchangService {
  static const String _baseUrl = "https://json.freeastrologyapi.com";
  static const String _apiKey = "vO6sSA5hKu8atz6KDG3xQt1rlTLkUzUhJ6x1wwtLJ";

  /// Fetch complete Panchang for a given date and location
  static Future<Map<String, dynamic>> fetchPanchang({
    required DateTime date,
    required double latitude,
    required double longitude,
    required double timezone,
  }) async {
    final url = Uri.parse("$_baseUrl/panchang");

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "x-api-key": _apiKey,
      },
      body: jsonEncode({
        "year": date.year,
        "month": date.month,
        "date": date.day,
        "hours": date.hour,
        "minutes": date.minute,
        "seconds": 0,
        "latitude": latitude,
        "longitude": longitude,
        "timezone": timezone,
        "ayanamsha": "lahiri",
      }),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to fetch Panchang: ${response.statusCode}");
    }

    return jsonDecode(response.body);
  }

  /// Calculate Rahu Kalam for a given date and location
  /// Rahu Kalam is an inauspicious period each day
  static Map<String, String> calculateRahuKalam({
    required DateTime date,
    required DateTime sunrise,
    required DateTime sunset,
  }) {
    // Duration of day in minutes
    final dayDuration = sunset.difference(sunrise).inMinutes;
    final unitDuration = dayDuration ~/ 8;
    
    // Rahu Kalam order by weekday (Sun=0, Mon=1, etc.)
    // Sunday: 8th, Monday: 2nd, Tuesday: 7th, Wednesday: 5th,
    // Thursday: 6th, Friday: 4th, Saturday: 3rd
    const rahuOrder = [7, 1, 6, 4, 5, 3, 2]; // 0-indexed position
    
    final weekday = date.weekday % 7; // 0=Sunday
    final position = rahuOrder[weekday];
    
    final startMinutes = position * unitDuration;
    final start = sunrise.add(Duration(minutes: startMinutes));
    final end = start.add(Duration(minutes: unitDuration));
    
    return {
      'start': _formatTime(start),
      'end': _formatTime(end),
    };
  }

  /// Calculate Gulika Kalam for a given date
  static Map<String, String> calculateGulikaKalam({
    required DateTime date,
    required DateTime sunrise,
    required DateTime sunset,
  }) {
    final dayDuration = sunset.difference(sunrise).inMinutes;
    final unitDuration = dayDuration ~/ 8;
    
    // Gulika Kalam order by weekday
    const gulikaOrder = [6, 5, 4, 3, 2, 1, 0];
    
    final weekday = date.weekday % 7;
    final position = gulikaOrder[weekday];
    
    final startMinutes = position * unitDuration;
    final start = sunrise.add(Duration(minutes: startMinutes));
    final end = start.add(Duration(minutes: unitDuration));
    
    return {
      'start': _formatTime(start),
      'end': _formatTime(end),
    };
  }

  /// Calculate Yamaganda Kalam for a given date
  static Map<String, String> calculateYamagandaKalam({
    required DateTime date,
    required DateTime sunrise,
    required DateTime sunset,
  }) {
    final dayDuration = sunset.difference(sunrise).inMinutes;
    final unitDuration = dayDuration ~/ 8;
    
    // Yamaganda order by weekday
    const yamOrder = [4, 3, 2, 1, 0, 6, 5];
    
    final weekday = date.weekday % 7;
    final position = yamOrder[weekday];
    
    final startMinutes = position * unitDuration;
    final start = sunrise.add(Duration(minutes: startMinutes));
    final end = start.add(Duration(minutes: unitDuration));
    
    return {
      'start': _formatTime(start),
      'end': _formatTime(end),
    };
  }

  /// Calculate Abhijit Muhurta (Most auspicious time of day)
  /// Occurs around local noon
  static Map<String, String> calculateAbhijitMuhurta({
    required DateTime sunrise,
    required DateTime sunset,
  }) {
    final dayDuration = sunset.difference(sunrise).inMinutes;
    final muhurtaDuration = dayDuration ~/ 15; // 15 muhurtas in a day
    
    // Abhijit is the 8th muhurta (around noon)
    final startMinutes = 7 * muhurtaDuration;
    final start = sunrise.add(Duration(minutes: startMinutes));
    final end = start.add(Duration(minutes: muhurtaDuration));
    
    return {
      'start': _formatTime(start),
      'end': _formatTime(end),
    };
  }

  /// Calculate approximate sunrise for a location
  /// (Simplified calculation - for accurate times, use an API)
  static DateTime calculateSunrise({
    required DateTime date,
    required double latitude,
    required double longitude,
    required double timezone,
  }) {
    // Simplified: assume 6 AM local time
    // For production, integrate with a proper sunrise API
    return DateTime(date.year, date.month, date.day, 6, 0);
  }

  /// Calculate approximate sunset
  static DateTime calculateSunset({
    required DateTime date,
    required double latitude,
    required double longitude,
    required double timezone,
  }) {
    // Simplified: assume 6 PM local time
    return DateTime(date.year, date.month, date.day, 18, 0);
  }

  /// Get weekday name (Vara)
  static String getVara(DateTime date) {
    const varas = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    return varas[date.weekday % 7];
  }

  /// Get Sanskrit weekday name
  static String getVaraSanskrit(DateTime date) {
    const varas = ['Ravivara', 'Somavara', 'Mangalavara', 'Budhavara', 'Guruvara', 'Shukravara', 'Shanivara'];
    return varas[date.weekday % 7];
  }

  /// Get ruling planet for the day
  static String getVaraLord(DateTime date) {
    const lords = ['Sun', 'Moon', 'Mars', 'Mercury', 'Jupiter', 'Venus', 'Saturn'];
    return lords[date.weekday % 7];
  }

  static String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  // ============ TITHI CALCULATION ============
  
  /// All 30 Tithis in order
  static const List<String> tithiNames = [
    'Pratipada', 'Dwitiya', 'Tritiya', 'Chaturthi', 'Panchami',
    'Shashthi', 'Saptami', 'Ashtami', 'Navami', 'Dashami',
    'Ekadashi', 'Dwadashi', 'Trayodashi', 'Chaturdashi', 'Purnima',
    'Pratipada', 'Dwitiya', 'Tritiya', 'Chaturthi', 'Panchami',
    'Shashthi', 'Saptami', 'Ashtami', 'Navami', 'Dashami',
    'Ekadashi', 'Dwadashi', 'Trayodashi', 'Chaturdashi', 'Amavasya',
  ];

  /// Calculate Tithi (Lunar Day) based on Sun-Moon angle
  /// Each tithi = 12° of Moon's elongation from Sun
  static Map<String, dynamic> calculateTithi(DateTime date) {
    // Approximate calculation using synodic month
    // New Moon (Amavasya) epoch: Jan 6, 2000 18:14 UTC
    final epoch = DateTime.utc(2000, 1, 6, 18, 14);
    final daysSinceEpoch = date.toUtc().difference(epoch).inMinutes / (60 * 24);
    
    // Synodic month = 29.530588853 days
    const synodicMonth = 29.530588853;
    
    // Calculate lunar age (days since last new moon)
    final lunarAge = daysSinceEpoch % synodicMonth;
    
    // Each tithi = synodic month / 30
    final tithiDuration = synodicMonth / 30;
    final tithiIndex = (lunarAge / tithiDuration).floor() % 30;
    
    // Determine paksha (lunar fortnight)
    final isShukla = tithiIndex < 15;
    final paksha = isShukla ? 'Shukla Paksha' : 'Krishna Paksha';
    final tithiInPaksha = isShukla ? tithiIndex + 1 : tithiIndex - 14;
    
    return {
      'name': tithiNames[tithiIndex],
      'number': tithiInPaksha,
      'paksha': paksha,
      'isShukla': isShukla,
      'lunarDay': tithiIndex + 1,
    };
  }

  // ============ NAKSHATRA CALCULATION ============
  
  /// All 27 Nakshatras in order
  static const List<String> nakshatraNames = [
    'Ashwini', 'Bharani', 'Krittika', 'Rohini', 'Mrigashira',
    'Ardra', 'Punarvasu', 'Pushya', 'Ashlesha', 'Magha',
    'Purva Phalguni', 'Uttara Phalguni', 'Hasta', 'Chitra', 'Swati',
    'Vishakha', 'Anuradha', 'Jyeshtha', 'Mula', 'Purva Ashadha',
    'Uttara Ashadha', 'Shravana', 'Dhanishta', 'Shatabhisha', 
    'Purva Bhadrapada', 'Uttara Bhadrapada', 'Revati',
  ];

  /// Nakshatra lords (Vimshottari Dasha order)
  static const List<String> nakshatraLords = [
    'Ketu', 'Venus', 'Sun', 'Moon', 'Mars',
    'Rahu', 'Jupiter', 'Saturn', 'Mercury', 'Ketu',
    'Venus', 'Sun', 'Moon', 'Mars', 'Rahu',
    'Jupiter', 'Saturn', 'Mercury', 'Ketu', 'Venus',
    'Sun', 'Moon', 'Mars', 'Rahu', 'Jupiter',
    'Saturn', 'Mercury',
  ];

  /// Calculate Moon's Nakshatra based on approximate sidereal longitude
  static Map<String, dynamic> calculateNakshatra(DateTime date) {
    // Approximate Moon position calculation
    // This is a simplified ephemeris calculation
    
    // Days since J2000.0 (Jan 1, 2000 12:00 TT)
    final j2000 = DateTime.utc(2000, 1, 1, 12, 0);
    final d = date.toUtc().difference(j2000).inMinutes / (60 * 24);
    
    // Moon's mean longitude (simplified)
    // L = 218.32 + 13.1764 * d (degrees)
    double moonLongitude = (218.32 + 13.1763965 * d) % 360;
    
    // Apply Lahiri Ayanamsa (approximate)
    // Ayanamsa on Jan 1, 2000 was about 23.86°, increases ~50" per year
    final yearsSince2000 = d / 365.25;
    final ayanamsa = 23.86 + (yearsSince2000 * 50.0 / 3600.0);
    
    // Sidereal Moon longitude
    double siderealMoon = (moonLongitude - ayanamsa) % 360;
    if (siderealMoon < 0) siderealMoon += 360;
    
    // Each nakshatra = 360/27 = 13.333... degrees
    final nakshatraSpan = 360.0 / 27.0;
    final nakshatraIndex = (siderealMoon / nakshatraSpan).floor() % 27;
    
    // Calculate pada (quarter) - each nakshatra has 4 padas
    final degreeInNakshatra = siderealMoon % nakshatraSpan;
    final pada = (degreeInNakshatra / (nakshatraSpan / 4)).floor() + 1;
    
    return {
      'name': nakshatraNames[nakshatraIndex],
      'number': nakshatraIndex + 1,
      'lord': nakshatraLords[nakshatraIndex],
      'pada': pada,
      'degree': siderealMoon,
    };
  }

  // ============ YOGA CALCULATION ============
  
  /// All 27 Yogas
  static const List<String> yogaNames = [
    'Vishkumbha', 'Priti', 'Ayushman', 'Saubhagya', 'Shobhana',
    'Atiganda', 'Sukarma', 'Dhriti', 'Shoola', 'Ganda',
    'Vriddhi', 'Dhruva', 'Vyaghata', 'Harshana', 'Vajra',
    'Siddhi', 'Vyatipata', 'Variyana', 'Parigha', 'Shiva',
    'Siddha', 'Sadhya', 'Shubha', 'Shukla', 'Brahma',
    'Indra', 'Vaidhriti',
  ];

  /// Calculate Yoga (Sun + Moon longitude / 13.33)
  static Map<String, dynamic> calculateYoga(DateTime date) {
    // Approximate Sun position
    final j2000 = DateTime.utc(2000, 1, 1, 12, 0);
    final d = date.toUtc().difference(j2000).inMinutes / (60 * 24);
    
    // Sun's mean longitude
    double sunLongitude = (280.46 + 0.9856474 * d) % 360;
    
    // Moon's mean longitude
    double moonLongitude = (218.32 + 13.1763965 * d) % 360;
    
    // Sum of longitudes
    final sum = (sunLongitude + moonLongitude) % 360;
    
    // Each yoga = 13.333... degrees
    final yogaIndex = (sum / (360.0 / 27.0)).floor() % 27;
    
    return {
      'name': yogaNames[yogaIndex],
      'number': yogaIndex + 1,
    };
  }

  // ============ KARANA CALCULATION ============
  
  /// All 11 Karanas (7 repeat, 4 are fixed)
  static const List<String> karanaNames = [
    'Bava', 'Balava', 'Kaulava', 'Taitila', 'Gara', 'Vanija', 'Vishti',
    'Shakuni', 'Chatushpada', 'Naga', 'Kimstughna',
  ];

  /// Calculate Karana (half of tithi)
  static Map<String, dynamic> calculateKarana(DateTime date) {
    final tithi = calculateTithi(date);
    final tithiNumber = tithi['lunarDay'] as int;
    
    // Each tithi has 2 karanas
    // Karanas 1-7 repeat, 8-11 are fixed at specific tithis
    final karanaNumber = ((tithiNumber - 1) * 2 + 1);
    
    // For simplicity, use cycling karanas
    final karanaIndex = (karanaNumber - 1) % 7;
    
    return {
      'name': karanaNames[karanaIndex],
      'number': karanaNumber,
    };
  }

  /// Get complete local Panchang (without API - basic calculations)
  static Map<String, dynamic> getLocalPanchang({
    required DateTime date,
    required double latitude,
    required double longitude,
    required double timezone,
  }) {
    final sunrise = calculateSunrise(
      date: date, latitude: latitude, longitude: longitude, timezone: timezone,
    );
    final sunset = calculateSunset(
      date: date, latitude: latitude, longitude: longitude, timezone: timezone,
    );

    return {
      'date': date.toIso8601String(),
      'vara': getVara(date),
      'varaSanskrit': getVaraSanskrit(date),
      'varaLord': getVaraLord(date),
      'sunrise': _formatTime(sunrise),
      'sunset': _formatTime(sunset),
      'rahuKalam': calculateRahuKalam(date: date, sunrise: sunrise, sunset: sunset),
      'gulikaKalam': calculateGulikaKalam(date: date, sunrise: sunrise, sunset: sunset),
      'yamagandaKalam': calculateYamagandaKalam(date: date, sunrise: sunrise, sunset: sunset),
      'abhijitMuhurta': calculateAbhijitMuhurta(sunrise: sunrise, sunset: sunset),
      'tithi': calculateTithi(date),
      'nakshatra': calculateNakshatra(date),
      'yoga': calculateYoga(date),
      'karana': calculateKarana(date),
    };
  }
}

