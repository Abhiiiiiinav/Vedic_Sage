import 'package:flutter_test/flutter_test.dart';
import 'package:astro_learn/core/services/yoga_detection_service.dart';
import 'package:astro_learn/core/services/special_days_service.dart';
import 'package:astro_learn/core/services/yoga_filter_service.dart';
import 'package:astro_learn/core/models/yoga_models.dart';

void main() {
  group('Yoga Error Handling Tests', () {
    late YogaDetectionService yogaService;
    late SpecialDaysService specialDaysService;
    late YogaFilterService filterService;

    setUp(() {
      yogaService = YogaDetectionService();
      specialDaysService = SpecialDaysService();
      filterService = YogaFilterService();
    });

    group('YogaDetectionService Input Validation', () {
      test('should throw ArgumentError for invalid latitude', () async {
        expect(
          () => yogaService.detectYogas(
            date: DateTime(2024, 1, 1),
            latitude: 100.0, // Invalid: > 90
            longitude: 77.0,
            timezone: 5.5,
          ),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should throw ArgumentError for invalid longitude', () async {
        expect(
          () => yogaService.detectYogas(
            date: DateTime(2024, 1, 1),
            latitude: 28.0,
            longitude: 200.0, // Invalid: > 180
            timezone: 5.5,
          ),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should throw ArgumentError for invalid timezone', () async {
        expect(
          () => yogaService.detectYogas(
            date: DateTime(2024, 1, 1),
            latitude: 28.0,
            longitude: 77.0,
            timezone: 15.0, // Invalid: > 14
          ),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should throw ArgumentError for date out of range', () async {
        expect(
          () => yogaService.detectYogas(
            date: DateTime(1800, 1, 1), // Too old
            latitude: 28.0,
            longitude: 77.0,
            timezone: 5.5,
          ),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should accept valid inputs', () async {
        // This should not throw
        final result = await yogaService.detectYogas(
          date: DateTime(2024, 1, 1),
          latitude: 28.6139,
          longitude: 77.2090,
          timezone: 5.5,
        );
        
        expect(result, isA<List>());
      });
    });

    group('SpecialDaysService Input Validation', () {
      test('should throw ArgumentError for invalid month', () async {
        expect(
          () => specialDaysService.getSpecialDaysForMonth(
            year: 2024,
            month: 13, // Invalid: > 12
            latitude: 28.0,
            longitude: 77.0,
            timezone: 5.5,
          ),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should accept valid month', () async {
        // This should not throw
        final result = await specialDaysService.getSpecialDaysForMonth(
          year: 2024,
          month: 1,
          latitude: 28.6139,
          longitude: 77.2090,
          timezone: 5.5,
        );
        
        expect(result, isA<Map>());
      });
    });

    group('YogaFilterService Null Safety', () {
      test('should return empty list for null input', () {
        final result = filterService.getAuspiciousYogas(null);
        expect(result, isEmpty);
      });

      test('should return empty list for empty input', () {
        final result = filterService.getAuspiciousYogas([]);
        expect(result, isEmpty);
      });

      test('should handle null yogas in filterByPurpose', () {
        final result = filterService.filterByPurpose(null, YogaPurpose.marriage);
        expect(result, isEmpty);
      });

      test('should handle null purposes in filterByPurposes', () {
        final result = filterService.filterByPurposes([], null);
        expect(result, isEmpty);
      });

      test('should return zero counts for null input', () {
        final counts = filterService.getCountByPurpose(null);
        expect(counts[YogaPurpose.marriage], equals(0));
        expect(counts[YogaPurpose.business], equals(0));
      });
    });

    group('Edge Cases', () {
      test('should handle boundary latitude values', () async {
        // Test with -90 (South Pole)
        final result1 = await yogaService.detectYogas(
          date: DateTime(2024, 1, 1),
          latitude: -90.0,
          longitude: 0.0,
          timezone: 0.0,
        );
        expect(result1, isA<List>());

        // Test with +90 (North Pole)
        final result2 = await yogaService.detectYogas(
          date: DateTime(2024, 1, 1),
          latitude: 90.0,
          longitude: 0.0,
          timezone: 0.0,
        );
        expect(result2, isA<List>());
      });

      test('should handle boundary longitude values', () async {
        // Test with -180
        final result1 = await yogaService.detectYogas(
          date: DateTime(2024, 1, 1),
          latitude: 0.0,
          longitude: -180.0,
          timezone: 0.0,
        );
        expect(result1, isA<List>());

        // Test with +180
        final result2 = await yogaService.detectYogas(
          date: DateTime(2024, 1, 1),
          latitude: 0.0,
          longitude: 180.0,
          timezone: 0.0,
        );
        expect(result2, isA<List>());
      });

      test('should handle boundary timezone values', () async {
        // Test with -12
        final result1 = await yogaService.detectYogas(
          date: DateTime(2024, 1, 1),
          latitude: 0.0,
          longitude: 0.0,
          timezone: -12.0,
        );
        expect(result1, isA<List>());

        // Test with +14
        final result2 = await yogaService.detectYogas(
          date: DateTime(2024, 1, 1),
          latitude: 0.0,
          longitude: 0.0,
          timezone: 14.0,
        );
        expect(result2, isA<List>());
      });

      test('should handle boundary dates', () async {
        // Test with year 1900
        final result1 = await yogaService.detectYogas(
          date: DateTime(1900, 1, 1),
          latitude: 28.0,
          longitude: 77.0,
          timezone: 5.5,
        );
        expect(result1, isA<List>());

        // Test with year 2100
        final result2 = await yogaService.detectYogas(
          date: DateTime(2100, 12, 31),
          latitude: 28.0,
          longitude: 77.0,
          timezone: 5.5,
        );
        expect(result2, isA<List>());
      });
    });
  });
}
