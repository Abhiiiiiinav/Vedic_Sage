/// Nakshatra syllables and phonetic mapping for name analysis
/// 
/// Traditional Vedic name selection is based on the syllable that corresponds
/// to the Moon's Nakshatra pada at birth.

class NakshatraSyllables {
  
  /// Map of Nakshatra names to their corresponding syllables/sounds
  /// Each Nakshatra has 4 padas, each with a specific syllable
  static const Map<String, List<String>> syllableMap = {
    // Nakshatra 1-9 (Ketu, Venus, Sun cycle)
    "Ashwini": ["Chu", "Che", "Cho", "La"],
    "Bharani": ["Li", "Lu", "Le", "Lo"],
    "Krittika": ["A", "I", "U", "E"],
    "Rohini": ["O", "Va", "Vi", "Vu"],
    "Mrigashira": ["Ve", "Vo", "Ka", "Ki"],
    "Ardra": ["Ku", "Gha", "Ng", "Chha"],
    "Punarvasu": ["Ke", "Ko", "Ha", "Hi"],
    "Pushya": ["Hu", "He", "Ho", "Da"],
    "Ashlesha": ["Di", "Du", "De", "Do"],

    // Nakshatra 10-18 (Moon, Mars, Rahu cycle)
    "Magha": ["Ma", "Mi", "Mu", "Me"],
    "PurvaPhalguni": ["Mo", "Ta", "Ti", "Tu"],
    "UttaraPhalguni": ["Te", "To", "Pa", "Pi"],
    "Hasta": ["Pu", "Sha", "Na", "Tha"],
    "Chitra": ["Pe", "Po", "Ra", "Ri"],
    "Swati": ["Ru", "Re", "Ro", "Ta"],
    "Vishakha": ["Ti", "Tu", "Te", "To"],
    "Anuradha": ["Na", "Ni", "Nu", "Ne"],
    "Jyeshtha": ["No", "Ya", "Yi", "Yu"],

    // Nakshatra 19-27 (Jupiter, Saturn, Mercury cycle)
    "Moola": ["Ye", "Yo", "Bha", "Bhi"],
    "PurvaAshadha": ["Bhu", "Dha", "Pha", "Dha"],
    "UttaraAshadha": ["Bhe", "Bho", "Ja", "Ji"],
    "Shravana": ["Khi", "Khu", "Khe", "Kho"],
    "Dhanishta": ["Ga", "Gi", "Gu", "Ge"],
    "Shatabhisha": ["Go", "Sa", "Si", "Su"],
    "PurvaBhadra": ["Se", "So", "Da", "Di"],
    "UttaraBhadra": ["Du", "Tha", "Jha", "Na"],
    "Revati": ["De", "Do", "Cha", "Chi"],
  };

  /// Get syllables for a specific Nakshatra by index (1-27)
  static List<String>? getSyllables(int nakshatraIndex) {
    if (nakshatraIndex < 1 || nakshatraIndex > 27) return null;
    
    final nakshatraNames = syllableMap.keys.toList();
    final name = nakshatraNames[nakshatraIndex - 1];
    return syllableMap[name];
  }

  /// Get the recommended syllable for a specific Nakshatra pada
  /// 
  /// [nakshatraIndex] - Nakshatra number (1-27)
  /// [pada] - Pada number (1-4)
  /// Returns: The syllable for that specific pada
  static String? getSyllableForPada(int nakshatraIndex, int pada) {
    if (pada < 1 || pada > 4) return null;
    
    final syllables = getSyllables(nakshatraIndex);
    if (syllables == null) return null;
    
    return syllables[pada - 1];
  }

  /// Calculate pada from Moon's degree
  /// 
  /// Each Nakshatra = 13°20' (13.333...)
  /// Each Pada = 3°20' (3.333...)
  /// 
  /// [moonDegree] - Moon's sidereal degree (0-360)
  /// Returns: Pada number (1-4)
  static int getPadaFromDegree(double moonDegree) {
    final degInNakshatra = moonDegree % 13.3333333;
    final pada = (degInNakshatra / 3.3333333).floor() + 1;
    return pada.clamp(1, 4);
  }

  /// Get Nakshatra name from index
  static String getNakshatraName(int nakshatraIndex) {
    if (nakshatraIndex < 1 || nakshatraIndex > 27) return "Unknown";
    return syllableMap.keys.toList()[nakshatraIndex - 1];
  }

  /// Find matching Nakshatras for a given name
  /// 
  /// Normalizes the name phonetically and matches against syllables
  /// 
  /// [name] - The name to analyze
  /// Returns: List of potential matching Nakshatra indices
  static List<int> findMatchingNakshatras(String name) {
    final normalized = normalizeNamePhonetically(name);
    final firstSound = getFirstSound(normalized);
    
    final matches = <int>[];
    
    for (int i = 1; i <= 27; i++) {
      final syllables = getSyllables(i);
      if (syllables == null) continue;
      
      for (final syllable in syllables) {
        if (firstSound.toUpperCase().startsWith(syllable.toUpperCase()) ||
            syllable.toUpperCase().startsWith(firstSound.toUpperCase())) {
          matches.add(i);
          break;
        }
      }
    }
    
    return matches;
  }

  /// Normalize name phonetically for matching
  /// 
  /// Handles foreign sounds (Z, X, Q) and common variations
  static String normalizeNamePhonetically(String name) {
    var normalized = name.toLowerCase().trim();
    
    // Foreign sound mappings
    normalized = normalized.replaceAll(RegExp(r'^z'), 'j');
    normalized = normalized.replaceAll(RegExp(r'^x'), 'ks');
    normalized = normalized.replaceAll(RegExp(r'^q'), 'k');
    
    // Common phonetic equivalents
    normalized = normalized.replaceAll('ph', 'f');
    normalized = normalized.replaceAll('kh', 'k');
    normalized = normalized.replaceAll('gh', 'g');
    
    // Handle Ch combinations
    if (normalized.startsWith('ch')) {
      normalized = 'cha' + normalized.substring(2);
    }
    
    return normalized;
  }

  /// Get the first phonetic sound from a name
  static String getFirstSound(String name) {
    final normalized = normalizeNamePhonetically(name);
    if (normalized.isEmpty) return "";
    
    // Try to get first 2-3 characters for better matching
    if (normalized.length >= 2) {
      return normalized.substring(0, 2);
    }
    
    return normalized.substring(0, 1);
  }

  /// Check if a name is compatible with a Nakshatra
  /// 
  /// [name] - The name to check
  /// [nakshatraIndex] - The Nakshatra to check against (1-27)
  /// Returns: true if the name matches any pada of the Nakshatra
  static bool isNameCompatible(String name, int nakshatraIndex) {
    final matches = findMatchingNakshatras(name);
    return matches.contains(nakshatraIndex);
  }
}

/// Analysis result for a name against a target Nakshatra
class NakshatraNameAnalysis {
  final String name;
  final String nakshatraName;
  final bool isAuspicious;
  final String? matchingSyllable;
  final List<String> auspiciousSyllables;
  final List<String>? aiGeneratedMaleNames;
  final List<String>? aiGeneratedFemaleNames;

  NakshatraNameAnalysis({
    required this.name,
    required this.nakshatraName,
    required this.isAuspicious,
    this.matchingSyllable,
    required this.auspiciousSyllables,
    this.aiGeneratedMaleNames,
    this.aiGeneratedFemaleNames,
  });

  /// Analyze a name against a specific Nakshatra
  static NakshatraNameAnalysis analyze(String name, String nakshatraName) {
    final normalized = NakshatraSyllables.normalizeNamePhonetically(name);
    final firstSound = NakshatraSyllables.getFirstSound(normalized);
    
    // Get syllables for this nakshatra
    // Note: This relies on the internal map in NakshatraSyllables matching the name provided
    // We do a best-effort lookup by cleaning the name
    
    List<String> validSyllables = [];
    
    // Find key in NakshatraSyllables map case-insensitively or via cleaned name
    String? matchedKey;
    for (final key in NakshatraSyllables.syllableMap.keys) {
      if (key.toLowerCase().replaceAll(' ', '') == nakshatraName.toLowerCase().replaceAll(' ', '')) {
        matchedKey = key;
        break;
      }
    }
    
    if (matchedKey != null) {
      validSyllables = NakshatraSyllables.syllableMap[matchedKey] ?? [];
    }

    String? match;
    for (final syllable in validSyllables) {
      if (firstSound.toUpperCase().startsWith(syllable.toUpperCase()) ||
          syllable.toUpperCase().startsWith(firstSound.toUpperCase())) {
        match = syllable;
        break;
      }
    }

    return NakshatraNameAnalysis(
      name: name,
      nakshatraName: nakshatraName,
      isAuspicious: match != null,
      matchingSyllable: match,
      auspiciousSyllables: validSyllables,
    );
  }

  NakshatraNameAnalysis withAINames({
    List<String>? maleNames,
    List<String>? femaleNames,
  }) {
    return NakshatraNameAnalysis(
      name: this.name,
      nakshatraName: this.nakshatraName,
      isAuspicious: this.isAuspicious,
      matchingSyllable: this.matchingSyllable,
      auspiciousSyllables: this.auspiciousSyllables,
      aiGeneratedMaleNames: maleNames ?? this.aiGeneratedMaleNames,
      aiGeneratedFemaleNames: femaleNames ?? this.aiGeneratedFemaleNames,
    );
  }
}
