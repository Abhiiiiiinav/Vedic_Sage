import 'package:flutter/material.dart';
import '../../../app/theme.dart';
import '../../../core/constants/astro_data.dart';
import '../../../shared/widgets/astro_card.dart';
import '../../../shared/widgets/gradient_container.dart';
import '../widgets/interactive_kundali_chart.dart';
import '../widgets/svg_chart_viewer.dart'; // For preprocessSvg function
import '../../../shared/widgets/astro_background.dart';
import 'planet_detail_screen.dart';
import 'house_detail_screen.dart';
import 'sign_detail_screen.dart';
import '../../../core/services/user_session.dart';
import '../../calculator/screens/birth_details_screen.dart';
import 'chart_gallery_screen.dart';
import '../../../core/services/chart_api_service.dart' as api;
import '../../../core/services/svg_chart_extractor.dart' hide SvgChartParser;
import '../../../core/services/svg_chart_parser.dart';

/// Chart display styles
enum ChartStyle {
  southApi('South Indian', 'API-generated chart'),
  divisional('Divisional', 'Multiple divisional charts');

  final String label;
  final String description;
  const ChartStyle(this.label, this.description);
}

class ChartScreen extends StatefulWidget {
  const ChartScreen({super.key});

  @override
  State<ChartScreen> createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final UserSession _session = UserSession();
  final api.ChartApiService _chartApiService = api.ChartApiService();

  // Chart style state
  ChartStyle _selectedChartStyle = ChartStyle.southApi;

  // SVG chart state
  final Map<String, String?> _svgChartCache = <String, String?>{};
  final Set<String> _inFlightSvgRequests = <String>{};
  String? _lastSvgProfileKey;

  // API extracted data (stored for reference across the app)
  Map<String, dynamic>? _apiPlanetaryData;
  ExtractedChartData? _extractedChartData; // Structured extracted data
  bool _isLoadingApiData = false;
  bool _isApiServerAvailable = false;

  // Selected divisional chart for South style
  api.DivisionalChart _selectedDivisionalChart = api.DivisionalChart.d1;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _checkApiServerAndLoadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _chartApiService.dispose();
    super.dispose();
  }

  bool _showChart = true;

  bool _parseBool(dynamic value, {bool fallback = false}) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      if (normalized == 'true' ||
          normalized == '1' ||
          normalized == 'yes' ||
          normalized == 'y') {
        return true;
      }
      if (normalized == 'false' ||
          normalized == '0' ||
          normalized == 'no' ||
          normalized == 'n' ||
          normalized.isEmpty) {
        return false;
      }
    }
    return fallback;
  }

  /// Check if chart API service is available and load planetary data
  Future<void> _checkApiServerAndLoadData() async {
    final isAvailable = await _chartApiService.healthCheck();
    setState(() => _isApiServerAvailable = isAvailable);

    if (isAvailable && _session.hasData) {
      await _loadApiPlanetaryData();
    }
  }

  /// Load planetary data from direct API and store for reference
  Future<void> _loadApiPlanetaryData() async {
    if (!_session.hasData || _session.birthDetails == null) return;

    setState(() => _isLoadingApiData = true);

    try {
      final details = _session.birthDetails!;
      final apiDetails = api.BirthDetails(
        year: details.birthDateTime.year,
        month: details.birthDateTime.month,
        date: details.birthDateTime.day,
        hours: details.birthDateTime.hour,
        minutes: details.birthDateTime.minute,
        seconds: 0,
        latitude: details.latitude,
        longitude: details.longitude,
        timezone: details.timezoneOffset,
      );

      final planetaryData = await _chartApiService.getPlanetaryData(apiDetails);

      if (mounted && planetaryData.isNotEmpty) {
        setState(() {
          _apiPlanetaryData = planetaryData;
          _isLoadingApiData = false;
        });

        // Store in session for app-wide reference
        _storeApiDataInSession(planetaryData);

        print('✅ API Planetary Data loaded: ${planetaryData.keys.join(", ")}');
      } else {
        setState(() => _isLoadingApiData = false);
      }
    } catch (e) {
      print('❌ Error loading API planetary data: $e');
      setState(() => _isLoadingApiData = false);
    }
  }

  /// Store API extracted data in the session for reference
  void _storeApiDataInSession(Map<String, dynamic> planetaryData) {
    if (_session.birthChart == null) return;

    // Vedic planets (exclude modern planets)
    const vedicPlanets = {
      'Sun',
      'Moon',
      'Mars',
      'Mercury',
      'Jupiter',
      'Venus',
      'Saturn',
      'Rahu',
      'Ketu',
      'Ascendant'
    };

    // Convert planet map to list format expected by extractor (filter Vedic only)
    final planetsList = planetaryData.entries
        .where((e) =>
            e.key != 'ayanamsa' &&
            e.value is Map &&
            vedicPlanets.contains(e.key))
        .map((e) => {e.key: e.value})
        .toList();

    // Get ascendant from session
    final ascSignIndex = _session.birthChart!['ascSignIndex'] as int? ?? 0;

    // Use the new extractor for structured data
    final extractedData = SvgChartDataExtractor.extractFromApiResponse(
      planetsList,
      chartType: 'D1',
      ascendantSign: ascSignIndex + 1, // Convert 0-indexed to 1-indexed
    );

    // Store structured data
    setState(() {
      _extractedChartData = extractedData;
    });

    // Create enriched chart data with API planetary positions
    final enrichedChart = Map<String, dynamic>.from(_session.birthChart!);
    enrichedChart['apiPlanets'] = planetaryData;
    enrichedChart['extractedChartData'] = extractedData.toMap();

    // Store house-planet mapping
    enrichedChart['housePlanets'] = extractedData.housePlanets.map(
      (house, planets) => MapEntry(house.toString(), planets),
    );

    // Store simplified planet positions for quick access
    final extractedDetails = _extractChartDetails(planetaryData);
    enrichedChart['apiExtracted'] = extractedDetails;

    // Update session (note: this doesn't call saveSession, just updates the reference)
    _session.birthChart!.addAll(enrichedChart);

    print(
        '📊 Extracted ${extractedData.planets.length} planets, Asc: ${extractedData.ascendantSignName}');
    print(
        '🏠 House Planets: ${extractedData.housePlanets.entries.where((e) => e.value.isNotEmpty).map((e) => "H${e.key}: ${e.value.join(",")}").join(" | ")}');
  }

  /// Extract key chart details from planetary data
  Map<String, dynamic> _extractChartDetails(
      Map<String, dynamic> planetaryData) {
    final extracted = <String, dynamic>{};

    // Vedic planets only
    const vedicPlanets = {
      'Sun',
      'Moon',
      'Mars',
      'Mercury',
      'Jupiter',
      'Venus',
      'Saturn',
      'Rahu',
      'Ketu',
      'Ascendant'
    };

    // Extract each planet's details
    planetaryData.forEach((key, value) {
      if (value is Map<String, dynamic> &&
          key != 'ayanamsa' &&
          vedicPlanets.contains(key)) {
        extracted[key] = {
          'name': value['name'] ?? key,
          'sign': value['current_sign'] != null
              ? SvgChartDataExtractor
                  .signs[(value['current_sign'] as int).clamp(1, 12) - 1]
              : (value['sign'] ?? value['zodiac_sign_name']),
          'signNumber': value['current_sign'] ??
              value['sign_num'] ??
              value['zodiac_sign_number'],
          'nakshatra': value['nakshatra'] ?? value['nakshatra_name'],
          'nakshatraPada':
              value['nakshatra_pada'] ?? value['nakshatra_quarter'],
          'longitude':
              value['fullDegree'] ?? value['longitude'] ?? value['full_degree'],
          'signDegree': value['normDegree'] ??
              value['sign_degree'] ??
              value['current_sign_degree'],
          'house': value['house_number'] ?? value['house'],
          'isRetrograde': _parseBool(
            value['isRetro'] ?? value['is_retro'] ?? value['isRetrograde'],
          ),
          'nakshatraLord': value['nakshatra_lord'],
          'signLord': value['sign_lord'] ?? value['zodiac_lord'],
        };
      }
    });

    // Store ayanamsa if available
    if (planetaryData.containsKey('ayanamsa')) {
      extracted['ayanamsa'] = planetaryData['ayanamsa'];
    }

    return extracted;
  }

  /// Load SVG chart from API
  Future<void> _loadChartSvg() async {
    if (!_session.hasData || _session.birthDetails == null) return;

    final details = _session.birthDetails!;
    final chartKey = _selectedDivisionalChart.code.toLowerCase();
    final profileKey = _buildSvgProfileKey();
    final requestKey = '$profileKey|$chartKey';

    if (_lastSvgProfileKey != profileKey) {
      _svgChartCache.clear();
      _inFlightSvgRequests.clear();
      _lastSvgProfileKey = profileKey;
    }

    final cachedSvg = _svgChartCache[requestKey];
    if (cachedSvg != null && cachedSvg.isNotEmpty) {
      setState(() {
        _extractedChartData = _extractFromSvg(
          cachedSvg,
          chartCode: _selectedDivisionalChart.code,
        );
      });
      return;
    }

    final savedDivisionalSvgs =
        _session.birthChart?['divisionalSvgs'] as Map<String, dynamic>?;
    final savedSvg = savedDivisionalSvgs?[chartKey];
    if (savedSvg is String && savedSvg.isNotEmpty) {
      setState(() {
        _svgChartCache[requestKey] = savedSvg;
        _extractedChartData = _extractFromSvg(
          savedSvg,
          chartCode: _selectedDivisionalChart.code,
        );
      });
      return;
    }

    if (_inFlightSvgRequests.contains(requestKey)) {
      return;
    }

    _inFlightSvgRequests.add(requestKey);

    try {
      final apiDetails = api.BirthDetails(
        year: details.birthDateTime.year,
        month: details.birthDateTime.month,
        date: details.birthDateTime.day,
        hours: details.birthDateTime.hour,
        minutes: details.birthDateTime.minute,
        seconds: 0,
        latitude: details.latitude,
        longitude: details.longitude,
        timezone: details.timezoneOffset,
      );
      final division = int.parse(_selectedDivisionalChart.code.substring(1));
      var response = await _chartApiService.getChartByDivision(
        apiDetails,
        division,
      );
      if (!response.success || response.svg == null || response.svg!.isEmpty) {
        _chartApiService.useNextApiKey();
        response = await _chartApiService.getChartByDivision(
          apiDetails,
          division,
        );
      }
      final svg = response.svg;

      setState(() {
        if (svg != null && svg.isNotEmpty) {
          _svgChartCache[requestKey] = svg;
          _extractedChartData = _extractFromSvg(
            svg,
            chartCode: _selectedDivisionalChart.code,
          );
        }
      });
    } catch (e) {
      print("❌ Error loading SVG chart: $e");
    } finally {
      _inFlightSvgRequests.remove(requestKey);
    }
  }

  String _buildSvgProfileKey() {
    final details = _session.birthDetails!;
    final dt = details.birthDateTime;
    return [
      dt.year,
      dt.month,
      dt.day,
      dt.hour,
      dt.minute,
      details.latitude.toStringAsFixed(6),
      details.longitude.toStringAsFixed(6),
      details.timezoneOffset.toStringAsFixed(2),
    ].join('|');
  }

  /// Parse SVG chart and convert it to ExtractedChartData used by the dialog UI.
  /// If API planet JSON is available, enrich the SVG extraction with degree/nakshatra.
  ExtractedChartData _extractFromSvg(String svg, {String chartCode = 'D1'}) {
    final parsed = SvgChartParser.extractPositions(svg);
    final fallbackAsc =
        ((_session.birthChart?['ascSignIndex'] as int?) ?? 0) + 1;
    final ascSign =
        parsed.ascendantSign > 0 ? parsed.ascendantSign : fallbackAsc;
    final ascSignName = SvgChartParser.getSignName(ascSign);

    final housePlanets = <int, List<String>>{
      for (int i = 1; i <= 12; i++) i: <String>[],
    };

    final planets = <ExtractedPlanet>[];
    parsed.planetSigns.forEach((abbr, signNumber) {
      final name = SvgChartParser.getPlanetName(abbr);
      final houseNumber = SvgChartParser.signToHouse(signNumber, ascSign);
      housePlanets[houseNumber]!.add(abbr);

      final api = _apiPlanetaryData?[name] as Map<String, dynamic>?;
      final fullDegreeRaw =
          api?['fullDegree'] ?? api?['full_degree'] ?? api?['longitude'] ?? 0.0;
      final signDegreeRaw = api?['normDegree'] ??
          api?['sign_degree'] ??
          api?['norm_degree'] ??
          0.0;
      final fullDegree = (fullDegreeRaw as num).toDouble();
      final signDegree = (signDegreeRaw as num).toDouble();

      String? nakshatra = api?['nakshatra'] ?? api?['nakshatra_name'];
      int? nakshatraPada = api?['nakshatra_pada'] ?? api?['nakshatra_quarter'];
      if ((nakshatra == null || nakshatra.isEmpty) && fullDegree > 0) {
        final nk = SvgChartParser.calculateNakshatra(fullDegree);
        nakshatra = nk.nakshatra;
        nakshatraPada = nk.pada;
      }

      planets.add(
        ExtractedPlanet(
          name: name,
          abbreviation: abbr,
          sign: SvgChartParser.getSignName(signNumber),
          signNumber: signNumber,
          houseNumber: houseNumber,
          fullDegree: fullDegree,
          signDegree: signDegree,
          isRetrograde: _parseBool(api?['isRetro'] ?? api?['is_retro']),
          nakshatra: nakshatra,
          nakshatraPada: nakshatraPada,
          nakshatraLord: api?['nakshatra_lord'],
        ),
      );
    });

    planets.sort((a, b) {
      final houseCmp = a.houseNumber.compareTo(b.houseNumber);
      if (houseCmp != 0) return houseCmp;
      return a.name.compareTo(b.name);
    });

    return ExtractedChartData(
      chartType: chartCode,
      ascendantSign: ascSign,
      ascendantSignName: ascSignName,
      planets: planets,
      housePlanets: housePlanets,
      extractedAt: DateTime.now(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AstroBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            SafeArea(
              bottom: false,
              child: _buildHeader(),
            ),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildPlanetsTab(),
                  _buildHousesTab(),
                  _buildSignsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: AstroTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AstroTheme.accentPurple.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _session.hasData
                          ? '${_session.birthDetails?.name}\'s Chart'
                          : 'Birth Chart Explorer',
                      style: AstroTheme.headingMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _session.hasData
                          ? 'Tap houses to explore your planetary placements'
                          : 'Tap to calculate your personal Vedic chart',
                      style: AstroTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInteractiveChart(),
        ],
      ),
    );
  }

  Widget _buildInteractiveChart() {
    if (!_session.hasData) {
      return _buildNoDataPlaceholder();
    }
    final screenHeight = MediaQuery.of(context).size.height;
    final chartContainerHeight = (screenHeight - 330).clamp(360.0, 500.0);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Chart mode + divisional selector
            Row(
              children: [
                _buildChartTypeToggle(),
                const SizedBox(width: 8),
                // Show divisional selector when in South style
                if (_selectedChartStyle == ChartStyle.southApi)
                  _buildDivisionalChartSelector()
                else
                  _buildGalleryButton(),
              ],
            ),
            Row(
              children: [
                // API data status indicator
                if (_apiPlanetaryData != null || _extractedChartData != null)
                  _buildApiDataIndicator(),
                _buildChartVisibilityToggle(),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: _showChart
              ? GradientContainer(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AstroTheme.cardBackground,
                      AstroTheme.cardBackgroundLight.withOpacity(0.5),
                    ],
                  ),
                  borderRadius: 20,
                  child: SizedBox(
                    height: chartContainerHeight,
                    child: _buildSvgChart(),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  /// Divisional chart quick selector for South style
  Widget _buildDivisionalChartSelector() {
    return PopupMenuButton<api.DivisionalChart>(
      onSelected: (chart) {
        if (chart == _selectedDivisionalChart) return;
        setState(() {
          _selectedDivisionalChart = chart;
        });
        if (_selectedChartStyle == ChartStyle.southApi) {
          _loadChartSvg();
        }
      },
      itemBuilder: (context) => [
        _buildDivisionalMenuItem(api.DivisionalChart.d1),
        _buildDivisionalMenuItem(api.DivisionalChart.d9),
        _buildDivisionalMenuItem(api.DivisionalChart.d10),
        _buildDivisionalMenuItem(api.DivisionalChart.d7),
        _buildDivisionalMenuItem(api.DivisionalChart.d12),
        const PopupMenuDivider(),
        PopupMenuItem(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ChartGalleryScreen()),
            );
          },
          child: const Row(
            children: [
              Icon(Icons.grid_view_rounded,
                  size: 16, color: AstroTheme.accentCyan),
              SizedBox(width: 8),
              Text('View All Charts',
                  style: TextStyle(color: AstroTheme.accentCyan)),
            ],
          ),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AstroTheme.accentPurple.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AstroTheme.accentPurple.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _selectedDivisionalChart.code,
              style: const TextStyle(
                color: AstroTheme.accentPurple,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down,
                size: 16, color: AstroTheme.accentPurple),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<api.DivisionalChart> _buildDivisionalMenuItem(
      api.DivisionalChart chart) {
    final isSelected = _selectedDivisionalChart == chart;
    return PopupMenuItem<api.DivisionalChart>(
      value: chart,
      child: Row(
        children: [
          Text(
            chart.code,
            style: TextStyle(
              color: isSelected ? AstroTheme.accentGold : Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              chart.name,
              style: TextStyle(
                color: isSelected ? AstroTheme.accentGold : Colors.white70,
              ),
            ),
          ),
          if (isSelected)
            const Icon(Icons.check, size: 16, color: AstroTheme.accentGold),
        ],
      ),
    );
  }

  /// API data status indicator
  Widget _buildApiDataIndicator() {
    return GestureDetector(
      onTap: () => _showApiDataDialog(),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isLoadingApiData)
              const SizedBox(
                width: 10,
                height: 10,
                child: CircularProgressIndicator(
                  strokeWidth: 1.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                ),
              )
            else
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green,
                ),
              ),
            const SizedBox(width: 6),
            const Text(
              'API Data',
              style: TextStyle(
                color: Colors.green,
                fontSize: 9,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Show dialog with extracted API data
  void _showApiDataDialog() {
    if (_apiPlanetaryData == null && _extractedChartData == null) return;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AstroTheme.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: DefaultTabController(
          length: 3,
          child: Container(
            width: 400,
            height: 550,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.green.withOpacity(0.3),
                            Colors.teal.withOpacity(0.2)
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.auto_awesome,
                          color: Colors.green, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Extracted Chart Data',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                        if (_extractedChartData != null)
                          Text(
                            'Ascendant: ${_extractedChartData!.ascendantSignName}',
                            style: const TextStyle(
                                color: AstroTheme.accentGold, fontSize: 12),
                          ),
                      ],
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white54),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Tab Bar
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const TabBar(
                    labelColor: AstroTheme.accentGold,
                    unselectedLabelColor: Colors.white54,
                    indicatorColor: AstroTheme.accentGold,
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    tabs: [
                      Tab(text: 'Planets', icon: Icon(Icons.circle, size: 14)),
                      Tab(text: 'Houses', icon: Icon(Icons.home, size: 14)),
                      Tab(
                          text: 'Summary',
                          icon: Icon(Icons.list_alt, size: 14)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Tab Content
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildDialogPlanetsTab(),
                      _buildDialogHousesTab(),
                      _buildDialogSummaryTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Planets tab in dialog
  Widget _buildDialogPlanetsTab() {
    if (_extractedChartData == null || _extractedChartData!.planets.isEmpty) {
      return const Center(
          child:
              Text('No planet data', style: TextStyle(color: Colors.white54)));
    }

    return ListView.builder(
      itemCount: _extractedChartData!.planets.length,
      itemBuilder: (context, index) {
        final planet = _extractedChartData!.planets[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: planet.isRetrograde
                  ? Colors.red.withOpacity(0.3)
                  : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              // Planet icon/name
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getPlanetColor(planet.name).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    planet.abbreviation,
                    style: TextStyle(
                      color: _getPlanetColor(planet.name),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Planet details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          planet.name,
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        if (planet.isRetrograde)
                          Container(
                            margin: const EdgeInsets.only(left: 6),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text('R',
                                style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${planet.sign} • H${planet.houseNumber} • ${planet.signDegree.toStringAsFixed(1)}°',
                      style: const TextStyle(
                          color: AstroTheme.accentCyan, fontSize: 12),
                    ),
                    if (planet.nakshatra != null)
                      Text(
                        '${planet.nakshatra} Pada ${planet.nakshatraPada ?? "-"}',
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.6), fontSize: 11),
                      ),
                  ],
                ),
              ),

              // House badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AstroTheme.accentPurple.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'H${planet.houseNumber}',
                  style: const TextStyle(
                      color: AstroTheme.accentPurple,
                      fontWeight: FontWeight.bold,
                      fontSize: 12),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Houses tab showing planets in each house
  Widget _buildDialogHousesTab() {
    if (_extractedChartData == null) {
      return const Center(
          child:
              Text('No house data', style: TextStyle(color: Colors.white54)));
    }

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: 12,
      itemBuilder: (context, index) {
        final houseNum = index + 1;
        final planets = _extractedChartData!.getPlanetsInHouse(houseNum);
        final sign = SvgChartDataExtractor
            .signs[(_extractedChartData!.ascendantSign + index - 1) % 12];

        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: planets.isNotEmpty
                ? AstroTheme.accentGold.withOpacity(0.1)
                : Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: planets.isNotEmpty
                  ? AstroTheme.accentGold.withOpacity(0.3)
                  : Colors.white.withOpacity(0.1),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'H$houseNum',
                style: TextStyle(
                  color: planets.isNotEmpty
                      ? AstroTheme.accentGold
                      : Colors.white54,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(
                sign.substring(0, 3),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 10,
                ),
              ),
              const SizedBox(height: 4),
              if (planets.isNotEmpty)
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 2,
                  runSpacing: 2,
                  children: planets
                      .map((p) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: _getPlanetColor(p.name).withOpacity(0.3),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              p.abbreviation,
                              style: TextStyle(
                                color: _getPlanetColor(p.name),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ))
                      .toList(),
                )
              else
                Text(
                  '—',
                  style: TextStyle(color: Colors.white.withOpacity(0.3)),
                ),
            ],
          ),
        );
      },
    );
  }

  /// Summary tab with all extracted info
  Widget _buildDialogSummaryTab() {
    if (_extractedChartData == null) {
      return const Center(
          child: Text('No data', style: TextStyle(color: Colors.white54)));
    }

    return ListView(
      children: [
        _buildSummaryCard(
          'Ascendant (Lagna)',
          _extractedChartData!.ascendantSignName,
          Icons.account_circle,
          AstroTheme.accentGold,
        ),
        _buildSummaryCard(
          'Total Planets',
          '${_extractedChartData!.planets.length} planets extracted',
          Icons.circle,
          AstroTheme.accentCyan,
        ),
        _buildSummaryCard(
          'Retrograde Planets',
          _extractedChartData!.planets
                  .where((p) => p.isRetrograde)
                  .map((p) => p.abbreviation)
                  .join(', ') ??
              'None',
          Icons.replay,
          Colors.red,
        ),
        const SizedBox(height: 16),
        const Text(
          'Planet Positions',
          style: TextStyle(
              color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ..._extractedChartData!.planets.map((p) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  SizedBox(
                    width: 60,
                    child: Text(p.name,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 12)),
                  ),
                  Text(
                    '${p.sign} ${p.signDegree.toStringAsFixed(1)}°',
                    style: const TextStyle(
                        color: AstroTheme.accentCyan, fontSize: 12),
                  ),
                  const Spacer(),
                  Text(
                    'House ${p.houseNumber}',
                    style: const TextStyle(
                        color: AstroTheme.accentPurple, fontSize: 12),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildSummaryCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.6), fontSize: 11)),
              Text(value,
                  style: TextStyle(
                      color: color, fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }

  Color _getPlanetColor(String planetName) {
    const colors = {
      'Sun': Colors.orange,
      'Moon': Colors.white,
      'Mars': Colors.red,
      'Mercury': Colors.green,
      'Jupiter': Colors.yellow,
      'Venus': Colors.pink,
      'Saturn': Colors.blue,
      'Rahu': Colors.grey,
      'Ketu': Colors.brown,
    };
    return colors[planetName] ?? Colors.white;
  }

  Widget _buildPlanetDetail(String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  color: Colors.white.withOpacity(0.6), fontSize: 12)),
          Text(value,
              style: const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }

  /// Build SVG chart widget using the cached SvgChartViewer
  Widget _buildSvgChart() {
    if (!_session.hasData || _session.birthDetails == null) {
      return const SizedBox.shrink();
    }
    final chartData = _session.birthChart!;
    final rawHouses = chartData['houses'] as List;
    final List<List<String>> housesList =
        rawHouses.map((e) => List<String>.from(e)).toList();
    final ascSign = ((chartData['ascSignIndex'] as int?) ?? 0) + 1;

    final details = _session.birthDetails!;
    // Map to API BirthDetails
    final apiDetails = api.BirthDetails(
      year: details.birthDateTime.year,
      month: details.birthDateTime.month,
      date: details.birthDateTime.day,
      hours: details.birthDateTime.hour,
      minutes: details.birthDateTime.minute,
      seconds: 0,
      latitude: details.latitude,
      longitude: details.longitude,
      timezone: details.timezoneOffset,
    );

    // Use SvgChartViewer which handles fetching, caching, and preprocessing
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          // Chart title
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AstroTheme.accentPurple.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${_selectedDivisionalChart.code} - ${_selectedDivisionalChart.name}',
                  style: const TextStyle(
                    color: AstroTheme.accentPurple,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _selectedDivisionalChart.description,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SvgChartViewer(
                key: ValueKey('${_selectedDivisionalChart.code}-svg'),
                birthDetails: apiDetails,
                chartType: _selectedDivisionalChart,
                size: 360, // Optimized size for the container
                fallback: InteractiveKundaliChart(
                  houses: housesList,
                  ascendantSign: ascSign,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Toggle between South chart mode and divisional gallery
  Widget _buildChartTypeToggle() {
    return PopupMenuButton<ChartStyle>(
      onSelected: (style) {
        setState(() {
          _selectedChartStyle = style;

          if (style == ChartStyle.southApi) {
            _loadChartSvg();
          }

          if (style == ChartStyle.divisional) {
            // Navigate to gallery
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ChartGalleryScreen()),
            );
            // Keep this screen in South API mode after opening gallery
            _selectedChartStyle = ChartStyle.southApi;
          }
        });
      },
      itemBuilder: (context) => [
        _buildChartStyleMenuItem(ChartStyle.southApi, Icons.api),
        _buildChartStyleMenuItem(
            ChartStyle.divisional, Icons.grid_view_rounded),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          gradient: _selectedChartStyle == ChartStyle.southApi
              ? LinearGradient(
                  colors: [
                    AstroTheme.accentCyan.withOpacity(0.2),
                    AstroTheme.accentCyan.withOpacity(0.1),
                  ],
                )
              : null,
          color: _selectedChartStyle != ChartStyle.southApi
              ? AstroTheme.cardBackground
              : null,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _selectedChartStyle == ChartStyle.southApi
                ? AstroTheme.accentCyan.withOpacity(0.5)
                : Colors.white.withOpacity(0.1),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Server status indicator for South style
            if (_selectedChartStyle == ChartStyle.southApi) ...[
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isApiServerAvailable ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(width: 6),
            ],
            Icon(
              _selectedChartStyle == ChartStyle.southApi
                  ? Icons.api
                  : Icons.grid_view_rounded,
              size: 14,
              color: _selectedChartStyle == ChartStyle.southApi
                  ? AstroTheme.accentCyan
                  : AstroTheme.accentGold,
            ),
            const SizedBox(width: 6),
            Text(
              _selectedChartStyle.label,
              style: TextStyle(
                color: _selectedChartStyle == ChartStyle.southApi
                    ? AstroTheme.accentCyan
                    : Colors.white70,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down,
              size: 16,
              color: _selectedChartStyle == ChartStyle.southApi
                  ? AstroTheme.accentCyan
                  : Colors.white54,
            ),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<ChartStyle> _buildChartStyleMenuItem(
      ChartStyle style, IconData icon) {
    final isSelected = _selectedChartStyle == style;
    final isServerRequired = style == ChartStyle.southApi;

    return PopupMenuItem<ChartStyle>(
      value: style,
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: isSelected ? AstroTheme.accentGold : Colors.white70,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  style.label,
                  style: TextStyle(
                    color: isSelected ? AstroTheme.accentGold : Colors.white,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                Text(
                  style.description,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          if (isServerRequired) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: _isApiServerAvailable
                    ? Colors.green.withOpacity(0.2)
                    : Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _isApiServerAvailable ? 'Online' : 'Offline',
                style: TextStyle(
                  color: _isApiServerAvailable ? Colors.green : Colors.red,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
          if (isSelected)
            const Icon(Icons.check, size: 16, color: AstroTheme.accentGold),
        ],
      ),
    );
  }

  /// Button to open Divisional Charts Gallery
  Widget _buildGalleryButton() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ChartGalleryScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AstroTheme.accentCyan.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AstroTheme.accentCyan.withOpacity(0.3)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.grid_view_rounded,
              size: 14,
              color: AstroTheme.accentCyan,
            ),
            SizedBox(width: 6),
            Text(
              'Divisional',
              style: TextStyle(
                color: AstroTheme.accentCyan,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoDataPlaceholder() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AstroTheme.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          const Icon(Icons.stars, size: 48, color: AstroTheme.accentGold),
          const SizedBox(height: 16),
          const Text(
            "Ready to see your chart?",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Enter your birth details to generate your authentic Vedic Kundali.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white60),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BirthDetailsScreen()),
              ).then((_) {
                // Refresh if data added
                setState(() {});
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AstroTheme.accentGold,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('CALCULATE NOW'),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AstroTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: AstroTheme.primaryGradient,
          borderRadius: BorderRadius.circular(12),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: const EdgeInsets.all(4),
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white54,
        labelStyle: const TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        tabs: const [
          Tab(text: 'Planets'),
          Tab(text: 'Houses'),
          Tab(text: 'Signs'),
        ],
      ),
    );
  }

  /// Find extracted planet data by matching name
  ExtractedPlanet? _findExtractedPlanet(String planetName) {
    if (_extractedChartData == null) return null;
    final lowerName = planetName.toLowerCase();
    for (final p in _extractedChartData!.planets) {
      if (p.name.toLowerCase() == lowerName) return p;
    }
    return null;
  }

  Widget _buildPlanetsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: AstroData.planets.length,
      itemBuilder: (context, index) {
        final planet = AstroData.planets[index];
        final color = AstroTheme.getPlanetColor(planet.id);
        final extracted = _findExtractedPlanet(planet.name);

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: AstroCard(
            onTap: () => _navigateToPlanetDetail(planet.id),
            padding: EdgeInsets.zero,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color.withOpacity(0.15),
                    color.withOpacity(0.05),
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: color.withOpacity(0.5),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: color.withOpacity(0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              planet.symbol,
                              style: TextStyle(
                                fontSize: 28,
                                color: color,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    planet.name,
                                    style: AstroTheme.headingSmall,
                                  ),
                                  if (extracted?.isRetrograde == true)
                                    Container(
                                      margin: const EdgeInsets.only(left: 6),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 5, vertical: 1),
                                      decoration: BoxDecoration(
                                        color: Colors.red.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(
                                            color: Colors.red.withOpacity(0.4)),
                                      ),
                                      child: const Text('R',
                                          style: TextStyle(
                                              color: Colors.red,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold)),
                                    ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black26,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.white10,
                                      ),
                                    ),
                                    child: Text(
                                      planet.nature.split(' ')[0],
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                planet.sanskritName,
                                style: AstroTheme.bodyMedium.copyWith(
                                  color: color.withOpacity(0.8),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    // --- Chart Position Data ---
                    if (extracted != null) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(10),
                          border:
                              Border.all(color: Colors.white.withOpacity(0.06)),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                _buildChartInfoChip(Icons.auto_awesome,
                                    extracted.sign, AstroTheme.accentGold),
                                const SizedBox(width: 8),
                                _buildChartInfoChip(
                                    Icons.home_outlined,
                                    'House ${extracted.houseNumber}',
                                    AstroTheme.accentPurple),
                                const SizedBox(width: 8),
                                _buildChartInfoChip(
                                    Icons.my_location,
                                    '${extracted.signDegree.toStringAsFixed(2)}°',
                                    AstroTheme.accentCyan),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                if (extracted.nakshatra != null)
                                  _buildChartInfoChip(
                                      Icons.star_outline,
                                      '${extracted.nakshatra} Pada ${extracted.nakshatraPada ?? "-"}',
                                      Colors.amber),
                                if (extracted.nakshatraLord != null) ...[
                                  const SizedBox(width: 8),
                                  _buildChartInfoChip(
                                      Icons.person_outline,
                                      'Lord: ${extracted.nakshatraLord}',
                                      Colors.tealAccent),
                                ],
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                _buildChartInfoChip(
                                    Icons.explore_outlined,
                                    '${extracted.fullDegree.toStringAsFixed(4)}° Abs',
                                    Colors.white54),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                    // --- Karakas ---
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: planet.karakas.take(3).map((karaka) {
                          return Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              karaka.split(' ')[0],
                              style: TextStyle(
                                fontSize: 10,
                                color: color.withOpacity(0.9),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildChartInfoChip(IconData icon, String text, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                text,
                style: TextStyle(
                    fontSize: 10, color: color, fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHousesTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: AstroData.houses.length,
      itemBuilder: (context, index) {
        final house = AstroData.houses[index];
        final planetsInHouse =
            _extractedChartData?.getPlanetsInHouse(house.number) ?? [];
        // Compute the sign for this house if chart data is available
        String? houseSign;
        if (_extractedChartData != null) {
          final signIndex =
              (_extractedChartData!.ascendantSign + house.number - 2) % 12;
          houseSign = SvgChartDataExtractor.signs[signIndex];
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: AstroCard(
            onTap: () => _navigateToHouseDetail(house.number),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: AstroTheme.primaryGradient,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AstroTheme.accentPurple.withOpacity(0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              '${house.number}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              house.name,
                              style: AstroTheme.headingSmall
                                  .copyWith(fontSize: 16),
                            ),
                            Row(
                              children: [
                                Text(
                                  house.sanskritName,
                                  style: AstroTheme.bodyMedium.copyWith(
                                    color: AstroTheme.accentGold,
                                    fontSize: 12,
                                  ),
                                ),
                                if (houseSign != null) ...[
                                  Text(
                                    ' • ',
                                    style: TextStyle(
                                        color: Colors.white.withOpacity(0.3),
                                        fontSize: 12),
                                  ),
                                  Text(
                                    houseSign,
                                    style: const TextStyle(
                                      color: AstroTheme.accentCyan,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.white24,
                      size: 16,
                    ),
                  ],
                ),
                // --- Planets in this house ---
                if (planetsInHouse.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AstroTheme.accentGold.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: AstroTheme.accentGold.withOpacity(0.15)),
                    ),
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: planetsInHouse.map((p) {
                        final pColor = _getPlanetColor(p.name);
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: pColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: pColor.withOpacity(0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                p.name,
                                style: TextStyle(
                                    color: pColor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${p.signDegree.toStringAsFixed(1)}°',
                                style: TextStyle(
                                    color: pColor.withOpacity(0.7),
                                    fontSize: 10),
                              ),
                              if (p.isRetrograde)
                                Padding(
                                  padding: const EdgeInsets.only(left: 3),
                                  child: Text('R',
                                      style: TextStyle(
                                          color: Colors.red.shade300,
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold)),
                                ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                Divider(color: Colors.white.withOpacity(0.05)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: house.lifeAreas.take(3).map((area) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Text(
                        area,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSignsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: AstroData.signs.length,
      itemBuilder: (context, index) {
        final sign = AstroData.signs[index];
        final elementColor = _getElementColor(sign.element);
        // Find planets in this sign from extracted chart data
        final signNumber = index + 1; // Signs are 1-indexed (Aries=1, etc.)
        final planetsInSign = _extractedChartData?.planets
                .where((p) => p.signNumber == signNumber)
                .toList() ??
            [];

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: AstroCard(
            onTap: () => _navigateToSignDetail(sign.id),
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: elementColor,
                    width: 4,
                  ),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: elementColor.withOpacity(0.1),
                              ),
                            ),
                            Text(
                              sign.symbol,
                              style: TextStyle(
                                fontSize: 26,
                                color: elementColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    sign.name,
                                    style: AstroTheme.headingSmall,
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: elementColor.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      sign.element.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: elementColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${sign.sanskritName} • Ruled by ${sign.rulingPlanet}',
                                style: AstroTheme.bodyMedium.copyWith(
                                  color: Colors.white60,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.north_east_rounded,
                          color: Colors.white24,
                          size: 20,
                        ),
                      ],
                    ),
                    // --- Planets in this sign ---
                    if (planetsInSign.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: planetsInSign.map((p) {
                          final pColor = _getPlanetColor(p.name);
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: pColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                              border:
                                  Border.all(color: pColor.withOpacity(0.25)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  p.name,
                                  style: TextStyle(
                                      color: pColor,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${p.signDegree.toStringAsFixed(1)}° • H${p.houseNumber}',
                                  style: TextStyle(
                                      color: pColor.withOpacity(0.7),
                                      fontSize: 10),
                                ),
                                if (p.isRetrograde)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 3),
                                    child: Text('R',
                                        style: TextStyle(
                                            color: Colors.red.shade300,
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold)),
                                  ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getElementColor(String element) {
    switch (element.toLowerCase()) {
      case 'fire':
        return const Color(0xFFff6b35);
      case 'earth':
        return const Color(0xFF4caf50);
      case 'air':
        return const Color(0xFF03a9f4);
      case 'water':
        return const Color(0xFF9c27b0);
      default:
        return AstroTheme.accentGold;
    }
  }

  void _navigateToPlanetDetail(String planetId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PlanetDetailScreen(planetId: planetId),
      ),
    );
  }

  void _navigateToHouseDetail(int houseNumber) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => HouseDetailScreen(houseNumber: houseNumber),
      ),
    );
  }

  void _navigateToSignDetail(String signId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SignDetailScreen(signId: signId),
      ),
    );
  }

  Widget _buildChartVisibilityToggle() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Show only icon on very small screens
        final showText = MediaQuery.of(context).size.width > 360;

        return GestureDetector(
          onTap: () {
            setState(() {
              _showChart = !_showChart;
            });
          },
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: showText ? 14 : 10,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: _showChart
                  ? AstroTheme.accentCyan.withOpacity(0.15)
                  : AstroTheme.cardBackground,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: _showChart
                    ? AstroTheme.accentCyan.withOpacity(0.5)
                    : Colors.white.withOpacity(0.1),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _showChart ? Icons.visibility : Icons.visibility_off,
                  size: 16,
                  color: _showChart ? AstroTheme.accentCyan : Colors.white54,
                ),
                if (showText) ...[
                  const SizedBox(width: 6),
                  Text(
                    _showChart ? 'Hide' : 'Show',
                    style: TextStyle(
                      color:
                          _showChart ? AstroTheme.accentCyan : Colors.white54,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
