import 'package:flutter/material.dart';
import '../../../app/theme.dart';
import '../../../core/constants/learning_roadmap.dart';
import '../../../core/models/gamification_models.dart';
import '../../../shared/widgets/astro_card.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock unlocked achievements
    final unlockedIds = ['first_steps', 'week_warrior', 'level_5'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievements & Badges'),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AstroTheme.cosmicGradient),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildHeader(unlockedIds.length, Achievements.all.length),
            const SizedBox(height: 24),
            ...Achievements.all.map((achievement) {
              final isUnlocked = unlockedIds.contains(achievement.id);
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildAchievementCard(achievement, isUnlocked),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(int unlocked, int total) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AstroTheme.primaryGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Icon(Icons.emoji_events, color: AstroTheme.accentGold, size: 48),
          const SizedBox(height: 12),
          Text(
            '$unlocked / $total Unlocked',
            style: AstroTheme.headingLarge.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: unlocked / total,
              minHeight: 10,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(AstroTheme.accentGold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementCard(Achievement achievement, bool isUnlocked) {
    return Opacity(
      opacity: isUnlocked ? 1.0 : 0.5,
      child: AstroCard(
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: isUnlocked
                    ? AstroTheme.goldGradient
                    : LinearGradient(
                        colors: [
                          Colors.grey.withOpacity(0.3),
                          Colors.grey.withOpacity(0.1),
                        ],
                      ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Text(
                      achievement.icon,
                      style: const TextStyle(fontSize: 32),
                    ),
                  ),
                  if (!isUnlocked)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.lock, color: Colors.white54),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    achievement.title,
                    style: AstroTheme.headingSmall.copyWith(
                      color: isUnlocked ? Colors.white : Colors.white54,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    achievement.description,
                    style: AstroTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.stars, size: 14, color: AstroTheme.accentGold),
                      const SizedBox(width: 4),
                      Text(
                        '+${achievement.xpReward} XP',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AstroTheme.accentGold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
