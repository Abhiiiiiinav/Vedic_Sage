/// Name validation and phonetic analysis utilities
/// Three-level validation for accurate Vedic name analysis:
/// Level 1: Basic format validation
/// Level 2: Phonetic accuracy (sound quality)
/// Level 3: Syllable confidence for Nakshatra mapping

class NameValidator {
  // ============================================================================
  // LEVEL 1: BASIC NAME VALIDATION (INPUT SANITY)
  // ============================================================================
  
  /// Validates basic name format - only letters, spaces, hyphens, apostrophes
  static bool isValidNameFormat(String name) {
    final cleaned = name.trim();
    
    if (cleaned.length < 2) return false;
    
    // Allow letters, spaces, hyphens, apostrophes only
    final regex = RegExp(r"^[a-zA-Z\s\-']+$");
    return regex.hasMatch(cleaned);
  }
  
  // ============================================================================
  // LEVEL 2: SPELLING & PHONETIC ACCURACY (SOUND QUALITY)
  // ============================================================================
  
  /// Detects unusual consonant clusters that make pronunciation unclear
  static bool hasUnusualClusters(String name) {
    final n = name.toLowerCase();
    
    // Too many consonants in a row (4+)
    final cluster = RegExp(r"[bcdfghjklmnpqrstvwxyz]{4,}");
    return cluster.hasMatch(n);
  }
  
  /// Counts foreign/modern sounds (z, q, x) that indicate non-traditional vibration
  static int countForeignSounds(String name) {
    final foreign = RegExp(r"[zqxf]");
    return foreign.allMatches(name.toLowerCase()).length;
  }
  
  /// Generates soundex code for phonetic similarity matching
  /// Groups names with similar sounds (e.g., "Abhinav" and "Abhinab")
  static String soundex(String s) {
    s = s.toUpperCase();
    if (s.isEmpty) return "";
    
    const map = {
      'B': '1', 'F': '1', 'P': '1', 'V': '1',
      'C': '2', 'G': '2', 'J': '2', 'K': '2', 'Q': '2', 'S': '2', 'X': '2', 'Z': '2',
      'D': '3', 'T': '3',
      'L': '4',
      'M': '5', 'N': '5',
      'R': '6',
    };
    
    final first = s[0];
    final buffer = StringBuffer(first);
    
    String prev = map[first] ?? '';
    
    for (int i = 1; i < s.length; i++) {
      final code = map[s[i]] ?? '';
      if (code != prev && code.isNotEmpty) buffer.write(code);
      prev = code;
    }
    
    return buffer.toString().padRight(4, '0').substring(0, 4);
  }
  
  // ============================================================================
  // LEVEL 3: SYLLABLE CONFIDENCE (FOR NAKSHATRA MAPPING)
  // ============================================================================
  
  /// Extracts the leading syllable correctly handling Vedic conjuncts
  /// Recognizes: ch, sh, th, dh, bh, ph, gh, kh as single sounds
  static String extractLeadingSyllable(String name) {
    final n = name.toLowerCase();
    if (n.isEmpty) return '';
    
    // Match Vedic conjunct consonants first, then single letters
    final match = RegExp(r'^(ch|sh|th|dh|bh|ph|gh|kh|[a-z])')
        .firstMatch(n);
    
    return match?.group(0) ?? n[0];
  }
  
  /// Calculates confidence score for name analysis accuracy
  /// Returns 0.3 (low) to 1.0 (high) confidence
  static double nameConfidenceScore(String name) {
    double score = 1.0;
    
    if (hasUnusualClusters(name)) score -= 0.3;
    if (countForeignSounds(name) > 1) score -= 0.2;
    if (name.trim().length < 3) score -= 0.2;
    
    return score.clamp(0.3, 1.0);
  }
  
  /// Returns confidence level as enum for UI display
  static ConfidenceLevel getConfidenceLevel(double score) {
    if (score >= 0.8) return ConfidenceLevel.high;
    if (score >= 0.5) return ConfidenceLevel.medium;
    return ConfidenceLevel.low;
  }
  
  /// Returns user-friendly validation message
  static String getValidationMessage(String name) {
    if (!isValidNameFormat(name)) {
      return 'Please enter a valid alphabetic name';
    }
    
    final confidence = nameConfidenceScore(name);
    final hasUnusual = hasUnusualClusters(name);
    final foreignCount = countForeignSounds(name);
    
    if (confidence >= 0.8) {
      return 'Name looks good for analysis ✓';
    } else if (foreignCount > 1) {
      return 'Modern phonetic influence detected ⚠';
    } else if (hasUnusual) {
      return 'Pronunciation unclear — results may vary ⚠';
    } else {
      return 'Name accepted, moderate confidence';
    }
  }
  
  /// Comprehensive validation result with all metrics
  static NameValidationResult validate(String name) {
    return NameValidationResult(
      isValid: isValidNameFormat(name),
      confidence: nameConfidenceScore(name),
      confidenceLevel: getConfidenceLevel(nameConfidenceScore(name)),
      hasUnusualClusters: hasUnusualClusters(name),
      foreignSoundCount: countForeignSounds(name),
      soundexCode: soundex(name),
      leadingSyllable: extractLeadingSyllable(name),
      message: getValidationMessage(name),
    );
  }
}

// ============================================================================
// SUPPORTING ENUMS AND MODELS
// ============================================================================

enum ConfidenceLevel {
  high,   // >= 0.8 - Green checkmark
  medium, // >= 0.5 - Yellow warning
  low,    // < 0.5  - Red alert
}

class NameValidationResult {
  final bool isValid;
  final double confidence;
  final ConfidenceLevel confidenceLevel;
  final bool hasUnusualClusters;
  final int foreignSoundCount;
  final String soundexCode;
  final String leadingSyllable;
  final String message;
  
  NameValidationResult({
    required this.isValid,
    required this.confidence,
    required this.confidenceLevel,
    required this.hasUnusualClusters,
    required this.foreignSoundCount,
    required this.soundexCode,
    required this.leadingSyllable,
    required this.message,
  });
  
  /// Returns icon based on confidence level
  String get confidenceIcon {
    switch (confidenceLevel) {
      case ConfidenceLevel.high:
        return '✅';
      case ConfidenceLevel.medium:
        return '⚠';
      case ConfidenceLevel.low:
        return '❗';
    }
  }
  
  /// Returns color suggestion for UI
  String get confidenceColor {
    switch (confidenceLevel) {
      case ConfidenceLevel.high:
        return 'green';
      case ConfidenceLevel.medium:
        return 'orange';
      case ConfidenceLevel.low:
        return 'red';
    }
  }
}
