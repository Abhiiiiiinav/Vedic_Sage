class NameAnalysisEngine {
  // Vedic-style sound to element mapping (approx)
  static final Map<String, String> _soundElementMap = {
    // Fire (Tejas)
    'k': 'fire', 'g': 'fire', 'r': 'fire', 'z': 'fire',

    // Air (Vayu)
    'c': 'air', 'j': 'air', 'l': 'air', 's': 'air', 'x': 'air',

    // Earth (Prithvi)
    't': 'earth', 'd': 'earth', 'n': 'earth', 'q': 'earth',

    // Water (Jala)
    'p': 'water', 'b': 'water', 'm': 'water', 'v': 'water', 'f': 'water',

    // Ether (Akasha)
    'h': 'ether', 'y': 'ether', 'w': 'ether',
  };

  static final Set<String> _vowels = {'a', 'e', 'i', 'o', 'u'};

  /// Deterministic name analysis using Vedic phonetic principles
  static Map<String, dynamic> analyzeName(String name) {
    final lower = name.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');

    int vowels = 0;
    int consonants = 0;
    int foreignSounds = 0;

    final Map<String, int> elementCount = {
      'fire': 0,
      'air': 0,
      'earth': 0,
      'water': 0,
      'ether': 0,
      'unknown': 0,
    };

    for (final ch in lower.split('')) {
      if (_vowels.contains(ch)) {
        vowels++;
      } else {
        consonants++;

        if (_soundElementMap.containsKey(ch)) {
          elementCount[_soundElementMap[ch]!] =
              elementCount[_soundElementMap[ch]!]! + 1;
        } else {
          elementCount['unknown'] = elementCount['unknown']! + 1;
          foreignSounds++;
        }
      }
    }

    final dominantElement = elementCount.entries
        .where((e) => e.key != 'unknown' && e.value > 0)
        .fold<MapEntry<String, int>?>(
          null,
          (prev, curr) => prev == null || curr.value > prev.value ? curr : prev,
        )
        ?.key ?? 'ether';

    return {
      'name': name,
      'normalized': lower,
      'length': lower.length,
      'vowels': vowels,
      'consonants': consonants,
      'vowel_consonant_ratio': consonants > 0 ? vowels / consonants : vowels.toDouble(),
      'foreign_sound_count': foreignSounds,
      'element_distribution': elementCount,
      'dominant_element': dominantElement,
      'has_foreign_influence': foreignSounds > 0,
      'first_letter': lower.isNotEmpty ? lower[0] : '',
      'first_sound_element': lower.isNotEmpty ? (_soundElementMap[lower[0]] ?? 'unknown') : 'unknown',
    };
  }

  /// Get element characteristics for interpretation
  static Map<String, dynamic> getElementCharacteristics(String element) {
    final characteristics = {
      'fire': {
        'qualities': ['Dynamic', 'Passionate', 'Leadership-oriented', 'Transformative'],
        'career_fit': ['Entrepreneurship', 'Politics', 'Sports', 'Innovation'],
        'relationship_style': 'Intense and inspiring',
      },
      'air': {
        'qualities': ['Intellectual', 'Communicative', 'Adaptable', 'Social'],
        'career_fit': ['Communication', 'Teaching', 'Writing', 'Sales'],
        'relationship_style': 'Friendly and mentally stimulating',
      },
      'earth': {
        'qualities': ['Grounded', 'Practical', 'Stable', 'Methodical'],
        'career_fit': ['Finance', 'Construction', 'Agriculture', 'Administration'],
        'relationship_style': 'Steady and reliable',
      },
      'water': {
        'qualities': ['Emotional', 'Nurturing', 'Intuitive', 'Flowing'],
        'career_fit': ['Healing', 'Arts', 'Counseling', 'Hospitality'],
        'relationship_style': 'Deeply caring and empathetic',
      },
      'ether': {
        'qualities': ['Spiritual', 'Expansive', 'Mysterious', 'Transcendent'],
        'career_fit': ['Research', 'Philosophy', 'Spirituality', 'Technology'],
        'relationship_style': 'Profound and otherworldly',
      },
    };

    return characteristics[element] ?? characteristics['ether']!;
  }
}
