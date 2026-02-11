/// Comprehensive Darakaraka Education & Interpretation Data
/// 
/// Contains detailed psychology, relationship patterns, and growth guidance
/// for each planet as Darakaraka (DK) - the relationship karma indicator.
/// 
/// Core Principle: DK describes relationship KARMA - the lessons, attractions,
/// and growth patterns activated through intimate partnerships.

class DarakarakaData {
  final String planet;
  final String planetName;
  final String archetype;
  final PartnerPsychology partnerPsychology;
  final RelationshipThemes relationshipThemes;
  final ShadowExpression shadowExpression;
  final RealLifePatterns realLifePatterns;
  final GrowthPath growthPath;
  final Map<String, String> signModifications;
  final Map<String, String> houseModifications;
  final String masterInsight;

  const DarakarakaData({
    required this.planet,
    required this.planetName,
    required this.archetype,
    required this.partnerPsychology,
    required this.relationshipThemes,
    required this.shadowExpression,
    required this.realLifePatterns,
    required this.growthPath,
    required this.signModifications,
    required this.houseModifications,
    required this.masterInsight,
  });
}

class PartnerPsychology {
  final String emotionalNeeds;
  final String communicationStyle;
  final String conflictStyle;
  final String attachmentPattern;
  final List<String> coreTraits;

  const PartnerPsychology({
    required this.emotionalNeeds,
    required this.communicationStyle,
    required this.conflictStyle,
    required this.attachmentPattern,
    required this.coreTraits,
  });
}

class RelationshipThemes {
  final String supportPattern;
  final String powerBalance;
  final String stabilityLevel;
  final List<String> keyDynamics;

  const RelationshipThemes({
    required this.supportPattern,
    required this.powerBalance,
    required this.stabilityLevel,
    required this.keyDynamics,
  });
}

class ShadowExpression {
  final String whenStressed;
  final List<String> breakdownCauses;
  final List<String> warningSignals;

  const ShadowExpression({
    required this.whenStressed,
    required this.breakdownCauses,
    required this.warningSignals,
  });
}

class RealLifePatterns {
  final String datingPattern;
  final String marriagePattern;
  final String longTermPattern;
  final List<String> observableSignals;

  const RealLifePatterns({
    required this.datingPattern,
    required this.marriagePattern,
    required this.longTermPattern,
    required this.observableSignals,
  });
}

class GrowthPath {
  final String coreLesson;
  final List<String> skillsNeeded;
  final List<String> practicalActions;
  final String ultimateGift;

  const GrowthPath({
    required this.coreLesson,
    required this.skillsNeeded,
    required this.practicalActions,
    required this.ultimateGift,
  });
}

class DarakarakaEducation {
  static const Map<String, DarakarakaData> data = {
    'Su': _sunDK,
    'Mo': _moonDK,
    'Ma': _marsDK,
    'Me': _mercuryDK,
    'Ju': _jupiterDK,
    'Ve': _venusDK,
    'Sa': _saturnDK,
  };

  // ============ SUN AS DARAKARAKA ============
  static const _sunDK = DarakarakaData(
    planet: 'Su',
    planetName: 'Sun',
    archetype: 'The Dignified Leader',
    partnerPsychology: PartnerPsychology(
      emotionalNeeds: 'Recognition, respect, and acknowledgment of authority. Partner needs to feel like a king/queen in the relationship.',
      communicationStyle: 'Direct, authoritative, sometimes commanding. Expresses through declarations rather than discussions.',
      conflictStyle: 'Takes offense to disrespect. May become ego-wounded and withdraw into silent dignity or assert dominance.',
      attachmentPattern: 'Secure when respected; anxious when feeling undervalued. Needs consistent recognition.',
      coreTraits: [
        'Strong sense of self',
        'Natural leadership tendency',
        'Pride in achievements',
        'Protective of family honor',
        'Value integrity highly',
      ],
    ),
    relationshipThemes: RelationshipThemes(
      supportPattern: 'Partner provides direction and structure. Support comes through clear leadership.',
      powerBalance: 'One partner often takes the lead role. Balance requires conscious role acknowledgment.',
      stabilityLevel: 'Stable when respect is mutual; volatile if ego is wounded.',
      keyDynamics: [
        'Authority distribution matters',
        'Public image as a couple is important',
        'Career achievements affect relationship',
        'Father figures influence relationship patterns',
      ],
    ),
    shadowExpression: ShadowExpression(
      whenStressed: 'Becomes domineering, arrogant, or dismissive. May demand loyalty tests or create hierarchies.',
      breakdownCauses: [
        'Ego clashes and power struggles',
        'Public humiliation or disrespect',
        'Career failures impacting self-worth',
        'Feeling outshone by partner',
      ],
      warningSignals: [
        'Excessive pride in early dating',
        'Inability to apologize',
        'Comparing partner unfavorably',
        'Needing to always "win" discussions',
      ],
    ),
    realLifePatterns: RealLifePatterns(
      datingPattern: 'Attracted to confident, accomplished individuals. May pursue those who enhance status.',
      marriagePattern: 'Formal, traditional marriages often. Partner may have authority-related career.',
      longTermPattern: 'Relationship becomes the "royal court" - clear roles and mutual respect.',
      observableSignals: [
        'Partner has leadership qualities or position',
        'Relationship has formal quality',
        'Public presentation matters to both',
        'Father themes repeat in relationship',
      ],
    ),
    growthPath: GrowthPath(
      coreLesson: 'Learning that true authority comes from service, not dominance.',
      skillsNeeded: [
        'Humility without losing self-respect',
        'Sharing spotlight gracefully',
        'Validating partner\'s contributions',
        'Apologizing when wrong',
      ],
      practicalActions: [
        'Practice acknowledging partner publicly',
        'Let partner lead in their strength areas',
        'Separate self-worth from achievements',
        'Develop gratitude practices',
      ],
      ultimateGift: 'A relationship of mutual dignity where both partners shine.',
    ),
    signModifications: {
      'Aries': 'Warrior-leader partner; very direct and action-oriented',
      'Taurus': 'Stable, wealth-conscious partner; values material security',
      'Gemini': 'Intellectually proud partner; communicates authority through knowledge',
      'Cancer': 'Emotionally authoritative partner; leads through nurturing',
      'Leo': 'Doubly dignified; very strong personality; needs high recognition',
      'Virgo': 'Perfectionist leader; authority through competence',
      'Libra': 'Diplomatic authority; leads through charm and balance',
      'Scorpio': 'Intense, powerful partner; hidden authority',
      'Sagittarius': 'Philosophical leader; authority through wisdom',
      'Capricorn': 'Professional authority; career-focused partner',
      'Aquarius': 'Unconventional leader; authority through innovation',
      'Pisces': 'Spiritual authority; leads through compassion',
    },
    houseModifications: {
      '1': 'Partner strongly influences your identity and self-expression',
      '2': 'Partner affects wealth, values, and family dynamics',
      '3': 'Partner impacts communication, courage, and sibling relations',
      '4': 'Partner influences home, peace, and emotional security',
      '5': 'Partner activates creativity, romance, and children themes',
      '6': 'Partner connected to service, health, or overcoming obstacles',
      '7': 'Strong marriage focus; partner is central to life direction',
      '8': 'Partner triggers transformation; deep psychological impact',
      '9': 'Partner affects beliefs, higher learning, and life philosophy',
      '10': 'Partner influences career and public status significantly',
      '11': 'Partner connected to gains, networks, and life goals',
      '12': 'Partner activates spiritual themes; some hidden dynamics',
    },
    masterInsight: 'Sun DK teaches that relationships work when both partners can be kings/queens in their own domains. The lesson is shared sovereignty, not competition for the throne.',
  );

  // ============ MOON AS DARAKARAKA ============
  static const _moonDK = DarakarakaData(
    planet: 'Mo',
    planetName: 'Moon',
    archetype: 'The Emotional Nurturer',
    partnerPsychology: PartnerPsychology(
      emotionalNeeds: 'Emotional safety, nurturing, and consistent presence. Partner needs to feel emotionally held and understood.',
      communicationStyle: 'Indirect, mood-dependent, intuitive. Communicates through feelings rather than words.',
      conflictStyle: 'Withdraws emotionally when hurt. May sulk, become passive-aggressive, or need space to process.',
      attachmentPattern: 'Anxious-leaning; needs reassurance. Very sensitive to emotional availability.',
      coreTraits: [
        'Deep emotional sensitivity',
        'Nurturing instincts',
        'Strong memory for feelings',
        'Connection to mother/family',
        'Intuitive understanding',
      ],
    ),
    relationshipThemes: RelationshipThemes(
      supportPattern: 'Support through emotional presence and care. Quality time is essential.',
      powerBalance: 'Emotional intelligence holds power. The more sensitive partner sets the emotional tone.',
      stabilityLevel: 'Can be fluctuating like moon phases. Needs emotional consistency to stabilize.',
      keyDynamics: [
        'Emotional attunement is crucial',
        'Home and family are central',
        'Mother figures influence patterns',
        'Food, comfort, and nurturing matter',
      ],
    ),
    shadowExpression: ShadowExpression(
      whenStressed: 'Becomes moody, clingy, or emotionally manipulative. May use guilt or emotional withdrawal as control.',
      breakdownCauses: [
        'Emotional neglect or unavailability',
        'Feeling misunderstood persistently',
        'Insecurity about partner\'s feelings',
        'Disruption of home/family stability',
      ],
      warningSignals: [
        'Excessive moodiness early on',
        'Over-dependence on partner for emotional regulation',
        'Guilt-tripping behaviors',
        'Inability to self-soothe',
      ],
    ),
    realLifePatterns: RealLifePatterns(
      datingPattern: 'Attracted to emotionally available, nurturing types. May seek "mother/father" figures.',
      marriagePattern: 'Home-centered marriages. Partner likely involved in caregiving or domestic life.',
      longTermPattern: 'Relationship becomes emotional sanctuary. Deep bonding but needs variety to prevent stagnation.',
      observableSignals: [
        'Partner is emotionally expressive',
        'Home life is prioritized',
        'Family gatherings are important',
        'Emotional check-ins are frequent',
      ],
    ),
    growthPath: GrowthPath(
      coreLesson: 'Learning emotional self-sufficiency while remaining open to intimacy.',
      skillsNeeded: [
        'Self-soothing techniques',
        'Clear emotional communication',
        'Recognizing projection',
        'Balancing giving and receiving',
      ],
      practicalActions: [
        'Develop personal emotional regulation practices',
        'Express needs verbally rather than expecting mind-reading',
        'Create personal emotional outlets',
        'Practice gratitude for emotional safety',
      ],
      ultimateGift: 'A deeply nurturing relationship that feels like coming home.',
    ),
    signModifications: {
      'Aries': 'Emotionally direct partner; quick to feel, quick to move on',
      'Taurus': 'Deeply stable emotional partner; comforting presence',
      'Gemini': 'Emotionally curious partner; talks through feelings',
      'Cancer': 'Highly nurturing partner; very mothering energy',
      'Leo': 'Dramatically emotional partner; needs emotional spotlight',
      'Virgo': 'Analytically emotional; shows care through service',
      'Libra': 'Harmonizing emotional style; avoids emotional conflict',
      'Scorpio': 'Deeply intense emotions; transformative emotional impact',
      'Sagittarius': 'Emotionally optimistic; needs freedom in feelings',
      'Capricorn': 'Emotionally reserved; shows care through responsibility',
      'Aquarius': 'Emotionally detached style; unconventional care',
      'Pisces': 'Boundlessly emotional; highly empathic partner',
    },
    houseModifications: {
      '1': 'Partner profoundly affects your emotional identity',
      '2': 'Partner nurtures through providing resources and security',
      '3': 'Emotional communication is central to relationship',
      '4': 'Deep home and family orientation; mother themes strong',
      '5': 'Romantic, playful emotional connection; children important',
      '6': 'Partner may need emotional healing; service through care',
      '7': 'Marriage is emotional core; partnership deeply nurturing',
      '8': 'Intense emotional transformation through relationship',
      '9': 'Emotional growth through higher beliefs and travel together',
      '10': 'Public image as nurturing couple; emotional career impact',
      '11': 'Emotional fulfillment through shared goals and community',
      '12': 'Deep spiritual-emotional connection; some hidden feelings',
    },
    masterInsight: 'Moon DK teaches that emotional intelligence is the currency of relationship. The lesson is to nurture without drowning, and receive without demanding.',
  );

  // ============ MARS AS DARAKARAKA ============
  static const _marsDK = DarakarakaData(
    planet: 'Ma',
    planetName: 'Mars',
    archetype: 'The Passionate Warrior',
    partnerPsychology: PartnerPsychology(
      emotionalNeeds: 'Action, passion, and direct engagement. Partner needs to feel alive through challenge and conquest.',
      communicationStyle: 'Direct, sometimes blunt. Prefers action to words. May communicate through doing.',
      conflictStyle: 'Confrontational and direct. Fights openly, then moves on quickly. Doesn\'t hold grudges long.',
      attachmentPattern: 'Independent-leaning but passionate. Needs space but also intense connection.',
      coreTraits: [
        'Strong drive and ambition',
        'Physical energy and vitality',
        'Competitive spirit',
        'Protective instincts',
        'Direct and honest approach',
      ],
    ),
    relationshipThemes: RelationshipThemes(
      supportPattern: 'Support through action and protection. Partner shows love by doing.',
      powerBalance: 'Can be competitive. Both partners need outlets for individual assertion.',
      stabilityLevel: 'Intense but can burn hot and cold. Needs healthy conflict expression.',
      keyDynamics: [
        'Physical attraction is important',
        'Shared activities and adventures',
        'Healthy competition dynamics',
        'Brother/sibling themes may appear',
      ],
    ),
    shadowExpression: ShadowExpression(
      whenStressed: 'Becomes aggressive, controlling, or physically intimidating. May create conflicts to feel alive.',
      breakdownCauses: [
        'Feeling controlled or restricted',
        'Loss of physical/sexual connection',
        'Passive-aggressive partner behavior',
        'Lack of challenge or excitement',
      ],
      warningSignals: [
        'Excessive anger or aggression',
        'Physical intimidation',
        'Starting fights for stimulation',
        'Controlling behaviors',
      ],
    ),
    realLifePatterns: RealLifePatterns(
      datingPattern: 'Attracted to strong, active, or challenging individuals. Pursues directly.',
      marriagePattern: 'Active, sometimes intense marriages. Shared physical activities common.',
      longTermPattern: 'Needs ongoing spark. Relationship works through shared goals and adventures.',
      observableSignals: [
        'Partner is physically active or assertive',
        'Relationship has competitive element',
        'Physical expression of love is central',
        'Arguments are direct but brief',
      ],
    ),
    growthPath: GrowthPath(
      coreLesson: 'Learning that strength includes patience, and passion includes tenderness.',
      skillsNeeded: [
        'Anger management',
        'Patience during disagreements',
        'Expressing vulnerability',
        'Channeling competitive energy positively',
      ],
      practicalActions: [
        'Develop physical outlets for excess energy',
        'Practice pausing before reacting',
        'Engage in shared physical activities',
        'Express appreciation for partner\'s strength',
      ],
      ultimateGift: 'A relationship of passionate aliveness where both partners feel empowered.',
    ),
    signModifications: {
      'Aries': 'Very direct, pioneering partner; pure warrior energy',
      'Taurus': 'Stubborn but stable partner; slow to anger, slow to forgive',
      'Gemini': 'Mentally active partner; argues with wit',
      'Cancer': 'Protective partner; fights for family',
      'Leo': 'Proud warrior partner; dramatic in conflict',
      'Virgo': 'Precise partner; critical when stressed',
      'Libra': 'Balanced aggression; fights for fairness',
      'Scorpio': 'Intensely passionate; never forgets betrayal',
      'Sagittarius': 'Adventurous warrior; philosophical about conflict',
      'Capricorn': 'Disciplined assertiveness; ambitious partner',
      'Aquarius': 'Rebellious energy; fights for ideals',
      'Pisces': 'Passive-aggressive potential; spiritual warrior',
    },
    houseModifications: {
      '1': 'Partner strongly affects your energy and assertiveness',
      '2': 'Action around finances and values; possibly conflicts over money',
      '3': 'Active communication; courage themes in relationship',
      '4': 'Home can be battlefield or haven; needs peace at home',
      '5': 'Passionate romance; active with children',
      '6': 'Partner may be in service/health; conflict management important',
      '7': 'Very active marriage; strong partnership dynamics',
      '8': 'Intense transformation; possible power struggles',
      '9': 'Adventurous relationship; active about beliefs',
      '10': 'Ambitious couple; career conflicts possible',
      '11': 'Active in community; competitive about goals',
      '12': 'Hidden conflicts; spiritual warrior themes',
    },
    masterInsight: 'Mars DK teaches that relationships require both the courage to fight for what matters and the wisdom to know when to surrender. The lesson is passionate engagement without destruction.',
  );

  // ============ MERCURY AS DARAKARAKA ============
  static const _mercuryDK = DarakarakaData(
    planet: 'Me',
    planetName: 'Mercury',
    archetype: 'The Communicative Intellectual',
    partnerPsychology: PartnerPsychology(
      emotionalNeeds: 'Mental stimulation, variety, and clear communication. Partner needs to feel heard and intellectually engaged.',
      communicationStyle: 'Verbal, analytical, curious. Talks through everything. May over-analyze feelings.',
      conflictStyle: 'Debates and discusses. Uses logic in arguments. May become detached or overly intellectual.',
      attachmentPattern: 'Flexible and adaptable. Can seem detached but values mental connection.',
      coreTraits: [
        'Quick thinking and wit',
        'Communication skills',
        'Curiosity about everything',
        'Adaptability',
        'Youthful energy',
      ],
    ),
    relationshipThemes: RelationshipThemes(
      supportPattern: 'Support through communication and problem-solving. Talks through challenges.',
      powerBalance: 'Information is power. The more articulate partner may dominate.',
      stabilityLevel: 'Can be changeable. Needs mental engagement to stay interested.',
      keyDynamics: [
        'Conversation quality matters enormously',
        'Learning together is bonding',
        'Business or intellectual partnerships',
        'Sibling-like playfulness',
      ],
    ),
    shadowExpression: ShadowExpression(
      whenStressed: 'Becomes overly critical, anxious, or uses words as weapons. May gaslight or argue endlessly.',
      breakdownCauses: [
        'Communication breakdown',
        'Feeling intellectually bored',
        'Partner dismissing ideas',
        'Lack of mental stimulation',
      ],
      warningSignals: [
        'Excessive criticism or nitpicking',
        'Gaslighting through wordplay',
        'Inability to commit',
        'Treating feelings as problems to solve',
      ],
    ),
    realLifePatterns: RealLifePatterns(
      datingPattern: 'Attracted to intelligent, communicative types. Meets partners through learning or work.',
      marriagePattern: 'Marriage of minds. Often share business or creative projects.',
      longTermPattern: 'Needs ongoing learning together. Relationship stays fresh through new experiences.',
      observableSignals: [
        'Partner is articulate or intellectual',
        'Lots of talking in relationship',
        'Shared learning activities',
        'Playful, sibling-like dynamic',
      ],
    ),
    growthPath: GrowthPath(
      coreLesson: 'Learning that not everything can be solved through thinking, and feelings have their own logic.',
      skillsNeeded: [
        'Emotional presence without analyzing',
        'Listening without planning response',
        'Commitment despite uncertainty',
        'Body-based connection',
      ],
      practicalActions: [
        'Practice active listening',
        'Develop non-verbal connection rituals',
        'Commit to decisions and stick with them',
        'Validate feelings before solving problems',
      ],
      ultimateGift: 'A relationship of endless discovery where minds dance together.',
    ),
    signModifications: {
      'Aries': 'Quick-thinking partner; fast-talking',
      'Taurus': 'Slow, deliberate communication style',
      'Gemini': 'Highly verbal partner; very communicative',
      'Cancer': 'Emotionally intelligent communication',
      'Leo': 'Dramatic storyteller partner',
      'Virgo': 'Precise, analytical communicator',
      'Libra': 'Diplomatic, balanced discussions',
      'Scorpio': 'Probing, investigative mind',
      'Sagittarius': 'Philosophical communicator; big ideas',
      'Capricorn': 'Practical, business-minded talk',
      'Aquarius': 'Innovative, unconventional ideas',
      'Pisces': 'Intuitive, poetic communication',
    },
    houseModifications: {
      '1': 'Partner affects how you think and communicate',
      '2': 'Communication around money and values',
      '3': 'Very strong communication emphasis; sibling themes',
      '4': 'Home becomes place of learning',
      '5': 'Creative mental connection; playful communication',
      '6': 'Partner may be in communication/service field',
      '7': 'Marriage based on mental compatibility',
      '8': 'Deep investigative discussions',
      '9': 'Learning and travel together; philosophical talks',
      '10': 'Business partner potential; career discussions',
      '11': 'Social networking together; shared intellectual goals',
      '12': 'Private communications; spiritual discussions',
    },
    masterInsight: 'Mercury DK teaches that words can heal or hurt, and the greatest communication is presence. The lesson is dialogue as devotion, not just information exchange.',
  );

  // ============ JUPITER AS DARAKARAKA ============
  static const _jupiterDK = DarakarakaData(
    planet: 'Ju',
    planetName: 'Jupiter',
    archetype: 'The Wise Guide',
    partnerPsychology: PartnerPsychology(
      emotionalNeeds: 'Meaning, growth, and expansion. Partner needs to feel the relationship has higher purpose.',
      communicationStyle: 'Teaching, sharing wisdom, uplifting. Speaks in principles and philosophies.',
      conflictStyle: 'Avoids pettiness. Seeks to understand bigger picture. May become preachy or righteous.',
      attachmentPattern: 'Secure but needs freedom. Values quality over intensity.',
      coreTraits: [
        'Wisdom and perspective',
        'Generosity and optimism',
        'Spiritual inclination',
        'Teaching ability',
        'Ethical foundation',
      ],
    ),
    relationshipThemes: RelationshipThemes(
      supportPattern: 'Support through guidance, optimism, and provision. Creates abundance together.',
      powerBalance: 'Wisdom holds authority. The one with more perspective may naturally lead.',
      stabilityLevel: 'Generally stable due to ethical foundation. Can struggle if beliefs diverge.',
      keyDynamics: [
        'Shared beliefs are essential',
        'Growth and expansion together',
        'Guru/teacher dynamics may appear',
        'Generosity in relationship',
      ],
    ),
    shadowExpression: ShadowExpression(
      whenStressed: 'Becomes preachy, self-righteous, or overindulgent. May use moral superiority as weapon.',
      breakdownCauses: [
        'Fundamental value differences',
        'Feeling like relationship limits growth',
        'Partner\'s ethical failures',
        'Stagnation or lack of meaning',
      ],
      warningSignals: [
        'Excessive moralizing',
        'Treating partner as student always',
        'Ignoring practical matters',
        'Over-promising, under-delivering',
      ],
    ),
    realLifePatterns: RealLifePatterns(
      datingPattern: 'Attracted to wise, generous, or spiritual individuals. May meet through education or religion.',
      marriagePattern: 'Traditional, often religious or ceremonial marriages. Partner may be teacher/advisor.',
      longTermPattern: 'Relationship becomes vehicle for mutual growth. Expands both partners.',
      observableSignals: [
        'Partner has wise, generous quality',
        'Relationship has spiritual or philosophical foundation',
        'Both partners grow significantly',
        'Abundance themes present',
      ],
    ),
    growthPath: GrowthPath(
      coreLesson: 'Learning that wisdom includes humility, and teaching includes learning.',
      skillsNeeded: [
        'Humility in knowing',
        'Practical grounding',
        'Receiving as well as giving',
        'Accepting partner\'s different path',
      ],
      practicalActions: [
        'Practice being student to partner',
        'Ground beliefs in daily practice',
        'Balance expansion with stability',
        'Celebrate partner\'s growth independently',
      ],
      ultimateGift: 'A relationship that expands both souls toward their highest potential.',
    ),
    signModifications: {
      'Aries': 'Pioneering wisdom partner; enthusiastic teacher',
      'Taurus': 'Practical wisdom; generous with resources',
      'Gemini': 'Intellectually wise; curious about everything',
      'Cancer': 'Nurturing wisdom; emotional teacher',
      'Leo': 'Dignified wisdom; generous leader',
      'Virgo': 'Precise wisdom; practical philosopher',
      'Libra': 'Balanced wisdom; diplomatic teacher',
      'Scorpio': 'Deep wisdom; transformative teacher',
      'Sagittarius': 'Pure guru energy; expansive wisdom',
      'Capricorn': 'Practical wisdom; wise about systems',
      'Aquarius': 'Unconventional wisdom; innovative teacher',
      'Pisces': 'Spiritual wisdom; compassionate guide',
    },
    houseModifications: {
      '1': 'Partner as primary teacher; identity expansion',
      '2': 'Wealth and wisdom through partnership',
      '3': 'Communication filled with wisdom',
      '4': 'Home becomes temple of learning',
      '5': 'Creative and wise partnership; blessed children',
      '6': 'Partner in service or healing field',
      '7': 'Blessed marriage; guru-like partner',
      '8': 'Wisdom through transformation',
      '9': 'Highly spiritual partnership; travel and learning',
      '10': 'Career wisdom through partner',
      '11': 'Abundant gains; wise social circle',
      '12': 'Spiritual liberation through relationship',
    },
    masterInsight: 'Jupiter DK teaches that the greatest wisdom is love in action. The lesson is to guide without controlling, and expand without losing ground.',
  );

  // ============ VENUS AS DARAKARAKA ============
  static const _venusDK = DarakarakaData(
    planet: 'Ve',
    planetName: 'Venus',
    archetype: 'The Harmonious Lover',
    partnerPsychology: PartnerPsychology(
      emotionalNeeds: 'Beauty, harmony, and pleasure. Partner needs to feel the relationship is beautiful and balanced.',
      communicationStyle: 'Charming, diplomatic, aesthetic. Expresses through beauty and grace.',
      conflictStyle: 'Avoids conflict strongly. May suppress to keep peace. Uses charm to deflect.',
      attachmentPattern: 'Secure when relationship is harmonious. Can be dependent on partner for self-worth.',
      coreTraits: [
        'Love of beauty and art',
        'Relationship orientation',
        'Diplomatic skills',
        'Sensuality and pleasure',
        'Value for harmony',
      ],
    ),
    relationshipThemes: RelationshipThemes(
      supportPattern: 'Support through creating beauty, harmony, and comfort. Love languages are active.',
      powerBalance: 'Charm holds power. The more attractive/charming partner may dominate socially.',
      stabilityLevel: 'Generally stable as harmony is prioritized. Can be superficial if depth is avoided.',
      keyDynamics: [
        'Romance and courtship matter',
        'Aesthetics of relationship important',
        'Social life as couple significant',
        'Gifts and expressions of love valued',
      ],
    ),
    shadowExpression: ShadowExpression(
      whenStressed: 'Becomes superficial, vain, or people-pleasing to dysfunction. May avoid necessary conflict.',
      breakdownCauses: [
        'Loss of attraction or romance',
        'Conflict that disrupts harmony',
        'Partner neglecting beauty/pleasure',
        'Social embarrassment',
      ],
      warningSignals: [
        'Excessive focus on appearance',
        'Avoiding all conflict',
        'Flirtatiousness beyond comfort',
        'Materialism over connection',
      ],
    ),
    realLifePatterns: RealLifePatterns(
      datingPattern: 'Attracted to beautiful, charming, artistic types. Dating is romantic and traditional.',
      marriagePattern: 'Beautiful weddings and homes. Social couple. Partner often artistic or in beauty/luxury field.',
      longTermPattern: 'Needs continued romance. Relationship thrives through beauty and art together.',
      observableSignals: [
        'Partner is attractive or artistic',
        'Relationship has romantic quality',
        'Beautiful home and lifestyle valued',
        'Social harmony important',
      ],
    ),
    growthPath: GrowthPath(
      coreLesson: 'Learning that true beauty includes depth, and harmony requires honest conflict.',
      skillsNeeded: [
        'Facing difficult truths',
        'Self-worth independent of beauty',
        'Constructive conflict skills',
        'Depth beyond surface',
      ],
      practicalActions: [
        'Practice having difficult conversations',
        'Develop inner beauty practices',
        'Balance social life with depth time',
        'Appreciate partner beyond appearance',
      ],
      ultimateGift: 'A relationship of genuine love where inner and outer beauty merge.',
    ),
    signModifications: {
      'Aries': 'Passionate beauty; direct in love',
      'Taurus': 'Deeply sensual partner; values luxury',
      'Gemini': 'Charming communicator; versatile lover',
      'Cancer': 'Nurturing beauty; emotionally romantic',
      'Leo': 'Dramatic romance; luxurious love',
      'Virgo': 'Refined beauty; precise in love',
      'Libra': 'Ultimate harmonizer; relationship focused',
      'Scorpio': 'Intense sensuality; deep love',
      'Sagittarius': 'Adventurous romance; philosophical beauty',
      'Capricorn': 'Sophisticated partner; classical beauty',
      'Aquarius': 'Unconventional beauty; unique romance',
      'Pisces': 'Romantic dreamer; spiritual beauty',
    },
    houseModifications: {
      '1': 'Partner beautifies your expression',
      '2': 'Wealth through beauty; valuable partnership',
      '3': 'Beautiful communication; artistic expression',
      '4': 'Beautiful home; harmonious domestic life',
      '5': 'Highly romantic; creative together',
      '6': 'Partner in beauty/wellness field',
      '7': 'Natural marriage indicator; harmonious union',
      '8': 'Deep sensual transformation',
      '9': 'Beauty in philosophy; romantic travel',
      '10': 'Public couple; beauty-related career together',
      '11': 'Beautiful social circle; artistic community',
      '12': 'Spiritual beauty; private romance',
    },
    masterInsight: 'Venus DK teaches that love is an art requiring both talent and practice. The lesson is to appreciate beauty while seeing beyond it.',
  );

  // ============ SATURN AS DARAKARAKA ============
  static const _saturnDK = DarakarakaData(
    planet: 'Sa',
    planetName: 'Saturn',
    archetype: 'The Committed Teacher',
    partnerPsychology: PartnerPsychology(
      emotionalNeeds: 'Security, commitment, and proven reliability. Partner needs to feel the relationship is solid and lasting.',
      communicationStyle: 'Slow, measured, serious. Expresses through actions and consistency.',
      conflictStyle: 'Avoids or delays. May become cold, withdrawn, or punitive. Long memory for hurts.',
      attachmentPattern: 'Anxious about reliability. Tests partner before trusting. Slow to open.',
      coreTraits: [
        'Strong sense of duty',
        'Patience and endurance',
        'Realism and practicality',
        'Commitment once made',
        'Respect for tradition',
      ],
    ),
    relationshipThemes: RelationshipThemes(
      supportPattern: 'Support through reliability, structure, and long-term building. Love is proven over time.',
      powerBalance: 'Age, experience, or responsibility may create hierarchy. Respect is earned gradually.',
      stabilityLevel: 'Very stable once established. Can become rigid or cold if not consciously warmed.',
      keyDynamics: [
        'Time and patience are required',
        'Commitment is non-negotiable',
        'Structure and responsibility shared',
        'Age difference or maturity themes',
      ],
    ),
    shadowExpression: ShadowExpression(
      whenStressed: 'Becomes cold, punitive, or withholding. May use duty as weapon. Creates distance through work.',
      breakdownCauses: [
        'Betrayal of commitment',
        'Irresponsibility from partner',
        'Feeling burdened by relationship',
        'Lack of respect for boundaries',
      ],
      warningSignals: [
        'Excessive coldness or distance',
        'Workaholism avoiding intimacy',
        'Treating relationship as duty only',
        'Punishment through withdrawal',
      ],
    ),
    realLifePatterns: RealLifePatterns(
      datingPattern: 'Slow to commit. Tests partner thoroughly. May date older or more mature individuals.',
      marriagePattern: 'Late marriages common. Traditional, sometimes arranged. Partner often serious or career-focused.',
      longTermPattern: 'Relationship deepens over decades. Built through shared challenges and achievements.',
      observableSignals: [
        'Partner is mature or responsible',
        'Relationship developed slowly',
        'Commitment is rock-solid',
        'Structure and routine in relationship',
      ],
    ),
    growthPath: GrowthPath(
      coreLesson: 'Learning that love requires vulnerability, not just reliability.',
      skillsNeeded: [
        'Emotional warmth and expression',
        'Flexibility within structure',
        'Forgiveness without keeping score',
        'Balancing duty with joy',
      ],
      practicalActions: [
        'Practice expressing affection regularly',
        'Create space for spontaneity',
        'Address hurts rather than storing them',
        'Balance work and relationship time',
      ],
      ultimateGift: 'A relationship that stands the test of time, deepening through decades.',
    ),
    signModifications: {
      'Aries': 'Disciplined action partner; impatient with structure',
      'Taurus': 'Very stable, slow partner; values security',
      'Gemini': 'Serious about communication; structured thinking',
      'Cancer': 'Emotionally cautious partner; slow to trust',
      'Leo': 'Dignified responsibility; serious about position',
      'Virgo': 'Precisely dutiful; perfectionist partner',
      'Libra': 'Commitment to balance; relationship takes time',
      'Scorpio': 'Deep commitment; very serious about trust',
      'Sagittarius': 'Philosophical about duty; free-spirited structure',
      'Capricorn': 'Ultimate responsibility; career-focused partner',
      'Aquarius': 'Unconventional commitment; detached reliability',
      'Pisces': 'Spiritual discipline; karmic relationship feel',
    },
    houseModifications: {
      '1': 'Partner matures your identity significantly',
      '2': 'Wealth built slowly together',
      '3': 'Serious communication; effort in expression',
      '4': 'Home requires building; may face property challenges',
      '5': 'Romance develops slowly; children may come late',
      '6': 'Partner in service or facing health challenges',
      '7': 'Delayed marriage; very committed once made',
      '8': 'Deep transformation; facing mortality together',
      '9': 'Serious about beliefs; structured philosophy',
      '10': 'Strong career couple; status important',
      '11': 'Long-term goals together; patient achievement',
      '12': 'Karmic relationship; spiritual discipline',
    },
    masterInsight: 'Saturn DK teaches that love is built, not found. The lesson is patient construction of a bond that outlasts youth and circumstance.',
  );

  /// Get Darakaraka data by planet abbreviation
  static DarakarakaData? getData(String planet) => data[planet];

  /// Get suitable communication style based on DK
  static String getCommunicationAdvice(String dkPlanet) {
    const advice = {
      'Su': 'Communicate with respect and acknowledgment. Validate authority and competence.',
      'Mo': 'Communicate with emotional presence. Listen to feelings before logic.',
      'Ma': 'Communicate directly and honestly. Don\'t beat around the bush.',
      'Me': 'Communicate clearly and intellectually. Engage in discussions.',
      'Ju': 'Communicate with meaning and wisdom. Share philosophies.',
      'Ve': 'Communicate with charm and appreciation. Express love verbally.',
      'Sa': 'Communicate with patience and reliability. Prove words with actions.',
    };
    return advice[dkPlanet] ?? 'Communicate with awareness and presence.';
  }

  /// Get relationship skill needed based on DK
  static List<String> getRequiredSkills(String dkPlanet) {
    final data = DarakarakaEducation.data[dkPlanet];
    return data?.growthPath.skillsNeeded ?? [];
  }

  /// Master rule for DK interpretation
  static const String masterRule = 
    'Darakaraka describes relationship KARMA, not just romantic preference. '
    'It shows what we must learn through intimate partnership. '
    'Strong DK = relationship is central to life lessons. '
    'Weak DK = relationship challenges require conscious development. '
    'NEVER interpret DK as "good" or "bad" partner - interpret as learning path.';
}
