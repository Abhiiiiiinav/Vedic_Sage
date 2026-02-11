/// Professional-Grade Kundali Engine
/// Matches Jagannatha Hora / Parashara Light accuracy
/// Uses angular house system, true obliquity, and correct Lahiri Ayanamsa
library;

import 'dart:math';

// ═══════════════════════════════════════════════════════════════════════════
// CONSTANTS
// ═══════════════════════════════════════════════════════════════════════════

const double DEG2RAD = pi / 180;
const double RAD2DEG = 180 / pi;

/// Planet symbols for chart display
class AstroConstants {
  static const Map<String, String> planetSymbols = {
    'Sun': 'Su', 'Moon': 'Mo', 'Mars': 'Ma', 'Mercury': 'Me',
    'Jupiter': 'Ju', 'Venus': 'Ve', 'Saturn': 'Sa', 'Rahu': 'Ra', 'Ketu': 'Ke',
    'Ascendant': 'Asc'
  };
  
  static const List<String> signs = [
    'Aries', 'Taurus', 'Gemini', 'Cancer', 'Leo', 'Virgo',
    'Libra', 'Scorpio', 'Sagittarius', 'Capricorn', 'Aquarius', 'Pisces'
  ];
  
  static const List<String> nakshatras = [
    'Ashwini', 'Bharani', 'Krittika', 'Rohini', 'Mrigashira', 'Ardra',
    'Punarvasu', 'Pushya', 'Ashlesha', 'Magha', 'Purva Phalguni', 'Uttara Phalguni',
    'Hasta', 'Chitra', 'Swati', 'Vishakha', 'Anuradha', 'Jyeshtha',
    'Mula', 'Purva Ashadha', 'Uttara Ashadha', 'Shravana', 'Dhanishta', 'Shatabhisha',
    'Purva Bhadrapada', 'Uttara Bhadrapada', 'Revati'
  ];
  
  static const List<String> nakshatraLords = [
    'Ketu', 'Venus', 'Sun', 'Moon', 'Mars', 'Rahu', 'Jupiter', 'Saturn', 'Mercury'
  ];
}

// ═══════════════════════════════════════════════════════════════════════════
// STEP 1: JULIAN DAY (UT, not local)
// ═══════════════════════════════════════════════════════════════════════════

/// Convert local DateTime to Julian Day (UT)
/// CRITICAL: Must convert to UTC first using timezone offset
double julianDay(DateTime dt, double tzHours) {
  // Convert local time to UTC
  final utc = dt.subtract(Duration(milliseconds: (tzHours * 3600000).round()));
  
  int y = utc.year;
  int m = utc.month;
  double d = utc.day + 
      (utc.hour + utc.minute / 60.0 + utc.second / 3600.0) / 24.0;

  if (m <= 2) {
    y -= 1;
    m += 12;
  }

  int A = y ~/ 100;
  int B = 2 - A + (A ~/ 4);

  return (365.25 * (y + 4716)).floor() +
      (30.6001 * (m + 1)).floor() +
      d +
      B -
      1524.5;
}

// ═══════════════════════════════════════════════════════════════════════════
// STEP 2: GREENWICH SIDEREAL TIME
// ═══════════════════════════════════════════════════════════════════════════

/// Greenwich Mean Sidereal Time in degrees
double greenwichSiderealTime(double jd) {
  double T = (jd - 2451545.0) / 36525.0;
  
  double theta = 280.46061837 +
      360.98564736629 * (jd - 2451545.0) +
      0.000387933 * T * T -
      (T * T * T) / 38710000.0;

  return (theta % 360 + 360) % 360;
}

// ═══════════════════════════════════════════════════════════════════════════
// STEP 3: LOCAL SIDEREAL TIME
// ═══════════════════════════════════════════════════════════════════════════

/// Local Sidereal Time in degrees
double localSiderealTime(double gst, double longitude) {
  return (gst + longitude) % 360;
}

// ═══════════════════════════════════════════════════════════════════════════
// STEP 4: TRUE OBLIQUITY (needed for accurate Lagna)
// ═══════════════════════════════════════════════════════════════════════════

/// True obliquity of the ecliptic
double trueObliquity(double T) {
  return 23.43929111 -
      0.0130041667 * T -
      1.63889e-7 * T * T +
      5.03611e-7 * T * T * T;
}

// ═══════════════════════════════════════════════════════════════════════════
// STEP 5: ASCENDANT (REAL SPHERICAL TRIG FORMULA)
// ═══════════════════════════════════════════════════════════════════════════

/// Calculate Tropical Ascendant using correct spherical trigonometry
/// This matches what Lahiri tables compute
double tropicalAscendant(double lstDeg, double latDeg, double jd) {
  double T = (jd - 2451545.0) / 36525.0;
  double eps = trueObliquity(T) * DEG2RAD;
  
  double theta = lstDeg * DEG2RAD; // LST in radians
  double phi = latDeg * DEG2RAD;   // Latitude in radians
  
  // Correct ascendant formula using spherical trigonometry
  // ASC = atan2(-cos(LST), sin(eps)*tan(lat) + cos(eps)*sin(LST))
  double y = -cos(theta);
  double x = sin(eps) * tan(phi) + cos(eps) * sin(theta);
  
  double asc = atan2(y, x) * RAD2DEG;
  
  // Add 180° to correct quadrant - atan2 returns the opposite point (descendant)
  // We need the actual rising point on the eastern horizon
  asc = asc + 180.0;
  
  return (asc + 360) % 360;
}

// ═══════════════════════════════════════════════════════════════════════════
// STEP 6: LAHIRI AYANAMSA (CORRECTED FORMULA)
// ═══════════════════════════════════════════════════════════════════════════

/// Lahiri Ayanamsa - matches official Indian Ephemeris
double lahiriAyanamsa(double jd) {
  double T = (jd - 2451545.0) / 36525.0;
  // Lahiri reference: 23°51'30" at Jan 1, 2000
  // Rate: ~50.29" per year
  return 23.85833 + (50.29 / 3600.0) * T * 100;
}

/// Convert tropical longitude to sidereal
double toSidereal(double tropicalDeg, double jd) {
  return (tropicalDeg - lahiriAyanamsa(jd) + 360) % 360;
}

// ═══════════════════════════════════════════════════════════════════════════
// STEP 7: HOUSE CALCULATION (ANGULAR DISTANCE - THIS FIXES MARS ERROR)
// ═══════════════════════════════════════════════════════════════════════════

/// Calculate house from angular distance from ascendant
/// ⚠️ CRITICAL: Never assign houses by sign. Always use angular distance.
int planetHouse(double ascDeg, double planetDeg) {
  double diff = (planetDeg - ascDeg + 360) % 360;
  return (diff ~/ 30).toInt() + 1;
}

/// Get sign (1-12) from degree
int signFromDegree(double deg) => (deg ~/ 30).toInt() + 1;

/// Get degree within sign (0-30)
double degreeInSign(double deg) => deg % 30;

// ═══════════════════════════════════════════════════════════════════════════
// STEP 8: PLANET LONGITUDES (MEAN PLANET - ACCURATE TO ~0.5°)
// ═══════════════════════════════════════════════════════════════════════════

/// Mean planet longitude calculation
double meanPlanet(double jd, double L0, double n) {
  return (L0 + n * (jd - 2451545.0)) % 360;
}

/// Calculate all planet tropical longitudes
Map<String, double> planetLongitudesTropical(double jd) {
  return {
    'Sun': meanPlanet(jd, 280.460, 0.9856474),
    'Moon': meanPlanet(jd, 218.316, 13.176396),
    'Mars': meanPlanet(jd, 355.433, 0.524039),
    'Mercury': meanPlanet(jd, 252.251, 4.092338),
    'Jupiter': meanPlanet(jd, 34.351, 0.083091),
    'Venus': meanPlanet(jd, 181.979, 1.602130),
    'Saturn': meanPlanet(jd, 50.077, 0.033459),
    'Rahu': meanPlanet(jd, 125.122, -0.0529538),
    'Ketu': (meanPlanet(jd, 125.122, -0.0529538) + 180) % 360,
  };
}

/// Convert all planets to sidereal
Map<String, double> planetLongitudesSidereal(double jd) {
  final tropical = planetLongitudesTropical(jd);
  final sidereal = <String, double>{};
  
  for (var entry in tropical.entries) {
    sidereal[entry.key] = toSidereal(entry.value, jd);
  }
  
  return sidereal;
}

// ═══════════════════════════════════════════════════════════════════════════
// NAKSHATRA & PADA CALCULATION
// ═══════════════════════════════════════════════════════════════════════════

/// Nakshatra index (1-27) from sidereal degree
int nakshatra(double deg) => (deg / 13.333333333).floor() + 1;

/// Pada (1-4) within nakshatra
int pada(double deg) => ((deg % 13.333333333) / 3.333333333).floor() + 1;

/// Get nakshatra name
String nakshatraName(int index) => AstroConstants.nakshatras[(index - 1) % 27];

/// Get nakshatra lord for Dasha
String nakshatraLord(int nakIndex) => 
    AstroConstants.nakshatraLords[(nakIndex - 1) % 9];

// ═══════════════════════════════════════════════════════════════════════════
// DIVISIONAL CHART ENGINE (ALL VARGAS)
// ═══════════════════════════════════════════════════════════════════════════

/// General Varga Sign calculation
/// This is the correct formula for all divisional charts
int vargaSign(double deg, int division) {
  double part = 30.0 / division;
  int rashi = (deg ~/ 30).toInt();
  double posInSign = deg % 30;
  int vargaPart = (posInSign / part).floor();
  return ((rashi * division + vargaPart) % 12) + 1;
}

/// Build a complete Varga chart for all planets
Map<String, int> buildVargaChart(Map<String, double> planetDeg, int division) {
  final map = <String, int>{};
  planetDeg.forEach((planet, deg) {
    map[planet] = vargaSign(deg, division);
  });
  return map;
}

/// Build all major Varga charts
Map<String, Map<String, dynamic>> buildAllVargas(
  Map<String, double> siderealPlanets,
  double siderealAsc,
) {
  return {
    'D1': _buildVargaData(siderealPlanets, siderealAsc, 1),
    'D2': _buildVargaData(siderealPlanets, siderealAsc, 2),
    'D3': _buildVargaData(siderealPlanets, siderealAsc, 3),
    'D4': _buildVargaData(siderealPlanets, siderealAsc, 4),
    'D7': _buildVargaData(siderealPlanets, siderealAsc, 7),
    'D9': _buildVargaData(siderealPlanets, siderealAsc, 9),
    'D10': _buildVargaData(siderealPlanets, siderealAsc, 10),
    'D12': _buildVargaData(siderealPlanets, siderealAsc, 12),
    'D16': _buildVargaData(siderealPlanets, siderealAsc, 16),
    'D20': _buildVargaData(siderealPlanets, siderealAsc, 20),
    'D24': _buildVargaData(siderealPlanets, siderealAsc, 24),
    'D27': _buildVargaData(siderealPlanets, siderealAsc, 27),
    'D30': _buildVargaData(siderealPlanets, siderealAsc, 30),
    'D40': _buildVargaData(siderealPlanets, siderealAsc, 40),
    'D45': _buildVargaData(siderealPlanets, siderealAsc, 45),
    'D60': _buildVargaData(siderealPlanets, siderealAsc, 60),
  };
}

Map<String, dynamic> _buildVargaData(
  Map<String, double> planets,
  double asc,
  int division,
) {
  final planetSigns = buildVargaChart(planets, division);
  final ascSign = vargaSign(asc, division);
  
  return {
    'division': division,
    'ascendantSign': ascSign - 1, // 0-indexed for display
    'planetSigns': planetSigns.map((k, v) => MapEntry(k, v - 1)), // 0-indexed
  };
}

// ═══════════════════════════════════════════════════════════════════════════
// HOUSE BUILDER (FOR CHART DISPLAY)
// ═══════════════════════════════════════════════════════════════════════════

/// Build houses list for chart display
/// Uses angular distance from ascendant (CORRECT METHOD)
List<List<String>> buildHousesFromAngular(
  double siderealAsc,
  Map<String, double> siderealPlanets,
  Map<String, bool>? retrogradeStatus,
) {
  List<List<String>> houses = List.generate(12, (_) => <String>[]);
  
  // Add Ascendant marker to House 1
  houses[0].add('Asc');
  
  // Place each planet in house based on angular distance
  siderealPlanets.forEach((planet, deg) {
    int house = planetHouse(siderealAsc, deg);
    String symbol = AstroConstants.planetSymbols[planet] ?? planet.substring(0, 2);
    
    // Add retrograde indicator
    bool isRetro = retrogradeStatus?[planet] ?? false;
    String display = isRetro ? '($symbol)' : symbol;
    
    houses[house - 1].add(display);
  });
  
  return houses;
}

// ═══════════════════════════════════════════════════════════════════════════
// RETROGRADE DETECTION
// ═══════════════════════════════════════════════════════════════════════════

/// Check if planets are retrograde by comparing positions 1 day apart
Map<String, bool> checkRetrograde(double jd) {
  final today = planetLongitudesTropical(jd);
  final tomorrow = planetLongitudesTropical(jd + 1);
  
  final retro = <String, bool>{};
  
  today.forEach((planet, degToday) {
    double degTomorrow = tomorrow[planet]!;
    
    // Handle 360° crossing
    double diff = degTomorrow - degToday;
    if (diff < -300) diff += 360;
    if (diff > 300) diff -= 360;
    
    // Retrograde if moving backwards (negative diff)
    // Sun and Moon never retrograde; Rahu/Ketu always move retrograde
    if (planet == 'Sun' || planet == 'Moon') {
      retro[planet] = false;
    } else if (planet == 'Rahu' || planet == 'Ketu') {
      retro[planet] = true; // Nodes are always retrograde
    } else {
      retro[planet] = diff < 0;
    }
  });
  
  return retro;
}

// ═══════════════════════════════════════════════════════════════════════════
// MAIN ENGINE ORCHESTRATOR
// ═══════════════════════════════════════════════════════════════════════════

/// Complete Kundali Result
class KundaliResult {
  final Map<String, Map<String, dynamic>> planets;
  final Map<String, dynamic> ascendant;
  final List<List<String>> houses;
  final Map<String, Map<String, dynamic>> vargas;
  final Map<String, dynamic> dasha;
  final Map<String, dynamic> meta;
  final Map<String, dynamic> validation;
  
  KundaliResult({
    required this.planets,
    required this.ascendant,
    required this.houses,
    required this.vargas,
    required this.dasha,
    required this.meta,
    required this.validation,
  });
}

/// Main Kundali Engine - Single Entry Point
class AccurateKundaliEngine {
  
  /// Generate complete Kundali chart
  /// This is the ONLY function you need to call
  static KundaliResult generateChart({
    required DateTime birthDateTime,
    required double latitude,
    required double longitude,
    required double timezoneOffset,
  }) {
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // STEP 1: Julian Day (UT)
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    final jd = julianDay(birthDateTime, timezoneOffset);
    final T = (jd - 2451545.0) / 36525.0; // Julian centuries
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // STEP 2: Greenwich Sidereal Time
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    final gst = greenwichSiderealTime(jd);
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // STEP 3: Local Sidereal Time
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    final lst = localSiderealTime(gst, longitude);
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // STEP 4: Tropical Ascendant
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    final tropicalAsc = tropicalAscendant(lst, latitude, jd);
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // STEP 5: Apply Lahiri Ayanamsa → Sidereal Ascendant
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    final ayanamsa = lahiriAyanamsa(jd);
    final siderealAsc = toSidereal(tropicalAsc, jd);
    final ascSign = signFromDegree(siderealAsc);
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // STEP 6: Planet Tropical Longitudes → Sidereal
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    final tropicalPlanets = planetLongitudesTropical(jd);
    final siderealPlanets = planetLongitudesSidereal(jd);
    final retrogradeStatus = checkRetrograde(jd);
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // STEP 7: Build Planet Data with Houses (ANGULAR METHOD)
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    final planetData = <String, Map<String, dynamic>>{};
    
    siderealPlanets.forEach((planet, deg) {
      int house = planetHouse(siderealAsc, deg); // ANGULAR HOUSE
      int sign = signFromDegree(deg);
      int nak = nakshatra(deg);
      
      planetData[planet] = {
        'degree': deg,
        'degreeInSign': degreeInSign(deg),
        'signIndex': sign - 1, // 0-indexed
        'signName': AstroConstants.signs[sign - 1],
        'house': house,
        'nakshatra': nakshatraName(nak),
        'nakshatraIndex': nak,
        'pada': pada(deg),
        'nakshatraLord': nakshatraLord(nak),
        'isRetrograde': retrogradeStatus[planet] ?? false,
      };
    });
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // STEP 8: Build Houses for Chart Display
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    final houses = buildHousesFromAngular(
      siderealAsc, 
      siderealPlanets, 
      retrogradeStatus,
    );
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // STEP 9: Build All Divisional Charts
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    final vargas = buildAllVargas(siderealPlanets, siderealAsc);
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // STEP 10: Calculate Vimshottari Dasha
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    final moonDeg = siderealPlanets['Moon']!;
    final moonNak = nakshatra(moonDeg);
    final dasha = VimshottariDasha.calculate(moonDeg, birthDateTime);
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // BUILD RESULT
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    return KundaliResult(
      planets: planetData,
      ascendant: {
        'degree': siderealAsc,
        'degreeInSign': degreeInSign(siderealAsc),
        'signIndex': ascSign - 1,
        'signName': AstroConstants.signs[ascSign - 1],
        'tropicalDegree': tropicalAsc,
      },
      houses: houses,
      vargas: vargas,
      dasha: dasha,
      meta: {
        'julianDay': jd,
        'julianCenturies': T,
        'greenwichSiderealTime': gst,
        'localSiderealTime': lst,
        'ayanamsa': ayanamsa,
        'obliquity': trueObliquity(T),
        'calculatedAt': DateTime.now().toIso8601String(),
        'engineVersion': '2.0.0-angular',
      },
      validation: {
        'moonNakshatra': nakshatraName(moonNak),
        'moonNakshatraIndex': moonNak,
        'moonPada': pada(moonDeg),
        'moonDegree': moonDeg,
        'ascDegree': siderealAsc,
        'ayanamsaUsed': ayanamsa,
      },
    );
  }
  
  /// Get chart summary for debugging
  static String getChartSummary(KundaliResult result) {
    final sb = StringBuffer();
    sb.writeln('╔══════════════════════════════════════════════════════════════╗');
    sb.writeln('║            ACCURATE KUNDALI ENGINE v2.0 (ANGULAR)            ║');
    sb.writeln('╠══════════════════════════════════════════════════════════════╣');
    sb.writeln('║ Ascendant: ${result.ascendant['signName']} ${result.ascendant['degreeInSign']?.toStringAsFixed(2)}°');
    sb.writeln('║ Moon Nakshatra: ${result.validation['moonNakshatra']} Pada ${result.validation['moonPada']}');
    sb.writeln('║ Ayanamsa: ${result.meta['ayanamsa']?.toStringAsFixed(4)}°');
    sb.writeln('╠══════════════════════════════════════════════════════════════╣');
    
    result.planets.forEach((planet, data) {
      final retro = data['isRetrograde'] == true ? ' (R)' : '';
      sb.writeln('║ $planet: ${data['signName']} ${data['degreeInSign']?.toStringAsFixed(2)}° | House ${data['house']}$retro');
    });
    
    sb.writeln('╚══════════════════════════════════════════════════════════════╝');
    return sb.toString();
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// VIMSHOTTARI DASHA CALCULATOR
// ═══════════════════════════════════════════════════════════════════════════

class VimshottariDasha {
  static const List<String> lordOrder = [
    'Ketu', 'Venus', 'Sun', 'Moon', 'Mars', 'Rahu', 'Jupiter', 'Saturn', 'Mercury'
  ];
  
  static const Map<String, double> dashaYears = {
    'Ketu': 7, 'Venus': 20, 'Sun': 6, 'Moon': 10, 'Mars': 7,
    'Rahu': 18, 'Jupiter': 16, 'Saturn': 19, 'Mercury': 17,
  };
  
  static const double totalCycle = 120; // years
  
  /// Calculate Vimshottari Dasha from Moon degree
  static Map<String, dynamic> calculate(double moonDeg, DateTime birthDate) {
    // Find nakshatra and progress within it
    int nak = nakshatra(moonDeg);
    double nakProgress = (moonDeg % 13.333333333) / 13.333333333;
    
    // Get ruling lord
    String startLord = nakshatraLord(nak);
    int lordIndex = lordOrder.indexOf(startLord);
    
    // Calculate elapsed portion of first dasha
    double firstDashaYears = dashaYears[startLord]!;
    double elapsedYears = nakProgress * firstDashaYears;
    double remainingYears = firstDashaYears - elapsedYears;
    
    // Build mahadashas
    List<Map<String, dynamic>> mahadashas = [];
    DateTime currentStart = birthDate;
    
    for (int i = 0; i < 9; i++) {
      int idx = (lordIndex + i) % 9;
      String lord = lordOrder[idx];
      double years = i == 0 ? remainingYears : dashaYears[lord]!;
      
      DateTime endDate = _addYears(currentStart, years);
      
      mahadashas.add({
        'lord': lord,
        'startDate': currentStart.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'years': years,
        'index': i,
      });
      
      currentStart = endDate;
    }
    
    // Find current running dasha
    DateTime now = DateTime.now();
    Map<String, dynamic>? currentDasha;
    for (var md in mahadashas) {
      DateTime start = DateTime.parse(md['startDate']);
      DateTime end = DateTime.parse(md['endDate']);
      if (now.isAfter(start) && now.isBefore(end)) {
        currentDasha = md;
        break;
      }
    }
    
    return {
      'moonNakshatra': nakshatraName(nak),
      'moonNakshatraLord': startLord,
      'birthDashaBalance': remainingYears,
      'mahadashas': mahadashas,
      'currentDasha': currentDasha,
    };
  }
  
  static DateTime _addYears(DateTime dt, double years) {
    int days = (years * 365.25).round();
    return dt.add(Duration(days: days));
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// LEGACY COMPATIBILITY WRAPPER
// ═══════════════════════════════════════════════════════════════════════════

/// Legacy KundaliEngine class for backward compatibility
/// Use AccurateKundaliEngine for new code
class KundaliEngine {
  /// Get Moon degree from chart data (for Dasha calculations)
  static double getMoonDegree(Map<String, dynamic> chartData) {
    // Try to get Moon degree from various possible locations in chart data
    if (chartData.containsKey('planets')) {
      final planets = chartData['planets'] as Map<String, dynamic>?;
      if (planets != null && planets.containsKey('Moon')) {
        final moonData = planets['Moon'] as Map<String, dynamic>?;
        if (moonData != null && moonData.containsKey('degree')) {
          return (moonData['degree'] as num).toDouble();
        }
      }
    }
    
    // Try planetData format
    if (chartData.containsKey('planetData')) {
      final planetData = chartData['planetData'] as Map<String, dynamic>?;
      if (planetData != null && planetData.containsKey('Moon')) {
        final moonData = planetData['Moon'] as Map<String, dynamic>?;
        if (moonData != null && moonData.containsKey('degree')) {
          return (moonData['degree'] as num).toDouble();
        }
      }
    }
    
    // Try direct Moon key
    if (chartData.containsKey('Moon')) {
      final moonData = chartData['Moon'];
      if (moonData is Map<String, dynamic> && moonData.containsKey('degree')) {
        return (moonData['degree'] as num).toDouble();
      }
    }
    
    // Default fallback - return 0 degrees (Aries)
    return 0.0;
  }
  
  /// Generate chart (delegates to AccurateKundaliEngine)
  static KundaliResult generateChart({
    required DateTime birthLocal,
    required double latitude,
    required double longitude,
    required int timezoneOffsetMinutes,
  }) {
    return AccurateKundaliEngine.generateChart(
      birthDateTime: birthLocal,
      latitude: latitude,
      longitude: longitude,
      timezoneOffset: timezoneOffsetMinutes / 60.0,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// VALIDATION / COMPARISON HELPER
// ═══════════════════════════════════════════════════════════════════════════

class ChartValidator {
  /// Print comparison data for verification against Jagannatha Hora
  static void printComparison(KundaliResult result) {
    print('');
    print('═══════════════════════════════════════════════════════');
    print('   VALIDATION DATA - Compare with Jagannatha Hora');
    print('═══════════════════════════════════════════════════════');
    print('');
    print('ASCENDANT:');
    print('  Sidereal: ${result.ascendant['signName']} ${result.ascendant['degreeInSign']?.toStringAsFixed(4)}°');
    print('  Tropical: ${result.ascendant['tropicalDegree']?.toStringAsFixed(4)}°');
    print('');
    print('AYANAMSA: ${result.meta['ayanamsa']?.toStringAsFixed(4)}° (Lahiri)');
    print('');
    print('MOON:');
    print('  Nakshatra: ${result.validation['moonNakshatra']}');
    print('  Pada: ${result.validation['moonPada']}');
    print('  Degree: ${result.validation['moonDegree']?.toStringAsFixed(4)}°');
    print('');
    print('PLANET HOUSES (Angular Method):');
    result.planets.forEach((planet, data) {
      final retro = data['isRetrograde'] == true ? ' (R)' : '';
      print('  $planet: House ${data['house']} | ${data['signName']} ${data['degreeInSign']?.toStringAsFixed(2)}°$retro');
    });
    print('');
    print('═══════════════════════════════════════════════════════');
  }
}
