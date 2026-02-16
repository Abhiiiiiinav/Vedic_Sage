
import 'package:flutter_test/flutter_test.dart';
import 'package:astro_learn/core/astro/kundali_engine.dart';
import 'package:astro_learn/core/astro/algorithms/astro_math.dart';

void main() {
  group('Kundali Engine Accuracy', () {
    // Test Case: 1st Jan 2000, 12:00 UTC, Greenwich (0, 51.5)
    // Julian Day: 2451545.0
    // Sun Mean Longitude: ~280.46
    
    test('Standard Epoch (J2000)', () {
      final date = DateTime.utc(2000, 1, 1, 12, 0);
      final jd = AstroMath.julianDay(date);
      expect(jd, closeTo(2451545.0, 0.001));
      
      final chart = KundaliEngine.calculateChart(
        birthTime: date,
        latitude: 51.4779, // Greenwich
        longitude: 0.0,
        timezoneOffset: 0.0,
      );
      
      final ayanamsa = chart.meta['ayanamsa'] as double;
      expect(ayanamsa, closeTo(23.85, 0.1)); // Approx Lahiri at 2000
      
      final planets = chart.planets;
      // Solar longitude is in planets['Sun']['degree']
      expect(planets['Sun']!['degree'], closeTo(256, 2.0)); 
    });

    test('Verification: New Delhi Chart', () {
       // 16 Aug 1990, 06:30 AM IST (UTC+5:30) => 01:00 UTC
       // Input is local time. 
       final date = DateTime(1990, 8, 16, 6, 30); 
       
       final chart = KundaliEngine.calculateChart(
         birthTime: date, 
         latitude: 28.6139, 
         longitude: 77.2090,
         timezoneOffset: 5.5,
       );
       
       final asc = chart.ascendant['degree'] as double;
       final planets = chart.planets;
       
       // Just ensuring values are in valid range
       expect(asc, inInclusiveRange(0, 360));
       expect(planets['Sun']!['degree'], inInclusiveRange(0, 360));
       expect(planets['Moon']!['degree'], inInclusiveRange(0, 360));
       
       // Verify structure
       expect(chart.houses, hasLength(12));
       expect(chart.vargas, isNotEmpty);
       expect(chart.dasha, isNotEmpty);
    });
  });
}
