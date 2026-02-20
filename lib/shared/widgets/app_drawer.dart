import 'package:flutter/material.dart';
import '../../core/services/app_update_service.dart';
import '../../core/services/local_notification_service.dart';
import '../../app/theme.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/daily/screens/day_ahead_screen.dart';
import '../../features/roadmap/screens/achievements_screen.dart';
import '../../features/calculator/screens/birth_details_screen.dart';
import '../../features/relationship/screens/relationship_report_screen.dart';
import '../../core/services/user_session.dart';
import '../../core/services/gamification_service.dart';
import 'level_progress_bar.dart';

class AppDrawer extends StatefulWidget {
  final int currentIndex;
  final Function(int) onNavigate;

  const AppDrawer({
    super.key,
    required this.currentIndex,
    required this.onNavigate,
  });

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  bool _isCheckingUpdate = false;

  @override
  Widget build(BuildContext context) {
    // Get real user data from session
    final session = UserSession();
    final userName = session.birthDetails?.name ?? 'Vedic Explorer';
    final hasChart = session.hasData;

    // Get real gamification data from service
    final gamification = GamificationService();
    final currentLevel = gamification.currentLevel;
    final currentXP = gamification.xpInCurrentLevel;
    final xpForNextLevel = gamification.xpForNextLevel;
    final badgeCount = gamification.unlockedAbilities.length;
    final streakDays = gamification.currentStreak;

    return Drawer(
      backgroundColor: AstroTheme.surfaceColor,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AstroTheme.scaffoldBackground,
              AstroTheme.surfaceColor,
            ],
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Profile Header
            _buildDrawerHeader(
              context,
              userName,
              currentLevel,
              currentXP,
              xpForNextLevel,
              badgeCount,
              streakDays,
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'QUICK ACCESS',
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 12,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            _buildActionItem(
              context,
              icon: Icons.wb_sunny,
              label: 'Day Ahead',
              color: AstroTheme.accentGold,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DayAheadScreen()),
                );
              },
            ),
            _buildActionItem(
              context,
              icon: Icons.emoji_events,
              label: 'Achievements',
              color: AstroTheme.accentPurple,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AchievementsScreen()),
                );
              },
            ),
            _buildActionItem(
              context,
              icon: Icons.favorite,
              label: 'Relationship Report',
              color: AstroTheme.accentPink,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const RelationshipReportScreen()),
                );
              },
            ),
            _buildActionItem(
              context,
              icon: Icons.api,
              label: 'SVG Chart Generator',
              color: Colors.teal,
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/chart-demo');
              },
            ),

            const Divider(color: Colors.white12, height: 32),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'PROFILE & SETTINGS',
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 12,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Profile Details
            _buildActionItem(
              context,
              icon: Icons.person,
              label: 'My Profile',
              color: AstroTheme.accentCyan,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              },
            ),

            // Birth Details / Calculator
            _buildActionItem(
              context,
              icon: hasChart ? Icons.edit : Icons.add_circle,
              label: hasChart ? 'Edit Birth Details' : 'Enter Birth Details',
              color: hasChart ? AstroTheme.accentGold : Colors.green,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BirthDetailsScreen()),
                );
              },
            ),

            // Show current birth details if available
            if (hasChart && session.birthDetails != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AstroTheme.accentCyan.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AstroTheme.accentCyan.withOpacity(0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.check_circle,
                              color: Colors.green, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            'Chart Generated',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${session.birthDetails!.name}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${session.birthDetails!.cityName}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        _formatDate(session.birthDetails!.birthDateTime),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // ── UPDATE CHECK ──
            const Divider(color: Colors.white12, height: 32),
            _buildUpdateTile(context),
            const SizedBox(height: 4),
            _buildTestNotificationTile(context),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final amPm = dt.hour >= 12 ? 'PM' : 'AM';
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year} at $hour:${dt.minute.toString().padLeft(2, '0')} $amPm';
  }

  Widget _buildDrawerHeader(
    BuildContext context,
    String userName,
    int level,
    int currentXP,
    int xpForNextLevel,
    int badgeCount,
    int streakDays,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 48, 16, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AstroTheme.accentPurple.withOpacity(0.3),
            AstroTheme.accentCyan.withOpacity(0.2),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Picture and Name
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
            child: Row(
              children: [
                Hero(
                  tag: 'profile_pic',
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AstroTheme.primaryGradient,
                    ),
                    child: const CircleAvatar(
                      radius: 32,
                      backgroundColor: AstroTheme.surfaceColor,
                      child: Icon(Icons.person, size: 32, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          gradient: AstroTheme.goldGradient,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Level $level',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios,
                    color: Colors.white38, size: 16),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Level Progress Bar
          LevelProgressBar(
            currentLevel: level,
            currentXP: currentXP,
            xpForNextLevel: xpForNextLevel,
            showDetails: true,
            height: 8,
          ),

          const SizedBox(height: 16),

          // Stats Row
          Row(
            children: [
              _buildStatBadge(Icons.local_fire_department,
                  '$streakDays Day Streak', Colors.orange),
              const SizedBox(width: 12),
              _buildStatBadge(
                  Icons.stars, '$badgeCount Badges', AstroTheme.accentPurple),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatBadge(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        label,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 15,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      onTap: onTap,
    );
  }

  // ── Update Checker Tile ──
  Widget _buildUpdateTile(BuildContext context) {
    final updateService = AppUpdateService();
    final hasUpdate = updateService.isUpdateAvailable;

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: (hasUpdate ? Colors.green : Colors.blueGrey).withOpacity(0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: _isCheckingUpdate
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white70,
                ),
              )
            : Icon(
                hasUpdate ? Icons.system_update : Icons.update,
                color: hasUpdate ? Colors.green : Colors.blueGrey,
                size: 20,
              ),
      ),
      title: Text(
        hasUpdate ? 'Update Available!' : 'Check for Updates',
        style: TextStyle(
          color: hasUpdate ? Colors.green : Colors.white70,
          fontSize: 15,
          fontWeight: hasUpdate ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: Text(
        updateService.timeSinceLastCheck,
        style: TextStyle(
          color: Colors.white38,
          fontSize: 11,
        ),
      ),
      trailing: hasUpdate
          ? Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
            )
          : null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      onTap: _isCheckingUpdate ? null : () => _handleUpdateCheck(context),
    );
  }

  Future<void> _handleUpdateCheck(BuildContext context) async {
    setState(() => _isCheckingUpdate = true);

    final result = await AppUpdateService().checkForUpdates();

    if (!mounted) return;
    setState(() => _isCheckingUpdate = false);

    // No update or error → just show a toast
    if (!result.success) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ ${result.error ?? "Check failed"}'),
          backgroundColor: Colors.red.shade800,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    if (!result.hasUpdate) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 18),
              SizedBox(width: 10),
              Text('You\'re up to date! ✨'),
            ],
          ),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    // Update available → show full dialog
    if (!context.mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A3E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.system_update, color: Colors.amber),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Update Available',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.amber.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Latest Commit',
                      style: TextStyle(
                          color: Colors.amber,
                          fontSize: 11,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(result.commitMessage ?? '',
                      style:
                          const TextStyle(color: Colors.white, fontSize: 14)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Current', result.currentSha ?? '—'),
            const SizedBox(height: 6),
            _buildInfoRow('Latest', result.latestSha ?? '—'),
            const SizedBox(height: 6),
            _buildInfoRow('Date', result.commitDate ?? '—'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await AppUpdateService().acknowledgeUpdate();
              if (ctx.mounted) Navigator.pop(ctx);
              if (mounted) setState(() {});
            },
            child: const Text('Mark as Updated',
                style: TextStyle(color: Colors.green)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close', style: TextStyle(color: Colors.white70)),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 60,
          child: Text(label,
              style: const TextStyle(color: Colors.white38, fontSize: 12)),
        ),
        Text(value,
            style: const TextStyle(
                color: Colors.white, fontSize: 13, fontFamily: 'monospace')),
      ],
    );
  }

  Widget _buildTestNotificationTile(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.deepPurple.withOpacity(0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.notifications_active,
            color: Colors.deepPurple, size: 20),
      ),
      title: const Text(
        'Test Notification',
        style: TextStyle(color: Colors.white70, fontSize: 15),
      ),
      subtitle: const Text(
        'Fire a test device notification',
        style: TextStyle(color: Colors.white38, fontSize: 11),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      onTap: () async {
        await LocalNotificationService().showNow(
          title: '🔔 AstroLearn Notification Test',
          body: 'Your cosmic notifications are working! ✨🌟',
          payload: 'test',
        );
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 18),
                SizedBox(width: 10),
                Text('Notification sent! Check your tray 🔔'),
              ],
            ),
            backgroundColor: Colors.deepPurple,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: const Duration(seconds: 3),
          ),
        );
      },
    );
  }
}
