import 'package:flutter/material.dart';
import '../../../app/theme.dart';
import '../../../shared/widgets/astro_card.dart';
import '../../../shared/widgets/section_card.dart';
import '../../../core/constants/nakshatra_data.dart';
import '../../../core/models/models.dart';
import '../../../core/services/gemini_service.dart';
import '../../../core/utils/name_analysis_engine.dart';
import '../../../core/utils/name_validator.dart';
import '../../../core/utils/vedic_name_analyzer.dart';
import '../../../core/astro/nakshatra_syllables.dart';
import '../../../shared/widgets/astro_background.dart';

class EnhancedNamesScreen extends StatefulWidget {
  const EnhancedNamesScreen({super.key});

  @override
  State<EnhancedNamesScreen> createState() => _EnhancedNamesScreenState();
}

class _EnhancedNamesScreenState extends State<EnhancedNamesScreen> {
  final TextEditingController _nameController = TextEditingController();
  final GeminiService _geminiService = GeminiService();
  int? _selectedNakshatra;
  int? _moonNakshatra; // User's actual Moon Nakshatra from birth chart
  NameAnalysisResult? _analysisResult;
  NameNakshatraAnalysis? _phoneticAnalysis;
  NakshatraNameAnalysis? _nakshatraSuggestion;
  bool _isLoading = false;
  String? _errorMessage;
  NameValidationResult? _validationResult;
  bool _showAllNakshatras = false;
  
  // ✨ NEW: AI Nakshatra Analysis Data
  Map<String, dynamic>? _nakshatraAnalysis;
  List<Map<String, dynamic>>? _recommendedMaleNames;
  List<Map<String, dynamic>>? _recommendedFemaleNames;
  String? _namingGuidance;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_validateNameLive);
  }

  @override
  void dispose() {
    _nameController.removeListener(_validateNameLive);
    _nameController.dispose();
    super.dispose();
  }

  void _validateNameLive() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _validationResult = null);
      return;
    }
    setState(() {
      _validationResult = NameValidator.validate(name);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AstroBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildMoonNakshatraSelector(),
              const SizedBox(height: 16),
              _buildNameInput(),
              const SizedBox(height: 16),
              if (_isLoading) _buildLoadingIndicator(),
              if (_errorMessage != null) _buildErrorMessage(),
              if (_analysisResult != null && !_isLoading) ...[
                if (_phoneticAnalysis != null) ...[
                  _buildPhoneticAnalysisCard(),
                  const SizedBox(height: 16),
                ],
                if (_nakshatraSuggestion != null) ...[
                  _buildNakshatraSuggestionCard(),
                  const SizedBox(height: 16),
                ],
                
                if (_nakshatraAnalysis != null) ...[
                  _buildNakshatraAnalysisCard(),
                  const SizedBox(height: 16),
                ],
                _buildAnalysisCard(),
                const SizedBox(height: 16),
                
                if (_recommendedMaleNames != null || _recommendedFemaleNames != null) ...[
                  _buildRecommendedNamesCard(),
                  const SizedBox(height: 16),
                ],
                _buildVibrationCard(),
                const SizedBox(height: 16),
                _buildPersonalityCard(),
                const SizedBox(height: 16),
                _buildFavoritesCard(),
                const SizedBox(height: 16),
                _buildStrengthsWeaknessesCard(),
                const SizedBox(height: 16),
                _buildCompatibilityCard(),
              ],
              const SizedBox(height: 16),
              _buildNakshatraSelector(),
              if (_selectedNakshatra != null) ...[
                const SizedBox(height: 16),
                _buildSyllablesDisplay(),
              ],
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              strokeWidth: 4,
              valueColor: AlwaysStoppedAnimation<Color>(AstroTheme.accentCyan),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Analyzing name energy with AI...',
            style: AstroTheme.headingSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'This may take a few seconds',
            style: AstroTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Error', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                const SizedBox(height: 4),
                Text(_errorMessage!, style: AstroTheme.bodyMedium),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.red),
            onPressed: () => setState(() => _errorMessage = null),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
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
            gradient: AstroTheme.goldGradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AstroTheme.accentGold.withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.text_fields, color: Colors.white, size: 28),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Name Analysis', style: AstroTheme.headingMedium),
              const SizedBox(height: 4),
              Text('Discover your name\'s energy', style: AstroTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMoonNakshatraSelector() {
    return AstroCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.nightlight_round, color: AstroTheme.accentCyan, size: 20),
              const SizedBox(width: 8),
              Text(
                'Select Your Moon Nakshatra',
                style: AstroTheme.headingSmall.copyWith(color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Choose the Moon Nakshatra from your birth chart for accurate name suggestions',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: AstroTheme.cardBackgroundLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AstroTheme.accentCyan.withOpacity(0.3)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: _moonNakshatra,
                hint: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Select Moon Nakshatra...',
                    style: TextStyle(color: Colors.white.withOpacity(0.5)),
                  ),
                ),
                isExpanded: true,
                dropdownColor: AstroTheme.surfaceColor,
                icon: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Icon(Icons.arrow_drop_down, color: AstroTheme.accentCyan),
                ),
                items: NakshatraData.nakshatras.map((nakshatra) {
                  return DropdownMenuItem<int>(
                    value: nakshatra.number - 1,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text(
                        '${nakshatra.number}. ${nakshatra.name}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _moonNakshatra = value;
                    // Reset analysis when changing Moon Nakshatra
                    _nakshatraSuggestion = null;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNameInput() {
    return SectionCard(
      title: 'Enter Your Name',
      icon: Icons.person,
      accentColor: AstroTheme.accentCyan,
      child: Column(
        children: [
          TextField(
            controller: _nameController,
            style: AstroTheme.bodyLarge,
            decoration: InputDecoration(
              hintText: 'Enter your full name...',
              hintStyle: AstroTheme.bodyMedium,
              filled: true,
              fillColor: AstroTheme.cardBackgroundLight,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              prefixIcon: const Icon(Icons.person_outline, color: AstroTheme.accentCyan),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _analyzeName,
              style: ElevatedButton.styleFrom(
                backgroundColor: AstroTheme.accentCyan,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.auto_awesome),
                  SizedBox(width: 8),
                  Text('Analyze Name Energy', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _analyzeName() async {
    final name = _nameController.text.trim();
    
    // STEP 0: Validate name format and quality
    final validation = NameValidator.validate(name);
    if (!validation.isValid) {
      setState(() {
        _errorMessage = validation.message;
      });
      return;
    }
    
    // Show confidence warning for low-quality names
    if (validation.confidenceLevel == ConfidenceLevel.low) {
      // Optional: show warning dialog but allow analysis
      print('⚠ Low confidence name: ${validation.message}');
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _analysisResult = null;
    });

    try {
      // ✅ NEW: Proper Vedic Phonetic Analysis (supports all 27 Nakshatras)
      final phoneticAnalysis = VedicNameAnalyzer.analyzeName(name);
      
      print('🔮 Vedic Phonetic Analysis:');
      print('   Name: $name');
      print('   Normalized: ${phoneticAnalysis.normalized}');
      print('   First Syllable: ${phoneticAnalysis.firstSyllable}');
      print('   Dominant Sound: ${phoneticAnalysis.dominantSound}');
      print('   Ending Sound: ${phoneticAnalysis.endingSound}');
      print('   Dominant Element: ${phoneticAnalysis.dominantElement}');
      
      if (phoneticAnalysis.primaryNakshatra != null) {
        print('   ✅ Primary Nakshatra: ${phoneticAnalysis.primaryNakshatra!.nakshatra.name}');
        print('   Matched Syllable: ${phoneticAnalysis.primaryNakshatra!.matchedSyllable}');
        print('   Confidence: ${phoneticAnalysis.primaryNakshatra!.confidenceLevel}');
      }
      
      // ✨ CHANGED: Use Moon Nakshatra if provided, otherwise use phonetically detected
      final Nakshatra matchedNakshatra;
      if (_moonNakshatra != null) {
        // Use user's actual Moon Nakshatra from birth chart
        matchedNakshatra = NakshatraData.nakshatras[_moonNakshatra!];
        print('🌙 Using selected Moon Nakshatra: ${matchedNakshatra.name}');
      } else {
        // Fallback to phonetic analysis
        matchedNakshatra = phoneticAnalysis.primaryNakshatra?.nakshatra ?? 
                          NakshatraData.nakshatras.first;
        print('🔮 Using phonetically detected Nakshatra: ${matchedNakshatra.name}');
      }

      // ✨ NEW: Generate Nakshatra-based name suggestions
      var nakshatraSuggestion = NakshatraNameAnalysis.analyze(
        name,
        matchedNakshatra.name,
      );
      
      print('🎯 Nakshatra Name Suggestion:');
      print('   Nakshatra Used: ${matchedNakshatra.name}');
      print('   Is Auspicious: ${nakshatraSuggestion.isAuspicious}');
      if (nakshatraSuggestion.matchingSyllable != null) {
        print('   Matching Syllable: ${nakshatraSuggestion.matchingSyllable}');
      }

      // STEP 1: Compute ALL features locally (determinism for fallback)
      final nameFeatures = NameAnalysisEngine.analyzeName(name);

      // STEP 2: Prepared Fallback Data (Local)
      final localData = _getFallbackAnalysis(matchedNakshatra);
      
      // STEP 3: Initialize with local fallback data
      String aiSummary = '';
      List<String> traits = List<String>.from(localData['personality_traits']);
      List<String> activities = List<String>.from(localData['favorite_activities']);
      List<String> strengths = List<String>.from(localData['strengths']);
      List<String> weaknesses = List<String>.from(localData['growth_areas']);
      List<String> compatible = List<String>.from(localData['compatible_nakshatras']);

      // ⚡ OPTIMIZED: Single Combined API Call (replaces 2 sequential calls)
      if (_geminiService.isConfigured() && _moonNakshatra != null) {
        try {
          print('⚡ Running OPTIMIZED single API call for analysis + names...');
          final stopwatch = Stopwatch()..start();
          
          // Collect syllables for name generation
          final uniqueSyllables = nakshatraSuggestion.auspiciousSyllables.toSet().toList();
          
          // Single combined call - gets BOTH analysis AND name suggestions
          final aiData = await _geminiService.generateCombinedNameAnalysis(
            name: name,
            nakshatra: matchedNakshatra.name,
            nakshatraLord: matchedNakshatra.lord,
            auspiciousSyllables: uniqueSyllables,
          );
          
          stopwatch.stop();
          print('✅ Combined AI call completed in ${stopwatch.elapsedMilliseconds}ms');
          
          // Extract analysis data
          if (aiData.containsKey('summary')) aiSummary = aiData['summary'];
          if (aiData.containsKey('personality_traits')) traits = List<String>.from(aiData['personality_traits']);
          if (aiData.containsKey('favorite_activities')) activities = List<String>.from(aiData['favorite_activities']);
          if (aiData.containsKey('strengths')) strengths = List<String>.from(aiData['strengths']);
          if (aiData.containsKey('growth_areas')) weaknesses = List<String>.from(aiData['growth_areas']);
          if (aiData.containsKey('compatible_nakshatras')) compatible = List<String>.from(aiData['compatible_nakshatras']);
          
          // ✨ NEW: Extract Nakshatra Analysis
          if (aiData.containsKey('nakshatra_analysis')) {
            _nakshatraAnalysis = Map<String, dynamic>.from(aiData['nakshatra_analysis']);
            print('   Nakshatra Analysis: Auspiciousness ${_nakshatraAnalysis?['auspiciousness_score']}%');
          }
          
          // ✨ NEW: Extract Recommended Names with Meanings
          if (aiData.containsKey('recommended_names')) {
            final recNames = aiData['recommended_names'] as Map<String, dynamic>;
            if (recNames.containsKey('male')) {
              _recommendedMaleNames = (recNames['male'] as List)
                  .map((e) => Map<String, dynamic>.from(e as Map))
                  .toList();
            }
            if (recNames.containsKey('female')) {
              _recommendedFemaleNames = (recNames['female'] as List)
                  .map((e) => Map<String, dynamic>.from(e as Map))
                  .toList();
            }
            print('   Recommended Names: ${_recommendedMaleNames?.length ?? 0} male, ${_recommendedFemaleNames?.length ?? 0} female with meanings');
          }
          
          // ✨ NEW: Extract Naming Guidance
          if (aiData.containsKey('naming_guidance')) {
            _namingGuidance = aiData['naming_guidance'];
          }
          
          // Extract AI-generated names (simple list for backward compatibility)
          final maleNames = aiData.containsKey('suggested_male_names') 
              ? List<String>.from(aiData['suggested_male_names']) 
              : <String>[];
          final femaleNames = aiData.containsKey('suggested_female_names') 
              ? List<String>.from(aiData['suggested_female_names']) 
              : <String>[];
          
          if (maleNames.isNotEmpty || femaleNames.isNotEmpty) {
            print('   AI Names: ${maleNames.length} male, ${femaleNames.length} female');
            nakshatraSuggestion = nakshatraSuggestion.withAINames(
              maleNames: maleNames.take(4).toList(),
              femaleNames: femaleNames.take(4).toList(),
            );
          }
          
        } catch (e) {
          print('⚠️ Combined AI Analysis failed: $e');
          // Fallback: Use local data (already initialized above)
          aiSummary = 'The name $name carries the ancient vibrations of ${matchedNakshatra.name}. '
              'Dominant element: ${nameFeatures['dominant_element']}. '
              'It suggests a path of ${matchedNakshatra.psychologicalDrivers.first.toLowerCase()}.';
        }
      } else if (_geminiService.isConfigured()) {
        // No Moon Nakshatra selected - just run analysis (no name generation)
        try {
          final aiData = await _geminiService.generateNameAnalysis(
            name: name,
            nakshatra: matchedNakshatra.name,
            nakshatraLord: matchedNakshatra.lord,
          );
          
          if (aiData.containsKey('summary')) aiSummary = aiData['summary'];
          if (aiData.containsKey('personality_traits')) traits = List<String>.from(aiData['personality_traits']);
          if (aiData.containsKey('favorite_activities')) activities = List<String>.from(aiData['favorite_activities']);
          if (aiData.containsKey('strengths')) strengths = List<String>.from(aiData['strengths']);
          if (aiData.containsKey('growth_areas')) weaknesses = List<String>.from(aiData['growth_areas']);
          if (aiData.containsKey('compatible_nakshatras')) compatible = List<String>.from(aiData['compatible_nakshatras']);
        } catch (e) {
          print('⚠️ AI Analysis failed: $e');
          aiSummary = 'The name $name carries the ancient vibrations of ${matchedNakshatra.name}. '
              'Dominant element: ${nameFeatures['dominant_element']}. '
              'It suggests a path of ${matchedNakshatra.psychologicalDrivers.first.toLowerCase()}.';
        }
      } else {
        // No Gemini configured - use local data only
        aiSummary = 'The name $name carries the ancient vibrations of ${matchedNakshatra.name}. '
            'Dominant element: ${nameFeatures['dominant_element']}. '
            'Vowel/consonant ratio: ${nameFeatures['vowel_consonant_ratio'].toStringAsFixed(2)}. '
            'It suggests a path of ${matchedNakshatra.psychologicalDrivers.first.toLowerCase()}.';
      }

      setState(() {
        _phoneticAnalysis = phoneticAnalysis;
        _nakshatraSuggestion = nakshatraSuggestion;
        _analysisResult = NameAnalysisResult(
          name: name,
          nakshatra: matchedNakshatra,
          summary: aiSummary,
          personalityTraits: traits,
          favoriteActivities: activities,
          strengths: strengths,
          weaknesses: weaknesses,
          compatibleNakshatras: compatible,
        );
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'An error occurred while analyzing the name: ${e.toString()}';
      });
    }
  }

  Map<String, dynamic> _getFallbackAnalysis(Nakshatra nakshatra) {
    return {
      'personality_traits': _getPersonalityTraits(nakshatra),
      'favorite_activities': _getFavoriteActivities(nakshatra),
      'strengths': _getStrengths(nakshatra),
      'growth_areas': _getWeaknesses(nakshatra),
      'compatible_nakshatras': _getCompatibleNakshatras(nakshatra),
    };
  }

  List<String> _getPersonalityTraits(Nakshatra nakshatra) {
    // Generate unique traits based on nakshatra's unique properties
    final baseTraits = <String>[
      '${nakshatra.lord}-influenced', // e.g., "Moon-influenced"
      '${nakshatra.gana} nature', // e.g., "Deva nature"
      'Driven by ${nakshatra.psychologicalDrivers.first.toLowerCase()}',
    ];
    
    // Add nakshatra-specific traits from psychological drivers
    baseTraits.addAll(nakshatra.psychologicalDrivers.take(2));
    
    return baseTraits.take(5).toList();
  }

  List<String> _getFavoriteActivities(Nakshatra nakshatra) {
    // Dynamic activities based on nakshatra characteristics
    final lordActivities = {
      'Sun': ['Leadership activities', 'Public speaking', 'Creative projects'],
      'Moon': ['Nurturing others', 'Artistic pursuits', 'Emotional bonding'],
      'Mars': ['Physical sports', 'Competitive games', 'Adventure activities'],
      'Mercury': ['Reading & writing', 'Communication', 'Intellectual debates'],
      'Jupiter': ['Teaching', 'Spiritual practices', 'Philosophical discussions'],
      'Venus': ['Arts & beauty', 'Social gatherings', 'Luxury experiences'],
      'Saturn': ['Disciplined work', 'Long-term projects', 'Service to others'],
      'Rahu': ['Innovation', 'Technology', 'Breaking conventions'],
      'Ketu': ['Meditation', 'Spiritual retreat', 'Detachment practices'],
    };
    
    final activities = lordActivities[nakshatra.lord] ?? ['Self-improvement', 'Learning', 'Creating'];
    
    // Add Gana-specific activities
    if (nakshatra.gana == 'Deva') {
      activities.add('Helping others');
      activities.add('Religious ceremonies');
    } else if (nakshatra.gana == 'Manushya') {
      activities.add('Social networking');
      activities.add('Balanced living');
    } else {
      activities.add('Intense pursuits');
      activities.add('Transformative work');
    }
    
    return activities.take(5).toList();
  }

  List<String> _getStrengths(Nakshatra nakshatra) {
    return [
      'Natural ${nakshatra.lord} energy brings ${_getLordStrength(nakshatra.lord)}',
      'Strong ${nakshatra.gana} qualities enhance ${_getGanaStrength(nakshatra.gana)}',
      'Excellent at ${nakshatra.psychologicalDrivers.first.toLowerCase()}',
    ];
  }
  
  String _getLordStrength(String lord) {
    final strengths = {
      'Sun': 'vitality and confidence',
      'Moon': 'emotional intelligence',
      'Mars': 'courage and action',
      'Mercury': 'communication skills',
      'Jupiter': 'wisdom and growth',
      'Venus': 'charm and creativity',
      'Saturn': 'discipline and endurance',
      'Rahu': 'innovation and ambition',
      'Ketu': 'spiritual insight',
    };
    return strengths[lord] ?? 'unique gifts';
  }
  
  String _getGanaStrength(String gana) {
    if (gana == 'Deva') return 'divine qualities and purity';
    if (gana == 'Manushya') return 'human connection and balance';
    return 'intensity and transformation';
  }

  List<String> _getWeaknesses(Nakshatra nakshatra) {
    return nakshatra.unconsciousBehaviors.take(3).toList();
  }

  List<String> _getCompatibleNakshatras(Nakshatra nakshatra) {
    // Compatibility based on Gana (Dev/Manushya/Rakshasa), Yoni, and traditional principles
    final compatibilityMap = {
      'Ashwini': ['Bharani', 'Pushya', 'Hasta', 'Swati', 'Shravana', 'Uttara Bhadrapada'],
      'Bharani': ['Ashwini', 'Rohini', 'Ardra', 'Uttara Phalguni', 'Anuradha', 'Purva Bhadrapada'],
      'Krittika': ['Mrigashira', 'Punarvasu', 'Uttara Phalguni', 'Chitra', 'Anuradha', 'Uttara Ashadha'],
      'Rohini': ['Bharani', 'Mrigashira', 'Pushya', 'Uttara Phalguni', 'Hasta', 'Uttara Bhadrapada'],
      'Mrigashira': ['Krittika', 'Rohini', 'Punarvasu', 'Chitra', 'Jyeshtha', 'Uttara Ashadha'],
      'Ardra': ['Bharani', 'Ashlesha', 'Magha', 'Swati', 'Purva Ashadha', 'Purva Bhadrapada'],
      'Punarvasu': ['Krittika', 'Mrigashira', 'Pushya', 'Uttara Phalguni', 'Chitra', 'Shravana'],
      'Pushya': ['Ashwini', 'Rohini', 'Punarvasu', 'Hasta', 'Anuradha', 'Uttara Bhadrapada'],
      'Ashlesha': ['Ardra', 'Magha', 'Purva Phalguni', 'Swati', 'Jyeshtha', 'Purva Bhadrapada'],
      'Magha': ['Ardra', 'Ashlesha', 'Purva Phalguni', 'Vishakha', 'Purva Ashadha', 'Dhanishta'],
      'Purva Phalguni': ['Ashlesha', 'Magha', 'Uttara Phalguni', 'Vishakha', 'Mula', 'Dhanishta'],
      'Uttara Phalguni': ['Krittika', 'Rohini', 'Bharani', 'Punarvasu', 'Purva Phalguni', 'Hasta', 'Swati'],
      'Hasta': ['Ashwini', 'Rohini', 'Pushya', 'Uttara Phalguni', 'Chitra', 'Anuradha', 'Shravana'],
      'Chitra': ['Krittika', 'Mrigashira', 'Punarvasu', 'Hasta', 'Vishakha', 'Uttara Ashadha'],
      'Swati': ['Ashwini', 'Ardra', 'Ashlesha', 'Uttara Phalguni', 'Anuradha', 'Shravana'],
      'Vishakha': ['Magha', 'Purva Phalguni', 'Chitra', 'Jyeshtha', 'Mula', 'Purva Ashadha'],
      'Anuradha': ['Bharani', 'Krittika', 'Pushya', 'Hasta', 'Swati', 'Shravana', 'Uttara Bhadrapada'],
      'Jyeshtha': ['Mrigashira', 'Ashlesha', 'Vishakha', 'Mula', 'Purva Ashadha', 'Dhanishta'],
      'Mula': ['Purva Phalguni', 'Vishakha', 'Jyeshtha', 'Purva Ashadha', 'Uttara Ashadha', 'Dhanishta'],
      'Purva Ashadha': ['Ardra', 'Magha', 'Vishakha', 'Jyeshtha', 'Mula', 'Purva Bhadrapada', 'Dhanishta'],
      'Uttara Ashadha': ['Krittika', 'Mrigashira', 'Chitra', 'Mula', 'Shravana', 'Shatabhisha'],
      'Shravana': ['Ashwini', 'Punarvasu', 'Pushya', 'Hasta', 'Swati', 'Anuradha', 'Uttara Ashadha'],
      'Dhanishta': ['Magha', 'Purva Phalguni', 'Jyeshtha', 'Mula', 'Purva Ashadha', 'Purva Bhadrapada'],
      'Shatabhisha': ['Ardra', 'Uttara Ashadha', 'Purva Bhadrapada', 'Uttara Bhadrapada', 'Revati'],
      'Purva Bhadrapada': ['Bharani', 'Ardra', 'Ashlesha', 'Purva Ashadha', 'Dhanishta', 'Shatabhisha'],
      'Uttara Bhadrapada': ['Ashwini', 'Rohini', 'Pushya', 'Anuradha', 'Shatabhisha', 'Revati'],
      'Revati': ['Shatabhisha', 'Uttara Bhadrapada', 'Ashwini', 'Punarvasu', 'Hasta', 'Shravana'],
    };
    
    return compatibilityMap[nakshatra.name] ?? ['Rohini', 'Pushya', 'Hasta', 'Shravana', 'Uttara Bhadrapada'];
  }

  Widget _buildAnalysisCard() {
    final result = _analysisResult!;
    final color = AstroTheme.getPlanetColor(result.nakshatra.lord);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withOpacity(0.3), color.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.4)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 2,
          )
        ],
      ),
      child: Column(
        children: [
          Text(
            '✨ ${result.name} ✨',
            style: AstroTheme.headingLarge.copyWith(
              color: color,
              fontSize: 32,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Soul Vibration: ${result.nakshatra.name}',
            style: AstroTheme.headingSmall.copyWith(letterSpacing: 1.1),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.auto_awesome, color: color, size: 16),
                const SizedBox(width: 8),
                Text(
                  'Ruled by ${result.nakshatra.lord}',
                  style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          if (result.summary.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.03),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                result.summary,
                style: AstroTheme.bodyLarge.copyWith(
                  height: 1.5,
                  fontStyle: FontStyle.italic,
                  color: Colors.white.withOpacity(0.9),
                ),
                textAlign: TextAlign.center,
              ),
            )
          else
            Text(
              result.nakshatra.description,
              style: AstroTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }

  Widget _buildVibrationCard() {
    final result = _analysisResult!;
    final color = AstroTheme.accentCyan;

    return SectionCard(
      title: 'Sound & Vibration Analysis',
      icon: Icons.graphic_eq,
      accentColor: color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          const SizedBox(height: 16),
          Text(
            'The initial sound of "${result.name}" resonates with the energy of ${result.nakshatra.name}. In Vedic tradition, this sound creates a specific frequency that shapes your interaction with the material world.',
            style: AstroTheme.bodyMedium.copyWith(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalityCard() {
    return SectionCard(
      title: 'Personality Traits',
      icon: Icons.psychology,
      accentColor: AstroTheme.accentPurple,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _analysisResult!.personalityTraits.map((trait) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AstroTheme.accentPurple.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AstroTheme.accentPurple.withOpacity(0.3)),
          ),
          child: Text(trait, style: const TextStyle(color: Colors.white, fontSize: 13)),
        )).toList(),
      ),
    );
  }

  Widget _buildFavoritesCard() {
    return SectionCard(
      title: 'Favorite Things to Do',
      icon: Icons.favorite,
      accentColor: AstroTheme.accentPink,
      child: Column(
        children: _analysisResult!.favoriteActivities.map((activity) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              const Icon(Icons.check_circle, color: AstroTheme.accentPink, size: 18),
              const SizedBox(width: 12),
              Expanded(child: Text(activity, style: AstroTheme.bodyLarge)),
            ],
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildStrengthsWeaknessesCard() {
    return SectionCard(
      title: 'Strengths & Growth Areas',
      icon: Icons.balance,
      accentColor: const Color(0xFF4caf50),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('💪 Strengths:', style: AstroTheme.headingSmall.copyWith(fontSize: 16)),
          const SizedBox(height: 8),
          ..._analysisResult!.strengths.map((s) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                const Icon(Icons.star, color: Color(0xFF4caf50), size: 16),
                const SizedBox(width: 8),
                Expanded(child: Text(s, style: AstroTheme.bodyMedium)),
              ],
            ),
          )),
          const SizedBox(height: 16),
          Text('🎯 Growth Areas:', style: AstroTheme.headingSmall.copyWith(fontSize: 16)),
          const SizedBox(height: 8),
          ..._analysisResult!.weaknesses.map((w) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                const Icon(Icons.trending_up, color: Color(0xFFff9800), size: 16),
                const SizedBox(width: 8),
                Expanded(child: Text(w, style: AstroTheme.bodyMedium)),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildCompatibilityCard() {
    return SectionCard(
      title: 'Compatible Nakshatras',
      icon: Icons.people,
      accentColor: AstroTheme.accentGold,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Names from these nakshatras may resonate well:', style: AstroTheme.bodyMedium),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _analysisResult!.compatibleNakshatras.map((n) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: AstroTheme.goldGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(n, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            )).toList(),
          ),
        ],
      ),
    );
  }

  /// ✨ NEW: Nakshatra Analysis Card - Shows detailed AI analysis
  Widget _buildNakshatraAnalysisCard() {
    final analysis = _nakshatraAnalysis!;
    final score = analysis['auspiciousness_score'] as int? ?? 0;
    final scoreColor = score >= 80 ? Colors.green : score >= 60 ? Colors.orange : Colors.red;
    
    return SectionCard(
      title: 'Nakshatra Name Analysis',
      icon: Icons.auto_awesome,
      accentColor: AstroTheme.accentPurple,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Auspiciousness Score
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [scoreColor.withOpacity(0.2), scoreColor.withOpacity(0.05)],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: scoreColor.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: scoreColor.withOpacity(0.2),
                    border: Border.all(color: scoreColor, width: 3),
                  ),
                  child: Center(
                    child: Text(
                      '$score%',
                      style: TextStyle(
                        color: scoreColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Name-Nakshatra Alignment',
                        style: AstroTheme.headingSmall.copyWith(fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        analysis['current_name_alignment'] ?? 'Analysis pending...',
                        style: AstroTheme.bodyMedium.copyWith(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Nakshatra Meaning
          if (analysis['nakshatra_meaning'] != null) ...[
            _buildAnalysisItem(
              '🌟 Nakshatra Energy',
              analysis['nakshatra_meaning'],
            ),
            const SizedBox(height: 12),
          ],
          
          // Ruling Planet Influence
          if (analysis['ruling_planet_influence'] != null) ...[
            _buildAnalysisItem(
              '🪐 Planetary Influence',
              analysis['ruling_planet_influence'],
            ),
            const SizedBox(height: 12),
          ],
          
          // Syllable Significance
          if (analysis['syllable_significance'] != null) ...[
            _buildAnalysisItem(
              '🔤 Sacred Syllables',
              analysis['syllable_significance'],
            ),
          ],
          
          // Naming Guidance
          if (_namingGuidance != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AstroTheme.accentGold.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AstroTheme.accentGold.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb, color: AstroTheme.accentGold, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _namingGuidance!,
                      style: TextStyle(color: AstroTheme.accentGold, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildAnalysisItem(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AstroTheme.headingSmall.copyWith(fontSize: 13, color: AstroTheme.accentCyan)),
        const SizedBox(height: 4),
        Text(content, style: AstroTheme.bodyMedium.copyWith(color: Colors.white70)),
      ],
    );
  }

  /// ✨ NEW: Recommended Names Card - Shows AI-generated names with meanings
  Widget _buildRecommendedNamesCard() {
    return SectionCard(
      title: 'Recommended Names',
      icon: Icons.child_care,
      accentColor: const Color(0xFF9C27B0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_recommendedMaleNames != null && _recommendedMaleNames!.isNotEmpty) ...[
            Row(
              children: [
                Icon(Icons.male, color: Colors.blue[300], size: 20),
                const SizedBox(width: 8),
                Text('Boy Names', style: AstroTheme.headingSmall.copyWith(fontSize: 14, color: Colors.blue[300])),
              ],
            ),
            const SizedBox(height: 12),
            ..._recommendedMaleNames!.map((nameData) => _buildNameCard(nameData, Colors.blue[300]!)),
            const SizedBox(height: 20),
          ],
          
          if (_recommendedFemaleNames != null && _recommendedFemaleNames!.isNotEmpty) ...[
            Row(
              children: [
                Icon(Icons.female, color: Colors.pink[300], size: 20),
                const SizedBox(width: 8),
                Text('Girl Names', style: AstroTheme.headingSmall.copyWith(fontSize: 14, color: Colors.pink[300])),
              ],
            ),
            const SizedBox(height: 12),
            ..._recommendedFemaleNames!.map((nameData) => _buildNameCard(nameData, Colors.pink[300]!)),
          ],
        ],
      ),
    );
  }
  
  Widget _buildNameCard(Map<String, dynamic> nameData, Color accentColor) {
    final name = nameData['name'] ?? '';
    final meaning = nameData['meaning'] ?? '';
    final syllable = nameData['syllable'] ?? '';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: accentColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              syllable,
              style: TextStyle(color: accentColor, fontWeight: FontWeight.bold, fontSize: 11),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                ),
                if (meaning.isNotEmpty)
                  Text(
                    meaning,
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
              ],
            ),
          ),
          Icon(Icons.star, color: accentColor.withOpacity(0.5), size: 16),
        ],
      ),
    );
  }

  Widget _buildNakshatraSelector() {
    return SectionCard(
      title: 'Find Your Moon Nakshatra',
      icon: Icons.stars,
      accentColor: AstroTheme.accentGold,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AstroTheme.cardBackgroundLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: DropdownButton<int>(
          value: _selectedNakshatra,
          isExpanded: true,
          dropdownColor: AstroTheme.cardBackground,
          hint: Text('Select your birth Moon Nakshatra', style: AstroTheme.bodyMedium),
          underline: const SizedBox(),
          items: NakshatraData.nakshatras.map((n) {
            return DropdownMenuItem<int>(
              value: n.number,
              child: Text('${n.number}. ${n.name}', style: AstroTheme.bodyLarge),
            );
          }).toList(),
          onChanged: (v) => setState(() => _selectedNakshatra = v),
        ),
      ),
    );
  }

  Widget _buildSyllablesDisplay() {
    final nakshatra = NakshatraData.getNakshatraByNumber(_selectedNakshatra!);
    if (nakshatra == null) return const SizedBox.shrink();
    final color = AstroTheme.getPlanetColor(nakshatra.lord);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color.withOpacity(0.2), color.withOpacity(0.05)]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(nakshatra.name, style: AstroTheme.headingSmall),
          Text('Lord: ${nakshatra.lord}', style: AstroTheme.bodyMedium.copyWith(color: color)),
          const SizedBox(height: 16),
          Text('Recommended Name Syllables', style: AstroTheme.labelText),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: nakshatra.syllables.map((s) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              decoration: BoxDecoration(
                color: color.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: color.withOpacity(0.5)),
              ),
              child: Text(s, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneticAnalysisCard() {
    if (_phoneticAnalysis == null) return const SizedBox();
    
    return SectionCard(
      title: '🔮 Phonetic Nakshatra Analysis',
      icon: Icons.psychology,
      accentColor: AstroTheme.accentGold,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Primary Nakshatra
          if (_phoneticAnalysis!.primaryNakshatra != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AstroTheme.accentGold.withOpacity(0.2),
                    AstroTheme.accentPurple.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _phoneticAnalysis!.primaryNakshatra!.nakshatra.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AstroTheme.accentGold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Lord: ${_phoneticAnalysis!.primaryNakshatra!.nakshatra.lord}  •  Deity: ${_phoneticAnalysis!.primaryNakshatra!.nakshatra.deity}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          
          // Phonetic breakdown
          _buildInfoRow('First Syllable', _phoneticAnalysis!.firstSyllable.toUpperCase()),
          _buildInfoRow('Dominant Sound', _phoneticAnalysis!.dominantSound),
          _buildInfoRow('Ending Sound', _phoneticAnalysis!.endingSound),
          
          const Divider(height: 24),
          
          _buildInfoRow('Dominant Element', _phoneticAnalysis!.dominantElement.toUpperCase()),
          _buildInfoRow('Stress Response', _phoneticAnalysis!.stressResponse),
          
          const SizedBox(height: 16),
          
          // Educational disclaimer
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber.withOpacity(0.3)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline, color: Colors.amber, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '⚠️ This is NAME vibration (mental pattern), not Moon-Nakshatra (destiny from birth chart). It shows how your name affects personality expression.',
                    style: TextStyle(
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNakshatraSuggestionCard() {
    if (_nakshatraSuggestion == null) return const SizedBox.shrink();

    final suggestion = _nakshatraSuggestion!;
    
    return AstroCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: suggestion.isAuspicious 
                    ? LinearGradient(colors: [Colors.green.shade700, Colors.green.shade500])
                    : LinearGradient(colors: [Colors.orange.shade700, Colors.orange.shade500]),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  suggestion.isAuspicious ? Icons.check_circle : Icons.lightbulb_outline,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nakshatra Name Analysis',
                      style: AstroTheme.headingSmall.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Based on ${suggestion.nakshatraName}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          const Divider(color: Colors.white12),
          const SizedBox(height: 16),
          
          // Status Message
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: suggestion.isAuspicious 
                ? Colors.green.withOpacity(0.1)
                : Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: suggestion.isAuspicious 
                  ? Colors.green.withOpacity(0.3)
                  : Colors.orange.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  suggestion.isAuspicious ? Icons.verified : Icons.info,
                  color: suggestion.isAuspicious ? Colors.green : Colors.orange,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    suggestion.isAuspicious
                      ? '✨ "${suggestion.name}" starts with "${suggestion.matchingSyllable}" - an auspicious syllable for ${suggestion.nakshatraName}!'
                      : '⚠️ "${suggestion.name}" does not start with the traditional syllables for ${suggestion.nakshatraName}',
                    style: TextStyle(
                      color: suggestion.isAuspicious ? Colors.green : Colors.orange,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          //Auspicious Syllables
          Text(
            'Auspicious Syllables for ${suggestion.nakshatraName}:',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: suggestion.auspiciousSyllables.map((syllable) {
              final isMatching = syllable.toLowerCase() == suggestion.matchingSyllable?.toLowerCase();
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: isMatching 
                    ? LinearGradient(colors: [AstroTheme.accentCyan, AstroTheme.accentPurple])
                    : null,
                  color: isMatching ? null : AstroTheme.cardBackgroundLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isMatching 
                      ? AstroTheme.accentCyan.withOpacity(0.5)
                      : Colors.white.withOpacity(0.2),
                  ),
                ),
                child: Text(
                  syllable,
                  style: TextStyle(
                    color: isMatching ? Colors.white : Colors.white.withOpacity(0.8),
                    fontWeight: isMatching ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
              );
            }).toList(),
          ),
          
          // AI-Generated Names Section
          if (suggestion.aiGeneratedMaleNames != null && suggestion.aiGeneratedFemaleNames != null) ...[
            const SizedBox(height: 20),
            const Divider(color: Colors.white12),
            const SizedBox(height: 16),
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AstroTheme.accentPurple.withOpacity(0.2),
                    AstroTheme.accentCyan.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AstroTheme.accentCyan.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.auto_awesome, color: AstroTheme.accentGold, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        '✨ AI-Generated Names',
                        style: TextStyle(
                          color: AstroTheme.accentGold,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Creative names using ${suggestion.nakshatraName} syllables',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Male Names
                  Text(
                    '👦 Male Names',
                    style: TextStyle(
                      color: Colors.blue.shade300,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...suggestion.aiGeneratedMaleNames!.map((name) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          Icon(Icons.arrow_right, color: Colors.blue.shade300, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            name,
                            style: TextStyle(
                              color: Colors.blue.shade100,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  
                  const SizedBox(height: 16),
                  
                  // Female Names
                  Text(
                    '👧 Female Names',
                    style: TextStyle(
                      color: Colors.pink.shade300,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...suggestion.aiGeneratedFemaleNames!.map((name) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          Icon(Icons.arrow_right, color: Colors.pink.shade300, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            name,
                            style: TextStyle(
                              color: Colors.pink.shade100,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ],
          
          const SizedBox(height: 20),
          
          // Warning Message
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.withOpacity(0.3)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.warning_amber, color: Colors.red, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                        height: 1.4,
                      ),
                      children: const [
                        TextSpan(
                          text: '⚠️ IMPORTANT: ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        TextSpan(
                          text: 'Consult a qualified Vedic astrologer before finalizing a name. ',
                        ),
                        TextSpan(
                          text: 'Names can influence destiny,',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        TextSpan(
                          text: ' and professional guidance ensures alignment with your complete birth chart.',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 13,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AstroTheme.accentGold,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class NameAnalysisResult {
  final String name;
  final Nakshatra nakshatra;
  final String summary;
  final List<String> personalityTraits;
  final List<String> favoriteActivities;
  final List<String> strengths;
  final List<String> weaknesses;
  final List<String> compatibleNakshatras;
  

  NameAnalysisResult({
    required this.name,
    required this.nakshatra,
    required this.summary,
    required this.personalityTraits,
    required this.favoriteActivities,
    required this.strengths,
    required this.weaknesses,
    required this.compatibleNakshatras,
    
  });
}
