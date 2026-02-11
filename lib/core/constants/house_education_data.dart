/// Comprehensive House Data with Strengthening Tips and Weakness Indicators
/// Based on professional Vedic astrology knowledge (20+ years experience)
/// 
/// Core Rule: A house becomes strong when its responsibilities are consciously 
/// accepted and expressed, not avoided.

class HouseEducationData {
  final int number;
  final String name;
  final String domain;
  final List<String> strengtheningTips;
  final List<String> weaknessIndicators;
  final String masterNote;
  final String coreRule;

  const HouseEducationData({
    required this.number,
    required this.name,
    required this.domain,
    required this.strengtheningTips,
    required this.weaknessIndicators,
    required this.masterNote,
    required this.coreRule,
  });

  static const Map<int, HouseEducationData> houses = {
    1: _h1, 2: _h2, 3: _h3, 4: _h4, 5: _h5, 6: _h6,
    7: _h7, 8: _h8, 9: _h9, 10: _h10, 11: _h11, 12: _h12,
  };

  // ============ FIRST HOUSE ============
  static const _h1 = HouseEducationData(
    number: 1,
    name: 'First House (Lagna)',
    domain: 'Self · Health · Direction',
    strengtheningTips: [
      'Maintain physical health consciously (sleep, movement, posture)',
      'Develop a stable daily routine',
      'Take ownership of life decisions',
      'Build self-confidence through action, not validation',
      'Present yourself clearly (appearance, communication)',
      'Stop blaming circumstances for identity issues',
      'Practice self-discipline',
      'Start things independently',
      'Improve body–mind awareness',
      'Choose direction over confusion',
    ],
    weaknessIndicators: [
      'Weak self-confidence or unstable identity',
      'Difficulty asserting personal boundaries',
      'Low vitality or fluctuating physical energy',
      'Confusion about life direction',
      'Over-dependence on others\' opinions',
      'Difficulty initiating life changes',
      'Poor self-image despite capability',
      'Feeling "lost" or undefined',
      'Health issues without clear diagnosis',
      'Life progress feels slow despite effort',
    ],
    masterNote: 'A weak 1st house affects everything, because all houses flow through it.',
    coreRule: 'The 1st house strengthens when you stop drifting and start owning yourself.',
  );

  // ============ SECOND HOUSE ============
  static const _h2 = HouseEducationData(
    number: 2,
    name: 'Second House',
    domain: 'Wealth · Speech · Values · Family',
    strengtheningTips: [
      'Practice conscious money management',
      'Build savings slowly and consistently',
      'Speak truthfully and respectfully',
      'Reduce harsh or careless speech',
      'Clarify personal values',
      'Eat mindfully and regularly',
      'Respect family responsibilities',
      'Avoid fear-based financial decisions',
      'Build self-worth independent of money',
      'Learn financial literacy',
    ],
    weaknessIndicators: [
      'Difficulty accumulating or retaining money',
      'Financial instability despite income',
      'Harsh, unclear, or ineffective speech',
      'Strained family environment',
      'Low sense of personal value or self-worth',
      'Problems with savings or assets',
      'Speech misunderstood or ignored',
      'Family responsibilities feel burdensome',
      'Fear around financial security',
      'Inconsistent eating habits or throat issues',
    ],
    masterNote: 'A weak 2nd house disturbs both money and self-valuation.',
    coreRule: 'The 2nd house strengthens when value and voice are aligned.',
  );

  // ============ THIRD HOUSE ============
  static const _h3 = HouseEducationData(
    number: 3,
    name: 'Third House',
    domain: 'Courage · Effort · Skills',
    strengtheningTips: [
      'Take initiative even in small matters',
      'Practice consistent effort',
      'Improve communication skills',
      'Face challenges instead of avoiding them',
      'Learn hands-on skills',
      'Network consciously',
      'Build confidence through action',
      'Strengthen sibling or peer relationships',
      'Practice assertive communication',
      'Finish what you start',
    ],
    weaknessIndicators: [
      'Lack of initiative or courage',
      'Fear of taking risks or starting projects',
      'Communication hesitation',
      'Difficulty sustaining effort',
      'Weak networking ability',
      'Strained sibling relationships',
      'Fear of competition',
      'Poor follow-through',
      'Low confidence in skills',
      'Avoidance of challenges',
    ],
    masterNote: 'Weak 3rd house = effort exists but courage collapses.',
    coreRule: 'The 3rd house strengthens through effort, not comfort.',
  );

  // ============ FOURTH HOUSE ============
  static const _h4 = HouseEducationData(
    number: 4,
    name: 'Fourth House',
    domain: 'Peace · Home · Emotional Stability',
    strengtheningTips: [
      'Create a calm home environment',
      'Address emotional issues honestly',
      'Spend time with family or caregivers',
      'Ground yourself emotionally',
      'Avoid emotional suppression',
      'Maintain stability in living space',
      'Respect mother / nurturing figures',
      'Reduce internal restlessness',
      'Practice emotional self-care',
      'Seek inner peace before outer success',
    ],
    weaknessIndicators: [
      'Lack of inner peace',
      'Emotional restlessness',
      'Unstable home environment',
      'Difficulty feeling "at home" anywhere',
      'Property or vehicle issues',
      'Emotional insecurity',
      'Strained relationship with mother',
      'Frequent relocations without stability',
      'Poor emotional grounding',
      'Difficulty relaxing',
    ],
    masterNote: 'Weak 4th house affects mental peace, not just property.',
    coreRule: 'The 4th house strengthens when emotional security is built internally.',
  );

  // ============ FIFTH HOUSE ============
  static const _h5 = HouseEducationData(
    number: 5,
    name: 'Fifth House',
    domain: 'Intelligence · Creativity · Confidence',
    strengtheningTips: [
      'Engage in creative activities',
      'Trust your intelligence',
      'Study with curiosity, not fear',
      'Express ideas confidently',
      'Avoid overthinking outcomes',
      'Take calculated intellectual risks',
      'Cultivate joy consciously',
      'Mentor or teach others',
      'Respect children or creative projects',
      'Make decisions independently',
    ],
    weaknessIndicators: [
      'Difficulty focusing intellectually',
      'Creative blocks',
      'Fear of self-expression',
      'Poor decision-making',
      'Academic struggles without cause',
      'Emotional detachment from joy',
      'Difficulty sustaining romance',
      'Worry or issues related to children',
      'Lack of confidence in intelligence',
      'Loss of curiosity',
    ],
    masterNote: 'Weak 5th house dims joy and confidence in one\'s mind.',
    coreRule: 'The 5th house strengthens through confident self-expression.',
  );

  // ============ SIXTH HOUSE ============
  static const _h6 = HouseEducationData(
    number: 6,
    name: 'Sixth House',
    domain: 'Discipline · Health · Challenges',
    strengtheningTips: [
      'Maintain daily discipline',
      'Address health issues proactively',
      'Develop problem-solving habits',
      'Face competition directly',
      'Build resilience through routine',
      'Avoid escapism from duties',
      'Serve without resentment',
      'Practice time management',
      'Reduce stress through structure',
      'Improve work ethics',
    ],
    weaknessIndicators: [
      'Recurrent health problems',
      'Difficulty handling stress',
      'Workplace conflicts',
      'Feeling overburdened by duties',
      'Fear of competition',
      'Chronic fatigue',
      'Legal or dispute-related stress',
      'Poor discipline in daily routines',
      'Difficulty defeating obstacles',
      'Persistent anxiety',
    ],
    masterNote: 'A weak 6th house makes small problems feel overwhelming.',
    coreRule: 'The 6th house strengthens by mastering daily struggles.',
  );

  // ============ SEVENTH HOUSE ============
  static const _h7 = HouseEducationData(
    number: 7,
    name: 'Seventh House',
    domain: 'Relationships · Balance · Commitment',
    strengtheningTips: [
      'Practice fairness in relationships',
      'Communicate expectations clearly',
      'Avoid ego clashes',
      'Respect boundaries (yours and others\')',
      'Learn compromise without self-loss',
      'Choose partners consciously',
      'Honor commitments',
      'Improve interpersonal skills',
      'Balance "me" and "we"',
      'Be accountable in partnerships',
    ],
    weaknessIndicators: [
      'Relationship dissatisfaction',
      'Difficulty trusting partners',
      'Delayed or unstable marriage',
      'Business partnership failures',
      'Fear of commitment',
      'Repeated misunderstandings in relationships',
      'Public image affected by others',
      'Attracting emotionally unavailable partners',
      'Difficulty balancing "self vs others"',
      'Feeling drained by relationships',
    ],
    masterNote: 'Weak 7th house reflects imbalance in one-to-one energy.',
    coreRule: 'The 7th house strengthens through mutual respect and balance.',
  );

  // ============ EIGHTH HOUSE ============
  static const _h8 = HouseEducationData(
    number: 8,
    name: 'Eighth House',
    domain: 'Transformation · Stability · Depth',
    strengtheningTips: [
      'Accept change instead of fearing it',
      'Build emotional resilience',
      'Address hidden fears consciously',
      'Handle crises calmly',
      'Practice psychological honesty',
      'Manage shared resources responsibly',
      'Avoid secrecy driven by fear',
      'Develop trust gradually',
      'Learn from losses',
      'Cultivate inner strength',
    ],
    weaknessIndicators: [
      'Fear of sudden change',
      'Anxiety about losses',
      'Emotional instability',
      'Difficulty handling crises',
      'Inheritance or joint finance issues',
      'Chronic uncertainty',
      'Trust issues',
      'Fear of intimacy',
      'Psychological stress',
      'Sudden disruptions in life',
    ],
    masterNote: 'Weak 8th house causes fear of the unknown, not just misfortune.',
    coreRule: 'The 8th house strengthens through conscious transformation.',
  );

  // ============ NINTH HOUSE ============
  static const _h9 = HouseEducationData(
    number: 9,
    name: 'Ninth House',
    domain: 'Faith · Luck · Guidance',
    strengtheningTips: [
      'Respect mentors and teachers',
      'Develop a personal philosophy',
      'Act ethically even under pressure',
      'Trust long-term vision',
      'Study higher knowledge',
      'Practice gratitude',
      'Avoid cynicism',
      'Travel or broaden perspective',
      'Align actions with beliefs',
      'Serve a higher purpose',
    ],
    weaknessIndicators: [
      'Loss of faith or optimism',
      'Poor guidance from mentors',
      'Luck not supporting effort',
      'Ethical confusion',
      'Blocked higher education',
      'Strained relationship with father/gurus',
      'Difficulty finding meaning',
      'Travel troubles',
      'Philosophical confusion',
      'Lack of long-term vision',
    ],
    masterNote: 'Weak 9th house blocks grace and guidance, not effort.',
    coreRule: 'The 9th house strengthens when faith is lived, not preached.',
  );

  // ============ TENTH HOUSE ============
  static const _h10 = HouseEducationData(
    number: 10,
    name: 'Tenth House',
    domain: 'Career · Responsibility · Karma',
    strengtheningTips: [
      'Take responsibility for career choices',
      'Work with integrity',
      'Build professional discipline',
      'Accept leadership roles gradually',
      'Avoid shortcuts',
      'Improve reputation consciously',
      'Set long-term career goals',
      'Respect authority and hierarchy',
      'Deliver consistent results',
      'Find meaning in work',
    ],
    weaknessIndicators: [
      'Career instability',
      'Lack of recognition',
      'Confusion about professional direction',
      'Fear of responsibility',
      'Poor authority relationships',
      'Public reputation issues',
      'Delayed career growth',
      'Difficulty sustaining ambition',
      'Feeling stuck professionally',
      'Work feels meaningless',
    ],
    masterNote: 'Weak 10th house affects karma execution, not talent.',
    coreRule: 'The 10th house strengthens through responsible action.',
  );

  // ============ ELEVENTH HOUSE ============
  static const _h11 = HouseEducationData(
    number: 11,
    name: 'Eleventh House',
    domain: 'Gains · Network · Aspirations',
    strengtheningTips: [
      'Set realistic long-term goals',
      'Build supportive networks',
      'Collaborate without jealousy',
      'Manage expectations',
      'Share success ethically',
      'Stay hopeful but grounded',
      'Maintain friendships',
      'Plan income strategically',
      'Celebrate others\' success',
      'Focus on sustainable growth',
    ],
    weaknessIndicators: [
      'Difficulty achieving goals',
      'Income instability',
      'Weak professional networks',
      'Social isolation',
      'Unrealistic expectations',
      'Gains come with struggle',
      'Disappointment despite success',
      'Poor long-term planning',
      'Loss of hope',
      'Difficulty maintaining friendships',
    ],
    masterNote: 'Weak 11th house delays rewards, not effort.',
    coreRule: 'The 11th house strengthens through collective growth.',
  );

  // ============ TWELFTH HOUSE ============
  static const _h12 = HouseEducationData(
    number: 12,
    name: 'Twelfth House',
    domain: 'Release · Rest · Inner World',
    strengtheningTips: [
      'Practice conscious rest',
      'Improve sleep habits',
      'Learn to let go',
      'Manage expenses wisely',
      'Practice mindfulness or meditation',
      'Accept solitude occasionally',
      'Avoid escapism',
      'Serve quietly',
      'Balance spirituality with practicality',
      'Reduce unconscious stress',
    ],
    weaknessIndicators: [
      'Excessive expenses',
      'Difficulty sleeping',
      'Mental exhaustion',
      'Escapism tendencies',
      'Feeling disconnected',
      'Fear of solitude',
      'Poor spiritual grounding',
      'Hidden anxieties',
      'Restlessness without cause',
      'Difficulty letting go',
    ],
    masterNote: 'Weak 12th house creates unconscious leakage of energy.',
    coreRule: 'The 12th house strengthens through healthy release, not avoidance.',
  );

  /// Get house data by number
  static HouseEducationData? getHouse(int number) => houses[number];

  /// Master rule for all houses
  static const String masterRule = 
    'A house is weak when its life themes cause fear, avoidance, instability, '
    'or repeated struggle instead of growth. '
    'Weak ≠ doomed. Weak = area requiring awareness and conscious strengthening.';
}
