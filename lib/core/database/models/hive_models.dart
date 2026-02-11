import 'package:hive/hive.dart';
import '../hive_boxes.dart';

/// User Profile Model for Hive storage
@HiveType(typeId: HiveTypeIds.userProfileModel)
class UserProfileModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  DateTime? birthDateTime;

  @HiveField(3)
  String? birthPlace;

  @HiveField(4)
  double? latitude;

  @HiveField(5)
  double? longitude;

  @HiveField(6)
  double? timezoneOffset;

  @HiveField(7)
  DateTime createdAt;

  @HiveField(8)
  DateTime updatedAt;

  @HiveField(9)
  bool isPrimary;

  UserProfileModel({
    required this.id,
    required this.name,
    this.birthDateTime,
    this.birthPlace,
    this.latitude,
    this.longitude,
    this.timezoneOffset,
    required this.createdAt,
    required this.updatedAt,
    this.isPrimary = false,
  });

  /// Create a copy with updated fields
  UserProfileModel copyWith({
    String? id,
    String? name,
    DateTime? birthDateTime,
    String? birthPlace,
    double? latitude,
    double? longitude,
    double? timezoneOffset,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isPrimary,
  }) {
    return UserProfileModel(
      id: id ?? this.id,
      name: name ?? this.name,
      birthDateTime: birthDateTime ?? this.birthDateTime,
      birthPlace: birthPlace ?? this.birthPlace,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      timezoneOffset: timezoneOffset ?? this.timezoneOffset,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      isPrimary: isPrimary ?? this.isPrimary,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'birthDateTime': birthDateTime?.toIso8601String(),
      'birthPlace': birthPlace,
      'latitude': latitude,
      'longitude': longitude,
      'timezoneOffset': timezoneOffset,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isPrimary': isPrimary,
    };
  }

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] as String,
      name: json['name'] as String,
      birthDateTime: json['birthDateTime'] != null
          ? DateTime.parse(json['birthDateTime'])
          : null,
      birthPlace: json['birthPlace'] as String?,
      latitude: json['latitude'] as double?,
      longitude: json['longitude'] as double?,
      timezoneOffset: json['timezoneOffset'] as double?,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      isPrimary: json['isPrimary'] as bool? ?? false,
    );
  }
}

/// Saved Chart Model for persisting birth charts
@HiveType(typeId: HiveTypeIds.savedChartModel)
class SavedChartModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String profileId;

  @HiveField(2)
  String name;

  @HiveField(3)
  DateTime birthDateTime;

  @HiveField(4)
  String birthPlace;

  @HiveField(5)
  double latitude;

  @HiveField(6)
  double longitude;

  @HiveField(7)
  double timezoneOffset;

  @HiveField(8)
  String? ascendantSign;

  @HiveField(9)
  double? ascendantDegrees;

  @HiveField(10)
  List<PlanetPlacementModel> planetPlacements;

  @HiveField(11)
  String? chartSvg;

  @HiveField(12)
  DateTime createdAt;

  @HiveField(13)
  DateTime updatedAt;

  @HiveField(14)
  Map<String, dynamic>? rawApiResponse;

  SavedChartModel({
    required this.id,
    required this.profileId,
    required this.name,
    required this.birthDateTime,
    required this.birthPlace,
    required this.latitude,
    required this.longitude,
    required this.timezoneOffset,
    this.ascendantSign,
    this.ascendantDegrees,
    required this.planetPlacements,
    this.chartSvg,
    required this.createdAt,
    required this.updatedAt,
    this.rawApiResponse,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'profileId': profileId,
      'name': name,
      'birthDateTime': birthDateTime.toIso8601String(),
      'birthPlace': birthPlace,
      'latitude': latitude,
      'longitude': longitude,
      'timezoneOffset': timezoneOffset,
      'ascendantSign': ascendantSign,
      'ascendantDegrees': ascendantDegrees,
      'planetPlacements': planetPlacements.map((p) => p.toJson()).toList(),
      'chartSvg': chartSvg,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'rawApiResponse': rawApiResponse,
    };
  }
}

/// Planet Placement Model for chart data
@HiveType(typeId: HiveTypeIds.planetPlacementModel)
class PlanetPlacementModel extends HiveObject {
  @HiveField(0)
  String planetId;

  @HiveField(1)
  int house;

  @HiveField(2)
  String sign;

  @HiveField(3)
  double degrees;

  @HiveField(4)
  String? nakshatra;

  @HiveField(5)
  int? nakshatraPada;

  @HiveField(6)
  bool isRetrograde;

  @HiveField(7)
  String? dignity;

  PlanetPlacementModel({
    required this.planetId,
    required this.house,
    required this.sign,
    required this.degrees,
    this.nakshatra,
    this.nakshatraPada,
    this.isRetrograde = false,
    this.dignity,
  });

  Map<String, dynamic> toJson() {
    return {
      'planetId': planetId,
      'house': house,
      'sign': sign,
      'degrees': degrees,
      'nakshatra': nakshatra,
      'nakshatraPada': nakshatraPada,
      'isRetrograde': isRetrograde,
      'dignity': dignity,
    };
  }

  factory PlanetPlacementModel.fromJson(Map<String, dynamic> json) {
    return PlanetPlacementModel(
      planetId: json['planetId'] as String,
      house: json['house'] as int,
      sign: json['sign'] as String,
      degrees: (json['degrees'] as num).toDouble(),
      nakshatra: json['nakshatra'] as String?,
      nakshatraPada: json['nakshatraPada'] as int?,
      isRetrograde: json['isRetrograde'] as bool? ?? false,
      dignity: json['dignity'] as String?,
    );
  }
}

/// Chart Cache Model for API response caching
@HiveType(typeId: HiveTypeIds.chartCacheModel)
class ChartCacheModel extends HiveObject {
  @HiveField(0)
  String cacheKey;

  @HiveField(1)
  String jsonData;

  @HiveField(2)
  DateTime cachedAt;

  @HiveField(3)
  DateTime? expiresAt;

  @HiveField(4)
  String cacheType; // 'chart_data', 'chart_svg', 'chart_url'

  ChartCacheModel({
    required this.cacheKey,
    required this.jsonData,
    required this.cachedAt,
    this.expiresAt,
    required this.cacheType,
  });

  bool get isExpired {
    if (expiresAt == null) return false; // No expiry = never expires
    return DateTime.now().isAfter(expiresAt!);
  }
}

/// App Settings Model for user preferences
@HiveType(typeId: HiveTypeIds.appSettingsModel)
class AppSettingsModel extends HiveObject {
  @HiveField(0)
  bool darkMode;

  @HiveField(1)
  String language;

  @HiveField(2)
  String ayanamsha;

  @HiveField(3)
  String chartStyle; // 'north', 'south', 'east'

  @HiveField(4)
  bool notifications;

  @HiveField(5)
  String defaultTimezone;

  @HiveField(6)
  bool showRetrogrades;

  @HiveField(7)
  bool showNakshatras;

  @HiveField(8)
  DateTime updatedAt;

  AppSettingsModel({
    this.darkMode = true,
    this.language = 'en',
    this.ayanamsha = 'lahiri',
    this.chartStyle = 'north',
    this.notifications = true,
    this.defaultTimezone = 'Asia/Kolkata',
    this.showRetrogrades = true,
    this.showNakshatras = true,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  AppSettingsModel copyWith({
    bool? darkMode,
    String? language,
    String? ayanamsha,
    String? chartStyle,
    bool? notifications,
    String? defaultTimezone,
    bool? showRetrogrades,
    bool? showNakshatras,
  }) {
    return AppSettingsModel(
      darkMode: darkMode ?? this.darkMode,
      language: language ?? this.language,
      ayanamsha: ayanamsha ?? this.ayanamsha,
      chartStyle: chartStyle ?? this.chartStyle,
      notifications: notifications ?? this.notifications,
      defaultTimezone: defaultTimezone ?? this.defaultTimezone,
      showRetrogrades: showRetrogrades ?? this.showRetrogrades,
      showNakshatras: showNakshatras ?? this.showNakshatras,
      updatedAt: DateTime.now(),
    );
  }
}

/// Analysis History Model for storing AI analysis results
@HiveType(typeId: HiveTypeIds.analysisHistoryModel)
class AnalysisHistoryModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String profileId;

  @HiveField(2)
  String analysisType; // 'name', 'chart', 'dasha', 'compatibility'

  @HiveField(3)
  String query;

  @HiveField(4)
  String response;

  @HiveField(5)
  DateTime createdAt;

  @HiveField(6)
  Map<String, dynamic>? metadata;

  AnalysisHistoryModel({
    required this.id,
    required this.profileId,
    required this.analysisType,
    required this.query,
    required this.response,
    required this.createdAt,
    this.metadata,
  });
}

/// Quiz Progress Model for gamification
@HiveType(typeId: HiveTypeIds.quizProgressModel)
class QuizProgressModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String profileId;

  @HiveField(2)
  String quizCategory;

  @HiveField(3)
  int score;

  @HiveField(4)
  int totalQuestions;

  @HiveField(5)
  int correctAnswers;

  @HiveField(6)
  List<String> completedQuizIds;

  @HiveField(7)
  DateTime lastAttemptAt;

  @HiveField(8)
  int streakDays;

  QuizProgressModel({
    required this.id,
    required this.profileId,
    required this.quizCategory,
    this.score = 0,
    this.totalQuestions = 0,
    this.correctAnswers = 0,
    List<String>? completedQuizIds,
    DateTime? lastAttemptAt,
    this.streakDays = 0,
  })  : completedQuizIds = completedQuizIds ?? [],
        lastAttemptAt = lastAttemptAt ?? DateTime.now();
}
