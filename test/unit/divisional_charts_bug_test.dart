/// Bug Condition Exploration Test for Divisional Chart Calculations
/// 
/// **Validates: Requirements 1.1-1.14, 2.1-2.14**
/// 
/// This test encodes the CORRECT expected behavior using proper Vedic formulas.
/// It MUST FAIL on unfixed code - failure confirms the bug exists.
/// When it passes after the fix, it validates the implementation is correct.
/// 
/// Test Data: Nov 22, 2003, 13:30, Mysore, India
/// Location: 12.2958°N, 76.6394°E, TZ +5.5 (IST)
/// Ayanamsha: Lahiri

import 'package:flutter_test/flutter_test.dart';
import 'package:astro_learn/core/astro/accurate_kundali_engine.dart';

void main() {
  group('Divisional Chart Bug Condition Exploration', () {
    // Test birth data
    final birthDate = DateTime(2003, 11, 22, 13, 30);
    const latitude = 12.2958;
    const longitude = 76.6394;
    const timezoneOffset = 5.5;

    late KundaliResult chart;

    setUpAll(() {
      // Generate the chart once for all tests
      chart = AccurateKundaliEngine.generateChart(
        birthDateTime: birthDate,
        latitude: latitude,
        longitude: longitude,
        timezoneOffset: timezoneOffset,
      );
    });

    /// Helper to get planet degree from chart
    double getPlanetDegree(String planet) {
      return chart.planets[planet]!['degree'] as double;
    }

    /// Helper functions implementing CORRECT Vedic formulas
    
    int expectedD4Sign(double deg) {
      // D4: 7°30' segments, offsets [0, 3, 6, 9] (1st/4th/7th/10th from sign)
      int rashi = (deg ~/ 30).toInt();
      double posInSign = deg % 30;
      int part = (posInSign / 7.5).floor(); // 0-3
      const offsets = [0, 3, 6, 9];
      return ((rashi + offsets[part]) % 12) + 1;
    }

    int expectedD7Sign(double deg) {
      // D7: 4°17'8" segments, odd signs from same sign, even signs from 7th sign
      int rashi = (deg ~/ 30).toInt();
      bool isOdd = (rashi % 2 == 0); // Aries=0 is odd
      double posInSign = deg % 30;
      int part = (posInSign / (30.0 / 7)).floor(); // 0-6
      int startSign = isOdd ? rashi : (rashi + 6) % 12;
      return ((startSign + part) % 12) + 1;
    }

    int expectedD9Sign(double deg) {
      // D9: 3°20' segments, Fire→Aries, Earth→Capricorn, Air→Libra, Water→Cancer
      int rashi = (deg ~/ 30).toInt();
      double posInSign = deg % 30;
      int part = (posInSign / (30.0 / 9)).floor(); // 0-8
      
      int element = rashi % 4; // 0=fire, 1=earth, 2=air, 3=water
      const startSigns = [0, 9, 6, 3]; // Aries, Capricorn, Libra, Cancer
      int startSign = startSigns[element];
      
      return ((startSign + part) % 12) + 1;
    }

    int expectedD10Sign(double deg) {
      // D10: 3° segments, odd from same sign, even from 9th sign
      int rashi = (deg ~/ 30).toInt();
      bool isOdd = (rashi % 2 == 0); // Aries=0 is odd
      double posInSign = deg % 30;
      int part = (posInSign / 3.0).floor(); // 0-9
      int startSign = isOdd ? rashi : (rashi + 8) % 12;
      return ((startSign + part) % 12) + 1;
    }

    int expectedD12Sign(double deg) {
      // D12: 2°30' segments, always from same sign
      int rashi = (deg ~/ 30).toInt();
      double posInSign = deg % 30;
      int part = (posInSign / 2.5).floor(); // 0-11
      return ((rashi + part) % 12) + 1;
    }

    int expectedD16Sign(double deg) {
      // D16: 1°52'30" segments, Movable→Aries, Fixed→Leo, Dual→Sagittarius
      int rashi = (deg ~/ 30).toInt();
      double posInSign = deg % 30;
      int part = (posInSign / (30.0 / 16)).floor(); // 0-15
      
      int classification = rashi % 3; // 0=movable, 1=fixed, 2=dual
      const startSigns = [0, 4, 8]; // Aries, Leo, Sagittarius
      int startSign = startSigns[classification];
      
      return ((startSign + part) % 12) + 1;
    }

    int expectedD20Sign(double deg) {
      // D20: 1°30' segments, Movable→Aries, Fixed→Sagittarius, Dual→Leo
      int rashi = (deg ~/ 30).toInt();
      double posInSign = deg % 30;
      int part = (posInSign / 1.5).floor(); // 0-19
      
      int classification = rashi % 3;
      const startSigns = [0, 8, 4]; // Aries, Sagittarius, Leo (different from D16!)
      int startSign = startSigns[classification];
      
      return ((startSign + part) % 12) + 1;
    }

    int expectedD24Sign(double deg) {
      // D24: 1°15' segments, Odd→Leo, Even→Cancer
      int rashi = (deg ~/ 30).toInt();
      bool isOdd = (rashi % 2 == 0);
      double posInSign = deg % 30;
      int part = (posInSign / 1.25).floor(); // 0-23
      int startSign = isOdd ? 4 : 3; // Leo or Cancer
      return ((startSign + part) % 12) + 1;
    }

    int expectedD27Sign(double deg) {
      // D27: 1°6'40" segments, Fire→Aries, Earth→Cancer, Air→Libra, Water→Capricorn
      int rashi = (deg ~/ 30).toInt();
      double posInSign = deg % 30;
      int part = (posInSign / (30.0 / 27)).floor(); // 0-26
      
      int element = rashi % 4;
      const startSigns = [0, 3, 6, 9]; // Aries, Cancer, Libra, Capricorn
      int startSign = startSigns[element];
      
      return ((startSign + part) % 12) + 1;
    }

    int expectedD40Sign(double deg) {
      // D40: 0°45' segments, Movable→Aries, Fixed→Leo, Dual→Sagittarius
      int rashi = (deg ~/ 30).toInt();
      double posInSign = deg % 30;
      int part = (posInSign / 0.75).floor(); // 0-39
      
      int classification = rashi % 3;
      const startSigns = [0, 4, 8];
      int startSign = startSigns[classification];
      
      return ((startSign + part) % 12) + 1;
    }

    int expectedD45Sign(double deg) {
      // D45: 0°40' segments, Movable→Aries, Fixed→Leo, Dual→Sagittarius
      int rashi = (deg ~/ 30).toInt();
      double posInSign = deg % 30;
      int part = (posInSign / (30.0 / 45)).floor(); // 0-44
      
      int classification = rashi % 3;
      const startSigns = [0, 4, 8];
      int startSign = startSigns[classification];
      
      return ((startSign + part) % 12) + 1;
    }

    int expectedD60Sign(double deg) {
      // D60: 0°30' segments, Odd→Aries, Even→Libra
      int rashi = (deg ~/ 30).toInt();
      bool isOdd = (rashi % 2 == 0);
      double posInSign = deg % 30;
      int part = (posInSign / 0.5).floor(); // 0-59
      int startSign = isOdd ? 0 : 6; // Aries or Libra
      return ((startSign + part) % 12) + 1;
    }

    test('D4 (Chaturthamsa) - Sun should use 1st/4th/7th/10th sign rule', () {
      final sunDeg = getPlanetDegree('Sun');
      final d4Data = chart.vargas['D4'] as Map<String, dynamic>;
      final planetSigns = d4Data['planetSigns'] as Map<String, int>;
      final actualSign = planetSigns['Sun']!;
      final expectedSign = expectedD4Sign(sunDeg);
      
      expect(actualSign, expectedSign,
          reason: 'D4 Sun: Expected sign $expectedSign but got $actualSign. '
              'Sun at ${sunDeg.toStringAsFixed(2)}° should use 7°30\' segments with 1st/4th/7th/10th rule.');
    });

    test('D7 (Saptamsa) - Moon should use odd/even sign rule', () {
      final moonDeg = getPlanetDegree('Moon');
      final d7Data = chart.vargas['D7'] as Map<String, dynamic>;
      final planetSigns = d7Data['planetSigns'] as Map<String, int>;
      final actualSign = planetSigns['Moon']!;
      final expectedSign = expectedD7Sign(moonDeg);
      
      expect(actualSign, expectedSign,
          reason: 'D7 Moon: Expected sign $expectedSign but got $actualSign. '
              'Moon at ${moonDeg.toStringAsFixed(2)}° should use 4°17\'8" segments with odd/even rule.');
    });

    test('D9 (Navamsa) - All planets should use element-based starting points', () {
      final d9Data = chart.vargas['D9'] as Map<String, dynamic>;
      final planetSigns = d9Data['planetSigns'] as Map<String, int>;
      
      // Test all planets
      for (final planet in ['Sun', 'Moon', 'Mars', 'Mercury', 'Jupiter', 'Venus', 'Saturn', 'Rahu', 'Ketu']) {
        final deg = getPlanetDegree(planet);
        final actualSign = planetSigns[planet]!;
        final expectedSign = expectedD9Sign(deg);
        
        expect(actualSign, expectedSign,
            reason: 'D9 $planet: Expected sign $expectedSign but got $actualSign. '
                '$planet at ${deg.toStringAsFixed(2)}° should use element-based starting point (Fire→Aries, Earth→Capricorn, Air→Libra, Water→Cancer).');
      }
    });

    test('D10 (Dasamsa) - Mars should use odd/even sign rule with 9th sign offset', () {
      final marsDeg = getPlanetDegree('Mars');
      final d10Data = chart.vargas['D10'] as Map<String, dynamic>;
      final planetSigns = d10Data['planetSigns'] as Map<String, int>;
      final actualSign = planetSigns['Mars']!;
      final expectedSign = expectedD10Sign(marsDeg);
      
      expect(actualSign, expectedSign,
          reason: 'D10 Mars: Expected sign $expectedSign but got $actualSign. '
              'Mars at ${marsDeg.toStringAsFixed(2)}° should use 3° segments with odd from same sign, even from 9th sign.');
    });

    test('D12 (Dwadasamsa) - Venus should always count from same sign', () {
      final venusDeg = getPlanetDegree('Venus');
      final d12Data = chart.vargas['D12'] as Map<String, dynamic>;
      final planetSigns = d12Data['planetSigns'] as Map<String, int>;
      final actualSign = planetSigns['Venus']!;
      final expectedSign = expectedD12Sign(venusDeg);
      
      expect(actualSign, expectedSign,
          reason: 'D12 Venus: Expected sign $expectedSign but got $actualSign. '
              'Venus at ${venusDeg.toStringAsFixed(2)}° should use 2°30\' segments always from same sign.');
    });

    test('D16 (Shodasamsa) - Jupiter should use movable/fixed/dual classification', () {
      final jupiterDeg = getPlanetDegree('Jupiter');
      final d16Data = chart.vargas['D16'] as Map<String, dynamic>;
      final planetSigns = d16Data['planetSigns'] as Map<String, int>;
      final actualSign = planetSigns['Jupiter']!;
      final expectedSign = expectedD16Sign(jupiterDeg);
      
      expect(actualSign, expectedSign,
          reason: 'D16 Jupiter: Expected sign $expectedSign but got $actualSign. '
              'Jupiter at ${jupiterDeg.toStringAsFixed(2)}° should use 1°52\'30" segments with Movable→Aries, Fixed→Leo, Dual→Sagittarius.');
    });

    test('D20 (Vimshamsa) - Saturn should use correct classification (different from D16)', () {
      final saturnDeg = getPlanetDegree('Saturn');
      final d20Data = chart.vargas['D20'] as Map<String, dynamic>;
      final planetSigns = d20Data['planetSigns'] as Map<String, int>;
      final actualSign = planetSigns['Saturn']!;
      final expectedSign = expectedD20Sign(saturnDeg);
      
      expect(actualSign, expectedSign,
          reason: 'D20 Saturn: Expected sign $expectedSign but got $actualSign. '
              'Saturn at ${saturnDeg.toStringAsFixed(2)}° should use 1°30\' segments with Movable→Aries, Fixed→Sagittarius, Dual→Leo.');
    });

    test('D24 (Chaturvimshamsa) - Mercury should use odd/even sign rule with Leo/Cancer', () {
      final mercuryDeg = getPlanetDegree('Mercury');
      final d24Data = chart.vargas['D24'] as Map<String, dynamic>;
      final planetSigns = d24Data['planetSigns'] as Map<String, int>;
      final actualSign = planetSigns['Mercury']!;
      final expectedSign = expectedD24Sign(mercuryDeg);
      
      expect(actualSign, expectedSign,
          reason: 'D24 Mercury: Expected sign $expectedSign but got $actualSign. '
              'Mercury at ${mercuryDeg.toStringAsFixed(2)}° should use 1°15\' segments with Odd→Leo, Even→Cancer.');
    });

    test('D27 (Bhamsa) - All planets should use element-based starting points', () {
      final d27Data = chart.vargas['D27'] as Map<String, dynamic>;
      final planetSigns = d27Data['planetSigns'] as Map<String, int>;
      
      // Test all planets
      for (final planet in ['Sun', 'Moon', 'Mars', 'Mercury', 'Jupiter', 'Venus', 'Saturn', 'Rahu', 'Ketu']) {
        final deg = getPlanetDegree(planet);
        final actualSign = planetSigns[planet]!;
        final expectedSign = expectedD27Sign(deg);
        
        expect(actualSign, expectedSign,
            reason: 'D27 $planet: Expected sign $expectedSign but got $actualSign. '
                '$planet at ${deg.toStringAsFixed(2)}° should use 1°6\'40" segments with Fire→Aries, Earth→Cancer, Air→Libra, Water→Capricorn.');
      }
    });

    test('D40 (Khavedamsa) - Rahu should use movable/fixed/dual classification', () {
      final rahuDeg = getPlanetDegree('Rahu');
      final d40Data = chart.vargas['D40'] as Map<String, dynamic>;
      final planetSigns = d40Data['planetSigns'] as Map<String, int>;
      final actualSign = planetSigns['Rahu']!;
      final expectedSign = expectedD40Sign(rahuDeg);
      
      expect(actualSign, expectedSign,
          reason: 'D40 Rahu: Expected sign $expectedSign but got $actualSign. '
              'Rahu at ${rahuDeg.toStringAsFixed(2)}° should use 0°45\' segments with Movable→Aries, Fixed→Leo, Dual→Sagittarius.');
    });

    test('D45 (Akshavedamsa) - Ketu should use movable/fixed/dual classification', () {
      final ketuDeg = getPlanetDegree('Ketu');
      final d45Data = chart.vargas['D45'] as Map<String, dynamic>;
      final planetSigns = d45Data['planetSigns'] as Map<String, int>;
      final actualSign = planetSigns['Ketu']!;
      final expectedSign = expectedD45Sign(ketuDeg);
      
      expect(actualSign, expectedSign,
          reason: 'D45 Ketu: Expected sign $expectedSign but got $actualSign. '
              'Ketu at ${ketuDeg.toStringAsFixed(2)}° should use 0°40\' segments with Movable→Aries, Fixed→Leo, Dual→Sagittarius.');
    });

    test('D60 (Shashtiamsa) - All planets should use odd/even sign rule with Aries/Libra', () {
      final d60Data = chart.vargas['D60'] as Map<String, dynamic>;
      final planetSigns = d60Data['planetSigns'] as Map<String, int>;
      
      // Test all planets
      for (final planet in ['Sun', 'Moon', 'Mars', 'Mercury', 'Jupiter', 'Venus', 'Saturn', 'Rahu', 'Ketu']) {
        final deg = getPlanetDegree(planet);
        final actualSign = planetSigns[planet]!;
        final expectedSign = expectedD60Sign(deg);
        
        expect(actualSign, expectedSign,
            reason: 'D60 $planet: Expected sign $expectedSign but got $actualSign. '
                '$planet at ${deg.toStringAsFixed(2)}° should use 0°30\' segments with Odd→Aries, Even→Libra.');
      }
    });

    test('Ascendant should also use correct formulas in all divisional charts', () {
      final ascDeg = chart.ascendant['degree'] as double;
      
      // Test ascendant in each divisional chart
      final tests = {
        'D4': expectedD4Sign(ascDeg),
        'D7': expectedD7Sign(ascDeg),
        'D9': expectedD9Sign(ascDeg),
        'D10': expectedD10Sign(ascDeg),
        'D12': expectedD12Sign(ascDeg),
        'D16': expectedD16Sign(ascDeg),
        'D20': expectedD20Sign(ascDeg),
        'D24': expectedD24Sign(ascDeg),
        'D27': expectedD27Sign(ascDeg),
        'D40': expectedD40Sign(ascDeg),
        'D45': expectedD45Sign(ascDeg),
        'D60': expectedD60Sign(ascDeg),
      };
      
      for (final entry in tests.entries) {
        final chartName = entry.key;
        final expectedSign = entry.value;
        final chartData = chart.vargas[chartName] as Map<String, dynamic>;
        final actualSign = chartData['ascendantSign'] as int;
        
        expect(actualSign, expectedSign,
            reason: '$chartName Ascendant: Expected sign $expectedSign but got $actualSign. '
                'Ascendant at ${ascDeg.toStringAsFixed(2)}° should use correct Vedic formula for $chartName.');
      }
    });
  });
}
