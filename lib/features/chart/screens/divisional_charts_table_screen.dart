import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../app/theme.dart';
import '../../../shared/widgets/animated_cosmic_background.dart';
import '../../../core/services/user_session.dart';
import '../../../core/services/svg_chart_parser.dart';
import '../../../core/services/direct_svg_chart_service.dart';

/// ─── Divisional Charts Table ───
/// Displays a comprehensive tabular view of planet placements across
/// all 16 Parashara divisional charts (D1 → D60).
///
/// Each row = one planet, each column = one divisional chart.
/// Cell value = the zodiac sign the planet is placed in for that chart.
///
/// This is the primary validation tool for checking chart accuracy.
class DivisionalChartsTableScreen extends StatefulWidget {
  const DivisionalChartsTableScreen({super.key});

  @override
  State<DivisionalChartsTableScreen> createState() =>
      _DivisionalChartsTableScreenState();
}

class _DivisionalChartsTableScreenState
    extends State<DivisionalChartsTableScreen> with TickerProviderStateMixin {
  bool _isLoading = true;
  String? _errorMessage;
  late TabController _tabController;

  // Extracted data per division
  final Map<String, SvgExtractionResult> _extractions = {};

  // Divisions that are fetching from API
  final Set<String> _fetchingDivisions = {};

  // Chart metadata
  static const List<_DivisionInfo> _divisions = [
    _DivisionInfo('d1', 'D1', 'Rasi', Color(0xFF667eea)),
    _DivisionInfo('d2', 'D2', 'Hora', Color(0xFFf5a623)),
    _DivisionInfo('d3', 'D3', 'Drekkana', Color(0xFF00d4ff)),
    _DivisionInfo('d4', 'D4', 'Chaturthamsa', Color(0xFF34c759)),
    _DivisionInfo('d7', 'D7', 'Saptamsa', Color(0xFFff6b9d)),
    _DivisionInfo('d9', 'D9', 'Navamsa', Color(0xFFe91e63)),
    _DivisionInfo('d10', 'D10', 'Dasamsa', Color(0xFF7B61FF)),
    _DivisionInfo('d12', 'D12', 'Dwadasamsa', Color(0xFF5856d6)),
    _DivisionInfo('d16', 'D16', 'Shodasamsa', Color(0xFF8e99a4)),
    _DivisionInfo('d20', 'D20', 'Vimsamsa', Color(0xFF0d9488)),
    _DivisionInfo('d24', 'D24', 'Siddhamsa', Color(0xFF2196f3)),
    _DivisionInfo('d27', 'D27', 'Nakshatramsa', Color(0xFFffcc00)),
    _DivisionInfo('d30', 'D30', 'Trimsamsa', Color(0xFFff3b30)),
    _DivisionInfo('d40', 'D40', 'Khavedamsa', Color(0xFF9c27b0)),
    _DivisionInfo('d45', 'D45', 'Akshavedamsa', Color(0xFF795548)),
    _DivisionInfo('d60', 'D60', 'Shashtyamsa', Color(0xFF607d8b)),
  ];

  static const List<String> _planets = [
    'Asc',
    'Su',
    'Mo',
    'Ma',
    'Me',
    'Ju',
    'Ve',
    'Sa',
    'Ra',
    'Ke'
  ];

  static const List<String> _planetFullNames = [
    'Ascendant',
    'Sun',
    'Moon',
    'Mars',
    'Mercury',
    'Jupiter',
    'Venus',
    'Saturn',
    'Rahu',
    'Ketu'
  ];

  static const List<String> _signAbbreviations = [
    'Ari',
    'Tau',
    'Gem',
    'Can',
    'Leo',
    'Vir',
    'Lib',
    'Sco',
    'Sag',
    'Cap',
    'Aqu',
    'Pis'
  ];

  static const List<String> _signFullNames = [
    'Aries',
    'Taurus',
    'Gemini',
    'Cancer',
    'Leo',
    'Virgo',
    'Libra',
    'Scorpio',
    'Sagittarius',
    'Capricorn',
    'Aquarius',
    'Pisces'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final session = UserSession();
    if (!session.hasData) {
      setState(() {
        _isLoading = false;
        _errorMessage =
            'No chart data found.\nPlease calculate your birth chart first.';
      });
      return;
    }

    // Extract from saved divisional SVGs
    final divisionalSvgs =
        session.birthChart?['divisionalSvgs'] as Map<String, dynamic>?;

    if (divisionalSvgs != null && divisionalSvgs.isNotEmpty) {
      for (final entry in divisionalSvgs.entries) {
        final key = entry.key.toLowerCase();
        final svg = entry.value?.toString() ?? '';
        if (svg.isNotEmpty && svg.contains('<svg')) {
          _extractions[key] = SvgChartParser.extractPositions(svg);
        }
      }
    }

    // D1 priority: SVG extraction > API planetary payload > local varga fallback.
    final apiPlanets =
        session.birthChart?['apiPlanets'] as Map<String, dynamic>?;
    final housePlanets =
        session.birthChart?['housePlanets'] as Map<String, dynamic>?;
    if (_isD1MissingOrIncomplete() &&
        apiPlanets != null &&
        apiPlanets.isNotEmpty) {
      _loadD1FromApiPlanets(apiPlanets, housePlanets: housePlanets);
    }

    // Fallback 1: use previously extracted divisional data if present.
    final divisionalExtracted =
        session.birthChart?['divisionalExtracted'] as Map<String, dynamic>?;
    if (divisionalExtracted != null && divisionalExtracted.isNotEmpty) {
      _loadFromDivisionalExtracted(divisionalExtracted);
    }

    // Fallback 2: use native-engine varga output (works without API/SVG).
    final vargas = session.birthChart?['vargas'] as Map<String, dynamic>?;
    debugPrint('\n?? CHART DATA AVAILABLE:');
    debugPrint('  Has vargas: ${vargas != null} (keys: ${vargas?.keys.toList()})');
    debugPrint('  Has apiPlanets: ${session.birthChart?['apiPlanets'] != null}');
    debugPrint('  Has divisionalExtracted: ${session.birthChart?['divisionalExtracted'] != null}');
    debugPrint('  Has divisionalSvgs: ${session.birthChart?['divisionalSvgs'] != null}\n');
    if (vargas != null && vargas.isNotEmpty) {
      _loadFromVargas(vargas);
    }

    setState(() {
      _isLoading = false;
    });

    // Auto-fetch all missing divisions if none were loaded from cache
    final loadedCount = _extractions.values.where((e) => e.hasData).length;
    if (loadedCount == 0 && session.birthDetails != null) {
      // No cached SVGs available — fetch all from API automatically
      debugPrint('📡 No cached divisional SVGs found, auto-fetching all...');
      _fetchAllMissing();
    }
  }

  void _loadFromDivisionalExtracted(Map<String, dynamic> divisionalExtracted) {
    for (final entry in divisionalExtracted.entries) {
      final normalizedKey = entry.key.toLowerCase();
      final key =
          normalizedKey.startsWith('d') ? normalizedKey : 'd$normalizedKey';
      final raw = entry.value;
      if (raw is! Map) continue;
      if (_extractions[key]?.hasData ?? false) continue;

      final rawAsc = raw['ascendant_sign'] ?? raw['ascendantSign'];
      final asc = _toInt(rawAsc);

      final rawPlanetSigns = raw['planet_signs'] ?? raw['planetSigns'];
      final planetSigns = <String, int>{};
      if (rawPlanetSigns is Map) {
        debugPrint('  ?? Found ${rawPlanetSigns.length} planet entries');
        for (final planetEntry in rawPlanetSigns.entries) {
          final abbr = _normalizePlanetAbbrev(planetEntry.key.toString());
          final sign = _toInt(planetEntry.value);
          if (abbr != null && sign >= 1 && sign <= 12) {
            planetSigns[abbr] = sign;
          }
        }
      }

      final extraction = _buildExtractionFromSigns(
        ascendantSign: asc,
        planetSigns: planetSigns,
      );
      if (extraction.hasData) {
        _extractions[key] = extraction;
      }
    }
  }

  void _loadFromVargas(Map<String, dynamic> vargas) {
    debugPrint('---------------------------------------------------');
    debugPrint('?? LOADING VARGA DATA FROM LOCAL CALCULATIONS');
    debugPrint('Available varga keys: ${vargas.keys.toList()}');
    debugPrint('---------------------------------------------------');
    for (final div in _divisions) {
      debugPrint('\n?? Processing ${div.label} (key: ${div.key})');
      // Skip if already loaded
      if (_extractions[div.key]?.hasData ?? false) continue;
      final varga = vargas[div.label]; // div.label is uppercase like 'D1'
      debugPrint('  Looking for key: ${div.label}');
      if (varga is! Map) {
        debugPrint('  ? ${div.label} data is not a Map, type: ${varga.runtimeType}');
        continue;
      }
      debugPrint('  ? ${div.label} data found, processing...');

      final asc = _toInt(varga['ascendantSign'] ?? varga['ascendant_sign']);
      final rawPlanetSigns = varga['planetSigns'] ?? varga['planet_signs'];
      final planetSigns = <String, int>{};
      if (rawPlanetSigns is Map) {
        debugPrint('  ?? Found ${rawPlanetSigns.length} planet entries');
        for (final planetEntry in rawPlanetSigns.entries) {
          final abbr = _normalizePlanetAbbrev(planetEntry.key.toString());
          final sign = _toInt(planetEntry.value);
          if (abbr != null && sign >= 1 && sign <= 12) {
            planetSigns[abbr] = sign;
          }
        }
      }

      final extraction = _buildExtractionFromSigns(
        ascendantSign: asc,
        planetSigns: planetSigns,
      );
      if (extraction.hasData) {
        _extractions[div.key.toLowerCase()] = extraction;
      }
    }
  }

  bool _isD1MissingOrIncomplete() {
    final d1 = _extractions['d1'];
    if (d1 == null) return true;
    if (!d1.hasData) return true;
    return d1.planetSigns.length < _planets.length;
  }

  void _loadD1FromApiPlanets(
    Map<String, dynamic> apiPlanets, {
    Map<String, dynamic>? housePlanets,
  }) {
    const nameToAbbrev = {
      'Sun': 'Su',
      'Moon': 'Mo',
      'Mars': 'Ma',
      'Mercury': 'Me',
      'Jupiter': 'Ju',
      'Venus': 'Ve',
      'Saturn': 'Sa',
      'Rahu': 'Ra',
      'Ketu': 'Ke',
    };

    int ascendantSign = 0;
    final planetSigns = <String, int>{};
    final planetsInHouses = <int, List<String>>{
      for (int i = 1; i <= 12; i++) i: <String>[],
    };

    for (final entry in apiPlanets.entries) {
      final key = entry.key.trim();
      final value = entry.value;
      if (value is! Map) continue;
      final node = _toStringKeyedMap(value);

      if (key == 'Ascendant') {
        ascendantSign = _toInt(
          node['current_sign'] ??
              node['sign_num'] ??
              node['zodiac_sign_number'],
        );
        continue;
      }

      final planetAbbrev = nameToAbbrev[key];
      if (planetAbbrev == null) continue;

      final signNum = _toInt(
        node['current_sign'] ?? node['sign_num'] ?? node['zodiac_sign_number'],
      );
      if (signNum >= 1 && signNum <= 12) {
        planetSigns[planetAbbrev] = signNum;
      }

      final houseNum = _toInt(node['house_number'] ?? node['house']);
      if (houseNum >= 1 && houseNum <= 12) {
        planetsInHouses[houseNum]!.add(planetAbbrev);
      }
    }

    // Fallback ascendant from existing chart metadata when API Ascendant is absent.
    if (ascendantSign < 1 || ascendantSign > 12) {
      final ascIndex = _toInt(UserSession().birthChart?['ascSignIndex']);
      final fallbackAsc = ascIndex + 1;
      if (fallbackAsc >= 1 && fallbackAsc <= 12) {
        ascendantSign = fallbackAsc;
      }
    }

    // Optional housePlanets fallback injected by ChartScreen.
    if (planetsInHouses.values.every((v) => v.isEmpty) &&
        housePlanets != null &&
        housePlanets.isNotEmpty) {
      for (final entry in housePlanets.entries) {
        final houseNum = _toInt(entry.key);
        if (houseNum < 1 || houseNum > 12) continue;
        final planets = entry.value;
        if (planets is! List) continue;
        for (final p in planets) {
          final abbr = _normalizePlanetAbbrev(p.toString());
          if (abbr != null && _planets.contains(abbr)) {
            planetsInHouses[houseNum]!.add(abbr);
          }
        }
      }
    }

    // If houses still missing, compute from signs + ascendant.
    if (planetsInHouses.values.every((v) => v.isEmpty) &&
        ascendantSign >= 1 &&
        ascendantSign <= 12) {
      for (final entry in planetSigns.entries) {
        final house = SvgChartParser.signToHouse(entry.value, ascendantSign);
        planetsInHouses[house]!.add(entry.key);
      }
    }

    final houseSigns = <int, Map<String, dynamic>>{
      for (int house = 1; house <= 12; house++)
        house: (ascendantSign >= 1 && ascendantSign <= 12)
            ? (() {
                final sign = ((ascendantSign + house - 2) % 12) + 1;
                return {
                  'sign_number': sign,
                  'sign_name': SvgChartParser.getSignName(sign),
                };
              })()
            : {
                'sign_number': 0,
                'sign_name': 'Unknown',
              }
    };

    final status =
        (ascendantSign >= 1 && ascendantSign <= 12) && planetSigns.isNotEmpty
            ? (planetSigns.length < _planets.length ? 'partial' : 'ok')
            : (planetSigns.isNotEmpty ? 'partial' : 'failed');

    final extraction = SvgExtractionResult(
      ascendantSign:
          (ascendantSign >= 1 && ascendantSign <= 12) ? ascendantSign : 0,
      ascendantName: (ascendantSign >= 1 && ascendantSign <= 12)
          ? SvgChartParser.getSignName(ascendantSign)
          : 'Unknown',
      planetSigns: planetSigns,
      planetsInHouses: planetsInHouses,
      houseSigns: houseSigns,
      rawTextNodeCount: 0,
      extractedPlanetCount: planetSigns.length,
      extractionStatus: status,
    );

    if (extraction.hasData) {
      _extractions['d1'] = extraction;
    }
  }

  SvgExtractionResult _buildExtractionFromSigns({
    required int ascendantSign,
    required Map<String, int> planetSigns,
  }) {
    final planetsInHouses = <int, List<String>>{
      for (int i = 1; i <= 12; i++) i: <String>[],
    };

    if (ascendantSign >= 1 && ascendantSign <= 12) {
      for (final entry in planetSigns.entries) {
        final house = SvgChartParser.signToHouse(entry.value, ascendantSign);
        planetsInHouses[house]!.add(entry.key);
      }
    }

    final houseSigns = <int, Map<String, dynamic>>{
      for (int house = 1; house <= 12; house++)
        house: (ascendantSign >= 1 && ascendantSign <= 12)
            ? (() {
                final sign = ((ascendantSign + house - 2) % 12) + 1;
                return {
                  'sign_number': sign,
                  'sign_name': SvgChartParser.getSignName(sign),
                };
              })()
            : {
                'sign_number': 0,
                'sign_name': 'Unknown',
              }
    };

    return SvgExtractionResult(
      ascendantSign:
          (ascendantSign >= 1 && ascendantSign <= 12) ? ascendantSign : 0,
      ascendantName: (ascendantSign >= 1 && ascendantSign <= 12)
          ? SvgChartParser.getSignName(ascendantSign)
          : 'Unknown',
      planetSigns: planetSigns,
      planetsInHouses: planetsInHouses,
      houseSigns: houseSigns,
      rawTextNodeCount: 0,
      extractedPlanetCount: planetSigns.length,
      extractionStatus: planetSigns.isNotEmpty ? 'ok' : 'failed',
    );
  }

  int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value.trim()) ?? 0;
    return 0;
  }

  Map<String, dynamic> _toStringKeyedMap(Map<dynamic, dynamic> raw) {
    return raw.map((key, value) => MapEntry(key.toString(), value));
  }

  String? _normalizePlanetAbbrev(String raw) {
    const fullToAbbrev = {
      'sun': 'Su',
      'moon': 'Mo',
      'mars': 'Ma',
      'mercury': 'Me',
      'jupiter': 'Ju',
      'venus': 'Ve',
      'saturn': 'Sa',
      'rahu': 'Ra',
      'ketu': 'Ke',
    };

    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;

    if (_planets.contains(trimmed)) return trimmed;

    final normalized = trimmed.toLowerCase();
    return fullToAbbrev[normalized];
  }

  /// Fetch a single missing division from API on demand
  Future<void> _fetchDivision(String divisionKey) async {
    if (_fetchingDivisions.contains(divisionKey)) return;

    final session = UserSession();
    if (session.birthDetails == null) return;

    setState(() => _fetchingDivisions.add(divisionKey));

    try {
      final details = session.birthDetails!;
      final service = DirectSvgChartService();
      final request = SvgChartRequest(
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

      final result = await service.fetchChartAsJson(
        division: divisionKey,
        request: request,
      );

      if (result['success'] == true && result['svg'] != null) {
        final svg = result['svg'] as String;
        _extractions[divisionKey] = SvgChartParser.extractPositions(svg);
        debugPrint('✅ Fetched $divisionKey successfully');
      } else {
        debugPrint(
            '⚠️ API returned failure for $divisionKey: ${result['error'] ?? 'unknown'}');
      }
    } catch (e) {
      debugPrint('❌ Error fetching $divisionKey: $e');
    } finally {
      if (mounted) {
        setState(() => _fetchingDivisions.remove(divisionKey));
      }
    }
  }

  /// Fetch all missing divisions
  Future<void> _fetchAllMissing() async {
    int successCount = 0;
    int failCount = 0;

    for (final div in _divisions) {
      debugPrint('\n?? Processing ${div.label} (key: ${div.key})');
      if (!_extractions.containsKey(div.key) ||
          !(_extractions[div.key]?.hasData ?? false)) {
        await _fetchDivision(div.key);
        if (_extractions[div.key]?.hasData ?? false) {
          successCount++;
        } else {
          failCount++;
        }
      }
    }

    if (mounted && (successCount > 0 || failCount > 0)) {
      final msg = successCount > 0
          ? '✅ Loaded $successCount charts${failCount > 0 ? ', $failCount failed' : ''}'
          : '⚠️ Could not fetch charts. API may be unavailable.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: successCount > 0
              ? const Color(0xFF34c759)
              : Colors.orange.shade700,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AnimatedCosmicBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              if (!_isLoading && _errorMessage == null) _buildTabBar(),
              Expanded(
                child: _isLoading
                    ? _buildLoadingState()
                    : _errorMessage != null
                        ? _buildErrorState()
                        : TabBarView(
                            controller: _tabController,
                            children: [
                              _buildPlanetSignsTable(),
                              _buildHouseOccupantsView(),
                            ],
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Header ───
  Widget _buildHeader() {
    final loadedCount = _extractions.values.where((e) => e.hasData).length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 12, 8, 4),
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
                  'Divisional Charts Table',
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '$loadedCount / ${_divisions.length} charts loaded',
                  style: GoogleFonts.quicksand(
                    fontSize: 12,
                    color: loadedCount == _divisions.length
                        ? const Color(0xFF34c759)
                        : Colors.white54,
                  ),
                ),
              ],
            ),
          ),
          if (!_isLoading && _errorMessage == null) ...[
            // Fetch all missing button
            if (_extractions.values.where((e) => e.hasData).length <
                _divisions.length)
              IconButton(
                onPressed: _fetchAllMissing,
                icon: const Icon(Icons.cloud_download_outlined,
                    color: AstroTheme.accentGold, size: 22),
                tooltip: 'Fetch all missing charts',
              ),
            IconButton(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh,
                  color: AstroTheme.accentGold, size: 22),
              tooltip: 'Refresh',
            ),
          ],
        ],
      ),
    );
  }

  // ─── Tab Bar ───
  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white54,
        labelStyle:
            GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 13),
        unselectedLabelStyle: GoogleFonts.outfit(fontSize: 13),
        dividerHeight: 0,
        tabs: const [
          Tab(text: '🪐  Planet Signs'),
          Tab(text: '🏠  House View'),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // TAB 1: Planet → Sign across all divisions
  // ═══════════════════════════════════════════════════════════════

  Widget _buildPlanetSignsTable() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(8, 12, 8, 24),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: _buildDataTable(),
      ),
    );
  }

  Widget _buildDataTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(
            Colors.white.withOpacity(0.06),
          ),
          dataRowColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.hovered)) {
              return Colors.white.withOpacity(0.05);
            }
            return Colors.transparent;
          }),
          columnSpacing: 4,
          horizontalMargin: 8,
          headingRowHeight: 52,
          dataRowMinHeight: 40,
          dataRowMaxHeight: 44,
          columns: [
            DataColumn(
              label: Text(
                'Planet',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
            // One column per division
            ..._divisions.map((div) {
              final hasData = _extractions[div.key]?.hasData ?? false;
              final isFetching = _fetchingDivisions.contains(div.key);
              return DataColumn(
                label: GestureDetector(
                  onTap: !hasData && !isFetching
                      ? () => _fetchDivision(div.key)
                      : null,
                  child: SizedBox(
                    width: 34,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            div.label,
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w700,
                              color: hasData ? div.color : Colors.white38,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        const SizedBox(height: 2),
                        if (isFetching)
                          SizedBox(
                            width: 10,
                            height: 10,
                            child: CircularProgressIndicator(
                              strokeWidth: 1.5,
                              color: div.color,
                            ),
                          )
                        else
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: hasData
                                  ? const Color(0xFF34c759)
                                  : Colors.white12,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
          rows: List.generate(_planets.length, (planetIdx) {
            final planet = _planets[planetIdx];
            final planetName = _planetFullNames[planetIdx];
            return DataRow(
              cells: [
                // Planet name cell
                DataCell(
                  SizedBox(
                    width: 94,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _planetEmoji(planet),
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            planetName,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w600,
                              color: _planetColor(planet),
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Sign for this planet in each division
                ..._divisions.map((div) {
                  final extraction = _extractions[div.key];
                  if (extraction == null || !extraction.hasData) {
                    return DataCell(
                      Center(
                        child: Text(
                          '—',
                          style: GoogleFonts.quicksand(
                            color: Colors.white12,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    );
                  }

                  // Handle Ascendant specially - it's stored in ascendantSign, not planetSigns
                  final signNum = planet == 'Asc'
                      ? extraction.ascendantSign
                      : extraction.planetSigns[planet];
                  if (signNum == null || signNum < 1 || signNum > 12) {
                    return DataCell(
                      Center(
                        child: Text(
                          '—',
                          style: GoogleFonts.quicksand(
                            color: Colors.white,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    );
                  }

                  final signAbbrev = _signAbbreviations[signNum - 1];
                  final signFull = _signFullNames[signNum - 1];
                  final signColor = _signColor(signNum);

                  return DataCell(
                    Tooltip(
                      message: '$planetName in $signFull (${div.fullName})',
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: signColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: signColor.withOpacity(0.2),
                            width: 0.5,
                          ),
                        ),
                        child: Text(
                          signAbbrev,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: signColor,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            );
          }),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // TAB 2: House occupants per division
  // ═══════════════════════════════════════════════════════════════

  Widget _buildHouseOccupantsView() {
    final loadedDivisions =
        _divisions.where((d) => _extractions[d.key]?.hasData ?? false).toList();

    if (loadedDivisions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.grid_off_rounded,
                  color: Colors.white24, size: 60),
              const SizedBox(height: 16),
              Text(
                'No divisional data loaded yet.\nTap the cloud icon to fetch charts.',
                textAlign: TextAlign.center,
                style:
                    GoogleFonts.quicksand(color: Colors.white54, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 32),
      physics: const BouncingScrollPhysics(),
      itemCount: loadedDivisions.length,
      itemBuilder: (context, index) {
        final div = loadedDivisions[index];
        final extraction = _extractions[div.key]!;
        return _buildHouseCard(div, extraction);
      },
    );
  }

  Widget _buildHouseCard(_DivisionInfo div, SvgExtractionResult extraction) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            div.color.withOpacity(0.12),
            div.color.withOpacity(0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: div.color.withOpacity(0.2)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: div.color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              div.label,
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: div.color,
              ),
            ),
          ),
          title: Text(
            div.fullName,
            style: GoogleFonts.outfit(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          subtitle: Text(
            'Asc: ${extraction.ascendantName}  •  ${extraction.planetCount} planets',
            style: GoogleFonts.quicksand(
              fontSize: 11,
              color: Colors.white54,
            ),
          ),
          iconColor: Colors.white54,
          collapsedIconColor: Colors.white38,
          children: [
            // House grid: 4 columns × 3 rows
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 6,
                mainAxisSpacing: 6,
                childAspectRatio: 1.3,
              ),
              itemCount: 12,
              itemBuilder: (context, houseIdx) {
                final houseNum = houseIdx + 1;
                final planets = extraction.planetsInHouses[houseNum] ?? [];
                final signInfo = extraction.houseSigns[houseNum];
                final signNum = signInfo?['sign_number'] as int? ?? 0;

                return Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: planets.isNotEmpty
                        ? Colors.white.withOpacity(0.06)
                        : Colors.white.withOpacity(0.02),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: planets.isNotEmpty
                          ? div.color.withOpacity(0.3)
                          : Colors.white.withOpacity(0.05),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // House number + sign
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'H$houseNum',
                            style: GoogleFonts.outfit(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: Colors.white54,
                            ),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            signNum > 0 ? _signAbbreviations[signNum - 1] : '—',
                            style: GoogleFonts.outfit(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: signNum > 0
                                  ? _signColor(signNum).withOpacity(0.8)
                                  : Colors.white24,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      // Planets
                      if (planets.isNotEmpty)
                        Wrap(
                          spacing: 3,
                          runSpacing: 2,
                          alignment: WrapAlignment.center,
                          children: planets.map((p) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 1),
                              decoration: BoxDecoration(
                                color: _planetColor(p).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                p,
                                style: GoogleFonts.outfit(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: _planetColor(p),
                                ),
                              ),
                            );
                          }).toList(),
                        )
                      else
                        Text(
                          '—',
                          style: GoogleFonts.quicksand(
                            fontSize: 10,
                            color: Colors.white12,
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // LOADING / ERROR STATES
  // ═══════════════════════════════════════════════════════════════

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AstroTheme.accentGold),
          const SizedBox(height: 20),
          Text('Loading chart data...',
              style: GoogleFonts.quicksand(
                  color: Colors.white.withOpacity(0.7), fontSize: 14)),
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
              style: GoogleFonts.quicksand(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AstroTheme.accentGold,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // UTILITY: Colors & Emojis
  // ═══════════════════════════════════════════════════════════════

  String _planetEmoji(String abbrev) {
    const emojis = {
      'Asc': '??',
      'Su': '☀️',
      'Mo': '🌙',
      'Ma': '♂️',
      'Me': '☿️',
      'Ju': '♃',
      'Ve': '♀️',
      'Sa': '♄',
      'Ra': '🐍',
      'Ke': '🔥',
    };
    return emojis[abbrev] ?? '⭐';
  }

  Color _planetColor(String abbrev) {
    const colors = {
      'Asc': Color(0xFFffd700),
      'Su': Color(0xFFf5a623),
      'Mo': Color(0xFFe0e0e0),
      'Ma': Color(0xFFff3b30),
      'Me': Color(0xFF34c759),
      'Ju': Color(0xFFffcc00),
      'Ve': Color(0xFFff69b4),
      'Sa': Color(0xFF8e8e93),
      'Ra': Color(0xFF7B61FF),
      'Ke': Color(0xFFff6b6b),
    };
    return colors[abbrev] ?? Colors.white;
  }

  /// Color based on zodiac element:
  /// Fire (1,5,9) = red, Earth (2,6,10) = green,
  /// Air (3,7,11) = cyan, Water (4,8,12) = blue
  Color _signColor(int signNum) {
    final element = (signNum - 1) % 4;
    switch (element) {
      case 0: // Fire: Aries, Leo, Sagittarius
        return const Color(0xFFff6b6b);
      case 1: // Earth: Taurus, Virgo, Capricorn
        return const Color(0xFF34c759);
      case 2: // Air: Gemini, Libra, Aquarius
        return const Color(0xFF00d4ff);
      case 3: // Water: Cancer, Scorpio, Pisces
        return const Color(0xFF5ac8fa);
      default:
        return Colors.white;
    }
  }
}

// ═══════════════════════════════════════════════════════════════
// ─── Division Info ───
// ═══════════════════════════════════════════════════════════════

class _DivisionInfo {
  final String key;
  final String label;
  final String fullName;
  final Color color;

  const _DivisionInfo(this.key, this.label, this.fullName, this.color);
}















