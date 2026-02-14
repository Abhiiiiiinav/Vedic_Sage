import 'package:flutter/material.dart';
import '../../../app/theme.dart';
import '../../../shared/widgets/section_card.dart';
import '../../../shared/widgets/astro_background.dart';
import '../../../core/services/user_session.dart';
import '../../../core/astro/darakaraka_engine.dart';
import '../../../core/astro/trine_compatibility_engine.dart';
import '../../../core/constants/darakaraka_education_data.dart';

class RelationshipReportScreen extends StatefulWidget {
  const RelationshipReportScreen({super.key});

  @override
  State<RelationshipReportScreen> createState() => _RelationshipReportScreenState();
}

class _RelationshipReportScreenState extends State<RelationshipReportScreen> {
  JaiminiKaraka? _darakaraka;
  DarakarakaData? _dkData;
  TrineAnalysis? _trineAnalysis;
  Map<String, dynamic>? _dkTrinePosition;
  Map<String, dynamic>? _dkLagnaRelation;
  List<JaiminiKaraka> _allKarakas = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final session = UserSession();
    
    // Debug logging
    print('🔍 RelationshipReport: Checking session data...');
    print('   hasData: ${session.hasData}');
    print('   birthDetails: ${session.birthDetails != null}');
    print('   birthChart: ${session.birthChart != null}');
    
    if (session.birthChart != null) {
      final chart = session.birthChart!;
      
      print('📊 Chart data keys: ${chart.keys.toList()}');
      print('📊 Planets: ${chart['planets']}');
      print('📊 Ascendant: ${chart['ascendant']}');
      print('📊 ascDegree: ${chart['ascDegree']}');
      print('📊 planetDegrees type: ${chart['planetDegrees'].runtimeType}');
      print('📊 planetDegrees: ${chart['planetDegrees']}');
      print('📊 planetHouseMap: ${chart['planetHouseMap']}');
      
      try {
        // Calculate Darakaraka
        _darakaraka = DarakarakaEngine.getDarakaraka(chart);
        print('💕 Darakaraka calculated: $_darakaraka');
        
        if (_darakaraka != null) {
          _dkData = DarakarakaEducation.getData(_darakaraka!.planet);
          print('📚 DK Data loaded: ${_dkData?.planetName}');
          
          // Calculate DK-Trine position
          _dkTrinePosition = TrineCompatibilityEngine.analyzeDKTrinePosition(
            chartData: chart,
            dkHouse: _darakaraka!.houseNumber,
            dkPlanet: _darakaraka!.planet,
          );
          
          // Calculate DK-Lagna relation
          _dkLagnaRelation = DarakarakaEngine.analyzeDKLagnaRelation(chart);
        }
        
        // Calculate all Karakas
        _allKarakas = DarakarakaEngine.calculateCharakarakas(chartData: chart);
        print('📊 All Karakas: ${_allKarakas.length}');
        
        // Calculate Trine Analysis
        _trineAnalysis = TrineCompatibilityEngine.analyzeDharmaTrine(chart);
        
      } catch (e, stack) {
        print('❌ Error calculating Darakaraka: $e');
        print('Stack: $stack');
      }
      
      setState(() => _isLoading = false);
    } else {
      print('⚠️ No birth chart data available');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AstroBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _darakaraka == null
                  ? _buildNeedDataView()
                  : _buildReportView(),
        ),
      ),
    );
  }

  Widget _buildNeedDataView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 64, color: Colors.white38),
            const SizedBox(height: 16),
            Text('Birth Details Needed', style: AstroTheme.headingSmall),
            const SizedBox(height: 8),
            Text(
              'Enter your birth details in Profile to generate your personalized Relationship Report',
              textAlign: TextAlign.center,
              style: AstroTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportView() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildHeader(),
        const SizedBox(height: 24),
        _buildDKHighlight(),
        const SizedBox(height: 20),
        _buildPartnerPsychologyCard(),
        const SizedBox(height: 16),
        _buildRelationshipThemesCard(),
        const SizedBox(height: 16),
        _buildShadowExpressionCard(),
        const SizedBox(height: 16),
        _buildRealLifePatternsCard(),
        const SizedBox(height: 16),
        _buildGrowthPathCard(),
        const SizedBox(height: 24),
        _buildDKPositionCard(),
        const SizedBox(height: 16),
        _buildTrineAnalysisCard(),
        const SizedBox(height: 16),
        _buildDKTrineConnectionCard(),
        const SizedBox(height: 16),
        _buildPracticalCompatibilityCard(),
        const SizedBox(height: 16),
        _buildAllKarakasCard(),
        const SizedBox(height: 16),
        _buildSafetyNotesCard(),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AstroTheme.accentPink.withOpacity(0.3),
            AstroTheme.accentPurple.withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ),
          const SizedBox(height: 8),
          const Icon(Icons.favorite, color: AstroTheme.accentPink, size: 48),
          const SizedBox(height: 12),
          Text('Relationship Psychology Report', style: AstroTheme.headingLarge),
          const SizedBox(height: 8),
          Text(
            'Jaimini Karaka Analysis & Trinal Compatibility',
            style: AstroTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDKHighlight() {
    if (_darakaraka == null) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AstroTheme.accentPink.withOpacity(0.4),
            AstroTheme.accentGold.withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AstroTheme.accentPink.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Text(_getPlanetSymbol(_darakaraka!.planet), style: const TextStyle(fontSize: 28)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your Darakaraka (DK)',
                      style: TextStyle(fontSize: 13, color: Colors.white70),
                    ),
                    Text(
                      _dkData?.planetName ?? _darakaraka!.planet,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '"${_dkData?.archetype ?? 'The Partner'}"',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildDKChip('Sign: ${_darakaraka!.signName}'),
                    const SizedBox(width: 8),
                    _buildDKChip('House: ${_darakaraka!.houseNumber}'),
                    const SizedBox(width: 8),
                    _buildDKChip('${_darakaraka!.degree.toStringAsFixed(1)}°'),
                  ],
                ),
                if (_darakaraka!.nakshatraName != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Nakshatra: ${_darakaraka!.nakshatraName}',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Darakaraka reveals your relationship karma — the psychology of partners you attract and the lessons love teaches you.',
            style: TextStyle(color: Colors.white.withOpacity(0.8), height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildDKChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildPartnerPsychologyCard() {
    if (_dkData == null) return const SizedBox.shrink();
    final psych = _dkData!.partnerPsychology;
    
    return SectionCard(
      title: 'Partner Psychology',
      icon: Icons.psychology,
      accentColor: AstroTheme.accentPink,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPsychologyRow('Emotional Needs', psych.emotionalNeeds),
          const SizedBox(height: 12),
          _buildPsychologyRow('Communication Style', psych.communicationStyle),
          const SizedBox(height: 12),
          _buildPsychologyRow('Conflict Style', psych.conflictStyle),
          const SizedBox(height: 12),
          _buildPsychologyRow('Attachment Pattern', psych.attachmentPattern),
          const SizedBox(height: 16),
          Text('Core Partner Traits:', style: AstroTheme.headingSmall.copyWith(fontSize: 14)),
          const SizedBox(height: 8),
          ...psych.coreTraits.map((trait) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                const Icon(Icons.star, color: AstroTheme.accentPink, size: 14),
                const SizedBox(width: 8),
                Expanded(child: Text(trait, style: AstroTheme.bodyMedium)),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildPsychologyRow(String label, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: AstroTheme.accentPink, fontWeight: FontWeight.w600, fontSize: 13)),
        const SizedBox(height: 4),
        Text(content, style: AstroTheme.bodyMedium.copyWith(height: 1.5)),
      ],
    );
  }

  Widget _buildRelationshipThemesCard() {
    if (_dkData == null) return const SizedBox.shrink();
    final themes = _dkData!.relationshipThemes;
    
    return SectionCard(
      title: 'Relationship Themes',
      icon: Icons.sync_alt,
      accentColor: AstroTheme.accentPurple,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildThemeBox('Support Pattern', themes.supportPattern, Icons.support),
          const SizedBox(height: 12),
          _buildThemeBox('Power Balance', themes.powerBalance, Icons.balance),
          const SizedBox(height: 12),
          _buildThemeBox('Stability Level', themes.stabilityLevel, Icons.trending_flat),
          const SizedBox(height: 16),
          Text('Key Dynamics:', style: AstroTheme.headingSmall.copyWith(fontSize: 14)),
          const SizedBox(height: 8),
          ...themes.keyDynamics.map((dynamic) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.arrow_right, color: AstroTheme.accentPurple, size: 18),
                const SizedBox(width: 6),
                Expanded(child: Text(dynamic, style: AstroTheme.bodyMedium)),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildThemeBox(String title, String content, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AstroTheme.accentPurple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AstroTheme.accentPurple.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AstroTheme.accentPurple, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 2),
                Text(content, style: AstroTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShadowExpressionCard() {
    if (_dkData == null) return const SizedBox.shrink();
    final shadow = _dkData!.shadowExpression;
    
    return SectionCard(
      title: 'Shadow Expression',
      icon: Icons.warning_amber,
      accentColor: const Color(0xFFff6b35),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFff6b35).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFff6b35).withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('When Stressed:', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFFff6b35), fontSize: 13)),
                const SizedBox(height: 4),
                Text(shadow.whenStressed, style: AstroTheme.bodyMedium.copyWith(height: 1.5)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text('Common Breakdown Causes:', style: AstroTheme.headingSmall.copyWith(fontSize: 14)),
          const SizedBox(height: 8),
          ...shadow.breakdownCauses.map((cause) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.remove_circle_outline, color: Color(0xFFff6b35), size: 16),
                const SizedBox(width: 8),
                Expanded(child: Text(cause, style: AstroTheme.bodyMedium)),
              ],
            ),
          )),
          const SizedBox(height: 16),
          Text('Warning Signals:', style: AstroTheme.headingSmall.copyWith(fontSize: 14)),
          const SizedBox(height: 8),
          ...shadow.warningSignals.map((signal) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.report_problem_outlined, color: Colors.amber, size: 16),
                const SizedBox(width: 8),
                Expanded(child: Text(signal, style: AstroTheme.bodyMedium)),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildRealLifePatternsCard() {
    if (_dkData == null) return const SizedBox.shrink();
    final patterns = _dkData!.realLifePatterns;
    
    return SectionCard(
      title: 'Real-Life Patterns',
      icon: Icons.visibility,
      accentColor: AstroTheme.accentCyan,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPatternRow('Dating', patterns.datingPattern, Icons.date_range),
          const SizedBox(height: 12),
          _buildPatternRow('Marriage', patterns.marriagePattern, Icons.favorite),
          const SizedBox(height: 12),
          _buildPatternRow('Long-Term', patterns.longTermPattern, Icons.timeline),
          const SizedBox(height: 16),
          Text('Observable Signals:', style: AstroTheme.headingSmall.copyWith(fontSize: 14)),
          const SizedBox(height: 8),
          ...patterns.observableSignals.map((signal) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.check_circle, color: AstroTheme.accentCyan, size: 16),
                const SizedBox(width: 8),
                Expanded(child: Text(signal, style: AstroTheme.bodyMedium)),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildPatternRow(String stage, String pattern, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AstroTheme.accentCyan.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AstroTheme.accentCyan, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(stage, style: TextStyle(fontWeight: FontWeight.w600, color: AstroTheme.accentCyan, fontSize: 13)),
              const SizedBox(height: 2),
              Text(pattern, style: AstroTheme.bodyMedium.copyWith(height: 1.4)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGrowthPathCard() {
    if (_dkData == null) return const SizedBox.shrink();
    final growth = _dkData!.growthPath;
    
    return SectionCard(
      title: 'Growth Path',
      icon: Icons.trending_up,
      accentColor: const Color(0xFF4caf50),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF4caf50).withOpacity(0.2),
                  const Color(0xFF4caf50).withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Core Lesson:', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF4caf50))),
                const SizedBox(height: 6),
                Text(growth.coreLesson, style: AstroTheme.bodyLarge.copyWith(color: Colors.white)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text('Skills Needed:', style: AstroTheme.headingSmall.copyWith(fontSize: 14)),
          const SizedBox(height: 8),
          ...growth.skillsNeeded.map((skill) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                const Icon(Icons.build, color: Color(0xFF4caf50), size: 16),
                const SizedBox(width: 8),
                Expanded(child: Text(skill, style: AstroTheme.bodyMedium)),
              ],
            ),
          )),
          const SizedBox(height: 16),
          Text('Practical Actions:', style: AstroTheme.headingSmall.copyWith(fontSize: 14)),
          const SizedBox(height: 8),
          ...growth.practicalActions.map((action) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.play_circle, color: Color(0xFF4caf50), size: 16),
                const SizedBox(width: 8),
                Expanded(child: Text(action, style: AstroTheme.bodyMedium)),
              ],
            ),
          )),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AstroTheme.accentGold.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AstroTheme.accentGold.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome, color: AstroTheme.accentGold),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Ultimate Gift:', style: TextStyle(fontWeight: FontWeight.w600, color: AstroTheme.accentGold)),
                      const SizedBox(height: 4),
                      Text(growth.ultimateGift, style: AstroTheme.bodyMedium),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDKPositionCard() {
    if (_dkData == null || _darakaraka == null) return const SizedBox.shrink();
    
    final signMod = _dkData!.signModifications[_darakaraka!.signName] ?? 'Position adds unique flavor.';
    final houseMod = _dkData!.houseModifications[_darakaraka!.houseNumber.toString()] ?? 'House placement shapes influence.';
    
    return SectionCard(
      title: 'DK Position Analysis',
      icon: Icons.location_on,
      accentColor: AstroTheme.accentGold,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPositionBox('DK in ${_darakaraka!.signName}', signMod, AstroTheme.accentGold),
          const SizedBox(height: 12),
          _buildPositionBox('DK in House ${_darakaraka!.houseNumber}', houseMod, AstroTheme.accentPurple),
          if (_darakaraka!.nakshatraName != null) ...[
            const SizedBox(height: 12),
            _buildPositionBox(
              'DK in ${_darakaraka!.nakshatraName}',
              'Nakshatra adds subconscious emotional patterns to partner psychology.',
              AstroTheme.accentCyan,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPositionBox(String title, String content, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 6),
          Text(content, style: AstroTheme.bodyMedium.copyWith(height: 1.4)),
        ],
      ),
    );
  }

  Widget _buildTrineAnalysisCard() {
    if (_trineAnalysis == null) return const SizedBox.shrink();
    
    return SectionCard(
      title: 'Dharma Trine (1-5-9) Analysis',
      icon: Icons.auto_awesome,
      accentColor: AstroTheme.accentGold,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildTrineHouseChip('H1', _trineAnalysis!.house1Planet, 'Identity'),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward, color: Colors.white38, size: 16),
              const SizedBox(width: 8),
              _buildTrineHouseChip('H5', _trineAnalysis!.house5Planet, 'Creativity'),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward, color: Colors.white38, size: 16),
              const SizedBox(width: 8),
              _buildTrineHouseChip('H9', _trineAnalysis!.house9Planet, 'Dharma'),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _getHarmonyColor(_trineAnalysis!.harmonyLevel).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _getHarmonyColor(_trineAnalysis!.harmonyLevel).withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Harmony Level: ${_trineAnalysis!.harmonyLevel}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _getHarmonyColor(_trineAnalysis!.harmonyLevel),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(_trineAnalysis!.interpretation, style: AstroTheme.bodyMedium.copyWith(height: 1.5)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text('Strengths:', style: AstroTheme.headingSmall.copyWith(fontSize: 14)),
          const SizedBox(height: 8),
          ..._trineAnalysis!.strengths.map((s) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                const Icon(Icons.add_circle, color: Color(0xFF4caf50), size: 14),
                const SizedBox(width: 8),
                Expanded(child: Text(s, style: AstroTheme.bodyMedium)),
              ],
            ),
          )),
          const SizedBox(height: 12),
          Text('Challenges:', style: AstroTheme.headingSmall.copyWith(fontSize: 14)),
          const SizedBox(height: 8),
          ..._trineAnalysis!.challenges.map((c) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                const Icon(Icons.warning, color: Colors.amber, size: 14),
                const SizedBox(width: 8),
                Expanded(child: Text(c, style: AstroTheme.bodyMedium)),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildTrineHouseChip(String house, String planet, String meaning) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: AstroTheme.accentGold.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(house, style: const TextStyle(fontWeight: FontWeight.bold, color: AstroTheme.accentGold)),
            Text(planet, style: AstroTheme.bodyMedium),
            Text(meaning, style: TextStyle(fontSize: 10, color: Colors.white54)),
          ],
        ),
      ),
    );
  }

  Widget _buildDKTrineConnectionCard() {
    if (_dkTrinePosition == null) return const SizedBox.shrink();
    
    return SectionCard(
      title: 'DK + Trine Connection',
      icon: Icons.link,
      accentColor: AstroTheme.accentPink,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AstroTheme.accentPink.withOpacity(0.15),
                  AstroTheme.accentPurple.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _dkTrinePosition!['connectionType'] ?? 'Connection Type',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AstroTheme.accentPink),
                ),
                const SizedBox(height: 8),
                Text(
                  _dkTrinePosition!['interpretation'] ?? '',
                  style: AstroTheme.bodyMedium.copyWith(height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text('Implications:', style: AstroTheme.headingSmall.copyWith(fontSize: 14)),
          const SizedBox(height: 8),
          ...(_dkTrinePosition!['implications'] as List<dynamic>? ?? []).map((imp) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.arrow_right, color: AstroTheme.accentPink, size: 18),
                const SizedBox(width: 6),
                Expanded(child: Text(imp.toString(), style: AstroTheme.bodyMedium)),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildPracticalCompatibilityCard() {
    final advice = DarakarakaEducation.getCommunicationAdvice(_darakaraka?.planet ?? '');
    final skills = DarakarakaEducation.getRequiredSkills(_darakaraka?.planet ?? '');
    
    return SectionCard(
      title: 'Practical Relationship Skills',
      icon: Icons.handshake,
      accentColor: const Color(0xFF4caf50),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF4caf50).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF4caf50).withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.chat, color: Color(0xFF4caf50), size: 18),
                    SizedBox(width: 8),
                    Text('Best Communication Approach:', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF4caf50))),
                  ],
                ),
                const SizedBox(height: 8),
                Text(advice, style: AstroTheme.bodyMedium.copyWith(height: 1.5)),
              ],
            ),
          ),
          if (skills.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text('Essential Skills for This DK:', style: AstroTheme.headingSmall.copyWith(fontSize: 14)),
            const SizedBox(height: 8),
            ...skills.map((skill) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Color(0xFF4caf50), size: 16),
                  const SizedBox(width: 8),
                  Expanded(child: Text(skill, style: AstroTheme.bodyMedium)),
                ],
              ),
            )),
          ],
        ],
      ),
    );
  }

  Widget _buildAllKarakasCard() {
    return SectionCard(
      title: 'All Jaimini Charakarakas',
      icon: Icons.list,
      accentColor: AstroTheme.accentPurple,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your planetary hierarchy by degree:',
            style: AstroTheme.bodyMedium.copyWith(color: Colors.white60),
          ),
          const SizedBox(height: 12),
          ..._allKarakas.map((k) => _buildKarakaRow(k)),
        ],
      ),
    );
  }

  Widget _buildKarakaRow(JaiminiKaraka karaka) {
    final isAK = karaka.karakaName == 'Atmakaraka';
    final isDK = karaka.karakaName == 'Darakaraka';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDK 
            ? AstroTheme.accentPink.withOpacity(0.1)
            : isAK 
                ? AstroTheme.accentGold.withOpacity(0.1)
                : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: isDK 
            ? Border.all(color: AstroTheme.accentPink.withOpacity(0.3))
            : isAK
                ? Border.all(color: AstroTheme.accentGold.withOpacity(0.3))
                : null,
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(_getPlanetSymbol(karaka.planet), style: const TextStyle(fontSize: 18)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(karaka.karakaName, style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isDK ? AstroTheme.accentPink : (isAK ? AstroTheme.accentGold : Colors.white),
                )),
                Text(
                  '${DarakarakaEngine.planetNames[karaka.planet]} in ${karaka.signName}',
                  style: AstroTheme.bodyMedium.copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            '${karaka.degree.toStringAsFixed(1)}°',
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildSafetyNotesCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.info_outline, color: Colors.white54, size: 18),
              SizedBox(width: 8),
              Text('About This Analysis', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white70)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '• This describes relationship patterns, not destiny\n'
            '• Free will and conscious choice always apply\n'
            '• All interpretations are growth-oriented\n'
            '• No "good" or "bad" - only "ease" or "effort-based growth"\n'
            '• Self-awareness is the goal, not prediction',
            style: AstroTheme.bodyMedium.copyWith(height: 1.6, color: Colors.white60),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AstroTheme.accentGold.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _dkData?.masterInsight ?? DarakarakaEducation.masterRule,
              style: TextStyle(fontStyle: FontStyle.italic, color: AstroTheme.accentGold, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  String _getPlanetSymbol(String abbr) {
    const symbols = {
      'Su': '☉', 'Mo': '☽', 'Ma': '♂', 'Me': '☿',
      'Ju': '♃', 'Ve': '♀', 'Sa': '♄', 'Ra': '☊', 'Ke': '☋',
    };
    return symbols[abbr] ?? abbr;
  }

  Color _getHarmonyColor(String level) {
    switch (level) {
      case 'High': return const Color(0xFF4caf50);
      case 'Effort-Based': return const Color(0xFFff9800);
      case 'Latent': return AstroTheme.accentCyan;
      default: return AstroTheme.accentPurple;
    }
  }
}
