import 'package:flutter_test/flutter_test.dart';
import 'package:astro_learn/core/services/special_days_service.dart';
import 'package:astro_learn/core/models/yoga_models.dart';

void main() {
  group('SpecialDaysService', () {
    late SpecialDaysService service;
    
    // Test location: New Delhi, India
    const double testLat = 28.6139;
    const double testLon = 77.2090;
    const double testTz = 5.5;
    
    setUp(() {
      service = SpecialDaysService();
    });
    
    test('getSpecialDaysForMonth returns map of dates to yogas', () async {
      // Test for January 2024
      final result = await service.getSpecialDaysForMonth(
        year: 2024,
        month: 1,
        latitude: testLat,
        longitude: testLon,
        timezone: testTz,
      );
      
      // Should return a map
      expect(result, isA<Map<DateTime, List<YogaResult>>>());
      
      // All dates should be in January 2024
      for (final date in result.keys) {
        expect(date.year, equals(2024));
        expect(date.month, equals(1));
      }
      
      // All yoga lists should be non-empty
      for (final yogas in result.values) {
        expect(yogas, isNotEmpty);
      }
    });
    
    test('getSpecialDaysForYear returns map for entire year', () async {
      // Test for 2024
      final result = await service.getSpecialDaysForYear(
        year: 2024,
        latitude: testLat,
        longitude: testLon,
        timezone: testTz,
      );
      
      // Should return a map
      expect(result, isA<Map<DateTime, List<YogaResult>>>());
      
      // All dates should be in 2024
      for (final date in result.keys) {
        expect(date.year, equals(2024));
      }
      
      // Should have dates from multiple months
      final months = result.keys.map((d) => d.month).toSet();
      expect(months.length, greaterThan(1));
    });
    
    test('getAuspiciousDaysForMonth filters correctly', () async {
      final result = await service.getAuspiciousDaysForMonth(
        year: 2024,
        month: 1,
        latitude: testLat,
        longitude: testLon,
        timezone: testTz,
      );
      
      // All yogas should be auspicious
      for (final yogas in result.values) {
        for (final yoga in yogas) {
          expect(yoga.isAuspicious, isTrue);
        }
      }
    });
    
    test('getInauspiciousDaysForMonth filters correctly', () async {
      final result = await service.getInauspiciousDaysForMonth(
        year: 2024,
        month: 1,
        latitude: testLat,
        longitude: testLon,
        timezone: testTz,
      );
      
      // All yogas should be inauspicious
      for (final yogas in result.values) {
        for (final yoga in yogas) {
          expect(yoga.isAuspicious, isFalse);
        }
      }
    });
    
    test('getMonthlyYogaStatistics returns count by type', () async {
      final result = await service.getMonthlyYogaStatistics(
        year: 2024,
        month: 1,
        latitude: testLat,
        longitude: testLon,
        timezone: testTz,
      );
      
      // Should return a map of yoga types to counts
      expect(result, isA<Map<YogaType, int>>());
      
      // All counts should be positive
      for (final count in result.values) {
        expect(count, greaterThan(0));
      }
    });
    
    test('getYearlyYogaStatistics returns count by type for year', () async {
      final result = await service.getYearlyYogaStatistics(
        year: 2024,
        latitude: testLat,
        longitude: testLon,
        timezone: testTz,
      );
      
      // Should return a map of yoga types to counts
      expect(result, isA<Map<YogaType, int>>());
      
      // All counts should be positive
      for (final count in result.values) {
        expect(count, greaterThan(0));
      }
      
      // Yearly counts should be higher than monthly
      final monthlyResult = await service.getMonthlyYogaStatistics(
        year: 2024,
        month: 1,
        latitude: testLat,
        longitude: testLon,
        timezone: testTz,
      );
      
      // At least one yoga type should have higher count in yearly stats
      bool hasHigherCount = false;
      for (final type in result.keys) {
        if (result[type]! > (monthlyResult[type] ?? 0)) {
          hasHigherCount = true;
          break;
        }
      }
      expect(hasHigherCount, isTrue);
    });
    
    test('dates are normalized to midnight', () async {
      final result = await service.getSpecialDaysForMonth(
        year: 2024,
        month: 1,
        latitude: testLat,
        longitude: testLon,
        timezone: testTz,
      );
      
      // All dates should be at midnight (00:00:00)
      for (final date in result.keys) {
        expect(date.hour, equals(0));
        expect(date.minute, equals(0));
        expect(date.second, equals(0));
        expect(date.millisecond, equals(0));
      }
    });
  });
}
