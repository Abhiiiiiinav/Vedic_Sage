/// Comprehensive Arudha Pada Education Data
/// 
/// Contains strengthening tips and weakness indicators for each Arudha Pada.
/// Based on professional Vedic astrology principles.
/// 
/// Core Concept: Arudhas show how the world PERCEIVES you in each life area.
/// Strengthening an Arudha improves your public image in that area.

class ArudhaEducationData {
  final int houseNumber;
  final String name;
  final String abbreviation;
  final String domain;
  final String description;
  final List<String> strengtheningTips;
  final List<String> weaknessIndicators;
  final Map<String, String> signInterpretations;
  final String masterNote;

  const ArudhaEducationData({
    required this.houseNumber,
    required this.name,
    required this.abbreviation,
    required this.domain,
    required this.description,
    required this.strengtheningTips,
    required this.weaknessIndicators,
    required this.signInterpretations,
    required this.masterNote,
  });

  static const Map<int, ArudhaEducationData> arudhas = {
    1: _al, 2: _a2, 3: _a3, 4: _a4, 5: _a5, 6: _a6,
    7: _a7, 8: _a8, 9: _a9, 10: _a10, 11: _a11, 12: _a12,
  };

  // ============ ARUDHA LAGNA (AL) ============
  static const _al = ArudhaEducationData(
    houseNumber: 1,
    name: 'Arudha Lagna',
    abbreviation: 'AL',
    domain: 'Overall Public Image · Status · First Impression',
    description: 'How the world perceives your personality, status, and overall character. This is your "public mask".',
    strengtheningTips: [
      'Dress according to your AL sign\'s colors and style',
      'Develop the positive traits of your AL sign consciously',
      'Manage first impressions deliberately',
      'Build reputation through consistent public behavior',
      'Strengthen the lord of your AL through remedies',
      'Be aware of how others perceive you vs. your true nature',
      'Use the AL sign\'s strengths in public settings',
      'Network in environments aligned with your AL',
    ],
    weaknessIndicators: [
      'People consistently misunderstand your character',
      'First impressions don\'t reflect your true abilities',
      'Reputation issues despite good intentions',
      'Social status feels unstable',
      'Public image doesn\'t match inner reality',
    ],
    signInterpretations: {
      'Aries': 'Seen as bold, direct, and action-oriented',
      'Taurus': 'Perceived as stable, wealthy, and grounded',
      'Gemini': 'Viewed as intelligent, communicative, versatile',
      'Cancer': 'Seen as nurturing, emotional, family-oriented',
      'Leo': 'Perceived as confident, authoritative, dignified',
      'Virgo': 'Viewed as analytical, helpful, detail-oriented',
      'Libra': 'Seen as balanced, diplomatic, relationship-focused',
      'Scorpio': 'Perceived as intense, mysterious, powerful',
      'Sagittarius': 'Viewed as wise, philosophical, optimistic',
      'Capricorn': 'Seen as ambitious, disciplined, professional',
      'Aquarius': 'Perceived as innovative, detached, humanitarian',
      'Pisces': 'Viewed as spiritual, compassionate, dreamy',
    },
    masterNote: 'AL shows the gap between perception and reality. Bridge this gap for authentic success.',
  );

  // ============ DHANA PADA (A2) ============
  static const _a2 = ArudhaEducationData(
    houseNumber: 2,
    name: 'Dhana Pada',
    abbreviation: 'A2',
    domain: 'Wealth Perception · Family Image · Speech',
    description: 'How wealthy and resourceful you appear to others. Your perceived financial status.',
    strengtheningTips: [
      'Speak with confidence about financial matters',
      'Dress in a way that reflects financial stability',
      'Build visible savings and assets',
      'Maintain family reputation',
      'Develop clear, authoritative speech',
      'Show generosity appropriately',
      'Learn financial vocabulary and concepts',
      'Present yourself as someone who values resources',
    ],
    weaknessIndicators: [
      'Others think you\'re poorer than you are',
      'People don\'t trust your financial judgment',
      'Family image suffers despite stability',
      'Speech doesn\'t command respect',
      'Wealth potential not recognized',
    ],
    signInterpretations: {
      'Aries': 'Seen as someone who earns through initiative',
      'Taurus': 'Perceived as naturally wealthy and stable',
      'Gemini': 'Viewed as earning through communication',
      'Cancer': 'Seen as having inherited wealth or family money',
      'Leo': 'Perceived as earning through authority/leadership',
      'Virgo': 'Viewed as earning through service and skills',
      'Libra': 'Seen as earning through partnerships',
      'Scorpio': 'Perceived as having hidden wealth',
      'Sagittarius': 'Viewed as fortunate in finances',
      'Capricorn': 'Seen as earning through hard work',
      'Aquarius': 'Perceived as earning through innovation',
      'Pisces': 'Viewed as spiritual about money',
    },
    masterNote: 'A2 shapes loan approvals, investor trust, and business credibility.',
  );

  // ============ VIKRAMA PADA (A3) ============
  static const _a3 = ArudhaEducationData(
    houseNumber: 3,
    name: 'Vikrama Pada',
    abbreviation: 'A3',
    domain: 'Courage Perception · Communication Image',
    description: 'How brave, skilled, and communicative you appear to others.',
    strengtheningTips: [
      'Demonstrate courage in public situations',
      'Showcase skills and talents openly',
      'Communicate achievements confidently',
      'Build a visible track record of initiative',
      'Engage in competitive activities publicly',
      'Share knowledge and teach others',
      'Develop public speaking skills',
      'Show consistency in following through',
    ],
    weaknessIndicators: [
      'People underestimate your courage',
      'Skills go unrecognized',
      'Communication efforts feel unheard',
      'Others don\'t see your initiative',
      'Sibling relationships affect reputation',
    ],
    signInterpretations: {
      'Aries': 'Seen as extremely courageous and pioneering',
      'Taurus': 'Perceived as having slow but steady courage',
      'Gemini': 'Viewed as skilled communicator',
      'Cancer': 'Seen as emotionally brave',
      'Leo': 'Perceived as dramatically courageous',
      'Virgo': 'Viewed as technically skilled',
      'Libra': 'Seen as diplomatically courageous',
      'Scorpio': 'Perceived as having hidden strength',
      'Sagittarius': 'Viewed as adventurous and bold',
      'Capricorn': 'Seen as professionally courageous',
      'Aquarius': 'Perceived as unconventionally brave',
      'Pisces': 'Viewed as spiritually courageous',
    },
    masterNote: 'A3 affects how people see your ability to take action and compete.',
  );

  // ============ SUKHA PADA (A4) ============
  static const _a4 = ArudhaEducationData(
    houseNumber: 4,
    name: 'Sukha Pada',
    abbreviation: 'A4',
    domain: 'Comfort Perception · Property Image · Peace',
    description: 'How comfortable, peaceful, and settled you appear. Your perceived domestic happiness.',
    strengtheningTips: [
      'Create a welcoming home environment',
      'Invest in visible property improvements',
      'Demonstrate emotional stability publicly',
      'Show contentment and peace of mind',
      'Display education and learning',
      'Maintain relationship with mother publicly',
      'Invest in visible vehicles and comforts',
      'Create a calm, balanced public presence',
    ],
    weaknessIndicators: [
      'People think you lack inner peace',
      'Property status underestimated',
      'Emotional instability visible to others',
      'Home life seems troubled to outsiders',
      'Educational achievements overlooked',
    ],
    signInterpretations: {
      'Aries': 'Seen as restless but dynamic at home',
      'Taurus': 'Perceived as having luxurious home life',
      'Gemini': 'Viewed as having an intellectual home',
      'Cancer': 'Seen as deeply rooted and nurturing',
      'Leo': 'Perceived as having a grand, royal home',
      'Virgo': 'Viewed as having an organized home',
      'Libra': 'Seen as having a beautiful, harmonious home',
      'Scorpio': 'Perceived as private about home life',
      'Sagittarius': 'Viewed as having an open, welcoming home',
      'Capricorn': 'Seen as having traditional property',
      'Aquarius': 'Perceived as having an unusual home',
      'Pisces': 'Viewed as having a spiritual home',
    },
    masterNote: 'A4 influences real estate deals, rental agreements, and domestic partnerships.',
  );

  // ============ MANTRA PADA (A5) ============
  static const _a5 = ArudhaEducationData(
    houseNumber: 5,
    name: 'Mantra Pada',
    abbreviation: 'A5',
    domain: 'Intelligence Perception · Creativity Image',
    description: 'How intelligent, creative, and talented you appear to others.',
    strengtheningTips: [
      'Showcase creative work publicly',
      'Share intellectual achievements',
      'Display good judgment in public',
      'Support and highlight children\'s achievements',
      'Engage in visible learning activities',
      'Express opinions confidently',
      'Create and share original content',
      'Demonstrate strategic thinking',
    ],
    weaknessIndicators: [
      'Intelligence is underestimated',
      'Creative work goes unnoticed',
      'Advice is not sought or valued',
      'Children\'s success doesn\'t reflect on you',
      'Romantic appeal seems lacking',
    ],
    signInterpretations: {
      'Aries': 'Seen as having spontaneous intelligence',
      'Taurus': 'Perceived as creatively practical',
      'Gemini': 'Viewed as intellectually brilliant',
      'Cancer': 'Seen as emotionally intelligent',
      'Leo': 'Perceived as dramatically creative',
      'Virgo': 'Viewed as analytically smart',
      'Libra': 'Seen as artistically refined',
      'Scorpio': 'Perceived as having deep insight',
      'Sagittarius': 'Viewed as philosophically wise',
      'Capricorn': 'Seen as strategically intelligent',
      'Aquarius': 'Perceived as innovatively genius',
      'Pisces': 'Viewed as intuitively creative',
    },
    masterNote: 'A5 shapes how others perceive your decision-making ability and creativity.',
  );

  // ============ ROGA PADA (A6) ============
  static const _a6 = ArudhaEducationData(
    houseNumber: 6,
    name: 'Roga Pada',
    abbreviation: 'A6',
    domain: 'Service Perception · Health Image',
    description: 'How your service, discipline, and health habits appear to others.',
    strengtheningTips: [
      'Demonstrate visible work ethic',
      'Show discipline and routine publicly',
      'Address conflicts professionally',
      'Display good health habits',
      'Serve others visibly',
      'Show problem-solving ability',
      'Maintain professional appearance',
      'Handle competition gracefully',
    ],
    weaknessIndicators: [
      'Work ethic is underappreciated',
      'Health seems worse than it is',
      'Service goes unnoticed',
      'Seen as someone who attracts problems',
      'Competition seems to always win',
    ],
    signInterpretations: {
      'Aries': 'Seen as aggressively tackling problems',
      'Taurus': 'Perceived as steadily serving',
      'Gemini': 'Viewed as mentally handling issues',
      'Cancer': 'Seen as emotionally processing challenges',
      'Leo': 'Perceived as proudly overcoming obstacles',
      'Virgo': 'Viewed as perfectly organized in service',
      'Libra': 'Seen as diplomatically handling conflicts',
      'Scorpio': 'Perceived as intensely fighting battles',
      'Sagittarius': 'Viewed as philosophically accepting challenges',
      'Capricorn': 'Seen as professionally disciplined',
      'Aquarius': 'Perceived as uniquely solving problems',
      'Pisces': 'Viewed as spiritually transcending issues',
    },
    masterNote: 'A6 influences workplace reputation and how people see your problem-solving.',
  );

  // ============ DARA PADA (A7) ============
  static const _a7 = ArudhaEducationData(
    houseNumber: 7,
    name: 'Dara Pada',
    abbreviation: 'A7',
    domain: 'Partnership Perception · Marriage Image',
    description: 'How your relationships and partnership abilities appear to others. Very important for marriage.',
    strengtheningTips: [
      'Present your relationship positively publicly',
      'Show partnership skills in professional settings',
      'Dress attractively and maintain appearance',
      'Demonstrate commitment and loyalty',
      'Improve social skills and charm',
      'Handle public interactions gracefully',
      'Show respect for partners publicly',
      'Build reputation as a good partner',
    ],
    weaknessIndicators: [
      'People think you\'re bad at relationships',
      'Marriage proposals don\'t come easily',
      'Business partnerships struggle',
      'Public perception as uncommitted',
      'Social charm feels lacking',
    ],
    signInterpretations: {
      'Aries': 'Seen as passionate and direct in love',
      'Taurus': 'Perceived as stable, loyal partner',
      'Gemini': 'Viewed as communicative in relationships',
      'Cancer': 'Seen as nurturing and devoted',
      'Leo': 'Perceived as romantic and proud partner',
      'Virgo': 'Viewed as practical in partnerships',
      'Libra': 'Seen as ideal relationship material',
      'Scorpio': 'Perceived as intensely devoted',
      'Sagittarius': 'Viewed as adventurous partner',
      'Capricorn': 'Seen as committed and responsible',
      'Aquarius': 'Perceived as unconventional in love',
      'Pisces': 'Viewed as romantic and spiritual',
    },
    masterNote: 'A7 is critical for marriage timing and partner attraction. Strengthen this carefully.',
  );

  // ============ MRITYU PADA (A8) ============
  static const _a8 = ArudhaEducationData(
    houseNumber: 8,
    name: 'Mrityu Pada',
    abbreviation: 'A8',
    domain: 'Transformation Perception · Mystery Image',
    description: 'How your depth, research abilities, and handling of crises appear to others.',
    strengtheningTips: [
      'Demonstrate resilience during crises',
      'Show research and investigative skills',
      'Handle sensitive matters with discretion',
      'Display calm during transformation',
      'Build reputation for depth and insight',
      'Show trustworthiness with secrets',
      'Demonstrate financial savvy with shared resources',
      'Handle inheritance matters gracefully',
    ],
    weaknessIndicators: [
      'Seen as someone who brings problems',
      'Others don\'t trust you with secrets',
      'Crisis handling seems poor',
      'Research abilities overlooked',
      'Inheritance or joint finances suffer',
    ],
    signInterpretations: {
      'Aries': 'Seen as directly facing transformations',
      'Taurus': 'Perceived as stable through changes',
      'Gemini': 'Viewed as mentally processing depth',
      'Cancer': 'Seen as emotionally handling crises',
      'Leo': 'Perceived as proudly transforming',
      'Virgo': 'Viewed as analytically researching',
      'Libra': 'Seen as balancing through changes',
      'Scorpio': 'Perceived as master of transformation',
      'Sagittarius': 'Viewed as philosophical about death/change',
      'Capricorn': 'Seen as professionally handling crises',
      'Aquarius': 'Perceived as detached from upheaval',
      'Pisces': 'Viewed as spiritually transcending',
    },
    masterNote: 'A8 affects trust in financial partnerships and crisis management reputation.',
  );

  // ============ BHAGYA PADA (A9) ============
  static const _a9 = ArudhaEducationData(
    houseNumber: 9,
    name: 'Bhagya Pada',
    abbreviation: 'A9',
    domain: 'Luck Perception · Dharma Image',
    description: 'How fortunate, wise, and dharmic you appear to others.',
    strengtheningTips: [
      'Display visible spiritual practices',
      'Show respect for teachers and elders',
      'Demonstrate ethical behavior publicly',
      'Travel and share experiences',
      'Pursue higher education visibly',
      'Show philosophical wisdom',
      'Support dharmic causes publicly',
      'Demonstrate gratitude for good fortune',
    ],
    weaknessIndicators: [
      'Others think you\'re unlucky',
      'Wisdom goes unrecognized',
      'Spiritual efforts seem futile',
      'Teachers don\'t support you',
      'Legal matters don\'t favor you',
    ],
    signInterpretations: {
      'Aries': 'Seen as actively pursuing dharma',
      'Taurus': 'Perceived as materially fortunate',
      'Gemini': 'Viewed as intellectually blessed',
      'Cancer': 'Seen as emotionally fortunate',
      'Leo': 'Perceived as royally blessed',
      'Virgo': 'Viewed as fortunate through service',
      'Libra': 'Seen as blessed in relationships',
      'Scorpio': 'Perceived as deeply fortunate',
      'Sagittarius': 'Viewed as naturally lucky',
      'Capricorn': 'Seen as earning luck through effort',
      'Aquarius': 'Perceived as uniquely blessed',
      'Pisces': 'Viewed as spiritually fortunate',
    },
    masterNote: 'A9 affects how people see your luck, making it crucial for opportunities.',
  );

  // ============ KARMA PADA (A10) ============
  static const _a10 = ArudhaEducationData(
    houseNumber: 10,
    name: 'Karma Pada',
    abbreviation: 'A10',
    domain: 'Career Perception · Professional Image',
    description: 'How your career, authority, and professional abilities appear. Critical for success.',
    strengtheningTips: [
      'Build visible professional achievements',
      'Dress professionally and appropriately',
      'Take on leadership roles publicly',
      'Maintain consistent work reputation',
      'Network in professional circles',
      'Accept recognition gracefully',
      'Show expertise in your field',
      'Deliver visible results consistently',
    ],
    weaknessIndicators: [
      'Career achievements go unnoticed',
      'Professional reputation suffers',
      'Promotions come slowly',
      'Authority is not recognized',
      'Public standing seems weak',
    ],
    signInterpretations: {
      'Aries': 'Seen as pioneering professional',
      'Taurus': 'Perceived as stable worker',
      'Gemini': 'Viewed as versatile professional',
      'Cancer': 'Seen as nurturing leader',
      'Leo': 'Perceived as authoritative boss',
      'Virgo': 'Viewed as skilled technician',
      'Libra': 'Seen as diplomatic professional',
      'Scorpio': 'Perceived as powerful in career',
      'Sagittarius': 'Viewed as inspiring leader',
      'Capricorn': 'Seen as ultimate professional',
      'Aquarius': 'Perceived as innovative professional',
      'Pisces': 'Viewed as creative professional',
    },
    masterNote: 'A10 directly impacts job interviews, promotions, and business success.',
  );

  // ============ LABHA PADA (A11) ============
  static const _a11 = ArudhaEducationData(
    houseNumber: 11,
    name: 'Labha Pada',
    abbreviation: 'A11',
    domain: 'Gains Perception · Network Image',
    description: 'How successful and well-connected you appear. Your perceived ability to achieve goals.',
    strengtheningTips: [
      'Showcase achievements and gains publicly',
      'Build and maintain visible networks',
      'Celebrate successes appropriately',
      'Support friends\' achievements',
      'Set and communicate clear goals',
      'Show appreciation for helpers',
      'Attend networking events',
      'Display optimism about goals',
    ],
    weaknessIndicators: [
      'Success goes unnoticed',
      'Networks feel weak',
      'Friends don\'t support goals',
      'Income seems less than reality',
      'Goals appear unreachable',
    ],
    signInterpretations: {
      'Aries': 'Seen as actively gaining',
      'Taurus': 'Perceived as steadily accumulating',
      'Gemini': 'Viewed as networking genius',
      'Cancer': 'Seen as gaining through family',
      'Leo': 'Perceived as achieving grandly',
      'Virgo': 'Viewed as gaining through work',
      'Libra': 'Seen as gaining through partnerships',
      'Scorpio': 'Perceived as secretly successful',
      'Sagittarius': 'Viewed as fortunately gaining',
      'Capricorn': 'Seen as professionally successful',
      'Aquarius': 'Perceived as innovatively gaining',
      'Pisces': 'Viewed as spiritually fulfilled',
    },
    masterNote: 'A11 affects investor confidence, funding, and social capital.',
  );

  // ============ VYAYA PADA (A12) ============
  static const _a12 = ArudhaEducationData(
    houseNumber: 12,
    name: 'Vyaya Pada',
    abbreviation: 'A12',
    domain: 'Expenditure Perception · Spiritual Image',
    description: 'How your spending, charity, and spiritual nature appear to others.',
    strengtheningTips: [
      'Practice visible charity appropriately',
      'Show spiritual practices balanced with worldly life',
      'Travel abroad and share experiences',
      'Handle expenses with visible wisdom',
      'Support ashrams or spiritual causes',
      'Show rest and recovery practices',
      'Demonstrate letting go gracefully',
      'Balance spending visibility carefully',
    ],
    weaknessIndicators: [
      'Seen as excessive spender',
      'Spiritual efforts misunderstood',
      'Losses become publicly known',
      'Charity goes unappreciated',
      'Isolation seems problematic',
    ],
    signInterpretations: {
      'Aries': 'Seen as actively spending/giving',
      'Taurus': 'Perceived as comfortable with expenses',
      'Gemini': 'Viewed as mentally releasing',
      'Cancer': 'Seen as emotionally giving',
      'Leo': 'Perceived as royally charitable',
      'Virgo': 'Viewed as organizing expenses',
      'Libra': 'Seen as balanced spender',
      'Scorpio': 'Perceived as secretly generous',
      'Sagittarius': 'Viewed as philosophically giving',
      'Capricorn': 'Seen as disciplined about expenses',
      'Aquarius': 'Perceived as humanitarian',
      'Pisces': 'Viewed as spiritually generous',
    },
    masterNote: 'A12 affects charity reputation and spiritual credibility.',
  );

  /// Get Arudha education data by house number
  static ArudhaEducationData? getArudha(int houseNumber) => arudhas[houseNumber];

  /// Get sign-specific interpretation for an Arudha
  static String? getSignInterpretation(int houseNumber, String signName) {
    final data = arudhas[houseNumber];
    return data?.signInterpretations[signName];
  }

  /// Master rules for all Arudhas
  static const String masterRule = 
    'Arudhas show PERCEPTION, not reality. A strong Arudha means others see that '
    'quality clearly, whether or not you truly possess it. Work on both your Arudha '
    '(image) and Bhava (reality) for authentic success.';
}
