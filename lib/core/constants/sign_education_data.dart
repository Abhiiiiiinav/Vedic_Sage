/// Comprehensive Zodiac Sign Data with Strengthening Tips and Weakness Indicators
/// Based on professional Vedic astrology knowledge (20+ years experience)
/// 
/// Core Rule: A zodiac sign becomes strong when its core energy is expressed 
/// consciously, confidently, and in balance.

class SignEducationData {
  final String id;
  final String name;
  final String symbol;
  final String domain;
  final List<String> strengtheningTips;
  final List<String> weaknessIndicators;
  final String masterNote;
  final String coreRule;

  const SignEducationData({
    required this.id,
    required this.name,
    required this.symbol,
    required this.domain,
    required this.strengtheningTips,
    required this.weaknessIndicators,
    required this.masterNote,
    required this.coreRule,
  });

  static const Map<String, SignEducationData> signs = {
    'aries': _aries, 'taurus': _taurus, 'gemini': _gemini,
    'cancer': _cancer, 'leo': _leo, 'virgo': _virgo,
    'libra': _libra, 'scorpio': _scorpio, 'sagittarius': _sagittarius,
    'capricorn': _capricorn, 'aquarius': _aquarius, 'pisces': _pisces,
  };

  // ============ ARIES ============
  static const _aries = SignEducationData(
    id: 'aries',
    name: 'Aries',
    symbol: '♈',
    domain: 'Initiative · Courage · Momentum',
    strengtheningTips: [
      'Start tasks without waiting for perfect conditions',
      'Engage in regular physical activity',
      'Practice decisive action daily',
      'Express anger constructively, not suppressively',
      'Take leadership in small situations',
      'Set short, clear goals',
      'Compete fairly to sharpen drive',
      'Say "yes" to challenges',
      'Avoid procrastination',
      'Act first, refine later',
    ],
    weaknessIndicators: [
      'Difficulty initiating action',
      'Fear of taking the first step',
      'Low physical drive or stamina',
      'Suppressed anger or internal frustration',
      'Avoidance of leadership roles',
      'Procrastination despite urgency',
      'Poor confidence in competitive situations',
      'Indecisiveness under pressure',
      'Lack of assertiveness',
      'Feeling dependent on others to begin things',
    ],
    masterNote: 'Weak Aries = blocked momentum, not laziness.',
    coreRule: 'Aries strengthens through action over hesitation.',
  );

  // ============ TAURUS ============
  static const _taurus = SignEducationData(
    id: 'taurus',
    name: 'Taurus',
    symbol: '♉',
    domain: 'Stability · Value · Security',
    strengtheningTips: [
      'Build steady financial habits',
      'Create consistent daily routines',
      'Practice self-worth independent of possessions',
      'Enjoy comfort without guilt',
      'Maintain patience during change',
      'Eat and live mindfully',
      'Reduce fear-based attachment',
      'Invest time in long-term growth',
      'Simplify material excess',
      'Stay grounded in the present',
    ],
    weaknessIndicators: [
      'Financial insecurity despite effort',
      'Difficulty maintaining routines',
      'Fear of change without flexibility',
      'Poor self-worth or undervaluing self',
      'Attachment anxiety around resources',
      'Difficulty enjoying comfort or pleasure',
      'Over-dependence on material safety',
      'Hoarding or fear of loss',
      'Inconsistent eating or lifestyle habits',
      'Resistance to growth due to fear',
    ],
    masterNote: 'Weak Taurus = fear-based attachment, not simplicity.',
    coreRule: 'Taurus strengthens through stable, conscious living.',
  );

  // ============ GEMINI ============
  static const _gemini = SignEducationData(
    id: 'gemini',
    name: 'Gemini',
    symbol: '♊',
    domain: 'Communication · Learning · Adaptability',
    strengtheningTips: [
      'Speak and write regularly',
      'Learn something new daily',
      'Practice clarity over speed',
      'Reduce mental clutter',
      'Ask questions freely',
      'Improve listening skills',
      'Avoid overthinking simple matters',
      'Teach what you know',
      'Embrace adaptability',
      'Channel curiosity productively',
    ],
    weaknessIndicators: [
      'Confusion while expressing ideas',
      'Difficulty articulating thoughts',
      'Mental restlessness without clarity',
      'Poor focus or scattered thinking',
      'Learning anxiety',
      'Miscommunication in relationships',
      'Nervousness during conversations',
      'Difficulty multitasking effectively',
      'Fear of being misunderstood',
      'Overthinking trivial matters',
    ],
    masterNote: 'Weak Gemini = noise without signal.',
    coreRule: 'Gemini strengthens through clear exchange of ideas.',
  );

  // ============ CANCER ============
  static const _cancer = SignEducationData(
    id: 'cancer',
    name: 'Cancer',
    symbol: '♋',
    domain: 'Emotional Security · Care · Belonging',
    strengtheningTips: [
      'Create emotional safety in daily life',
      'Maintain a calm home environment',
      'Express feelings honestly',
      'Set healthy emotional boundaries',
      'Care for self before others',
      'Honor family and roots',
      'Practice emotional grounding',
      'Avoid mood-based decisions',
      'Nurture selectively, not excessively',
      'Build inner security',
    ],
    weaknessIndicators: [
      'Emotional insecurity',
      'Difficulty trusting emotional bonds',
      'Fear of abandonment',
      'Mood instability',
      'Over-dependence on others for comfort',
      'Difficulty setting emotional boundaries',
      'Strained maternal relationships',
      'Difficulty feeling "at home"',
      'Emotional withdrawal under stress',
      'Trouble processing feelings',
    ],
    masterNote: 'Weak Cancer = unprotected emotions.',
    coreRule: 'Cancer strengthens through emotional balance and care.',
  );

  // ============ LEO ============
  static const _leo = SignEducationData(
    id: 'leo',
    name: 'Leo',
    symbol: '♌',
    domain: 'Confidence · Expression · Dignity',
    strengtheningTips: [
      'Take pride in your identity',
      'Express creativity openly',
      'Accept recognition gracefully',
      'Lead with responsibility',
      'Reduce dependence on validation',
      'Maintain strong posture and presence',
      'Speak with confidence',
      'Celebrate personal achievements',
      'Avoid ego defensiveness',
      'Shine without dominating',
    ],
    weaknessIndicators: [
      'Low self-esteem despite ability',
      'Fear of visibility or recognition',
      'Difficulty asserting authority',
      'Ego wounds or humiliation sensitivity',
      'Over-dependence on validation',
      'Suppressed creativity',
      'Difficulty leading others',
      'Inconsistent self-belief',
      'Feeling ignored or unseen',
      'Loss of pride in identity',
    ],
    masterNote: 'Weak Leo = dimmed inner fire, not lack of talent.',
    coreRule: 'Leo strengthens through authentic self-expression.',
  );

  // ============ VIRGO ============
  static const _virgo = SignEducationData(
    id: 'virgo',
    name: 'Virgo',
    symbol: '♍',
    domain: 'Analysis · Service · Precision',
    strengtheningTips: [
      'Focus on process, not perfection',
      'Build healthy routines',
      'Trust your skills',
      'Serve without self-criticism',
      'Organize tasks realistically',
      'Reduce anxiety over details',
      'Improve health habits',
      'Accept imperfections',
      'Finish tasks methodically',
      'Apply analysis constructively',
    ],
    weaknessIndicators: [
      'Over-critical thinking',
      'Anxiety over small details',
      'Perfection paralysis',
      'Difficulty completing tasks',
      'Fear of making mistakes',
      'Poor health routines',
      'Self-doubt in skills',
      'Excessive worry',
      'Difficulty trusting one\'s competence',
      'Mental fatigue from overanalysis',
    ],
    masterNote: 'Weak Virgo = analysis without confidence.',
    coreRule: 'Virgo strengthens through useful order, not worry.',
  );

  // ============ LIBRA ============
  static const _libra = SignEducationData(
    id: 'libra',
    name: 'Libra',
    symbol: '♎',
    domain: 'Balance · Relationships · Harmony',
    strengtheningTips: [
      'Practice fair decision-making',
      'Express personal needs clearly',
      'Maintain equal relationships',
      'Reduce people-pleasing',
      'Face conflict calmly',
      'Build internal balance',
      'Choose consciously in partnerships',
      'Avoid indecision through clarity',
      'Cultivate diplomacy',
      'Balance self and others',
    ],
    weaknessIndicators: [
      'Difficulty making decisions',
      'Over-dependence on others\' opinions',
      'Fear of conflict',
      'Relationship imbalance',
      'People-pleasing tendencies',
      'Suppressed personal needs',
      'Indecision in partnerships',
      'Emotional compromise beyond limits',
      'Avoidance of confrontation',
      'Inner imbalance despite outer harmony',
    ],
    masterNote: 'Weak Libra = peace at the cost of self.',
    coreRule: 'Libra strengthens through fairness without self-loss.',
  );

  // ============ SCORPIO ============
  static const _scorpio = SignEducationData(
    id: 'scorpio',
    name: 'Scorpio',
    symbol: '♏',
    domain: 'Depth · Transformation · Resilience',
    strengtheningTips: [
      'Face emotional truths',
      'Release fear of vulnerability',
      'Channel intensity constructively',
      'Practice emotional honesty',
      'Let go of grudges',
      'Accept transformation',
      'Develop inner strength',
      'Trust selectively, not blindly',
      'Avoid emotional suppression',
      'Embrace change',
    ],
    weaknessIndicators: [
      'Fear of emotional intensity',
      'Trust issues',
      'Difficulty letting go',
      'Emotional suppression',
      'Obsessive thinking',
      'Fear of vulnerability',
      'Resistance to change',
      'Internalized anger',
      'Emotional secrecy without clarity',
      'Difficulty handling crises',
    ],
    masterNote: 'Weak Scorpio = blocked transformation.',
    coreRule: 'Scorpio strengthens through conscious transformation.',
  );

  // ============ SAGITTARIUS ============
  static const _sagittarius = SignEducationData(
    id: 'sagittarius',
    name: 'Sagittarius',
    symbol: '♐',
    domain: 'Faith · Vision · Meaning',
    strengtheningTips: [
      'Develop long-term vision',
      'Study philosophy or ethics',
      'Align actions with beliefs',
      'Maintain optimism with realism',
      'Respect mentors and guides',
      'Travel or expand perspectives',
      'Avoid dogmatism',
      'Commit to ideals',
      'Trust growth over fear',
      'Live with purpose',
    ],
    weaknessIndicators: [
      'Loss of optimism',
      'Difficulty trusting life\'s direction',
      'Lack of long-term vision',
      'Ethical confusion',
      'Poor guidance from mentors',
      'Restlessness without purpose',
      'Cynicism toward belief systems',
      'Difficulty committing to ideals',
      'Blocked higher learning',
      'Loss of enthusiasm',
    ],
    masterNote: 'Weak Sagittarius = directionless freedom.',
    coreRule: 'Sagittarius strengthens through guided expansion.',
  );

  // ============ CAPRICORN ============
  static const _capricorn = SignEducationData(
    id: 'capricorn',
    name: 'Capricorn',
    symbol: '♑',
    domain: 'Discipline · Structure · Responsibility',
    strengtheningTips: [
      'Build consistent routines',
      'Accept responsibility willingly',
      'Plan long-term goals',
      'Improve time management',
      'Work patiently toward success',
      'Avoid fear of failure',
      'Respect rules and systems',
      'Balance ambition with rest',
      'Simplify priorities',
      'Stay committed under pressure',
    ],
    weaknessIndicators: [
      'Fear of responsibility',
      'Procrastination despite ambition',
      'Difficulty sustaining effort',
      'Poor time management',
      'Avoidance of authority roles',
      'Feeling overwhelmed by duties',
      'Lack of long-term planning',
      'Burnout tendencies',
      'Resistance to discipline',
      'Fear of failure',
    ],
    masterNote: 'Weak Capricorn = ambition without structure.',
    coreRule: 'Capricorn strengthens through structured effort.',
  );

  // ============ AQUARIUS ============
  static const _aquarius = SignEducationData(
    id: 'aquarius',
    name: 'Aquarius',
    symbol: '♒',
    domain: 'Innovation · Detachment · Collective Thinking',
    strengtheningTips: [
      'Ground abstract ideas practically',
      'Balance detachment with empathy',
      'Engage with groups meaningfully',
      'Use innovation responsibly',
      'Avoid emotional avoidance',
      'Serve a collective purpose',
      'Maintain individual ethics',
      'Clarify ideals',
      'Stay mentally flexible',
      'Integrate logic with feeling',
    ],
    weaknessIndicators: [
      'Emotional detachment without clarity',
      'Feeling alienated or isolated',
      'Difficulty integrating into groups',
      'Over-intellectualization of emotions',
      'Fear of emotional intimacy',
      'Resistance to tradition without purpose',
      'Inconsistent ideals',
      'Detachment turning into escapism',
      'Feeling misunderstood',
      'Difficulty grounding abstract ideas',
    ],
    masterNote: 'Weak Aquarius = detachment without vision.',
    coreRule: 'Aquarius strengthens through purposeful detachment.',
  );

  // ============ PISCES ============
  static const _pisces = SignEducationData(
    id: 'pisces',
    name: 'Pisces',
    symbol: '♓',
    domain: 'Compassion · Intuition · Surrender',
    strengtheningTips: [
      'Ground intuition in reality',
      'Maintain clear boundaries',
      'Practice mindful compassion',
      'Avoid escapism',
      'Balance spirituality with duty',
      'Trust intuition with awareness',
      'Express empathy wisely',
      'Accept uncertainty calmly',
      'Serve without self-erasure',
      'Develop inner clarity',
    ],
    weaknessIndicators: [
      'Escapism tendencies',
      'Difficulty maintaining boundaries',
      'Emotional overwhelm',
      'Confusion about reality vs imagination',
      'Lack of grounding',
      'Over-sacrifice',
      'Difficulty making practical decisions',
      'Victim mentality',
      'Spiritual confusion',
      'Avoidance of responsibility',
    ],
    masterNote: 'Weak Pisces = sensitivity without grounding.',
    coreRule: 'Pisces strengthens through grounded compassion.',
  );

  /// Get sign data by ID
  static SignEducationData? getSign(String id) => signs[id.toLowerCase()];

  /// Master rule for all signs
  static const String masterRule = 
    'A zodiac sign is weak when its core energy is expressed through fear, '
    'avoidance, or imbalance instead of confidence and clarity.';
}
