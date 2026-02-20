import 'package:flutter/material.dart';
import '../../../app/theme.dart';
import '../../../core/astro/kundali_engine.dart';
import '../../../core/services/panchang_service.dart';
import '../../../core/services/user_session.dart';
import '../../calculator/screens/birth_details_screen.dart';
import '../../../shared/widgets/section_card.dart';
import '../../../shared/widgets/astro_background.dart';

class DayAheadScreen extends StatefulWidget {
  const DayAheadScreen({super.key});

  @override
  State<DayAheadScreen> createState() => _DayAheadScreenState();
}

class _TransitInsight {
  final String planet;
  final String sign;
  final int house;
  final String effect;
  final Color color;

  const _TransitInsight({
    required this.planet,
    required this.sign,
    required this.house,
    required this.effect,
    required this.color,
  });
}

class _TaraInsight {
  final int tara;
  final String title;
  final String description;
  final Color color;

  const _TaraInsight({
    required this.tara,
    required this.title,
    required this.description,
    required this.color,
  });
}

class _DayAheadScreenState extends State<DayAheadScreen> {
  final UserSession _session = UserSession();

  DateTime _today = DateTime.now();
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic>? _panchang;
  Map<String, Map<String, dynamic>> _transitPlanets = {};

  double _latitude = 28.6139;
  double _longitude = 77.2090;
  double _timezone = 5.5;

  bool get _hasChart => _session.hasData && _session.birthChart != null;

  @override
  void initState() {
    super.initState();
    _loadDayData();
  }

  Future<void> _loadDayData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    _loadUserLocation();
    final nowForUser = _getCurrentUserDateTime();

    try {
      final localPanchang = PanchangService.getLocalPanchang(
        date: nowForUser,
        latitude: _latitude,
        longitude: _longitude,
        timezone: _timezone,
      );

      Map<String, dynamic> mergedPanchang = localPanchang;
      try {
        final apiPanchang = await PanchangService.fetchPanchang(
          date: nowForUser,
          latitude: _latitude,
          longitude: _longitude,
          timezone: _timezone,
        );
        mergedPanchang = {...apiPanchang, ...localPanchang};
      } catch (_) {
        mergedPanchang = localPanchang;
      }

      final transitResult = KundaliEngine.calculateChart(
        birthTime: nowForUser,
        latitude: _latitude,
        longitude: _longitude,
        timezoneOffset: _timezone,
      );

      final transitPlanets = <String, Map<String, dynamic>>{};
      transitResult.planets.forEach((planet, data) {
        transitPlanets[planet] = Map<String, dynamic>.from(data);
      });

      setState(() {
        _today = nowForUser;
        _panchang = mergedPanchang;
        _transitPlanets = transitPlanets;
        _isLoading = false;
      });
    } catch (_) {
      setState(() {
        _today = nowForUser;
        _errorMessage =
            'Unable to load all day-ahead signals. Showing fallback values.';
        _isLoading = false;
      });
    }
  }

  void _loadUserLocation() {
    if (_session.hasData && _session.birthDetails != null) {
      _latitude = _session.birthDetails!.latitude;
      _longitude = _session.birthDetails!.longitude;
      _timezone = _session.birthDetails!.timezoneOffset;
    }
  }

  DateTime _getCurrentUserDateTime() {
    final nowUtc = DateTime.now().toUtc();
    return nowUtc.add(Duration(minutes: (_timezone * 60).round()));
  }

  @override
  Widget build(BuildContext context) {
    return AstroBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('Your Day Ahead'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadDayData,
            ),
          ],
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AstroTheme.accentGold),
              )
            : ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _buildDateHeader(),
                  const SizedBox(height: 20),
                  if (_errorMessage != null) ...[
                    _buildErrorBanner(),
                    const SizedBox(height: 16),
                  ],
                  if (!_hasChart) ...[
                    _buildNoChartBanner(),
                    const SizedBox(height: 16),
                  ],
                  _buildDailySummary(),
                  const SizedBox(height: 16),
                  _buildPanchangCard(),
                  const SizedBox(height: 16),
                  _buildTransitsCard(),
                  const SizedBox(height: 16),
                  _buildPersonalizedGuidance(),
                  const SizedBox(height: 16),
                  _buildLuckyElements(),
                  const SizedBox(height: 40),
                ],
              ),
      ),
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.4)),
      ),
      child: Text(
        _errorMessage ?? '',
        style: AstroTheme.bodyMedium.copyWith(color: Colors.orange.shade200),
      ),
    );
  }

  Widget _buildNoChartBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AstroTheme.accentPurple.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AstroTheme.accentPurple.withOpacity(0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Generate your birth chart for fully personalized house-based transits.',
            style: AstroTheme.bodyMedium.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BirthDetailsScreen()),
              ).then((_) => _loadDayData());
            },
            icon: const Icon(Icons.calculate),
            label: const Text('CALCULATE CHART'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AstroTheme.accentGold,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateHeader() {
    final weekday = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ][_today.weekday - 1];
    final month = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ][_today.month - 1];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AstroTheme.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AstroTheme.accentPurple.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.wb_sunny, color: AstroTheme.accentGold, size: 48),
          const SizedBox(height: 12),
          Text(
            weekday,
            style: AstroTheme.headingMedium.copyWith(color: Colors.white70),
          ),
          Text(
            '${_today.day} $month ${_today.year}',
            style: AstroTheme.headingLarge,
          ),
        ],
      ),
    );
  }

  Widget _buildDailySummary() {
    final summary = _generateDailySummary();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AstroTheme.accentCyan.withOpacity(0.2),
            AstroTheme.accentPurple.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AstroTheme.accentCyan.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.auto_awesome, color: AstroTheme.accentCyan),
              SizedBox(width: 12),
              Text(
                'Your Personalized Day Ahead',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            summary,
            style: AstroTheme.bodyLarge.copyWith(height: 1.8, fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget _buildPanchangCard() {
    final tithiValue = _buildTithiText();
    final nakshatraValue = _buildNakshatraText();
    final yogaValue = _panchang?['yoga']?['name']?.toString() ?? '--';
    final karanaValue = _panchang?['karana']?['name']?.toString() ?? '--';
    final vara = _panchang?['vara']?.toString() ?? '--';
    final varaLord = _panchang?['varaLord']?.toString() ?? '--';
    final auspiciousTime =
        _formatTimeRange(_panchang?['abhijitMuhurta']) ?? '--';

    return SectionCard(
      title: 'Today\'s Panchang',
      icon: Icons.calendar_today,
      accentColor: AstroTheme.accentGold,
      child: Column(
        children: [
          _buildPanchangRow('Tithi', tithiValue, Icons.brightness_3),
          _buildPanchangRow('Nakshatra', nakshatraValue, Icons.stars),
          _buildPanchangRow('Yoga', yogaValue, Icons.self_improvement),
          _buildPanchangRow('Karana', karanaValue, Icons.category),
          _buildPanchangRow('Vara', '$vara ($varaLord)', Icons.wb_sunny),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF4caf50).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle,
                    color: Color(0xFF4caf50), size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Auspicious Time: $auspiciousTime',
                    style: const TextStyle(
                      color: Color(0xFF4caf50),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPanchangRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AstroTheme.accentGold),
          const SizedBox(width: 12),
          SizedBox(
            width: 90,
            child: Text(label, style: AstroTheme.labelText),
          ),
          Expanded(
            child: Text(
              value,
              style: AstroTheme.bodyLarge.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransitsCard() {
    final insights = _buildTransitInsights();

    return SectionCard(
      title: 'Current Planetary Transits',
      icon: Icons.track_changes,
      accentColor: AstroTheme.accentPurple,
      child: Column(
        children: insights.isEmpty
            ? [
                Text(
                  'Transit signals are loading. Pull to refresh in a moment.',
                  style: AstroTheme.bodyMedium,
                ),
              ]
            : insights
                .map(
                  (insight) => _buildTransitRow(
                    insight.planet,
                    '${insight.sign} (${_ordinal(insight.house)} house)',
                    insight.color,
                    insight.effect,
                  ),
                )
                .toList(),
      ),
    );
  }

  Widget _buildTransitRow(
      String planet, String position, Color color, String effect) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      planet[0],
                      style:
                          TextStyle(color: color, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(planet,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      Text(position,
                          style: AstroTheme.bodyMedium.copyWith(fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '-> $effect',
              style:
                  AstroTheme.bodyMedium.copyWith(fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalizedGuidance() {
    final guidance = _buildGuidance();

    return SectionCard(
      title: 'Personalized Guidance',
      icon: Icons.lightbulb,
      accentColor: const Color(0xFF4caf50),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGuidanceItem('DO', guidance['do']!, const Color(0xFF4caf50)),
          const SizedBox(height: 12),
          _buildGuidanceItem(
            'AVOID',
            guidance['avoid']!,
            const Color(0xFFff9800),
          ),
          const SizedBox(height: 12),
          _buildGuidanceItem(
              'FOCUS ON', guidance['focus']!, AstroTheme.accentCyan),
        ],
      ),
    );
  }

  Widget _buildGuidanceItem(String label, String text, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: color, fontSize: 14)),
          const SizedBox(height: 4),
          Text(text,
              style: AstroTheme.bodyMedium.copyWith(color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildLuckyElements() {
    final lucky = _buildLuckyValues();

    return SectionCard(
      title: 'Lucky Elements Today',
      icon: Icons.stars,
      accentColor: AstroTheme.accentGold,
      child: Row(
        children: [
          Expanded(
            child: _buildLuckyBox(
              'Color',
              lucky['color']!,
              _colorForLuckyName(lucky['color']!),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildLuckyBox(
                'Number', lucky['number']!, AstroTheme.accentGold),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildLuckyBox(
              'Direction',
              lucky['direction']!,
              AstroTheme.accentCyan,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLuckyBox(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(label, style: AstroTheme.labelText),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
                fontWeight: FontWeight.bold, color: color, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _buildTithiText() {
    final tithi = _panchang?['tithi'];
    if (tithi is Map<String, dynamic>) {
      final paksha = tithi['paksha']?.toString() ?? '';
      final name = tithi['name']?.toString() ?? '--';
      return '$paksha $name'.trim();
    }
    return '--';
  }

  String _buildNakshatraText() {
    final nak = _panchang?['nakshatra'];
    if (nak is Map<String, dynamic>) {
      final name = nak['name']?.toString() ?? '--';
      final pada = nak['pada']?.toString();
      return pada == null ? name : '$name (Pada $pada)';
    }
    return '--';
  }

  String? _formatTimeRange(dynamic value) {
    if (value is Map<String, dynamic>) {
      final start = value['start']?.toString();
      final end = value['end']?.toString();
      if (start != null && end != null) {
        return '$start - $end';
      }
    }
    return null;
  }

  String _generateDailySummary() {
    final tithiName = _panchang?['tithi']?['name']?.toString() ?? 'Unknown';
    final paksha = _panchang?['tithi']?['paksha']?.toString() ?? '';
    final nakshatra = _panchang?['nakshatra']?['name']?.toString() ?? 'Unknown';
    final auspiciousWindow =
        _formatTimeRange(_panchang?['abhijitMuhurta']) ?? 'not available';

    final moonTransit = _transitForPlanet('Moon');
    final mercuryTransit = _transitForPlanet('Mercury');
    final tara = _getTaraInsight();

    final moonLine = moonTransit == null
        ? 'The Moon transit data is currently limited.'
        : 'Moon is in ${moonTransit.sign}, activating your ${_ordinal(moonTransit.house)} house of ${_houseTheme(moonTransit.house)}.';

    final mercuryLine = mercuryTransit == null
        ? 'Communication patterns are neutral today.'
        : 'Mercury highlights your ${_ordinal(mercuryTransit.house)} house, so clear communication and quick decisions will help.';

    final personalizationLine = _hasChart
        ? '${tara.title}: ${tara.description}'
        : 'Generate your birth chart to map these transits to your personal houses.';

    return 'Tithi: $paksha $tithiName. Nakshatra: $nakshatra. '
        '$moonLine $mercuryLine '
        'Auspicious window: $auspiciousWindow. $personalizationLine';
  }

  List<_TransitInsight> _buildTransitInsights() {
    const order = [
      'Sun',
      'Moon',
      'Mercury',
      'Venus',
      'Mars',
      'Jupiter',
      'Saturn',
      'Rahu',
      'Ketu',
    ];

    final insights = <_TransitInsight>[];
    for (final planet in order) {
      final data = _transitPlanets[planet];
      if (data == null) continue;

      final sign =
          data['signName']?.toString() ?? data['sign']?.toString() ?? 'Unknown';
      final signIndex = (data['signIndex'] as int?) ?? _signIndexFromName(sign);
      final house = _hasChart
          ? _houseFromNatalAsc(signIndex)
          : (data['house'] as int? ?? 1);

      insights.add(
        _TransitInsight(
          planet: planet,
          sign: sign,
          house: house,
          effect: _buildTransitEffect(planet, house),
          color: AstroTheme.getPlanetColor(planet),
        ),
      );
    }
    return insights;
  }

  _TransitInsight? _transitForPlanet(String planet) {
    final all = _buildTransitInsights();
    for (final item in all) {
      if (item.planet == planet) return item;
    }
    return null;
  }

  int _houseFromNatalAsc(int transitSignIndex) {
    if (!_hasChart) return 1;
    final ascSignIndex = _resolveAscSignIndex(_session.birthChart!);
    return ((transitSignIndex - ascSignIndex + 12) % 12) + 1;
  }

  int _resolveAscSignIndex(Map<String, dynamic> chart) {
    final ascIndex = chart['ascSignIndex'];
    if (ascIndex is int) return ascIndex.clamp(0, 11);

    final ascSign = chart['ascSign']?.toString();
    if (ascSign != null) return _signIndexFromName(ascSign);
    return 0;
  }

  int _signIndexFromName(String sign) {
    const signs = [
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
    final idx = signs.indexWhere((s) => s.toLowerCase() == sign.toLowerCase());
    return idx == -1 ? 0 : idx;
  }

  String _buildTransitEffect(String planet, int house) {
    const houseThemes = {
      1: 'self, confidence, and direction',
      2: 'money, family, and speech',
      3: 'communication and initiatives',
      4: 'home and emotional stability',
      5: 'creativity and learning',
      6: 'work routines and health',
      7: 'partnerships and agreements',
      8: 'deep change and hidden matters',
      9: 'beliefs, mentors, and wisdom',
      10: 'career and public image',
      11: 'gains and networks',
      12: 'rest, release, and reflection',
    };

    const planetActions = {
      'Sun': 'Brings visibility to',
      'Moon': 'Creates emotional movement in',
      'Mercury': 'Improves thinking and planning for',
      'Venus': 'Adds harmony and attraction to',
      'Mars': 'Pushes direct action in',
      'Jupiter': 'Expands opportunity in',
      'Saturn': 'Demands discipline in',
      'Rahu': 'Amplifies ambition in',
      'Ketu': 'Detaches and clarifies',
    };

    return '${planetActions[planet] ?? 'Highlights'} '
        '${houseThemes[house] ?? 'key life themes'}.';
  }

  _TaraInsight _getTaraInsight() {
    if (!_hasChart) {
      return const _TaraInsight(
        tara: 0,
        title: 'General Day Flow',
        description: 'Use Panchang timing to structure key tasks.',
        color: Colors.cyan,
      );
    }

    final todayNakshatra = _panchang?['nakshatra']?['name']?.toString() ?? '';
    final userNakshatra = _getUserNakshatra(_session.birthChart!);
    if (todayNakshatra.isEmpty || userNakshatra.isEmpty) {
      return const _TaraInsight(
        tara: 0,
        title: 'Neutral Alignment',
        description: 'Proceed with steady effort and practical planning.',
        color: Colors.amber,
      );
    }

    final nakshatras = PanchangService.nakshatraNames;
    var userIndex = nakshatras.indexOf(userNakshatra);
    var todayIndex = nakshatras.indexOf(todayNakshatra);
    if (userIndex == -1) userIndex = 0;
    if (todayIndex == -1) todayIndex = 0;

    final tara = ((todayIndex - userIndex + 27) % 27) % 9 + 1;

    final taraMap = <int, _TaraInsight>{
      1: const _TaraInsight(
        tara: 1,
        title: 'Janma (Birth)',
        description: 'Good for routine work and emotional reset.',
        color: Colors.orange,
      ),
      2: const _TaraInsight(
        tara: 2,
        title: 'Sampat (Wealth)',
        description: 'Strong for financial and practical decisions.',
        color: Colors.green,
      ),
      3: const _TaraInsight(
        tara: 3,
        title: 'Vipat (Caution)',
        description: 'Avoid risky commitments and rushed decisions.',
        color: Colors.red,
      ),
      4: const _TaraInsight(
        tara: 4,
        title: 'Kshema (Well-being)',
        description: 'Supportive for healing, peace, and stability.',
        color: Colors.teal,
      ),
      5: const _TaraInsight(
        tara: 5,
        title: 'Pratyak (Obstacles)',
        description: 'Handle pending issues before new launches.',
        color: Colors.deepOrange,
      ),
      6: const _TaraInsight(
        tara: 6,
        title: 'Sadhana (Achievement)',
        description: 'High execution energy for goals and milestones.',
        color: Colors.amber,
      ),
      7: const _TaraInsight(
        tara: 7,
        title: 'Naidhana (Transformative)',
        description: 'Keep decisions conservative and introspective.',
        color: Colors.blueGrey,
      ),
      8: const _TaraInsight(
        tara: 8,
        title: 'Mitra (Friendly)',
        description: 'Good for teamwork, networking, and support.',
        color: Colors.blue,
      ),
      9: const _TaraInsight(
        tara: 9,
        title: 'Parama Mitra (Excellent)',
        description: 'One of the best alignments for key actions.',
        color: Colors.purple,
      ),
    };

    return taraMap[tara] ?? taraMap[1]!;
  }

  String _getUserNakshatra(Map<String, dynamic> chart) {
    final moonNakshatra = chart['moonNakshatraName']?.toString();
    if (moonNakshatra != null && moonNakshatra.isNotEmpty) return moonNakshatra;

    try {
      final positions = chart['planetPositions'] as Map<String, dynamic>?;
      final moon = positions?['Moon'] as Map<String, dynamic>?;
      final moonFromPosition = moon?['nakshatra']?.toString();
      if (moonFromPosition != null && moonFromPosition.isNotEmpty) {
        return moonFromPosition;
      }

      final moonLongitude = (moon?['longitude'] as num?)?.toDouble() ??
          (chart['planetDegrees']?['Moon'] as num?)?.toDouble();
      if (moonLongitude != null) {
        return _nakshatraFromLongitude(moonLongitude);
      }
    } catch (_) {
      return '';
    }
    return '';
  }

  String _nakshatraFromLongitude(double longitude) {
    final nakshatras = PanchangService.nakshatraNames;
    final index = ((longitude % 360) / (360 / 27)).floor();
    return nakshatras[index % 27];
  }

  Map<String, String> _buildGuidance() {
    final tara = _getTaraInsight();
    final varaLord = _panchang?['varaLord']?.toString() ?? 'Sun';
    final dominantHouse = _dominantHouse();

    final doText = _doByDayLord(varaLord);
    final avoidText = _avoidByTara(tara.tara);
    final focusText = _hasChart
        ? 'Focus on ${_houseTheme(dominantHouse)} and keep actions aligned with ${tara.title}.'
        : 'Focus on core responsibilities and use the auspicious window for key tasks.';

    return {
      'do': doText,
      'avoid': avoidText,
      'focus': focusText,
    };
  }

  String _doByDayLord(String dayLord) {
    const map = {
      'Sun': 'Take visible leadership actions and finish one high-impact task.',
      'Moon': 'Prioritize emotional balance and supportive conversations.',
      'Mars': 'Use focused physical and mental energy to complete hard tasks.',
      'Mercury': 'Handle communication, planning, and learning work first.',
      'Jupiter': 'Invest time in growth, teaching, or strategic decisions.',
      'Venus': 'Strengthen relationships and improve quality in your work.',
      'Saturn': 'Use discipline, structure, and patience to clear backlogs.',
    };
    return map[dayLord] ?? 'Act with clarity and steady execution.';
  }

  String _avoidByTara(int tara) {
    if ([3, 5, 7].contains(tara)) {
      return 'Avoid impulsive commitments, arguments, and high-risk decisions.';
    }
    if (tara == 1 || tara == 4) {
      return 'Avoid overloading your schedule; keep the day balanced.';
    }
    return 'Avoid distractions that pull attention away from your priorities.';
  }

  int _dominantHouse() {
    final insights = _buildTransitInsights();
    if (insights.isEmpty) return 1;

    final score = <int, int>{};
    const weights = {
      'Sun': 2,
      'Moon': 2,
      'Mercury': 1,
      'Venus': 1,
      'Mars': 1,
      'Jupiter': 2,
      'Saturn': 2,
      'Rahu': 1,
      'Ketu': 1,
    };

    for (final item in insights) {
      final weight = weights[item.planet] ?? 1;
      score[item.house] = (score[item.house] ?? 0) + weight;
    }

    var bestHouse = 1;
    var bestScore = -1;
    for (final entry in score.entries) {
      if (entry.value > bestScore) {
        bestScore = entry.value;
        bestHouse = entry.key;
      }
    }
    return bestHouse;
  }

  String _houseTheme(int house) {
    const themes = {
      1: 'self-direction and confidence',
      2: 'finances and values',
      3: 'communication and effort',
      4: 'home and emotional grounding',
      5: 'creativity and learning',
      6: 'work systems and health',
      7: 'relationships and agreements',
      8: 'transformation and depth',
      9: 'guidance and long-term vision',
      10: 'career and recognition',
      11: 'network, gains, and support',
      12: 'rest and inner clarity',
    };
    return themes[house] ?? 'core life priorities';
  }

  Map<String, String> _buildLuckyValues() {
    final varaLord = _panchang?['varaLord']?.toString() ?? 'Sun';
    final tithiNum = (_panchang?['tithi']?['number'] as int?) ?? 1;
    final moonHouse = _transitForPlanet('Moon')?.house ?? _dominantHouse();

    final colorMap = {
      'Sun': 'Amber',
      'Moon': 'Pearl White',
      'Mars': 'Red',
      'Mercury': 'Green',
      'Jupiter': 'Yellow',
      'Venus': 'Rose',
      'Saturn': 'Indigo',
    };

    final directionMap = {
      'Sun': 'East',
      'Moon': 'North-West',
      'Mars': 'South',
      'Mercury': 'North',
      'Jupiter': 'North-East',
      'Venus': 'South-East',
      'Saturn': 'West',
    };

    final luckyNumbers = <int>{
      tithiNum,
      moonHouse,
      ((tithiNum + moonHouse) % 9) + 1,
    }.toList()
      ..sort();

    return {
      'color': colorMap[varaLord] ?? 'Gold',
      'number': luckyNumbers.join(', '),
      'direction': directionMap[varaLord] ?? 'East',
    };
  }

  Color _colorForLuckyName(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'amber':
      case 'yellow':
        return AstroTheme.accentGold;
      case 'pearl white':
        return AstroTheme.moonColor;
      case 'red':
        return AstroTheme.marsColor;
      case 'green':
        return AstroTheme.mercuryColor;
      case 'rose':
        return AstroTheme.venusColor;
      case 'indigo':
        return AstroTheme.saturnColor;
      default:
        return AstroTheme.accentCyan;
    }
  }

  String _ordinal(int number) {
    if (number >= 11 && number <= 13) return '${number}th';
    switch (number % 10) {
      case 1:
        return '${number}st';
      case 2:
        return '${number}nd';
      case 3:
        return '${number}rd';
      default:
        return '${number}th';
    }
  }
}
