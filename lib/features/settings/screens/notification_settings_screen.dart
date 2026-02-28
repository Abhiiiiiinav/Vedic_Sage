import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../app/theme.dart';
import '../../../core/services/push_notification_service.dart';
import '../../../core/services/local_notification_service.dart';
import '../../../shared/widgets/astro_background.dart';
import 'notification_test_screen.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool _dailyReminders = true;
  bool _streakAlerts = true;
  bool _learningNudges = true;
  bool _achievementAlerts = true;
  bool _cosmicUpdates = true;
  bool _socialNotifications = true;

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
                      _buildSectionTitle('Daily Notifications'),
                      const SizedBox(height: 12),
                      _buildNotificationTile(
                        icon: Icons.wb_sunny_rounded,
                        title: 'Daily Reminders',
                        subtitle: 'Morning tasks and cosmic updates',
                        value: _dailyReminders,
                        color: const Color(0xFF00d4ff),
                        onChanged: (val) =>
                            setState(() => _dailyReminders = val),
                      ),
                      const SizedBox(height: 12),
                      _buildNotificationTile(
                        icon: Icons.local_fire_department,
                        title: 'Streak Alerts',
                        subtitle: 'Protect your learning streak',
                        value: _streakAlerts,
                        color: const Color(0xFFff9500),
                        onChanged: (val) => setState(() => _streakAlerts = val),
                      ),
                      const SizedBox(height: 12),
                      _buildNotificationTile(
                        icon: Icons.menu_book_rounded,
                        title: 'Learning Nudges',
                        subtitle: 'Evening reminders to continue learning',
                        value: _learningNudges,
                        color: const Color(0xFF34c759),
                        onChanged: (val) =>
                            setState(() => _learningNudges = val),
                      ),
                      const SizedBox(height: 24),
                      _buildSectionTitle('Updates & Achievements'),
                      const SizedBox(height: 12),
                      _buildNotificationTile(
                        icon: Icons.emoji_events_rounded,
                        title: 'Achievement Alerts',
                        subtitle: 'New badges and milestones',
                        value: _achievementAlerts,
                        color: const Color(0xFFf5a623),
                        onChanged: (val) =>
                            setState(() => _achievementAlerts = val),
                      ),
                      const SizedBox(height: 12),
                      _buildNotificationTile(
                        icon: Icons.auto_awesome,
                        title: 'Cosmic Updates',
                        subtitle: 'Daily horoscope and planetary transits',
                        value: _cosmicUpdates,
                        color: const Color(0xFF7B61FF),
                        onChanged: (val) =>
                            setState(() => _cosmicUpdates = val),
                      ),
                      const SizedBox(height: 24),
                      _buildSectionTitle('Social'),
                      const SizedBox(height: 12),
                      _buildNotificationTile(
                        icon: Icons.people_rounded,
                        title: 'Social Notifications',
                        subtitle: 'Friend requests and interactions',
                        value: _socialNotifications,
                        color: const Color(0xFF667eea),
                        onChanged: (val) =>
                            setState(() => _socialNotifications = val),
                      ),
                      const SizedBox(height: 24),
                      _buildTestSection(),
                      const SizedBox(height: 24),
                      _buildTokenSection(),
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
            'Notification Settings',
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
              Icons.notifications_active,
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
                  'Stay Connected',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Customize your notification preferences to stay aligned with the cosmos',
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

  Widget _buildNotificationTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Color color,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
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
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: color,
            activeTrackColor: color.withOpacity(0.5),
          ),
        ],
      ),
    );
  }

  Widget _buildTestSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.science_rounded,
                color: Colors.white70,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Test Notifications',
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      await PushNotificationService().sendTestNotification();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Test notification sent!'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    } catch (e) {
                      // Firebase not configured - use local notification instead
                      await LocalNotificationService().showNow(
                        title: '🔔 Test Notification',
                        body: 'Your notifications are working! ✨',
                        payload: 'test',
                      );
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Test notification sent!'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AstroTheme.accentPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Quick Test',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => NotificationTestScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AstroTheme.accentCyan,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Test All Types',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTokenSection() {
    try {
      final token = PushNotificationService().fcmToken;
      if (token == null) return const SizedBox.shrink();

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.key,
                  color: Colors.white70,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Device Token',
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              token,
              style: GoogleFonts.sourceCodePro(
                fontSize: 10,
                color: Colors.white54,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      );
    } catch (e) {
      // Firebase not initialized - hide token section
      return const SizedBox.shrink();
    }
  }
}
