import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/models/realm_models.dart';
import '../../../core/services/realm_service.dart';
import '../../../core/services/friends_service.dart';
import '../../../core/services/presence_service.dart';
import '../../../core/services/fast_travel_service.dart';
import '../../../core/services/procedural_realm_service.dart';
import '../../friends/screens/pet_interaction_screen.dart';
import '../../friends/screens/friend_profile_screen.dart';
import '../widgets/minimap_overlay.dart';
import '../widgets/fast_travel_overlay.dart';

/// Scrollable Realm Map — a pannable/zoomable fantasy world where
/// pets live in elemental zones and friends appear as interactive markers.
///
/// Integrates:
///   - Live friend presence syncing
///   - Procedurally generated realm tiles
///   - Expandable minimap with fast travel
class RealmMapScreen extends StatefulWidget {
  const RealmMapScreen({super.key});

  @override
  State<RealmMapScreen> createState() => _RealmMapScreenState();
}

class _RealmMapScreenState extends State<RealmMapScreen>
    with TickerProviderStateMixin {
  final _realmService = RealmService();
  final _presenceService = PresenceService();
  final _fastTravelService = FastTravelService();
  final _proceduralService = ProceduralRealmService();

  late RealmType _userRealm;
  late List<FriendMapMarker> _friendMarkers;
  late AnimationController _pulseController;
  late AnimationController _entryController;

  // Procedural configs per realm (generated once, deterministic)
  final Map<RealmType, RealmGenerationConfig> _realmConfigs = {};

  // Canvas dimensions
  static const double _canvasWidth = 1600;
  static const double _canvasHeight = 1200;

  // Realm zones on the canvas
  static const _realmZones = <RealmType, Rect>{
    RealmType.fire: Rect.fromLTWH(0, 0, 760, 560),
    RealmType.water: Rect.fromLTWH(840, 0, 760, 560),
    RealmType.central: Rect.fromLTWH(400, 460, 800, 340),
    RealmType.forest: Rect.fromLTWH(0, 640, 760, 560),
    RealmType.air: Rect.fromLTWH(840, 640, 760, 560),
  };

  bool _showTravelAnimation = false;
  RealmType? _travelDestination;

  @override
  void initState() {
    super.initState();
    _userRealm = _realmService.getUserRealm();
    _friendMarkers = _realmService.buildFriendMarkers();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();

    // Generate procedural configs for each realm
    for (final realm in RealmType.values) {
      _realmConfigs[realm] = _proceduralService.generateRealmConfig(
        realm,
        realm.index * 1000 + 42,
      );
    }

    // Initialize presence & fast travel services
    _initServices();
  }

  Future<void> _initServices() async {
    try {
      await _presenceService.initialize();
      await _fastTravelService.initialize();
      _presenceService.setOnPresenceUpdated(_onPresenceUpdated);
      // Update markers from live presence
      _refreshMarkersFromPresence();
    } catch (_) {
      // Graceful fallback — static markers remain
    }
  }

  void _onPresenceUpdated() {
    if (!mounted) return;
    _refreshMarkersFromPresence();
  }

  void _refreshMarkersFromPresence() {
    if (!mounted) return;
    final presences = _presenceService.getFriendPresences();
    if (presences.isNotEmpty) {
      setState(() {
        _friendMarkers =
            _realmService.buildFriendMarkersFromPresence(presences);
      });
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _entryController.dispose();
    _presenceService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      body: Stack(
        children: [
          // Main map
          AnimatedBuilder(
            animation: _entryController,
            builder: (context, child) {
              final scale = 0.85 +
                  0.15 * Curves.easeOutCubic.transform(_entryController.value);
              final opacity = _entryController.value;
              return Opacity(
                opacity: opacity,
                child: Transform.scale(
                  scale: scale,
                  child: child,
                ),
              );
            },
            child: InteractiveViewer(
              constrained: false,
              panEnabled: true,
              minScale: 0.3,
              maxScale: 3.0,
              boundaryMargin: const EdgeInsets.all(double.infinity),
              child: SizedBox(
                width: _canvasWidth,
                height: _canvasHeight,
                child: Stack(
                  children: [
                    // Realm backgrounds with procedural tiles
                    ..._realmZones.entries
                        .map((e) => _buildRealmTile(e.key, e.value)),
                    // Procedural landmarks
                    ..._realmZones.entries.expand(
                        (e) => _buildProceduralLandmarks(e.key, e.value)),
                    // Friend markers
                    ..._friendMarkers.map(_buildFriendMarker),
                    // User's "You Are Here" marker
                    _buildUserMarker(),
                  ],
                ),
              ),
            ),
          ),
          // Top bar overlay
          _buildTopBar(),
          // Minimap (tappable → opens overlay)
          Positioned(
            right: 16,
            bottom: 32,
            child: GestureDetector(
              onTap: _openMinimapOverlay,
              child: _buildMinimap(),
            ),
          ),
          // Legend
          Positioned(
            left: 16,
            bottom: 32,
            child: _buildLegend(),
          ),
          // Travel animation overlay
          if (_showTravelAnimation && _travelDestination != null)
            FastTravelOverlay(
              from: _userRealm,
              to: _travelDestination!,
              travelMessage: 'Traveling to ${_travelDestination!.label}...',
              travelsRemaining: _fastTravelService.travelsRemaining,
              onComplete: _onTravelComplete,
            ),
        ],
      ),
    );
  }

  // ─── Top Bar ───

  Widget _buildTopBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 8,
          left: 16,
          right: 16,
          bottom: 12,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF0A0E21),
              const Color(0xFF0A0E21).withOpacity(0.8),
              Colors.transparent,
            ],
          ),
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white12),
                ),
                child:
                    const Icon(Icons.arrow_back, color: Colors.white, size: 20),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Realm Map',
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Your realm: ${_userRealm.emoji} ${_userRealm.label}',
                    style: GoogleFonts.quicksand(
                      fontSize: 12,
                      color: _userRealm.accentColor.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            // Travel counter badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.flight_rounded,
                      color: Colors.white38, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    '${_fastTravelService.travelsRemaining}',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _fastTravelService.travelsRemaining > 0
                          ? const Color(0xFF69F0AE)
                          : const Color(0xFFff6b9d),
                    ),
                  ),
                ],
              ),
            ),
            // Friend count
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.people_rounded,
                      color: Colors.white54, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    '${_friendMarkers.length}',
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Realm Tile (Painted) ───

  Widget _buildRealmTile(RealmType realm, Rect bounds) {
    final isHome = realm == _userRealm;
    final config = _realmConfigs[realm];

    return Positioned(
      left: bounds.left,
      top: bounds.top,
      width: bounds.width,
      height: bounds.height,
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          final glow = isHome ? 0.1 + 0.08 * _pulseController.value : 0.0;
          return Container(
            margin: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: realm.gradientColors,
              ),
              border: Border.all(
                color: isHome
                    ? realm.accentColor
                        .withOpacity(0.5 + 0.3 * _pulseController.value)
                    : Colors.white.withOpacity(0.1),
                width: isHome ? 2.5 : 1,
              ),
              boxShadow: isHome
                  ? [
                      BoxShadow(
                        color: realm.accentColor.withOpacity(glow),
                        blurRadius: 30,
                        spreadRadius: 5,
                      )
                    ]
                  : null,
            ),
            child: child,
          );
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(23),
          child: Stack(
            children: [
              // Particle dots
              ..._buildParticles(realm, bounds),
              // Original landmark icons
              ..._buildLandmarks(realm, bounds),
              // Biome indicator badges (from procedural gen)
              if (config != null)
                ...config.biomes.asMap().entries.map((entry) {
                  final i = entry.key;
                  return Positioned(
                    right: 12,
                    bottom: 44.0 + i * 22,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: realm.accentColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                            color: realm.accentColor.withOpacity(0.15)),
                      ),
                      child: Text(
                        entry.value.replaceAll('_', ' '),
                        style: GoogleFonts.quicksand(
                          fontSize: 8,
                          fontWeight: FontWeight.w600,
                          color: realm.accentColor.withOpacity(0.6),
                        ),
                      ),
                    ),
                  );
                }),
              // Realm label
              Positioned(
                left: 20,
                top: 18,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          realm.emoji,
                          style: const TextStyle(fontSize: 22),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          realm.label,
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                        if (isHome) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: realm.accentColor.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'HOME',
                              style: GoogleFonts.quicksand(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: realm.accentColor,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      realm.subtitle,
                      style: GoogleFonts.quicksand(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
              // Central land special content
              if (realm == RealmType.central)
                Positioned(
                  right: 20,
                  top: 18,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFf5a623).withOpacity(0.3),
                          const Color(0xFFff6b9d).withOpacity(0.3),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFf5a623).withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.auto_awesome,
                            color: Color(0xFFf5a623), size: 14),
                        const SizedBox(width: 5),
                        Text(
                          'All Friends Welcome',
                          style: GoogleFonts.quicksand(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFf5a623),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Procedural Landmarks (from generated config) ───

  List<Widget> _buildProceduralLandmarks(RealmType realm, Rect bounds) {
    final config = _realmConfigs[realm];
    if (config == null) return [];

    return config.landmarks.map((landmark) {
      // Scale landmark position to fit within bounds
      final x = bounds.left + 20 + (landmark.x / 700) * (bounds.width - 80);
      final y = bounds.top + 60 + (landmark.y / 450) * (bounds.height - 120);

      return Positioned(
        left: x,
        top: y,
        child: Tooltip(
          message: landmark.displayName,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: realm.accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: realm.accentColor.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _landmarkIcon(landmark.type),
                  color: realm.accentColor.withOpacity(0.5),
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  landmark.displayName,
                  style: GoogleFonts.quicksand(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: realm.accentColor.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  IconData _landmarkIcon(String type) {
    if (type.contains('temple') || type.contains('shrine')) {
      return Icons.temple_hindu_rounded;
    }
    if (type.contains('village') || type.contains('outpost')) {
      return Icons.holiday_village_rounded;
    }
    if (type.contains('tower') || type.contains('lighthouse')) {
      return Icons.cell_tower_rounded;
    }
    if (type.contains('palace') || type.contains('citadel')) {
      return Icons.castle_rounded;
    }
    if (type.contains('grove') ||
        type.contains('tree') ||
        type.contains('forest')) {
      return Icons.forest_rounded;
    }
    if (type.contains('hub') ||
        type.contains('plaza') ||
        type.contains('stage')) {
      return Icons.location_city_rounded;
    }
    if (type.contains('fountain') || type.contains('pool')) {
      return Icons.water_rounded;
    }
    return Icons.place_rounded;
  }

  // ─── Decorative Particles ───

  List<Widget> _buildParticles(RealmType realm, Rect bounds) {
    final random = Random(realm.index * 100);
    final count = 12;
    final color = realm.accentColor;

    return List.generate(count, (i) {
      final x = random.nextDouble() * (bounds.width - 40) + 10;
      final y = random.nextDouble() * (bounds.height - 40) + 30;
      final size = 2.0 + random.nextDouble() * 4;
      final opacity = 0.1 + random.nextDouble() * 0.2;

      return Positioned(
        left: x,
        top: y,
        child: AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            final scale =
                0.8 + 0.4 * sin(_pulseController.value * pi * 2 + i * 0.5);
            return Transform.scale(
              scale: scale,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: color.withOpacity(opacity),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(opacity * 0.5),
                      blurRadius: size * 2,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    });
  }

  // ─── Landmark Icons ───

  List<Widget> _buildLandmarks(RealmType realm, Rect bounds) {
    final icons = realm.landmarkIcons;
    final random = Random(realm.index * 200 + 50);
    final color = realm.accentColor;

    return List.generate(icons.length, (i) {
      final x = 60.0 + random.nextDouble() * (bounds.width - 160);
      final y = 80.0 + random.nextDouble() * (bounds.height - 160);

      return Positioned(
        left: x,
        top: y,
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withOpacity(0.15)),
          ),
          child: Icon(icons[i], color: color.withOpacity(0.35), size: 24),
        ),
      );
    });
  }

  // ─── Friend Marker ───

  Widget _buildFriendMarker(FriendMapMarker marker) {
    final zone = _realmZones[marker.realm]!;

    return Positioned(
      left: zone.left + marker.x,
      top: zone.top + marker.y,
      child: GestureDetector(
        onTap: () => _showFriendSheet(marker),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Avatar circle
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    marker.avatarColor,
                    marker.avatarColor.withOpacity(0.7),
                  ],
                ),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: marker.avatarColor.withOpacity(0.4),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  marker.initial,
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            // Name tag
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF0A0E21).withOpacity(0.85),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white12),
              ),
              child: Text(
                marker.name.split(' ').first,
                style: GoogleFonts.quicksand(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.white70,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── User "You Are Here" Marker ───

  Widget _buildUserMarker() {
    final zone = _realmZones[_userRealm]!;
    final x = zone.left + zone.width / 2 - 30;
    final y = zone.top + zone.height / 2 + 20;

    return Positioned(
      left: x,
      top: y,
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          final scale = 1.0 + 0.08 * sin(_pulseController.value * pi * 2);
          return Transform.scale(scale: scale, child: child);
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _userRealm.accentColor,
                    _userRealm.accentColor.withOpacity(0.6),
                  ],
                ),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: _userRealm.accentColor.withOpacity(0.5),
                    blurRadius: 20,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: const Center(
                child:
                    Icon(Icons.person_rounded, color: Colors.white, size: 26),
              ),
            ),
            const SizedBox(height: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _userRealm.accentColor.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10),
                border:
                    Border.all(color: _userRealm.accentColor.withOpacity(0.5)),
              ),
              child: Text(
                'YOU',
                style: GoogleFonts.outfit(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Minimap ───

  Widget _buildMinimap() {
    return Container(
      width: 120,
      height: 90,
      decoration: BoxDecoration(
        color: const Color(0xFF0A0E21).withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(11),
            child: CustomPaint(
              painter: _MinimapPainter(
                userRealm: _userRealm,
                friendMarkers: _friendMarkers,
                realmZones: _realmZones,
                canvasWidth: _canvasWidth,
                canvasHeight: _canvasHeight,
              ),
            ),
          ),
          // Tap hint icon
          Positioned(
            right: 4,
            bottom: 4,
            child: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(
                Icons.open_in_full_rounded,
                color: Colors.white54,
                size: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Legend ───

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0E21).withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: RealmType.values.map((realm) {
          final isHome = realm == _userRealm;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: realm.accentColor,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '${realm.emoji} ${realm.label}',
                  style: GoogleFonts.quicksand(
                    fontSize: 10,
                    fontWeight: isHome ? FontWeight.w700 : FontWeight.w500,
                    color: isHome ? realm.accentColor : Colors.white54,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ─── Minimap Overlay ───

  void _openMinimapOverlay() {
    // Count friends per realm
    final friendCounts = <RealmType, int>{};
    for (final marker in _friendMarkers) {
      friendCounts[marker.realm] = (friendCounts[marker.realm] ?? 0) + 1;
    }

    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, animation, secondaryAnimation) {
          return FadeTransition(
            opacity: animation,
            child: MinimapOverlay(
              userRealm: _userRealm,
              realmZones: _realmZones,
              friendCounts: friendCounts,
              canvasWidth: _canvasWidth,
              canvasHeight: _canvasHeight,
              travelsRemaining: _fastTravelService.travelsRemaining,
              onRealmTap: (destination) {
                Navigator.pop(context);
                _initiateTravel(destination);
              },
              onClose: () => Navigator.pop(context),
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 250),
      ),
    );
  }

  // ─── Fast Travel ───

  Future<void> _initiateTravel(RealmType destination) async {
    if (destination == _userRealm) {
      _showSnack('You are already in ${destination.label}');
      return;
    }

    final result = await _fastTravelService.recordTravel(destination);
    print(
        '[RealmMap] Travel result: success=${result.success}, msg=${result.message}');

    if (!result.success) {
      _showSnack(result.message);
      return;
    }

    setState(() {
      _showTravelAnimation = true;
      _travelDestination = destination;
    });
  }

  void _onTravelComplete() {
    if (!mounted) return;
    setState(() {
      _userRealm = _travelDestination ?? _userRealm;
      _showTravelAnimation = false;
      _travelDestination = null;
    });

    // Update presence
    final zone = _realmZones[_userRealm]!;
    _presenceService.updateMyPresence(
      realm: _userRealm,
      x: zone.width / 2,
      y: zone.height / 2,
    );
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF151830),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ─── Friend Bottom Sheet ───

  void _showFriendSheet(FriendMapMarker marker) {
    final friend = FriendsService().getFriend(marker.friendId);
    if (friend == null) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color(0xFF151830),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            // Friend info
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        marker.avatarColor,
                        marker.avatarColor.withOpacity(0.6),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      marker.initial,
                      style: GoogleFonts.outfit(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        marker.name,
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: marker.realm.accentColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${marker.realm.emoji} ${marker.realm.label}',
                            style: GoogleFonts.quicksand(
                              fontSize: 13,
                              color: marker.realm.accentColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Action buttons — now 3 across
            Row(
              children: [
                Expanded(
                  child: _actionButton(
                    icon: Icons.person_rounded,
                    label: 'Profile',
                    color: const Color(0xFF00d4ff),
                    onTap: () {
                      Navigator.pop(ctx);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FriendProfileScreen(friend: friend),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _actionButton(
                    icon: Icons.pets_rounded,
                    label: 'Visit Pet',
                    color: const Color(0xFFff6b9d),
                    onTap: () {
                      Navigator.pop(ctx);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PetInteractionScreen(friend: friend),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                // NEW: Visit Realm button
                Expanded(
                  child: _actionButton(
                    icon: Icons.flight_takeoff_rounded,
                    label: 'Visit Realm',
                    color: marker.realm.accentColor,
                    onTap: () {
                      Navigator.pop(ctx);
                      _initiateTravel(marker.realm);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Cooperative quote
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.04),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withOpacity(0.06)),
              ),
              child: Row(
                children: [
                  const Text('💬 ', style: TextStyle(fontSize: 16)),
                  Expanded(
                    child: Text(
                      _getMapDialogue(marker.realm),
                      style: GoogleFonts.quicksand(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: Colors.white54,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: MediaQuery.of(ctx).padding.bottom + 8),
          ],
        ),
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getMapDialogue(RealmType realm) {
    final dialogues = {
      RealmType.fire:
          "The ember glow is strong here. Your friend's pet is energized!",
      RealmType.water: "The currents are calm. A good time to connect.",
      RealmType.forest: "The ancient trees hum with shared energy.",
      RealmType.air: "High above the clouds, your friend dreams big.",
      RealmType.central:
          "The Central Land is lively today. Want to join the gathering?",
    };
    return dialogues[realm] ?? "Your friend's pet looks happy to see you!";
  }
}

// ─── Minimap Painter ───

class _MinimapPainter extends CustomPainter {
  final RealmType userRealm;
  final List<FriendMapMarker> friendMarkers;
  final Map<RealmType, Rect> realmZones;
  final double canvasWidth;
  final double canvasHeight;

  _MinimapPainter({
    required this.userRealm,
    required this.friendMarkers,
    required this.realmZones,
    required this.canvasWidth,
    required this.canvasHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / canvasWidth;
    final scaleY = size.height / canvasHeight;

    // Draw realm zones
    for (final entry in realmZones.entries) {
      final realm = entry.key;
      final zone = entry.value;
      final isHome = realm == userRealm;

      final rect = Rect.fromLTWH(
        zone.left * scaleX + 1,
        zone.top * scaleY + 1,
        zone.width * scaleX - 2,
        zone.height * scaleY - 2,
      );

      final paint = Paint()
        ..color = realm.accentColor.withOpacity(isHome ? 0.5 : 0.2)
        ..style = PaintingStyle.fill;

      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(3)),
        paint,
      );

      if (isHome) {
        final borderPaint = Paint()
          ..color = realm.accentColor.withOpacity(0.8)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(3)),
          borderPaint,
        );
      }
    }

    // Draw friend dots
    for (final marker in friendMarkers) {
      final zone = realmZones[marker.realm]!;
      final x = (zone.left + marker.x) * scaleX;
      final y = (zone.top + marker.y) * scaleY;

      canvas.drawCircle(
        Offset(x, y),
        2,
        Paint()..color = marker.avatarColor.withOpacity(0.8),
      );
    }

    // Draw user dot
    final userZone = realmZones[userRealm]!;
    final ux = (userZone.left + userZone.width / 2) * scaleX;
    final uy = (userZone.top + userZone.height / 2 + 20) * scaleY;
    canvas.drawCircle(
      Offset(ux, uy),
      3.5,
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
