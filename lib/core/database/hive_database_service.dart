import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:crypto/crypto.dart';
import 'hive_boxes.dart';
import 'models/hive_models.dart';
import 'models/hive_adapters.dart';
import 'models/divisional_chart_model.dart';
import 'models/divisional_chart_adapter.dart';

/// Main database service for Hive operations
/// Provides a clean API for CRUD operations on all data types
class HiveDatabaseService {
  static final HiveDatabaseService _instance = HiveDatabaseService._internal();
  factory HiveDatabaseService() => _instance;
  HiveDatabaseService._internal();

  bool _isInitialized = false;

  /// Initialize Hive and register all adapters
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Initialize Hive for Flutter
    await Hive.initFlutter();

    // Register all adapters
    _registerAdapters();

    // Open all boxes
    await _openBoxes();

    _isInitialized = true;
    print('Hive Database initialized successfully');
  }

  /// Register all Hive type adapters
  void _registerAdapters() {
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(UserProfileModelAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(SavedChartModelAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(ChartCacheModelAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(PlanetPlacementModelAdapter());
    }
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(AppSettingsModelAdapter());
    }
    if (!Hive.isAdapterRegistered(5)) {
      Hive.registerAdapter(AnalysisHistoryModelAdapter());
    }
    if (!Hive.isAdapterRegistered(6)) {
      Hive.registerAdapter(QuizProgressModelAdapter());
    }
    if (!Hive.isAdapterRegistered(10)) {
      Hive.registerAdapter(DivisionalChartModelAdapter());
    }
  }

  /// Open all required boxes
  Future<void> _openBoxes() async {
    await Hive.openBox<UserProfileModel>(HiveBoxes.userProfile);
    await Hive.openBox<SavedChartModel>(HiveBoxes.savedCharts);
    await Hive.openBox<ChartCacheModel>(HiveBoxes.chartCache);
    await Hive.openBox<AppSettingsModel>(HiveBoxes.appSettings);
    await Hive.openBox<AnalysisHistoryModel>(HiveBoxes.analysisHistory);
    await Hive.openBox<QuizProgressModel>(HiveBoxes.quizProgress);
    await Hive.openBox<DivisionalChartModel>('divisional_charts');
  }

  // ============================================================
  // USER PROFILE OPERATIONS
  // ============================================================

  /// Get user profiles box
  Box<UserProfileModel> get _profilesBox =>
      Hive.box<UserProfileModel>(HiveBoxes.userProfile);

  /// Create a new user profile
  Future<UserProfileModel> createProfile({
    required String name,
    DateTime? birthDateTime,
    String? birthPlace,
    double? latitude,
    double? longitude,
    double? timezoneOffset,
    bool isPrimary = false,
  }) async {
    final id = _generateUniqueId();
    final now = DateTime.now();

    // If this is set as primary, unset other primary profiles
    if (isPrimary) {
      await _clearPrimaryProfiles();
    }

    final profile = UserProfileModel(
      id: id,
      name: name,
      birthDateTime: birthDateTime,
      birthPlace: birthPlace,
      latitude: latitude,
      longitude: longitude,
      timezoneOffset: timezoneOffset,
      createdAt: now,
      updatedAt: now,
      isPrimary: isPrimary,
    );

    await _profilesBox.put(id, profile);
    print('Created profile: $name (ID: $id)');
    return profile;
  }

  /// Get all user profiles
  List<UserProfileModel> getAllProfiles() {
    return _profilesBox.values.toList();
  }

  /// Get a specific profile by ID
  UserProfileModel? getProfile(String id) {
    return _profilesBox.get(id);
  }

  /// Get the primary profile
  UserProfileModel? getPrimaryProfile() {
    try {
      return _profilesBox.values.firstWhere((p) => p.isPrimary);
    } catch (e) {
      // No primary profile found, return the first one if available
      return _profilesBox.values.isNotEmpty ? _profilesBox.values.first : null;
    }
  }

  /// Update a user profile
  Future<void> updateProfile(UserProfileModel profile) async {
    final updated = profile.copyWith(updatedAt: DateTime.now());
    await _profilesBox.put(profile.id, updated);
    print(' Updated profile: ${profile.name}');
  }

  /// Set a profile as primary
  Future<void> setPrimaryProfile(String id) async {
    await _clearPrimaryProfiles();
    final profile = _profilesBox.get(id);
    if (profile != null) {
      await _profilesBox.put(id, profile.copyWith(isPrimary: true));
      print('Set primary profile: ${profile.name}');
    }
  }

  /// Clear primary status from all profiles
  Future<void> _clearPrimaryProfiles() async {
    for (final profile in _profilesBox.values.where((p) => p.isPrimary)) {
      await _profilesBox.put(profile.id, profile.copyWith(isPrimary: false));
    }
  }

  /// Delete a user profile
  Future<void> deleteProfile(String id) async {
    await _profilesBox.delete(id);
    // Also delete associated charts
    await deleteChartsForProfile(id);
    print('Deleted profile: $id');
  }

  // ============================================================
  // SAVED CHARTS OPERATIONS
  // ============================================================

  /// Get saved charts box
  Box<SavedChartModel> get _chartsBox =>
      Hive.box<SavedChartModel>(HiveBoxes.savedCharts);

  /// Save a new chart
  Future<SavedChartModel> saveChart({
    required String profileId,
    required String name,
    required DateTime birthDateTime,
    required String birthPlace,
    required double latitude,
    required double longitude,
    required double timezoneOffset,
    String? ascendantSign,
    double? ascendantDegrees,
    List<PlanetPlacementModel>? planetPlacements,
    String? chartSvg,
    Map<String, dynamic>? rawApiResponse,
  }) async {
    final id = _generateUniqueId();
    final now = DateTime.now();

    final chart = SavedChartModel(
      id: id,
      profileId: profileId,
      name: name,
      birthDateTime: birthDateTime,
      birthPlace: birthPlace,
      latitude: latitude,
      longitude: longitude,
      timezoneOffset: timezoneOffset,
      ascendantSign: ascendantSign,
      ascendantDegrees: ascendantDegrees,
      planetPlacements: planetPlacements ?? [],
      chartSvg: chartSvg,
      createdAt: now,
      updatedAt: now,
      rawApiResponse: rawApiResponse,
    );

    await _chartsBox.put(id, chart);
    print('Saved chart: $name');
    return chart;
  }

  /// Get all saved charts
  List<SavedChartModel> getAllCharts() {
    return _chartsBox.values.toList();
  }

  /// Get charts for a specific profile
  List<SavedChartModel> getChartsForProfile(String profileId) {
    return _chartsBox.values.where((c) => c.profileId == profileId).toList();
  }

  /// Get a specific chart by ID
  SavedChartModel? getChart(String id) {
    return _chartsBox.get(id);
  }

  /// Update a saved chart
  Future<void> updateChart(SavedChartModel chart) async {
    chart.updatedAt = DateTime.now();
    await _chartsBox.put(chart.id, chart);
    print('Updated chart: ${chart.name}');
  }

  /// Delete a chart
  Future<void> deleteChart(String id) async {
    await _chartsBox.delete(id);
    print(' Deleted chart: $id');
  }

  /// Delete all charts for a profile
  Future<void> deleteChartsForProfile(String profileId) async {
    final chartsToDelete = _chartsBox.values
        .where((c) => c.profileId == profileId)
        .map((c) => c.id)
        .toList();
    
    for (final id in chartsToDelete) {
      await _chartsBox.delete(id);
    }
    print('Deleted ${chartsToDelete.length} charts for profile: $profileId');
  }

  // ============================================================
  // CHART CACHE OPERATIONS
  // ============================================================

  /// Get chart cache box
  Box<ChartCacheModel> get _cacheBox =>
      Hive.box<ChartCacheModel>(HiveBoxes.chartCache);

  /// Generate cache key from birth details
  String _generateCacheKey({
    required int year,
    required int month,
    required int date,
    required int hours,
    required int minutes,
    required double latitude,
    required double longitude,
    required double timezone,
    String? ayanamsha,
    String? cacheType,
  }) {
    final key = '${cacheType ?? "data"}-$year-$month-$date-$hours-$minutes-$latitude-$longitude-$timezone-${ayanamsha ?? "lahiri"}';
    return md5.convert(utf8.encode(key)).toString();
  }

  /// Cache chart data
  Future<void> cacheChartData({
    required int year,
    required int month,
    required int date,
    required int hours,
    required int minutes,
    required double latitude,
    required double longitude,
    required double timezone,
    required Map<String, dynamic> data,
    String? ayanamsha,
    Duration? expiryDuration,
  }) async {
    final cacheKey = _generateCacheKey(
      year: year,
      month: month,
      date: date,
      hours: hours,
      minutes: minutes,
      latitude: latitude,
      longitude: longitude,
      timezone: timezone,
      ayanamsha: ayanamsha,
      cacheType: 'chart_data',
    );

    final cache = ChartCacheModel(
      cacheKey: cacheKey,
      jsonData: jsonEncode(data),
      cachedAt: DateTime.now(),
      expiresAt: expiryDuration != null
          ? DateTime.now().add(expiryDuration)
          : null, // No expiry for birth charts
      cacheType: 'chart_data',
    );

    await _cacheBox.put(cacheKey, cache);
    print('Cached chart data: $cacheKey');
  }

  /// Get cached chart data
  Map<String, dynamic>? getCachedChartData({
    required int year,
    required int month,
    required int date,
    required int hours,
    required int minutes,
    required double latitude,
    required double longitude,
    required double timezone,
    String? ayanamsha,
  }) {
    final cacheKey = _generateCacheKey(
      year: year,
      month: month,
      date: date,
      hours: hours,
      minutes: minutes,
      latitude: latitude,
      longitude: longitude,
      timezone: timezone,
      ayanamsha: ayanamsha,
      cacheType: 'chart_data',
    );

    final cache = _cacheBox.get(cacheKey);
    if (cache == null || cache.isExpired) {
      return null;
    }

    print('Cache hit: $cacheKey');
    return jsonDecode(cache.jsonData) as Map<String, dynamic>;
  }

  /// Cache SVG charts
  Future<void> cacheSvgCharts({
    required int year,
    required int month,
    required int date,
    required int hours,
    required int minutes,
    required double latitude,
    required double longitude,
    required double timezone,
    required Map<String, String> svgCharts,
  }) async {
    final cacheKey = _generateCacheKey(
      year: year,
      month: month,
      date: date,
      hours: hours,
      minutes: minutes,
      latitude: latitude,
      longitude: longitude,
      timezone: timezone,
      cacheType: 'chart_svg',
    );

    final cache = ChartCacheModel(
      cacheKey: cacheKey,
      jsonData: jsonEncode(svgCharts),
      cachedAt: DateTime.now(),
      expiresAt: null, // SVG charts never expire
      cacheType: 'chart_svg',
    );

    await _cacheBox.put(cacheKey, cache);
    print('Cached ${svgCharts.length} SVG charts');
  }

  /// Get cached SVG charts
  Map<String, String>? getCachedSvgCharts({
    required int year,
    required int month,
    required int date,
    required int hours,
    required int minutes,
    required double latitude,
    required double longitude,
    required double timezone,
  }) {
    final cacheKey = _generateCacheKey(
      year: year,
      month: month,
      date: date,
      hours: hours,
      minutes: minutes,
      latitude: latitude,
      longitude: longitude,
      timezone: timezone,
      cacheType: 'chart_svg',
    );

    final cache = _cacheBox.get(cacheKey);
    if (cache == null || cache.isExpired) {
      return null;
    }

    print('📦 SVG cache hit: $cacheKey');
    final decoded = jsonDecode(cache.jsonData) as Map<String, dynamic>;
    return decoded.map((k, v) => MapEntry(k, v.toString()));
  }

  /// Clear all cache
  Future<void> clearCache() async {
    await _cacheBox.clear();
    print('🗑️ Cache cleared');
  }

  /// Clear expired cache entries
  Future<void> clearExpiredCache() async {
    final expiredKeys = _cacheBox.values
        .where((c) => c.isExpired)
        .map((c) => c.cacheKey)
        .toList();

    for (final key in expiredKeys) {
      await _cacheBox.delete(key);
    }
    print('🧹 Cleared ${expiredKeys.length} expired cache entries');
  }

  // ============================================================
  // APP SETTINGS OPERATIONS
  // ============================================================

  /// Get app settings box
  Box<AppSettingsModel> get _settingsBox =>
      Hive.box<AppSettingsModel>(HiveBoxes.appSettings);

  static const String _settingsKey = 'app_settings';

  /// Get current app settings
  AppSettingsModel getSettings() {
    return _settingsBox.get(_settingsKey) ?? AppSettingsModel();
  }

  /// Save app settings
  Future<void> saveSettings(AppSettingsModel settings) async {
    await _settingsBox.put(_settingsKey, settings);
    print('⚙️ Settings saved');
  }

  /// Update a specific setting
  Future<void> updateSetting<T>({
    required String key,
    required T value,
  }) async {
    final current = getSettings();
    AppSettingsModel updated;

    switch (key) {
      case 'darkMode':
        updated = current.copyWith(darkMode: value as bool);
        break;
      case 'language':
        updated = current.copyWith(language: value as String);
        break;
      case 'ayanamsha':
        updated = current.copyWith(ayanamsha: value as String);
        break;
      case 'chartStyle':
        updated = current.copyWith(chartStyle: value as String);
        break;
      case 'notifications':
        updated = current.copyWith(notifications: value as bool);
        break;
      case 'defaultTimezone':
        updated = current.copyWith(defaultTimezone: value as String);
        break;
      case 'showRetrogrades':
        updated = current.copyWith(showRetrogrades: value as bool);
        break;
      case 'showNakshatras':
        updated = current.copyWith(showNakshatras: value as bool);
        break;
      default:
        print('⚠️ Unknown setting key: $key');
        return;
    }

    await saveSettings(updated);
  }

  // ============================================================
  // ANALYSIS HISTORY OPERATIONS
  // ============================================================

  /// Get analysis history box
  Box<AnalysisHistoryModel> get _historyBox =>
      Hive.box<AnalysisHistoryModel>(HiveBoxes.analysisHistory);

  /// Save an analysis to history
  Future<AnalysisHistoryModel> saveAnalysis({
    required String profileId,
    required String analysisType,
    required String query,
    required String response,
    Map<String, dynamic>? metadata,
  }) async {
    final id = _generateUniqueId();

    final analysis = AnalysisHistoryModel(
      id: id,
      profileId: profileId,
      analysisType: analysisType,
      query: query,
      response: response,
      createdAt: DateTime.now(),
      metadata: metadata,
    );

    await _historyBox.put(id, analysis);
    print('📝 Saved analysis: $analysisType');
    return analysis;
  }

  /// Get all analysis history
  List<AnalysisHistoryModel> getAnalysisHistory() {
    return _historyBox.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Get analysis history for a profile
  List<AnalysisHistoryModel> getAnalysisHistoryForProfile(String profileId) {
    return _historyBox.values
        .where((a) => a.profileId == profileId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Get analysis history by type
  List<AnalysisHistoryModel> getAnalysisHistoryByType(String analysisType) {
    return _historyBox.values
        .where((a) => a.analysisType == analysisType)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Delete an analysis
  Future<void> deleteAnalysis(String id) async {
    await _historyBox.delete(id);
    print('🗑️ Deleted analysis: $id');
  }

  /// Clear all analysis history
  Future<void> clearAnalysisHistory() async {
    await _historyBox.clear();
    print('🗑️ Analysis history cleared');
  }

  // ============================================================
  // QUIZ PROGRESS OPERATIONS
  // ============================================================

  /// Get quiz progress box
  Box<QuizProgressModel> get _quizBox =>
      Hive.box<QuizProgressModel>(HiveBoxes.quizProgress);

  /// Get or create quiz progress for a profile and category
  QuizProgressModel getQuizProgress({
    required String profileId,
    required String category,
  }) {
    final key = '${profileId}_$category';
    return _quizBox.get(key) ??
        QuizProgressModel(
          id: key,
          profileId: profileId,
          quizCategory: category,
        );
  }

  /// Update quiz progress
  Future<void> updateQuizProgress({
    required String profileId,
    required String category,
    required int score,
    required int totalQuestions,
    required int correctAnswers,
    String? completedQuizId,
  }) async {
    final key = '${profileId}_$category';
    final existing = _quizBox.get(key);

    final progress = QuizProgressModel(
      id: key,
      profileId: profileId,
      quizCategory: category,
      score: (existing?.score ?? 0) + score,
      totalQuestions: (existing?.totalQuestions ?? 0) + totalQuestions,
      correctAnswers: (existing?.correctAnswers ?? 0) + correctAnswers,
      completedQuizIds: [
        ...(existing?.completedQuizIds ?? []),
        if (completedQuizId != null) completedQuizId,
      ],
      lastAttemptAt: DateTime.now(),
      streakDays: _calculateStreak(existing?.lastAttemptAt),
    );

    await _quizBox.put(key, progress);
    print('🎮 Updated quiz progress: $category');
  }

  /// Calculate streak days
  int _calculateStreak(DateTime? lastAttempt) {
    if (lastAttempt == null) return 1;

    final today = DateTime.now();
    final difference = today.difference(lastAttempt).inDays;

    if (difference == 0 || difference == 1) {
      return 1; // Continue or maintain streak
    }
    return 1; // Reset streak
  }

  /// Get all quiz progress for a profile
  List<QuizProgressModel> getQuizProgressForProfile(String profileId) {
    return _quizBox.values.where((q) => q.profileId == profileId).toList();
  }

  // ============================================================
  // UTILITY METHODS
  // ============================================================

  /// Generate a unique ID
  String _generateUniqueId() {
    final now = DateTime.now();
    final random = now.microsecondsSinceEpoch.toString();
    return md5.convert(utf8.encode('$now$random')).toString().substring(0, 16);
  }

  /// Get database statistics
  Future<Map<String, dynamic>> getDatabaseStats() async {
    return {
      'profiles': _profilesBox.length,
      'charts': _chartsBox.length,
      'cacheEntries': _cacheBox.length,
      'analysisHistory': _historyBox.length,
      'quizProgress': _quizBox.length,
    };
  }

  /// Clear all data (for testing/reset)
  Future<void> clearAllData() async {
    await _profilesBox.clear();
    await _chartsBox.clear();
    await _cacheBox.clear();
    await _settingsBox.clear();
    await _historyBox.clear();
    await _quizBox.clear();
    print('🗑️ All database data cleared');
  }

  /// Close all boxes
  Future<void> close() async {
    await Hive.close();
    _isInitialized = false;
    print('📦 Hive database closed');
  }
}
