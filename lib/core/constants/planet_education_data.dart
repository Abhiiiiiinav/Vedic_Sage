/// Comprehensive Planet Data with Strengthening Tips and Weakness Indicators
/// Based on professional Vedic astrology knowledge (20+ years experience)
/// 
/// Core Rule: A planet is strengthened when its core principle is lived consciously.

class PlanetEducationData {
  final String abbrev;
  final String name;
  final String symbol;
  final String domain;
  final List<String> strengtheningTips;
  final List<String> weaknessIndicators;
  final String masterNote;
  final String coreRule;

  const PlanetEducationData({
    required this.abbrev,
    required this.name,
    required this.symbol,
    required this.domain,
    required this.strengtheningTips,
    required this.weaknessIndicators,
    required this.masterNote,
    required this.coreRule,
  });

  static const Map<String, PlanetEducationData> planets = {
    'Su': _sun,
    'Mo': _moon,
    'Ma': _mars,
    'Me': _mercury,
    'Ju': _jupiter,
    'Ve': _venus,
    'Sa': _saturn,
    'Ra': _rahu,
    'Ke': _ketu,
  };

  // ============ SUN ============
  static const _sun = PlanetEducationData(
    abbrev: 'Su',
    name: 'Sun',
    symbol: '☀️',
    domain: 'Confidence · Authority · Purpose · Vitality',
    strengtheningTips: [
      'Wake up early and consistently (before sunrise if possible)',
      'Take responsibility instead of avoiding leadership',
      'Maintain self-respect, even in small decisions',
      'Speak the truth clearly, without aggression',
      'Respect father, mentors, and authority figures',
      'Get daily sunlight exposure',
      'Set a clear life direction and stick to it',
      'Avoid self-pity and victim mindset',
      'Practice standing tall (posture matters)',
      'Do work that gives visible contribution',
    ],
    weaknessIndicators: [
      'Chronic lack of self-confidence despite competence',
      'Difficulty asserting authority or taking leadership roles',
      'Fear of visibility, spotlight, or responsibility',
      'Strained or distant relationship with father/authority figures',
      'Low vitality, frequent exhaustion without medical cause',
      'Overdependence on validation from others',
      'Ego wounds, humiliation sensitivity, or pride collapse',
      'Inconsistent life direction or weak sense of purpose',
      'Difficulty making decisive choices',
      'Repeated issues with reputation or public image',
    ],
    masterNote: 'A weak Sun does not mean lack of talent — it means identity is not integrated.',
    coreRule: 'Sun strengthens when identity is owned.',
  );

  // ============ MOON ============
  static const _moon = PlanetEducationData(
    abbrev: 'Mo',
    name: 'Moon',
    symbol: '🌙',
    domain: 'Emotions · Mind · Peace · Adaptability',
    strengtheningTips: [
      'Maintain a stable daily routine (sleep, meals)',
      'Practice emotional awareness instead of suppression',
      'Spend time near water or nature',
      'Care for mother / maternal figures',
      'Journal or talk about feelings regularly',
      'Avoid emotional overreaction',
      'Create a safe, calm home environment',
      'Practice gratitude daily',
      'Reduce mental overstimulation at night',
      'Eat warm, nourishing food',
    ],
    weaknessIndicators: [
      'Emotional instability or frequent mood swings',
      'Difficulty feeling emotionally safe or settled',
      'Overthinking, anxiety, or mental restlessness',
      'Attachment issues or fear of abandonment',
      'Sleep disturbances or irregular routines',
      'Emotional dependence on others\' approval',
      'Difficulty nurturing self or others',
      'Poor memory retention under stress',
      'Discomfort with change or uncertainty',
      'Strained bond with mother or maternal figures',
    ],
    masterNote: 'A weak Moon shows emotional processing issues, not weakness of character.',
    coreRule: 'Moon strengthens through emotional safety.',
  );

  // ============ MARS ============
  static const _mars = PlanetEducationData(
    abbrev: 'Ma',
    name: 'Mars',
    symbol: '♂️',
    domain: 'Energy · Courage · Action · Boundaries',
    strengtheningTips: [
      'Engage in physical exercise regularly',
      'Take initiative even when afraid',
      'Practice saying "no" clearly',
      'Channel anger into action, not suppression',
      'Finish what you start',
      'Stand up for yourself respectfully',
      'Take calculated risks',
      'Maintain discipline in body and habits',
      'Protect the weak instead of fighting them',
      'Avoid passive-aggressiveness',
    ],
    weaknessIndicators: [
      'Low physical drive or chronic lethargy',
      'Avoidance of confrontation even when necessary',
      'Suppressed anger or passive-aggressive behavior',
      'Fear of taking initiative or risks',
      'Difficulty setting or defending boundaries',
      'Poor follow-through despite motivation',
      'Lack of competitive spirit',
      'Indecisiveness in action-oriented situations',
      'Physical weakness or recurring inflammations',
      'Issues with younger siblings or teamwork conflicts',
    ],
    masterNote: 'Weak Mars shows blocked assertive energy, not lack of ambition.',
    coreRule: 'Mars strengthens through decisive action.',
  );

  // ============ MERCURY ============
  static const _mercury = PlanetEducationData(
    abbrev: 'Me',
    name: 'Mercury',
    symbol: '☿',
    domain: 'Intellect · Communication · Learning · Adaptability',
    strengtheningTips: [
      'Practice clear communication (speaking & writing)',
      'Learn continuously, even in small doses',
      'Teach or explain concepts to others',
      'Avoid overthinking; simplify thoughts',
      'Keep curiosity alive',
      'Improve listening skills',
      'Maintain honesty in communication',
      'Read daily (any subject)',
      'Reduce mental clutter',
      'Adapt instead of resisting change',
    ],
    weaknessIndicators: [
      'Difficulty articulating thoughts clearly',
      'Confusion while explaining known concepts',
      'Nervousness during communication or interviews',
      'Poor short-term memory recall',
      'Overthinking simple matters',
      'Difficulty learning new skills efficiently',
      'Frequent misunderstandings with others',
      'Inconsistent focus or scattered thinking',
      'Lack of confidence in analytical ability',
      'Trouble adapting to changing environments',
    ],
    masterNote: 'Weak Mercury shows poor signal clarity, not low intelligence.',
    coreRule: 'Mercury strengthens through clarity and curiosity.',
  );

  // ============ JUPITER ============
  static const _jupiter = PlanetEducationData(
    abbrev: 'Ju',
    name: 'Jupiter',
    symbol: '♃',
    domain: 'Wisdom · Growth · Faith · Protection',
    strengtheningTips: [
      'Respect teachers, elders, and guides',
      'Study philosophy, ethics, or higher knowledge',
      'Practice generosity without expectation',
      'Keep promises and moral commitments',
      'Mentor or guide someone',
      'Avoid arrogance disguised as intelligence',
      'Maintain faith during setbacks',
      'Think long-term, not short-term',
      'Eat moderately and consciously',
      'Align actions with values',
    ],
    weaknessIndicators: [
      'Loss of faith in self, life, or future',
      'Poor guidance from mentors or elders',
      'Difficulty making ethical decisions',
      'Narrow or pessimistic worldview',
      'Repeated disappointments despite effort',
      'Over-reliance on luck instead of wisdom',
      'Difficulty sustaining long-term growth',
      'Weak moral compass under pressure',
      'Financial instability despite opportunities',
      'Struggles in higher education or teaching roles',
    ],
    masterNote: 'Weak Jupiter indicates misalignment with wisdom, not lack of intelligence.',
    coreRule: 'Jupiter strengthens through wisdom and integrity.',
  );

  // ============ VENUS ============
  static const _venus = PlanetEducationData(
    abbrev: 'Ve',
    name: 'Venus',
    symbol: '♀️',
    domain: 'Love · Harmony · Pleasure · Value',
    strengtheningTips: [
      'Practice self-worth and self-care',
      'Maintain balance in relationships',
      'Enjoy art, music, or beauty consciously',
      'Avoid toxic or draining relationships',
      'Practice kindness without dependency',
      'Keep surroundings clean and pleasant',
      'Express affection honestly',
      'Spend money wisely, not impulsively',
      'Cultivate gratitude for pleasures',
      'Learn to receive, not just give',
    ],
    weaknessIndicators: [
      'Repeated relationship dissatisfaction',
      'Difficulty experiencing joy or pleasure',
      'Poor self-worth or self-valuation',
      'Lack of emotional or romantic fulfillment',
      'Creative blocks or loss of aesthetic sense',
      'Over-sacrifice in relationships',
      'Attracting unbalanced or draining partners',
      'Financial instability linked to indulgence',
      'Discomfort with intimacy or affection',
      'Inability to relax or enjoy life',
    ],
    masterNote: 'Weak Venus reflects distorted value systems, not lack of love.',
    coreRule: 'Venus strengthens through healthy enjoyment.',
  );

  // ============ SATURN ============
  static const _saturn = PlanetEducationData(
    abbrev: 'Sa',
    name: 'Saturn',
    symbol: '♄',
    domain: 'Discipline · Responsibility · Endurance · Karma',
    strengtheningTips: [
      'Maintain consistent routines',
      'Accept responsibility instead of avoiding it',
      'Practice patience during delays',
      'Work honestly, even when unnoticed',
      'Serve without complaint',
      'Respect time and deadlines',
      'Simplify life; avoid excess',
      'Face fears gradually, not suddenly',
      'Support the underprivileged',
      'Stay committed during hardship',
    ],
    weaknessIndicators: [
      'Fear of responsibility or commitment',
      'Chronic procrastination',
      'Difficulty maintaining routines',
      'Avoidance of long-term planning',
      'Feeling overwhelmed by duties',
      'Poor time management',
      'Lack of patience under pressure',
      'Repeated failures due to inconsistency',
      'Resistance to discipline or structure',
      'Fear of authority, rules, or accountability',
    ],
    masterNote: 'Weak Saturn causes collapse under pressure, not lack of ability.',
    coreRule: 'Saturn strengthens through discipline and humility.',
  );

  // ============ RAHU ============
  static const _rahu = PlanetEducationData(
    abbrev: 'Ra',
    name: 'Rahu',
    symbol: '☊',
    domain: 'Ambition · Innovation · Growth · Desire',
    strengtheningTips: [
      'Embrace change instead of fearing it',
      'Learn new technologies or skills',
      'Step outside comfort zone regularly',
      'Channel ambition constructively',
      'Avoid obsession or shortcuts',
      'Think differently but responsibly',
      'Break limiting beliefs consciously',
      'Work with diverse people',
      'Be aware of desires, not controlled by them',
      'Seek growth, not chaos',
    ],
    weaknessIndicators: [
      'Lack of ambition or drive for growth',
      'Fear of stepping outside comfort zone',
      'Resistance to change or unconventional paths',
      'Difficulty embracing technology or new ideas',
      'Low appetite for achievement',
      'Over-attachment to past patterns',
      'Missed opportunities due to hesitation',
      'Inability to take calculated risks',
      'Suppressed desires leading to frustration',
      'Fear of public exposure or success',
    ],
    masterNote: 'Weak Rahu shows blocked evolution, not purity.',
    coreRule: 'Rahu strengthens through conscious evolution.',
  );

  // ============ KETU ============
  static const _ketu = PlanetEducationData(
    abbrev: 'Ke',
    name: 'Ketu',
    symbol: '☋',
    domain: 'Detachment · Insight · Spiritual Intelligence',
    strengtheningTips: [
      'Practice mindfulness or meditation',
      'Spend time in silence regularly',
      'Let go of unnecessary attachments',
      'Trust intuition, but verify with reason',
      'Avoid escapism',
      'Study spiritual or inner sciences',
      'Serve without seeking recognition',
      'Accept uncertainty gracefully',
      'Balance detachment with responsibility',
      'Seek meaning beyond material success',
    ],
    weaknessIndicators: [
      'Spiritual confusion or aimlessness',
      'Feeling disconnected without clarity',
      'Lack of inner peace despite detachment',
      'Difficulty trusting intuition',
      'Escapism without understanding',
      'Fear of solitude or silence',
      'Loss of meaning or direction',
      'Inability to integrate past experiences',
      'Spiritual pride without grounding',
      'Detachment that leads to withdrawal, not wisdom',
    ],
    masterNote: 'Weak Ketu creates confusion, not enlightenment.',
    coreRule: 'Ketu strengthens through awareness and balance.',
  );

  /// Get planet data by abbreviation
  static PlanetEducationData? getPlanet(String abbrev) => planets[abbrev];

  /// Master rule for all planets
  static const String masterRule = 
    'A planet is strengthened when its core principle is lived consciously, '
    'not when it is feared or suppressed. '
    'Weakness ≠ bad fate. Weakness = area requiring awareness and conscious development.';
}
