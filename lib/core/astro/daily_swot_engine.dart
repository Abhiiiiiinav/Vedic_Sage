/// Daily SWOT Engine
///
/// Generates deterministic SWOT analysis from Panchang data:
/// - Strengths: Tithi + Vara alignment
/// - Weaknesses: Nakshatra sensitivities
/// - Opportunities: Yoga + Karana favorable actions
/// - Threats: Friction patterns
///
/// Also generates 2 micro-actions (5-10 min tasks) aligned with the day.

import '../models/cosmic_pet_models.dart';

class DailySWOTEngine {
  /// Generate daily SWOT from Panchang data
  ///
  /// [panchangData] is from PanchangService.getLocalPanchang():
  ///   - 'tithi': Map with 'name', 'number', 'paksha'
  ///   - 'nakshatra': Map with 'name', 'lord'
  ///   - 'yoga': Map with 'name', 'number'
  ///   - 'karana': Map with 'name'
  ///   - 'vara': String (weekday)
  ///   - 'varaLord': String (ruling planet)
  static DailySWOT generateSWOT(Map<String, dynamic> panchangData) {
    final date = DateTime.now();

    final tithi = panchangData['tithi'] as Map<String, dynamic>?;
    final nakshatra = panchangData['nakshatra'] as Map<String, dynamic>?;
    final yoga = panchangData['yoga'] as Map<String, dynamic>?;
    final karana = panchangData['karana'] as Map<String, dynamic>?;
    final varaLord = panchangData['varaLord'] as String? ?? 'Sun';

    // Generate each quadrant
    final strengths = _generateStrengths(tithi, varaLord);
    final weaknesses = _generateWeaknesses(nakshatra);
    final opportunities = _generateOpportunities(yoga, karana);
    final threats = _generateThreats(tithi, nakshatra, yoga);

    return DailySWOT(
      strengths: strengths,
      weaknesses: weaknesses,
      opportunities: opportunities,
      threats: threats,
      date: date,
    );
  }

  /// Generate 2 micro-actions from today's Panchang
  static List<MicroAction> generateMicroActions(
      Map<String, dynamic> panchangData) {
    final actions = <MicroAction>[];
    final tithi = panchangData['tithi'] as Map<String, dynamic>?;
    final nakshatra = panchangData['nakshatra'] as Map<String, dynamic>?;

    final tithiName = tithi?['name'] as String? ?? '';
    final nakshatraName = nakshatra?['name'] as String? ?? '';

    // Action 1: from Tithi
    final tithiAction = _tithiMicroAction(tithiName);
    actions.add(MicroAction(
      id: 'tithi_${DateTime.now().day}',
      title: tithiAction.title,
      description: tithiAction.description,
      source: 'Tithi: $tithiName',
      xpReward: 15,
    ));

    // Action 2: from Nakshatra
    final nakAction = _nakshatraMicroAction(nakshatraName);
    actions.add(MicroAction(
      id: 'nak_${DateTime.now().day}',
      title: nakAction.title,
      description: nakAction.description,
      source: 'Nakshatra: $nakshatraName',
      xpReward: 15,
    ));

    return actions;
  }

  // ════════════════════════════════════════════════════════════
  // STRENGTHS (Tithi + Vara)
  // ════════════════════════════════════════════════════════════

  static List<SWOTItem> _generateStrengths(
      Map<String, dynamic>? tithi, String varaLord) {
    final items = <SWOTItem>[];
    final tithiName = (tithi?['name'] as String? ?? '').toLowerCase();
    final paksha = (tithi?['paksha'] as String? ?? '').toLowerCase();

    // Tithi-based strength
    if (paksha.contains('shukla') || paksha.contains('waxing')) {
      items.add(const SWOTItem(
        text:
            'Growing lunar energy supports new initiatives and building momentum.',
        source: 'Shukla Paksha (Waxing Moon)',
        sourceEmoji: '🌓',
      ));
    } else {
      items.add(const SWOTItem(
        text:
            'Waning energy supports letting go, decluttering, and releasing what no longer serves.',
        source: 'Krishna Paksha (Waning Moon)',
        sourceEmoji: '🌗',
      ));
    }

    // Tithi-specific strengths
    final tithiStrength = _tithiStrength(tithiName);
    if (tithiStrength != null) {
      items.add(SWOTItem(
        text: tithiStrength,
        source: 'Tithi: ${tithi?['name'] ?? 'Unknown'}',
        sourceEmoji: '🌙',
      ));
    }

    // Vara-based strength
    items.add(SWOTItem(
      text: _varaStrength(varaLord),
      source: 'Day Ruler: $varaLord',
      sourceEmoji: '📅',
    ));

    return items;
  }

  static String? _tithiStrength(String tithiLower) {
    if (tithiLower.contains('pratipada')) {
      return 'Perfect for launching small projects — fresh start energy.';
    }
    if (tithiLower.contains('panchami')) {
      return 'Learning and creative energy is at its peak today.';
    }
    if (tithiLower.contains('dashami')) {
      return 'Strong execution energy — finish what you started.';
    }
    if (tithiLower.contains('ekadashi')) {
      return 'Mental clarity is heightened — ideal for focused thinking.';
    }
    if (tithiLower.contains('purnima')) {
      return 'Full moon amplifies insight — reflect on progress.';
    }
    if (tithiLower.contains('saptami')) {
      return 'Leadership energy flows naturally — take initiative.';
    }
    return null;
  }

  static String _varaStrength(String varaLord) {
    switch (varaLord) {
      case 'Sun':
        return 'Confidence and authority come naturally today.';
      case 'Moon':
        return 'Emotional intelligence is your hidden advantage.';
      case 'Mars':
        return 'Physical energy and courage are amplified.';
      case 'Mercury':
        return 'Communication and analytical thinking are sharp.';
      case 'Jupiter':
        return 'Wisdom and generosity attract good outcomes.';
      case 'Venus':
        return 'Aesthetic sense and diplomacy are strengths today.';
      case 'Saturn':
        return 'Patience and structured effort yield results.';
      default:
        return 'Today\'s energy supports steady progress.';
    }
  }

  // ════════════════════════════════════════════════════════════
  // WEAKNESSES (Nakshatra sensitivities)
  // ════════════════════════════════════════════════════════════

  static List<SWOTItem> _generateWeaknesses(Map<String, dynamic>? nakshatra) {
    final items = <SWOTItem>[];
    final name = nakshatra?['name'] as String? ?? '';

    final weakness = _nakshatraWeakness(name);
    items.add(SWOTItem(
      text: weakness,
      source: 'Nakshatra: $name',
      sourceEmoji: '⭐',
    ));

    return items;
  }

  static String _nakshatraWeakness(String name) {
    const weaknesses = {
      'Ashwini': 'May act too hastily — pause before big decisions.',
      'Bharani': 'Tendency to overcommit — be selective with energy.',
      'Krittika': 'Sharp words possible — choose communication carefully.',
      'Rohini': 'Risk of overindulgence — moderation is key.',
      'Mrigashira': 'Restless mind — avoid starting too many things.',
      'Ardra': 'Emotional sensitivity heightened — watch for reactivity.',
      'Punarvasu': 'May lack follow-through — commit to one thing.',
      'Pushya': 'Over-nurturing others at own expense — set boundaries.',
      'Ashlesha': 'Suspicion may cloud judgment — trust the process.',
      'Magha': 'Ego may block collaboration — stay humble.',
      'Purva Phalguni': 'Pleasure-seeking may distract from goals.',
      'Uttara Phalguni': 'Rigidity in plans — stay flexible.',
      'Hasta': 'Perfectionism may slow progress — done > perfect.',
      'Chitra': 'Focus on appearance over substance — go deeper.',
      'Swati': 'Indecisiveness possible — pick a direction.',
      'Vishakha': 'Tunnel vision — don\'t forget the bigger picture.',
      'Anuradha': 'People-pleasing tendency — protect your needs.',
      'Jyeshtha': 'Control tendencies — delegate more.',
      'Mula': 'Over-analyzing root causes — don\'t get stuck.',
      'Purva Ashadha': 'Overconfidence — double-check assumptions.',
      'Uttara Ashadha': 'Stubbornness — listen to alternatives.',
      'Shravana': 'Information overload — filter what matters.',
      'Dhanishta': 'Group pressure may influence judgment.',
      'Shatabhisha': 'Isolation tendency — reach out to someone.',
      'Purva Bhadrapada': 'Impractical idealism — ground your plans.',
      'Uttara Bhadrapada': 'Over-seriousness — allow some lightness.',
      'Revati': 'Over-empathy may drain energy — protect your space.',
    };
    return weaknesses[name] ??
        'Be mindful of energy levels and emotional balance.';
  }

  // ════════════════════════════════════════════════════════════
  // OPPORTUNITIES (Yoga + Karana)
  // ════════════════════════════════════════════════════════════

  static List<SWOTItem> _generateOpportunities(
      Map<String, dynamic>? yoga, Map<String, dynamic>? karana) {
    final items = <SWOTItem>[];

    // Yoga-based opportunity
    final yogaName = yoga?['name'] as String? ?? '';
    if (yogaName.isNotEmpty) {
      items.add(SWOTItem(
        text: _yogaOpportunity(yogaName),
        source: 'Yoga: $yogaName',
        sourceEmoji: '🧘',
      ));
    }

    // Karana-based opportunity
    final karanaName = karana?['name'] as String? ?? '';
    if (karanaName.isNotEmpty) {
      items.add(SWOTItem(
        text: _karanaOpportunity(karanaName),
        source: 'Karana: $karanaName',
        sourceEmoji: '⚡',
      ));
    }

    return items;
  }

  static String _yogaOpportunity(String yogaName) {
    const opportunities = {
      'Vishkambha': 'Overcoming obstacles — push through barriers today.',
      'Preeti': 'Favorable for relationships and pleasant interactions.',
      'Ayushman': 'Health and vitality are supported — start wellness habits.',
      'Saubhagya': 'Good fortune energy — take advantage of opportunities.',
      'Shobhana': 'Excellent for artistic and creative projects.',
      'Atiganda': 'Problem-solving skills are enhanced today.',
      'Sukarman': 'Great for starting good deeds and charitable acts.',
      'Dhriti': 'Determination and willpower are strong — commit.',
      'Shoola': 'Good for clearing pain points — face discomfort.',
      'Ganda': 'Knot-cutting energy — resolve complex situations.',
      'Vriddhi': 'Growth and expansion — plant seeds for the future.',
      'Dhruva': 'Stability and permanence — make lasting decisions.',
      'Vyaghata': 'Breaking patterns — end unhealthy cycles.',
      'Harshana': 'Joy and celebration — share good news.',
      'Vajra': 'Diamond-like strength — tackle hard problems.',
      'Siddhi': 'Accomplishment energy — complete important tasks.',
      'Vyatipata': 'Caution needed, but good for inner transformation.',
      'Variyan': 'Comfort and ease — enjoy earned rest.',
      'Parigha': 'Remove obstacles through persistent effort.',
      'Shiva': 'Auspicious for spiritual practices and meditation.',
      'Siddha': 'Success is favored — act on important goals.',
      'Sadhya': 'Achievable outcomes — set realistic targets.',
      'Shubha': 'Auspicious for new beginnings and fresh starts.',
      'Shukla': 'Purity and clarity — simplify complex matters.',
      'Brahma': 'Knowledge expansion — study and learn deeply.',
      'Indra': 'Authority and influence are enhanced — lead.',
      'Vaidhriti': 'Challenge yourself — grow through difficulty.',
    };
    return opportunities[yogaName] ??
        'Today\'s cosmic yoga supports focused effort.';
  }

  static String _karanaOpportunity(String karanaName) {
    const opportunities = {
      'Bava': 'Good for starting ventures and new projects.',
      'Balava': 'Favorable for education and skill building.',
      'Kaulava': 'Ideal for building friendships and alliances.',
      'Taitila': 'Good for stability and securing resources.',
      'Gara': 'Farming, gardening, and nurturing efforts thrive.',
      'Vanija': 'Excellent for trade, negotiation, and exchange.',
      'Vishti': 'Take it slow — avoid impulsive starts.',
      'Shakuni': 'Good for strategic planning and foresight.',
      'Chatushpada': 'Grounding energy — focus on foundations.',
      'Naga': 'Transformation energy — embrace change.',
      'Kimstughna': 'Neutral — maintain steady effort.',
    };
    return opportunities[karanaName] ??
        'Steady action aligned with today\'s energy yields results.';
  }

  // ════════════════════════════════════════════════════════════
  // THREATS (Friction patterns)
  // ════════════════════════════════════════════════════════════

  static List<SWOTItem> _generateThreats(
    Map<String, dynamic>? tithi,
    Map<String, dynamic>? nakshatra,
    Map<String, dynamic>? yoga,
  ) {
    final items = <SWOTItem>[];

    // Tithi-based threat (certain tithis are traditionally cautious)
    final tithiName = (tithi?['name'] as String? ?? '').toLowerCase();
    if (tithiName.contains('ashtami') || tithiName.contains('chaturdashi')) {
      items.add(SWOTItem(
        text: 'Intense energy today — avoid impulsive confrontations.',
        source: 'Tithi: ${tithi?['name']}',
        sourceEmoji: '⚠️',
      ));
    }
    if (tithiName.contains('amavasya')) {
      items.add(SWOTItem(
        text: 'Low visibility energy — not ideal for major launches.',
        source: 'Tithi: Amavasya',
        sourceEmoji: '🌑',
      ));
    }

    // Yoga-based threat
    final yogaName = yoga?['name'] as String? ?? '';
    if (_isCautionYoga(yogaName)) {
      items.add(SWOTItem(
        text: _cautionYogaMessage(yogaName),
        source: 'Yoga: $yogaName',
        sourceEmoji: '🧘',
      ));
    }

    // Nakshatra-based threat (some nakshatras have challenging qualities)
    final nakName = nakshatra?['name'] as String? ?? '';
    final nakThreat = _nakshatraThreat(nakName);
    if (nakThreat != null) {
      items.add(SWOTItem(
        text: nakThreat,
        source: 'Nakshatra: $nakName',
        sourceEmoji: '⭐',
      ));
    }

    // If no specific threats, add a gentle default
    if (items.isEmpty) {
      items.add(const SWOTItem(
        text:
            'No major friction patterns today — stay mindful of overcommitment.',
        source: 'General Guidance',
        sourceEmoji: '✅',
      ));
    }

    return items;
  }

  static bool _isCautionYoga(String yogaName) {
    return [
      'Vyatipata',
      'Vaidhriti',
      'Shoola',
      'Ganda',
      'Atiganda',
      'Vyaghata',
      'Parigha'
    ].contains(yogaName);
  }

  static String _cautionYogaMessage(String yogaName) {
    switch (yogaName) {
      case 'Vyatipata':
        return 'Avoid impulsive decisions — think before you act.';
      case 'Vaidhriti':
        return 'Caution with commitments — don\'t overextend.';
      case 'Shoola':
        return 'Potential for sharp words or pain — choose gentleness.';
      case 'Ganda':
        return 'Knots and complications — approach problems patiently.';
      case 'Atiganda':
        return 'Excess energy — channel it constructively.';
      case 'Vyaghata':
        return 'Destructive tendencies — redirect to creative breakdown.';
      case 'Parigha':
        return 'Obstacles may feel stronger — persist gently.';
      default:
        return 'Navigate today\'s energy with awareness.';
    }
  }

  static String? _nakshatraThreat(String name) {
    const threats = {
      'Ardra': 'Storm energy — emotional outbursts possible if unchecked.',
      'Ashlesha': 'Manipulation risks — stay authentic in interactions.',
      'Mula': 'Upheaval energy — avoid uprooting what\'s working.',
      'Jyeshtha': 'Power struggles possible — choose your battles.',
      'Purva Bhadrapada':
          'Extreme thinking — balance idealism with pragmatism.',
    };
    return threats[name];
  }

  // ════════════════════════════════════════════════════════════
  // MICRO-ACTIONS (Tithi + Nakshatra mapped)
  // ════════════════════════════════════════════════════════════

  static _ActionTemplate _tithiMicroAction(String tithiName) {
    final lower = tithiName.toLowerCase();

    if (lower.contains('pratipada')) {
      return const _ActionTemplate('Start One Small Task',
          'Write down one goal for the week and take a tiny first step. (5 min)');
    }
    if (lower.contains('dwitiya')) {
      return const _ActionTemplate('Resource Check',
          'Review your to-do list and prioritize the top 3 items. (5 min)');
    }
    if (lower.contains('tritiya')) {
      return const _ActionTemplate('Learn Something New',
          'Read one article or watch one short video on a topic you\'re curious about. (10 min)');
    }
    if (lower.contains('chaturthi')) {
      return const _ActionTemplate('Remove a Blocker',
          'Identify one thing blocking your progress and take action to address it. (5 min)');
    }
    if (lower.contains('panchami')) {
      return const _ActionTemplate('Creative Warm-Up',
          'Sketch, doodle, or write freely for 5 minutes without judgment.');
    }
    if (lower.contains('shashthi')) {
      return const _ActionTemplate('Body Check-In',
          'Do a 5-minute stretch or walk. Notice how your body feels.');
    }
    if (lower.contains('saptami')) {
      return const _ActionTemplate('Take the Lead',
          'Reach out to someone about a project or idea you believe in. (5 min)');
    }
    if (lower.contains('ashtami')) {
      return const _ActionTemplate('Shadow Journaling',
          'Write about one thing that frustrated you recently. What does it reveal? (5 min)');
    }
    if (lower.contains('navami')) {
      return const _ActionTemplate('Courage Step',
          'Do one thing slightly outside your comfort zone today.');
    }
    if (lower.contains('dashami')) {
      return const _ActionTemplate('Complete One Pending Task',
          'Pick your oldest pending task and finish it. Progress over perfection.');
    }
    if (lower.contains('ekadashi')) {
      return const _ActionTemplate('Digital Detox',
          'Put your phone away for 30 minutes. Practice single-tasking.');
    }
    if (lower.contains('dwadashi')) {
      return const _ActionTemplate('Review & Celebrate',
          'List 3 things you accomplished this week. Appreciate your progress.');
    }
    if (lower.contains('trayodashi')) {
      return const _ActionTemplate('Polish Something',
          'Take one existing piece of work and refine it. (10 min)');
    }
    if (lower.contains('chaturdashi')) {
      return const _ActionTemplate('Closure Ritual',
          'Close one open loop — reply to a message, finish a note, clear a tab. (5 min)');
    }
    if (lower.contains('purnima')) {
      return const _ActionTemplate('Gratitude Reflection',
          'Write 3 things you\'re grateful for today. Let the full moon illuminate your wins.');
    }
    if (lower.contains('amavasya')) {
      return const _ActionTemplate('Gentle Reset',
          'Rest intentionally. Do nothing productive for 10 minutes — just breathe.');
    }

    return const _ActionTemplate('Mindful Moment',
        'Take 5 slow breaths. Set one intention for the rest of the day.');
  }

  static _ActionTemplate _nakshatraMicroAction(String nakshatraName) {
    const actions = {
      'Ashwini': _ActionTemplate('Quick Win',
          'Do the fastest task on your list — no overthinking. (5 min)'),
      'Bharani': _ActionTemplate(
          'End Something', 'Close one pending task you\'ve been avoiding.'),
      'Krittika': _ActionTemplate('Clean & Organize',
          'Tidy one small area — desk, folder, or inbox. (5 min)'),
      'Rohini': _ActionTemplate(
          'Nurture Growth', 'Water a plant or check on someone\'s well-being.'),
      'Mrigashira': _ActionTemplate('Explore Options',
          'Research one alternative approach to a current challenge.'),
      'Ardra': _ActionTemplate('Emotional Check-In',
          'Name your current emotion in one word. Write why. (5 min)'),
      'Punarvasu': _ActionTemplate('Try Again',
          'Revisit something you gave up on. Give it one more chance.'),
      'Pushya': _ActionTemplate('Nourish a Routine',
          'Commit to one healthy habit for today only — drink water, stretch, read.'),
      'Ashlesha': _ActionTemplate('Release a Pattern',
          'Identify one unhelpful habit and consciously skip it today.'),
      'Magha': _ActionTemplate('Honor Your Roots',
          'Call or message a family member or mentor. (5 min)'),
      'Purva Phalguni': _ActionTemplate('Creative Play',
          'Make something fun — draw, cook, build, compose. (10 min)'),
      'Uttara Phalguni': _ActionTemplate('Make a Commitment',
          'Promise yourself one thing you\'ll follow through on this week.'),
      'Hasta': _ActionTemplate('Craft with Hands',
          'Do one hands-on task: fix, build, cook, or create.'),
      'Chitra': _ActionTemplate('Redesign Something',
          'Improve the look of something — your notes, desk, wallpaper.'),
      'Swati': _ActionTemplate('Independent Choice',
          'Make one decision today without asking for others\' opinion.'),
      'Vishakha': _ActionTemplate('Focused Sprint',
          'Set a 10-minute timer and work on one thing with full focus.'),
      'Anuradha': _ActionTemplate('Collaborate',
          'Reach out to a friend or colleague about working on something together.'),
      'Jyeshtha': _ActionTemplate('Take Responsibility',
          'Own one thing you\'ve been deferring. Handle it now.'),
      'Mula': _ActionTemplate('Root Cause',
          'Pick one recurring problem and trace it to its root. (5 min)'),
      'Purva Ashadha': _ActionTemplate(
          'Set a Boundary', 'Say no to one low-priority request today.'),
      'Uttara Ashadha': _ActionTemplate('Long-Term Plan',
          'Write one sentence about where you want to be in 6 months.'),
      'Shravana': _ActionTemplate('Listen & Learn',
          'Listen to a podcast or read a blog post on something new. (10 min)'),
      'Dhanishta': _ActionTemplate('Team Effort',
          'Help someone else with their task today — no strings attached.'),
      'Shatabhisha': _ActionTemplate('Healing Pause',
          'Do a 5-minute breathing exercise or listen to calming music.'),
      'Purva Bhadrapada': _ActionTemplate(
          'Dream Big', 'Write one wild, ambitious idea — no filters. (5 min)'),
      'Uttara Bhadrapada': _ActionTemplate('Ground Yourself',
          'Sit quietly for 5 minutes. Feel your feet on the ground.'),
      'Revati': _ActionTemplate('Complete Something',
          'Finish one thing fully — a chapter, a task, a conversation.'),
    };

    return actions[nakshatraName] ??
        const _ActionTemplate('Mindful Action',
            'Choose one small aligned task and complete it with full attention.');
  }
}

/// Internal template for micro-actions
class _ActionTemplate {
  final String title;
  final String description;
  const _ActionTemplate(this.title, this.description);
}
