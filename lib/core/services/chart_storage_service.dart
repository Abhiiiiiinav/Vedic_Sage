import 'package:hive_flutter/hive_flutter.dart';
import '../database/models/divisional_chart_model.dart';
import 'svg_chart_parser.dart';

/// Chart Storage Service
/// Handles saving and loading divisional charts to/from Hive
/// 
/// Architecture:
/// Birth Data → API/Engine → SVG + Planet Data → Parser → Hive Storage
class ChartStorageService {
  static const String _boxName = 'divisional_charts';
  
  /// Get the charts box
  Box<DivisionalChartModel> get _chartsBox =>
      Hive.box<DivisionalChartModel>(_boxName);

  /// Save a divisional chart to Hive
  /// 
  /// This is the CORRECT way to store charts:
  /// 1. Parse SVG to extract planet positions
  /// 2. Map planets to houses using ascendant
  /// 3. Store complete data model (not just SVG)
  Future<String> saveDivisionalChart({
    required String chartType,
    required String svg,
    required int ascendantSign,
    required String profileId,
    Map<String, double>? planetDegrees,
    Map<String, dynamic>? metadata,
  }) async {
    // Validate SVG
    if (!SvgChartParser.isValidSvgChart(svg)) {
      throw Exception('Invalid SVG chart format');
    }

    // Extract house-to-planets mapping from SVG
    final housePlanets = SvgChartParser.extractHousePlanetsFromSvg(
      svg,
      ascendantSign,
    );

    // Get chart name
    final chartName = _getChartName(chartType);

    // Create model
    final chart = DivisionalChartModel(
      chartType: chartType,
      ascendantSign: ascendantSign,
      housePlanets: housePlanets,
      svg: svg,
      profileId: profileId,
      chartName: chartName,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      planetDegrees: planetDegrees,
      metadata: metadata,
    );

    // Save to Hive
    await _chartsBox.add(chart);

    print('📦 Saved $chartName for profile $profileId');
    return chart.key.toString();
  }

  /// Save multiple charts at once (batch operation)
  Future<List<String>> saveBatchCharts({
    required Map<String, String> chartSvgs, // chartType → svg
    required int ascendantSign,
    required String profileId,
    Map<String, double>? planetDegrees,
  }) async {
    final keys = <String>[];

    for (var entry in chartSvgs.entries) {
      final key = await saveDivisionalChart(
        chartType: entry.key,
        svg: entry.value,
        ascendantSign: ascendantSign,
        profileId: profileId,
        planetDegrees: planetDegrees,
      );
      keys.add(key);
    }

    print('📦 Saved ${keys.length} charts in batch');
    return keys;
  }

  /// Get all charts for a profile
  List<DivisionalChartModel> getChartsForProfile(String profileId) {
    return _chartsBox.values
        .where((chart) => chart.profileId == profileId)
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  /// Get a specific chart by type for a profile
  DivisionalChartModel? getChartByType(String profileId, String chartType) {
    try {
      return _chartsBox.values.firstWhere(
        (chart) =>
            chart.profileId == profileId && chart.chartType == chartType,
      );
    } catch (e) {
      return null;
    }
  }

  /// Get chart by key
  DivisionalChartModel? getChartByKey(String key) {
    try {
      final index = int.parse(key);
      return _chartsBox.getAt(index);
    } catch (e) {
      return null;
    }
  }

  /// Update an existing chart
  Future<void> updateChart(
    String key,
    DivisionalChartModel updatedChart,
  ) async {
    try {
      final index = int.parse(key);
      await _chartsBox.putAt(index, updatedChart.copyWith(
        updatedAt: DateTime.now(),
      ));
      print('✏️ Updated chart: ${updatedChart.chartName}');
    } catch (e) {
      throw Exception('Failed to update chart: $e');
    }
  }

  /// Delete a chart
  Future<void> deleteChart(String key) async {
    try {
      final index = int.parse(key);
      await _chartsBox.deleteAt(index);
      print('🗑️ Deleted chart at index $index');
    } catch (e) {
      throw Exception('Failed to delete chart: $e');
    }
  }

  /// Delete all charts for a profile
  Future<void> deleteChartsForProfile(String profileId) async {
    final charts = getChartsForProfile(profileId);
    for (var chart in charts) {
      await _chartsBox.delete(chart.key);
    }
    print('🗑️ Deleted ${charts.length} charts for profile $profileId');
  }

  /// Get chart statistics
  Map<String, dynamic> getChartStats(String profileId) {
    final charts = getChartsForProfile(profileId);
    
    return {
      'totalCharts': charts.length,
      'chartTypes': charts.map((c) => c.chartType).toSet().toList(),
      'lastUpdated': charts.isNotEmpty
          ? charts.first.updatedAt.toIso8601String()
          : null,
      'ascendantSign': charts.isNotEmpty
          ? charts.first.ascendantSignName
          : null,
    };
  }

  /// Clear all charts (for testing)
  Future<void> clearAllCharts() async {
    await _chartsBox.clear();
    print('🗑️ Cleared all charts');
  }

  /// Get chart name from type
  String _getChartName(String chartType) {
    const chartNames = {
      'd1': 'Rasi Chart (Birth Chart)',
      'd2': 'Hora Chart',
      'd3': 'Drekkana Chart',
      'd4': 'Chaturthamsa Chart',
      'd7': 'Saptamsa Chart',
      'd9': 'Navamsa Chart',
      'd10': 'Dasamsa Chart',
      'd12': 'Dwadasamsa Chart',
      'd16': 'Shodasamsa Chart',
      'd20': 'Vimsamsa Chart',
      'd24': 'Siddhamsa Chart',
      'd27': 'Nakshatramsa Chart',
      'd30': 'Trimsamsa Chart',
      'd40': 'Khavedamsa Chart',
      'd45': 'Akshavedamsa Chart',
      'd60': 'Shashtyamsa Chart',
    };
    return chartNames[chartType] ?? chartType.toUpperCase();
  }

  /// Validate chart data integrity
  bool validateChart(DivisionalChartModel chart) {
    // Check ascendant sign range
    if (chart.ascendantSign < 1 || chart.ascendantSign > 12) {
      return false;
    }

    // Check house count
    if (chart.housePlanets.length != 12) {
      return false;
    }

    // Check SVG validity
    if (!SvgChartParser.isValidSvgChart(chart.svg)) {
      return false;
    }

    return true;
  }

  /// Export chart to JSON
  Map<String, dynamic> exportChartToJson(String key) {
    final chart = getChartByKey(key);
    if (chart == null) {
      throw Exception('Chart not found');
    }
    return chart.toJson();
  }

  /// Import chart from JSON
  Future<String> importChartFromJson(Map<String, dynamic> json) async {
    final chart = DivisionalChartModel.fromJson(json);
    await _chartsBox.add(chart);
    return chart.key.toString();
  }
}
