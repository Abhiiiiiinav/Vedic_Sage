import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../app/theme.dart';
import '../../../core/astro/compatibility_engine.dart';
import '../../../core/astro/kundali_engine.dart';
import '../../../core/models/friend_model.dart';
import '../../../core/services/user_session.dart';

class CompatibilityReportScreen extends StatefulWidget {
  final FriendProfile friend;

  const CompatibilityReportScreen({super.key, required this.friend});

  @override
  State<CompatibilityReportScreen> createState() =>
      _CompatibilityReportScreenState();
}

class _CompatibilityReportScreenState extends State<CompatibilityReportScreen>
    with SingleTickerProviderStateMixin {
  CompatibilityReport? _report;
  bool _isLoading = true;
  String? _error;
  late AnimationController _scoreAnimCtrl;
  late Animation<double> _scoreAnim;

  @override
  void initState() {
    super.initState();
    _scoreAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _scoreAnim = CurvedAnimation(
      parent: _scoreAnimCtrl,
      curve: Curves.easeOutCubic,
    );
    _calculate();
  }

  @override
  void dispose() {
    _scoreAnimCtrl.dispose();
    super.dispose();
  }

  void _calculate() {
    try {
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

      final userChart = KundaliEngine.calculateChart(
        birthTime: userDetails.birthDateTime,
        latitude: userDetails.latitude,
        longitude: userDetails.longitude,
        timezoneOffset: userDetails.timezoneOffset,
      );

      final friendChart = KundaliEngine.calculateChart(
        birthTime: widget.friend.dateOfBirth,
        latitude: widget.friend.latitude,
        longitude: widget.friend.longitude,
        timezoneOffset: widget.friend.timezoneOffset,
      );

      _report = CompatibilityEngine.generateReport(
        chart1: userChart,
        chart2: friendChart,
        name1: userDetails.name,
        name2: widget.friend.name,
      );

      setState(() => _isLoading = false);
      _scoreAnimCtrl.forward();
    } catch (e) {
      setState(() {
        _error = 'Error generating report: $e';
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
                'Compatibility',
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
                      AstroTheme.accentPink.withOpacity(0.25),
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
                    color: AstroTheme.accentPink, strokeWidth: 2.5),
              ),
            )
          else if (_error != null)
            SliverFillRemaining(child: _buildError())
          else ...[
            // Score ring + Names
            SliverToBoxAdapter(child: _buildScoreHeader()),

            // Verdict
            SliverToBoxAdapter(child: _buildVerdict()),

            // Section label
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
                child: Text(
                  'ASHTAKOOT GUNA MILAN',
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AstroTheme.accentGold.withOpacity(0.7),
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),

            // 8 Guna cards
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) => _buildGunaCard(_report!.gunas[i], i),
                  childCount: _report!.gunas.length,
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ],
      ),
    );
  }

  // ════════════════════════════════════════
  // WIDGETS
  // ════════════════════════════════════════

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
            Text(_error!,
                textAlign: TextAlign.center,
                style: GoogleFonts.quicksand(
                    color: Colors.white60, fontSize: 15, height: 1.5)),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreHeader() {
    final r = _report!;
    final gradeColor = _gradeColor(r.grade);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        child: Column(
          children: [
            // Names row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  r.person1Name,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AstroTheme.accentCyan,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text('💕', style: const TextStyle(fontSize: 16)),
                ),
                Text(
                  r.person2Name,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AstroTheme.accentPink,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Animated score ring
            AnimatedBuilder(
              animation: _scoreAnim,
              builder: (ctx, _) {
                final currentScore = r.totalScore * _scoreAnim.value;
                return SizedBox(
                  width: 160,
                  height: 160,
                  child: CustomPaint(
                    painter: _ScoreRingPainter(
                      progress: currentScore / r.maxScore,
                      color: gradeColor,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            r.grade,
                            style: GoogleFonts.outfit(
                              fontSize: 36,
                              fontWeight: FontWeight.w800,
                              color: gradeColor,
                            ),
                          ),
                          Text(
                            '${currentScore.toStringAsFixed(0)}/${r.maxScore.toInt()}',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 14,
                              color: Colors.white38,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 16),
            Text(
              '${r.percentage.round()}% Compatibility',
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: gradeColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerdict() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AstroTheme.accentPink.withOpacity(0.08),
              const Color(0xFF764ba2).withOpacity(0.06),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AstroTheme.accentPink.withOpacity(0.15)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('🔮', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _report!.verdict,
                style: GoogleFonts.quicksand(
                  fontSize: 13,
                  color: Colors.white60,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGunaCard(GunaScore guna, int index) {
    final progress = guna.maximum > 0 ? guna.earned / guna.maximum : 0.0;
    final color = progress >= 0.7
        ? AstroTheme.accentGreen
        : progress >= 0.3
            ? AstroTheme.accentGold
            : AstroTheme.accentPink;

    final icons = ['🕉️', '🧲', '⭐', '🐾', '🧠', '🎭', '💫', '🩺'];

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icons[index], style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      guna.name,
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      guna.description,
                      style: GoogleFonts.quicksand(
                          fontSize: 11, color: Colors.white30),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${guna.earned.toStringAsFixed(0)}/${guna.maximum.toInt()}',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withOpacity(0.06),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 5,
            ),
          ),

          const SizedBox(height: 10),

          // Interpretation
          Text(
            guna.interpretation,
            style: GoogleFonts.quicksand(
              fontSize: 12,
              color: Colors.white54,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Color _gradeColor(String grade) {
    switch (grade) {
      case 'A+':
        return AstroTheme.accentGreen;
      case 'A':
        return const Color(0xFF00C853);
      case 'B':
        return AstroTheme.accentGold;
      case 'C':
        return Colors.orange;
      case 'D':
        return Colors.deepOrange;
      default:
        return AstroTheme.accentPink;
    }
  }
}

// ════════════════════════════════════════════════════════════
// SCORE RING PAINTER
// ════════════════════════════════════════════════════════════

class _ScoreRingPainter extends CustomPainter {
  final double progress;
  final Color color;

  _ScoreRingPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    const strokeWidth = 10.0;

    // Track
    final trackPaint = Paint()
      ..color = Colors.white.withOpacity(0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      progressPaint,
    );

    // Glow effect
    final glowPaint = Paint()
      ..color = color.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth + 6
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      glowPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ScoreRingPainter old) =>
      old.progress != progress || old.color != color;
}
