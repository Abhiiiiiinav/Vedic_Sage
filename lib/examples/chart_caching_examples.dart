/// Complete Example: Chart ID-Based Caching System
/// 
/// This demonstrates the PRODUCTION-GRADE architecture:
/// 1. Generate chart_id from birth details
/// 2. Check Hive cache first
/// 3. Fetch from API only if needed
/// 4. Store in ProfileStore for app-wide access
/// 5. Use across all features (predictions, dasha, learning)

import 'package:flutter/material.dart';
import '../core/repositories/chart_repository.dart';
import '../core/stores/profile_store.dart';
import '../core/services/chart_id_generator.dart';
import '../core/database/hive_database_service.dart';

// ============================================================
// EXAMPLE 1: Initial Profile Setup
// ============================================================

Future<void> exampleInitialSetup() async {
  final repo = ChartRepository();
  final db = HiveDatabaseService();

  // Birth details
  final birthDetails = {
    'year': 1995,
    'month': 1,
    'date': 15,
    'hours': 5,
    'minutes': 30,
    'seconds': 0,
    'latitude': 28.6139,
    'longitude': 77.2090,
    'timezone': 5.5,
  };

  // Create or get profile
  var profile = db.getPrimaryProfile();
  if (profile == null) {
    profile = await db.createProfile(
      name: 'Abhinav',
      birthDateTime: DateTime(1995, 1, 15, 5, 30),
      birthPlace: 'New Delhi',
      latitude: 28.6139,
      longitude: 77.2090,
      timezoneOffset: 5.5,
      isPrimary: true,
    );
  }

  // Fetch essential charts (D1, D9, D10)
  // This will check cache first, fetch only if needed
  final charts = await repo.fetchEssentialCharts(
    birthDetails: birthDetails,
    profileId: profile.id,
  );

  // Load into ProfileStore for app-wide access
  ProfileStore().loadProfile(profile, charts);

  print('✅ Profile setup complete!');
  print('📊 Charts loaded: ${charts.keys.join(", ")}');
}

// ============================================================
// EXAMPLE 2: Fetch All Divisional Charts
// ============================================================

Future<void> exampleFetchAllCharts() async {
  final repo = ChartRepository();
  final profile = ProfileStore().profile;

  if (profile == null) {
    print('❌ No profile loaded');
    return;
  }

  final birthDetails = {
    'year': profile.birthDateTime!.year,
    'month': profile.birthDateTime!.month,
    'date': profile.birthDateTime!.day,
    'hours': profile.birthDateTime!.hour,
    'minutes': profile.birthDateTime!.minute,
    'seconds': profile.birthDateTime!.second,
    'latitude': profile.latitude!,
    'longitude': profile.longitude!,
    'timezone': profile.timezoneOffset!,
  };

  // Fetch all divisional charts (D1-D60)
  // Cache-first: Only fetches charts not already in Hive
  final charts = await repo.fetchAllDivisionalCharts(
    birthDetails: birthDetails,
    profileId: profile.id,
  );

  // Update ProfileStore
  ProfileStore().loadProfile(profile, charts);

  print('✅ All charts loaded: ${charts.length} charts');
}

// ============================================================
// EXAMPLE 3: Using ProfileStore Across App
// ============================================================

class PredictionScreen extends StatelessWidget {
  const PredictionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final store = ProfileStore();

    if (!store.isLoaded) {
      return const Center(child: Text('No profile loaded'));
    }

    // Access chart data anywhere in the app
    final ascendant = store.ascendant;
    final sunHouse = store.getPlanetHouse('Su');
    final moonHouse = store.getPlanetHouse('Mo');
    final planetsIn10th = store.getPlanetsInHouse(10);

    return Column(
      children: [
        Text('User: ${store.userName}'),
        Text('Ascendant: $ascendant'),
        Text('Sun in House: $sunHouse'),
        Text('Moon in House: $moonHouse'),
        Text('10th House Planets: ${planetsIn10th.join(", ")}'),
        
        // Vargottama analysis
        Text('Vargottama Planets: ${store.getVargottamaPlanets().join(", ")}'),
      ],
    );
  }
}

// ============================================================
// EXAMPLE 4: Dasha Calculation Using ProfileStore
// ============================================================

class DashaCalculator {
  static Map<String, dynamic> calculateDasha() {
    final store = ProfileStore();

    if (!store.isLoaded) {
      throw Exception('Profile not loaded');
    }

    // Access birth details
    final birthDate = store.birthDateTime!;
    
    // Access D1 chart for Dasha calculation
    final d1 = store.d1Chart;
    final moonHouse = store.getPlanetHouse('Mo');

    // Your Dasha calculation logic here
    return {
      'birthDate': birthDate,
      'moonHouse': moonHouse,
      'currentDasha': 'Venus', // Example
    };
  }
}

// ============================================================
// EXAMPLE 5: Learning Module Using ProfileStore
// ============================================================

class LearningModule {
  static String getPersonalizedLesson() {
    final store = ProfileStore();

    if (!store.isLoaded) {
      return 'Please load your profile first';
    }

    final ascendant = store.ascendant;
    final sunHouse = store.getPlanetHouse('Su');

    return '''
    Personalized Lesson for ${store.userName}
    
    Your Ascendant: $ascendant
    Your Sun is in House $sunHouse
    
    This means...
    [Personalized content based on chart]
    ''';
  }
}

// ============================================================
// EXAMPLE 6: Check Cache Before API Call
// ============================================================

Future<void> exampleCacheCheck() async {
  final repo = ChartRepository();
  final profileId = ProfileStore().profile?.id ?? 'user_123';

  // Check if D9 is cached
  final isCached = repo.isCached(
    profileId: profileId,
    division: 'd9',
  );

  if (isCached) {
    print('✅ D9 chart is cached, no API call needed');
  } else {
    print('📡 D9 chart not cached, will fetch from API');
  }

  // Get cache statistics
  final stats = repo.getCacheStats(profileId);
  print('📊 Cache stats: $stats');
}

// ============================================================
// EXAMPLE 7: Complete App Initialization Flow
// ============================================================

class AppInitializer {
  static Future<void> initialize() async {
    print('🚀 Initializing AstroLearn...');

    // 1. Initialize Hive
    await HiveDatabaseService().initialize();
    print('✅ Hive initialized');

    // 2. Load primary profile
    final db = HiveDatabaseService();
    final profile = db.getPrimaryProfile();

    if (profile == null) {
      print('⚠️ No profile found, user needs to create one');
      return;
    }

    // 3. Load charts from cache
    final repo = ChartRepository();
    final birthDetails = {
      'year': profile.birthDateTime!.year,
      'month': profile.birthDateTime!.month,
      'date': profile.birthDateTime!.day,
      'hours': profile.birthDateTime!.hour,
      'minutes': profile.birthDateTime!.minute,
      'seconds': profile.birthDateTime!.second,
      'latitude': profile.latitude!,
      'longitude': profile.longitude!,
      'timezone': profile.timezoneOffset!,
    };

    // Fetch essential charts (cache-first)
    final charts = await repo.fetchEssentialCharts(
      birthDetails: birthDetails,
      profileId: profile.id,
    );

    // 4. Load into ProfileStore
    ProfileStore().loadProfile(profile, charts);

    print('✅ App initialized successfully');
    print('📱 User: ${profile.name}');
    print('📊 Charts: ${charts.keys.join(", ")}');
  }
}

// ============================================================
// EXAMPLE 8: Chart ID Usage
// ============================================================

void exampleChartId() {
  final birthDetails = {
    'year': 1995,
    'month': 1,
    'date': 15,
    'hours': 5,
    'minutes': 30,
    'seconds': 0,
    'latitude': 28.6139,
    'longitude': 77.2090,
    'timezone': 5.5,
  };

  // Generate chart ID
  final chartId = ChartIdGenerator.generate(birthDetails);
  print('Chart ID: $chartId');
  print('Short ID: ${ChartIdGenerator.shortId(chartId)}');

  // Generate IDs for multiple divisions
  final batchIds = ChartIdGenerator.generateBatchIds(
    birthDetails,
    ['d1', 'd9', 'd10'],
  );
  print('Batch IDs: $batchIds');

  // Validate chart ID
  final isValid = ChartIdGenerator.isValidChartId(chartId);
  print('Valid: $isValid');
}

// ============================================================
// EXAMPLE 9: Complete Widget with Cache-First Loading
// ============================================================

class ChartLoaderWidget extends StatefulWidget {
  const ChartLoaderWidget({Key? key}) : super(key: key);

  @override
  State<ChartLoaderWidget> createState() => _ChartLoaderWidgetState();
}

class _ChartLoaderWidgetState extends State<ChartLoaderWidget> {
  bool _loading = false;
  String _status = 'Ready';

  Future<void> _loadCharts() async {
    setState(() {
      _loading = true;
      _status = 'Loading profile...';
    });

    try {
      final db = HiveDatabaseService();
      final profile = db.getPrimaryProfile();

      if (profile == null) {
        setState(() {
          _status = 'No profile found';
          _loading = false;
        });
        return;
      }

      setState(() => _status = 'Checking cache...');

      final repo = ChartRepository();
      final birthDetails = {
        'year': profile.birthDateTime!.year,
        'month': profile.birthDateTime!.month,
        'date': profile.birthDateTime!.day,
        'hours': profile.birthDateTime!.hour,
        'minutes': profile.birthDateTime!.minute,
        'seconds': profile.birthDateTime!.second,
        'latitude': profile.latitude!,
        'longitude': profile.longitude!,
        'timezone': profile.timezoneOffset!,
      };

      // Check cache
      final isCached = repo.isCached(
        profileId: profile.id,
        division: 'd1',
      );

      if (isCached) {
        setState(() => _status = 'Loading from cache...');
      } else {
        setState(() => _status = 'Fetching from API...');
      }

      // Fetch charts (cache-first)
      final charts = await repo.fetchEssentialCharts(
        birthDetails: birthDetails,
        profileId: profile.id,
      );

      // Load into store
      ProfileStore().loadProfile(profile, charts);

      setState(() {
        _status = 'Loaded ${charts.length} charts';
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _status = 'Error: $e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(_status),
        if (_loading) const CircularProgressIndicator(),
        if (!_loading)
          ElevatedButton(
            onPressed: _loadCharts,
            child: const Text('Load Charts'),
          ),
        if (ProfileStore().isLoaded) ...[
          const Divider(),
          Text('User: ${ProfileStore().userName}'),
          Text('Ascendant: ${ProfileStore().ascendant}'),
          Text('Charts: ${ProfileStore().availableCharts.join(", ")}'),
        ],
      ],
    );
  }
}

// ============================================================
// KEY TAKEAWAYS
// ============================================================

/// ✅ Chart ID ensures no duplicate API calls
/// ✅ Cache-first strategy saves bandwidth
/// ✅ ProfileStore provides app-wide access
/// ✅ Works offline after initial fetch
/// ✅ Supports all divisional charts (D1-D60)
/// ✅ Used by predictions, dasha, learning, etc.
/// ✅ Deterministic and stable
