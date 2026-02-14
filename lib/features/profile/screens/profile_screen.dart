import 'package:flutter/material.dart';
import '../../../app/theme.dart';
import '../../../shared/widgets/level_progress_bar.dart';
import '../../../shared/widgets/astro_background.dart';
import '../../../shared/widgets/ability_card.dart';
import '../../../core/constants/learning_roadmap.dart';
import '../../../core/models/gamification_models.dart';
import '../../../core/services/gamification_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gamification = GamificationService();
    final userName = 'Vedic Sage';
    final currentLevel = gamification.currentLevel;
    final totalXP = gamification.totalXP;
    final currentXP = totalXP % ((currentLevel * 100) + 100);
    final xpForNextLevel = (currentLevel * 100) + 100;
    final completedChapters = gamification.completedChapterCount;
    final currentStreak = gamification.currentStreak;
    const badgesEarned = 2;
    const achievementsUnlocked = 3;

    return AstroBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        body: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              expandedHeight: 280,
              pinned: true,
              backgroundColor: Colors.transparent,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: _buildHeader(
                  userName,
                  currentLevel,
                  currentXP,
                  xpForNextLevel,
                  totalXP,
                ),
              ),
            ),
            // Statistics
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'STATISTICS',
                      style: TextStyle(
                        color: Colors.white38,
                        fontSize: 13,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildStatsGrid(
                      completedChapters,
                      currentStreak,
                      badgesEarned,
                      achievementsUnlocked,
                    ),
                    const SizedBox(height: 32),
                    // Abilities Section
                    const Text(
                      'UNLOCKED ABILITIES',
                      style: TextStyle(
                        color: Colors.white38,
                        fontSize: 13,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Personality insights revealed through learning',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildAbilitiesGrid(),
                    const SizedBox(height: 32),
                    const Text(
                      'LEARNING JOURNEY',
                      style: TextStyle(
                        color: Colors.white38,
                        fontSize: 13,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildJourneyCard(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    String userName,
    int level,
    int currentXP,
    int xpForNextLevel,
    int totalXP,
  ) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AstroTheme.accentPurple.withValues(alpha: 0.3),
                AstroTheme.accentCyan.withValues(alpha: 0.2),
              ],
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Avatar
                Hero(
                  tag: 'profile_pic',
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AstroTheme.primaryGradient,
                      boxShadow: [
                        BoxShadow(
                          color: AstroTheme.accentPurple.withValues(alpha: 0.5),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: const CircleAvatar(
                      radius: 50,
                      backgroundColor: AstroTheme.surfaceColor,
                      child: Icon(Icons.person, size: 50, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Name
                Text(
                  userName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                // Level Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: AstroTheme.goldGradient,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.stars, color: Colors.white, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'Level $level',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$totalXP Total XP',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 20),
                // Progress Bar
                LevelProgressBar(
                  currentLevel: level,
                  currentXP: currentXP,
                  xpForNextLevel: xpForNextLevel,
                  showDetails: true,
                  height: 10,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(
    int completedChapters,
    int streak,
    int badges,
    int achievements,
  ) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          'Completed Chapters',
          completedChapters.toString(),
          Icons.check_circle_outline,
          AstroTheme.accentCyan,
        ),
        _buildStatCard(
          'Day Streak',
          streak.toString(),
          Icons.local_fire_department,
          Colors.orange,
        ),
        _buildStatCard(
          'Badges Earned',
          badges.toString(),
          Icons.emoji_events,
          AstroTheme.accentGold,
        ),
        _buildStatCard(
          'Achievements',
          achievements.toString(),
          Icons.stars,
          AstroTheme.accentPurple,
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AstroTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJourneyCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AstroTheme.accentPurple.withValues(alpha: 0.2),
            AstroTheme.accentCyan.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AstroTheme.accentPurple.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.insights, color: AstroTheme.accentCyan, size: 24),
              SizedBox(width: 12),
              Text(
                'Your Journey',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildJourneyItem('Started learning', '2 weeks ago'),
          _buildJourneyItem('First milestone', 'Level 1 achieved'),
          _buildJourneyItem('Current progress', 'Mastering Moon'),
        ],
      ),
    );
  }

  Widget _buildJourneyItem(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AstroTheme.accentCyan,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAbilitiesGrid() {
    final abilities = AbilityRegistry.coreAbilities;
    final unlockedIds = GamificationService().unlockedAbilities.toSet();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.1,
      ),
      itemCount: abilities.length,
      itemBuilder: (context, index) {
        final ability = abilities[index];
        return AbilityCard(
          ability: ability,
          isUnlocked: unlockedIds.contains(ability.id),
        );
      },
    );
  }
}

