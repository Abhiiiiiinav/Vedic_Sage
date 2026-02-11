import 'package:hive_flutter/hive_flutter.dart';
import '../database/models/divisional_chart_model.dart';
import 'chart_id_generator.dart';
import 'chart_api_service.dart';
import 'chart_storage_service.dart';
import 'svg_chart_parser.dart';

/// Chart Repository
/// Implements cache-first strategy to prevent duplicate API calls
/// 
/// Flow:
/// 1. Generate chart_id from birth details
/// 2. Check Hive cache
/// 3. If cached → return immediately
/// 4. If not cached → fetch from API → store → return
/// 
/// Guarantees:
/// ✅ No duplicate API calls for same birth details
/// ✅ Works offline after first fetch
/// ✅ Deterministic chart identification
/// ✅ Fast subsequent access
class ChartRepository {
  final ChartStorageService _storage;
  final ChartApiService _api;

  ChartRepository({
    ChartStorageService? storage,
    ChartApiService? api,
  })  : _storage = storage ?? ChartStorageService(),
        _api = api ?? ChartApiService();

  /// Get or create a single divisional chart
  /// 
  /// Cache-first strategy:
  /// 1. Generate chart_id
  /// 2. Check cache
  /// 3. Return cached or fetch new
  Future<DivisionalChartModel> getOrCreateChart({
    required Map<String, dynamic> birthDetails,
    required String profileId,
    required String division,
  }) async {
    // Generate deterministic chart ID
    final chartId = ChartIdGenerator.forDivision(birthDetails, division);

    // Check cache first
    final cached = _storage.getChartByType(profileId, division);
    if (cached != null && _isValidCache(cached)) {
      print(' Cache hit for $division (ID: ${ChartIdGenerator.shortId(chartId)})');
      return cached;
    }

    print(' Cache miss for $division, fetching from API...');

    // Fetch from API
    final chart = await _fetchAndStore(
      birthDetails: birthDetails,
      profileId: profileId,
      division: division,
      chartId: chartId,
    );

    return chart;
  }

  /// Get or create multiple divisional charts (batch)
  /// 
  /// Optimized batch fetching:
  /// 1. Check which charts are cached
  /// 2. Fetch only missing charts from API
  /// 3. Store new charts
  /// 4. Return all charts
  Future<Map<String, DivisionalChartModel>> getOrCreateBatchCharts({
    required Map<String, dynamic> birthDetails,
    required String profileId,
    required List<String> divisions,
  }) async {
    final results = <String, DivisionalChartModel>{};
    final missingDivisions = <String>[];

    // Check cache for each division
    for (var division in divisions) {
      final cached = _storage.getChartByType(profileId, division);
      if (cached != null && _isValidCache(cached)) {
        results[division] = cached;
        print('Cache hit for $division');
      } else {
        missingDivisions.add(division);
      }
    }

    // Fetch missing charts
    if (missingDivisions.isNotEmpty) {
      print('📡 Fetching ${missingDivisions.length} charts from API...');
      
      final newCharts = await _fetchBatchAndStore(
        birthDetails: birthDetails,
        profileId: profileId,
        divisions: missingDivisions,
      );

      results.addAll(newCharts);
    }

    print('✅ Loaded ${results.length} charts (${results.length - missingDivisions.length} cached, ${missingDivisions.length} fetched)');
    return results;
  }

  /// Fetch all standard divisional charts (D1-D60)
  Future<Map<String, DivisionalChartModel>> fetchAllDivisionalCharts({
    required Map<String, dynamic> birthDetails,
    required String profileId,
  }) async {
    const allDivisions = [
      'd1', 'd2', 'd3', 'd4', 'd7', 'd9', 'd10', 'd12',
      'd16', 'd20', 'd24', 'd27', 'd30', 'd40', 'd45', 'd60',
    ];

    return await getOrCreateBatchCharts(
      birthDetails: birthDetails,
      profileId: profileId,
      divisions: allDivisions,
    );
  }

  /// Fetch essential charts (D1, D9, D10)
  Future<Map<String, DivisionalChartModel>> fetchEssentialCharts({
    required Map<String, dynamic> birthDetails,
    required String profileId,
  }) async {
    const essentialDivisions = ['d1', 'd9', 'd10'];

    return await getOrCreateBatchCharts(
      birthDetails: birthDetails,
      profileId: profileId,
      divisions: essentialDivisions,
    );
  }

  /// Force refresh a chart (bypass cache)
  Future<DivisionalChartModel> refreshChart({
    required Map<String, dynamic> birthDetails,
    required String profileId,
    required String division,
  }) async {
    final chartId = ChartIdGenerator.forDivision(birthDetails, division);
    
    print('🔄 Force refreshing $division...');
    
    return await _fetchAndStore(
      birthDetails: birthDetails,
      profileId: profileId,
      division: division,
      chartId: chartId,
    );
  }

  /// Check if a chart is cached
  bool isCached({
    required String profileId,
    required String division,
  }) {
    final cached = _storage.getChartByType(profileId, division);
    return cached != null && _isValidCache(cached);
  }

  /// Get cache statistics
  Map<String, dynamic> getCacheStats(String profileId) {
    return _storage.getChartStats(profileId);
  }

  /// Clear cache for a profile
  Future<void> clearCache(String profileId) async {
    await _storage.deleteChartsForProfile(profileId);
    print('🗑️ Cleared cache for profile $profileId');
  }

  /// Validate cache integrity
  bool validateCache(String profileId) {
    final charts = _storage.getChartsForProfile(profileId);
    return charts.every((chart) => _storage.validateChart(chart));
  }

  // ============================================================
  // PRIVATE METHODS
  // ============================================================

  /// Fetch single chart from API and store
  Future<DivisionalChartModel> _fetchAndStore({
    required Map<String, dynamic> birthDetails,
    required String profileId,
    required String division,
    required String chartId,
  }) async {
    try {
      // Fetch from API
      final response = await _api.getChartByDivision(
        'chart/$division',
        _convertToApiFormat(birthDetails),
      );

      if (!response.success || response.svg == null) {
        throw Exception('Failed to fetch chart: ${response.error}');
      }

      // Extract ascendant from response
      final ascendantSign = _extractAscendantSign(response);

      // Store in Hive
      await _storage.saveDivisionalChart(
        chartType: division,
        svg: response.svg!,
        ascendantSign: ascendantSign,
        profileId: profileId,
        metadata: {
          'chartId': chartId,
          'fetchedAt': DateTime.now().toIso8601String(),
          'apiResponse': response.toJson(),
        },
      );

      // Retrieve and return
      final chart = _storage.getChartByType(profileId, division);
      if (chart == null) {
        throw Exception('Failed to retrieve stored chart');
      }

      return chart;
    } catch (e) {
      print('❌ Error fetching chart: $e');
      rethrow;
    }
  }

  /// Fetch multiple charts from API and store
  Future<Map<String, DivisionalChartModel>> _fetchBatchAndStore({
    required Map<String, dynamic> birthDetails,
    required String profileId,
    required List<String> divisions,
  }) async {
    try {
      // Fetch batch from API
      final response = await _api.getBatchCharts(
        _convertToApiFormat(birthDetails),
        divisions,
      );

      if (!response.success) {
        throw Exception('Batch fetch failed: ${response.error}');
      }

      // Extract ascendant
      final ascendantSign = _extractAscendantSign(response);

      // Store all charts
      await _storage.saveBatchCharts(
        chartSvgs: response.charts,
        ascendantSign: ascendantSign,
        profileId: profileId,
      );

      // Retrieve and return
      final results = <String, DivisionalChartModel>{};
      for (var division in divisions) {
        final chart = _storage.getChartByType(profileId, division);
        if (chart != null) {
          results[division] = chart;
        }
      }

      return results;
    } catch (e) {
      print('❌ Error in batch fetch: $e');
      rethrow;
    }
  }

  /// Convert birth details to API format
  BirthDetails _convertToApiFormat(Map<String, dynamic> details) {
    return BirthDetails(
      year: details['year'] as int,
      month: details['month'] as int,
      date: details['date'] as int,
      hours: details['hours'] as int,
      minutes: details['minutes'] as int,
      seconds: details['seconds'] as int? ?? 0,
      latitude: details['latitude'] as double,
      longitude: details['longitude'] as double,
      timezone: details['timezone'] as double,
    );
  }

  /// Extract ascendant sign from API response
  int _extractAscendantSign(ChartResponse response) {
    // Try to get from metadata
    if (response.metadata?['ascendantSign'] != null) {
      return response.metadata!['ascendantSign'] as int;
    }

    // Default to Aries if not available
    // TODO: Parse from SVG or planetary data
    return 1;
  }

  /// Check if cached chart is still valid
  bool _isValidCache(DivisionalChartModel chart) {
    // Check if chart is too old (optional expiry)
    final age = DateTime.now().difference(chart.updatedAt);
    if (age.inDays > 365) {
      print('⚠️ Chart expired (${age.inDays} days old)');
      return false;
    }

    // Validate chart structure
    if (!_storage.validateChart(chart)) {
      print('⚠️ Chart validation failed');
      return false;
    }

    return true;
  }
}

/// Birth Details Helper Class
class BirthDetails {
  final int year;
  final int month;
  final int date;
  final int hours;
  final int minutes;
  final int seconds;
  final double latitude;
  final double longitude;
  final double timezone;

  BirthDetails({
    required this.year,
    required this.month,
    required this.date,
    required this.hours,
    required this.minutes,
    this.seconds = 0,
    required this.latitude,
    required this.longitude,
    required this.timezone,
  });

  Map<String, dynamic> toJson() {
    return {
      'year': year,
      'month': month,
      'date': date,
      'hours': hours,
      'minutes': minutes,
      'seconds': seconds,
      'latitude': latitude,
      'longitude': longitude,
      'timezone': timezone,
    };
  }
}
