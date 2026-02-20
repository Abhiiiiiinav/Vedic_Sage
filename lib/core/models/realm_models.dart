import 'package:flutter/material.dart';

/// The 5 elemental realms in the pet world map
enum RealmType {
  fire,
  water,
  forest,
  air,
  central,
}

extension RealmTypeExt on RealmType {
  String get label {
    switch (this) {
      case RealmType.fire:
        return 'Fire Realm';
      case RealmType.water:
        return 'Water Realm';
      case RealmType.forest:
        return 'Forest Realm';
      case RealmType.air:
        return 'Air Realm';
      case RealmType.central:
        return 'Central Land';
    }
  }

  String get emoji {
    switch (this) {
      case RealmType.fire:
        return '🔥';
      case RealmType.water:
        return '💧';
      case RealmType.forest:
        return '🌲';
      case RealmType.air:
        return '🌬️';
      case RealmType.central:
        return '🏛️';
    }
  }

  String get subtitle {
    switch (this) {
      case RealmType.fire:
        return 'Volcanic Islands';
      case RealmType.water:
        return 'Ocean Depths';
      case RealmType.forest:
        return 'Ancient Woods';
      case RealmType.air:
        return 'Sky Islands';
      case RealmType.central:
        return 'Hangout Hub';
    }
  }

  /// Primary gradient colors for each realm
  List<Color> get gradientColors {
    switch (this) {
      case RealmType.fire:
        return [
          const Color(0xFF5C1A0B),
          const Color(0xFFBF360C),
          const Color(0xFFFF6D00)
        ];
      case RealmType.water:
        return [
          const Color(0xFF0A1929),
          const Color(0xFF0D47A1),
          const Color(0xFF00B8D4)
        ];
      case RealmType.forest:
        return [
          const Color(0xFF1B3A1B),
          const Color(0xFF2E7D32),
          const Color(0xFF69F0AE)
        ];
      case RealmType.air:
        return [
          const Color(0xFF263238),
          const Color(0xFF546E7A),
          const Color(0xFFB0BEC5)
        ];
      case RealmType.central:
        return [
          const Color(0xFF1A1040),
          const Color(0xFF4A148C),
          const Color(0xFFEA80FC)
        ];
    }
  }

  /// Accent color for markers and glows
  Color get accentColor {
    switch (this) {
      case RealmType.fire:
        return const Color(0xFFFF6D00);
      case RealmType.water:
        return const Color(0xFF00B8D4);
      case RealmType.forest:
        return const Color(0xFF69F0AE);
      case RealmType.air:
        return const Color(0xFFB0BEC5);
      case RealmType.central:
        return const Color(0xFFEA80FC);
    }
  }

  /// Icons representing landmarks in the realm
  List<IconData> get landmarkIcons {
    switch (this) {
      case RealmType.fire:
        return [
          Icons.whatshot_rounded,
          Icons.volcano_rounded,
          Icons.local_fire_department_rounded
        ];
      case RealmType.water:
        return [Icons.water_rounded, Icons.waves_rounded, Icons.pool_rounded];
      case RealmType.forest:
        return [Icons.park_rounded, Icons.forest_rounded, Icons.eco_rounded];
      case RealmType.air:
        return [
          Icons.cloud_rounded,
          Icons.air_rounded,
          Icons.filter_drama_rounded
        ];
      case RealmType.central:
        return [
          Icons.location_city_rounded,
          Icons.celebration_rounded,
          Icons.groups_rounded
        ];
    }
  }
}

/// Defines a realm zone's bounds on the scrollable canvas
class RealmZone {
  final RealmType type;
  final Rect bounds; // position & size on the canvas

  const RealmZone({required this.type, required this.bounds});
}

/// A friend's marker on the realm map
class FriendMapMarker {
  final String friendId;
  final String name;
  final String initial; // first letter for avatar
  final RealmType realm;
  final double x; // offset within the realm
  final double y;
  final String? petSpecies; // optional pet species key
  final Color avatarColor;

  const FriendMapMarker({
    required this.friendId,
    required this.name,
    required this.initial,
    required this.realm,
    required this.x,
    required this.y,
    this.petSpecies,
    required this.avatarColor,
  });
}

/// The astrological element derived from zodiac signs
enum AstroElement {
  fire,
  water,
  earth,
  air,
}

extension AstroElementExt on AstroElement {
  RealmType get realm {
    switch (this) {
      case AstroElement.fire:
        return RealmType.fire;
      case AstroElement.water:
        return RealmType.water;
      case AstroElement.earth:
        return RealmType.forest;
      case AstroElement.air:
        return RealmType.air;
    }
  }

  String get label {
    switch (this) {
      case AstroElement.fire:
        return 'Fire';
      case AstroElement.water:
        return 'Water';
      case AstroElement.earth:
        return 'Earth';
      case AstroElement.air:
        return 'Air';
    }
  }
}

// ════════════════════════════════════════════════════════════
// PROCEDURAL REALM GENERATION MODELS
// ════════════════════════════════════════════════════════════

/// Defines a complete procedural realm world
class RealmGenerationConfig {
  final String realmId;
  final RealmType theme;
  final int seed;
  final List<String> biomes;
  final List<RealmLandmark> landmarks;
  final List<RealmPath> paths;
  final List<String> ambientFx;

  const RealmGenerationConfig({
    required this.realmId,
    required this.theme,
    required this.seed,
    required this.biomes,
    required this.landmarks,
    required this.paths,
    required this.ambientFx,
  });

  Map<String, dynamic> toMap() => {
        'realm_id': realmId,
        'theme': theme.name,
        'seed': seed,
        'biomes': biomes,
        'landmarks': landmarks.map((l) => l.toMap()).toList(),
        'paths': paths.map((p) => p.toMap()).toList(),
        'ambient_fx': ambientFx,
      };
}

/// A landmark within a realm
class RealmLandmark {
  final String type;
  final double x;
  final double y;

  const RealmLandmark({
    required this.type,
    required this.x,
    required this.y,
  });

  Map<String, dynamic> toMap() => {
        'type': type,
        'x': x,
        'y': y,
      };

  String get displayName => type
      .replaceAll('_', ' ')
      .split(' ')
      .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');
}

/// A path connecting two landmarks
class RealmPath {
  final String from;
  final String to;
  final String style;

  const RealmPath({
    required this.from,
    required this.to,
    required this.style,
  });

  Map<String, dynamic> toMap() => {
        'from': from,
        'to': to,
        'style': style,
      };
}

/// A single tile in the procedural grid
class RealmTile {
  final String tileId;
  final String terrain;
  final String biome;
  final List<String> props;
  final List<String> spawnPoints;
  final int col;
  final int row;

  const RealmTile({
    required this.tileId,
    required this.terrain,
    required this.biome,
    required this.props,
    required this.spawnPoints,
    required this.col,
    required this.row,
  });

  Map<String, dynamic> toMap() => {
        'tile_id': tileId,
        'terrain': terrain,
        'biome': biome,
        'props': props,
        'spawn_points': spawnPoints,
      };
}
