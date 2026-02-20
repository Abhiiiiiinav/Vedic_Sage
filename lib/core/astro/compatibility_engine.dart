/// Ashtakoot Guna Milan (8-Factor Vedic Compatibility Engine)
///
/// Computes compatibility score out of 36 based on Moon sign
/// and Nakshatra data from two birth charts.

import 'kundali_engine.dart';

// ════════════════════════════════════════════════════════════
// RESULT MODELS
// ════════════════════════════════════════════════════════════

class GunaScore {
  final String name;
  final String description;
  final double earned;
  final double maximum;
  final String interpretation;

  const GunaScore({
    required this.name,
    required this.description,
    required this.earned,
    required this.maximum,
    required this.interpretation,
  });

  double get percentage => maximum > 0 ? (earned / maximum) * 100 : 0;
}

class ElementBalance {
  final int fire;
  final int earth;
  final int air;
  final int water;

  const ElementBalance(
      {required this.fire,
      required this.earth,
      required this.air,
      required this.water});

  int get total => fire + earth + air + water;
  String get dominant {
    final map = {'Fire': fire, 'Earth': earth, 'Air': air, 'Water': water};
    return map.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }
}

class CompatibilityReport {
  final String person1Name;
  final String person2Name;
  final List<GunaScore> gunas;
  final double totalScore;
  final double maxScore;
  final String grade;
  final String verdict;
  final ElementBalance person1Elements;
  final ElementBalance person2Elements;
  final List<String> sharedSigns;
  final List<PlanetComparison> planetComparisons;

  const CompatibilityReport({
    required this.person1Name,
    required this.person2Name,
    required this.gunas,
    required this.totalScore,
    required this.maxScore,
    required this.grade,
    required this.verdict,
    required this.person1Elements,
    required this.person2Elements,
    required this.sharedSigns,
    required this.planetComparisons,
  });

  double get percentage => (totalScore / maxScore) * 100;
}

class PlanetComparison {
  final String planet;
  final String person1Sign;
  final String person2Sign;
  final int person1House;
  final int person2House;
  final bool sameSign;

  const PlanetComparison({
    required this.planet,
    required this.person1Sign,
    required this.person2Sign,
    required this.person1House,
    required this.person2House,
    required this.sameSign,
  });
}

// ════════════════════════════════════════════════════════════
// COMPATIBILITY ENGINE
// ════════════════════════════════════════════════════════════

class CompatibilityEngine {
  // ── Sign Constants ──
  static const _signs = [
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
    'Pisces',
  ];

  // Sign lords (0-indexed)
  static const _signLords = [
    'Mars',
    'Venus',
    'Mercury',
    'Moon',
    'Sun',
    'Mercury',
    'Venus',
    'Mars',
    'Jupiter',
    'Saturn',
    'Saturn',
    'Jupiter',
  ];

  // Element: Fire=0, Earth=1, Air=2, Water=3
  static const _signElements = [0, 1, 2, 3, 0, 1, 2, 3, 0, 1, 2, 3];

  // Varna: Brahmin(3)=highest, Kshatriya(2), Vaishya(1), Shudra(0)
  static const _signVarna = [2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3];

  // Vashya groups: Chatushpada(0), Manava(1), Jalachara(2), Vanachara(3), Keeta(4)
  static const _signVashya = [0, 0, 1, 2, 3, 1, 1, 4, 0, 2, 1, 2];

  // Nakshatra Gana: Deva(0), Manushya(1), Rakshasa(2)
  static const _nakshatraGana = [
    0, 1, 2, 1, 0, 1, 0, 0, 2, // 1-9
    2, 1, 0, 0, 2, 0, 2, 0, 2, // 10-18
    2, 1, 1, 0, 2, 2, 1, 1, 0, // 19-27
  ];

  // Nakshatra Yoni (animal): 14 animals
  static const _nakshatraYoni = [
    0, 1, 2, 3, 3, 4, 5, 6,
    5, // Horse, Elephant, Sheep, Snake, Snake, Dog, Cat, Ram, Cat
    7, 7, 8, 9, 10, 9, 10, 11,
    11, // Rat, Rat, Cow, Buffalo, Tiger, Buffalo, Tiger, Deer, Deer
    4, 12, 8, 12, 0, 6, 13, 8,
    1, // Dog, Monkey, Cow, Monkey, Horse, Ram, Lion, Cow, Elephant
  ];

  // Nakshatra Nadi: Aadi(0), Madhya(1), Antya(2)
  static const _nakshatraNadi = [
    0, 1, 2, 2, 1, 0, 0, 1, 2, // 1-9
    0, 1, 2, 2, 1, 0, 0, 1, 2, // 10-18
    0, 1, 2, 2, 1, 0, 0, 1, 2, // 19-27
  ];

  // Planet friendship table (natural)
  static const _friendships = <String, List<String>>{
    'Sun': ['Moon', 'Mars', 'Jupiter'],
    'Moon': ['Sun', 'Mercury'],
    'Mars': ['Sun', 'Moon', 'Jupiter'],
    'Mercury': ['Sun', 'Venus'],
    'Jupiter': ['Sun', 'Moon', 'Mars'],
    'Venus': ['Mercury', 'Saturn'],
    'Saturn': ['Mercury', 'Venus'],
  };

  static const _enemies = <String, List<String>>{
    'Sun': ['Venus', 'Saturn'],
    'Moon': [],
    'Mars': ['Mercury'],
    'Mercury': ['Moon'],
    'Jupiter': ['Mercury', 'Venus'],
    'Venus': ['Sun', 'Moon'],
    'Saturn': ['Sun', 'Moon', 'Mars'],
  };

  // ════════════════════════════════════════════════════════════
  // MAIN: Generate Full Report
  // ════════════════════════════════════════════════════════════

  static CompatibilityReport generateReport({
    required KundaliResult chart1,
    required KundaliResult chart2,
    required String name1,
    required String name2,
  }) {
    // Extract Moon data
    final moon1 = chart1.planets['Moon']!;
    final moon2 = chart2.planets['Moon']!;
    final moonSignIdx1 = moon1['signIndex'] as int;
    final moonSignIdx2 = moon2['signIndex'] as int;
    final moonNakIdx1 = (moon1['nakshatraIndex'] as int) - 1; // 0-indexed
    final moonNakIdx2 = (moon2['nakshatraIndex'] as int) - 1;

    // Calculate 8 Gunas
    final gunas = <GunaScore>[
      _calcVarna(moonSignIdx1, moonSignIdx2),
      _calcVashya(moonSignIdx1, moonSignIdx2),
      _calcTara(moonNakIdx1, moonNakIdx2),
      _calcYoni(moonNakIdx1, moonNakIdx2),
      _calcGrahaMaitri(moonSignIdx1, moonSignIdx2),
      _calcGana(moonNakIdx1, moonNakIdx2),
      _calcBhakut(moonSignIdx1, moonSignIdx2),
      _calcNadi(moonNakIdx1, moonNakIdx2),
    ];

    final total = gunas.fold<double>(0, (sum, g) => sum + g.earned);
    final grade = _getGrade(total);
    final verdict = _getVerdict(total);

    // Planet comparisons
    final comparisons = _buildPlanetComparisons(chart1, chart2);
    final shared =
        comparisons.where((c) => c.sameSign).map((c) => c.planet).toList();

    // Element balance
    final elem1 = _getElementBalance(chart1);
    final elem2 = _getElementBalance(chart2);

    return CompatibilityReport(
      person1Name: name1,
      person2Name: name2,
      gunas: gunas,
      totalScore: total,
      maxScore: 36,
      grade: grade,
      verdict: verdict,
      person1Elements: elem1,
      person2Elements: elem2,
      sharedSigns: shared,
      planetComparisons: comparisons,
    );
  }

  // ════════════════════════════════════════════════════════════
  // 8 GUNAS
  // ════════════════════════════════════════════════════════════

  /// 1. Varna (1 point) — Spiritual compatibility
  static GunaScore _calcVarna(int sign1, int sign2) {
    final v1 = _signVarna[sign1];
    final v2 = _signVarna[sign2];
    // Boy's varna should be >= girl's (traditional). Here we just check equality or proximity.
    final earned = v1 >= v2 ? 1.0 : 0.0;
    return GunaScore(
      name: 'Varna',
      description: 'Spiritual compatibility',
      earned: earned,
      maximum: 1,
      interpretation: earned > 0
          ? 'Good spiritual alignment between both charts'
          : 'Different spiritual temperaments — growth opportunity',
    );
  }

  /// 2. Vashya (2 points) — Mutual attraction & control
  static GunaScore _calcVashya(int sign1, int sign2) {
    final g1 = _signVashya[sign1];
    final g2 = _signVashya[sign2];
    double earned;
    if (g1 == g2) {
      earned = 2;
    } else if (_vashyaCompatible(g1, g2)) {
      earned = 1;
    } else {
      earned = 0;
    }
    return GunaScore(
      name: 'Vashya',
      description: 'Mutual attraction & influence',
      earned: earned,
      maximum: 2,
      interpretation: earned >= 2
          ? 'Strong natural magnetism between you'
          : earned >= 1
              ? 'Moderate mutual attraction'
              : 'Different wavelengths — needs conscious effort',
    );
  }

  static bool _vashyaCompatible(int g1, int g2) {
    // Simplified: Manava(1) controls Chatushpada(0) & Jalachara(2)
    if (g1 == 1 && (g2 == 0 || g2 == 2)) return true;
    if (g2 == 1 && (g1 == 0 || g1 == 2)) return true;
    return false;
  }

  /// 3. Tara (3 points) — Destiny compatibility (Nakshatra distance)
  static GunaScore _calcTara(int nak1, int nak2) {
    final dist = ((nak2 - nak1) % 27 + 27) % 27;
    final tara = (dist % 9) + 1;
    // Favorable taras: 1, 2, 4, 6, 8, 9
    final favorable = {1, 2, 4, 6, 8, 9};
    final earned = favorable.contains(tara) ? 3.0 : 0.0;
    final taraNames = [
      '',
      'Janma',
      'Sampat',
      'Vipat',
      'Kshema',
      'Pratyari',
      'Sadhaka',
      'Vadha',
      'Mitra',
      'Ati Mitra'
    ];
    return GunaScore(
      name: 'Tara',
      description: 'Destiny & star harmony',
      earned: earned,
      maximum: 3,
      interpretation: earned > 0
          ? 'Stars are aligned — ${taraNames[tara]} Tara (favorable)'
          : '${taraNames[tara]} Tara — challenging star alignment',
    );
  }

  /// 4. Yoni (4 points) — Intimacy & temperament
  static GunaScore _calcYoni(int nak1, int nak2) {
    final y1 = _nakshatraYoni[nak1];
    final y2 = _nakshatraYoni[nak2];
    double earned;
    if (y1 == y2) {
      earned = 4;
    } else if (_yoniEnemy(y1, y2)) {
      earned = 0;
    } else {
      earned = 2;
    }
    return GunaScore(
      name: 'Yoni',
      description: 'Intimacy & natural temperament',
      earned: earned,
      maximum: 4,
      interpretation: earned >= 4
          ? 'Excellent natural rapport and understanding'
          : earned >= 2
              ? 'Decent compatibility, some adjustments needed'
              : 'Contrasting natures — patience is key',
    );
  }

  static bool _yoniEnemy(int y1, int y2) {
    // Enemy pairs: (Horse,Buffalo), (Elephant,Lion), (Sheep,Monkey),
    // (Snake,Mongoose), (Dog,Deer), (Cat,Rat), (Tiger,Cow)
    const enemies = {
      0: 9, 9: 0, // Horse-Buffalo→ actually {0:9}
      1: 13, 13: 1, // Elephant-Lion
      2: 12, 12: 2, // Sheep-Monkey
      3: -1, // Snake (no direct enemy in simplified model)
      4: 11, 11: 4, // Dog-Deer
      5: 7, 7: 5, // Cat-Rat
      10: 8, 8: 10, // Tiger-Cow
    };
    return enemies[y1] == y2;
  }

  /// 5. Graha Maitri (5 points) — Mental compatibility (sign lord friendship)
  static GunaScore _calcGrahaMaitri(int sign1, int sign2) {
    final lord1 = _signLords[sign1];
    final lord2 = _signLords[sign2];

    double earned;
    if (lord1 == lord2) {
      earned = 5;
    } else {
      final areFriends1 = _friendships[lord1]?.contains(lord2) ?? false;
      final areFriends2 = _friendships[lord2]?.contains(lord1) ?? false;
      final areEnemies1 = _enemies[lord1]?.contains(lord2) ?? false;
      final areEnemies2 = _enemies[lord2]?.contains(lord1) ?? false;

      if (areFriends1 && areFriends2) {
        earned = 5;
      } else if (areFriends1 || areFriends2) {
        earned = 4;
      } else if (areEnemies1 && areEnemies2) {
        earned = 0;
      } else if (areEnemies1 || areEnemies2) {
        earned = 1;
      } else {
        earned = 3; // Neutral
      }
    }

    return GunaScore(
      name: 'Graha Maitri',
      description: 'Mental & intellectual harmony',
      earned: earned,
      maximum: 5,
      interpretation: earned >= 4
          ? 'Excellent mental wavelength match'
          : earned >= 3
              ? 'Neutral mental compatibility'
              : 'Different thinking patterns — enriching diversity',
    );
  }

  /// 6. Gana (6 points) — Temperament & behavior
  static GunaScore _calcGana(int nak1, int nak2) {
    final g1 = _nakshatraGana[nak1];
    final g2 = _nakshatraGana[nak2];

    double earned;
    if (g1 == g2) {
      earned = 6;
    } else if ((g1 == 0 && g2 == 1) || (g1 == 1 && g2 == 0)) {
      earned = 5; // Deva-Manushya
    } else if ((g1 == 1 && g2 == 2) || (g1 == 2 && g2 == 1)) {
      earned = 1; // Manushya-Rakshasa
    } else {
      earned = 0; // Deva-Rakshasa
    }

    final ganaNames = [
      'Deva (divine)',
      'Manushya (human)',
      'Rakshasa (fierce)'
    ];
    return GunaScore(
      name: 'Gana',
      description: 'Temperament & nature',
      earned: earned,
      maximum: 6,
      interpretation: earned >= 5
          ? 'Harmonious temperaments (${ganaNames[g1]} & ${ganaNames[g2]})'
          : earned >= 1
              ? 'Mixed temperaments — balance is possible'
              : 'Contrasting natures — requires understanding',
    );
  }

  /// 7. Bhakut (7 points) — Emotional & family harmony
  static GunaScore _calcBhakut(int sign1, int sign2) {
    final dist = ((sign2 - sign1) % 12 + 12) % 12;
    // Inauspicious distances: 2-12, 5-9, 6-8
    final bad = {2, 10, 5, 7, 6, 8}; // distances that map to those axes
    // Actually the traditional rule: distance pairs 2/12, 5/9, 6/8 are bad
    final isBad = bad.contains(dist);

    return GunaScore(
      name: 'Bhakut',
      description: 'Emotional & family well-being',
      earned: isBad ? 0 : 7,
      maximum: 7,
      interpretation: isBad
          ? 'Challenging emotional axis (${_signs[sign1]} ↔ ${_signs[sign2]})'
          : 'Supportive emotional connection',
    );
  }

  /// 8. Nadi (8 points) — Health & genetic compatibility
  static GunaScore _calcNadi(int nak1, int nak2) {
    final n1 = _nakshatraNadi[nak1];
    final n2 = _nakshatraNadi[nak2];
    final earned = n1 != n2 ? 8.0 : 0.0;
    final nadiNames = ['Aadi (Vata)', 'Madhya (Pitta)', 'Antya (Kapha)'];

    return GunaScore(
      name: 'Nadi',
      description: 'Health & vitality match',
      earned: earned,
      maximum: 8,
      interpretation: earned > 0
          ? 'Different Nadis — excellent health compatibility'
          : 'Same Nadi (${nadiNames[n1]}) — Nadi Dosha present',
    );
  }

  // ════════════════════════════════════════════════════════════
  // HELPERS
  // ════════════════════════════════════════════════════════════

  static String _getGrade(double score) {
    if (score >= 30) return 'A+';
    if (score >= 25) return 'A';
    if (score >= 21) return 'B';
    if (score >= 18) return 'C';
    if (score >= 14) return 'D';
    return 'F';
  }

  static String _getVerdict(double score) {
    if (score >= 30) {
      return 'Exceptional cosmic alignment! This connection has powerful karmic resonance and deep natural harmony.';
    } else if (score >= 25) {
      return 'Excellent compatibility. The stars strongly favor this connection with natural understanding.';
    } else if (score >= 21) {
      return 'Good compatibility. A solid foundation with some areas that invite growth and adaptation.';
    } else if (score >= 18) {
      return 'Average compatibility. The relationship can thrive with mutual effort and conscious understanding.';
    } else if (score >= 14) {
      return 'Challenging alignment. Significant differences exist, but they can create powerful growth if embraced.';
    } else {
      return 'Difficult cosmic alignment. This pairing requires exceptional patience and deep commitment to overcome natural friction.';
    }
  }

  static List<PlanetComparison> _buildPlanetComparisons(
      KundaliResult c1, KundaliResult c2) {
    const planets = [
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
    return planets.map((p) {
      final p1 = c1.planets[p];
      final p2 = c2.planets[p];
      final s1 = (p1?['signName'] as String?) ?? '—';
      final s2 = (p2?['signName'] as String?) ?? '—';
      final h1 = (p1?['house'] as int?) ?? 0;
      final h2 = (p2?['house'] as int?) ?? 0;
      return PlanetComparison(
        planet: p,
        person1Sign: s1,
        person2Sign: s2,
        person1House: h1,
        person2House: h2,
        sameSign: s1 == s2 && s1 != '—',
      );
    }).toList();
  }

  static ElementBalance _getElementBalance(KundaliResult chart) {
    int fire = 0, earth = 0, air = 0, water = 0;
    for (final entry in chart.planets.entries) {
      final signIdx = entry.value['signIndex'] as int? ?? 0;
      switch (_signElements[signIdx]) {
        case 0:
          fire++;
          break;
        case 1:
          earth++;
          break;
        case 2:
          air++;
          break;
        case 3:
          water++;
          break;
      }
    }
    return ElementBalance(fire: fire, earth: earth, air: air, water: water);
  }
}
