import '../models/birth_details.dart';
import '../database/hive_database_service.dart';
import '../database/models/hive_models.dart';

/// Singleton service to store user data across the session
/// Now persists data to Hive local storage
class UserSession {
  static final UserSession _instance = UserSession._internal();
  factory UserSession() => _instance;
  UserSession._internal();

  final HiveDatabaseService _db = HiveDatabaseService();
  
  BirthDetails? _birthDetails;
  Map<String, dynamic>? _birthChart;
  UserProfileModel? _currentProfile;

  /// Get stored birth details
  BirthDetails? get birthDetails => _birthDetails;

  /// Get stored birth chart
  Map<String, dynamic>? get birthChart => _birthChart;
  
  /// Get current profile
  UserProfileModel? get currentProfile => _currentProfile;

  /// Initialize session - load from database
  Future<void> initialize() async {
    await _loadFromDatabase();
    print('📱 UserSession initialized');
  }
  
  /// Load primary profile from database
  Future<void> _loadFromDatabase() async {
    try {
      // Get primary profile
      final profile = _db.getPrimaryProfile();
      if (profile != null && profile.birthDateTime != null) {
        _currentProfile = profile;
        _birthDetails = BirthDetails(
          name: profile.name,
          birthDateTime: profile.birthDateTime!,
          latitude: profile.latitude ?? 28.6139, // Default Delhi
          longitude: profile.longitude ?? 77.2090,
          cityName: profile.birthPlace ?? 'Unknown',
          timezoneOffset: profile.timezoneOffset ?? 5.5,
        );
        
        // Load saved chart for this profile if available
        final charts = _db.getChartsForProfile(profile.id);
        if (charts.isNotEmpty) {
          final latestChart = charts.last;
          _birthChart = _convertSavedChartToMap(latestChart);
        }
        
        print('✅ Loaded profile: ${profile.name}');
      }
    } catch (e) {
      print('⚠️ Error loading from database: $e');
    }
  }
  
  /// Convert SavedChartModel to the Map format used by the app
  Map<String, dynamic> _convertSavedChartToMap(SavedChartModel chart) {
    // Build houses list from planet placements
    List<List<String>> houses = List.generate(12, (_) => <String>[]);
    Map<String, dynamic> planetPositions = {};
    Map<String, double> planetDegrees = {};
    Map<String, int> planetSigns = {};
    Map<String, int> planetHouses = {};
    
    for (var planet in chart.planetPlacements) {
      // Add to house
      if (planet.house >= 1 && planet.house <= 12) {
        houses[planet.house - 1].add(_getAbbreviation(planet.planetId));
      }
      
      planetPositions[planet.planetId] = {
        'longitude': planet.degrees,
        'sign': planet.sign,
        'signIndex': _getSignIndex(planet.sign),
        'house': planet.house,
        'degreeInSign': planet.degrees % 30,
      };
      planetDegrees[planet.planetId] = planet.degrees;
      planetSigns[planet.planetId] = _getSignIndex(planet.sign) + 1;
      planetHouses[planet.planetId] = planet.house;
    }
    
    return {
      'houses': houses,
      'planetPositions': planetPositions,
      'planetDegrees': planetDegrees,
      'planetSigns': planetSigns,
      'planetHouses': planetHouses,
      'ascendant': chart.ascendantDegrees ?? 0.0,
      'ascDegree': chart.ascendantDegrees ?? 0.0,
      'ascSign': chart.ascendantSign,
      'ascSignIndex': _getSignIndex(chart.ascendantSign ?? 'Aries'),
      'savedChartId': chart.id,
      'rawApiResponse': chart.rawApiResponse,
    };
  }
  
  String _getAbbreviation(String name) {
    const abbrevMap = {
      'Sun': 'Su', 'Moon': 'Mo', 'Mars': 'Ma', 'Mercury': 'Me',
      'Jupiter': 'Ju', 'Venus': 'Ve', 'Saturn': 'Sa', 'Rahu': 'Ra', 'Ketu': 'Ke',
    };
    return abbrevMap[name] ?? name.substring(0, 2);
  }
  
  int _getSignIndex(String sign) {
    const signs = ['Aries', 'Taurus', 'Gemini', 'Cancer', 'Leo', 'Virgo',
                   'Libra', 'Scorpio', 'Sagittarius', 'Capricorn', 'Aquarius', 'Pisces'];
    return signs.indexOf(sign).clamp(0, 11);
  }

  /// Save birth details and chart - also persists to database
  Future<void> saveSession({
    required BirthDetails details,
    required Map<String, dynamic> chart,
  }) async {
    _birthDetails = details;
    _birthChart = chart;
    
    // Save to database
    await _saveToDatabase(details, chart);
    
    print('💾 User session saved for: ${details.name}');
  }
  
  /// Save to Hive database
  Future<void> _saveToDatabase(BirthDetails details, Map<String, dynamic> chart) async {
    try {
      // Check if profile exists
      final profiles = _db.getAllProfiles();
      var profile = profiles.cast<UserProfileModel?>().firstWhere(
        (p) => p?.name.toLowerCase() == details.name.toLowerCase(),
        orElse: () => null,
      );
      
      if (profile == null) {
        // Create new profile
        profile = await _db.createProfile(
          name: details.name,
          birthDateTime: details.birthDateTime,
          birthPlace: details.cityName,
          latitude: details.latitude,
          longitude: details.longitude,
          timezoneOffset: details.timezoneOffset,
          isPrimary: true,
        );
      } else {
        // Update existing profile
        await _db.updateProfile(profile.copyWith(
          birthDateTime: details.birthDateTime,
          birthPlace: details.cityName,
          latitude: details.latitude,
          longitude: details.longitude,
          timezoneOffset: details.timezoneOffset,
        ));
        await _db.setPrimaryProfile(profile.id);
      }
      
      _currentProfile = profile;
      
      // Save chart data
      final planetPlacements = _extractPlanetPlacements(chart);
      
      await _db.saveChart(
        profileId: profile.id,
        name: '${details.name} - D1 Rasi',
        birthDateTime: details.birthDateTime,
        birthPlace: details.cityName,
        latitude: details.latitude,
        longitude: details.longitude,
        timezoneOffset: details.timezoneOffset,
        ascendantSign: chart['ascSign'] as String?,
        ascendantDegrees: (chart['ascDegree'] as num?)?.toDouble(),
        planetPlacements: planetPlacements,
        rawApiResponse: chart['apiPlanets'] as Map<String, dynamic>?,
      );
      
      print('📦 Saved to Hive database');
    } catch (e) {
      print('⚠️ Error saving to database: $e');
    }
  }
  
  /// Extract planet placements from chart data
  List<PlanetPlacementModel> _extractPlanetPlacements(Map<String, dynamic> chart) {
    final placements = <PlanetPlacementModel>[];
    final positions = chart['planetPositions'] as Map<String, dynamic>?;
    
    if (positions != null) {
      positions.forEach((name, data) {
        if (data is Map<String, dynamic>) {
          placements.add(PlanetPlacementModel(
            planetId: name,
            sign: data['sign'] as String? ?? 'Aries',
            house: data['house'] as int? ?? 1,
            degrees: (data['longitude'] as num?)?.toDouble() ?? 0.0,
            isRetrograde: data['isRetrograde'] as bool? ?? false,
            nakshatra: data['nakshatra'] as String?,
            nakshatraPada: data['pada'] as int?,
          ));
        }
      });
    }
    
    return placements;
  }

  /// Clear session
  void clear() {
    _birthDetails = null;
    _birthChart = null;
    _currentProfile = null;
  }

  /// Check if user has entered birth details
  bool get hasData => _birthDetails != null && _birthChart != null;
  
  /// Reload from database
  Future<void> reload() async {
    await _loadFromDatabase();
  }
}
