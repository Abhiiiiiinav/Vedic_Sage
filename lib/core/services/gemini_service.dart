import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_keys.dart';

/// Service to interact with Google Gemini API for astrological insights
class GeminiService {
  static final String _apiKey = ApiKeys.geminiApiKey;
  static const String _baseUrl = 
  'https://generativelanguage.googleapis.com/v1beta/models/gemini-3-flash-preview:generateContent';

  /// Generate daily prediction based on chart details
  Future<String> generateDailyPrediction({
    required String moonSign,
    required String ascendant,
    required Map<String, dynamic> currentTransits,
    required Map<String, dynamic> panchang,
  }) async {
    final prompt = '''
You are a Vedic astrology expert. Generate a personalized daily prediction (100 words max) for someone with:
- Moon Sign: $moonSign
- Ascendant: $ascendant
- Current Transits: ${jsonEncode(currentTransits)}
- Today's Panchang: ${jsonEncode(panchang)}

Focus on:
1. How planetary transits affect their day
2. Auspicious and inauspicious timings
3. Practical advice for the day
4. Areas of life to focus on

Keep it positive, practical, and educational. Avoid fear-based predictions.
''';

    return await _generateContent(prompt);
  }

  /// Generate combination interpretation
  Future<String> generateCombinationInterpretation({
    required String planet,
    required String house,
    required String sign,
  }) async {
    final prompt = '''
You are a Vedic astrology expert. Interpret this combination in detail:
Planet: $planet in House: $house in Sign: $sign

Provide a comprehensive interpretation covering:
1. What this combination means
2. How the planet's energy manifests in this house
3. How the sign modifies the expression
4. Strengths of this placement
5. Challenges to be aware of
6. Practical advice for working with this energy

Keep it educational, balanced, and actionable. Focus on self-awareness and growth.
''';

    return await _generateContent(prompt);
  }

  /// Generate name analysis insights
  Future<Map<String, dynamic>> generateNameAnalysis({
    required String name,
    required String nakshatra,
    required String nakshatraLord,
  }) async {
    final prompt = '''
You are an elite Vedic Astrologer and Namakarana (Name Numerology) master with deep expertise in sound vibration science.

ANALYZE THIS SPECIFIC NAME: "$name"

Key Context:
- This name vibrates with the $nakshatra Nakshatra
- Ruled by the planet $nakshatraLord
- Each sound creates a unique cosmic signature

YOUR TASK:
Provide a deeply personalized, UNIQUE analysis for "$name" specifically. Do NOT use generic templates.

CRITICAL REQUIREMENTS:
1. Analyze the EXACT sound vibrations (Aksharas) of "$name"
2. Consider how the specific syllables interact with $nakshatra's energy
3. Examine the influence of ruling planet $nakshatraLord on THIS name
4. Identify hidden strengths and karmic challenges UNIQUE to "$name"
5. Provide 5 SPECIFIC strengths and 5 SPECIFIC growth areas
6. Ensure every trait directly relates to "$name" and its Vedic placement

RESPONSE FORMAT (JSON ONLY):
{
  "summary": "A profound 3-4 sentence overview revealing the soul essence of the name '$name'. Mention specific sound vibrations and how they create this person's unique cosmic fingerprint.",
  
  "personality_traits": [
    "Unique trait 1 based on '$name' vibrations",
    "Unique trait 2 influenced by $nakshatraLord",
    "Unique trait 3 from $nakshatra placement",
    "Unique trait 4 from sound frequency analysis",
    "Unique trait 5 combining all factors"
  ],
  
  "favorite_activities": [
    "Specific activity 1 that resonates with '$name' energy",
    "Activity 2 aligned with $nakshatraLord rulership",
    "Activity 3 matching $nakshatra nature",
    "Activity 4 from psychological drivers",
    "Activity 5 for soul nourishment"
  ],
  
  "strengths": [
    "DETAILED strength 1: [Explain HOW this strength manifests from '$name' specifically]",
    "DETAILED strength 2: [Explain the Vedic principle behind this strength]",
    "DETAILED strength 3: [Connect to $nakshatraLord's gifts]",
    "DETAILED strength 4: [Relate to $nakshatra's unique qualities]",
    "DETAILED strength 5: [Describe the karmic advantage this brings]"
  ],
  
  "growth_areas": [
    "DETAILED challenge 1: [WHY this challenge exists for '$name' and how to overcome it]",
    "DETAILED challenge 2: [The karmic lesson behind this weakness]",
    "DETAILED challenge 3: [How $nakshatraLord creates this struggle]",
    "DETAILED challenge 4: [Practical steps to transform this]",
    "DETAILED challenge 5: [The spiritual growth opportunity here]"
  ],
  
  "compatible_nakshatras": [
    "Nakshatra 1 with brief reason",
    "Nakshatra 2 with brief reason",
    "Nakshatra 3 with brief reason",
    "Nakshatra 4 with brief reason",
    "Nakshatra 5 with brief reason"
  ],
  
  "syllable_analysis": "Deep dive into the sound vibrations of '$name'. Explain which specific syllables carry power, how they interact with $nakshatra, and what frequency they create in the person's aura. Be VERY specific to THIS name."
}

QUALITY CHECK:
- Is every response element UNIQUE to "$name"? (Not generic)
- Did you analyze the SPECIFIC sounds in "$name"?
- Are the strengths and weaknesses DETAILED with explanations?
- Does the analysis feel personal and revealing?

If you used any generic filler text, REWRITE IT to be specific to "$name".

GENERATE NOW:
''';

    final response = await _generateContent(prompt);
    
    // Extract JSON from response
    final jsonStart = response.indexOf('{');
    final jsonEnd = response.lastIndexOf('}') + 1;
    if (jsonStart != -1 && jsonEnd > jsonStart) {
      final jsonStr = response.substring(jsonStart, jsonEnd);
      try {
        return jsonDecode(jsonStr);
      } 
      catch (e) {
        print('Error parsing JSON response: $e');
        print('Response received: $response');
        throw Exception('Failed to parse name analysis. The cosmic energies are slightly misaligned. Please try again.');
      }
    }
    

    // If no JSON found in response
    print('No JSON found in response: $response');
    throw Exception('Failed to generate name analysis. The cosmic energies are slightly misaligned. Please try again.');
  }

  /// ⚡ OPTIMIZED: Combined Name Analysis + Name Generation in ONE API call
  /// This cuts API time roughly in half compared to sequential calls
  Future<Map<String, dynamic>> generateCombinedNameAnalysis({
    required String name,
    required String nakshatra,
    required String nakshatraLord,
    required List<String> auspiciousSyllables,
  }) async {
    final syllableList = auspiciousSyllables.take(8).join(', ');
    
    final prompt = '''You are an elite Vedic Astrologer specializing in Namakarana (Vedic Name Science).

TASK: Provide COMPLETE name analysis for "$name" + recommend names for $nakshatra Nakshatra.

INPUT:
- Name to analyze: "$name"
- Moon Nakshatra: $nakshatra (ruled by $nakshatraLord)
- Auspicious starting syllables for this Nakshatra: $syllableList

RESPOND IN JSON ONLY (no markdown, no code blocks):
{
  "summary": "3-4 sentence profound analysis of '$name' - its sound vibrations, cosmic energy, and connection to $nakshatra. Make it personal and insightful.",
  
  "nakshatra_analysis": {
    "nakshatra_meaning": "Brief meaning of $nakshatra and its energy",
    "ruling_planet_influence": "How $nakshatraLord shapes personality",
    "syllable_significance": "Why syllables ($syllableList) are auspicious for $nakshatra",
    "current_name_alignment": "How well '$name' aligns with $nakshatra energy (explain match/mismatch)",
    "auspiciousness_score": 85
  },
  
  "personality_traits": ["trait1 specific to $name", "trait2", "trait3", "trait4", "trait5"],
  
  "favorite_activities": ["activity1", "activity2", "activity3", "activity4"],
  
  "strengths": [
    "Strength 1: detailed explanation of how this manifests",
    "Strength 2: brief explanation",
    "Strength 3: brief explanation"
  ],
  
  "growth_areas": [
    "Challenge 1: what it is and how to overcome",
    "Challenge 2: brief with remedy",
    "Challenge 3: brief with remedy"
  ],
  
  "compatible_nakshatras": ["Nakshatra1 - reason", "Nakshatra2 - reason", "Nakshatra3 - reason"],
  
  "recommended_names": {
    "male": [
      {"name": "Name1", "meaning": "meaning", "syllable": "starting syllable used"},
      {"name": "Name2", "meaning": "meaning", "syllable": "starting syllable used"},
      {"name": "Name3", "meaning": "meaning", "syllable": "starting syllable used"},
      {"name": "Name4", "meaning": "meaning", "syllable": "starting syllable used"}
    ],
    "female": [
      {"name": "Name1", "meaning": "meaning", "syllable": "starting syllable used"},
      {"name": "Name2", "meaning": "meaning", "syllable": "starting syllable used"},
      {"name": "Name3", "meaning": "meaning", "syllable": "starting syllable used"},
      {"name": "Name4", "meaning": "meaning", "syllable": "starting syllable used"}
    ]
  },
  
  "suggested_male_names": ["Name1", "Name2", "Name3", "Name4"],
  "suggested_female_names": ["Name1", "Name2", "Name3", "Name4"],
  
  "naming_guidance": "1-2 sentences on what type of names work best for $nakshatra natives"
}

CRITICAL RULES:
- Be SPECIFIC to "$name" and $nakshatra - no generic content
- All recommended names MUST start with one of: $syllableList
- Include meaningful names with positive Sanskrit/Indian meanings
- Auspiciousness score: 0-100 based on how well '$name' matches $nakshatra
- Keep response focused and valuable
''';

    final response = await _generateContent(prompt);
    
    // Extract JSON from response
    final jsonStart = response.indexOf('{');
    final jsonEnd = response.lastIndexOf('}') + 1;
    if (jsonStart != -1 && jsonEnd > jsonStart) {
      final jsonStr = response.substring(jsonStart, jsonEnd);
      try {
        return jsonDecode(jsonStr);
      } catch (e) {
        print('Error parsing combined analysis JSON: $e');
        throw Exception('Failed to parse analysis. Please try again.');
      }
    }
    
    throw Exception('Failed to generate analysis. Please try again.');
  }

  /// Generate interpretation from computed name features (deterministic data)
  /// Returns PLAIN TEXT interpretation, not JSON
  Future<String> generateStructuredNameReading(
    Map<String, dynamic> features,
    String nakshatra,
    String nakshatraLord,
  ) async {
    final prompt = '''
You are a Vedic psychology expert and master interpreter.

COMPUTED NAME FEATURES (DO NOT MODIFY):
${jsonEncode(features)}

NAKSHATRA CONTEXT:
- Nakshatra: $nakshatra
- Ruling Planet: $nakshatraLord

Your task: Provide a profound, narrative interpretation of these computed features.

IMPORTANT RULES:
1. DO NOT invent or modify the technical data
2. ONLY interpret what is provided in the features
3. Reference the actual computed values (e.g., "The dominant ${features['dominant_element']} element...")
4. If "has_foreign_influence" is true → explain modern, unconventional traits
5. Use vowel/consonant ratio for emotional vs action orientation

Provide a 3-4 paragraph interpretation covering:
- Soul essence based on the sound analysis and nakshatra
- How the dominant element shapes personality
- Strengths from this phonetic signature
- Growth areas and karmic lessons
- Relationship with the ruling planet $nakshatraLord

Be specific, personal, and reference the actual computed data.
DO NOT return JSON. Return flowing narrative text only.
''';

    return await _generateContent(prompt);
  }

  /// Generate interpretation from computed birth chart
  Future<String> generateChartInterpretation(String chartSummary) async {
    final prompt = '''
You are an expert Vedic astrologer with deep knowledge of Jyotish shastra. Analyze this birth chart and provide a COMPREHENSIVE, DETAILED interpretation.

COMPUTED BIRTH CHART DATA:
$chartSummary

Generate a DETAILED REPORT covering:

**1. ASCENDANT ANALYSIS (2-3 paragraphs)**
- Deep dive into what this ascendant sign reveals about life path and destiny
- Physical appearance tendencies and natural demeanor
- Core life themes and karmic lessons
- How this shapes the entire chart interpretation

**2. PERSONALITY PROFILE (2 paragraphs)**
- Intrinsic nature and behavioral patterns
- Mental and emotional characteristics
- How others perceive them vs their inner reality
- Natural talents and inclinations

**3. PLANETARY PLACEMENTS (1-2 paragraphs)**
- Significance of key planet positions in houses
- Strength of planets (dignified, debilitated, neutral)
- Which planets are most influential in this chart
- Major yogas (auspicious combinations) if any

**4. LIFE AREAS ANALYSIS**
- **Career & Ambitions**: Natural career paths, professional strengths
- **Relationships**: Approach to partnerships, compatibility factors
- **Finances**: Wealth potential, financial patterns
- **Health**: Areas to watch, vitality levels
- **Spirituality**: Spiritual inclinations and paths

**5. KARMIC THEMES & LIFE PURPOSE (1-2 paragraphs)**
- Soul's evolutionary journey in this lifetime
- Past life influences (if indicated)
- Key lessons to master
- Higher purpose and dharma

**6. PRACTICAL GUIDANCE**
- Specific recommendations for success
- Areas requiring conscious awareness
- Best times/periods for major decisions
- Remedial measures (mantras, gemstones, lifestyle)

IMPORTANT:
- Write in flowing paragraphs with clear section headers
- Be specific and personal based on the chart data
- Balance positive insights with growth opportunities
- Use Vedic terminology but explain concepts clearly
- Provide actionable wisdom, not just descriptions
- Make it inspiring and empowering
- Write at least 800-1000 words for a comprehensive reading

Generate the detailed interpretation now:
''';

    return await _generateContent(prompt);
  }

  /// Generate personalized growth exercises
  Future<List<String>> generateGrowthExercises({
    required String planet,
    required String userContext,
  }) async {
    final prompt = '''
You are a Vedic astrology expert. Generate 10 practical daily exercises to strengthen $planet energy.

User context: $userContext

Each exercise should:
1. Be actionable and specific
2. Take 5-30 minutes daily
3. Focus on behavioral change, not rituals
4. Be modern and practical
5. Directly relate to $planet's significations

Format: Return only the exercises as a JSON array of strings.
Example: ["Exercise 1", "Exercise 2", "Exercise 3", "Exercise 4"]
''';

    final response = await _generateContent(prompt);
    try {
      final jsonStart = response.indexOf('[');
      final jsonEnd = response.lastIndexOf(']') + 1;
      if (jsonStart != -1 && jsonEnd > jsonStart) {
        final jsonStr = response.substring(jsonStart, jsonEnd);
        final List<dynamic> exercises = jsonDecode(jsonStr);
        return exercises.map((e) => e.toString()).toList();
      }
    } catch (e) {
      print('Error parsing exercises: $e');
    }
    
    return [
      'Practice mindfulness for 10 minutes',
      'Journal about your experiences',
      'Engage in related activities',
      'Reflect on your growth',
    ];
  }

  /// Generate birth chart details from birth info
  Future<Map<String, dynamic>> generateBirthChart({
    required String name,
    required String dob,
    required String tob,
    required String pob,
  }) async {
    final prompt = '''
You are a Vedic Astrology calculation expert. Calculate the approximate birth chart for:
Name: $name
DOB: $dob
TOB: $tob
POB: $pob

Return a JSON response with:
{
  "ascendant": "SignName",
  "interpretation": "Short personality summary",
  "houses": [
    ["Planet1Abbr", "Planet2Abbr"], // House 1
    [], // House 2
    ["Planet3Abbr"] // ... up to House 12
  ]
}

Use standard abbreviations: Su, Mo, Ma, Me, Ju, Ve, Sa, Ra, Ke.
The "houses" array MUST contain exactly 12 lists, representing houses 1 to 12.
''';

    final response = await _generateContent(prompt);
    try {
      final jsonStart = response.indexOf('{');
      final jsonEnd = response.lastIndexOf('}') + 1;
      if (jsonStart != -1 && jsonEnd > jsonStart) {
        final jsonStr = response.substring(jsonStart, jsonEnd);
        final decoded = jsonDecode(jsonStr);
        
        // ✅ CRITICAL FIX: Properly cast nested lists from List<dynamic> to List<List<String>>
        final rawHouses = decoded['houses'] as List;
        final List<List<String>> parsedHouses = 
            rawHouses.map((h) => List<String>.from(h as List)).toList();
        
        return {
          'ascendant': decoded['ascendant'],
          'interpretation': decoded['interpretation'],
          'houses': parsedHouses,
        };
      }
    } catch (e) {
      print('Error parsing birth chart: $e');
    }
    
    // ✅ FIX: Return default with strongly-typed empty lists
    return {
      'ascendant': 'Unknown',
      'interpretation': 'Unable to calculate chart at this time.',
      'houses': List.generate(12, (_) => <String>[]),
    };
  }

  /// Generate short Dasha interpretation
  Future<String> generateDashaInterpretation({
    required String mahadashaLord,
    required String antardashaLord,
    required String dashaLagnaHouse,
    required String context,
  }) async {
    final prompt = '''
You are a Vedic astrology expert. Interpret the current Mahadasha and Antardasha period with a focus on Dasha Lagna.

**Current Period:**
- Mahadasha (Major Period): $mahadashaLord
- Antardasha (Sub-Period): $antardashaLord

**Dasha Lagna Analysis:**
The Mahadasha lord ($mahadashaLord) is placed in House $dashaLagnaHouse from the Birth Lagna.
*Crucial Concept:* This means House $dashaLagnaHouse becomes the effective "Ascendant" or primary focus for this entire Mahadasha period. All other houses shift relative to this new center.

**Context/Focus:** $context

**Please Provide:**
1.  **The "New Normal":** Explain how the themes of House $dashaLagnaHouse become the central backdrop of life during this time.
2.  **Mahadasha & Antardasha Dynamic:** How the sub-period lord ($antardashaLord) interacts offering support or challenge to this main theme.
3.  **Actionable Strategy:** Specific practical advice on how to align with this energy. What activities should be prioritized?
4.  **Growth Focus:** One key area of self-development to focus on.

*Tone:* Educational, empowering, modern, and practical. Avoid fatalistic predictions. Length: Approx 150-200 words.
''';

    return await _generateContent(prompt);
  }

  /// Generate answer to user's astrological question
  Future<String> generateQuestionAnswer({
    required String question,
    required String category,
    required Map<String, dynamic> chartDetails,
  }) async {
    final prompt = '''
You are a Vedic astrology expert. Answer this question about $category:

Question: "$question"

User's chart details: ${jsonEncode(chartDetails)}

Provide:
1. Direct answer to the question
2. Which houses and planets to analyze
3. What to look for in the chart
4. Practical guidance
5. Distinction between fate and free will

Keep it educational, empowering, and focused on self-awareness. Avoid definitive predictions about timing.
''';

    return await _generateContent(prompt);
  }

  /// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  /// COMPREHENSIVE VEDIC INTERPRETATION SYSTEM
  /// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Generate COMPLETE personalized Vedic chart interpretation
  Future<Map<String, dynamic>> generateComprehensiveInterpretation({
    required Map<String, dynamic> chartData,
    required String name,
  }) async {
    // Extract chart details
    final ascDegree = chartData['ascendant'] as double? ?? 0.0;
    final ascSign = ['Aries', 'Taurus', 'Gemini', 'Cancer', 'Leo', 'Virgo',
                     'Libra', 'Scorpio', 'Sagittarius', 'Capricorn', 'Aquarius', 'Pisces']
                    [((ascDegree / 30).floor() % 12)];
    
    final planets = chartData['planets'] as Map<String, dynamic>? ?? {};
    final moonData = planets['Mo'];
    final moonDegree = moonData is Map ? (moonData['longitude'] ?? moonData['degree'] ?? 0.0) as double : 0.0;
    final moonSign = ['Aries', 'Taurus', 'Gemini', 'Cancer', 'Leo', 'Virgo',
                      'Libra', 'Scorpio', 'Sagittarius', 'Capricorn', 'Aquarius', 'Pisces']
                     [((moonDegree / 30).floor() % 12)];
    final moonNakshatra = _getNakshatraName(moonDegree);
    
    // Build planet summary
    final planetSummary = _buildPlanetSummary(planets, ascDegree);

    final prompt = '''
You are a senior Vedic astrologer, behavioral analyst, and astrology system architect with mastery in Parashari astrology, Nakshatra psychology, Lagna-based behavioral assessment, and planetary karaka theory.

ANALYZE THIS SPECIFIC BIRTH CHART for "$name":

CHART DATA:
- Ascendant (Lagna): $ascSign at ${ascDegree.toStringAsFixed(2)}°
- Moon Sign (Rashi): $moonSign at ${moonDegree.toStringAsFixed(2)}°
- Moon Nakshatra: $moonNakshatra
- Planetary Positions:
$planetSummary

GENERATE A COMPREHENSIVE, PERSONALIZED INTERPRETATION covering:

━━━ 1. LAGNA (ASCENDANT) ANALYSIS ━━━
- What $ascSign Lagna reveals about identity, body, vitality
- Physical frame tendencies and facial expression style
- Energy level and social behavior patterns
- How the Lagna lord modifies appearance
- First reactions, posture, confidence patterns
- How this Lagna evolves with maturity

━━━ 2. NAKSHATRA PSYCHOLOGY ━━━
For Moon in $moonNakshatra:
- Core subconscious desire and fear pattern
- Growth impulse and social behavior tendency
- Relationship style influenced by this Nakshatra
- Career inclinations from Nakshatra energy
- Emotional triggers and coping patterns
- How this Nakshatra activates during its lord's Dasha

━━━ 3. PERSONALITY PROFILE ━━━
- Intrinsic nature and behavioral patterns
- Mental and emotional characteristics
- How others perceive them vs inner reality
- Natural talents and inclinations
- The interplay between Lagna, Moon sign, and Nakshatra

━━━ 4. PLANETARY BEHAVIOR TOWARD KARAKAS ━━━
For EACH significant planet in this chart, explain:
- Its natural karakas (life areas it governs)
- Current strength/weakness based on placement
- Psychological expression in this chart
- How it affects the life areas it rules
- Observable behavioral patterns

━━━ 5. LIFE AREAS ANALYSIS ━━━
Based on house lords and placements:
- Career & Ambitions: Natural paths, 10th house analysis
- Relationships: 7th house, Venus, partnership patterns
- Finances: 2nd and 11th house, wealth potential
- Health: 6th house, vitality indicators
- Spirituality: 9th and 12th house themes

━━━ 6. KEEPING PLANETS "HAPPY" — BEHAVIORAL REMEDIES ━━━
For this specific chart, provide:
- Which planets need strengthening and WHY
- Specific behavioral practices (not just rituals)
- Daily habits to align with planetary energies
- Communication and lifestyle adjustments
- How behavior rewires planetary expression

━━━ 7. GROWTH PATH & KARMIC LESSONS ━━━
- Soul's evolutionary journey in this lifetime
- Key lessons to master based on chart patterns
- Higher purpose and dharma indicators
- What challenges are actually training zones
- Observation checklist for self-validation

CRITICAL RULES:
- Be SPECIFIC to THIS chart, not generic
- Frame everything as behavioral and observable
- No fatalistic language - emphasize personal agency
- Provide detection logic (how user can observe it)
- Include practical, daily-life examples
- Balance insights with growth opportunities

Return as JSON:
{
  "lagna_analysis": {
    "sign": "$ascSign",
    "core_identity": "detailed paragraph",
    "physical_tendencies": ["tendency1", "tendency2"],
    "behavioral_patterns": ["pattern1", "pattern2"],
    "evolution_path": "how this evolves with age"
  },
  "nakshatra_psychology": {
    "nakshatra": "$moonNakshatra",
    "core_desire": "what drives this person",
    "fear_pattern": "what they avoid",
    "relationship_style": "how they connect",
    "emotional_triggers": ["trigger1", "trigger2"],
    "career_inclinations": ["career1", "career2"]
  },
  "personality_profile": {
    "intrinsic_nature": "detailed paragraph",
    "mental_emotional": "detailed paragraph",
    "perception_gap": "how others see them vs reality",
    "natural_talents": ["talent1", "talent2", "talent3"]
  },
  "planetary_analysis": [
    {
      "planet": "Sun",
      "placement": "sign and house",
      "strength": "strong/moderate/weak",
      "karakas_affected": ["authority", "father", "confidence"],
      "behavioral_expression": "how it shows in daily life",
      "life_impact": "how it affects specific areas"
    }
  ],
  "life_areas": {
    "career": "detailed analysis",
    "relationships": "detailed analysis",
    "finances": "detailed analysis",
    "health": "detailed analysis",
    "spirituality": "detailed analysis"
  },
  "behavioral_remedies": [
    {
      "planet": "planet name",
      "why_strengthen": "reason based on chart",
      "daily_practices": ["practice1", "practice2"],
      "lifestyle_adjustments": ["adjustment1", "adjustment2"]
    }
  ],
  "growth_path": {
    "karmic_lessons": ["lesson1", "lesson2"],
    "dharma_indicators": "life purpose insights",
    "training_zones": ["challenge as growth area"],
    "observation_checklist": ["what to notice in daily life"]
  },
  "master_insight": "One profound, personalized insight that synthesizes the entire chart"
}
''';

    final response = await _generateContent(prompt);
    
    // Parse JSON response
    try {
      final jsonStart = response.indexOf('{');
      final jsonEnd = response.lastIndexOf('}') + 1;
      if (jsonStart != -1 && jsonEnd > jsonStart) {
        final jsonStr = response.substring(jsonStart, jsonEnd);
        return jsonDecode(jsonStr);
      }
    } catch (e) {
      print('Error parsing comprehensive interpretation: $e');
    }
    
    return {'error': 'Unable to generate interpretation', 'raw': response};
  }

  /// Generate Darakaraka (DK) relationship analysis
  Future<Map<String, dynamic>> generateDarakarakaAnalysis({
    required String dkPlanet,
    required String dkSign,
    required int dkHouse,
    required String dkNakshatra,
    required String name,
  }) async {
    final prompt = '''
You are a senior Vedic astrologer specializing in Jaimini Karaka system and relationship psychology.

ANALYZE THE DARAKARAKA for "$name":

DARAKARAKA DATA:
- DK Planet: $dkPlanet
- DK Sign: $dkSign
- DK House: $dkHouse
- DK Nakshatra: $dkNakshatra

Darakaraka = planet with lowest degree in chart (spouse/relationship indicator)

GENERATE DETAILED RELATIONSHIP PSYCHOLOGY covering:

━━━ A) PARTNER PERSONALITY STYLE ━━━
Based on $dkPlanet as Darakaraka:
- Emotional needs of partners attracted
- Communication tendencies in relationships
- Conflict style and resolution patterns
- Attachment behavior and security needs

━━━ B) RELATIONSHIP THEMES ━━━
- Support vs struggle patterns typical for this DK
- Power balance tendencies in partnerships
- Stability vs intensity patterns
- What activates relationship karma

━━━ C) SHADOW EXPRESSION ━━━
- What happens when $dkPlanet DK is stressed
- Typical relationship breakdown causes
- Early warning signals in partnerships
- Unconscious patterns to watch

━━━ D) REAL-LIFE PATTERN DETECTION ━━━
- How this shows in dating behavior
- Marriage and commitment patterns
- Long-term relationship dynamics
- Observable signals in partner selection

━━━ E) GROWTH PATH ━━━
- Core lesson for relationship success
- Skills needed for harmony
- Practical daily actions
- Ultimate relationship gift when mastered

━━━ F) DK POSITION ANALYSIS ━━━
- $dkPlanet in $dkSign: behavioral style of partners
- DK in House $dkHouse: where partner influence is strongest
- DK in $dkNakshatra: subconscious emotional patterns

CRITICAL:
- Explain relationship KARMA, not just romance
- No soulmate fatalism or divorce predictions
- Emphasize free will and behavioral change
- Frame challenges as training zones
- Be specific to THIS placement combination

Return as JSON:
{
  "dk_profile": {
    "planet": "$dkPlanet",
    "archetype": "partner archetype name",
    "core_meaning": "what this DK represents"
  },
  "partner_psychology": {
    "emotional_needs": "detailed description",
    "communication_style": "how partners communicate",
    "conflict_style": "how conflicts unfold",
    "attachment_pattern": "security and bonding style"
  },
  "relationship_themes": {
    "support_pattern": "how support manifests",
    "power_balance": "typical power dynamics",
    "stability_level": "stable vs intense tendencies",
    "key_dynamics": ["dynamic1", "dynamic2", "dynamic3"]
  },
  "shadow_expression": {
    "when_stressed": "what happens under pressure",
    "breakdown_causes": ["cause1", "cause2", "cause3"],
    "warning_signals": ["signal1", "signal2", "signal3"]
  },
  "real_life_patterns": {
    "dating": "how they date",
    "marriage": "marriage patterns",
    "long_term": "what sustains or strains",
    "observable_signals": ["signal1", "signal2"]
  },
  "growth_path": {
    "core_lesson": "main relationship lesson",
    "skills_needed": ["skill1", "skill2", "skill3"],
    "practical_actions": ["action1", "action2", "action3"],
    "ultimate_gift": "what mastery brings"
  },
  "position_analysis": {
    "sign_influence": "how $dkSign modifies expression",
    "house_influence": "how House $dkHouse shapes impact",
    "nakshatra_influence": "subconscious patterns from $dkNakshatra"
  },
  "master_insight": "One profound insight about this person's relationship karma"
}
''';

    final response = await _generateContent(prompt);
    
    try {
      final jsonStart = response.indexOf('{');
      final jsonEnd = response.lastIndexOf('}') + 1;
      if (jsonStart != -1 && jsonEnd > jsonStart) {
        final jsonStr = response.substring(jsonStart, jsonEnd);
        return jsonDecode(jsonStr);
      }
    } catch (e) {
      print('Error parsing DK analysis: $e');
    }
    
    return {'error': 'Unable to generate DK analysis', 'raw': response};
  }

  /// Generate Trinal Compatibility (1-5-9) analysis
  Future<Map<String, dynamic>> generateTrineAnalysis({
    required String house1Planet,
    required String house5Planet,
    required String house9Planet,
    required String name,
  }) async {
    final prompt = '''
You are a senior Vedic astrologer specializing in trinal planetary analysis and dharmic compatibility.

ANALYZE THE DHARMA TRINE (1-5-9) for "$name":

TRINE CONFIGURATION:
- House 1 (Identity): $house1Planet
- House 5 (Creativity/Love): $house5Planet
- House 9 (Beliefs/Destiny): $house9Planet

GENERATE COMPREHENSIVE TRINE ANALYSIS:

━━━ TRINAL PRINCIPLE ━━━
Explain how planets in trine form supportive evolutionary themes and natural energy flow.

━━━ HARMONY ANALYSIS ━━━
For this specific $house1Planet-$house5Planet-$house9Planet configuration:
- Overall harmony level (High/Mixed/Effort-Based)
- Natural talents indicated
- Destiny-supportive relationships
- Why trines matter for long-term compatibility

━━━ PLANET-TO-PLANET DYNAMICS ━━━
Analyze:
- $house1Planet (identity) ↔ $house5Planet (creativity) interaction
- $house5Planet (creativity) ↔ $house9Planet (beliefs) interaction
- $house1Planet (identity) ↔ $house9Planet (destiny) interaction

For each interaction explain:
- Harmony or tension
- Growth synergy potential
- Conflict patterns if any

━━━ FUNCTIONAL COMPATIBILITY ━━━
How this trine affects:
- Career alignment
- Emotional maturity
- Value system coherence
- Decision-making style

━━━ RELATIONSHIP IMPLICATIONS ━━━
How this trine configuration affects:
- Type of partners attracted
- Relationship support patterns
- Long-term compatibility factors

Return as JSON:
{
  "trine_profile": {
    "house1": "$house1Planet",
    "house5": "$house5Planet",
    "house9": "$house9Planet",
    "overall_harmony": "High/Mixed/Effort-Based",
    "interpretation": "detailed overview"
  },
  "planet_interactions": [
    {
      "planets": "$house1Planet ↔ $house5Planet",
      "houses": "1 ↔ 5",
      "harmony_level": "level",
      "interpretation": "how they interact"
    },
    {
      "planets": "$house5Planet ↔ $house9Planet",
      "houses": "5 ↔ 9",
      "harmony_level": "level",
      "interpretation": "how they interact"
    },
    {
      "planets": "$house1Planet ↔ $house9Planet",
      "houses": "1 ↔ 9",
      "harmony_level": "level",
      "interpretation": "how they interact"
    }
  ],
  "strengths": ["strength1", "strength2", "strength3"],
  "challenges": ["challenge1", "challenge2"],
  "relationship_implications": {
    "partner_type": "what partners are attracted",
    "support_pattern": "how relationships support growth",
    "long_term_factors": "what sustains relationships"
  },
  "growth_guidance": ["guidance1", "guidance2", "guidance3"]
}
''';

    final response = await _generateContent(prompt);
    
    try {
      final jsonStart = response.indexOf('{');
      final jsonEnd = response.lastIndexOf('}') + 1;
      if (jsonStart != -1 && jsonEnd > jsonStart) {
        final jsonStr = response.substring(jsonStart, jsonEnd);
        return jsonDecode(jsonStr);
      }
    } catch (e) {
      print('Error parsing trine analysis: $e');
    }
    
    return {'error': 'Unable to generate trine analysis', 'raw': response};
  }

  /// Generate Lagna-specific behavioral analysis
  Future<Map<String, dynamic>> generateLagnaAnalysis({
    required String lagnaSign,
    required double lagnaDegree,
    required List<String> planetsIn1stHouse,
    required String lagnaLord,
    required String lagnaLordSign,
    required int lagnaLordHouse,
  }) async {
    final prompt = '''
You are a senior Vedic astrologer specializing in Lagna-based physical and behavioral assessment.

ANALYZE THIS LAGNA CONFIGURATION:

LAGNA DATA:
- Lagna Sign: $lagnaSign at ${lagnaDegree.toStringAsFixed(2)}°
- Planets in 1st House: ${planetsIn1stHouse.isEmpty ? 'None' : planetsIn1stHouse.join(', ')}
- Lagna Lord: $lagnaLord
- Lagna Lord Position: $lagnaLordSign (House $lagnaLordHouse)

GENERATE DETAILED LAGNA ANALYSIS:

━━━ 1. CORE IDENTITY ━━━
What $lagnaSign Lagna represents:
- Life approach and default behavior
- Vitality and energy expression
- Identity formation pattern

━━━ 2. PHYSICAL TENDENCIES ━━━
For $lagnaSign Lagna:
- Body frame and build tendencies
- Facial expression style
- Posture and movement patterns
- Eyes, skin, and distinctive features

━━━ 3. LAGNA LORD MODIFICATION ━━━
$lagnaLord as Lagna Lord in $lagnaLordSign (House $lagnaLordHouse):
- How this modifies physical appearance
- How this shapes life direction
- Energy and vitality implications

━━━ 4. PLANETS IN 1ST HOUSE ━━━
${planetsIn1stHouse.isEmpty ? 'No planets in 1st house - pure Lagna sign expression' : 'How ${planetsIn1stHouse.join(", ")} alter expression'}

━━━ 5. BEHAVIORAL PATTERNS ━━━
- First reactions and responses
- Confidence expression
- Social behavior tendencies
- How they approach new situations

━━━ 6. EVOLUTION WITH MATURITY ━━━
- How this Lagna evolves over decades
- What opens up after Saturn return
- Wisdom gained through this body type

━━━ 7. OBSERVATION CHECKLIST ━━━
- How to observe these Lagna traits in daily life
- What confirms this Lagna is operating
- Behavioral markers to track

Return as JSON:
{
  "lagna_sign": "$lagnaSign",
  "core_identity": {
    "life_approach": "detailed description",
    "default_behavior": "how they naturally act",
    "vitality_pattern": "energy expression"
  },
  "physical_tendencies": {
    "body_frame": "build and structure",
    "facial_style": "expression tendencies",
    "posture_movement": "how they move",
    "distinctive_features": ["feature1", "feature2"]
  },
  "lagna_lord_influence": {
    "lord": "$lagnaLord",
    "position": "$lagnaLordSign House $lagnaLordHouse",
    "modification": "how this changes expression",
    "life_direction": "where energy flows"
  },
  "first_house_planets": {
    "planets": ${planetsIn1stHouse.isEmpty ? '[]' : planetsIn1stHouse},
    "influence": "how they alter expression"
  },
  "behavioral_patterns": {
    "first_reactions": "how they respond initially",
    "confidence_style": "how confidence shows",
    "social_approach": "how they engage socially",
    "new_situations": "approach to the unfamiliar"
  },
  "evolution_path": {
    "youth": "early expression",
    "after_saturn_return": "matured expression",
    "wisdom_gained": "what age brings"
  },
  "observation_checklist": ["marker1", "marker2", "marker3", "marker4"]
}
''';

    final response = await _generateContent(prompt);
    
    try {
      final jsonStart = response.indexOf('{');
      final jsonEnd = response.lastIndexOf('}') + 1;
      if (jsonStart != -1 && jsonEnd > jsonStart) {
        final jsonStr = response.substring(jsonStart, jsonEnd);
        return jsonDecode(jsonStr);
      }
    } catch (e) {
      print('Error parsing Lagna analysis: $e');
    }
    
    return {'error': 'Unable to generate Lagna analysis', 'raw': response};
  }

  /// Generate Nakshatra psychological profile
  Future<Map<String, dynamic>> generateNakshatraProfile({
    required String nakshatra,
    required String nakshatraLord,
    required String planetInNakshatra,
    required String sign,
  }) async {
    final prompt = '''
You are a senior Vedic astrologer specializing in Nakshatra psychology and behavioral manifestation.

ANALYZE THIS NAKSHATRA PLACEMENT:

NAKSHATRA DATA:
- Nakshatra: $nakshatra
- Nakshatra Lord: $nakshatraLord
- Planet Placed: $planetInNakshatra
- Sign: $sign

GENERATE COMPREHENSIVE NAKSHATRA PSYCHOLOGY:

━━━ 1. CORE PSYCHOLOGY ━━━
For $nakshatra:
- Subconscious driver (the WHY behind behavior)
- Core desire that motivates
- Fear pattern that creates avoidance
- Growth impulse that propels forward

━━━ 2. BEHAVIORAL MANIFESTATION ━━━
How $nakshatra expresses through $planetInNakshatra:
- Social behavior tendencies
- Communication style
- Decision-making patterns
- Stress responses

━━━ 3. RELATIONSHIP STYLE ━━━
How $nakshatra influences:
- Emotional bonding patterns
- Trust development
- Intimacy expression
- Attachment security

━━━ 4. CAREER INCLINATIONS ━━━
Natural career paths for $nakshatra energy:
- Suitable fields
- Work style
- Leadership vs team orientation
- Creative expression

━━━ 5. EMOTIONAL TRIGGERS ━━━
What activates strong emotional responses:
- Triggers that create reactivity
- Healing patterns
- Coping mechanisms
- Growth edges

━━━ 6. ACTIVATION PERIODS ━━━
When $nakshatra energy activates strongly:
- During $nakshatraLord Dasha
- Transits over this degree
- Life themes that repeat

━━━ 7. DETECTION LOGIC ━━━
How to observe $nakshatra patterns:
- In relationship choices
- In career decisions
- In emotional responses
- In daily habits

Remember:
- Planet gives WHAT
- Sign gives HOW
- Nakshatra gives WHY

Return as JSON:
{
  "nakshatra": "$nakshatra",
  "lord": "$nakshatraLord",
  "planet": "$planetInNakshatra",
  "core_psychology": {
    "subconscious_driver": "the why behind behavior",
    "core_desire": "what motivates deeply",
    "fear_pattern": "what is avoided",
    "growth_impulse": "what propels forward"
  },
  "behavioral_manifestation": {
    "social_style": "how they engage socially",
    "communication": "how they express",
    "decision_making": "how they choose",
    "stress_response": "how they cope"
  },
  "relationship_style": {
    "bonding_pattern": "how they connect",
    "trust_development": "how trust builds",
    "intimacy_expression": "how closeness shows",
    "attachment_type": "security style"
  },
  "career_inclinations": {
    "suitable_fields": ["field1", "field2", "field3"],
    "work_style": "how they work",
    "leadership_orientation": "leader vs team",
    "creative_expression": "how creativity flows"
  },
  "emotional_triggers": {
    "reactivity_triggers": ["trigger1", "trigger2"],
    "healing_patterns": ["pattern1", "pattern2"],
    "coping_mechanisms": ["mechanism1", "mechanism2"],
    "growth_edges": ["edge1", "edge2"]
  },
  "activation_periods": {
    "dasha_activation": "how it shows during $nakshatraLord dasha",
    "transit_activation": "what transits trigger it",
    "recurring_themes": ["theme1", "theme2"]
  },
  "detection_checklist": ["how to observe in relationships", "how to observe in career", "how to observe emotionally"]
}
''';

    final response = await _generateContent(prompt);
    
    try {
      final jsonStart = response.indexOf('{');
      final jsonEnd = response.lastIndexOf('}') + 1;
      if (jsonStart != -1 && jsonEnd > jsonStart) {
        final jsonStr = response.substring(jsonStart, jsonEnd);
        return jsonDecode(jsonStr);
      }
    } catch (e) {
      print('Error parsing Nakshatra profile: $e');
    }
    
    return {'error': 'Unable to generate Nakshatra profile', 'raw': response};
  }

  /// Generate planetary behavioral remedy system
  Future<Map<String, dynamic>> generatePlanetaryRemedies({
    required String planet,
    required String sign,
    required int house,
    required String strength,
    required String context,
  }) async {
    final prompt = '''
You are a senior Vedic astrologer specializing in behavioral remedies and planetary strengthening.

GENERATE BEHAVIORAL REMEDY SYSTEM for:

PLANET DATA:
- Planet: $planet
- Sign: $sign
- House: $house
- Strength: $strength
- Context: $context

━━━ KEEPING $planet "HAPPY" ━━━

Define planetary happiness as:
- Expression of planet's natural function
- Alignment with planet's evolutionary purpose

GENERATE COMPREHENSIVE REMEDY SYSTEM:

1. CORE UNDERSTANDING
- Why $planet in $sign House $house needs attention
- What "weak" or "strong" means behaviorally
- How karaka problems appear as life issues

2. BEHAVIORAL REMEDIES (Primary)
- Daily habits that align with $planet energy
- Communication adjustments
- Lifestyle modifications
- Relationship behaviors

3. PRACTICAL ACTIONS
- 5-30 minute daily practices
- Weekly rituals that strengthen
- Monthly check-ins
- Seasonal adjustments

4. MENTAL/EMOTIONAL WORK
- Mindset shifts needed
- Emotional patterns to address
- Belief systems to examine
- Inner work focus

5. OBSERVAABLE IMPROVEMENTS
- How to know remedies are working
- Behavioral markers of strengthening
- Life area improvements to expect
- Timeline for changes

CRITICAL:
- Focus on behavior, not just rituals
- Explain WHY each remedy works
- Make everything practical and doable
- No superstition - psychological grounding

Return as JSON:
{
  "planet": "$planet",
  "placement": "$sign House $house",
  "strength": "$strength",
  "core_understanding": {
    "why_attention_needed": "specific reason for this chart",
    "behavioral_meaning": "what weakness/strength means in daily life",
    "karaka_impact": "which life areas affected and how"
  },
  "behavioral_remedies": {
    "daily_habits": ["habit1", "habit2", "habit3", "habit4", "habit5"],
    "communication_adjustments": ["adjustment1", "adjustment2"],
    "lifestyle_modifications": ["modification1", "modification2"],
    "relationship_behaviors": ["behavior1", "behavior2"]
  },
  "practical_actions": {
    "daily_practices": ["practice1 (10 min)", "practice2 (15 min)"],
    "weekly_rituals": ["ritual1", "ritual2"],
    "monthly_check_ins": ["checkin1", "checkin2"],
    "seasonal_focus": "what to emphasize each season"
  },
  "inner_work": {
    "mindset_shifts": ["shift1", "shift2"],
    "emotional_patterns": ["pattern to address"],
    "belief_systems": ["belief to examine"],
    "focus_area": "primary inner work"
  },
  "observable_improvements": {
    "behavioral_markers": ["marker1", "marker2"],
    "life_area_improvements": ["improvement1", "improvement2"],
    "timeline": "realistic expectation",
    "success_indicators": ["indicator1", "indicator2"]
  },
  "master_principle": "One core truth about strengthening $planet"
}
''';

    final response = await _generateContent(prompt);
    
    try {
      final jsonStart = response.indexOf('{');
      final jsonEnd = response.lastIndexOf('}') + 1;
      if (jsonStart != -1 && jsonEnd > jsonStart) {
        final jsonStr = response.substring(jsonStart, jsonEnd);
        return jsonDecode(jsonStr);
      }
    } catch (e) {
      print('Error parsing planetary remedies: $e');
    }
    
    return {'error': 'Unable to generate remedies', 'raw': response};
  }

  // Helper: Build planet summary for prompts
  String _buildPlanetSummary(Map<String, dynamic> planets, double ascDegree) {
    final buffer = StringBuffer();
    final ascSign = ((ascDegree / 30).floor() % 12) + 1;
    final signs = ['Aries', 'Taurus', 'Gemini', 'Cancer', 'Leo', 'Virgo',
                   'Libra', 'Scorpio', 'Sagittarius', 'Capricorn', 'Aquarius', 'Pisces'];
    final planetNames = {'Su': 'Sun', 'Mo': 'Moon', 'Ma': 'Mars', 'Me': 'Mercury',
                         'Ju': 'Jupiter', 'Ve': 'Venus', 'Sa': 'Saturn', 'Ra': 'Rahu', 'Ke': 'Ketu'};
    
    planets.forEach((abbr, data) {
      if (data is Map<String, dynamic>) {
        final degree = (data['longitude'] ?? data['degree'] ?? 0.0) as double;
        final signNum = ((degree / 30).floor() % 12) + 1;
        final houseNum = ((signNum - ascSign + 12) % 12) + 1;
        final signName = signs[signNum - 1];
        final planetName = planetNames[abbr] ?? abbr;
        buffer.writeln('  - $planetName: $signName (House $houseNum) at ${degree.toStringAsFixed(2)}°');
      }
    });
    
    return buffer.toString();
  }

  // Helper: Get Nakshatra name from degree
  String _getNakshatraName(double degree) {
    const nakshatras = [
      'Ashwini', 'Bharani', 'Krittika', 'Rohini', 'Mrigashira', 'Ardra',
      'Punarvasu', 'Pushya', 'Ashlesha', 'Magha', 'Purva Phalguni', 'Uttara Phalguni',
      'Hasta', 'Chitra', 'Swati', 'Vishakha', 'Anuradha', 'Jyeshtha',
      'Mula', 'Purva Ashadha', 'Uttara Ashadha', 'Shravana', 'Dhanishta', 'Shatabhisha',
      'Purva Bhadrapada', 'Uttara Bhadrapada', 'Revati',
    ];
    final index = ((degree / (360 / 27)).floor() % 27);
    return nakshatras[index];
  }

  /// Core method to call Gemini API
  Future<String> _generateContent(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.7,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 2048,
          },
          'safetySettings': [
            {
              'category': 'HARM_CATEGORY_HARASSMENT',
              'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
            },
            {
              'category': 'HARM_CATEGORY_HATE_SPEECH',
              'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
            },
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates'][0]['content']['parts'][0]['text'];
        return text ?? 'Unable to generate response';
      } else {
        print('API Error: ${response.statusCode} - ${response.body}');
        return 'Unable to generate response at this time. Please try again later.';
      }
    } catch (e) {
      print('Error calling Gemini API: $e');
      return 'Error generating content. Please check your internet connection.';
    }
  }

  /// Check if API key is configured
  bool isConfigured() {
    return _apiKey != 'YOUR_GEMINI_API_KEY_HERE' && _apiKey.isNotEmpty;
  }

  /// Public method to generate content with custom prompt
  Future<String> generateContent(String prompt) async {
    return await _generateContent(prompt);
  }
}
