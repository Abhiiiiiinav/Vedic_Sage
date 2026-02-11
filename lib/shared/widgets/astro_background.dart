import 'package:flutter/material.dart';
import '../../app/theme.dart';

class AstroBackground extends StatelessWidget {
  final Widget child;

  const AstroBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Container(
        decoration: const BoxDecoration(
          gradient: AstroTheme.cosmicGradient,
        ),
        child: Stack(
          children: [
            // Ambient Glow Orbs (Premium Touch)
            Positioned(
              top: -100,
              right: -50,
              child: _buildGlowOrb(AstroTheme.accentPurple, 250),
            ),
            Positioned(
              bottom: 100,
              left: -80,
              child: _buildGlowOrb(AstroTheme.accentCyan, 200),
            ),
            
            // The actual content
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildGlowOrb(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.05),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 100,
            spreadRadius: 40,
          )
        ],
      ),
    );
  }
}
