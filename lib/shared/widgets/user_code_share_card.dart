import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app/theme.dart';

/// User Code Share Card — "Your Cosmic Code" shareable profile.
///
/// Shows Ascendant, Sun sign, Moon sign + Nakshatra, key planetary placements,
/// and element balance in a premium 9:16 story-format card.
class UserCodeShareCard extends StatelessWidget {
  final Map<String, dynamic> chartData;
  final String userName;

  const UserCodeShareCard({
    super.key,
    required this.chartData,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    // Extract data
    final ascSign = chartData['ascSign'] as String? ?? 'Unknown';
    final apiExtracted =
        chartData['apiExtracted'] as Map<String, dynamic>? ?? {};

    // Key planets
    final sun = apiExtracted['Sun'] as Map<String, dynamic>?;
    final moon = apiExtracted['Moon'] as Map<String, dynamic>?;
    final mars = apiExtracted['Mars'] as Map<String, dynamic>?;
    final venus = apiExtracted['Venus'] as Map<String, dynamic>?;
    final jupiter = apiExtracted['Jupiter'] as Map<String, dynamic>?;
    final saturn = apiExtracted['Saturn'] as Map<String, dynamic>?;

    // Element balance
    final elements = _countElements(apiExtracted);

    return SizedBox(
      width: 360,
      height: 640,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0D0D2B),
              Color(0xFF15103A),
              Color(0xFF0A1628),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Header ──
              _buildHeader(),
              const SizedBox(height: 18),

              // ── Title ──
              Text(
                'Your Cosmic Code',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                userName,
                style: GoogleFonts.quicksand(
                  color: AstroTheme.accentGold,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),

              // ── Ascendant Hero ──
              _buildAscendantHero(ascSign),
              const SizedBox(height: 18),

              // ── Key Placements Grid ──
              _buildPlacementRow('☉ Sun', sun),
              const SizedBox(height: 6),
              _buildPlacementRow('☽ Moon', moon),
              const SizedBox(height: 6),
              _buildPlacementRow('♂ Mars', mars),
              const SizedBox(height: 6),
              _buildPlacementRow('♀ Venus', venus),
              const SizedBox(height: 6),
              _buildPlacementRow('♃ Jupiter', jupiter),
              const SizedBox(height: 6),
              _buildPlacementRow('♄ Saturn', saturn),

              const SizedBox(height: 18),

              // ── Moon Nakshatra ──
              if (moon != null && moon['nakshatra'] != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AstroTheme.accentCyan.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AstroTheme.accentCyan.withOpacity(0.2)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('🌙', style: TextStyle(fontSize: 14)),
                      const SizedBox(width: 8),
                      Text(
                        'Moon Nakshatra: ${moon['nakshatra']}',
                        style: GoogleFonts.outfit(
                          color: AstroTheme.accentCyan,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (moon['nakshatraPada'] != null)
                        Text(
                          ' (Pada ${moon['nakshatraPada']})',
                          style: GoogleFonts.quicksand(
                            color: AstroTheme.accentCyan.withOpacity(0.6),
                            fontSize: 11,
                          ),
                        ),
                    ],
                  ),
                ),

              const SizedBox(height: 14),

              // ── Element Balance ──
              _buildElementBar(elements),

              const Spacer(),

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
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            gradient: AstroTheme.primaryGradient,
            borderRadius: BorderRadius.circular(7),
          ),
          child: const Center(
            child: Text('✨', style: TextStyle(fontSize: 14)),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'AstroLearn',
          style: GoogleFonts.outfit(
            color: AstroTheme.accentGold,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildAscendantHero(String ascSign) {
    final symbol = _signSymbol(ascSign);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AstroTheme.accentPurple.withOpacity(0.15),
            AstroTheme.accentGold.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AstroTheme.accentPurple.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(symbol, style: const TextStyle(fontSize: 32)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ascendant',
                style: GoogleFonts.quicksand(
                  color: Colors.white54,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                ascSign,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlacementRow(String label, Map<String, dynamic>? data) {
    final sign = data?['sign'] as String? ?? '—';
    final house = data?['house'];
    final isRetro = data?['isRetrograde'] == true;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: GoogleFonts.outfit(
                color: Colors.white70,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              sign,
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (house != null)
            Text(
              'H$house',
              style: GoogleFonts.outfit(
                color: AstroTheme.accentPurple.withOpacity(0.8),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          if (isRetro)
            Padding(
              padding: const EdgeInsets.only(left: 6),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: const Text('R',
                    style: TextStyle(
                        color: Colors.red,
                        fontSize: 9,
                        fontWeight: FontWeight.bold)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildElementBar(Map<String, int> elements) {
    final total = elements.values.fold(0, (a, b) => a + b).clamp(1, 999);
    const colors = {
      'Fire': Color(0xFFFF6B35),
      'Earth': Color(0xFF4CAF50),
      'Air': Color(0xFF42A5F5),
      'Water': Color(0xFF7E57C2),
    };

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: elements.entries.map((e) {
          final ratio = e.value / total;
          final color = colors[e.key] ?? Colors.grey;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Column(
                children: [
                  Text(
                    _elementEmoji(e.key),
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: ratio,
                      backgroundColor: Colors.white10,
                      valueColor: AlwaysStoppedAnimation(color),
                      minHeight: 5,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${e.key}\n${e.value}',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.quicksand(
                      color: color.withOpacity(0.8),
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(height: 1, width: 40, color: Colors.white12),
        const SizedBox(width: 10),
        Text(
          'AstroLearn • Discover Your Stars',
          style: GoogleFonts.quicksand(
            color: Colors.white30,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 10),
        Container(height: 1, width: 40, color: Colors.white12),
      ],
    );
  }

  // ── Helpers ──

  Map<String, int> _countElements(Map<String, dynamic> extracted) {
    final counts = {'Fire': 0, 'Earth': 0, 'Air': 0, 'Water': 0};
    const signElements = {
      'Aries': 'Fire',
      'Leo': 'Fire',
      'Sagittarius': 'Fire',
      'Taurus': 'Earth',
      'Virgo': 'Earth',
      'Capricorn': 'Earth',
      'Gemini': 'Air',
      'Libra': 'Air',
      'Aquarius': 'Air',
      'Cancer': 'Water',
      'Scorpio': 'Water',
      'Pisces': 'Water',
    };

    for (final entry in extracted.entries) {
      if (entry.value is Map<String, dynamic>) {
        final sign = (entry.value as Map<String, dynamic>)['sign'] as String?;
        if (sign != null && signElements.containsKey(sign)) {
          counts[signElements[sign]!] = (counts[signElements[sign]!] ?? 0) + 1;
        }
      }
    }
    return counts;
  }

  String _signSymbol(String sign) {
    const symbols = {
      'Aries': '♈',
      'Taurus': '♉',
      'Gemini': '♊',
      'Cancer': '♋',
      'Leo': '♌',
      'Virgo': '♍',
      'Libra': '♎',
      'Scorpio': '♏',
      'Sagittarius': '♐',
      'Capricorn': '♑',
      'Aquarius': '♒',
      'Pisces': '♓',
    };
    return symbols[sign] ?? '🌟';
  }

  String _elementEmoji(String element) {
    switch (element) {
      case 'Fire':
        return '🔥';
      case 'Earth':
        return '🌿';
      case 'Air':
        return '💨';
      case 'Water':
        return '🌊';
      default:
        return '✨';
    }
  }
}
