/// Fast Travel Overlay — animated travel between realms.
///
/// 3-phase animation:
///   1. Zoom out (300ms)
///   2. Fly to destination (500ms)
///   3. Zoom in (300ms)
///
/// Displays pet emoji animating along the travel path,
/// destination realm name, and subtitle.

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/models/realm_models.dart';

class FastTravelOverlay extends StatefulWidget {
  final RealmType from;
  final RealmType to;
  final String travelMessage;
  final int travelsRemaining;
  final VoidCallback onComplete;

  const FastTravelOverlay({
    super.key,
    required this.from,
    required this.to,
    required this.travelMessage,
    required this.travelsRemaining,
    required this.onComplete,
  });

  @override
  State<FastTravelOverlay> createState() => _FastTravelOverlayState();
}

class _FastTravelOverlayState extends State<FastTravelOverlay>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _zoomOut;
  late Animation<double> _fly;
  late Animation<double> _zoomIn;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    // Phase 1: Zoom out (0.0 → 0.27)
    _zoomOut = Tween<double>(begin: 1.0, end: 0.4).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.27, curve: Curves.easeInCubic),
      ),
    );

    // Phase 2: Fly (0.27 → 0.73)
    _fly = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.27, 0.73, curve: Curves.easeInOutCubic),
      ),
    );

    // Phase 3: Zoom in (0.73 → 1.0)
    _zoomIn = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.73, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.8, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 400), widget.onComplete);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Material(
      color: Colors.transparent,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          // Current zoom level (combines zoom out and zoom in)
          final zoom = _controller.value < 0.5 ? _zoomOut.value : _zoomIn.value;

          // Background gradient transitions from source to destination
          final fromColors = widget.from.gradientColors;
          final toColors = widget.to.gradientColors;
          final t = _fly.value;
          final bgColor1 = Color.lerp(fromColors[0], toColors[0], t)!;
          final bgColor2 = Color.lerp(fromColors[1], toColors[1], t)!;
          final bgColor3 = Color.lerp(
              fromColors.length > 2 ? fromColors[2] : fromColors[1],
              toColors.length > 2 ? toColors[2] : toColors[1],
              t)!;

          return Container(
            width: size.width,
            height: size.height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [bgColor1, bgColor2, bgColor3],
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Animated star particles
                ..._buildStars(size, zoom),

                // Traveling pet emoji
                _buildTravelingPet(size),

                // Destination info (fades in at the end)
                Opacity(
                  opacity: _fadeIn.value,
                  child: _buildDestinationInfo(),
                ),

                // Progress indicator
                Positioned(
                  bottom: 60,
                  child: _buildProgressBar(size),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildStars(Size size, double zoom) {
    final rng = Random(42);
    return List.generate(20, (i) {
      final starX = rng.nextDouble() * size.width;
      final starY = rng.nextDouble() * size.height;
      final starSize = 1.5 + rng.nextDouble() * 3;

      // Stars stretch during flight
      final stretch = 1.0 + (1.0 - zoom) * 3;

      return Positioned(
        left: starX,
        top: starY,
        child: Transform.scale(
          scaleX: 1.0,
          scaleY: stretch,
          child: Container(
            width: starSize,
            height: starSize,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3 + _fly.value * 0.5),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.2),
                  blurRadius: starSize * 2,
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildTravelingPet(Size size) {
    // Pet moves from left to right during flight
    final x = 80 + _fly.value * (size.width - 160);
    // Slight arc trajectory
    final yOffset = sin(_fly.value * pi) * -60;
    final y = size.height * 0.4 + yOffset;

    // Pet bounces
    final bounce = sin(_controller.value * pi * 6) * 4;

    return Positioned(
      left: x - 24,
      top: y + bounce - 24,
      child: Transform.scale(
        scale: 1.2 + sin(_controller.value * pi * 4) * 0.15,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.to.emoji,
              style: const TextStyle(fontSize: 36),
            ),
            // Motion trail
            Container(
              width: 30,
              height: 3,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    widget.to.accentColor.withOpacity(0.0),
                    widget.to.accentColor.withOpacity(0.4),
                  ],
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDestinationInfo() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.to.emoji,
          style: const TextStyle(fontSize: 48),
        ),
        const SizedBox(height: 12),
        Text(
          widget.to.label,
          style: GoogleFonts.outfit(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          widget.to.subtitle,
          style: GoogleFonts.quicksand(
            fontSize: 14,
            color: Colors.white.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.15)),
          ),
          child: Text(
            widget.travelMessage,
            style: GoogleFonts.quicksand(
              fontSize: 12,
              color: Colors.white70,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar(Size size) {
    return Container(
      width: size.width * 0.5,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(2),
      ),
      child: FractionallySizedBox(
        widthFactor: _controller.value,
        alignment: Alignment.centerLeft,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                widget.from.accentColor,
                widget.to.accentColor,
              ],
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}
