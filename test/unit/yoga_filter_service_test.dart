import 'package:flutter_test/flutter_test.dart';
import 'package:astro_learn/core/models/yoga_models.dart';
import 'package:astro_learn/core/services/yoga_filter_service.dart';

void main() {
  late YogaFilterService filterService;
  late List<YogaResult> testYogas;

  setUp(() {
    filterService = YogaFilterService();
    
    // Create test yoga results
    testYogas = [
      YogaResult(
        type: YogaType.amritSiddhi,
        definition: YogaDefinitions.amritSiddhi,
        activeDate: DateTime(2024, 1, 15),
        tithi: 'Shukla Pratipada',
        nakshatra: 'Ashwini',
        vara: 'Sunday',
      ),
      YogaResult(
        type: YogaType.guruPushya,
        definition: YogaDefinitions.guruPushya,
        activeDate: DateTime(2024, 1, 18),
        tithi: 'Shukla Chaturthi',
        nakshatra: 'Pushya',
        vara: 'Thursday',
      ),
      YogaResult(
        type: YogaType.dagdha,
        definition: YogaDefinitions.dagdha,
        activeDate: DateTime(2024, 1, 20),
        tithi: 'Shukla Shashthi',
        nakshatra: 'Mrigashira',
        vara: 'Saturday',
      ),
      YogaResult(
        type: YogaType.siddha,
        definition: YogaDefinitions.siddha,
        activeDate: DateTime(2024, 1, 22),
        tithi: 'Shukla Ashtami',
        nakshatra: 'Punarvasu',
        vara: 'Monday',
      ),
      YogaResult(
        type: YogaType.visha,
        definition: YogaDefinitions.visha,
        activeDate: DateTime(2024, 1, 25),
        tithi: 'Shukla Ekadashi',
        nakshatra: 'Ashlesha',
        vara: 'Wednesday',
      ),
    ];
  });

  group('YogaFilterService - filterByPurpose', () {
    test('Should filter yogas by marriage purpose', () {
      final result = filterService.filterByPurpose(testYogas, YogaPurpose.marriage);
      
      expect(result.length, equals(2));
      expect(result.any((y) => y.type == YogaType.amritSiddhi), isTrue);
      expect(result.any((y) => y.type == YogaType.siddha), isTrue);
    });

    test('Should filter yogas by business purpose', () {
      final result = filterService.filterByPurpose(testYogas, YogaPurpose.business);
      
      expect(result.length, equals(3));
      expect(result.any((y) => y.type == YogaType.amritSiddhi), isTrue);
      expect(result.any((y) => y.type == YogaType.guruPushya), isTrue);
      expect(result.any((y) => y.type == YogaType.siddha), isTrue);
    });

    test('Should filter yogas by spiritual purpose', () {
      final result = filterService.filterByPurpose(testYogas, YogaPurpose.spiritual);
      
      expect(result.length, equals(3));
      expect(result.any((y) => y.type == YogaType.amritSiddhi), isTrue);
      expect(result.any((y) => y.type == YogaType.guruPushya), isTrue);
      expect(result.any((y) => y.type == YogaType.siddha), isTrue);
    });

    test('Should return empty list when no yogas match purpose', () {
      // Create a list with only inauspicious yogas
      final inauspiciousOnly = [testYogas[2], testYogas[4]];
      final result = filterService.filterByPurpose(inauspiciousOnly, YogaPurpose.marriage);
      
      expect(result, isEmpty);
    });

    test('Should return empty list for empty input', () {
      final result = filterService.filterByPurpose([], YogaPurpose.marriage);
      
      expect(result, isEmpty);
    });
  });

  group('YogaFilterService - getAuspiciousYogas', () {
    test('Should return only auspicious yogas', () {
      final result = filterService.getAuspiciousYogas(testYogas);
      
      expect(result.length, equals(3));
      expect(result.every((y) => y.isAuspicious), isTrue);
      expect(result.any((y) => y.type == YogaType.amritSiddhi), isTrue);
      expect(result.any((y) => y.type == YogaType.guruPushya), isTrue);
      expect(result.any((y) => y.type == YogaType.siddha), isTrue);
    });

    test('Should return empty list when no auspicious yogas present', () {
      final inauspiciousOnly = [testYogas[2], testYogas[4]];
      final result = filterService.getAuspiciousYogas(inauspiciousOnly);
      
      expect(result, isEmpty);
    });

    test('Should return empty list for empty input', () {
      final result = filterService.getAuspiciousYogas([]);
      
      expect(result, isEmpty);
    });
  });

  group('YogaFilterService - getInauspiciousYogas', () {
    test('Should return only inauspicious yogas', () {
      final result = filterService.getInauspiciousYogas(testYogas);
      
      expect(result.length, equals(2));
      expect(result.every((y) => !y.isAuspicious), isTrue);
      expect(result.any((y) => y.type == YogaType.dagdha), isTrue);
      expect(result.any((y) => y.type == YogaType.visha), isTrue);
    });

    test('Should return empty list when no inauspicious yogas present', () {
      final auspiciousOnly = [testYogas[0], testYogas[1], testYogas[3]];
      final result = filterService.getInauspiciousYogas(auspiciousOnly);
      
      expect(result, isEmpty);
    });

    test('Should return empty list for empty input', () {
      final result = filterService.getInauspiciousYogas([]);
      
      expect(result, isEmpty);
    });
  });

  group('YogaFilterService - filterByPurposes', () {
    test('Should filter by multiple purposes with OR logic', () {
      final result = filterService.filterByPurposes(
        testYogas,
        [YogaPurpose.education, YogaPurpose.health],
      );
      
      // amritSiddhi has both education and health
      // guruPushya has education
      // siddha has education
      expect(result.length, equals(3));
      expect(result.any((y) => y.type == YogaType.amritSiddhi), isTrue);
      expect(result.any((y) => y.type == YogaType.guruPushya), isTrue);
      expect(result.any((y) => y.type == YogaType.siddha), isTrue);
    });

    test('Should return all yogas when purposes list is empty', () {
      final result = filterService.filterByPurposes(testYogas, []);
      
      expect(result.length, equals(testYogas.length));
    });

    test('Should return empty list for empty input', () {
      final result = filterService.filterByPurposes([], [YogaPurpose.marriage]);
      
      expect(result, isEmpty);
    });
  });

  group('YogaFilterService - groupByAuspiciousness', () {
    test('Should group yogas by auspiciousness', () {
      final result = filterService.groupByAuspiciousness(testYogas);
      
      expect(result.containsKey('auspicious'), isTrue);
      expect(result.containsKey('inauspicious'), isTrue);
      expect(result['auspicious']?.length, equals(3));
      expect(result['inauspicious']?.length, equals(2));
    });

    test('Should handle empty input', () {
      final result = filterService.groupByAuspiciousness([]);
      
      expect(result['auspicious'], isEmpty);
      expect(result['inauspicious'], isEmpty);
    });

    test('Should handle only auspicious yogas', () {
      final auspiciousOnly = [testYogas[0], testYogas[1], testYogas[3]];
      final result = filterService.groupByAuspiciousness(auspiciousOnly);
      
      expect(result['auspicious']?.length, equals(3));
      expect(result['inauspicious'], isEmpty);
    });
  });

  group('YogaFilterService - getCountByPurpose', () {
    test('Should count yogas for each purpose', () {
      final result = filterService.getCountByPurpose(testYogas);
      
      expect(result[YogaPurpose.marriage], equals(2));
      expect(result[YogaPurpose.business], equals(3));
      expect(result[YogaPurpose.education], equals(3));
      expect(result[YogaPurpose.travel], equals(1));
      expect(result[YogaPurpose.spiritual], equals(3));
      expect(result[YogaPurpose.health], equals(1));
    });

    test('Should return zero counts for empty input', () {
      final result = filterService.getCountByPurpose([]);
      
      for (final purpose in YogaPurpose.values) {
        expect(result[purpose], equals(0));
      }
    });

    test('Should return all zero counts for only inauspicious yogas', () {
      final inauspiciousOnly = [testYogas[2], testYogas[4]];
      final result = filterService.getCountByPurpose(inauspiciousOnly);
      
      for (final purpose in YogaPurpose.values) {
        expect(result[purpose], equals(0));
      }
    });
  });
}
