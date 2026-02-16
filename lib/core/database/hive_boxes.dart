/// Hive Box Names - Centralized constants for box names
/// This ensures consistency across the app when accessing boxes
class HiveBoxes {
  // Box names
  static const String userProfile = 'user_profile';
  static const String savedCharts = 'saved_charts';
  static const String chartCache = 'chart_cache';
  static const String appSettings = 'app_settings';
  static const String favoriteNakshatras = 'favorite_nakshatras';
  static const String analysisHistory = 'analysis_history';
  static const String quizProgress = 'quiz_progress';
  static const String kundaliRecords = 'kundali_records';

  // Private constructor to prevent instantiation
  HiveBoxes._();
}

/// Hive Type IDs - Must be unique across the app
/// Range 0-223 is available for custom types
class HiveTypeIds {
  static const int userProfileModel = 0;
  static const int savedChartModel = 1;
  static const int chartCacheModel = 2;
  static const int planetPlacementModel = 3;
  static const int appSettingsModel = 4;
  static const int analysisHistoryModel = 5;
  static const int quizProgressModel = 6;
  static const int kundaliRecordModel = 11;

  // Private constructor to prevent instantiation
  HiveTypeIds._();
}
