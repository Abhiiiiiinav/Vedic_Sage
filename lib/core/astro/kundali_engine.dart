
import 'dart:math';
import 'algorithms/astro_math.dart';
import 'algorithms/planetary_positions.dart';
import 'algorithms/ascendant_calculator.dart';
import 'accurate_kundali_engine.dart' show VimshottariDasha, buildAllVargas, KundaliResult; 

// Re-export result types
export 'accurate_kundali_engine.dart' show KundaliResult;

/// Main Kundali Engine (Deterministic, High Precision)
class KundaliEngine {
  
  /// Calculate complete chart data
  static KundaliResult calculateChart({
    required DateTime birthTime,
    required double latitude,
    required double longitude,
    required double timezoneOffset, // Added timezone offset
  }) {
    // 1. Time Conversions
    // Treat birthTime as Wall Clock Time and subtract offset to get UTC
    // We create a new DateTime to ensure we don't carry over device timezone artifacts if strictly using components
    final wallClock = DateTime.utc(
      birthTime.year, birthTime.month, birthTime.day,
      birthTime.hour, birthTime.minute, birthTime.second
    );
    final utcTime = wallClock.subtract(Duration(milliseconds: (timezoneOffset * 3600000).round()));
    
    final jd = AstroMath.julianDay(utcTime);
    
    // 2. Ayanamsa (Lahiri)
    final T = (jd - 2451545.0) / 36525.0;
    final ayanamsa = 23.854305 + 0.013963 * T; // Simplified Lahiri
    
    // 3. Sidereal Time
    final d = jd - 2451545.0;
    final gmst = AstroMath.normalize(280.46061837 + 360.98564736629 * d);
    final lst = AstroMath.normalize(gmst + longitude);
    
    // 4. Obliquity
    final epsilon = 23.4392911 - 0.0130042 * T;
    
    // 5. Ascendant (Tropical -> Sidereal)
    final tropicalAsc = AscendantCalculator.calculateAscendant(lst, latitude, epsilon);
    final siderealAsc = AstroMath.normalize(tropicalAsc - ayanamsa);
    final ascSignIndex = (siderealAsc / 30).floor();
    
    // 6. Planets (Heliocentric -> Geocentric Tropical -> Sidereal)
    final tropicalPlanets = PlanetaryPositions.calculatePlanets(jd);
    
    // Retrograde check (compare with t+1 hour? or 1 day?)
    // Simple 1 hour check is sufficient for direction
    final tropicalPlanetsNext = PlanetaryPositions.calculatePlanets(jd + (1/24.0));
    final retrogradeStatus = <String, bool>{};
    tropicalPlanets.forEach((k, v) {
      double diff = tropicalPlanetsNext[k]! - v;
      if (diff < -300) diff += 360;
      if (diff > 300) diff -= 360;
      
      if (k == 'Rahu' || k == 'Ketu') {
        retrogradeStatus[k] = true; // Nodes always retro (Mean)
      } else if (k == 'Sun' || k == 'Moon') {
         retrogradeStatus[k] = false;
      } else {
         retrogradeStatus[k] = diff < 0;
      }
    });

    final siderealPlanets = <String, double>{};
    final planetDetails = <String, Map<String, dynamic>>{};
    
    tropicalPlanets.forEach((planet, deg) {
      final siderealDeg = AstroMath.normalize(deg - ayanamsa);
      siderealPlanets[planet] = siderealDeg;
      
      final signIndex = (siderealDeg / 30).floor();
      final degInSign = siderealDeg % 30;
      final nakIndex = (siderealDeg / 13.333333333).floor() + 1;
      final pada = ((siderealDeg % 13.333333333) / 3.333333333).floor() + 1;
      
      // Calculate House (Angular from Asc)
      // distance = (planet - asc + 360) % 360; house = floor(distance/30) + 1
      final distFromAsc = AstroMath.normalize(siderealDeg - siderealAsc);
      final house = (distFromAsc / 30).floor() + 1;
      
      planetDetails[planet] = {
        'degree': siderealDeg,
        'degreeInSign': degInSign,
        'signIndex': signIndex,
        'signName': _getSignName(signIndex),
        'house': house,
        'nakshatra': _getNakshatraName(nakIndex),
        'nakshatraIndex': nakIndex,
        'pada': pada,
        'nakshatraLord': _getNakshatraLord(nakIndex),
        'isRetrograde': retrogradeStatus[planet] ?? false,
      };
    });
    
    // 7. House Cusps (Equal House System - Vedic Standard)
    // Build display houses list like [[Asc, Su], [], ...]
    final formattedHouses = List.generate(12, (_) => <String>[]);
    formattedHouses[0].add('Asc'); // Always in 1st house relative to itself
    
    planetDetails.forEach((planet, data) {
      final houseIdx = (data['house'] as int) - 1;
      String symbol = _getPlanetSymbol(planet);
      if (data['isRetrograde'] == true) symbol = '($symbol)';
      formattedHouses[houseIdx].add(symbol);
    });
    
    // 8. Varga Charts (D1-D60)
    final vargas = buildAllVargas(siderealPlanets, siderealAsc);
    
    // 9. Dasha Calculation
    final dasha = VimshottariDasha.calculate(siderealPlanets['Moon']!, birthTime);

    // 10. Assemble Result
    return KundaliResult(
      planets: planetDetails,
      ascendant: {
        'degree': siderealAsc,
        'degreeInSign': siderealAsc % 30,
        'signIndex': ascSignIndex,
        'signName': _getSignName(ascSignIndex),
        'tropicalDegree': tropicalAsc,
      },
      houses: formattedHouses,
      vargas: vargas,
      dasha: dasha,
      meta: {
        'julianDay': jd,
        'lst': lst,
        'obliquity': epsilon,
        'algorithm': 'Kepler_VSOP_Subset',
        'engine': 'AstroLearn Native v3.0',
        'ayanamsa': ayanamsa,
      },
      validation: {
        'moonNakshatra': planetDetails['Moon']?['nakshatra'],
        'moonNakshatraIndex': planetDetails['Moon']?['nakshatraIndex'],
        'moonPada': planetDetails['Moon']?['pada'],
        'moonDegree': siderealPlanets['Moon'],
        'ascDegree': siderealAsc,
        'ayanamsaUsed': ayanamsa,
      },
    );
  }
  
  // --- Helpers ---
  
  static String _getSignName(int index) {
    const signs = ['Aries', 'Taurus', 'Gemini', 'Cancer', 'Leo', 'Virgo',
                   'Libra', 'Scorpio', 'Sagittarius', 'Capricorn', 'Aquarius', 'Pisces'];
    return signs[index % 12];
  }
  
  static String _getNakshatraName(int index) {
    const naks = [
      'Ashwini', 'Bharani', 'Krittika', 'Rohini', 'Mrigashira', 'Ardra',
      'Punarvasu', 'Pushya', 'Ashlesha', 'Magha', 'Purva Phalguni', 'Uttara Phalguni',
      'Hasta', 'Chitra', 'Swati', 'Vishakha', 'Anuradha', 'Jyeshtha',
      'Mula', 'Purva Ashadha', 'Uttara Ashadha', 'Shravana', 'Dhanishta', 'Shatabhisha',
      'Purva Bhadrapada', 'Uttara Bhadrapada', 'Revati'
    ];
    return naks[(index - 1) % 27];
  }
  
  static String _getNakshatraLord(int index) {
    const lords = ['Ketu', 'Venus', 'Sun', 'Moon', 'Mars', 'Rahu', 'Jupiter', 'Saturn', 'Mercury'];
    return lords[(index - 1) % 9];
  }

  static String _getPlanetSymbol(String planet) {
    const symbols = {
      'Sun': 'Su', 'Moon': 'Mo', 'Mars': 'Ma', 'Mercury': 'Me',
      'Jupiter': 'Ju', 'Venus': 'Ve', 'Saturn': 'Sa', 'Rahu': 'Ra', 'Ketu': 'Ke',
    };
    return symbols[planet] ?? planet.substring(0, 2);
  }

  /// Get Moon degree from chart data (for Dasha calculations)
  /// Backward-compatible utility method
  static double getMoonDegree(Map<String, dynamic> chartData) {
    // Try planets map format
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
    return 0.0;
  }

}
