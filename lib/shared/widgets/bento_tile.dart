import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum BentoTileSize { regular, hero }

class BentoTile extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  /// Accent color used ONLY for icon and title text, not the card background.
  final Color accentColor;
  final VoidCallback onTap;
  final BentoTileSize size;

  const BentoTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.accentColor = const Color(0xFF667eea),
    this.size = BentoTileSize.regular,
  });

  @override
  State<BentoTile> createState() => _BentoTileState();
}

class _BentoTileState extends State<BentoTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isHero = widget.size == BentoTileSize.hero;

    return ScaleTransition(
      scale: _scaleAnim,
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) {
          _controller.reverse();
          widget.onTap();
        },
        onTapCancel: () => _controller.reverse(),
        child: Container(
          padding: EdgeInsets.all(isHero ? 20 : 16),
          decoration: BoxDecoration(
            // Neutral dark card — no color fill
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1e1e38), Color(0xFF16162a)],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.08),
              width: 1,
            ),
          ),
          child: isHero ? _buildHeroLayout() : _buildRegularLayout(),
        ),
      ),
    );
  }

  /// Hero tile: horizontal layout — icon left, text right
  Widget _buildHeroLayout() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: widget.accentColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            widget.icon,
            color: widget.accentColor,
            size: 32,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.title,
                style: GoogleFonts.outfit(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: widget.accentColor,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.subtitle,
                style: GoogleFonts.quicksand(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.white54,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        Icon(
          Icons.arrow_forward_ios_rounded,
          color: Colors.white24,
          size: 18,
        ),
      ],
    );
  }

  /// Regular tile: vertical layout — icon top, text bottom
  Widget _buildRegularLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Icon with tinted circle
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: widget.accentColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            widget.icon,
            color: widget.accentColor,
            size: 24,
          ),
        ),
        // Title (colored) + Subtitle (neutral)
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: GoogleFonts.outfit(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: widget.accentColor,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              widget.subtitle,
              style: GoogleFonts.quicksand(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.white54,
                height: 1.3,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ],
    );
  }
}
