import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../app/theme.dart';
import '../../../shared/widgets/animated_cosmic_background.dart';
import '../../../core/services/user_session.dart';
import '../../../core/services/chart_api_service.dart' as api;

import '../widgets/svg_chart_viewer.dart';

/// ─── Chart Gallery ───
/// Shows all 16 Parashara divisional charts in a scrollable grid.
/// Tapping any card opens a full-screen detail view with the rendered chart.
class ChartGalleryScreen extends StatefulWidget {
  const ChartGalleryScreen({super.key});

  @override
  State<ChartGalleryScreen> createState() => _ChartGalleryScreenState();
}

class _ChartGalleryScreenState extends State<ChartGalleryScreen> {
  bool _isLoading = true;
  String? _errorMessage;

  // ─── Chart Metadata ───
  static const List<ChartInfo> _charts = [
    ChartInfo(
        key: 'd1',
        name: 'D1',
        fullName: 'Rasi',
        desc: 'Birth chart — foundation of all analysis',
        icon: '🌟',
        color: Color(0xFF667eea)),
    ChartInfo(
        key: 'd2',
        name: 'D2',
        fullName: 'Hora',
        desc: 'Wealth & financial prosperity',
        icon: '💰',
        color: Color(0xFFf5a623)),
    ChartInfo(
        key: 'd3',
        name: 'D3',
        fullName: 'Drekkana',
        desc: 'Siblings, courage & initiative',
        icon: '👥',
        color: Color(0xFF00d4ff)),
    ChartInfo(
        key: 'd4',
        name: 'D4',
        fullName: 'Chaturthamsa',
        desc: 'Property & fixed assets',
        icon: '🏠',
        color: Color(0xFF34c759)),
    ChartInfo(
        key: 'd7',
        name: 'D7',
        fullName: 'Saptamsa',
        desc: 'Children & creativity',
        icon: '👶',
        color: Color(0xFFff6b9d)),
    ChartInfo(
        key: 'd9',
        name: 'D9',
        fullName: 'Navamsa',
        desc: 'Marriage, destiny & dharma',
        icon: '💕',
        color: Color(0xFFe91e63)),
    ChartInfo(
        key: 'd10',
        name: 'D10',
        fullName: 'Dasamsa',
        desc: 'Career & professional karma',
        icon: '💼',
        color: Color(0xFF7B61FF)),
    ChartInfo(
        key: 'd12',
        name: 'D12',
        fullName: 'Dwadasamsa',
        desc: 'Parents & ancestral lineage',
        icon: '👨‍👩‍👧',
        color: Color(0xFF5856d6)),
    ChartInfo(
        key: 'd16',
        name: 'D16',
        fullName: 'Shodasamsa',
        desc: 'Vehicles & comforts',
        icon: '🚗',
        color: Color(0xFF8e99a4)),
    ChartInfo(
        key: 'd20',
        name: 'D20',
        fullName: 'Vimsamsa',
        desc: 'Spiritual progress & upasana',
        icon: '🙏',
        color: Color(0xFF0d9488)),
    ChartInfo(
        key: 'd24',
        name: 'D24',
        fullName: 'Siddhamsa',
        desc: 'Education & learning',
        icon: '📚',
        color: Color(0xFF2196f3)),
    ChartInfo(
        key: 'd27',
        name: 'D27',
        fullName: 'Nakshatramsa',
        desc: 'Strengths & vitality',
        icon: '⭐',
        color: Color(0xFFffcc00)),
    ChartInfo(
        key: 'd30',
        name: 'D30',
        fullName: 'Trimsamsa',
        desc: 'Misfortunes & challenges',
        icon: '🛡️',
        color: Color(0xFFff3b30)),
    ChartInfo(
        key: 'd40',
        name: 'D40',
        fullName: 'Khavedamsa',
        desc: 'Auspicious effects',
        icon: '☯️',
        color: Color(0xFF9c27b0)),
    ChartInfo(
        key: 'd45',
        name: 'D45',
        fullName: 'Akshavedamsa',
        desc: 'Paternal legacy',
        icon: '🧬',
        color: Color(0xFF795548)),
    ChartInfo(
        key: 'd60',
        name: 'D60',
        fullName: 'Shashtyamsa',
        desc: 'Past life karma',
        icon: '♾️',
        color: Color(0xFF607d8b)),
  ];

  @override
  void initState() {
    super.initState();
    _loadCharts();
  }

  Future<void> _loadCharts() async {
    final session = UserSession();
    if (!session.hasData) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'No chart data found. Please recalculate.';
      });
      return;
    }
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted)
      setState(() {
        _isLoading = false;
        _errorMessage = null;
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AnimatedCosmicBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: _isLoading
                    ? _buildLoadingState()
                    : _errorMessage != null
                        ? _buildErrorState()
                        : _buildChartGrid(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Header ───
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 12, 16, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon:
                const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Divisional Charts',
                  style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '16 Parashara Vargas',
                  style: GoogleFonts.quicksand(
                    fontSize: 13,
                    color: Colors.white54,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _loadCharts,
            icon: const Icon(Icons.refresh,
                color: AstroTheme.accentGold, size: 22),
            tooltip: 'Refresh',
          ),
        ],
      ),
    );
  }

  // ─── Chart Grid ───
  Widget _buildChartGrid() {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      physics: const BouncingScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.0,
      ),
      itemCount: _charts.length,
      itemBuilder: (context, index) {
        final chart = _charts[index];
        return _ChartCard(
          chart: chart,
          hasData: _hasChartData(chart.key),
          onTap: () => _openChartDetail(chart),
        );
      },
    );
  }

  bool _hasChartData(String chartKey) {
    final session = UserSession();
    // Check saved SVG
    final svgs = session.birthChart?['divisionalSvgs'] as Map<String, dynamic>?;
    if (svgs?[chartKey.toLowerCase()] != null) return true;
    // Check local varga
    final vargas = session.birthChart?['vargas'] as Map<String, dynamic>?;
    final vargaKey = chartKey.toLowerCase().replaceFirst('d', 'D');
    return vargas?[vargaKey] is Map;
  }

  void _openChartDetail(ChartInfo chart) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => _ChartDetailScreen(chart: chart),
        transitionsBuilder: (_, anim, __, child) {
          return FadeTransition(
            opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 250),
      ),
    );
  }

  // ─── Loading / Error ───
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AstroTheme.accentGold),
          const SizedBox(height: 20),
          Text('Loading Charts...',
              style: TextStyle(color: Colors.white.withOpacity(0.7))),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 60),
            const SizedBox(height: 16),
            Text(_errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadCharts,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: AstroTheme.accentGold,
                  foregroundColor: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// ─── Chart Card Widget ───
// ═══════════════════════════════════════════════════════════════

class _ChartCard extends StatelessWidget {
  final ChartInfo chart;
  final bool hasData;
  final VoidCallback onTap;

  const _ChartCard({
    required this.chart,
    required this.hasData,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              chart.color.withOpacity(0.2),
              chart.color.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: chart.color.withOpacity(0.25), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: chart.color.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background glow circle
            Positioned(
              right: -15,
              top: -15,
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      chart.color.withOpacity(0.12),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon + Name row
                  Row(
                    children: [
                      Text(chart.icon, style: const TextStyle(fontSize: 24)),
                      const Spacer(),
                      // Status indicator
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: hasData
                              ? const Color(0xFF34c759)
                              : Colors.white24,
                          boxShadow: hasData
                              ? [
                                  BoxShadow(
                                      color: const Color(0xFF34c759)
                                          .withOpacity(0.4),
                                      blurRadius: 6)
                                ]
                              : null,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Chart name
                  Text(
                    chart.name,
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: chart.color.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    chart.fullName,
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.85),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    chart.desc,
                    style: GoogleFonts.quicksand(
                      fontSize: 10.5,
                      color: Colors.white38,
                    ),
                    maxLines: 2,
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
}

// ═══════════════════════════════════════════════════════════════
// ─── Chart Detail Screen ───
// ═══════════════════════════════════════════════════════════════

class _ChartDetailScreen extends StatelessWidget {
  final ChartInfo chart;

  const _ChartDetailScreen({required this.chart});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AnimatedCosmicBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(child: _buildChartView(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 12, 16, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon:
                const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          ),
          Text(chart.icon, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${chart.fullName} (${chart.name})',
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: chart.color,
                  ),
                ),
                Text(
                  chart.desc,
                  style: GoogleFonts.quicksand(
                      fontSize: 12, color: Colors.white54),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartView(BuildContext context) {
    final session = UserSession();
    if (!session.hasData || session.birthDetails == null) {
      return const Center(
        child: Text('No birth details found',
            style: TextStyle(color: Colors.white54)),
      );
    }

    final details = session.birthDetails!;
    final savedDivisionalSvgs =
        session.birthChart?['divisionalSvgs'] as Map<String, dynamic>?;
    final savedSvg = savedDivisionalSvgs?[chart.key.toLowerCase()] as String?;

    return LayoutBuilder(
      builder: (context, constraints) {
        final chartSize = (constraints.maxWidth - 32).clamp(260.0, 520.0);

        // Priority: 1. Saved SVG → 2. API SVG fetch → 3. Placeholder
        Widget chartWidget;
        if (savedSvg != null && savedSvg.isNotEmpty) {
          chartWidget = ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: chartSize,
              height: chartSize,
              child: SvgPicture.string(
                preprocessSvg(savedSvg),
                fit: BoxFit.contain,
              ),
            ),
          );
        } else {
          final chartType = _apiChartType(chart.key);
          if (chartType != null) {
            final apiDetails = api.BirthDetails(
              year: details.birthDateTime.year,
              month: details.birthDateTime.month,
              date: details.birthDateTime.day,
              hours: details.birthDateTime.hour,
              minutes: details.birthDateTime.minute,
              seconds: details.birthDateTime.second,
              latitude: details.latitude,
              longitude: details.longitude,
              timezone: details.timezoneOffset,
            );
            chartWidget = SvgChartViewer(
              birthDetails: apiDetails,
              chartType: chartType,
              size: chartSize,
              showTitle: false,
            );
          } else {
            chartWidget = _buildPlaceholder(chartSize);
          }
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Chart info banner
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      chart.color.withOpacity(0.15),
                      chart.color.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: chart.color.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: chart.color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(chart.icon,
                          style: const TextStyle(fontSize: 28)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            chart.fullName,
                            style: GoogleFonts.outfit(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: chart.color,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            chart.desc,
                            style: GoogleFonts.quicksand(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Chart display
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.06)),
                ),
                child: Center(child: chartWidget),
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPlaceholder(double size) {
    return SizedBox(
      width: size,
      height: size * 0.6,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.hourglass_empty_rounded,
                color: Colors.white24, size: 48),
            const SizedBox(height: 12),
            Text(
              'Recalculate chart to view ${chart.name}',
              style: const TextStyle(color: Colors.white38, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ─── API Chart Type (all 16 Parashara divisions) ───
  api.DivisionalChart? _apiChartType(String chartKey) {
    const map = {
      'd1': api.DivisionalChart.d1,
      'd2': api.DivisionalChart.d2,
      'd3': api.DivisionalChart.d3,
      'd4': api.DivisionalChart.d4,
      'd7': api.DivisionalChart.d7,
      'd9': api.DivisionalChart.d9,
      'd10': api.DivisionalChart.d10,
      'd12': api.DivisionalChart.d12,
      'd16': api.DivisionalChart.d16,
      'd20': api.DivisionalChart.d20,
      'd24': api.DivisionalChart.d24,
      'd27': api.DivisionalChart.d27,
      'd30': api.DivisionalChart.d30,
      'd40': api.DivisionalChart.d40,
      'd45': api.DivisionalChart.d45,
      'd60': api.DivisionalChart.d60,
    };
    return map[chartKey.toLowerCase()];
  }
}

// ═══════════════════════════════════════════════════════════════
// ─── ChartInfo Model ───
// ═══════════════════════════════════════════════════════════════

class ChartInfo {
  final String key;
  final String name;
  final String fullName;
  final String desc;
  final String icon;
  final Color color;

  const ChartInfo({
    required this.key,
    required this.name,
    required this.fullName,
    required this.desc,
    required this.icon,
    required this.color,
  });
}
