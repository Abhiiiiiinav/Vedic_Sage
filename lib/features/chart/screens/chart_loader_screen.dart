import 'package:flutter/material.dart';
import '../../../app/theme.dart';
import '../../../shared/widgets/astro_background.dart';
import '../../../core/services/user_session.dart';
import '../../../core/models/birth_details.dart';
import '../../../core/astro/kundali_orchestrator.dart';
import '../../../core/services/chart_api_service.dart' as api;

/// Intermediate loading screen that navigates immediately
/// and loads chart data in background - creates instant feel
class ChartLoaderScreen extends StatefulWidget {
  final BirthDetails birthDetails;
  final String name;

  const ChartLoaderScreen({
    super.key,
    required this.birthDetails,
    required this.name,
  });

  @override
  State<ChartLoaderScreen> createState() => _ChartLoaderScreenState();
}

class _ChartLoaderScreenState extends State<ChartLoaderScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  String _statusMessage = 'Connecting to cosmic servers...';
  int _progress = 0;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    // Start loading immediately
    _loadChartData();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadChartData() async {
    final details = widget.birthDetails;
    final birthDateTime = details.birthDateTime;

    try {
      // Step 1: Try Flask API first for accurate positions
      _updateStatus('Connecting to astrology server...', 10);
      
      final chartApiService = api.ChartApiService();
      final apiDetails = api.BirthDetails(
        year: birthDateTime.year,
        month: birthDateTime.month,
        date: birthDateTime.day,
        hours: birthDateTime.hour,
        minutes: birthDateTime.minute,
        seconds: 0,
        latitude: details.latitude,
        longitude: details.longitude,
        timezone: details.timezoneOffset,
      );
      
      // Check if API is available
      final isApiAvailable = await chartApiService.healthCheck();
      
      Map<String, dynamic>? apiPlanetData;
      bool usingApi = false;
      
      if (isApiAvailable) {
        _updateStatus('Fetching accurate planetary data...', 25);
        
        try {
          apiPlanetData = await chartApiService.getPlanetaryData(apiDetails);
          if (apiPlanetData.isNotEmpty) {
            usingApi = true;
            print('✅ Using API data for accurate positions');
          }
        } catch (e) {
          print('⚠️ API fetch failed, falling back to local engine: $e');
        }
      }

      _updateStatus('Computing planetary positions...', 40);
      
      // Step 2: Generate chart using local engine (for Dasha, structure, etc.)
      final result = AccurateKundaliEngine.generateChart(
        birthDateTime: birthDateTime,
        latitude: details.latitude,
        longitude: details.longitude,
        timezoneOffset: details.timezoneOffset,
      );

      _updateStatus('Computing divisional charts...', 60);
      await Future.delayed(const Duration(milliseconds: 100));

      _updateStatus('Calculating Vimshottari Dasha...', 75);
      await Future.delayed(const Duration(milliseconds: 100));

      // Step 3: If API data available, merge it with local engine results
      KundaliResult finalResult = result;
      if (usingApi && apiPlanetData != null) {
        _updateStatus('Applying accurate positions...', 85);
        finalResult = _mergeApiDataWithResult(result, apiPlanetData);
      }

      // Step 4: Convert to legacy format for existing UI
      _updateStatus('Preparing chart display...', 90);
      
      final chartData = _convertToLegacyFormat(finalResult);
      
      // Add API data flag
      chartData['usingApiData'] = usingApi;
      if (apiPlanetData != null) {
        chartData['apiPlanets'] = apiPlanetData;
      }

      // Step 5: Save to session and database
      _updateStatus('Saving to session...', 95);
      
      final session = UserSession();
      await session.saveSession(
        details: details,
        chart: chartData,
      );

      _updateStatus('✅ Chart ready!', 100);

      // Print validation data
      print('');
      print('🎯 CHART RESULTS (${usingApi ? "API" : "Local Engine"}):');
      print(AccurateKundaliEngine.getChartSummary(finalResult));
      if (!usingApi) {
        ChartValidator.printComparison(finalResult);
      }

      // Small delay for user to see completion
      await Future.delayed(const Duration(milliseconds: 300));

      if (!mounted) return;

      // Navigate to main app
      Navigator.pushReplacementNamed(context, '/home');

    } catch (e, stack) {
      print('❌ Chart loading error: $e');
      print(stack);
      
      if (!mounted) return;

      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
  }
  
  /// Merge API planetary data with local engine result
  KundaliResult _mergeApiDataWithResult(KundaliResult localResult, Map<String, dynamic> apiData) {
    // Build new houses array from API planet positions
    List<List<String>> newHouses = List.generate(12, (_) => <String>[]);
    Map<String, Map<String, dynamic>> newPlanets = {};
    
    // Planet abbreviations
    const abbrevMap = {
      'Sun': 'Su', 'Moon': 'Mo', 'Mars': 'Ma', 'Mercury': 'Me',
      'Jupiter': 'Ju', 'Venus': 'Ve', 'Saturn': 'Sa', 'Rahu': 'Ra', 'Ketu': 'Ke',
    };
    
    // Process API planets
    int? ascSign;
    for (var entry in apiData.entries) {
      final name = entry.key;
      final data = entry.value;
      
      if (data is! Map) continue;
      
      // Get Ascendant sign
      if (name == 'Ascendant') {
        ascSign = data['current_sign'] as int?;
        continue;
      }
      
      // Skip non-Vedic planets
      if (!abbrevMap.containsKey(name)) continue;
      
      // Get house number from API (1-indexed)
      final houseNum = data['house_number'] as int? ?? 1;
      final abbrev = abbrevMap[name]!;
      
      // Add to houses (0-indexed array, house 1 = index 0)
      if (houseNum >= 1 && houseNum <= 12) {
        newHouses[houseNum - 1].add(abbrev);
      }
      
      // Build planet data
      final degree = (data['fullDegree'] ?? data['full_degree'] ?? 0.0) as num;
      final signDegree = (data['normDegree'] ?? data['current_sign_degree'] ?? 0.0) as num;
      final signNum = (data['current_sign'] ?? 1) as int;
      final nakshatra = data['nakshatra'] ?? data['nakshatra_name'];
      final nakshatraPada = data['nakshatra_pada'] ?? data['nakshatra_quarter'];
      final isRetro = data['isRetro'] ?? data['is_retro'] ?? false;
      
      newPlanets[name] = {
        'degree': degree.toDouble(),
        'degreeInSign': signDegree.toDouble(),
        'signIndex': signNum - 1, // 0-indexed
        'signName': _getSignName(signNum),
        'house': houseNum,
        'nakshatra': nakshatra,
        'nakshatraIndex': _getNakshatraIndex(degree.toDouble()),
        'pada': nakshatraPada,
        'isRetrograde': isRetro,
      };
    }
    
    // Update ascendant if available
    Map<String, dynamic> newAscendant = Map.from(localResult.ascendant);
    if (ascSign != null) {
      newAscendant['signIndex'] = ascSign - 1;
      newAscendant['signName'] = _getSignName(ascSign);
    }
    
    return KundaliResult(
      planets: newPlanets.isEmpty ? localResult.planets : newPlanets,
      ascendant: newAscendant,
      houses: newHouses.any((h) => h.isNotEmpty) ? newHouses : localResult.houses,
      vargas: localResult.vargas,
      dasha: localResult.dasha,
      meta: localResult.meta,
      validation: localResult.validation,
    );
  }
  
  String _getSignName(int signNum) {
    const signs = ['Aries', 'Taurus', 'Gemini', 'Cancer', 'Leo', 'Virgo',
                   'Libra', 'Scorpio', 'Sagittarius', 'Capricorn', 'Aquarius', 'Pisces'];
    return signs[(signNum - 1).clamp(0, 11)];
  }
  
  int _getNakshatraIndex(double degree) {
    return (degree / 13.333333333).floor() + 1;
  }

  /// Convert new engine format to legacy format for existing UI
  Map<String, dynamic> _convertToLegacyFormat(KundaliResult result) {
    // Build houses list
    List<List<String>> houses = result.houses;
    
    // Build planet positions
    Map<String, dynamic> planetPositions = {};
    for (var entry in result.planets.entries) {
      planetPositions[entry.key] = {
        'longitude': entry.value['degree'],
        'sign': entry.value['signName'],
        'signIndex': entry.value['signIndex'],
        'house': entry.value['house'],
        'degreeInSign': entry.value['degreeInSign'],
      };
    }
    
    // Build planet degrees
    Map<String, double> planetDegrees = {};
    Map<String, int> planetSigns = {};
    Map<String, int> planetHouses = {};
    
    for (var entry in result.planets.entries) {
      planetDegrees[entry.key] = entry.value['degree'];
      planetSigns[entry.key] = entry.value['signIndex'] + 1; // 1-indexed
      planetHouses[entry.key] = entry.value['house'];
    }
    
    return {
      'houses': houses,
      'planetPositions': planetPositions,
      'planetDegrees': planetDegrees,
      'planetSigns': planetSigns,
      'planetHouses': planetHouses,
      'ascendant': result.ascendant['degree'],
      'ascDegree': result.ascendant['degree'],
      'ascSign': result.ascendant['signName'],
      'ascSignIndex': result.ascendant['signIndex'],
      'moonNakshatra': result.planets['Moon']?['nakshatraIndex'],
      'moonNakshatraName': result.planets['Moon']?['nakshatra'],
      'moonPada': result.planets['Moon']?['pada'],
      'dasha': result.dasha,
      'vargas': result.vargas,
      'meta': result.meta,
      'validation': result.validation,
    };
  }

  void _updateStatus(String message, int progress) {
    if (!mounted) return;
    setState(() {
      _statusMessage = message;
      _progress = progress;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AstroBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: _hasError ? _buildErrorUI() : _buildLoadingUI(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingUI() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Animated cosmic loader
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AstroTheme.accentGold.withOpacity(0.3 + _pulseController.value * 0.3),
                    AstroTheme.accentCyan.withOpacity(0.1 + _pulseController.value * 0.1),
                    Colors.transparent,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AstroTheme.accentGold.withOpacity(0.3 * _pulseController.value),
                    blurRadius: 30 + 20 * _pulseController.value,
                    spreadRadius: 5 + 10 * _pulseController.value,
                  ),
                ],
              ),
              child: const Icon(
                Icons.auto_awesome,
                size: 48,
                color: AstroTheme.accentGold,
              ),
            );
          },
        ),

        const SizedBox(height: 40),

        // Status message
        Text(
          _statusMessage,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(height: 24),

        // Progress bar
        SizedBox(
          width: 200,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: _progress / 100,
              minHeight: 8,
              backgroundColor: Colors.white.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(
                _progress > 80 ? AstroTheme.accentCyan : AstroTheme.accentGold,
              ),
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Progress percentage
        Text(
          '$_progress%',
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 12,
          ),
        ),

        const SizedBox(height: 16),
        
        // Engine badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AstroTheme.accentCyan.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AstroTheme.accentCyan.withOpacity(0.3)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.verified, size: 14, color: AstroTheme.accentCyan),
              SizedBox(width: 6),
              Text(
                'Local Accurate Engine',
                style: TextStyle(
                  color: AstroTheme.accentCyan,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 48),

        // Birth details summary
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Column(
            children: [
              Text(
                widget.name,
                style: const TextStyle(
                  color: AstroTheme.accentGold,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.birthDetails.cityName,
                style: const TextStyle(color: Colors.white60, fontSize: 14),
              ),
              Text(
                _formatDate(widget.birthDetails.birthDateTime),
                style: const TextStyle(color: Colors.white60, fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorUI() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.error_outline,
          size: 64,
          color: Colors.redAccent,
        ),
        const SizedBox(height: 24),
        const Text(
          'Failed to calculate chart',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          _errorMessage ?? 'Unknown error',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white60),
        ),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _hasError = false;
                  _errorMessage = null;
                  _progress = 0;
                });
                _loadChartData();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AstroTheme.accentGold,
                foregroundColor: Colors.black,
              ),
            ),
            const SizedBox(width: 16),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white70,
                side: const BorderSide(color: Colors.white24),
              ),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ],
    );
  }

  String _formatDate(DateTime dt) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final amPm = dt.hour >= 12 ? 'PM' : 'AM';
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year} at $hour:${dt.minute.toString().padLeft(2, '0')} $amPm';
  }
}
