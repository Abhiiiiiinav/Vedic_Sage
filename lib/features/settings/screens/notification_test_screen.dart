import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../app/theme.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/services/local_notification_service.dart';
import '../../../shared/widgets/astro_background.dart';

class NotificationTestScreen extends StatefulWidget {
  const NotificationTestScreen({super.key});

  @override
  State<NotificationTestScreen> createState() => _NotificationTestScreenState();
}

class _NotificationTestScreenState extends State<NotificationTestScreen> {
  String _lastTestResult = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AstroTheme.scaffoldBackground,
      body: AstroBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoCard(),
                      const SizedBox(height: 24),
                      _buildSectionTitle('Notification Types'),
                      const SizedBox(height: 12),
                      _buildTestButton(
                        icon: Icons.local_fire_department,
                        title: 'Streak Alert',
                        subtitle: 'Test streak protection notification',
                        color: const Color(0xFFff9500),
                        onTap: () => _testStreakNotification(),
                      ),
                      const SizedBox(height: 12),
                      _buildTestButton(
                        icon: Icons.menu_book_rounded,
                        title: 'Learning Reminder',
                        subtitle: 'Test learning nudge notification',
                        color: const Color(0xFF34c759),
                        onTap: () => _testLearningNotification(),
                      ),
                      const SizedBox(height: 12),
                      _buildTestButton(
                        icon: Icons.wb_sunny_rounded,
                        title: 'Cosmic Update',
                        subtitle: 'Test daily horoscope notification',
                        color: const Color(0xFF00d4ff),
                        onTap: () => _testCosmicNotification(),
                      ),
                      const SizedBox(height: 12),
                      _buildTestButton(
                        icon: Icons.people_rounded,
                        title: 'Social Notification',
                        subtitle: 'Test friend interaction notification',
                        color: const Color(0xFF667eea),
                        onTap: () => _testSocialNotification(),
                      ),
                      const SizedBox(height: 12),
                      _buildTestButton(
                        icon: Icons.emoji_events_rounded,
                        title: 'Achievement Alert',
                        subtitle: 'Test badge unlock notification',
                        color: const Color(0xFFf5a623),
                        onTap: () => _testAchievementNotification(),
                      ),
                      const SizedBox(height: 12),
                      _buildTestButton(
                        icon: Icons.task_alt_rounded,
                        title: 'Daily Tasks',
                        subtitle: 'Test morning tasks notification',
                        color: const Color(0xFF7B61FF),
                        onTap: () => _testDailyTasksNotification(),
                      ),
                      const SizedBox(height: 24),
                      _buildSectionTitle('Scheduled Notifications'),
                      const SizedBox(height: 12),
                      _buildInfoTile(
                        icon: Icons.wb_sunny_rounded,
                        title: 'Morning Tasks',
                        subtitle: 'Scheduled for 8:00 AM daily',
                        color: const Color(0xFF00d4ff),
                      ),
                      const SizedBox(height: 12),
                      _buildInfoTile(
                        icon: Icons.menu_book_rounded,
                        title: 'Evening Learning',
                        subtitle: 'Scheduled for 6:00 PM daily',
                        color: const Color(0xFF34c759),
                      ),
                      const SizedBox(height: 12),
                      _buildInfoTile(
                        icon: Icons.local_fire_department,
                        title: 'Streak Protection',
                        subtitle: 'Scheduled for 8:00 PM daily',
                        color: const Color(0xFFff9500),
                      ),
                      const SizedBox(height: 24),
                      _buildSectionTitle('Test All'),
                      const SizedBox(height: 12),
                      _buildTestAllButton(),
                      if (_lastTestResult.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        _buildResultCard(),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          Text(
            'Test Notifications',
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AstroTheme.accentPurple.withOpacity(0.15),
            AstroTheme.accentCyan.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AstroTheme.accentPurple.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AstroTheme.accentPurple.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.science_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notification Testing Lab',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Test all notification types and see them in action',
                  style: GoogleFonts.quicksand(
                    fontSize: 13,
                    color: Colors.white60,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: GoogleFonts.quicksand(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AstroTheme.accentGold.withOpacity(0.7),
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildTestButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.quicksand(
                      fontSize: 12,
                      color: Colors.white54,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.play_arrow,
                color: color,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.quicksand(
                    fontSize: 11,
                    color: Colors.white38,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.schedule,
            color: Colors.white24,
            size: 18,
          ),
        ],
      ),
    );
  }

  Widget _buildTestAllButton() {
    return InkWell(
      onTap: _testAllNotifications,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: AstroTheme.primaryGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AstroTheme.accentPurple.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.rocket_launch, color: Colors.white, size: 22),
            const SizedBox(width: 12),
            Text(
              'Test All Notifications',
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.green.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _lastTestResult,
              style: GoogleFonts.quicksand(
                fontSize: 13,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Test notification methods
  Future<void> _testStreakNotification() async {
    await NotificationService().addNotification(
      title: '🔥 Your 7-day streak is at risk!',
      message: 'Complete a lesson to keep your cosmic streak alive. Don\'t break the chain!',
      icon: Icons.local_fire_department,
      color: const Color(0xFFff9500),
      type: 'streak',
    );
    
    setState(() {
      _lastTestResult = 'Streak notification sent! Check your notification center.';
    });
    
    _showSnackBar('Streak notification sent!', Colors.orange);
  }

  Future<void> _testLearningNotification() async {
    await NotificationService().addNotification(
      title: '📚 Continue your Jyotish journey',
      message: 'A few minutes of learning keeps your cosmic wisdom growing. Your next lesson awaits!',
      icon: Icons.menu_book_rounded,
      color: const Color(0xFF34c759),
      type: 'learning',
    );
    
    setState(() {
      _lastTestResult = 'Learning notification sent! Check your notification center.';
    });
    
    _showSnackBar('Learning notification sent!', Colors.green);
  }

  Future<void> _testCosmicNotification() async {
    await NotificationService().addNotification(
      title: '☀️ Your daily cosmic forecast is ready',
      message: 'Today\'s planetary transits bring opportunities for growth. Tap to read your personalized horoscope.',
      icon: Icons.wb_sunny_rounded,
      color: const Color(0xFF00d4ff),
      type: 'cosmic',
    );
    
    setState(() {
      _lastTestResult = 'Cosmic notification sent! Check your notification center.';
    });
    
    _showSnackBar('Cosmic notification sent!', Colors.cyan);
  }

  Future<void> _testSocialNotification() async {
    await NotificationService().addNotification(
      title: '👥 New friend request',
      message: 'Cosmic Explorer wants to connect with you! View their chart and accept the request.',
      icon: Icons.people_rounded,
      color: const Color(0xFF667eea),
      type: 'social',
    );
    
    setState(() {
      _lastTestResult = 'Social notification sent! Check your notification center.';
    });
    
    _showSnackBar('Social notification sent!', Colors.purple);
  }

  Future<void> _testAchievementNotification() async {
    await NotificationService().addNotification(
      title: '🏆 Achievement Unlocked!',
      message: 'You\'ve earned the "Nakshatra Master" badge! You\'ve completed all 27 Nakshatra lessons.',
      icon: Icons.emoji_events_rounded,
      color: const Color(0xFFf5a623),
      type: 'achievement',
    );
    
    setState(() {
      _lastTestResult = 'Achievement notification sent! Check your notification center.';
    });
    
    _showSnackBar('Achievement notification sent!', Colors.amber);
  }

  Future<void> _testDailyTasksNotification() async {
    await NotificationService().addNotification(
      title: '✨ Your cosmic tasks are ready!',
      message: 'Start your day aligned with the stars. 5 new personalized tasks await you.',
      icon: Icons.task_alt_rounded,
      color: const Color(0xFF7B61FF),
      type: 'learning',
    );
    
    setState(() {
      _lastTestResult = 'Daily tasks notification sent! Check your notification center.';
    });
    
    _showSnackBar('Daily tasks notification sent!', const Color(0xFF7B61FF));
  }

  Future<void> _testAllNotifications() async {
    await _testStreakNotification();
    await Future.delayed(const Duration(milliseconds: 500));
    await _testLearningNotification();
    await Future.delayed(const Duration(milliseconds: 500));
    await _testCosmicNotification();
    await Future.delayed(const Duration(milliseconds: 500));
    await _testSocialNotification();
    await Future.delayed(const Duration(milliseconds: 500));
    await _testAchievementNotification();
    await Future.delayed(const Duration(milliseconds: 500));
    await _testDailyTasksNotification();
    
    setState(() {
      _lastTestResult = 'All 6 notifications sent! Check your notification center to see them all.';
    });
    
    _showSnackBar('All notifications sent! 🎉', Colors.green);
  }

  void _showSnackBar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
