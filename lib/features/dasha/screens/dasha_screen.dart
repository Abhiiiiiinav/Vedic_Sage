import 'package:flutter/material.dart';
import '../../../app/theme.dart';
import '../../../shared/widgets/astro_card.dart';
import '../../../shared/widgets/section_card.dart';
import '../../../shared/widgets/astro_background.dart';
import '../../../core/astro/vimshottari_engine.dart';
import '../../../core/astro/nakshatra_dasha_map.dart';
import '../../../core/astro/dasha_lagna.dart';
import '../../../core/models/dasha_models.dart';
import '../../../core/services/gemini_service.dart';
import '../../../core/services/user_session.dart';
import '../../../core/astro/accurate_kundali_engine.dart';
import '../../calculator/screens/birth_details_screen.dart';
import '../widgets/dasha_timeline.dart';
import '../widgets/dasha_info_card.dart';
import 'package:intl/intl.dart';

class DashaScreen extends StatefulWidget {
  const DashaScreen({super.key});

  @override
  State<DashaScreen> createState() => _DashaScreenState();
}

class _DashaScreenState extends State<DashaScreen> {
  final GeminiService _geminiService = GeminiService();
  final UserSession _session = UserSession();
  List<Map<String, dynamic>>? _mahadashas;
  Map<String, dynamic>? _currentDasha;
  Map<String, dynamic>? _selectedDasha;
  String? _aiInterpretation;
  bool _isLoading = true;
  bool _isAiLoading = false;
  bool _noData = false;
  
  @override
  void initState() {
    super.initState();
    _calculateDashas();
  }
  
  void _calculateDashas() {
    setState(() {
      _isLoading = true;
      _noData = false;
    });
    
    if (!_session.hasData) {
      setState(() {
        _isLoading = false;
        _noData = true;
      });
      return;
    }

    try {
      final chartData = _session.birthChart!;
      final birthDetails = _session.birthDetails!;
      
      // Use actual Moon degree from calculated chart
      final moonDegree = KundaliEngine.getMoonDegree(chartData);
      
      // Calculate starting Mahadasha
      final startingMD = VimshottariEngine.getStartingMahadasha(moonDegree);
      
      // Use actual birth date
      final birthDate = birthDetails.birthDateTime;
      
      final mahadashas = VimshottariEngine.generateMahadashas(
        startLord: startingMD['lord'],
        startRemainingYears: startingMD['remainingYears'],
        birthDate: birthDate,
      );
      
      // Find current Dasha
      final currentDasha = VimshottariEngine.getCurrentDasha(
        mahadashas: mahadashas,
        currentDate: DateTime.now(),
      );
      
      setState(() {
        _mahadashas = mahadashas;
        _currentDasha = currentDasha;
        _selectedDasha = currentDasha;
        _isLoading = false;
      });
      
      _fetchAiInterpretation();
    } catch (e) {
      print('Error calculating Dashas: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchAiInterpretation() async {
    if (_selectedDasha == null) return;
    
    setState(() {
      _isAiLoading = true;
    });
    
    try {
      final md = _selectedDasha!['md'] as Map<String, dynamic>;
      final ad = _selectedDasha!['ad'] as Map<String, dynamic>;
      final chartData = _session.birthChart;
      
      if (chartData == null) {
        setState(() {
          _isAiLoading = false;
          _aiInterpretation = "Chart data not available.";
        });
        return;
      }
      
      // Extract house of Mahadasha lord from real chart with proper type handling
      final planetHouseMapRaw = chartData['planetHouseMap'] as Map<String, dynamic>?;
      int dashaLagna = 1; // default
      
      if (planetHouseMapRaw != null && md['lord'] != null) {
        final lordHouse = planetHouseMapRaw[md['lord']];
        if (lordHouse is int) {
          dashaLagna = lordHouse;
        }
      }
      
      final interpretation = await _geminiService.generateDashaInterpretation(
        mahadashaLord: md['fullName'] as String? ?? 'Unknown',
        antardashaLord: ad['fullName'] as String? ?? 'Unknown',
        dashaLagnaHouse: dashaLagna.toString(),
        context: "Explain main life theme and practical advice based on this lord's placement.",
      );
      
      setState(() {
        _aiInterpretation = interpretation;
        _isAiLoading = false;
      });
    } catch (e) {
      print('Error fetching AI interpretation: $e');
      setState(() {
        _isAiLoading = false;
        _aiInterpretation = "The stars are currently obscured. Focus on the main themes of your dasha lord.";
      });
    }
  }

  void _onDashaSelected(Map<String, dynamic> dashaMap) {
    setState(() {
      // If selecting a different mahadasha, we default to its first antardasha or calculate active AD for that period if it overlaps with now?
      // For simplicity in this timeline, let's assume dashaMap represents the Mahadasha period. 
      // Unlike _currentDasha which has specific MD/AD calculated for specific date, mahadashas list has just MD info usually?
      // Wait, VimshottariEngine.generateMahadashas returns List<Map<String, dynamic>> where each map is {'md': ..., 'ad_list': ...} ? 
      // Let's check VimshottariEngine.generateMahadashas structure. 
      // The `mahadashas` list contains map with 'md' (MahadashaModel) and potentially 'end_date' etc.
      // But `_currentDasha` structure is {'md': x, 'ad': y}. 
      // If the user clicks a Mahadasha in timeline, we should probably show that Mahadasha and maybe the FIRST Antardasha or the one active if it's the current period.
      
      // Let's inspect `dashaMap` passed from timeline. It is one item from `_mahadashas`.
      // We need to construct a "selectedDasha" object that looks like `{'md': ..., 'ad': ...}` for the UI to consume.
      
      final mdModel = MahadashaModel.fromMap(dashaMap['md'] as Map<String, dynamic>);
      
      // If this is the current active mahadasha, revert to showing the exact current AD.
      if (_currentDasha != null && (_currentDasha!['md'] as Map<String, dynamic>)['lord'] == mdModel.lord) {
        _selectedDasha = _currentDasha;
      } else {
        // Otherwise, show the first AD of this Mahadasha or just a placeholder? 
        // VimshottariEngine doesn't seem to pre-calculate all ADs in the `generateMahadashas` list item unless we look.
        // Actually, let's look at `VimshottariEngine` again or just generate ADs for this MD.
        final ads = VimshottariEngine.generateAntardashas(
          mdLord: mdModel.lord,
          mdYears: mdModel.years,
          mdStartDate: mdModel.startDate,
        );
        
        // Check if ads is not null and not empty
        if (ads.isEmpty) {
          // Fallback: use the current dasha if available
          _selectedDasha = _currentDasha;
          return;
        }
        
        // Default to first AD
        final firstAd = ads[0]; 
        _selectedDasha = {
          'md': dashaMap['md'],
          'ad': firstAd,  // firstAd is already a Map<String, dynamic>
        };
      }
      _fetchAiInterpretation(); // Refresh AI for selected period
    });
  }

  Widget _buildNoDataView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.hourglass_empty, size: 64, color: AstroTheme.accentGold),
            const SizedBox(height: 24),
            const Text(
              'No Birth Chart Found',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Calculate your birth chart first to see your Dasha periods',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BirthDetailsScreen()),
                );
              },
              icon: const Icon(Icons.calculate),
              label: const Text('Calculate Chart'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AstroTheme.accentGold,
                foregroundColor: AstroTheme.scaffoldBackground,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        const SizedBox(height: 8),
        Text(
          '⏳ Your Dasha Timeline',
          style: AstroTheme.headingLarge.copyWith(color: AstroTheme.accentGold),
        ),
        const SizedBox(height: 8),
        Text(
          'Life periods ruled by different planets',
          style: AstroTheme.bodyLarge.copyWith(color: Colors.white70),
        ),
      ],
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return AstroBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _noData 
                  ? _buildNoDataView()
                  : ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 24),
                        if (_mahadashas != null) ...[
                          DashaTimeline(
                            mahadashas: _mahadashas!,
                            currentDasha: _selectedDasha, // Highlight selected
                            onDashaSelected: _onDashaSelected,
                          ),
                          const SizedBox(height: 24),
                        ],
                        if (_selectedDasha != null) ...[
                          _buildMahadashaInfo(),
                          const SizedBox(height: 16),
                          _buildAntardashaInfo(),
                          const SizedBox(height: 16),
                          _buildDashaLagnaCard(),
                          const SizedBox(height: 16),
                          _buildFocusAdviceCard(),
                        ],
                        const SizedBox(height: 16),
                        _buildSystemExplainerCard(),
                        const SizedBox(height: 40),
                      ],
                    ),
        ),
      ),
    );
  }

  Widget _buildMahadashaInfo() {
    final md = _selectedDasha!['md'] as Map<String, dynamic>;
    final mdModel = MahadashaModel.fromMap(md);
    
    // Logic for remaining time or total duration label
    final isCurrent = _currentDasha != null && (_currentDasha!['md'] as Map<String, dynamic>)['lord'] == mdModel.lord;
    final remainingDays = mdModel.endDate.difference(DateTime.now()).inDays;
    
    return DashaInfoCard(
      title: '🌟 Mahadasha',
      icon: Icons.timeline,
      accentColor: AstroTheme.accentGold,
      lordName: mdModel.fullName,
      durationLabel: '${mdModel.years.toStringAsFixed(1)} years',
      startDate: mdModel.startDate,
      endDate: mdModel.endDate,
      remainingTimeLabel: isCurrent 
          ? '$remainingDays days remaining' 
          : 'Duration: ${mdModel.years} yrs',
    );
  }

  Widget _buildAntardashaInfo() {
    final ad = _selectedDasha!['ad'] as Map<String, dynamic>;
    final adModel = AntardashaModel.fromMap(ad);
    
    final isCurrent = _currentDasha != null && 
        (_currentDasha!['md'] as Map<String, dynamic>)['lord'] == (_selectedDasha!['md'] as Map<String, dynamic>)['lord'] &&
        (_currentDasha!['ad'] as Map<String, dynamic>)['lord'] == adModel.lord;

    final remainingDays = adModel.daysRemaining(DateTime.now());

    return DashaInfoCard(
      title: '✨ Antardasha',
      icon: Icons.auto_awesome,
      accentColor: AstroTheme.accentCyan,
      lordName: adModel.fullName,
      durationLabel: '${adModel.days} days',
      startDate: adModel.startDate,
      endDate: adModel.endDate,
      remainingTimeLabel: isCurrent 
          ? '$remainingDays days remaining'
          : '${adModel.days} days duration',
    );
  }

  
  Widget _buildDashaLagnaCard() {
    final md = _selectedDasha!['md'] as Map<String, dynamic>?;
    if (md == null) return const SizedBox.shrink();
    
    final chartData = _session.birthChart;
    if (chartData == null) return const SizedBox.shrink();
    
    final planetHouseMap = chartData['planetHouseMap'] as Map<String, dynamic>?;
    if (planetHouseMap == null) return const SizedBox.shrink();
    
    // Convert dynamic map to Map<String, int>
    final planetHouseMapInt = <String, int>{};
    planetHouseMap.forEach((key, value) {
      if (value is int) {
        planetHouseMapInt[key] = value;
      }
    });
    
    final dashaLagna = DashaLagna.getDashaLagnaHouse(
      mdLord: md['lord'] as String,
      planetHouseMap: planetHouseMapInt,
    );
    
    // We can also calculate which house Dasha Lagna falls into relative to Birth Lagna?
    // Actually DashaLagna.getDashaLagnaHouse returns the house number (1-12) where the planet resides.
    // This IS the house number relative to Birth Lagna.
    
    return SectionCard(
      title: '🎯 Dasha Lagna (Temporary Ascendant)',
      icon: Icons.my_location,
      accentColor: AstroTheme.accentPurple,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'During ${md['fullName'] as String? ?? 'Unknown'} Mahadasha, House $dashaLagna becomes your temporary ascendant',
            style: AstroTheme.bodyLarge.copyWith(height: 1.6),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AstroTheme.accentPurple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '💡 What This Means:',
                  style: TextStyle(fontWeight: FontWeight.bold, color: AstroTheme.accentPurple),
                ),
                const SizedBox(height: 8),
                Text(
                  'Life focus shifts to themes of House $dashaLagna. Events and experiences are interpreted from this new perspective.',
                  style: AstroTheme.bodyMedium.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFocusAdviceCard() {
    return SectionCard(
      title: '📌 AI Cosmic Insights',
      icon: Icons.psychology,
      accentColor: const Color(0xFF4caf50),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_isAiLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_aiInterpretation != null)
            Text(
              _aiInterpretation!,
              style: AstroTheme.bodyLarge.copyWith(height: 1.6),
            )
          else
            const Text('Loading insights from the stars...'),
          
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: _isAiLoading ? null : _fetchAiInterpretation,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Regenerate Insights'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF4caf50),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAdvicePoint(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFF4caf50).withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, color: Color(0xFF4caf50), size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4caf50),
                  ),
                ),
                Text(
                  description,
                  style: AstroTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSystemExplainerCard() {
    return AstroCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.school, color: AstroTheme.accentPurple),
              SizedBox(width: 12),
              Text(
                'Understanding Vimshottari Dasha',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Life is divided into a 120-year cycle ruled by 9 planets. Your starting period depends on Moon\'s Nakshatra at birth.',
            style: AstroTheme.bodyLarge.copyWith(height: 1.8),
          ),
          const SizedBox(height: 12),
          const Text(
            '🔹 Mahadasha = Main theme (6-20 years)\n🔹 Antardasha = Sub-period events\n🔹 Dasha Lagna = Temporary life focus',
            style: TextStyle(color: Colors.white70, height: 1.8),
          ),
          const SizedBox(height: 16),
          Text(
            '📚 Learn more in the Roadmap section',
            style: AstroTheme.bodyMedium.copyWith(
              color: AstroTheme.accentCyan,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
