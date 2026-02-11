import 'package:flutter/material.dart';
import '../../../app/theme.dart';
import '../../../shared/widgets/section_card.dart';
import '../../../shared/widgets/astro_background.dart';

class DayAheadScreen extends StatefulWidget {
  const DayAheadScreen({super.key});

  @override
  State<DayAheadScreen> createState() => _DayAheadScreenState();
}

class _DayAheadScreenState extends State<DayAheadScreen> {
  final DateTime _today = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return AstroBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Your Day Ahead'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => setState(() {}),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildDateHeader(),
            const SizedBox(height: 20),
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

  Widget _buildDateHeader() {
    final weekday = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'][_today.weekday - 1];
    final month = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'][_today.month - 1];

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
    // This would combine user's chart + panchang + transits
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
              Text('Your Personalized Day Ahead', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
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

  String _generateDailySummary() {
    // Mock personalized summary - in real app, this would use actual chart data
    return 'Today\'s planetary alignments favor your communication sector. With Mercury transiting your 3rd house and Moon in a favorable nakshatra, it\'s an excellent day for important conversations and learning. The Panchang shows auspicious timing between 10 AM - 12 PM. Your birth chart\'s Jupiter placement suggests opportunities in education or teaching. Stay mindful of Mars transit which may bring impatience - channel this energy into productive tasks. Evening hours are ideal for creative pursuits.';
  }

  Widget _buildPanchangCard() {
    return SectionCard(
      title: 'Today\'s Panchang',
      icon: Icons.calendar_today,
      accentColor: AstroTheme.accentGold,
      child: Column(
        children: [
          _buildPanchangRow('Tithi', 'Shukla Paksha Saptami', Icons.brightness_3),
          _buildPanchangRow('Nakshatra', 'Pushya (Moon)', Icons.stars),
          _buildPanchangRow('Yoga', 'Siddha Yoga', Icons.self_improvement),
          _buildPanchangRow('Karana', 'Bava', Icons.category),
          _buildPanchangRow('Vara', 'Thursday (Jupiter)', Icons.wb_sunny),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF4caf50).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: const [
                Icon(Icons.check_circle, color: Color(0xFF4caf50), size: 20),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Auspicious Time: 10:00 AM - 12:00 PM',
                    style: TextStyle(color: Color(0xFF4caf50), fontWeight: FontWeight.w600),
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
    return SectionCard(
      title: 'Current Planetary Transits',
      icon: Icons.track_changes,
      accentColor: AstroTheme.accentPurple,
      child: Column(
        children: [
          _buildTransitRow('Sun', 'Capricorn (10th house)', AstroTheme.sunColor, 'Career focus, authority'),
          _buildTransitRow('Moon', 'Cancer (4th house)', AstroTheme.moonColor, 'Emotional comfort, home'),
          _buildTransitRow('Mercury', 'Aquarius (11th house)', AstroTheme.mercuryColor, 'Social connections, ideas'),
          _buildTransitRow('Venus', 'Pisces (12th house)', AstroTheme.venusColor, 'Spiritual love, creativity'),
          _buildTransitRow('Mars', 'Aries (1st house)', AstroTheme.marsColor, 'High energy, initiative'),
          _buildTransitRow('Jupiter', 'Taurus (2nd house)', AstroTheme.jupiterColor, 'Wealth growth, values'),
          _buildTransitRow('Saturn', 'Aquarius (11th house)', AstroTheme.saturnColor, 'Long-term goals, discipline'),
        ],
      ),
    );
  }

  Widget _buildTransitRow(String planet, String position, Color color, String effect) {
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
                      style: TextStyle(color: color, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(planet, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                      Text(position, style: AstroTheme.bodyMedium.copyWith(fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '→ $effect',
              style: AstroTheme.bodyMedium.copyWith(fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalizedGuidance() {
    return SectionCard(
      title: 'Personalized Guidance',
      icon: Icons.lightbulb,
      accentColor: const Color(0xFF4caf50),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGuidanceItem('✅ Do', 'Initiate important conversations, focus on learning, engage in creative work', const Color(0xFF4caf50)),
          const SizedBox(height: 12),
          _buildGuidanceItem('⚠️ Avoid', 'Making impulsive decisions, starting conflicts, overspending', const Color(0xFFff9800)),
          const SizedBox(height: 12),
          _buildGuidanceItem('🎯 Focus On', 'Communication skills, building connections, self-expression', AstroTheme.accentCyan),
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
          Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 14)),
          const SizedBox(height: 4),
          Text(text, style: AstroTheme.bodyMedium.copyWith(color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildLuckyElements() {
    return SectionCard(
      title: 'Lucky Elements Today',
      icon: Icons.stars,
      accentColor: AstroTheme.accentGold,
      child: Row(
        children: [
          Expanded(
            child: _buildLuckyBox('Color', '💚 Green', AstroTheme.mercuryColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildLuckyBox('Number', '3, 5, 7', AstroTheme.accentGold),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildLuckyBox('Direction', '🧭 East', AstroTheme.accentCyan),
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
            style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
