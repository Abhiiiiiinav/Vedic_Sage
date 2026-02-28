import '../models/yoga_models.dart';
import 'yoga_detection_service.dart';
import 'yoga_cache_service.dart';

/// Service for calculating special yoga days for months and years
/// 
/// This service provides batch processing capabilities to efficiently
/// detect yogas across multiple dates for calendar display and planning.
/// Uses caching and parallel processing for optimal performance.
class SpecialDaysService {
  final YogaDetectionService _yogaDetectionService = YogaDetectionService();
  final YogaCacheService _cache = YogaCacheService();
  
  /// Get all special yoga days for a specific month
  /// 
  /// Parameters:
  /// - [year]: The year (e.g., 2024)
  /// - [month]: The month (1-12)
  /// - [latitude]: Geographic latitude
  /// - [longitude]: Geographic longitude
  /// - [timezone]: Timezone offset in hours
  /// 
  /// Returns a map of dates to their detected yogas, suitable for calendar display
  /// 
  /// This method uses batch processing and caching for optimal performance.
  /// 
  /// Throws:
  /// - [ArgumentError] if month is not between 1-12
  /// - [Exception] if yoga detection fails
  Future<Map<DateTime, List<YogaResult>>> getSpecialDaysForMonth({
    required int year,
    required int month,
    required double latitude,
    required double longitude,
    required double timezone,
  }) async {
    // Validate month
    if (month < 1 || month > 12) {
      throw ArgumentError('Month must be between 1 and 12, got: $month');
    }
    
    final Map<DateTime, List<YogaResult>> specialDays = {};
    
    try {
      // Get the number of days in the month
      final daysInMonth = DateTime(year, month + 1, 0).day;
    
    // Create list of dates to process
    final dates = List.generate(
      daysInMonth,
      (index) => DateTime(year, month, index + 1, 12, 0),
    );
    
    // Process dates in parallel batches for better performance
    // Use batch size of 7 (one week) to balance parallelism and memory
    const batchSize = 7;
    
    for (int i = 0; i < dates.length; i += batchSize) {
      final batchEnd = (i + batchSize < dates.length) ? i + batchSize : dates.length;
      final batch = dates.sublist(i, batchEnd);
      
      try {
        // Process batch in parallel
        final results = await Future.wait(
          batch.map((date) => _yogaDetectionService.detectYogas(
            date: date,
            latitude: latitude,
            longitude: longitude,
            timezone: timezone,
            useCache: true, // Use cache for efficiency
          )),
        );
        
        // Store results
        for (int j = 0; j < batch.length; j++) {
          final date = batch[j];
          final yogas = results[j];
          
          // Only include dates that have yogas
          if (yogas.isNotEmpty) {
            // Normalize the date to midnight for consistent map keys
            final normalizedDate = DateTime(date.year, date.month, date.day);
            specialDays[normalizedDate] = yogas;
          }
        }
      } catch (e) {
        // Log batch error but continue with other batches
        print('Error processing batch ${i ~/ batchSize + 1}: $e');
        // Continue processing remaining batches
      }
    }
    
    return specialDays;
    } catch (e) {
      throw Exception('Failed to get special days for month: ${e.toString()}');
    }
  }
  
  /// Get all special yoga days for an entire year
  /// 
  /// Parameters:
  /// - [year]: The year (e.g., 2024)
  /// - [latitude]: Geographic latitude
  /// - [longitude]: Geographic longitude
  /// - [timezone]: Timezone offset in hours
  /// 
  /// Returns a map of dates to their detected yogas for the entire year
  /// 
  /// This method processes months in parallel for optimal performance.
  /// 
  /// Throws:
  /// - [Exception] if yoga detection fails for the year
  Future<Map<DateTime, List<YogaResult>>> getSpecialDaysForYear({
    required int year,
    required double latitude,
    required double longitude,
    required double timezone,
  }) async {
    try {
      // Process all months in parallel for better performance
      final monthlyResults = await Future.wait(
        List.generate(12, (index) => index + 1).map((month) =>
          getSpecialDaysForMonth(
            year: year,
            month: month,
            latitude: latitude,
            longitude: longitude,
            timezone: timezone,
          ).catchError((e) {
            // Log error but return empty map for failed months
            print('Error processing month $month: $e');
            return <DateTime, List<YogaResult>>{};
          }),
        ),
      );
      
      // Merge all monthly results into a single map
      final Map<DateTime, List<YogaResult>> specialDays = {};
      for (final monthlyDays in monthlyResults) {
        specialDays.addAll(monthlyDays);
      }
      
      return specialDays;
    } catch (e) {
      throw Exception('Failed to get special days for year: ${e.toString()}');
    }
  }
  
  /// Get only auspicious special days for a month
  /// 
  /// Filters the monthly results to include only dates with auspicious yogas
  Future<Map<DateTime, List<YogaResult>>> getAuspiciousDaysForMonth({
    required int year,
    required int month,
    required double latitude,
    required double longitude,
    required double timezone,
  }) async {
    final allDays = await getSpecialDaysForMonth(
      year: year,
      month: month,
      latitude: latitude,
      longitude: longitude,
      timezone: timezone,
    );
    
    return _filterAuspiciousDays(allDays);
  }
  
  /// Get only auspicious special days for a year
  /// 
  /// Filters the annual results to include only dates with auspicious yogas
  Future<Map<DateTime, List<YogaResult>>> getAuspiciousDaysForYear({
    required int year,
    required double latitude,
    required double longitude,
    required double timezone,
  }) async {
    final allDays = await getSpecialDaysForYear(
      year: year,
      latitude: latitude,
      longitude: longitude,
      timezone: timezone,
    );
    
    return _filterAuspiciousDays(allDays);
  }
  
  /// Get only inauspicious days for a month
  /// 
  /// Filters the monthly results to include only dates with inauspicious yogas
  Future<Map<DateTime, List<YogaResult>>> getInauspiciousDaysForMonth({
    required int year,
    required int month,
    required double latitude,
    required double longitude,
    required double timezone,
  }) async {
    final allDays = await getSpecialDaysForMonth(
      year: year,
      month: month,
      latitude: latitude,
      longitude: longitude,
      timezone: timezone,
    );
    
    return _filterInauspiciousDays(allDays);
  }
  
  /// Get only inauspicious days for a year
  /// 
  /// Filters the annual results to include only dates with inauspicious yogas
  Future<Map<DateTime, List<YogaResult>>> getInauspiciousDaysForYear({
    required int year,
    required double latitude,
    required double longitude,
    required double timezone,
  }) async {
    final allDays = await getSpecialDaysForYear(
      year: year,
      latitude: latitude,
      longitude: longitude,
      timezone: timezone,
    );
    
    return _filterInauspiciousDays(allDays);
  }
  
  /// Filter map to include only dates with auspicious yogas
  Map<DateTime, List<YogaResult>> _filterAuspiciousDays(
    Map<DateTime, List<YogaResult>> days,
  ) {
    final filtered = <DateTime, List<YogaResult>>{};
    
    for (final entry in days.entries) {
      final auspiciousYogas = entry.value
          .where((yoga) => yoga.isAuspicious)
          .toList();
      
      if (auspiciousYogas.isNotEmpty) {
        filtered[entry.key] = auspiciousYogas;
      }
    }
    
    return filtered;
  }
  
  /// Filter map to include only dates with inauspicious yogas
  Map<DateTime, List<YogaResult>> _filterInauspiciousDays(
    Map<DateTime, List<YogaResult>> days,
  ) {
    final filtered = <DateTime, List<YogaResult>>{};
    
    for (final entry in days.entries) {
      final inauspiciousYogas = entry.value
          .where((yoga) => !yoga.isAuspicious)
          .toList();
      
      if (inauspiciousYogas.isNotEmpty) {
        filtered[entry.key] = inauspiciousYogas;
      }
    }
    
    return filtered;
  }
  
  /// Get count of special days by yoga type for a month
  /// 
  /// Useful for statistics and summary displays
  Future<Map<YogaType, int>> getMonthlyYogaStatistics({
    required int year,
    required int month,
    required double latitude,
    required double longitude,
    required double timezone,
  }) async {
    final specialDays = await getSpecialDaysForMonth(
      year: year,
      month: month,
      latitude: latitude,
      longitude: longitude,
      timezone: timezone,
    );
    
    return _calculateYogaStatistics(specialDays);
  }
  
  /// Get count of special days by yoga type for a year
  /// 
  /// Useful for statistics and summary displays
  Future<Map<YogaType, int>> getYearlyYogaStatistics({
    required int year,
    required double latitude,
    required double longitude,
    required double timezone,
  }) async {
    final specialDays = await getSpecialDaysForYear(
      year: year,
      latitude: latitude,
      longitude: longitude,
      timezone: timezone,
    );
    
    return _calculateYogaStatistics(specialDays);
  }
  
  /// Calculate statistics from a map of special days
  Map<YogaType, int> _calculateYogaStatistics(
    Map<DateTime, List<YogaResult>> specialDays,
  ) {
    final statistics = <YogaType, int>{};
    
    for (final yogas in specialDays.values) {
      for (final yoga in yogas) {
        statistics[yoga.type] = (statistics[yoga.type] ?? 0) + 1;
      }
    }
    
    return statistics;
  }
}
