/// Vargottama Analysis Examples
///
/// Vargottama = Planet in same ZODIAC SIGN in D1 and divisional chart
/// This is a powerful placement indicating strength and consistency
///
/// IMPORTANT: Vargottama is based on SIGNS, not houses!
/// Example:
/// - Sun in Aries (sign 1) in D1
/// - Sun in Aries (sign 1) in D9
/// → Sun is Vargottama ✅
///
/// Even if houses are different:
/// - Sun in House 1 (Aries) in D1
/// - Sun in House 5 (Aries) in D9
/// → Still Vargottama because SIGN is same ✅

import 'package:flutter/material.dart';
import '../core/stores/profile_store.dart';
import '../core/repositories/chart_repository.dart';

// ============================================================
// EXAMPLE 1: Get Vargottama Planets in D9
// ============================================================

void exampleVargottamaD9() {
  final store = ProfileStore();

  // Get Vargottama planets (D1 vs D9)
  final vargottama = store.getVargottamaPlanets();

  print('Vargottama Planets (D1 = D9):');
  for (var planet in vargottama) {
    final d1 = store.d1Chart;
    final d9 = store.d9Chart;

    final d1Sign = d1?.getSignNameForPlanet(planet);
    final d9Sign = d9?.getSignNameForPlanet(planet);

    print('  $planet: $d1Sign (D1) = $d9Sign (D9) ✅');
  }
}

// ============================================================
// EXAMPLE 2: Get Vargottama Across ALL Charts
// ============================================================

void exampleVargottamaAllCharts() {
  final store = ProfileStore();

  // Get Vargottama across all divisional charts
  final vargottamaMap = store.getVargottamaPlanetsAcrossCharts();

  print('Vargottama Analysis Across All Charts:');
  print('=====================================');

  vargottamaMap.forEach((chartType, planets) {
    print('\n$chartType:');
    for (var planet in planets) {
      final d1Sign = store.d1Chart?.getSignNameForPlanet(planet);
      final divSign = store.getChart(chartType)?.getSignNameForPlanet(planet);
      print('  $planet: $d1Sign (D1) = $divSign ($chartType) ✅');
    }
  });
}

// ============================================================
// EXAMPLE 3: Detailed Analysis for Specific Planet
// ============================================================

void examplePlanetVargottamaAnalysis(String planet) {
  final store = ProfileStore();

  final analysis = store.getVargottamaAnalysis(planet);

  print('Vargottama Analysis for $planet:');
  print('================================');
  print('D1 Sign: ${analysis['d1SignName']}');
  print('Vargottama in ${analysis['vargottamaCount']} charts');
  print('Charts: ${(analysis['vargottamaIn'] as List).join(", ")}');

  print('\nDetailed Comparison:');
  final comparison =
      analysis['signComparison'] as Map<String, Map<String, dynamic>>;
  comparison.forEach((chartType, data) {
    final isVargottama = data['isVargottama'] as bool;
    final signName = data['signName'];
    final status = isVargottama ? '✅ Vargottama' : '❌ Not Vargottama';
    print('  $chartType: $signName $status');
  });
}

// ============================================================
// EXAMPLE 4: UI Widget Showing Vargottama
// ============================================================

class VargottamaAnalysisWidget extends StatelessWidget {
  const VargottamaAnalysisWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final store = ProfileStore();

    if (!store.isLoaded) {
      return const Center(child: Text('No profile loaded'));
    }

    final vargottamaMap = store.getVargottamaPlanetsAcrossCharts();

    return ListView(
      children: [
        // Header
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Vargottama Analysis',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),

        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Vargottama = Planet in same zodiac sign in D1 and divisional chart',
            style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
          ),
        ),

        const Divider(height: 32),

        // D9 Vargottama (most important)
        _buildChartSection('D9 (Navamsa)', vargottamaMap['d9'] ?? []),

        // Other charts
        ...vargottamaMap.entries
            .where((e) => e.key != 'd9')
            .map((e) => _buildChartSection(e.key.toUpperCase(), e.value)),
      ],
    );
  }

  Widget _buildChartSection(String chartName, List<String> planets) {
    if (planets.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              chartName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...planets.map((planet) => _buildPlanetRow(planet, chartName)),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanetRow(String planet, String chartName) {
    final store = ProfileStore();
    final d1Sign = store.d1Chart?.getSignNameForPlanet(planet);
    final chartType = chartName.toLowerCase().split(' ')[0];
    final divSign = store.getChart(chartType)?.getSignNameForPlanet(planet);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 20),
          const SizedBox(width: 8),
          Text(
            '$planet: $d1Sign (D1) = $divSign ($chartType)',
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// EXAMPLE 5: Find Strongest Planets (Most Vargottama)
// ============================================================

Map<String, int> findStrongestPlanets() {
  final store = ProfileStore();
  final d1 = store.d1Chart;

  if (d1 == null || store.charts == null) return {};

  final planetStrength = <String, int>{};

  // Count Vargottama occurrences for each planet
  for (var planet in d1.getAllPlanets()) {
    int count = 0;

    for (var entry in store.charts!.entries) {
      if (entry.key == 'd1') continue;

      final d1Sign = d1.getSignForPlanet(planet);
      final divSign = entry.value.getSignForPlanet(planet);

      if (d1Sign != null && divSign != null && d1Sign == divSign) {
        count++;
      }
    }

    planetStrength[planet] = count;
  }

  // Sort by strength
  final sorted = Map.fromEntries(
    planetStrength.entries.toList()..sort((a, b) => b.value.compareTo(a.value)),
  );

  return sorted;
}

void printStrongestPlanets() {
  final strength = findStrongestPlanets();

  print('Planet Strength (Vargottama Count):');
  print('===================================');

  strength.forEach((planet, count) {
    final stars = '⭐' * count;
    print('$planet: $count charts $stars');
  });
}

// ============================================================
// EXAMPLE 6: Complete Vargottama Report
// ============================================================

class VargottamaReport {
  static Map<String, dynamic> generate() {
    final store = ProfileStore();
    final vargottamaMap = store.getVargottamaPlanetsAcrossCharts();
    final strength = findStrongestPlanets();

    // Find planets with maximum Vargottama
    final maxStrength = strength.values.isEmpty
        ? 0
        : strength.values.reduce((a, b) => a > b ? a : b);
    final strongestPlanets = strength.entries
        .where((e) => e.value == maxStrength)
        .map((e) => e.key)
        .toList();

    return {
      'totalCharts': store.availableCharts.length,
      'vargottamaByChart': vargottamaMap,
      'planetStrength': strength,
      'strongestPlanets': strongestPlanets,
      'maxVargottamaCount': maxStrength,
      'summary': _generateSummary(vargottamaMap, strongestPlanets, maxStrength),
    };
  }

  static String _generateSummary(
    Map<String, List<String>> vargottamaMap,
    List<String> strongestPlanets,
    int maxStrength,
  ) {
    final totalVargottama =
        vargottamaMap.values.expand((planets) => planets).toSet().length;

    return '''
Vargottama Analysis Summary
===========================

Total Unique Vargottama Planets: $totalVargottama
Strongest Planets: ${strongestPlanets.join(", ")}
Maximum Vargottama Count: $maxStrength charts

Interpretation:
${strongestPlanets.map((p) => '- $p is Vargottama in $maxStrength charts, indicating exceptional strength').join('\n')}

Charts with Vargottama:
${vargottamaMap.entries.map((e) => '- ${e.key}: ${e.value.join(", ")}').join('\n')}
''';
  }
}

// ============================================================
// EXAMPLE 7: Usage in App
// ============================================================

Future<void> exampleCompleteFlow() async {
  // 1. Load charts
  final repo = ChartRepository();
  final _ = await repo.fetchEssentialCharts(
    birthDetails: {
      'year': 1995,
      'month': 1,
      'date': 15,
      'hours': 5,
      'minutes': 30,
      'seconds': 0,
      'latitude': 28.6139,
      'longitude': 77.2090,
      'timezone': 5.5,
    },
    profileId: 'user_123',
  );

  // 2. Load into store
  // TODO: Replace with your actual UserProfileModel instance
  // ProfileStore().loadProfile(yourProfileModel, charts);

  // 3. Analyze Vargottama
  print('\n=== D9 Vargottama ===');
  exampleVargottamaD9();

  print('\n=== All Charts Vargottama ===');
  exampleVargottamaAllCharts();

  print('\n=== Sun Analysis ===');
  examplePlanetVargottamaAnalysis('Su');

  print('\n=== Strongest Planets ===');
  printStrongestPlanets();

  print('\n=== Complete Report ===');
  final report = VargottamaReport.generate();
  print(report['summary']);
}

// ============================================================
// KEY TAKEAWAYS
// ============================================================

/// ✅ Vargottama is based on SIGNS, not houses
/// ✅ Works across ALL divisional charts (D1-D60)
/// ✅ Indicates planet strength and consistency
/// ✅ Most important: D9 Vargottama
/// ✅ Can analyze individual planets or all planets
/// ✅ Provides detailed comparison across charts
