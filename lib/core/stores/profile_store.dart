import '../database/models/divisional_chart_model.dart';
import '../database/models/hive_models.dart';

/// Profile Store (Singleton)
/// Provides app-wide access to current user's chart data
/// 
/// Usage across app:
/// ```dart
/// // Load profile
/// ProfileStore().loadProfile(profile, charts);
/// 
/// // Access anywhere
/// final asc = ProfileStore().ascendant;
/// final sunHouse = ProfileStore().getPlanetHouse('Su');
/// final d9Chart = ProfileStore().getChart('d9');
/// ```
/// 
/// Used by:
/// - Predictions
/// - Dasha calculations
/// - Learning modules
/// - Nakshatra lessons
/// - Remedies
/// - Yogas
class ProfileStore {
  // Singleton instance
  static final ProfileStore _instance = ProfileStore._internal();
  factory ProfileStore() => _instance;
  ProfileStore._internal();

  // Current profile data
  UserProfileModel? _profile;
  Map<String, DivisionalChartModel>? _charts;
  DivisionalChartModel? _activeChart;

  // ============================================================
  // PROFILE MANAGEMENT
  // ============================================================

  /// Load profile and charts into store
  void loadProfile(
    UserProfileModel profile,
    Map<String, DivisionalChartModel> charts,
  ) {
    _profile = profile;
    _charts = charts;
    _activeChart = charts['d1']; // Default to D1
    print('📱 Profile loaded: ${profile.name}');
    print('📊 Charts loaded: ${charts.keys.join(", ")}');
  }

  /// Clear profile data
  void clear() {
    _profile = null;
    _charts = null;
    _activeChart = null;
    print('🗑️ Profile store cleared');
  }

  /// Check if profile is loaded
  bool get isLoaded => _profile != null && _charts != null;

  /// Get current profile
  UserProfileModel? get profile => _profile;

  /// Get all charts
  Map<String, DivisionalChartModel>? get charts => _charts;

  /// Get active chart (default: D1)
  DivisionalChartModel? get activeChart => _activeChart;

  /// Set active chart
  void setActiveChart(String chartType) {
    if (_charts != null && _charts!.containsKey(chartType)) {
      _activeChart = _charts![chartType];
      print('📊 Active chart set to: $chartType');
    }
  }

  // ============================================================
  // CHART DATA ACCESS
  // ============================================================

  /// Get a specific chart
  DivisionalChartModel? getChart(String chartType) {
    return _charts?[chartType];
  }

  /// Get D1 (Rasi) chart
  DivisionalChartModel? get d1Chart => _charts?['d1'];

  /// Get D9 (Navamsa) chart
  DivisionalChartModel? get d9Chart => _charts?['d9'];

  /// Get D10 (Dasamsa) chart
  DivisionalChartModel? get d10Chart => _charts?['d10'];

  /// Get ascendant sign name
  String? get ascendant => _activeChart?.ascendantSignName;

  /// Get ascendant sign number (1-12)
  int? get ascendantSign => _activeChart?.ascendantSign;

  /// Get all available chart types
  List<String> get availableCharts => _charts?.keys.toList() ?? [];

  // ============================================================
  // PLANET QUERIES
  // ============================================================

  /// Get house number for a planet in active chart
  int? getPlanetHouse(String planetAbbrev) {
    return _activeChart?.getHouseForPlanet(planetAbbrev);
  }

  /// Get planets in a specific house in active chart
  List<String> getPlanetsInHouse(int houseNumber) {
    return _activeChart?.getPlanetsInHouse(houseNumber) ?? [];
  }

  /// Check if planet is in a specific house
  bool isPlanetInHouse(String planetAbbrev, int houseNumber) {
    return _activeChart?.isPlanetInHouse(planetAbbrev, houseNumber) ?? false;
  }

  /// Get all planets in active chart
  List<String> get allPlanets => _activeChart?.getAllPlanets() ?? [];

  /// Get empty houses in active chart
  List<int> get emptyHouses => _activeChart?.getEmptyHouses() ?? [];

  /// Get occupied houses in active chart
  List<int> get occupiedHouses => _activeChart?.getOccupiedHouses() ?? [];

  // ============================================================
  // CROSS-CHART QUERIES
  // ============================================================

  /// Get planet house in a specific chart
  int? getPlanetHouseInChart(String chartType, String planetAbbrev) {
    return _charts?[chartType]?.getHouseForPlanet(planetAbbrev);
  }

  /// Compare planet positions across charts
  Map<String, int?> getPlanetAcrossCharts(String planetAbbrev) {
    if (_charts == null) return {};
    
    return {
      for (var entry in _charts!.entries)
        entry.key: entry.value.getHouseForPlanet(planetAbbrev),
    };
  }

  /// Get Vargottama planets (same sign in D1 and divisional charts)
  /// 
  /// Vargottama = Planet in same zodiac sign in D1 and divisional chart
  /// This is a powerful placement indicating strength
  /// 
  /// Returns map of chart types to Vargottama planets in that chart
  Map<String, List<String>> getVargottamaPlanetsAcrossCharts() {
    final d1 = _charts?['d1'];
    if (d1 == null || _charts == null) return {};

    final vargottamaMap = <String, List<String>>{};

    // Check each divisional chart against D1
    for (var entry in _charts!.entries) {
      final chartType = entry.key;
      if (chartType == 'd1') continue; // Skip D1 itself

      final divChart = entry.value;
      final vargottamaPlanets = <String>[];

      // Check each planet
      for (var planet in d1.getAllPlanets()) {
        final d1Sign = d1.getSignForPlanet(planet);
        final divSign = divChart.getSignForPlanet(planet);

        // Vargottama = same sign in both charts
        if (d1Sign != null && divSign != null && d1Sign == divSign) {
          vargottamaPlanets.add(planet);
        }
      }

      if (vargottamaPlanets.isNotEmpty) {
        vargottamaMap[chartType] = vargottamaPlanets;
      }
    }

    return vargottamaMap;
  }

  /// Get Vargottama planets in D9 (most common usage)
  /// Returns list of planets that are in same sign in D1 and D9
  List<String> getVargottamaPlanets() {
    final d1 = _charts?['d1'];
    final d9 = _charts?['d9'];
    
    if (d1 == null || d9 == null) return [];

    final vargottama = <String>[];
    for (var planet in d1.getAllPlanets()) {
      final d1Sign = d1.getSignForPlanet(planet);
      final d9Sign = d9.getSignForPlanet(planet);
      
      // Vargottama = same SIGN (not house)
      if (d1Sign != null && d9Sign != null && d1Sign == d9Sign) {
        vargottama.add(planet);
      }
    }

    return vargottama;
  }

  /// Get detailed Vargottama analysis for a specific planet
  /// Shows which charts the planet is Vargottama in
  Map<String, dynamic> getVargottamaAnalysis(String planetAbbrev) {
    final d1 = _charts?['d1'];
    if (d1 == null || _charts == null) return {};

    final d1Sign = d1.getSignForPlanet(planetAbbrev);
    final d1SignName = d1.getSignNameForPlanet(planetAbbrev);
    
    if (d1Sign == null) return {};

    final vargottamaIn = <String>[];
    final signComparison = <String, Map<String, dynamic>>{};

    for (var entry in _charts!.entries) {
      final chartType = entry.key;
      if (chartType == 'd1') continue;

      final divChart = entry.value;
      final divSign = divChart.getSignForPlanet(planetAbbrev);
      final divSignName = divChart.getSignNameForPlanet(planetAbbrev);

      signComparison[chartType] = {
        'sign': divSign,
        'signName': divSignName,
        'isVargottama': divSign == d1Sign,
      };

      if (divSign == d1Sign) {
        vargottamaIn.add(chartType);
      }
    }

    return {
      'planet': planetAbbrev,
      'd1Sign': d1Sign,
      'd1SignName': d1SignName,
      'vargottamaIn': vargottamaIn,
      'vargottamaCount': vargottamaIn.length,
      'signComparison': signComparison,
    };
  }

  // ============================================================
  // CONVENIENCE GETTERS
  // ============================================================

  /// Get user's name
  String? get userName => _profile?.name;

  /// Get birth date and time
  DateTime? get birthDateTime => _profile?.birthDateTime;

  /// Get birth place
  String? get birthPlace => _profile?.birthPlace;

  /// Get coordinates
  double? get latitude => _profile?.latitude;
  double? get longitude => _profile?.longitude;

  /// Get timezone offset
  double? get timezoneOffset => _profile?.timezoneOffset;

  // ============================================================
  // CHART STATISTICS
  // ============================================================

  /// Get chart summary
  Map<String, dynamic> getChartSummary() {
    if (!isLoaded) return {};

    return {
      'userName': userName,
      'ascendant': ascendant,
      'birthPlace': birthPlace,
      'chartsLoaded': availableCharts.length,
      'chartTypes': availableCharts,
      'totalPlanets': allPlanets.length,
      'emptyHouses': emptyHouses.length,
      'occupiedHouses': occupiedHouses.length,
      'vargottamaPlanets': getVargottamaPlanets(),
    };
  }

  /// Export profile data
  Map<String, dynamic> exportData() {
    if (!isLoaded) return {};

    return {
      'profile': _profile!.toJson(),
      'charts': _charts!.map((k, v) => MapEntry(k, v.toJson())),
      'exportedAt': DateTime.now().toIso8601String(),
    };
  }

  // ============================================================
  // VALIDATION
  // ============================================================

  /// Validate profile data integrity
  bool validate() {
    if (!isLoaded) return false;
    if (_profile == null) return false;
    if (_charts == null || _charts!.isEmpty) return false;
    if (!_charts!.containsKey('d1')) return false; // D1 is mandatory
    
    return true;
  }

  /// Get validation errors
  List<String> getValidationErrors() {
    final errors = <String>[];

    if (_profile == null) {
      errors.add('Profile not loaded');
    }

    if (_charts == null || _charts!.isEmpty) {
      errors.add('No charts loaded');
    }

    if (_charts != null && !_charts!.containsKey('d1')) {
      errors.add('D1 chart missing');
    }

    return errors;
  }

  @override
  String toString() {
    if (!isLoaded) return 'ProfileStore(empty)';
    
    return 'ProfileStore('
        'user: $userName, '
        'asc: $ascendant, '
        'charts: ${availableCharts.length}'
        ')';
  }
}
