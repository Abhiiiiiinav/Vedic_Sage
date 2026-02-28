import 'package:flutter_test/flutter_test.dart';
import 'package:astro_learn/core/services/yoga_cache_service.dart';
import 'package:astro_learn/core/models/yoga_models.dart';

void main() {
  group('YogaCacheService', () {
    late YogaCacheService cache;

    setUp(() {
      cache = YogaCacheService();
      cache.clear(); // Clear cache before each test
    });

    tearDown(() {
      cache.clear();
    });

    test('should return null for cache miss', () {
      final result = cache.get(
        date: DateTime(2024, 1, 1),
        latitude: 28.6139,
        longitude: 77.2090,
        timezone: 5.5,
      );

      expect(result, isNull);
    });

    test('should store and retrieve cached results', () {
      final date = DateTime(2024, 1, 1);
      final yogas = [
        YogaResult(
          type: YogaType.guruPushya,
          definition: YogaDefinitions.getDefinition(YogaType.guruPushya),
          activeDate: date,
          tithi: 'Pratipada',
          nakshatra: 'Pushya',
          vara: 'Thursday',
        ),
      ];

      // Store in cache
      cache.put(
        date: date,
        latitude: 28.6139,
        longitude: 77.2090,
        timezone: 5.5,
        results: yogas,
      );

      // Retrieve from cache
      final cached = cache.get(
        date: date,
        latitude: 28.6139,
        longitude: 77.2090,
        timezone: 5.5,
      );

      expect(cached, isNotNull);
      expect(cached!.length, equals(1));
      expect(cached[0].type, equals(YogaType.guruPushya));
    });

    test('should normalize dates to midnight for consistent keys', () {
      final date1 = DateTime(2024, 1, 1, 10, 30);
      final date2 = DateTime(2024, 1, 1, 15, 45);
      final yogas = [
        YogaResult(
          type: YogaType.siddha,
          definition: YogaDefinitions.getDefinition(YogaType.siddha),
          activeDate: date1,
          tithi: 'Dwitiya',
          nakshatra: 'Rohini',
          vara: 'Monday',
        ),
      ];

      // Store with first date
      cache.put(
        date: date1,
        latitude: 28.6139,
        longitude: 77.2090,
        timezone: 5.5,
        results: yogas,
      );

      // Retrieve with second date (same day, different time)
      final cached = cache.get(
        date: date2,
        latitude: 28.6139,
        longitude: 77.2090,
        timezone: 5.5,
      );

      expect(cached, isNotNull);
      expect(cached!.length, equals(1));
    });

    test('should differentiate by location', () {
      final date = DateTime(2024, 1, 1);
      final yogas1 = [
        YogaResult(
          type: YogaType.amritSiddhi,
          definition: YogaDefinitions.getDefinition(YogaType.amritSiddhi),
          activeDate: date,
          tithi: 'Pratipada',
          nakshatra: 'Hasta',
          vara: 'Sunday',
        ),
      ];
      final yogas2 = [
        YogaResult(
          type: YogaType.siddha,
          definition: YogaDefinitions.getDefinition(YogaType.siddha),
          activeDate: date,
          tithi: 'Dwitiya',
          nakshatra: 'Rohini',
          vara: 'Monday',
        ),
      ];

      // Store for location 1
      cache.put(
        date: date,
        latitude: 28.6139,
        longitude: 77.2090,
        timezone: 5.5,
        results: yogas1,
      );

      // Store for location 2
      cache.put(
        date: date,
        latitude: 40.7128,
        longitude: -74.0060,
        timezone: -5.0,
        results: yogas2,
      );

      // Retrieve for location 1
      final cached1 = cache.get(
        date: date,
        latitude: 28.6139,
        longitude: 77.2090,
        timezone: 5.5,
      );

      // Retrieve for location 2
      final cached2 = cache.get(
        date: date,
        latitude: 40.7128,
        longitude: -74.0060,
        timezone: -5.0,
      );

      expect(cached1![0].type, equals(YogaType.amritSiddhi));
      expect(cached2![0].type, equals(YogaType.siddha));
    });

    test('should clear all cached entries', () {
      final date = DateTime(2024, 1, 1);
      final yogas = [
        YogaResult(
          type: YogaType.guruPushya,
          definition: YogaDefinitions.getDefinition(YogaType.guruPushya),
          activeDate: date,
          tithi: 'Pratipada',
          nakshatra: 'Pushya',
          vara: 'Thursday',
        ),
      ];

      cache.put(
        date: date,
        latitude: 28.6139,
        longitude: 77.2090,
        timezone: 5.5,
        results: yogas,
      );

      expect(cache.getStats().size, equals(1));

      cache.clear();

      expect(cache.getStats().size, equals(0));
      
      final cached = cache.get(
        date: date,
        latitude: 28.6139,
        longitude: 77.2090,
        timezone: 5.5,
      );
      
      expect(cached, isNull);
    });

    test('should preload batch of results', () {
      final results = {
        DateTime(2024, 1, 1): [
          YogaResult(
            type: YogaType.guruPushya,
            definition: YogaDefinitions.getDefinition(YogaType.guruPushya),
            activeDate: DateTime(2024, 1, 1),
            tithi: 'Pratipada',
            nakshatra: 'Pushya',
            vara: 'Thursday',
          ),
        ],
        DateTime(2024, 1, 2): [
          YogaResult(
            type: YogaType.siddha,
            definition: YogaDefinitions.getDefinition(YogaType.siddha),
            activeDate: DateTime(2024, 1, 2),
            tithi: 'Dwitiya',
            nakshatra: 'Rohini',
            vara: 'Monday',
          ),
        ],
      };

      cache.preloadBatch(
        results: results,
        latitude: 28.6139,
        longitude: 77.2090,
        timezone: 5.5,
      );

      expect(cache.getStats().size, equals(2));

      final cached1 = cache.get(
        date: DateTime(2024, 1, 1),
        latitude: 28.6139,
        longitude: 77.2090,
        timezone: 5.5,
      );

      final cached2 = cache.get(
        date: DateTime(2024, 1, 2),
        latitude: 28.6139,
        longitude: 77.2090,
        timezone: 5.5,
      );

      expect(cached1, isNotNull);
      expect(cached2, isNotNull);
      expect(cached1![0].type, equals(YogaType.guruPushya));
      expect(cached2![0].type, equals(YogaType.siddha));
    });

    test('should provide cache statistics', () {
      final stats = cache.getStats();

      expect(stats.size, equals(0));
      expect(stats.maxSize, equals(100));
      expect(stats.utilizationPercent, equals(0.0));

      // Add some entries
      for (int i = 1; i <= 10; i++) {
        cache.put(
          date: DateTime(2024, 1, i),
          latitude: 28.6139,
          longitude: 77.2090,
          timezone: 5.5,
          results: [],
        );
      }

      final stats2 = cache.getStats();
      expect(stats2.size, equals(10));
      expect(stats2.utilizationPercent, equals(10.0));
    });

    test('should handle empty results', () {
      final date = DateTime(2024, 1, 1);
      final emptyYogas = <YogaResult>[];

      cache.put(
        date: date,
        latitude: 28.6139,
        longitude: 77.2090,
        timezone: 5.5,
        results: emptyYogas,
      );

      final cached = cache.get(
        date: date,
        latitude: 28.6139,
        longitude: 77.2090,
        timezone: 5.5,
      );

      expect(cached, isNotNull);
      expect(cached!.isEmpty, isTrue);
    });
  });
}
