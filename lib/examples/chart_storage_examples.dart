/// Example: How to Use the Production-Grade Chart Storage System
///
/// This demonstrates the CORRECT architecture:
/// Birth Data → API/Engine → SVG + Planets → Parser → Hive Storage → Display
///
/// Key Principles:
/// ✅ SVG is for display only
/// ✅ Houses are calculated from Ascendant + Signs
/// ✅ All data is stored in Hive for offline access
/// ✅ Works for all divisional charts (D1-D60)

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../core/services/chart_api_service.dart';
import '../core/services/chart_storage_service.dart';
import '../core/services/svg_chart_parser.dart';
import '../core/database/models/divisional_chart_model.dart';

/// Example 1: Fetch and Store a Single Chart
Future<void> exampleFetchAndStoreChart() async {
  // Step 1: Prepare birth details
  final birthDetails = BirthDetails(
    year: 1995,
    month: 1,
    date: 15,
    hours: 5,
    minutes: 30,
    seconds: 0,
    latitude: 28.6139,
    longitude: 77.2090,
    timezone: 5.5,
  );

  // Step 2: Fetch D1 chart from API
  final apiService = ChartApiService();
  final response = await apiService.getChartByDivision(
    birthDetails,
    1, // D1 = division 1
  );

  if (!response.success || response.svg == null) {
    print('❌ Failed to fetch chart');
    return;
  }

  // Step 3: Extract ascendant from API response
  // (In real app, this comes from planetary data)
  final ascendantSign = 1; // Aries (from API planetary data)

  // Step 4: Save to Hive
  final storageService = ChartStorageService();
  final chartKey = await storageService.saveDivisionalChart(
    chartType: 'd1',
    svg: response.svg!,
    ascendantSign: ascendantSign,
    profileId: 'user_123',
  );

  print('✅ Chart saved with key: $chartKey');
}

/// Example 2: Fetch and Store Multiple Charts (Batch)
Future<void> exampleBatchChartStorage() async {
  final birthDetails = BirthDetails(
    year: 1995,
    month: 1,
    date: 15,
    hours: 5,
    minutes: 30,
    seconds: 0,
    latitude: 28.6139,
    longitude: 77.2090,
    timezone: 5.5,
  );

  // Fetch multiple charts
  final apiService = ChartApiService();
  final batchResponse = await apiService.getMultipleCharts(
    birthDetails,
    charts: [
      'd1',
      'd3',
      'd9',
      'd10',
      'd20',
      'd24',
      'd27',
      'd30',
      'd40',
      'd45',
      'd50',
      'd60'
    ],
  );

  if (!batchResponse.success) {
    print('❌ Batch fetch failed');
    return;
  }

  // Convert ChartData map to SVG string map for storage
  final chartSvgs = <String, String>{};
  batchResponse.charts?.forEach((key, chartData) {
    chartSvgs[key] = chartData.svg;
  });

  // Save all charts
  final storageService = ChartStorageService();
  final keys = await storageService.saveBatchCharts(
    chartSvgs: chartSvgs,
    ascendantSign: 1, // From API planetary data
    profileId: 'user_123',
  );

  print('✅ Saved ${keys.length} charts');
}

/// Example 3: Load and Display a Chart
Widget exampleDisplayChart(String profileId) {
  final storageService = ChartStorageService();

  // Get D1 chart for profile
  final chart = storageService.getChartByType(profileId, 'd1');

  if (chart == null) {
    return const Text('No chart found');
  }

  return Column(
    children: [
      // Display chart name
      Text(
        chart.displayName,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),

      // Display ascendant
      Text('Ascendant: ${chart.ascendantSignName}'),

      // Display SVG
      SvgPicture.string(chart.svg),

      // Display house information
      ...List.generate(12, (index) {
        final houseNum = index + 1;
        final planets = chart.getPlanetsInHouse(houseNum);

        return ListTile(
          title: Text('House $houseNum'),
          subtitle: Text(
            planets.isEmpty
                ? 'Empty'
                : planets.map(SvgChartParser.getPlanetName).join(', '),
          ),
        );
      }),
    ],
  );
}

/// Example 4: Query Chart Data
void exampleQueryChartData(DivisionalChartModel chart) {
  // Get all planets
  final allPlanets = chart.getAllPlanets();
  print('Planets in chart: $allPlanets');

  // Find Sun's house
  final sunHouse = chart.getHouseForPlanet('Su');
  print('Sun is in House $sunHouse');

  // Check if Jupiter is in 5th house
  final jupiterIn5th = chart.isPlanetInHouse('Ju', 5);
  print('Jupiter in 5th house: $jupiterIn5th');

  // Get empty houses
  final emptyHouses = chart.getEmptyHouses();
  print('Empty houses: $emptyHouses');

  // Get occupied houses
  final occupiedHouses = chart.getOccupiedHouses();
  print('Occupied houses: $occupiedHouses');
}

/// Example 5: Manual SVG Parsing (Advanced)
void exampleManualParsing() {
  final svg = '''
    <svg width="400" height="400">
      <text x="150" y="50">Su</text>
      <text x="250" y="50">Mo</text>
      <text x="50" y="150">Ma</text>
    </svg>
  ''';

  final ascendantSign = 1; // Aries

  // Parse SVG to get house-planet mapping
  final housePlanets = SvgChartParser.extractHousePlanetsFromSvg(
    svg,
    ascendantSign,
  );

  print('House-Planet Mapping:');
  housePlanets.forEach((house, planets) {
    if (planets.isNotEmpty) {
      print('House $house: ${planets.join(", ")}');
    }
  });
}

/// Example 6: Complete Workflow (Birth Details → Storage → Display)
class ChartWorkflowExample extends StatefulWidget {
  const ChartWorkflowExample({Key? key}) : super(key: key);

  @override
  State<ChartWorkflowExample> createState() => _ChartWorkflowExampleState();
}

class _ChartWorkflowExampleState extends State<ChartWorkflowExample> {
  DivisionalChartModel? _chart;
  bool _loading = false;

  Future<void> _generateAndStoreChart() async {
    setState(() => _loading = true);

    try {
      // 1. Fetch from API
      final apiService = ChartApiService();
      final birthDetails = BirthDetails(
        year: 1995,
        month: 1,
        date: 15,
        hours: 5,
        minutes: 30,
        seconds: 0,
        latitude: 28.6139,
        longitude: 77.2090,
        timezone: 5.5,
      );

      final response = await apiService.getChartByDivision(
        birthDetails,
        1, // D1 = division 1
      );

      if (!response.success || response.svg == null) {
        throw Exception('Failed to fetch chart');
      }

      // 2. Store in Hive
      final storageService = ChartStorageService();
      final chartKey = await storageService.saveDivisionalChart(
        chartType: 'd1',
        svg: response.svg!,
        ascendantSign: 1, // From API
        profileId: 'current_user',
      );

      // 3. Load from Hive
      final chart = storageService.getChartByKey(chartKey);

      setState(() {
        _chart = chart;
        _loading = false;
      });
    } catch (e) {
      print('Error: $e');
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const CircularProgressIndicator();
    }

    if (_chart == null) {
      return ElevatedButton(
        onPressed: _generateAndStoreChart,
        child: const Text('Generate Chart'),
      );
    }

    return Column(
      children: [
        Text(_chart!.displayName),
        Text('Ascendant: ${_chart!.ascendantSignName}'),
        SvgPicture.string(_chart!.svg),

        // House list
        Expanded(
          child: ListView.builder(
            itemCount: 12,
            itemBuilder: (context, index) {
              final houseNum = index + 1;
              final planets = _chart!.getPlanetsInHouse(houseNum);

              return ListTile(
                title: Text('House $houseNum'),
                subtitle: Text(
                  planets.isEmpty
                      ? 'Empty'
                      : planets.map(SvgChartParser.getPlanetName).join(', '),
                ),
                onTap: () {
                  // Navigate to house detail screen
                  print('Tapped House $houseNum');
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Example 7: Export/Import Charts
Future<void> exampleExportImport() async {
  final storageService = ChartStorageService();

  // Export chart to JSON
  final chartKey = '0'; // First chart
  final json = storageService.exportChartToJson(chartKey);

  // Save to file or send to server
  print('Exported: ${json['chartName']}');

  // Import chart from JSON
  final importedKey = await storageService.importChartFromJson(json);
  print('Imported with key: $importedKey');
}

/// Key Takeaways:
///
/// ✅ Always fetch from API for accurate data
/// ✅ Parse SVG to extract planet positions
/// ✅ Store complete data in Hive (not just SVG)
/// ✅ Use ascendant to calculate houses dynamically
/// ✅ SVG is for display only, not calculation
/// ✅ Works offline after initial fetch
/// ✅ Supports all divisional charts (D1-D60)
