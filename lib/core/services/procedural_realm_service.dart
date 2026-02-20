/// Procedural Realm Generation Service
///
/// Generates deterministic realm configurations using seeded randomness.
/// Each realm's biomes, landmarks, paths, and tiles are fully reproducible
/// from a seed integer.

import 'dart:math';
import '../models/realm_models.dart';

class ProceduralRealmService {
  static final ProceduralRealmService _instance = ProceduralRealmService._();
  factory ProceduralRealmService() => _instance;
  ProceduralRealmService._();

  // ── Biome pools per theme (deterministic constraints) ──

  static const Map<RealmType, List<String>> _biomePool = {
    RealmType.fire: [
      'volcano',
      'ember_forest',
      'lava_river',
      'ash_plains',
      'magma_cave'
    ],
    RealmType.water: [
      'coral_reef',
      'deep_trench',
      'tidal_pools',
      'ice_grotto',
      'kelp_forest'
    ],
    RealmType.forest: [
      'ancient_woods',
      'mushroom_grove',
      'crystal_glade',
      'moss_swamp',
      'fern_valley'
    ],
    RealmType.air: [
      'cloud_peaks',
      'wind_canyon',
      'storm_ridge',
      'aurora_plateau',
      'sky_bridge'
    ],
    RealmType.central: [
      'plaza',
      'garden',
      'amphitheatre',
      'market',
      'fountain_court'
    ],
  };

  static const Map<RealmType, List<String>> _landmarkPool = {
    RealmType.fire: [
      'volcano_temple',
      'ember_village',
      'forge_tower',
      'obsidian_gate',
      'flame_shrine'
    ],
    RealmType.water: [
      'pearl_palace',
      'tide_village',
      'coral_temple',
      'whirlpool_arena',
      'moonpool'
    ],
    RealmType.forest: [
      'tree_of_life',
      'ranger_outpost',
      'druid_circle',
      'beast_den',
      'vine_bridge'
    ],
    RealmType.air: [
      'sky_citadel',
      'wind_temple',
      'eagle_nest',
      'cloud_market',
      'storm_lighthouse'
    ],
    RealmType.central: [
      'grand_hub',
      'pet_plaza',
      'stargazer_tower',
      'friendship_fountain',
      'cosmic_stage'
    ],
  };

  static const Map<RealmType, List<String>> _pathStyles = {
    RealmType.fire: ['lava_bridge', 'ember_trail', 'obsidian_road'],
    RealmType.water: ['coral_path', 'ice_bridge', 'bubble_stream'],
    RealmType.forest: ['vine_bridge', 'moss_trail', 'root_path'],
    RealmType.air: ['cloud_bridge', 'wind_current', 'rainbow_arc'],
    RealmType.central: ['golden_path', 'starlit_road', 'crystal_walk'],
  };

  static const Map<RealmType, List<String>> _terrainTypes = {
    RealmType.fire: ['lava', 'scorched_earth', 'obsidian', 'embers'],
    RealmType.water: ['shallow_water', 'deep_water', 'sand', 'coral'],
    RealmType.forest: ['grass', 'moss', 'roots', 'mushroom_floor'],
    RealmType.air: ['cloud', 'wind_stone', 'mist', 'crystal'],
    RealmType.central: ['marble', 'garden_path', 'stone', 'grass'],
  };

  static const Map<RealmType, List<String>> _propPool = {
    RealmType.fire: [
      'rock',
      'ember_tree',
      'fire_crystal',
      'lava_rock',
      'ash_pile'
    ],
    RealmType.water: ['seaweed', 'shell', 'coral_branch', 'pearl', 'driftwood'],
    RealmType.forest: ['tree', 'bush', 'mushroom', 'flower', 'moss_rock'],
    RealmType.air: [
      'cloud_puff',
      'feather',
      'wind_chime',
      'crystal_shard',
      'nest'
    ],
    RealmType.central: ['bench', 'lantern', 'fountain', 'banner', 'flower_pot'],
  };

  static const Map<RealmType, List<String>> _ambientFxPool = {
    RealmType.fire: ['embers', 'heat_wave', 'sparks', 'smoke_wisps'],
    RealmType.water: ['bubbles', 'ripples', 'mist', 'bioluminescence'],
    RealmType.forest: ['fireflies', 'falling_leaves', 'spores', 'sunbeams'],
    RealmType.air: ['wind_particles', 'cloud_wisps', 'aurora', 'feathers'],
    RealmType.central: ['stardust', 'sparkles', 'light_orbs', 'confetti'],
  };

  // ── Generation ──

  /// Generate a complete realm configuration from a seed.
  RealmGenerationConfig generateRealmConfig(RealmType theme, int seed) {
    final rng = Random(seed);
    final biomes = _biomePool[theme]!;
    final landmarks = _landmarkPool[theme]!;
    final paths = _pathStyles[theme]!;
    final ambientFx = _ambientFxPool[theme]!;

    // Pick 2-3 biomes
    final selectedBiomes = _pickN(biomes, 2 + rng.nextInt(2), rng);

    // Place 2-4 landmarks
    final numLandmarks = 2 + rng.nextInt(3);
    final selectedLandmarks = <RealmLandmark>[];
    final usedLandmarkNames = <String>[];
    for (int i = 0; i < numLandmarks; i++) {
      final name = landmarks[rng.nextInt(landmarks.length)];
      if (usedLandmarkNames.contains(name)) continue;
      usedLandmarkNames.add(name);
      selectedLandmarks.add(RealmLandmark(
        type: name,
        x: 100.0 + rng.nextDouble() * 500,
        y: 80.0 + rng.nextDouble() * 350,
      ));
    }

    // Generate paths between adjacent landmarks
    final selectedPaths = <RealmPath>[];
    for (int i = 0; i < selectedLandmarks.length - 1; i++) {
      selectedPaths.add(RealmPath(
        from: selectedLandmarks[i].type,
        to: selectedLandmarks[i + 1].type,
        style: paths[rng.nextInt(paths.length)],
      ));
    }

    // Pick 2 ambient effects
    final selectedFx = _pickN(ambientFx, 2, rng);

    return RealmGenerationConfig(
      realmId: '${theme.name}_${seed.toString().padLeft(3, "0")}',
      theme: theme,
      seed: seed,
      biomes: selectedBiomes,
      landmarks: selectedLandmarks,
      paths: selectedPaths,
      ambientFx: selectedFx,
    );
  }

  /// Generate tiles for a realm within given bounds.
  /// Divides the area into a 150×150 grid.
  List<RealmTile> generateTiles(
      RealmGenerationConfig config, double width, double height) {
    final rng = Random(config.seed);
    final tiles = <RealmTile>[];
    final terrains = _terrainTypes[config.theme]!;
    final props = _propPool[config.theme]!;

    const tileSize = 150.0;
    final cols = (width / tileSize).ceil();
    final rows = (height / tileSize).ceil();

    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < cols; col++) {
        final biomeIndex = (row + col) % config.biomes.length;
        final terrain = terrains[rng.nextInt(terrains.length)];

        // 1–3 random props per tile
        final numProps = 1 + rng.nextInt(3);
        final tileProps = _pickN(props, numProps, rng);

        // Spawn points (20% chance per tile)
        final spawnPoints = <String>[];
        if (rng.nextDouble() < 0.2) spawnPoints.add('pet_spawn');
        if (rng.nextDouble() < 0.15) spawnPoints.add('friend_spawn');

        tiles.add(RealmTile(
          tileId: '${config.theme.name}_tile_${col}_$row',
          terrain: terrain,
          biome: config.biomes[biomeIndex],
          props: tileProps,
          spawnPoints: spawnPoints,
          col: col,
          row: row,
        ));
      }
    }

    return tiles;
  }

  /// Get ambient effects for a realm.
  List<String> getAmbientFx(RealmType realm) {
    return _ambientFxPool[realm] ?? [];
  }

  /// Validate deterministic constraints.
  /// Ensures no cross-element contamination.
  bool isLandmarkAllowed(RealmType realm, String landmarkType) {
    // Fire realm: no water-themed landmarks
    if (realm == RealmType.fire) {
      const forbidden = [
        'pearl_palace',
        'tide_village',
        'coral_temple',
        'moonpool'
      ];
      if (forbidden.contains(landmarkType)) return false;
    }
    // Central land: neutral only
    if (realm == RealmType.central) {
      return _landmarkPool[RealmType.central]!.contains(landmarkType);
    }
    return true;
  }

  // ── Helpers ──

  List<String> _pickN(List<String> pool, int n, Random rng) {
    final shuffled = List<String>.from(pool)..shuffle(rng);
    return shuffled.take(n.clamp(1, shuffled.length)).toList();
  }
}
