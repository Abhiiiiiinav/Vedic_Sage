import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../app/theme.dart';
import '../../../shared/widgets/astro_background.dart';
import '../../../shared/widgets/astro_card.dart';
import '../../../shared/widgets/section_card.dart';
import '../../../core/services/panchang_service.dart';
import '../../../core/services/user_session.dart';
import '../../../core/constants/astro_data.dart';
import '../../calculator/screens/birth_details_screen.dart';

class PanchangScreen extends StatefulWidget {
  const PanchangScreen({super.key});

  @override
  State<PanchangScreen> createState() => _PanchangScreenState();
}

class _PanchangScreenState extends State<PanchangScreen> with SingleTickerProviderStateMixin {
  DateTime _selectedDate = DateTime.now();
  Map<String, dynamic>? _panchang;
  bool _isLoading = true;
  String? _errorMessage;
  
  // User Session for chart data
  final UserSession _session = UserSession();
  
  // Tab controller for switching between general and personalized views
  late TabController _tabController;
  
  // Default to Delhi coordinates
  double _latitude = 28.6139;
  double _longitude = 77.2090;
  double _timezone = 5.5;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUserLocation();
    _fetchPanchang();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadUserLocation() {
    final session = UserSession();
    if (session.hasData && session.birthDetails != null) {
      setState(() {
        _latitude = session.birthDetails!.latitude;
        _longitude = session.birthDetails!.longitude;
        _timezone = session.birthDetails!.timezoneOffset;
      });
    }
  }

  Future<void> _fetchPanchang() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Try API first
      final apiData = await PanchangService.fetchPanchang(
        date: _selectedDate,
        latitude: _latitude,
        longitude: _longitude,
        timezone: _timezone,
      );
      
      // Merge with local calculations
      final localData = PanchangService.getLocalPanchang(
        date: _selectedDate,
        latitude: _latitude,
        longitude: _longitude,
        timezone: _timezone,
      );
      
      setState(() {
        _panchang = {...localData, ...apiData};
        _isLoading = false;
      });
    } catch (e) {
      print("API failed, using local calculations: $e");
      // Fallback to local calculations only
      setState(() {
        _panchang = PanchangService.getLocalPanchang(
          date: _selectedDate,
          latitude: _latitude,
          longitude: _longitude,
          timezone: _timezone,
        );
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AstroTheme.accentGold,
              onPrimary: Colors.black,
              surface: AstroTheme.cardBackground,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
      _fetchPanchang();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AstroBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: AstroTheme.accentGold))
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          _buildHeader(),
                          const SizedBox(height: 20),
                          _buildDateSelector(),
                          const SizedBox(height: 16),
                          _buildTabBar(),
                        ],
                      ),
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildGeneralPanchangTab(),
                          _buildPersonalizedPanchangTab(),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
  
  /// Tab bar for switching between general and personalized views
  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: AstroTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: AstroTheme.primaryGradient,
          borderRadius: BorderRadius.circular(12),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: const EdgeInsets.all(4),
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white54,
        labelStyle: const TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        tabs: const [
          Tab(text: '📅 Today'),
          Tab(text: '✨ For You'),
        ],
      ),
    );
  }
  
  /// General Panchang tab content
  Widget _buildGeneralPanchangTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (_panchang != null) ...[
          _buildVaraCard(),
          const SizedBox(height: 16),
          _buildTimingsCard(),
          const SizedBox(height: 16),
          _buildPanchangaSection(),
          const SizedBox(height: 16),
          _buildInauspiciousTimings(),
          const SizedBox(height: 16),
          _buildAuspiciousTimings(),
        ],
        if (_errorMessage != null) _buildErrorCard(),
        const SizedBox(height: 40),
      ],
    );
  }
  
  /// Personalized Panchang tab based on user's birth chart
  Widget _buildPersonalizedPanchangTab() {
    if (!_session.hasData || _session.birthChart == null) {
      return _buildNoChartPlaceholder();
    }
    
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildUserChartSummary(),
        const SizedBox(height: 20),
        _buildTodaysTransitEffects(),
        const SizedBox(height: 16),
        _buildNakshatraCompatibility(),
        const SizedBox(height: 16),
        _buildAuspiciousActivities(),
        const SizedBox(height: 16),
        _buildPlanetaryStrengthToday(),
        const SizedBox(height: 40),
      ],
    );
  }
  
  /// Placeholder when user has no chart data
  Widget _buildNoChartPlaceholder() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AstroTheme.primaryGradient.scale(0.3),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: AstroTheme.accentGold,
                size: 64,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Personalized Panchang',
              style: AstroTheme.headingMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Calculate your birth chart to see how today\'s cosmic energies personally affect you.',
              style: AstroTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BirthDetailsScreen()),
                ).then((_) {
                  setState(() {});
                });
              },
              icon: const Icon(Icons.calculate),
              label: const Text('CALCULATE CHART'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AstroTheme.accentGold,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// User's chart summary card
  Widget _buildUserChartSummary() {
    final chart = _session.birthChart!;
    final details = _session.birthDetails!;
    final ascSign = chart['ascSign'] ?? 'Unknown';
    final moonSign = _getMoonSign(chart);
    final sunSign = _getSunSign(chart);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AstroTheme.accentPurple.withOpacity(0.2),
            AstroTheme.accentCyan.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AstroTheme.accentPurple.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: AstroTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.person, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${details.name}\'s Chart',
                      style: AstroTheme.headingSmall,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Personalized insights for today',
                      style: AstroTheme.bodyMedium.copyWith(color: Colors.white60),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildMiniSignChip('Lagna', ascSign, AstroTheme.accentGold),
              const SizedBox(width: 10),
              _buildMiniSignChip('Moon', moonSign, AstroTheme.accentCyan),
              const SizedBox(width: 10),
              _buildMiniSignChip('Sun', sunSign, Colors.orange),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildMiniSignChip(String label, String sign, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(color: color.withOpacity(0.8), fontSize: 10),
            ),
            const SizedBox(height: 4),
            Text(
              sign,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
  
  /// Today's transit effects based on user's chart
  Widget _buildTodaysTransitEffects() {
    final chart = _session.birthChart!;
    final todayNakshatra = _panchang?['nakshatra']?['name'] ?? 'Unknown';
    final userNakshatra = _getUserNakshatra(chart);
    final transitEffect = _calculateTransitEffect(todayNakshatra, userNakshatra);
    
    return SectionCard(
      title: 'Today\'s Transit Effect',
      icon: Icons.swap_horiz,
      accentColor: transitEffect['color'] as Color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (transitEffect['color'] as Color).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  transitEffect['icon'] as IconData,
                  color: transitEffect['color'] as Color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transitEffect['title'] as String,
                      style: TextStyle(
                        color: transitEffect['color'] as Color,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Moon transit through $todayNakshatra',
                      style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              transitEffect['description'] as String,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  /// Nakshatra compatibility with today
  Widget _buildNakshatraCompatibility() {
    final chart = _session.birthChart!;
    final todayNakshatra = _panchang?['nakshatra']?['name'] ?? 'Unknown';
    final userNakshatra = _getUserNakshatra(chart);
    final compatibility = _calculateNakshatraCompatibility(todayNakshatra, userNakshatra);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AstroTheme.accentCyan.withOpacity(0.15),
            AstroTheme.accentCyan.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AstroTheme.accentCyan.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.star, color: AstroTheme.accentCyan),
              const SizedBox(width: 10),
              Text(
                'Nakshatra Alignment',
                style: AstroTheme.headingSmall.copyWith(color: AstroTheme.accentCyan),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildNakshatraChip('Your Nakshatra', userNakshatra),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getCompatibilityColor(compatibility).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  compatibility,
                  style: TextStyle(
                    color: _getCompatibilityColor(compatibility),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              Expanded(
                child: _buildNakshatraChip('Today', todayNakshatra),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            _getCompatibilityAdvice(compatibility),
            style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildNakshatraChip(String label, String nakshatra) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10),
        ),
        const SizedBox(height: 6),
        Text(
          nakshatra,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
  
  /// Auspicious activities based on user's chart + today's panchang
  Widget _buildAuspiciousActivities() {
    final chart = _session.birthChart!;
    final activities = _getPersonalizedActivities(chart);
    
    return SectionCard(
      title: 'Favorable Today For You',
      icon: Icons.check_circle_outline,
      accentColor: Colors.green,
      child: Column(
        children: activities.map((activity) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  activity['icon'] as IconData,
                  color: Colors.green,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  activity['label'] as String,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: (activity['strength'] as Color).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  activity['rating'] as String,
                  style: TextStyle(
                    color: activity['strength'] as Color,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        )).toList(),
      ),
    );
  }
  
  /// Planetary strength today based on user's chart placements
  Widget _buildPlanetaryStrengthToday() {
    final chart = _session.birthChart!;
    final vara = _panchang?['vara'] ?? '';
    final dayLord = _getDayLord(vara);
    final relevance = _getPlanetRelevance(chart, dayLord);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AstroTheme.accentGold.withOpacity(0.15),
            AstroTheme.accentGold.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AstroTheme.accentGold.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.wb_sunny, color: AstroTheme.accentGold),
              const SizedBox(width: 10),
              Text(
                'Day Lord: $dayLord',
                style: AstroTheme.headingSmall.copyWith(color: AstroTheme.accentGold),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Impact on Your Chart',
                  style: TextStyle(
                    color: AstroTheme.accentGold.withOpacity(0.9),
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  relevance,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPanchangaSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            'पञ्चाङ्ग (Five Limbs)',
            style: AstroTheme.headingSmall.copyWith(color: AstroTheme.accentGold),
          ),
        ),
        // Row 1: Tithi and Nakshatra
        Row(
          children: [
            Expanded(child: _buildTithiMiniCard()),
            const SizedBox(width: 12),
            Expanded(child: _buildNakshatraMiniCard()),
          ],
        ),
        const SizedBox(height: 12),
        // Row 2: Yoga and Karana
        Row(
          children: [
            Expanded(child: _buildYogaMiniCard()),
            const SizedBox(width: 12),
            Expanded(child: _buildKaranaMiniCard()),
          ],
        ),
      ],
    );
  }

  Widget _buildTithiMiniCard() {
    final tithi = _panchang!['tithi'] as Map<String, dynamic>?;
    if (tithi == null) return const SizedBox.shrink();
    
    final isShukla = tithi['isShukla'] == true;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AstroTheme.accentPurple.withOpacity(0.2),
            AstroTheme.accentPurple.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AstroTheme.accentPurple.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isShukla ? Icons.brightness_high : Icons.brightness_2,
                color: AstroTheme.accentPurple,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text('Tithi', style: TextStyle(color: Colors.white54, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            tithi['name'] ?? 'Unknown',
            style: const TextStyle(
              color: AstroTheme.accentPurple,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            tithi['paksha'] ?? '',
            style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildNakshatraMiniCard() {
    final nakshatra = _panchang!['nakshatra'] as Map<String, dynamic>?;
    if (nakshatra == null) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AstroTheme.accentCyan.withOpacity(0.2),
            AstroTheme.accentCyan.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AstroTheme.accentCyan.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.star, color: AstroTheme.accentCyan, size: 20),
              const SizedBox(width: 8),
              const Text('Nakshatra', style: TextStyle(color: Colors.white54, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            nakshatra['name'] ?? 'Unknown',
            style: const TextStyle(
              color: AstroTheme.accentCyan,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Pada ${nakshatra['pada']} • ${nakshatra['lord']}',
            style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildYogaMiniCard() {
    final yoga = _panchang!['yoga'] as Map<String, dynamic>?;
    if (yoga == null) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.teal.withOpacity(0.2),
            Colors.teal.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.teal.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.self_improvement, color: Colors.teal, size: 20),
              const SizedBox(width: 8),
              const Text('Yoga', style: TextStyle(color: Colors.white54, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            yoga['name'] ?? 'Unknown',
            style: const TextStyle(
              color: Colors.teal,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '#${yoga['number']} of 27',
            style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildKaranaMiniCard() {
    final karana = _panchang!['karana'] as Map<String, dynamic>?;
    if (karana == null) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.amber.withOpacity(0.2),
            Colors.amber.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.hourglass_bottom, color: Colors.amber, size: 20),
              const SizedBox(width: 8),
              const Text('Karana', style: TextStyle(color: Colors.white54, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            karana['name'] ?? 'Unknown',
            style: const TextStyle(
              color: Colors.amber,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Half Tithi',
            style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: AstroTheme.goldGradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AstroTheme.accentGold.withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.calendar_today, color: Colors.white, size: 28),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Panchang', style: AstroTheme.headingMedium),
              const SizedBox(height: 4),
              Text('Daily Vedic Almanac', style: AstroTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDateSelector() {
    return GestureDetector(
      onTap: _selectDate,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AstroTheme.accentCyan.withOpacity(0.2),
              AstroTheme.accentCyan.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AstroTheme.accentCyan.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AstroTheme.accentCyan.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.event, color: AstroTheme.accentCyan),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('EEEE').format(_selectedDate),
                    style: const TextStyle(
                      color: AstroTheme.accentCyan,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    DateFormat('dd MMMM yyyy').format(_selectedDate),
                    style: TextStyle(color: Colors.white.withOpacity(0.7)),
                  ),
                ],
              ),
            ),
            const Icon(Icons.edit_calendar, color: AstroTheme.accentCyan),
          ],
        ),
      ),
    );
  }

  Widget _buildVaraCard() {
    final vara = _panchang!['vara'] ?? 'Unknown';
    final varaSanskrit = _panchang!['varaSanskrit'] ?? '';
    final varaLord = _panchang!['varaLord'] ?? '';
    
    return AstroCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AstroTheme.accentGold.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.wb_sunny, color: AstroTheme.accentGold),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vara,
                      style: const TextStyle(
                        color: AstroTheme.accentGold,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      varaSanskrit,
                      style: TextStyle(color: Colors.white.withOpacity(0.6)),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AstroTheme.accentGold.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Lord: $varaLord',
                  style: const TextStyle(color: AstroTheme.accentGold, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimingsCard() {
    final sunrise = _panchang!['sunrise'] ?? '--:--';
    final sunset = _panchang!['sunset'] ?? '--:--';
    
    return Row(
      children: [
        Expanded(
          child: _buildTimingTile(
            icon: Icons.wb_twilight,
            label: 'Sunrise',
            time: sunrise,
            color: Colors.yellow,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildTimingTile(
            icon: Icons.nights_stay,
            label: 'Sunset',
            time: sunset,
            color: Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildTimingTile({
    required IconData icon,
    required String label,
    required String time,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(
            time,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInauspiciousTimings() {
    final rahuKalam = _panchang!['rahuKalam'] as Map<String, String>?;
    final gulikaKalam = _panchang!['gulikaKalam'] as Map<String, String>?;
    final yamaganda = _panchang!['yamagandaKalam'] as Map<String, String>?;

    return SectionCard(
      title: 'Inauspicious Timings',
      icon: Icons.warning_amber_rounded,
      accentColor: Colors.red,
      child: Column(
        children: [
          if (rahuKalam != null)
            _buildTimeRow
            ('Rahu Kalam', '${rahuKalam['start']} - ${rahuKalam['end']}', Icons.dangerous, Colors.white70),
          const SizedBox(height: 12),
          if (gulikaKalam != null)
            _buildTimeRow('Gulika Kalam', '${gulikaKalam['start']}- ${gulikaKalam['end']}', Icons.warning, Colors.white70),
          const SizedBox(height: 12),
          if (yamaganda != null)
            _buildTimeRow('Yamaganda', '${yamaganda['start']}- ${yamaganda['end']}', Icons.block, Colors.white70),
        ],
      ),
    );
  }

  Widget _buildAuspiciousTimings() {
    final abhijit = _panchang!['abhijitMuhurta'] as Map<String, String>?;

    return SectionCard(
      title: 'Auspicious Timings',
      icon: Icons.star,
      accentColor: Colors.green,
      child: Column(
        children: [
          if (abhijit != null)
            _buildTimeRow('Abhijit Muhurta', '${abhijit['start']} - ${abhijit['end']}', Icons.auto_awesome, Colors.green),
          const SizedBox(height: 8),
          Text(
            'Most auspicious time of the day for important activities',
            style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeRow(String label, String time, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            time,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTithiCard() {
    final tithi = _panchang!['tithi'];
    
    return SectionCard(
      title: 'Tithi (Lunar Day)',
      icon: Icons.brightness_2,
      accentColor: AstroTheme.accentPurple,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tithi['name'] ?? 'Unknown',
            style: const TextStyle(
              color: AstroTheme.accentPurple,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          if (tithi['paksha'] != null)
            Text(
              'Paksha: ${tithi['paksha']}',
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
            ),
        ],
      ),
    );
  }

  Widget _buildNakshatraCard() {
    final nakshatra = _panchang!['nakshatra'];
    
    return SectionCard(
      title: 'Nakshatra (Moon Star)',
      icon: Icons.star_border,
      accentColor: AstroTheme.accentCyan,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            nakshatra['name'] ?? 'Unknown',
            style: const TextStyle(
              color: AstroTheme.accentCyan,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          if (nakshatra['lord'] != null)
            Text(
              'Lord: ${nakshatra['lord']}',
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
            ),
        ],
      ),
    );
  }

  Widget _buildErrorCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
  
  // ═══════════════════════════════════════════════════════════════
  // HELPER METHODS FOR PERSONALIZED PANCHANG
  // ═══════════════════════════════════════════════════════════════
  
  /// Get Moon sign from chart data
  String _getMoonSign(Map<String, dynamic> chart) {
    try {
      final planets = chart['planets'] as Map<String, dynamic>?;
      if (planets != null && planets.containsKey('Moon')) {
        final moonData = planets['Moon'] as Map<String, dynamic>?;
        return moonData?['sign'] ?? 'Unknown';
      }
      // Alternative: Get from houses
      final houses = chart['houses'] as List?;
      if (houses != null) {
        for (int i = 0; i < houses.length; i++) {
          final house = houses[i] as List;
          if (house.any((p) => p.toString().contains('Mo') || p.toString().contains('Moon'))) {
            return _getSignForHouse(i, chart);
          }
        }
      }
    } catch (e) {
      print('Error getting moon sign: $e');
    }
    return 'Unknown';
  }
  
  /// Get Sun sign from chart data
  String _getSunSign(Map<String, dynamic> chart) {
    try {
      final planets = chart['planets'] as Map<String, dynamic>?;
      if (planets != null && planets.containsKey('Sun')) {
        final sunData = planets['Sun'] as Map<String, dynamic>?;
        return sunData?['sign'] ?? 'Unknown';
      }
      // Alternative: Get from houses
      final houses = chart['houses'] as List?;
      if (houses != null) {
        for (int i = 0; i < houses.length; i++) {
          final house = houses[i] as List;
          if (house.any((p) => p.toString().contains('Su') || p.toString().contains('Sun'))) {
            return _getSignForHouse(i, chart);
          }
        }
      }
    } catch (e) {
      print('Error getting sun sign: $e');
    }
    return 'Unknown';
  }
  
  /// Get sign name for a house index
  String _getSignForHouse(int houseIndex, Map<String, dynamic> chart) {
    final signs = [
      'Aries', 'Taurus', 'Gemini', 'Cancer', 'Leo', 'Virgo',
      'Libra', 'Scorpio', 'Sagittarius', 'Capricorn', 'Aquarius', 'Pisces'
    ];
    final ascSignIndex = chart['ascSignIndex'] as int? ?? 0;
    final signIndex = (ascSignIndex + houseIndex) % 12;
    return signs[signIndex];
  }
  
  /// Get user's Moon Nakshatra from chart
  String _getUserNakshatra(Map<String, dynamic> chart) {
    try {
      final planets = chart['planets'] as Map<String, dynamic>?;
      if (planets != null && planets.containsKey('Moon')) {
        final moonData = planets['Moon'] as Map<String, dynamic>?;
        return moonData?['nakshatra'] ?? 'Ashwini';
      }
      // Fallback: calculate from Moon longitude if available
      if (planets != null && planets.containsKey('Moon')) {
        final moonLong = (planets['Moon'] as Map<String, dynamic>?)?['longitude'] as double?;
        if (moonLong != null) {
          return _getNakshatraFromLongitude(moonLong);
        }
      }
    } catch (e) {
      print('Error getting user nakshatra: $e');
    }
    return 'Ashwini';
  }
  
  /// Get Nakshatra from longitude
  String _getNakshatraFromLongitude(double longitude) {
    final nakshatras = [
      'Ashwini', 'Bharani', 'Krittika', 'Rohini', 'Mrigashira', 'Ardra',
      'Punarvasu', 'Pushya', 'Ashlesha', 'Magha', 'Purva Phalguni', 'Uttara Phalguni',
      'Hasta', 'Chitra', 'Swati', 'Vishakha', 'Anuradha', 'Jyeshtha',
      'Mula', 'Purva Ashadha', 'Uttara Ashadha', 'Shravana', 'Dhanishta', 'Shatabhisha',
      'Purva Bhadrapada', 'Uttara Bhadrapada', 'Revati'
    ];
    final nakshatraIndex = ((longitude % 360) / (360 / 27)).floor();
    return nakshatras[nakshatraIndex % 27];
  }
  
  /// Calculate transit effect based on Tara Bala
  Map<String, dynamic> _calculateTransitEffect(String todayNakshatra, String userNakshatra) {
    final nakshatras = [
      'Ashwini', 'Bharani', 'Krittika', 'Rohini', 'Mrigashira', 'Ardra',
      'Punarvasu', 'Pushya', 'Ashlesha', 'Magha', 'Purva Phalguni', 'Uttara Phalguni',
      'Hasta', 'Chitra', 'Swati', 'Vishakha', 'Anuradha', 'Jyeshtha',
      'Mula', 'Purva Ashadha', 'Uttara Ashadha', 'Shravana', 'Dhanishta', 'Shatabhisha',
      'Purva Bhadrapada', 'Uttara Bhadrapada', 'Revati'
    ];
    
    int userIndex = nakshatras.indexOf(userNakshatra);
    int todayIndex = nakshatras.indexOf(todayNakshatra);
    
    if (userIndex == -1) userIndex = 0;
    if (todayIndex == -1) todayIndex = 0;
    
    // Calculate Tara (1-9 cycle)
    int tara = ((todayIndex - userIndex + 27) % 27) % 9 + 1;
    
    // Tara Bala effects
    final taraEffects = {
      1: {
        'title': 'Janma (Birth)',
        'icon': Icons.favorite,
        'color': Colors.orange,
        'description': 'Today\'s Moon transits your birth star. This is a day of moderate energy. Focus on routine activities and avoid major initiations. Good for introspection and self-care.',
      },
      2: {
        'title': 'Sampat (Wealth)',
        'icon': Icons.attach_money,
        'color': Colors.green,
        'description': 'Excellent day for financial matters, wealth accumulation, and material gains. Your prosperity potential is heightened. Good time for investments and business decisions.',
      },
      3: {
        'title': 'Vipat (Danger)',
        'icon': Icons.warning_amber,
        'color': Colors.red,
        'description': 'A challenging transit. Exercise caution in important decisions. Avoid risky ventures and major commitments. Focus on completing existing tasks rather than starting new ones.',
      },
      4: {
        'title': 'Kshema (Well-being)',
        'icon': Icons.spa,
        'color': Colors.teal,
        'description': 'A day of comfort-being and peace. Favorable for health-related activities, relaxation, and nurturing relationships. Good for medical treatments and wellness practices.',
      },
      5: {
        'title': 'Pratyak (Obstacles)',
        'icon': Icons.block,
        'color': Colors.deepOrange,
        'description': 'Potential for obstacles and delays. Not ideal for launching new projects. Focus on problem-solving and clearing pending issues. Patience is key today.',
      },
      6: {
        'title': 'Sadhana (Achievement)',
        'icon': Icons.emoji_events,
        'color': Colors.amber,
        'description': 'Excellent for accomplishing goals and realizing ambitions. Your efforts are likely to bear fruit. Great day for competitions, exams, and pursuing achievements.',
      },
      7: {
        'title': 'Naidhana (Death)',
        'icon': Icons.shield,
        'color': Colors.blueGrey,
        'description': 'A transformative but challenging transit. Avoid major risks. Good for spiritual practices, endings that lead to new beginnings, and letting go of the old.',
      },
      8: {
        'title': 'Mitra (Friend)',
        'icon': Icons.people,
        'color': Colors.blue,
        'description': 'Auspicious for friendships, partnerships, and social connections. Great day for networking, collaborations, and strengthening relationships.',
      },
      9: {
        'title': 'Parama Mitra (Best Friend)',
        'icon': Icons.star,
        'color': Colors.purple,
        'description': 'Highly auspicious! One of the best days for you. Favorable for all important activities, new beginnings, and major decisions. Success comes naturally today.',
      },
    };
    
    return taraEffects[tara] ?? taraEffects[1]!;
  }
  
  /// Calculate Nakshatra compatibility
  String _calculateNakshatraCompatibility(String todayNakshatra, String userNakshatra) {
    final nakshatras = [
      'Ashwini', 'Bharani', 'Krittika', 'Rohini', 'Mrigashira', 'Ardra',
      'Punarvasu', 'Pushya', 'Ashlesha', 'Magha', 'Purva Phalguni', 'Uttara Phalguni',
      'Hasta', 'Chitra', 'Swati', 'Vishakha', 'Anuradha', 'Jyeshtha',
      'Mula', 'Purva Ashadha', 'Uttara Ashadha', 'Shravana', 'Dhanishta', 'Shatabhisha',
      'Purva Bhadrapada', 'Uttara Bhadrapada', 'Revati'
    ];
    
    int userIndex = nakshatras.indexOf(userNakshatra);
    int todayIndex = nakshatras.indexOf(todayNakshatra);
    
    if (userIndex == -1) userIndex = 0;
    if (todayIndex == -1) todayIndex = 0;
    
    int tara = ((todayIndex - userIndex + 27) % 27) % 9 + 1;
    
    // Good taras: 2 (Sampat), 4 (Kshema), 6 (Sadhana), 8 (Mitra), 9 (Parama Mitra)
    // Neutral: 1 (Janma)
    // Challenging: 3 (Vipat), 5 (Pratyak), 7 (Naidhana)
    
    if (tara == 9) return 'Excellent';
    if ([2, 6, 8].contains(tara)) return 'Good';
    if ([1, 4].contains(tara)) return 'Neutral';
    return 'Challenging';
  }
  
  Color _getCompatibilityColor(String compatibility) {
    switch (compatibility) {
      case 'Excellent': return Colors.purple;
      case 'Good': return Colors.green;
      case 'Neutral': return Colors.amber;
      case 'Challenging': return Colors.red;
      default: return Colors.white;
    }
  }
  
  String _getCompatibilityAdvice(String compatibility) {
    switch (compatibility) {
      case 'Excellent':
        return 'Today is exceptionally favorable for you! Pursue your goals with confidence.';
      case 'Good':
        return 'A supportive day. Good time for important decisions and new initiatives.';
      case 'Neutral':
        return 'A balanced day. Focus on routine activities and maintain steady progress.';
      case 'Challenging':
        return 'Exercise caution today. Focus on completing existing tasks rather than starting new ventures.';
      default:
        return 'Check your alignment with the stars.';
    }
  }
  
  /// Get personalized activities based on chart and panchang
  List<Map<String, dynamic>> _getPersonalizedActivities(Map<String, dynamic> chart) {
    final vara = _panchang?['vara'] ?? '';
    final tithi = _panchang?['tithi']?['name'] ?? '';
    final nakshatra = _panchang?['nakshatra']?['name'] ?? '';
    
    List<Map<String, dynamic>> activities = [];
    
    // Based on day (Vara)
    if (vara.toString().contains('Sunday') || vara.toString().contains('Sun')) {
      activities.add({
        'icon': Icons.self_improvement,
        'label': 'Spiritual practices & leadership tasks',
        'rating': 'Strong',
        'strength': Colors.green,
      });
    } else if (vara.toString().contains('Monday') || vara.toString().contains('Mon')) {
      activities.add({
        'icon': Icons.home,
        'label': 'Domestic activities & nurturing',
        'rating': 'Strong',
        'strength': Colors.green,
      });
    } else if (vara.toString().contains('Tuesday') || vara.toString().contains('Tue')) {
      activities.add({
        'icon': Icons.fitness_center,
        'label': 'Physical activities & competitions',
        'rating': 'Strong',
        'strength': Colors.green,
      });
    } else if (vara.toString().contains('Wednesday') || vara.toString().contains('Wed')) {
      activities.add({
        'icon': Icons.school,
        'label': 'Learning, communication & business',
        'rating': 'Strong',
        'strength': Colors.green,
      });
    } else if (vara.toString().contains('Thursday') || vara.toString().contains('Thu')) {
      activities.add({
        'icon': Icons.auto_stories,
        'label': 'Teaching, spirituality & expansion',
        'rating': 'Excellent',
        'strength': Colors.purple,
      });
    } else if (vara.toString().contains('Friday') || vara.toString().contains('Fri')) {
      activities.add({
        'icon': Icons.favorite,
        'label': 'Romance, arts & luxury purchases',
        'rating': 'Excellent',
        'strength': Colors.purple,
      });
    } else if (vara.toString().contains('Saturday') || vara.toString().contains('Sat')) {
      activities.add({
        'icon': Icons.construction,
        'label': 'Hard work, discipline & service',
        'rating': 'Moderate',
        'strength': Colors.amber,
      });
    }
    
    // Based on user's ascendant
    final ascSign = chart['ascSign'] ?? '';
    if (ascSign.toString().isNotEmpty) {
      activities.add({
        'icon': Icons.trending_up,
        'label': 'Activities related to ${ascSign.toString()} energy',
        'rating': 'Personal',
        'strength': AstroTheme.accentCyan,
      });
    }
    
    // Based on tithi
    final tithiNum = _getTithiNumber(tithi);
    if ([2, 3, 5, 7, 10, 11, 13].contains(tithiNum)) {
      activities.add({
        'icon': Icons.rocket_launch,
        'label': 'Starting new ventures and initiatives',
        'rating': 'Auspicious',
        'strength': Colors.green,
      });
    }
    
    // Ensure we have at least 3 activities
    if (activities.length < 3) {
      activities.add({
        'icon': Icons.lightbulb,
        'label': 'Self-reflection and planning',
        'rating': 'Good',
        'strength': Colors.blue,
      });
    }
    
    return activities.take(5).toList();
  }
  
  int _getTithiNumber(String tithi) {
    final tithiNames = [
      'Pratipada', 'Dwitiya', 'Tritiya', 'Chaturthi', 'Panchami',
      'Shashthi', 'Saptami', 'Ashtami', 'Navami', 'Dashami',
      'Ekadashi', 'Dwadashi', 'Trayodashi', 'Chaturdashi', 'Purnima', 'Amavasya'
    ];
    for (int i = 0; i < tithiNames.length; i++) {
      if (tithi.contains(tithiNames[i])) return i + 1;
    }
    return 0;
  }
  
  /// Get day lord planet name
  String _getDayLord(String vara) {
    final dayLords = {
      'Sunday': 'Sun',
      'Monday': 'Moon',
      'Tuesday': 'Mars',
      'Wednesday': 'Mercury',
      'Thursday': 'Jupiter',
      'Friday': 'Venus',
      'Saturday': 'Saturn',
    };
    
    for (var entry in dayLords.entries) {
      if (vara.toLowerCase().contains(entry.key.toLowerCase())) {
        return entry.value;
      }
    }
    return 'Unknown';
  }
  
  /// Get planet's relevance in user's chart
  String _getPlanetRelevance(Map<String, dynamic> chart, String planetName) {
    if (planetName == 'Unknown') {
      return 'Unable to determine today\'s planetary influence on your chart.';
    }
    
    final ascSign = chart['ascSign'] ?? '';
    final planets = chart['planets'] as Map<String, dynamic>?;
    
    // Find what houses this planet rules and occupies
    String relevance = 'Today is ruled by $planetName. ';
    
    // Add personalized insight based on planet
    final planetInsights = {
      'Sun': 'Focus on self-expression, authority matters, and leadership. Good day to connect with father figures or take initiative in career.',
      'Moon': 'Emotions are heightened. Pay attention to your mental well-being and nurturing relationships. Great for domestic activities.',
      'Mars': 'Energy levels are high. Channel into physical activities, competitions, or tackling challenges head-on. Avoid conflicts.',
      'Mercury': 'Excellent for communication, learning, and business deals. Your intellect is sharp today. Good for writing and negotiations.',
      'Jupiter': 'Wisdom and expansion are favored. Seek guidance from mentors, engage in spiritual practices, or make important decisions.',
      'Venus': 'Romance, arts, and beauty are highlighted. Good for relationships, creative pursuits, and enjoying life\'s pleasures.',
      'Saturn': 'Discipline and hard work are key. Focus on responsibilities, long-term goals, and clearing pending tasks.',
    };
    
    relevance += planetInsights[planetName] ?? 'Pay attention to ${planetName}-related activities.';
    
    // Check if planet is in a key house
    if (planets != null && planets.containsKey(planetName)) {
      final planetData = planets[planetName] as Map<String, dynamic>?;
      final house = planetData?['house'];
      if (house != null) {
        relevance += '\n\nIn your chart, $planetName influences your ${_getHouseName(house as int)} matters.';
      }
    }
    
    return relevance;
  }
  
  String _getHouseName(int house) {
    final houseNames = {
      1: 'personality and self',
      2: 'wealth and family',
      3: 'communication and siblings',
      4: 'home and mother',
      5: 'creativity and children',
      6: 'health and service',
      7: 'partnerships and marriage',
      8: 'transformation and mysteries',
      9: 'wisdom and fortune',
      10: 'career and reputation',
      11: 'gains and friendships',
      12: 'spirituality and liberation',
    };
    return houseNames[house] ?? 'life';
  }
}
