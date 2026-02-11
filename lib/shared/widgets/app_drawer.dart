import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/roadmap/screens/roadmap_screen.dart';
import '../../features/chart/screens/chart_screen.dart';
import '../../features/nakshatra/screens/nakshatra_screen.dart';
import '../../features/questions/screens/questions_screen.dart';
import '../../features/names/screens/names_screen.dart';
import '../../features/growth/screens/growth_screen.dart';
import '../../features/arudha/screens/arudha_screen.dart';
import '../../features/daily/screens/day_ahead_screen.dart';
import '../../features/roadmap/screens/achievements_screen.dart';
import '../../features/calculator/screens/birth_details_screen.dart';
import '../../features/relationship/screens/relationship_report_screen.dart';
import '../../core/services/user_session.dart';
import 'level_progress_bar.dart';

class AppDrawer extends StatelessWidget {
  final int currentIndex;
  final Function(int) onNavigate;

  const AppDrawer({
    super.key,
    required this.currentIndex,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    // Get real user data from session
    final session = UserSession();
    final userName = session.birthDetails?.name ?? 'Vedic Explorer';
    final hasChart = session.hasData;
    
    // Mock gamification data (can be stored in DB later)
    const currentLevel = 5;
    const currentXP = 650;
    const xpForNextLevel = 1000;
    const badgeCount = 2;
    const streakDays = 4;

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
                'NAVIGATE',
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 12,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            
            // Navigation Items
            _buildDrawerItem(
              context,
              icon: Icons.map,
              label: 'Roadmap',
              index: 0,
            ),
            _buildDrawerItem(
              context,
              icon: Icons.auto_awesome,
              label: 'Birth Chart',
              index: 1,
            ),
            _buildDrawerItem(
              context,
              icon: Icons.stars,
              label: 'Nakshatra',
              index: 2,
            ),
            _buildDrawerItem(
              context,
              icon: Icons.help_rounded,
              label: 'Q&A',
              index: 3,
            ),
            _buildDrawerItem(
              context,
              icon: Icons.text_fields,
              label: 'Names',
              index: 4,
            ),
            _buildDrawerItem(
              context,
              icon: Icons.rocket_launch,
              label: 'Growth',
              index: 5,
            ),
            _buildDrawerItem(
              context,
              icon: Icons.visibility,
              label: 'Arudha',
              index: 6,
            ),
            _buildDrawerItem(
              context,
              icon: Icons.calculate,
              label: 'Calculator',
              index: 7,
            ),
            _buildDrawerItem(
              context,
              icon: Icons.access_time,
              label: 'Dasha Periods',
              index: 8,
            ),
            _buildDrawerItem(
              context,
              icon: Icons.calendar_today,
              label: 'Panchang',
              index: 9,
            ),
            
            const Divider(color: Colors.white12, height: 32),
            
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
                  MaterialPageRoute(builder: (_) => const RelationshipReportScreen()),
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
                    border: Border.all(color: AstroTheme.accentCyan.withOpacity(0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green, size: 16),
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

          ],
        ),
      ),
    );
  }
  
  String _formatDate(DateTime dt) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
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
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
                const Icon(Icons.arrow_forward_ios, color: Colors.white38, size: 16),
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
              _buildStatBadge(Icons.local_fire_department, '$streakDays Day Streak', Colors.orange),
              const SizedBox(width: 12),
              _buildStatBadge(Icons.stars, '$badgeCount Badges', AstroTheme.accentPurple),
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

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = currentIndex == index;
    
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? AstroTheme.accentCyan : Colors.white60,
        size: 24,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.white70,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 15,
        ),
      ),
      selected: isSelected,
      selectedTileColor: AstroTheme.accentCyan.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected
            ? BorderSide(color: AstroTheme.accentCyan.withOpacity(0.3))
            : BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      onTap: () {
        Navigator.pop(context);
        onNavigate(index);
      },
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
}
