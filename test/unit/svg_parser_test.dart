import 'package:flutter_test/flutter_test.dart';
import 'package:astro_learn/core/services/svg_chart_parser.dart';

/// Unit tests for the enhanced SvgChartParser.
///
/// Run: flutter test test/unit/svg_parser_test.dart
void main() {
  group('SvgChartParser.extractPositions', () {
    test('extracts planets and ascendant from South Indian SVG', () {
      // Minimal SVG simulating a South Indian chart (400x400)
      // Grid: 4 cells of 100px each
      // Row 0: Pisces(12), Aries(1), Taurus(2), Gemini(3)
      // Row 1: Aqua(11),   center,   center,    Cancer(4)
      // Row 2: Capri(10),  center,   center,    Leo(5)
      // Row 3: Sagi(9),    Scorp(8), Libra(7),  Virgo(6)
      final svg = '''
<svg viewBox="0 0 400 400" xmlns="http://www.w3.org/2000/svg">
  <!-- Grid lines omitted for brevity -->
  <!-- Ascendant in Aries cell (col=1, row=0, sign=1) -->
  <text x="150" y="50">Asc</text>
  <!-- Sun in Scorpio cell (col=1, row=3, sign=8) -->
  <text x="150" y="350">Su</text>
  <!-- Moon in Cancer cell (col=3, row=1, sign=4) -->
  <text x="350" y="150">Mo</text>
  <!-- Mars in Leo cell (col=3, row=2, sign=5) -->
  <text x="350" y="250">Ma</text>
  <!-- Jupiter in Pisces cell (col=0, row=0, sign=12) -->
  <text x="50" y="50">Ju</text>
  <!-- Saturn in Capricorn cell (col=0, row=2, sign=10) -->
  <text x="50" y="250">Sa</text>
  <!-- Mercury in Sagittarius (col=0, row=3, sign=9) -->
  <text x="50" y="350">Me</text>
  <!-- Venus in Taurus (col=2, row=0, sign=2) -->
  <text x="250" y="50">Ve</text>
  <!-- Rahu in Gemini (col=3, row=0, sign=3) -->
  <text x="350" y="50">Ra</text>
  <!-- Ketu in Libra (col=2, row=3, sign=7) -->
  <text x="250" y="350">Ke</text>
</svg>
''';

      final result = SvgChartParser.extractPositions(svg);

      // Ascendant detection
      expect(result.ascendantSign, equals(1),
          reason: 'Ascendant should be Aries (1)');
      expect(result.ascendantName, equals('Aries'));

      // Planet signs
      expect(result.planetSigns['Su'], equals(8), reason: 'Sun in Scorpio');
      expect(result.planetSigns['Mo'], equals(4), reason: 'Moon in Cancer');
      expect(result.planetSigns['Ma'], equals(5), reason: 'Mars in Leo');
      expect(result.planetSigns['Ju'], equals(12), reason: 'Jupiter in Pisces');
      expect(result.planetSigns['Sa'], equals(10),
          reason: 'Saturn in Capricorn');
      expect(result.planetSigns['Me'], equals(9),
          reason: 'Mercury in Sagittarius');
      expect(result.planetSigns['Ve'], equals(2), reason: 'Venus in Taurus');
      expect(result.planetSigns['Ra'], equals(3), reason: 'Rahu in Gemini');
      expect(result.planetSigns['Ke'], equals(7), reason: 'Ketu in Libra');

      // Planet count
      expect(result.planetCount, equals(9));

      // House assignments (Asc = Aries = 1, so sign == house)
      expect(result.planetsInHouses[8]!, contains('Su'),
          reason: 'Sun in House 8');
      expect(result.planetsInHouses[4]!, contains('Mo'),
          reason: 'Moon in House 4');
      expect(result.planetsInHouses[5]!, contains('Ma'),
          reason: 'Mars in House 5');
      expect(result.planetsInHouses[12]!, contains('Ju'),
          reason: 'Jupiter in House 12');
    });

    test('handles Cancer ascendant house calculation', () {
      // With Cancer (4) as ascendant:
      //   Cancer(4) → House 1, Leo(5) → House 2, Aries(1) → House 10
      final svg = '''
<svg viewBox="0 0 400 400">
  <text x="350" y="150">Asc</text>
  <text x="150" y="50">Su</text>
  <text x="350" y="250">Ma</text>
</svg>
''';

      final result = SvgChartParser.extractPositions(svg);

      expect(result.ascendantSign, equals(4),
          reason: 'Ascendant should be Cancer (4)');

      // Sun at Aries(1): house = ((1-4+12)%12)+1 = 10
      expect(result.planetsInHouses[10]!, contains('Su'),
          reason: 'Sun in House 10');
      // Mars at Leo(5): house = ((5-4+12)%12)+1 = 2
      expect(result.planetsInHouses[2]!, contains('Ma'),
          reason: 'Mars in House 2');
    });

    test('returns empty result for invalid SVG', () {
      final result = SvgChartParser.extractPositions('');
      expect(result.hasData, isFalse);
      expect(result.ascendantSign, equals(0));
      expect(result.planetCount, equals(0));
    });

    test('ignores non-planet text elements', () {
      final svg = '''
<svg viewBox="0 0 400 400">
  <text x="150" y="50">Asc</text>
  <text x="150" y="350">Su</text>
  <text x="250" y="150">RandomText</text>
  <text x="50" y="50">D1</text>
</svg>
''';

      final result = SvgChartParser.extractPositions(svg);
      expect(result.planetCount, equals(1),
          reason: 'Only Su should be detected');
    });
  });

  group('SvgChartParser.calculateNakshatra', () {
    test('calculates Ashwini for 0 degrees', () {
      final nak = SvgChartParser.calculateNakshatra(0.0);
      expect(nak.nakshatra, equals('Ashwini'));
      expect(nak.pada, equals(1));
      expect(nak.lord, equals('Ketu'));
      expect(nak.index, equals(0));
    });

    test('calculates Rohini for ~45 degrees', () {
      // Rohini starts at ~40° (nakshatra index 3)
      // 40° / 13.333° = 3.0 → index 3 = Rohini
      final nak = SvgChartParser.calculateNakshatra(45.0);
      expect(nak.nakshatra, equals('Rohini'));
      expect(nak.lord, equals('Moon'));
    });

    test('calculates Jyeshtha for ~236 degrees', () {
      // Jyeshtha: index 17, starts at 226.67°, ends at 240°
      final nak = SvgChartParser.calculateNakshatra(236.0);
      expect(nak.nakshatra, equals('Jyeshtha'));
      expect(nak.lord, equals('Mercury'));
    });

    test('calculates Revati for ~359 degrees', () {
      // Revati: index 26, starts at 346.67°, ends at 360°
      final nak = SvgChartParser.calculateNakshatra(359.0);
      expect(nak.nakshatra, equals('Revati'));
      expect(nak.lord, equals('Mercury'));
    });

    test('wraps 360 degrees to 0 (Ashwini)', () {
      final nak = SvgChartParser.calculateNakshatra(360.0);
      expect(nak.nakshatra, equals('Ashwini'));
    });

    test('pada calculation is correct', () {
      // Each nakshatra = 13.333°, each pada = 3.333°
      // Ashwini pada 1: 0° - 3.333°
      // Ashwini pada 2: 3.333° - 6.667°
      // Ashwini pada 3: 6.667° - 10°
      // Ashwini pada 4: 10° - 13.333°
      expect(SvgChartParser.calculateNakshatra(1.0).pada, equals(1));
      expect(SvgChartParser.calculateNakshatra(4.0).pada, equals(2));
      expect(SvgChartParser.calculateNakshatra(7.0).pada, equals(3));
      expect(SvgChartParser.calculateNakshatra(11.0).pada, equals(4));
    });
  });

  group('SvgChartParser.calculateAllNakshatras', () {
    test('calculates nakshatras for multiple planets', () {
      final degrees = {
        'Sun': 216.5, // Vishakha region
        'Moon': 45.0, // Rohini region
        'Mars': 0.5, // Ashwini region
      };

      final results = SvgChartParser.calculateAllNakshatras(degrees);

      expect(results.length, equals(3));
      expect(results['Sun']!.nakshatra, equals('Anuradha'));
      expect(results['Moon']!.nakshatra, equals('Rohini'));
      expect(results['Mars']!.nakshatra, equals('Ashwini'));
    });
  });

  group('SvgChartParser.signToHouse', () {
    test('Aries ascendant: sign == house', () {
      for (int sign = 1; sign <= 12; sign++) {
        expect(SvgChartParser.signToHouse(sign, 1), equals(sign));
      }
    });

    test('Cancer ascendant: Cancer=H1, Leo=H2, Aries=H10', () {
      expect(SvgChartParser.signToHouse(4, 4), equals(1));
      expect(SvgChartParser.signToHouse(5, 4), equals(2));
      expect(SvgChartParser.signToHouse(1, 4), equals(10));
      expect(SvgChartParser.signToHouse(3, 4), equals(12));
    });

    test('Pisces ascendant: Pisces=H1, Aries=H2', () {
      expect(SvgChartParser.signToHouse(12, 12), equals(1));
      expect(SvgChartParser.signToHouse(1, 12), equals(2));
      expect(SvgChartParser.signToHouse(11, 12), equals(12));
    });
  });

  group('SvgChartParser.buildKundaliData', () {
    test('builds complete data from SVGs and degrees', () {
      final svgs = {
        'd1': '''<svg viewBox="0 0 400 400">
          <text x="150" y="50">Asc</text>
          <text x="150" y="350">Su</text>
          <text x="350" y="150">Mo</text>
        </svg>''',
        'd9': '''<svg viewBox="0 0 400 400">
          <text x="350" y="250">Asc</text>
          <text x="50" y="50">Su</text>
          <text x="150" y="350">Mo</text>
        </svg>''',
      };

      final degrees = {
        'Sun': 216.5,
        'Moon': 45.0,
      };

      final data = SvgChartParser.buildKundaliData(
        svgsByDivision: svgs,
        d1PlanetDegrees: degrees,
      );

      // Check ascendants
      final ascendants = data['ascendants'] as Map<String, int>;
      expect(ascendants['d1'], equals(1), reason: 'D1 asc = Aries');
      expect(ascendants['d9'], equals(5), reason: 'D9 asc = Leo');

      // Check nakshatras were calculated
      final nakshatras = data['planetNakshatras'] as Map<String, String>;
      expect(nakshatras['Sun'], isNotEmpty);
      expect(nakshatras['Moon'], isNotEmpty);
    });
  });

  group('SvgChartParser utilities', () {
    test('getSignName returns correct names', () {
      expect(SvgChartParser.getSignName(1), equals('Aries'));
      expect(SvgChartParser.getSignName(7), equals('Libra'));
      expect(SvgChartParser.getSignName(12), equals('Pisces'));
    });

    test('getPlanetName returns full names', () {
      expect(SvgChartParser.getPlanetName('Su'), equals('Sun'));
      expect(SvgChartParser.getPlanetName('Ra'), equals('Rahu'));
      expect(SvgChartParser.getPlanetName('Unknown'), equals('Unknown'));
    });

    test('isValidSvgChart validates structure', () {
      expect(SvgChartParser.isValidSvgChart(''), isFalse);
      expect(
          SvgChartParser.isValidSvgChart('<svg><text>Su</text></svg>'), isTrue);
      expect(SvgChartParser.isValidSvgChart('<div>Hello</div>'), isFalse);
    });

    test('houseToSign is inverse of signToHouse', () {
      for (int asc = 1; asc <= 12; asc++) {
        for (int house = 1; house <= 12; house++) {
          final sign = SvgChartParser.houseToSign(house, asc);
          final backToHouse = SvgChartParser.signToHouse(sign, asc);
          expect(backToHouse, equals(house),
              reason: 'asc=$asc, house=$house, sign=$sign');
        }
      }
    });
  });
}
