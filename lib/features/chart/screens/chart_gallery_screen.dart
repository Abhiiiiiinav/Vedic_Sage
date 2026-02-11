import 'package:flutter/material.dart';
import '../../../app/theme.dart';
import '../../../shared/widgets/animated_cosmic_background.dart';
import '../../../core/services/user_session.dart';
import '../widgets/interactive_kundali_chart.dart';
import '../../../core/astro/accurate_kundali_engine.dart';

/// Screen to display all generated chart images using Local Engine
class ChartGalleryScreen extends StatefulWidget {
  const ChartGalleryScreen({super.key});

  @override
  State<ChartGalleryScreen> createState() => _ChartGalleryScreenState();
}

class _ChartGalleryScreenState extends State<ChartGalleryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  String? _errorMessage;
  String _selectedChart = 'rasi';

  // Chart metadata - Added D3
  static const Map<String, ChartInfo> _chartInfo = {
    'rasi': ChartInfo(
      name: 'Rasi (D1)',
      fullName: 'Birth Chart / Lagna Kundali',
      description: 'Primary chart showing planetary positions at birth. Foundation of all analysis.',
      icon: '🌟',
    ),
    'd3': ChartInfo(
      name: 'Drekkana (D3)',
      fullName: 'Third Divisional Chart',
      description: 'Siblings and courage. Shows co-borns and mental strength.',
      icon: '👥',
    ),
    'd5': ChartInfo(
      name: 'Saptamsa (D7)', // Renamed to actual D7
      fullName: 'Seventh Divisional Chart',
      description: 'Reveals potential for children, creativity, and intelligence.',
      icon: '👶',
    ),
    'd9': ChartInfo(
      name: 'Navamsa (D9)',
      fullName: 'Ninth Divisional Chart',
      description: 'Most important divisional chart. Shows marriage, destiny, and soul purpose.',
      icon: '💕',
    ),
    'd10': ChartInfo(
      name: 'Dasamsa (D10)',
      fullName: 'Tenth Divisional Chart',
      description: 'Career and profession chart. Shows professional success and karma yoga.',
      icon: '💼',
    ),
    'd12': ChartInfo(
      name: 'Dwadasamsa (D12)',
      fullName: 'Twelfth Divisional Chart',
      description: 'Parents and ancestral lineage. Shows karma inherited from parents.',
      icon: '👨‍👩‍👧',
    ),
    'd16': ChartInfo(
      name: 'Shodasamsa (D16)',
      fullName: 'Sixteenth Divisional Chart',
      description: 'Vehicles, comforts, and luxuries. Shows material happiness.',
      icon: '🚗',
    ),
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
    _loadCharts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadCharts() async {
    // Data is already pre-calculated in UserSession by ChartLoaderScreen
    // Just verify session exists
    final session = UserSession();
    
    if (!session.hasData) {
      setState(() {
        _isLoading = false;
        _errorMessage = "No chart data found. please recalculate.";
      });
      return;
    }
    
    // Simulate brief load for UX
    await Future.delayed(const Duration(milliseconds: 300));
    
    if (mounted) {
      setState(() {
        _isLoading = false;
        _errorMessage = null;
      });
    }
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
              _buildTabBar(),
              Expanded(
                child: _isLoading
                    ? _buildLoadingState()
                    : _errorMessage != null
                        ? _buildErrorState()
                        : _buildChartTabView(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          ),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Chart Gallery',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Explore all divisional charts',
                  style: TextStyle(color: Colors.white60, fontSize: 14),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _loadCharts,
            icon: const Icon(Icons.refresh, color: AstroTheme.accentGold),
            tooltip: 'Refresh Charts',
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        indicatorColor: AstroTheme.accentGold,
        indicatorWeight: 3,
        labelColor: AstroTheme.accentGold,
        unselectedLabelColor: Colors.white60,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        tabs: _chartInfo.entries.map((entry) {
          return Tab(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(entry.value.icon),
                  const SizedBox(width: 4),
                  Text(entry.value.name),
                ],
              ),
            ),
          );
        }).toList(),
        onTap: (index) {
          setState(() {
            _selectedChart = _chartInfo.keys.elementAt(index);
          });
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AstroTheme.accentGold),
          const SizedBox(height: 20),
          Text(
            'Generating Charts...',
            style: TextStyle(color: Colors.white.withOpacity(0.7)),
          ),
          const SizedBox(height: 8),
          Text(
            'This may take a moment',
            style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
          ),
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
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadCharts,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AstroTheme.accentGold,
                foregroundColor: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartTabView() {
    return TabBarView(
      controller: _tabController,
      children: _chartInfo.keys.map((chartKey) {
        return _buildChartPage(chartKey, _chartInfo[chartKey]!);
      }).toList(),
    );
  }

  Widget _buildChartPage(String chartKey, ChartInfo info) {
    if (_isLoading) {
      return _buildLoadingState();
    }
    
    // Generate chart data locally
    final session = UserSession();
    if (!session.hasData) return const SizedBox.shrink();
    
    final details = session.birthDetails!;
    
    // Map internal key to Engine key
    final engineKey = chartKey.toUpperCase(); // 'rasi' -> 'RASI'? No, Engine uses 'D1', 'D9' etc.
    String vargaKey = 'D1';
    switch (chartKey) {
      case 'rasi': vargaKey = 'D1'; break;
      case 'd3': vargaKey = 'D3'; break;
      case 'd5': vargaKey = 'D7'; break; // Engine has D7 (Children), typically D5 implies Panchamsa which isn't standard in basic list? VargaCalculator has D7. D5 is usually not distinct in Parashara? Parashara has D1,2,3,4,7,9,10,12,16,20,24,27,30,40,45,60. I'll map 'd5' to 'D7' or remove it? The UI has 'd5'. Let's use D7 for now or check my VargaCalculator.
      // VargaCalculator.dart has: D1, D2, D3, D4, D7, D9... 
      // ChartGallery used 'd5' -> 'Panchamsa' -> Children. D7 is Saptamsa (Children). 
      // I will map 'd5' to 'D7' (Saptamsa) as it is the standard for Children. 
      // Or I should rename 'd5' to 'd7' in the UI list to be accurate. 
      // Let's stick to D7 (Saptamsa) for children.
      case 'd9': vargaKey = 'D9'; break;
      case 'd10': vargaKey = 'D10'; break;
      case 'd12': vargaKey = 'D12'; break;
      case 'd16': vargaKey = 'D16'; break;
      default: vargaKey = 'D1';
    }

    // Generate Varga Data
    // We need to re-generate strictly speaking or access from session if stored.
    // KundaliOrchestrator stores all vargas in result.
    // But UserSession stores 'birthChart' map which has 'vargas' map.
    
    final allVargas = session.birthChart!['vargas'] as Map<String, dynamic>;
    final vargaData = allVargas[vargaKey];

    if (vargaData == null) {
      return Center(child: Text("Chart $vargaKey not available"));
    }

    // Convert to display format
    final int ascSign = vargaData['ascendantSign'];
    final Map<String, int> planetSigns = Map<String, int>.from(vargaData['planetSigns']);
    
    // We need 'planets' map format for house building
    // Build houses using angular method
    List<List<String>> housesList = List.generate(12, (_) => <String>[]);
    
    // Map planet symbols
    const Map<String, String> planetSymbols = {
      'Sun': 'Su', 'Moon': 'Mo', 'Mars': 'Ma', 'Mercury': 'Me',
      'Jupiter': 'Ju', 'Venus': 'Ve', 'Saturn': 'Sa', 'Rahu': 'Ra', 'Ketu': 'Ke',
    };
    
    planetSigns.forEach((planet, sign) {
      // House = (planet sign - asc sign + 12) % 12 + 1
      int house = ((sign - ascSign + 12) % 12);
      String symbol = planetSymbols[planet] ?? planet.substring(0, 2);
      housesList[house].add(symbol);
    });
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Chart info card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AstroTheme.accentGold.withOpacity(0.15),
                  AstroTheme.accentGold.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AstroTheme.accentGold.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Text(info.icon, style: const TextStyle(fontSize: 32)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        info.fullName,
                        style: const TextStyle(
                          color: AstroTheme.accentGold,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        info.description,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Interactive Chart (Non-interactive mode)
          Container(
             // Decorate it nicely
             decoration: BoxDecoration(
               boxShadow: [
                  BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0,4))
               ]
             ),
             child: InteractiveKundaliChart(
                houses: housesList,
                ascendantSign: ascSign + 1, // 1-based index
                onHouseChanged: null, // Disable interaction if desired, or enable
             ),
          ),
          
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _downloadChart(String? url) {
    if (url == null || url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No chart available to download')),
      );
      return;
    }
    // TODO: Implement actual download functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Download feature coming soon!'),
        backgroundColor: AstroTheme.accentCyan,
      ),
    );
  }

  void _shareChart(String? url) {
    if (url == null || url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No chart available to share')),
      );
      return;
    }
    // TODO: Implement actual share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Share feature coming soon!'),
        backgroundColor: AstroTheme.accentGold,
      ),
    );
  }
}

/// Metadata for each chart type
class ChartInfo {
  final String name;
  final String fullName;
  final String description;
  final String icon;

  const ChartInfo({
    required this.name,
    required this.fullName,
    required this.description,
    required this.icon,
  });
}
