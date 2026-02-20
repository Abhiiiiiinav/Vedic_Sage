/// Minimap Overlay — fullscreen expanded minimap for fast travel.
///
/// Shows a complete overview of all realms with:
///   - Tappable realm zones that trigger fast travel
///   - User position indicator (glowing dot)
///   - Friend clusters with count badges
///   - Remaining travels counter
///   - Close button

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/models/realm_models.dart';
import '../../../core/services/fast_travel_service.dart';

class MinimapOverlay extends StatelessWidget {
  final RealmType userRealm;
  final Map<RealmType, Rect> realmZones;
  final Map<RealmType, int> friendCounts;
  final double canvasWidth;
  final double canvasHeight;
  final int travelsRemaining;
  final void Function(RealmType destination) onRealmTap;
  final VoidCallback onClose;

  const MinimapOverlay({
    super.key,
    required this.userRealm,
    required this.realmZones,
    required this.friendCounts,
    required this.canvasWidth,
    required this.canvasHeight,
    required this.travelsRemaining,
    required this.onRealmTap,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black87,
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            const SizedBox(height: 12),
            Expanded(child: _buildMap(context)),
            const SizedBox(height: 12),
            _buildTravelCounter(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: onClose,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white12),
              ),
              child: const Icon(Icons.close, color: Colors.white70, size: 20),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'World Map',
              style: GoogleFonts.outfit(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  userRealm.accentColor.withOpacity(0.3),
                  userRealm.accentColor.withOpacity(0.15),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: userRealm.accentColor.withOpacity(0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.location_on, color: userRealm.accentColor, size: 14),
                const SizedBox(width: 4),
                Text(
                  userRealm.label,
                  style: GoogleFonts.quicksand(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: userRealm.accentColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMap(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width - 40;
    final aspectRatio = canvasWidth / canvasHeight;
    final mapHeight = screenWidth / aspectRatio;

    return Center(
      child: Container(
        width: screenWidth,
        height:
            mapHeight.clamp(200.0, MediaQuery.of(context).size.height * 0.65),
        decoration: BoxDecoration(
          color: const Color(0xFF0A0E21),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 30,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(19),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final scaleX = constraints.maxWidth / canvasWidth;
              final scaleY = constraints.maxHeight / canvasHeight;

              return Stack(
                children: [
                  // Realm zones
                  ...realmZones.entries.map((entry) {
                    final realm = entry.key;
                    final zone = entry.value;
                    final isHome = realm == userRealm;
                    final count = friendCounts[realm] ?? 0;

                    return Positioned(
                      left: zone.left * scaleX + 3,
                      top: zone.top * scaleY + 3,
                      width: zone.width * scaleX - 6,
                      height: zone.height * scaleY - 6,
                      child: GestureDetector(
                        onTap: () => onRealmTap(realm),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                realm.gradientColors[0].withOpacity(0.6),
                                realm.gradientColors[1].withOpacity(0.4),
                              ],
                            ),
                            border: Border.all(
                              color: isHome
                                  ? realm.accentColor.withOpacity(0.7)
                                  : Colors.white.withOpacity(0.15),
                              width: isHome ? 2 : 1,
                            ),
                            boxShadow: isHome
                                ? [
                                    BoxShadow(
                                      color: realm.accentColor.withOpacity(0.2),
                                      blurRadius: 12,
                                    )
                                  ]
                                : null,
                          ),
                          child: Stack(
                            children: [
                              // Realm label
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(realm.emoji,
                                            style:
                                                const TextStyle(fontSize: 14)),
                                        const SizedBox(width: 4),
                                        Flexible(
                                          child: Text(
                                            realm.label,
                                            style: GoogleFonts.outfit(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                              color:
                                                  Colors.white.withOpacity(0.9),
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (isHome)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 2),
                                        child: Text(
                                          '📍 You are here',
                                          style: GoogleFonts.quicksand(
                                            fontSize: 9,
                                            color: realm.accentColor,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              // Friend count badge
                              if (count > 0)
                                Positioned(
                                  right: 6,
                                  bottom: 6,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.people_rounded,
                                            color: Colors.white54, size: 10),
                                        const SizedBox(width: 3),
                                        Text(
                                          '$count',
                                          style: GoogleFonts.outfit(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white60,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              // Tap feedback text
                              if (!isHome)
                                Positioned(
                                  right: 6,
                                  top: 6,
                                  child: Icon(
                                    Icons.flight_takeoff_rounded,
                                    color: Colors.white.withOpacity(0.2),
                                    size: 14,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTravelCounter() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.flight_rounded, color: Colors.white54, size: 18),
          const SizedBox(width: 10),
          Text(
            'Travels remaining: ',
            style: GoogleFonts.quicksand(
              fontSize: 13,
              color: Colors.white54,
            ),
          ),
          Text(
            '$travelsRemaining',
            style: GoogleFonts.outfit(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: travelsRemaining > 0
                  ? const Color(0xFF69F0AE)
                  : const Color(0xFFff6b9d),
            ),
          ),
          Text(
            ' • Central always free',
            style: GoogleFonts.quicksand(
              fontSize: 11,
              color: Colors.white30,
            ),
          ),
        ],
      ),
    );
  }
}
