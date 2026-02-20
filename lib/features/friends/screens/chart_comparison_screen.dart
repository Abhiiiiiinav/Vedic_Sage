import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../app/theme.dart';
import '../../../core/astro/compatibility_engine.dart';
import '../../../core/astro/kundali_engine.dart';
import '../../../core/models/friend_model.dart';
import '../../../core/services/user_session.dart';

class ChartComparisonScreen extends StatefulWidget {
  final FriendProfile friend;

  const ChartComparisonScreen({super.key, required this.friend});

  @override
  State<ChartComparisonScreen> createState() => _ChartComparisonScreenState();
}

class _ChartComparisonScreenState extends State<ChartComparisonScreen> {
  KundaliResult? _userChart;
  KundaliResult? _friendChart;
  List<PlanetComparison>? _comparisons;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _calculateCharts();
  }

  void _calculateCharts() {
    try {
      // User chart
      final session = UserSession();
      final userDetails = session.birthDetails;
      if (userDetails == null) {
        setState(() {
          _error =
              'Your birth chart is not available. Please generate it first.';
          _isLoading = false;
        });
        return;
      }

      _userChart = KundaliEngine.calculateChart(
        birthTime: userDetails.birthDateTime,
        latitude: userDetails.latitude,
        longitude: userDetails.longitude,
        timezoneOffset: userDetails.timezoneOffset,
      );

      // Friend chart
      _friendChart = KundaliEngine.calculateChart(
        birthTime: widget.friend.dateOfBirth,
        latitude: widget.friend.latitude,
        longitude: widget.friend.longitude,
        timezoneOffset: widget.friend.timezoneOffset,
      );

      _comparisons = CompatibilityEngine.generateReport(
        chart1: _userChart!,
        chart2: _friendChart!,
        name1: userDetails.name,
        name2: widget.friend.name,
      ).planetComparisons;

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _error = 'Error calculating charts: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AstroTheme.scaffoldBackground,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 100,
            pinned: true,
            backgroundColor: AstroTheme.scaffoldBackground,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white70, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Compare Charts',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AstroTheme.accentCyan.withOpacity(0.25),
                      const Color(0xFF764ba2).withOpacity(0.15),
                      AstroTheme.scaffoldBackground,
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(
                    color: Color(0xFF667eea), strokeWidth: 2.5),
              ),
            )
          else if (_error != null)
            SliverFillRemaining(
              child: _buildError(),
            )
          else ...[
            // Names header
            SliverToBoxAdapter(child: _buildNamesHeader()),

            // Ascendant comparison
            SliverToBoxAdapter(child: _buildAscendantRow()),

            // Section label
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                child: Text(
                  'PLANETARY POSITIONS',
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AstroTheme.accentGold.withOpacity(0.7),
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),

            // Planet table
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) => _buildPlanetRow(_comparisons![i]),
                  childCount: _comparisons!.length,
                ),
              ),
            ),

            // Quick stats
            SliverToBoxAdapter(child: _buildQuickStats()),

            // Element comparison
            SliverToBoxAdapter(child: _buildElementComparison()),

            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ],
      ),
    );
  }

  // ══════════════════════════════════════
  // WIDGETS
  // ══════════════════════════════════════

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded,
                color: Colors.amber.shade300, size: 56),
            const SizedBox(height: 16),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: GoogleFonts.quicksand(
                  color: Colors.white60, fontSize: 15, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNamesHeader() {
    final userName = UserSession().birthDetails?.name ?? 'You';
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        child: Row(
          children: [
            // Person 1
            Expanded(
              child: Column(
                children: [
                  _buildAvatar(userName, AstroTheme.accentCyan),
                  const SizedBox(height: 8),
                  Text(
                    userName,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AstroTheme.accentCyan,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // VS
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF667eea).withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'VS',
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF667eea),
                  letterSpacing: 2,
                ),
              ),
            ),

            // Person 2
            Expanded(
              child: Column(
                children: [
                  _buildAvatar(widget.friend.name, AstroTheme.accentPink),
                  const SizedBox(height: 8),
                  Text(
                    widget.friend.name,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AstroTheme.accentPink,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(String name, Color color) {
    final parts = name.trim().split(' ');
    final initials = parts.length >= 2
        ? '${parts.first[0]}${parts.last[0]}'.toUpperCase()
        : name.isNotEmpty
            ? name[0].toUpperCase()
            : '?';
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Center(
        child: Text(
          initials,
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }

  Widget _buildAscendantRow() {
    final asc1 = _userChart!.ascendant['signName'] as String? ?? '—';
    final asc2 = _friendChart!.ascendant['signName'] as String? ?? '—';
    final same = asc1 == asc2 && asc1 != '—';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF667eea).withOpacity(0.1),
              const Color(0xFF764ba2).withOpacity(0.08),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: same
                ? AstroTheme.accentGreen.withOpacity(0.4)
                : const Color(0xFF667eea).withOpacity(0.15),
          ),
        ),
        child: Row(
          children: [
            const Text('🔱', style: TextStyle(fontSize: 22)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ascendant (Lagna)',
                    style: GoogleFonts.quicksand(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white38,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(asc1,
                          style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AstroTheme.accentCyan)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Icon(
                          same ? Icons.link : Icons.compare_arrows_rounded,
                          size: 16,
                          color: same ? AstroTheme.accentGreen : Colors.white24,
                        ),
                      ),
                      Text(asc2,
                          style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AstroTheme.accentPink)),
                    ],
                  ),
                ],
              ),
            ),
            if (same)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AstroTheme.accentGreen.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('Match!',
                    style: TextStyle(
                        color: AstroTheme.accentGreen,
                        fontSize: 11,
                        fontWeight: FontWeight.bold)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanetRow(PlanetComparison comp) {
    final emoji = _planetEmoji(comp.planet);
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: comp.sameSign
            ? AstroTheme.accentGreen.withOpacity(0.06)
            : Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: comp.sameSign
              ? AstroTheme.accentGreen.withOpacity(0.2)
              : Colors.white.withOpacity(0.04),
        ),
      ),
      child: Row(
        children: [
          // Planet
          SizedBox(
            width: 80,
            child: Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 6),
                Text(
                  comp.planet,
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),

          // Person 1 sign + house
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  comp.person1Sign,
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AstroTheme.accentCyan,
                  ),
                ),
                Text(
                  'H${comp.person1House}',
                  style: TextStyle(fontSize: 10, color: Colors.white24),
                ),
              ],
            ),
          ),

          // Match indicator
          Icon(
            comp.sameSign ? Icons.check_circle : Icons.remove,
            size: 16,
            color: comp.sameSign ? AstroTheme.accentGreen : Colors.white12,
          ),

          // Person 2 sign + house
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  comp.person2Sign,
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AstroTheme.accentPink,
                  ),
                ),
                Text(
                  'H${comp.person2House}',
                  style: TextStyle(fontSize: 10, color: Colors.white24),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    final sharedCount = _comparisons!.where((c) => c.sameSign).length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStat('$sharedCount', 'Shared\nSigns', AstroTheme.accentGreen),
            _buildStat(
              '${_comparisons!.length - sharedCount}',
              'Different\nSigns',
              Colors.white38,
            ),
            _buildStat(
              '${(sharedCount / _comparisons!.length * 100).round()}%',
              'Sign\nMatch',
              AstroTheme.accentGold,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.outfit(
              fontSize: 24, fontWeight: FontWeight.bold, color: color),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.quicksand(
              fontSize: 10, color: Colors.white38, height: 1.3),
        ),
      ],
    );
  }

  Widget _buildElementComparison() {
    final elem1 = CompatibilityEngine.generateReport(
      chart1: _userChart!,
      chart2: _friendChart!,
      name1: 'You',
      name2: widget.friend.name,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ELEMENT BALANCE',
              style: GoogleFonts.outfit(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AstroTheme.accentGold.withOpacity(0.7),
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            _buildElementRow('🔥', 'Fire', elem1.person1Elements.fire,
                elem1.person2Elements.fire, Colors.redAccent),
            const SizedBox(height: 10),
            _buildElementRow('🌍', 'Earth', elem1.person1Elements.earth,
                elem1.person2Elements.earth, Colors.green),
            const SizedBox(height: 10),
            _buildElementRow('💨', 'Air', elem1.person1Elements.air,
                elem1.person2Elements.air, Colors.lightBlueAccent),
            const SizedBox(height: 10),
            _buildElementRow('💧', 'Water', elem1.person1Elements.water,
                elem1.person2Elements.water, Colors.blueAccent),
          ],
        ),
      ),
    );
  }

  Widget _buildElementRow(
      String emoji, String label, int val1, int val2, Color color) {
    final maxVal = 9; // 9 planets max
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 8),
        SizedBox(
          width: 40,
          child: Text(label,
              style:
                  GoogleFonts.quicksand(fontSize: 11, color: Colors.white38)),
        ),
        const SizedBox(width: 8),
        // Person 1 bar
        Expanded(
          child: Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              FractionallySizedBox(
                widthFactor: val1 / maxVal,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: AstroTheme.accentCyan.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Text('$val1 | $val2',
              style: GoogleFonts.jetBrainsMono(
                  fontSize: 10, color: Colors.white38)),
        ),
        // Person 2 bar
        Expanded(
          child: Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              FractionallySizedBox(
                widthFactor: val2 / maxVal,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: AstroTheme.accentPink.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _planetEmoji(String planet) {
    const emojis = {
      'Sun': '☀️',
      'Moon': '🌙',
      'Mars': '♂️',
      'Mercury': '☿️',
      'Jupiter': '♃',
      'Venus': '♀️',
      'Saturn': '♄',
      'Rahu': '🐉',
      'Ketu': '🌀',
    };
    return emojis[planet] ?? '⭐';
  }
}
