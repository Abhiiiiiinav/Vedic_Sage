/// Data models for Vedic Special Combinations (Yogas)

/// Enum representing the 10 major yoga types
enum YogaType {
  /// Auspicious yoga - Nectar of Success
  amritSiddhi,
  
  /// Auspicious yoga - Accomplished/Perfect
  siddha,
  
  /// Auspicious yoga - Great Accomplishment
  mahasiddhi,
  
  /// Auspicious yoga - Success in All Endeavors
  sarvarthaSiddhi,
  
  /// Auspicious yoga - Jupiter-Pushya combination (Thursday + Pushya nakshatra)
  guruPushya,
  
  /// Auspicious yoga - Sun-Pushya combination (Sunday + Pushya nakshatra)
  raviPushya,
  
  /// Inauspicious yoga - Burnt/Scorched
  dagdha,
  
  /// Inauspicious yoga - Fire God
  hutashana,
  
  /// Inauspicious yoga - Poison
  visha,
  
  /// Inauspicious yoga - Vishti Karana (Bhadra)
  vishtiKarana,
}

/// Enum representing purposes/activities for which yogas are suitable
enum YogaPurpose {
  /// Marriage ceremonies and related activities
  marriage,
  
  /// Business ventures, investments, and financial activities
  business,
  
  /// Education, learning, and academic pursuits
  education,
  
  /// Travel and journeys
  travel,
  
  /// Spiritual practices, meditation, and religious activities
  spiritual,
  
  /// Health-related activities and treatments
  health,
}

/// Class representing a detected yoga result
class YogaResult {
  /// Type of yoga detected
  final YogaType type;
  
  /// Definition/properties of the yoga
  final YogaDefinition definition;
  
  /// Date and time when the yoga is active
  final DateTime activeDate;
  
  /// Tithi (lunar day) during the yoga
  final String tithi;
  
  /// Nakshatra (lunar constellation) during the yoga
  final String nakshatra;
  
  /// Vara (weekday) during the yoga
  final String vara;
  
  YogaResult({
    required this.type,
    required this.definition,
    required this.activeDate,
    required this.tithi,
    required this.nakshatra,
    required this.vara,
  });
  
  /// Whether this yoga is auspicious
  bool get isAuspicious => definition.isAuspicious;
  
  /// Get applicable purposes for this yoga
  List<YogaPurpose> get purposes => definition.purposes;
}

/// Class representing the definition and properties of a yoga
class YogaDefinition {
  /// Type of yoga
  final YogaType type;
  
  /// Display name of the yoga
  final String name;
  
  /// Detailed description of the yoga
  final String description;
  
  /// Whether this yoga is auspicious (true) or inauspicious (false)
  final bool isAuspicious;
  
  /// List of purposes/activities this yoga is suitable for
  final List<YogaPurpose> purposes;
  
  const YogaDefinition({
    required this.type,
    required this.name,
    required this.description,
    required this.isAuspicious,
    required this.purposes,
  });
}

/// Static definitions for all 10 yoga types
class YogaDefinitions {
  static const amritSiddhi = YogaDefinition(
    type: YogaType.amritSiddhi,
    name: 'Amrit Siddhi Yoga',
    description: 'A highly auspicious combination known as the "Nectar of Success". '
        'This yoga brings success, prosperity, and fulfillment in all endeavors. '
        'It is considered one of the most powerful auspicious yogas.',
    isAuspicious: true,
    purposes: [
      YogaPurpose.marriage,
      YogaPurpose.business,
      YogaPurpose.education,
      YogaPurpose.travel,
      YogaPurpose.spiritual,
      YogaPurpose.health,
    ],
  );
  
  static const siddha = YogaDefinition(
    type: YogaType.siddha,
    name: 'Siddha Yoga',
    description: 'An auspicious yoga that brings accomplishment and perfection. '
        'Activities started during this yoga are likely to be completed successfully. '
        'Favorable for important undertakings and new beginnings.',
    isAuspicious: true,
    purposes: [
      YogaPurpose.marriage,
      YogaPurpose.business,
      YogaPurpose.education,
      YogaPurpose.spiritual,
    ],
  );
  
  static const mahasiddhi = YogaDefinition(
    type: YogaType.mahasiddhi,
    name: 'Mahasiddhi Yoga',
    description: 'A great accomplishment yoga that brings extraordinary success. '
        'This rare combination is highly favorable for major life events and important decisions. '
        'Considered even more powerful than regular Siddha yoga.',
    isAuspicious: true,
    purposes: [
      YogaPurpose.marriage,
      YogaPurpose.business,
      YogaPurpose.education,
      YogaPurpose.travel,
      YogaPurpose.spiritual,
    ],
  );
  
  static const sarvarthaSiddhi = YogaDefinition(
    type: YogaType.sarvarthaSiddhi,
    name: 'Sarvartha Siddhi Yoga',
    description: 'The "Success in All Endeavors" yoga. This powerful combination ensures '
        'success in all types of activities. Highly auspicious for any important work, '
        'ceremonies, or new ventures.',
    isAuspicious: true,
    purposes: [
      YogaPurpose.marriage,
      YogaPurpose.business,
      YogaPurpose.education,
      YogaPurpose.travel,
      YogaPurpose.spiritual,
      YogaPurpose.health,
    ],
  );
  
  static const guruPushya = YogaDefinition(
    type: YogaType.guruPushya,
    name: 'Guru Pushya Yoga',
    description: 'A special combination of Thursday (Guru/Jupiter day) with Pushya nakshatra. '
        'This is one of the most auspicious yogas for starting new ventures, making investments, '
        'and performing religious ceremonies. Occurs approximately once a month.',
    isAuspicious: true,
    purposes: [
      YogaPurpose.business,
      YogaPurpose.education,
      YogaPurpose.spiritual,
    ],
  );
  
  static const raviPushya = YogaDefinition(
    type: YogaType.raviPushya,
    name: 'Ravi Pushya Yoga',
    description: 'A special combination of Sunday (Ravi/Sun day) with Pushya nakshatra. '
        'This auspicious yoga is favorable for government-related work, leadership activities, '
        'and spiritual practices. Occurs approximately once a month.',
    isAuspicious: true,
    purposes: [
      YogaPurpose.business,
      YogaPurpose.spiritual,
      YogaPurpose.health,
    ],
  );
  
  static const dagdha = YogaDefinition(
    type: YogaType.dagdha,
    name: 'Dagdha Yoga',
    description: 'An inauspicious combination meaning "burnt" or "scorched". '
        'This yoga is formed by specific Tithi-Vara combinations and is considered unfavorable '
        'for important activities, ceremonies, and new beginnings. Best to avoid major decisions.',
    isAuspicious: false,
    purposes: [],
  );
  
  static const hutashana = YogaDefinition(
    type: YogaType.hutashana,
    name: 'Hutashana Yoga',
    description: 'An inauspicious yoga named after the Fire God. This combination can bring '
        'obstacles, delays, and unfavorable outcomes. Not recommended for starting new ventures '
        'or performing important ceremonies.',
    isAuspicious: false,
    purposes: [],
  );
  
  static const visha = YogaDefinition(
    type: YogaType.visha,
    name: 'Visha Yoga',
    description: 'An inauspicious yoga meaning "poison". This combination is considered highly '
        'unfavorable and can bring negative results. Activities started during this yoga may '
        'face significant obstacles and challenges.',
    isAuspicious: false,
    purposes: [],
  );
  
  static const vishtiKarana = YogaDefinition(
    type: YogaType.vishtiKarana,
    name: 'Vishti Karana (Bhadra)',
    description: 'An inauspicious karana also known as Bhadra. This period is considered '
        'unfavorable for auspicious activities and ceremonies. Occurs twice in each lunar month. '
        'Best avoided for important undertakings.',
    isAuspicious: false,
    purposes: [],
  );
  
  /// Get definition for a specific yoga type
  static YogaDefinition getDefinition(YogaType type) {
    switch (type) {
      case YogaType.amritSiddhi:
        return amritSiddhi;
      case YogaType.siddha:
        return siddha;
      case YogaType.mahasiddhi:
        return mahasiddhi;
      case YogaType.sarvarthaSiddhi:
        return sarvarthaSiddhi;
      case YogaType.guruPushya:
        return guruPushya;
      case YogaType.raviPushya:
        return raviPushya;
      case YogaType.dagdha:
        return dagdha;
      case YogaType.hutashana:
        return hutashana;
      case YogaType.visha:
        return visha;
      case YogaType.vishtiKarana:
        return vishtiKarana;
    }
  }
  
  /// Get all auspicious yoga definitions
  static List<YogaDefinition> get auspiciousYogas => [
    amritSiddhi,
    siddha,
    mahasiddhi,
    sarvarthaSiddhi,
    guruPushya,
    raviPushya,
  ];
  
  /// Get all inauspicious yoga definitions
  static List<YogaDefinition> get inauspiciousYogas => [
    dagdha,
    hutashana,
    visha,
    vishtiKarana,
  ];
  
  /// Get all yoga definitions
  static List<YogaDefinition> get allYogas => [
    ...auspiciousYogas,
    ...inauspiciousYogas,
  ];
}
