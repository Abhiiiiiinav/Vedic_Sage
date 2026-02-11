import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Chart ID Generator
/// Creates deterministic, stable IDs for birth charts
/// 
/// Same birth details → Same chart_id → No duplicate API calls
class ChartIdGenerator {
  /// Generate a deterministic chart ID from birth details
  /// 
  /// Uses SHA256 hash of sorted JSON to ensure:
  /// - Same inputs always produce same ID
  /// - Different inputs produce different IDs
  /// - ID is stable across app restarts
  /// 
  /// Example:
  /// ```dart
  /// final id = ChartIdGenerator.generate({
  ///   'year': 1995,
  ///   'month': 1,
  ///   'date': 15,
  ///   'hours': 5,
  ///   'minutes': 30,
  ///   'latitude': 28.6139,
  ///   'longitude': 77.2090,
  ///   'timezone': 5.5,
  /// });
  /// // Returns: "a3f5c8d2e1b4f6a9" (16-char hex)
  /// ```
  static String generate(Map<String, dynamic> birthDetails) {
    // Sort keys to ensure deterministic JSON
    final sortedJson = _sortedJsonEncode(birthDetails);
    
    // Generate SHA256 hash
    final bytes = utf8.encode(sortedJson);
    final hash = sha256.convert(bytes);
    
    // Return first 16 characters (sufficient for uniqueness)
    return hash.toString().substring(0, 16);
  }

  /// Generate chart ID from individual parameters
  static String fromParameters({
    required int year,
    required int month,
    required int date,
    required int hours,
    required int minutes,
    required int seconds,
    required double latitude,
    required double longitude,
    required double timezone,
    String ayanamsha = 'lahiri',
  }) {
    return generate({
      'year': year,
      'month': month,
      'date': date,
      'hours': hours,
      'minutes': minutes,
      'seconds': seconds,
      'latitude': _roundCoordinate(latitude),
      'longitude': _roundCoordinate(longitude),
      'timezone': timezone,
      'ayanamsha': ayanamsha,
    });
  }

  /// Generate chart ID for a specific divisional chart
  /// Includes chart type in the hash
  static String forDivision(
    Map<String, dynamic> birthDetails,
    String division,
  ) {
    final detailsWithDivision = {
      ...birthDetails,
      'division': division,
    };
    return generate(detailsWithDivision);
  }

  /// Validate chart ID format
  static bool isValidChartId(String chartId) {
    // Must be 16-character hexadecimal string
    final hexPattern = RegExp(r'^[a-f0-9]{16}$');
    return hexPattern.hasMatch(chartId);
  }

  /// Extract metadata from chart ID (if stored)
  /// Note: This is just for validation, actual data is in Hive
  static Map<String, dynamic> getMetadata(String chartId) {
    return {
      'chartId': chartId,
      'isValid': isValidChartId(chartId),
      'length': chartId.length,
    };
  }

  /// Compare two sets of birth details
  /// Returns true if they would generate the same chart ID
  static bool areSameBirthDetails(
    Map<String, dynamic> details1,
    Map<String, dynamic> details2,
  ) {
    return generate(details1) == generate(details2);
  }

  /// Round coordinates to 4 decimal places for consistency
  /// Prevents floating-point precision issues
  static double _roundCoordinate(double value) {
    return double.parse(value.toStringAsFixed(4));
  }

  /// Encode JSON with sorted keys for deterministic output
  static String _sortedJsonEncode(Map<String, dynamic> map) {
    final sortedMap = Map.fromEntries(
      map.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
    return jsonEncode(sortedMap);
  }

  /// Generate a short display ID (for UI)
  /// Example: "a3f5...f6a9"
  static String shortId(String chartId) {
    if (chartId.length < 8) return chartId;
    return '${chartId.substring(0, 4)}...${chartId.substring(chartId.length - 4)}';
  }

  /// Generate batch chart IDs for multiple divisions
  static Map<String, String> generateBatchIds(
    Map<String, dynamic> birthDetails,
    List<String> divisions,
  ) {
    return {
      for (var division in divisions)
        division: forDivision(birthDetails, division),
    };
  }
}
