import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app/theme.dart';
import '../../core/models/cosmic_pet_models.dart';

/// SWOT Share Card — Premium 9:16 story-format card for sharing Daily SWOT.
///
/// Wrap in a RepaintBoundary with a GlobalKey, then use ShareCardService
/// to capture and share.
class SWOTShareCard extends StatelessWidget {
  final DailySWOT swot;
  final String userName;

  const SWOTShareCard({
    super.key,
    required this.swot,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    // Fixed 9:16 story dimensions (rendered off-screen, captured at 3x)
    return SizedBox(
      width: 360,
      height: 640,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0D0D2B),
              Color(0xFF1A1040),
              Color(0xFF0F1023),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──
              _buildHeader(),
              const SizedBox(height: 20),

              // ── Title ──
              Text(
                'Daily Cosmic SWOT',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${_formatDate(swot.date)} • $userName',
                style: GoogleFonts.quicksand(
                  color: Colors.white54,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),

              // ── SWOT Grid ──
              Expanded(child: _buildSWOTGrid()),

              const SizedBox(height: 16),

              // ── Footer ──
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            gradient: AstroTheme.primaryGradient,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: Text('✨', style: TextStyle(fontSize: 16)),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'AstroLearn',
          style: GoogleFonts.outfit(
            color: AstroTheme.accentGold,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildSWOTGrid() {
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: _quadrant(
                  title: 'Strengths',
                  emoji: '💪',
                  items: swot.strengths,
                  color: AstroTheme.accentGreen,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _quadrant(
                  title: 'Weaknesses',
                  emoji: '⚠️',
                  items: swot.weaknesses,
                  color: AstroTheme.accentGold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: _quadrant(
                  title: 'Opportunities',
                  emoji: '🌟',
                  items: swot.opportunities,
                  color: AstroTheme.accentCyan,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _quadrant(
                  title: 'Threats',
                  emoji: '🛡️',
                  items: swot.threats,
                  color: AstroTheme.accentPink,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _quadrant({
    required String title,
    required String emoji,
    required List<SWOTItem> items,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 13)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.outfit(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ...items.take(3).map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.text,
                      style: GoogleFonts.quicksand(
                        color: Colors.white70,
                        fontSize: 10,
                        height: 1.3,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${item.sourceEmoji} ${item.source}',
                      style: GoogleFonts.quicksand(
                        color: Colors.white30,
                        fontSize: 8,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: 1,
          width: 40,
          color: Colors.white12,
        ),
        const SizedBox(width: 10),
        Text(
          'AstroLearn • Your Cosmic Code',
          style: GoogleFonts.quicksand(
            color: Colors.white30,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 10),
        Container(
          height: 1,
          width: 40,
          color: Colors.white12,
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
