import '../models/models.dart';
import '../constants/nakshatra_data.dart';

/// Professional Vedic Name-Nakshatra Analyzer
/// 
/// This analyzes NAME vibration (mental pattern), NOT Moon-Nakshatra (destiny).
/// 
/// Process:
/// 1. Normalize name → extract phonetic sounds
/// 2. Detect digraphs (ch, sh, th, dh, bh, ph, kh, gh, ksh)
/// 3. Map first strong syllable → Primary Nakshatra
/// 4. Analyze dominant/ending sounds → Secondary influence
/// 5. Calculate elemental balance
class VedicNameAnalyzer {
  
  /// Phonetic digraphs in Sanskrit/Hindi names
  static const List<String> digraphs = [
    'ksh', 'ch', 'sh', 'th', 'dh', 'bh', 'ph', 'kh', 'gh'
  ];
  
  /// Complete Nakshatra sound mapping (based on authoritative Pada table)
  static final Map<String, List<String>> nakshatraSounds = {
    // Ashwini: Chu, Che, Cho, La
    'Ashwini': ['chu', 'che', 'cho', 'la'],
    
    // Bharani: Li, Lu, Ley, Lo
    'Bharani': ['li', 'lu', 'le', 'ley', 'lo'],
    
    // Krittika: Aa, Ee, U, A
    'Krittika': ['aa', 'ee', 'u', 'a', 'i', 'ea'],
    
    // Rohini: O, Va, Vee, Vo
    'Rohini': ['o', 'va', 'vi', 'vee', 'vo'],
    
    // Mrigashira: Vay, Vo, Ka, Kee
    'Mrigashira': ['ve', 'vay', 'vo', 'ka', 'ki', 'kee'],
    
    // Ardra: Koo, Ghaa, Jna, Chcha
    'Ardra': ['ku', 'koo', 'gha', 'ghaa', 'jna', 'chha', 'chcha'],
    
    // Punarvasu: Kay, Ko, Ha, Hee
    'Punarvasu': ['ke', 'kay', 'ko', 'ha', 'hi', 'hee'],
    
    // Pushya: Hoo, Hay, Ho, Daa
    'Pushya': ['hu', 'hoo', 'he', 'hay', 'ho', 'da', 'daa'],
    
    // Ashlesha: Dee, Doo, Day, Do
    'Ashlesha': ['di', 'dee', 'du', 'doo', 'de', 'day', 'do'],
    
    // Magha: Maa, Mee, Moo, May
    'Magha': ['ma', 'maa', 'mi', 'mee', 'mu', 'moo', 'me', 'may'],
    
    // Purva Phalguni: Mo, Taa, Tee, Too
    'Purva Phalguni': ['mo', 'ta', 'taa', 'ti', 'tee', 'tu', 'too'],
    
    // Uttara Phalguni: Tay, To, Paa, Pee
    'Uttara Phalguni': ['te', 'tay', 'to', 'pa', 'paa', 'pi', 'pee'],
    
    // Hasta: Pu, Shaa, Na, Thaa
    'Hasta': ['pu', 'sha', 'shaa', 'na', 'tha', 'thaa'],
    
    // Chitra: Pay, Po, Raa, Re
    'Chitra': ['pe', 'pay', 'po', 'ra', 'raa', 'ri', 'ree'],
    
    // Swati: Ru, Ray, Pa, Ta
    'Swati': ['ru', 'roo', 're', 'ray', 'ro', 'ta'],  // Note: 'Pa' logic conflict with U-Phalguni? Table says Pa is here (Pada 3).
                                                     // User Table: Swati Pada 3 is 'Pa', Pada 4 is 'Ta'.
                                                     // U-Phalguni Pada 3 is 'Paa'. 
                                                     // We keep both. Exact match priority handles conflicts.
    
    // Vishakha: Thee, Thuu, Thay, Thou
    'Vishakha': ['ti', 'thee', 'tu', 'thuu', 'te', 'thay', 'to', 'thou'],
    
    // Anuradha: Naa, Nee, Nou, Nay
    'Anuradha': ['na', 'naa', 'ni', 'nee', 'nu', 'nou', 'ne', 'nay'],
    
    // Jyeshtha: No, Ya, Yee, You
    'Jyeshtha': ['no', 'ya', 'yi', 'yee', 'yu', 'you'],
    
    // Mula: Yay, Yo, Baa, Bee
    'Mula': ['ye', 'yay', 'yo', 'ba', 'baa', 'bi', 'bee', 'bha'], // Bha/Ba often interchangeable
    
    // Purva Ashadha: By, Dha, Bha, Dha
    // Table: By(? usually Bu), Dha, Bha, Dha. Assuming 'Bu' for 'By' or 'Bhay'.
    'Purva Ashadha': ['bu', 'dha', 'bha', 'pha'], 
    
    // Uttara Ashadha: Bay, Bo, Jaa, Jee
    'Uttara Ashadha': ['be', 'bay', 'bo', 'ja', 'jaa', 'ji', 'jee'],
    
    // Shravana: Ju, Jay, Jo, Gha
    'Shravana': ['ju', 'je', 'jay', 'jo', 'gha'], // Gha also in Ardra, checking context
    
    // Dhanishta: Gaa, Gee, Goo, Gay
    'Dhanishta': ['ga', 'gaa', 'gi', 'gee', 'gu', 'goo', 'ge', 'gay'],
    
    // Shatabhisha: Go, Sa, See, Sou
    'Shatabhisha': ['go', 'sa', 'si', 'see', 'su', 'sou', 'shu'], // Added 'shu' for phonetic variation of 'su/sou'
    
    // Purva Bhadrapada: Say, So, Daa, Dee
    'Purva Bhadrapada': ['se', 'say', 'so', 'da', 'daa', 'di', 'dee'],
    
    // Uttara Bhadrapada: Du, Tha, Aa, Jna
    'Uttara Bhadrapada': ['du', 'tha', 'jna', 'aa', 'gya'], 
    
    // Revati: De, Do, Chaa, Chee
    'Revati': ['de', 'do', 'cha', 'chaa', 'chi', 'chee'],
  };
  
  /// Elemental classification of sounds
  static final Map<String, String> soundElements = {
    // Fire (Tejas)
    'ka': 'fire', 'ra': 'fire', 'ta': 'fire', 'za': 'fire',
    // Air (Vayu)  
    'sa': 'air', 'la': 'air', 'xa': 'air', 'cha': 'air', 'sha': 'air',
    // Earth (Prithvi)
    'na': 'earth', 'da': 'earth', 'qa': 'earth', 'tha': 'earth',
    // Water (Jala)
    'ma': 'water', 'ba': 'water', 'va': 'water', 'fa': 'water', 'pa': 'water', 'bha': 'water',
    // Ether (Akasha)
    'ha': 'ether', 'ya': 'ether', 'wa': 'ether', 'kha': 'ether', 'gha': 'ether',
  };
  
  /// Analyze name and return comprehensive Nakshatra influence
  static NameNakshatraAnalysis analyzeName(String name) {
    // Step 1: Normalize
    final normalized = _normalizeName(name);
    
    // Step 2: Extract phonetic units
    final firstSyllable = _extractFirstSyllable(normalized);
    final dominantSound = _findDominantSound(normalized);
    final endingSound = _extractEndingSound(normalized);
    
    // Step 3: Map to Nakshatras
    final primary = _findPrimaryNakshatra(firstSyllable);
    final secondary = _findSecondaryNakshatra(dominantSound);
    final stressResponse = _findStressResponse(endingSound);
    
    // Step 4: Calculate elemental balance
    final elements = _calculateElements(normalized);
    
    return NameNakshatraAnalysis(
      name: name,
      normalized: normalized,
      primaryNakshatra: primary,
      secondaryInfluence: secondary,
      stressResponse: stressResponse,
      elementalBalance: elements,
      firstSyllable: firstSyllable,
      dominantSound: dominantSound,
      endingSound: endingSound,
    );
  }
  
  /// Step 1: Normalize name - remove junk, keep phonetic integrity
  static String _normalizeName(String name) {
    String cleaned = name.toLowerCase().trim();
    // Remove numbers, symbols, but keep letters
    cleaned = cleaned.replaceAll(RegExp(r'[^a-z]'), '');
    return cleaned;
  }
  
  /// Step 2: Extract first strong phonetic syllable
  static String _extractFirstSyllable(String name) {
    if (name.isEmpty) return '';
    
    // Check for digraphs first (critical!)
    for (final digraph in digraphs) {
      if (name.startsWith(digraph)) {
        // Get digraph + next vowel if exists
        if (name.length > digraph.length) {
          final nextChar = name[digraph.length];
          if ('aeiou'.contains(nextChar)) {
            return digraph + nextChar;
          }
        }
        return digraph;
      }
    }
    
    // Single consonant + vowel
    if (name.length >= 2) {
      final first = name[0];
      final second = name[1];
      if ('aeiou'.contains(second)) {
        return first + second;
      }
    }
    
    // Just first char if vowel
    if ('aeiou'.contains(name[0])) {
      return name[0];
    }
    
    // Fallback to first 2 chars
    return name.length >= 2 ? name.substring(0, 2) : name;
  }
  
  /// Find dominant repeated sound (mental habit loop)
  static String _findDominantSound(String name) {
    final Map<String, int> soundCount = {};
    
    // Count digraphs
    for (final digraph in digraphs) {
      final count = digraph.allMatches(name).length;
      if (count > 0) soundCount[digraph] = count;
    }
    
    // Count single sounds (first 2 chars of each segment)
    for (int i = 0; i < name.length - 1; i++) {
      final sound = name.substring(i, i + 2);
      soundCount[sound] = (soundCount[sound] ?? 0) + 1;
    }
    
    if (soundCount.isEmpty) return '';
    
    // Return most frequent
    return soundCount.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }
  
  /// Extract ending sound (stress response indicator)
  static String _extractEndingSound(String name) {
    if (name.length < 2) return name;
    return name.substring(name.length - 2);
  }
  
  /// Map first syllable to primary Nakshatra - PRIORITIZING SPECIFICITY (Longest Match)
  static NakshatraMatch? _findPrimaryNakshatra(String syllable) {
    NakshatraMatch? bestMatch;
    int maxMatchLength = -1;

    for (final entry in nakshatraSounds.entries) {
      for (final sound in entry.value) {
        // Check for match
        if (syllable.toLowerCase() == sound.toLowerCase() ||
            syllable.toLowerCase().startsWith(sound.toLowerCase())) {
          
          // Found a match. Is it better (longer) than previous?
          if (sound.length > maxMatchLength) {
            final nakshatra = NakshatraData.nakshatras.firstWhere(
              (n) => n.name == entry.key,
            );
            
            bestMatch = NakshatraMatch(
              nakshatra: nakshatra,
              matchedSyllable: sound,
              confidenceLevel: 'High - Primary',
              matchType: 'Life Direction',
            );
            maxMatchLength = sound.length;
          }
        }
      }
    }
    return bestMatch;
  }
  
  /// Find secondary Nakshatra from dominant sound
  static NakshatraMatch? _findSecondaryNakshatra(String sound) {
    for (final entry in nakshatraSounds.entries) {
      if (entry.value.any((s) => s.contains(sound.substring(0, 1)))) {
        final nakshatra = NakshatraData.nakshatras.firstWhere(
          (n) => n.name == entry.key,
        );
        return NakshatraMatch(
          nakshatra: nakshatra,
          matchedSyllable: sound,
          confidenceLevel: 'Medium - Secondary',
          matchType: 'Mental Habit',
        );
      }
    }
    return null;
  }
  
  /// Find stress response from ending
  static String _findStressResponse(String ending) {
    if (ending.endsWith('v') || ending.endsWith('va')) return 'Relational coping';
    if (ending.endsWith('r') || ending.endsWith('ra')) return 'Aggressive coping';
    if (ending.endsWith('n') || ending.endsWith('na')) return 'Emotional dependency';
    if (ending.endsWith('m') || ending.endsWith('ma')) return 'Nurturing response';
    if (ending.endsWith('l') || ending.endsWith('la')) return 'Flexible adaptation';
    return 'Balanced response';
  }
  
  /// Calculate elemental balance (Panchabhuta)
  static Map<String, int> _calculateElements(String name) {
    final Map<String, int> elements = {
      'fire': 0,
      'air': 0,
      'earth': 0,
      'water': 0,
      'ether': 0,
    };
    
    // Analyze each 2-char sound unit
    for (int i = 0; i < name.length - 1; i++) {
      final sound = name.substring(i, i + 2);
      if (soundElements.containsKey(sound)) {
        final element = soundElements[sound]!;
        elements[element] = elements[element]! + 1;
      }
    }
    
    return elements;
  }
  
  /// Get all 27 Nakshatras with their sounds for educational reference
  static List<NakshatraReference> getAllNakshatrasReference() {
    return NakshatraData.nakshatras.map((nakshatra) {
      final sounds = nakshatraSounds[nakshatra.name] ?? [];
      return NakshatraReference(
        nakshatra: nakshatra,
        sounds: sounds,
        soundsFormatted: sounds.join(', '),
      );
    }).toList();
  }
}

/// Complete analysis result with multi-layer interpretation
class NameNakshatraAnalysis {
  final String name;
  final String normalized;
  final NakshatraMatch? primaryNakshatra;
  final NakshatraMatch? secondaryInfluence;
  final String stressResponse;
  final Map<String, int> elementalBalance;
  final String firstSyllable;
  final String dominantSound;
  final String endingSound;
  
  NameNakshatraAnalysis({
    required this.name,
    required this.normalized,
    this.primaryNakshatra,
    this.secondaryInfluence,
    required this.stressResponse,
    required this.elementalBalance,
    required this.firstSyllable,
    required this.dominantSound,
    required this.endingSound,
  });
  
  /// Get dominant element
  String get dominantElement {
    return elementalBalance.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }
  
  /// Comprehensive interpretation
  String get fullInterpretation {
    final parts = <String>[];
    
    if (primaryNakshatra != null) {
      parts.add('Primary Direction (${primaryNakshatra!.nakshatra.name}): ${primaryNakshatra!.nakshatra.description}');
    }
    
    if (secondaryInfluence != null) {
      parts.add('Mental Habit Pattern: ${secondaryInfluence!.nakshatra.name} influence');
    }
    
    parts.add('Stress Response: $stressResponse');
    parts.add('Dominant Element: $dominantElement (temperament)');
    
    return parts.join('\n\n');
  }
}

/// Nakshatra match with context
class NakshatraMatch {
  final Nakshatra nakshatra;
  final String matchedSyllable;
  final String confidenceLevel;
  final String matchType;
  
  NakshatraMatch({
    required this.nakshatra,
    required this.matchedSyllable,
    required this.confidenceLevel,
    required this.matchType,
  });
}

/// Nakshatra reference for educational display
class NakshatraReference {
  final Nakshatra nakshatra;
  final List<String> sounds;
  final String soundsFormatted;
  
  NakshatraReference({
    required this.nakshatra,
    required this.sounds,
    required this.soundsFormatted,
  });
}
