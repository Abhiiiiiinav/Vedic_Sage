// GENERATED CODE - Manually created Hive adapters
// These adapters serialize/deserialize models for Hive storage

import 'package:hive/hive.dart';
import 'hive_models.dart';

/// Adapter for UserProfileModel
class UserProfileModelAdapter extends TypeAdapter<UserProfileModel> {
  @override
  final int typeId = 0;

  @override
  UserProfileModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserProfileModel(
      id: fields[0] as String,
      name: fields[1] as String,
      birthDateTime: fields[2] as DateTime?,
      birthPlace: fields[3] as String?,
      latitude: fields[4] as double?,
      longitude: fields[5] as double?,
      timezoneOffset: fields[6] as double?,
      createdAt: fields[7] as DateTime,
      updatedAt: fields[8] as DateTime,
      isPrimary: fields[9] as bool? ?? false,
    );
  }

  @override
  void write(BinaryWriter writer, UserProfileModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.birthDateTime)
      ..writeByte(3)
      ..write(obj.birthPlace)
      ..writeByte(4)
      ..write(obj.latitude)
      ..writeByte(5)
      ..write(obj.longitude)
      ..writeByte(6)
      ..write(obj.timezoneOffset)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.updatedAt)
      ..writeByte(9)
      ..write(obj.isPrimary);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfileModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

/// Adapter for PlanetPlacementModel
class PlanetPlacementModelAdapter extends TypeAdapter<PlanetPlacementModel> {
  @override
  final int typeId = 3;

  @override
  PlanetPlacementModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PlanetPlacementModel(
      planetId: fields[0] as String,
      house: fields[1] as int,
      sign: fields[2] as String,
      degrees: fields[3] as double,
      nakshatra: fields[4] as String?,
      nakshatraPada: fields[5] as int?,
      isRetrograde: fields[6] as bool? ?? false,
      dignity: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, PlanetPlacementModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.planetId)
      ..writeByte(1)
      ..write(obj.house)
      ..writeByte(2)
      ..write(obj.sign)
      ..writeByte(3)
      ..write(obj.degrees)
      ..writeByte(4)
      ..write(obj.nakshatra)
      ..writeByte(5)
      ..write(obj.nakshatraPada)
      ..writeByte(6)
      ..write(obj.isRetrograde)
      ..writeByte(7)
      ..write(obj.dignity);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlanetPlacementModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

/// Adapter for SavedChartModel
class SavedChartModelAdapter extends TypeAdapter<SavedChartModel> {
  @override
  final int typeId = 1;

  @override
  SavedChartModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SavedChartModel(
      id: fields[0] as String,
      profileId: fields[1] as String,
      name: fields[2] as String,
      birthDateTime: fields[3] as DateTime,
      birthPlace: fields[4] as String,
      latitude: fields[5] as double,
      longitude: fields[6] as double,
      timezoneOffset: fields[7] as double,
      ascendantSign: fields[8] as String?,
      ascendantDegrees: fields[9] as double?,
      planetPlacements: (fields[10] as List).cast<PlanetPlacementModel>(),
      chartSvg: fields[11] as String?,
      createdAt: fields[12] as DateTime,
      updatedAt: fields[13] as DateTime,
      rawApiResponse: (fields[14] as Map?)?.cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, SavedChartModel obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.profileId)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.birthDateTime)
      ..writeByte(4)
      ..write(obj.birthPlace)
      ..writeByte(5)
      ..write(obj.latitude)
      ..writeByte(6)
      ..write(obj.longitude)
      ..writeByte(7)
      ..write(obj.timezoneOffset)
      ..writeByte(8)
      ..write(obj.ascendantSign)
      ..writeByte(9)
      ..write(obj.ascendantDegrees)
      ..writeByte(10)
      ..write(obj.planetPlacements)
      ..writeByte(11)
      ..write(obj.chartSvg)
      ..writeByte(12)
      ..write(obj.createdAt)
      ..writeByte(13)
      ..write(obj.updatedAt)
      ..writeByte(14)
      ..write(obj.rawApiResponse);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SavedChartModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

/// Adapter for ChartCacheModel
class ChartCacheModelAdapter extends TypeAdapter<ChartCacheModel> {
  @override
  final int typeId = 2;

  @override
  ChartCacheModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChartCacheModel(
      cacheKey: fields[0] as String,
      jsonData: fields[1] as String,
      cachedAt: fields[2] as DateTime,
      expiresAt: fields[3] as DateTime?,
      cacheType: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ChartCacheModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.cacheKey)
      ..writeByte(1)
      ..write(obj.jsonData)
      ..writeByte(2)
      ..write(obj.cachedAt)
      ..writeByte(3)
      ..write(obj.expiresAt)
      ..writeByte(4)
      ..write(obj.cacheType);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChartCacheModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

/// Adapter for AppSettingsModel
class AppSettingsModelAdapter extends TypeAdapter<AppSettingsModel> {
  @override
  final int typeId = 4;

  @override
  AppSettingsModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppSettingsModel(
      darkMode: fields[0] as bool? ?? true,
      language: fields[1] as String? ?? 'en',
      ayanamsha: fields[2] as String? ?? 'lahiri',
      chartStyle: fields[3] as String? ?? 'north',
      notifications: fields[4] as bool? ?? true,
      defaultTimezone: fields[5] as String? ?? 'Asia/Kolkata',
      showRetrogrades: fields[6] as bool? ?? true,
      showNakshatras: fields[7] as bool? ?? true,
      updatedAt: fields[8] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, AppSettingsModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.darkMode)
      ..writeByte(1)
      ..write(obj.language)
      ..writeByte(2)
      ..write(obj.ayanamsha)
      ..writeByte(3)
      ..write(obj.chartStyle)
      ..writeByte(4)
      ..write(obj.notifications)
      ..writeByte(5)
      ..write(obj.defaultTimezone)
      ..writeByte(6)
      ..write(obj.showRetrogrades)
      ..writeByte(7)
      ..write(obj.showNakshatras)
      ..writeByte(8)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSettingsModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

/// Adapter for AnalysisHistoryModel
class AnalysisHistoryModelAdapter extends TypeAdapter<AnalysisHistoryModel> {
  @override
  final int typeId = 5;

  @override
  AnalysisHistoryModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AnalysisHistoryModel(
      id: fields[0] as String,
      profileId: fields[1] as String,
      analysisType: fields[2] as String,
      query: fields[3] as String,
      response: fields[4] as String,
      createdAt: fields[5] as DateTime,
      metadata: (fields[6] as Map?)?.cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, AnalysisHistoryModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.profileId)
      ..writeByte(2)
      ..write(obj.analysisType)
      ..writeByte(3)
      ..write(obj.query)
      ..writeByte(4)
      ..write(obj.response)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.metadata);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnalysisHistoryModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

/// Adapter for QuizProgressModel
class QuizProgressModelAdapter extends TypeAdapter<QuizProgressModel> {
  @override
  final int typeId = 6;

  @override
  QuizProgressModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return QuizProgressModel(
      id: fields[0] as String,
      profileId: fields[1] as String,
      quizCategory: fields[2] as String,
      score: fields[3] as int? ?? 0,
      totalQuestions: fields[4] as int? ?? 0,
      correctAnswers: fields[5] as int? ?? 0,
      completedQuizIds: (fields[6] as List?)?.cast<String>() ?? [],
      lastAttemptAt: fields[7] as DateTime?,
      streakDays: fields[8] as int? ?? 0,
    );
  }

  @override
  void write(BinaryWriter writer, QuizProgressModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.profileId)
      ..writeByte(2)
      ..write(obj.quizCategory)
      ..writeByte(3)
      ..write(obj.score)
      ..writeByte(4)
      ..write(obj.totalQuestions)
      ..writeByte(5)
      ..write(obj.correctAnswers)
      ..writeByte(6)
      ..write(obj.completedQuizIds)
      ..writeByte(7)
      ..write(obj.lastAttemptAt)
      ..writeByte(8)
      ..write(obj.streakDays);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuizProgressModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
