import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../app/theme.dart';
import '../../../shared/widgets/level_progress_bar.dart';
import '../../../shared/widgets/astro_background.dart';
import '../../../shared/widgets/ability_card.dart';
import '../../../core/constants/learning_roadmap.dart';
import '../../../core/services/gamification_service.dart';
import '../../../core/services/user_session.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gamification = GamificationService();
    final session = UserSession();
    final userName = session.birthDetails?.name ?? 'Vedic Sage';
    final birthPlace = session.birthDetails?.cityName;

    final currentLevel = gamification.currentLevel;
    final totalXP = gamification.totalXP;
    final currentXP = totalXP % ((currentLevel * 100) + 100);
    final xpForNextLevel = (currentLevel * 100) + 100;
    final xpToNextLevel = (xpForNextLevel - currentXP).clamp(0, xpForNextLevel);

    final completedChapters = gamification.completedChapterCount;
    final currentStreak = gamification.currentStreak;
    final unlockedAbilities = gamification.unlockedAbilities.length;
    final totalAbilities = AbilityRegistry.coreAbilities.length;
    final achievementsUnlocked = 3;

    return AstroBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              expandedHeight: 340,
              pinned: true,
              stretch: true,
              backgroundColor: Colors.transparent,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                'Profile',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                ),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: _buildHeader(
                  userName: userName,
                  birthPlace: birthPlace,
                  level: currentLevel,
                  totalXP: totalXP,
                  currentXP: currentXP,
                  xpForNextLevel: xpForNextLevel,
                  streak: currentStreak,
                  xpToNextLevel: xpToNextLevel,
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              sliver: SliverList(
                delegate: SliverChildListDelegate(
                  [
                    _buildSectionLabel(
                      title: 'Overview',
                      subtitle: 'Your current learning momentum at a glance',
                    ),
                    const SizedBox(height: 12),
                    _buildOverviewBand(
                      completedChapters: completedChapters,
                      unlockedAbilities: unlockedAbilities,
                      totalAbilities: totalAbilities,
                    ),
                    const SizedBox(height: 24),
                    _buildSectionLabel(
                      title: 'Statistics',
                      subtitle: 'Growth milestones from your study journey',
                    ),
                    const SizedBox(height: 14),
                    _buildStatsGrid(
                      completedChapters: completedChapters,
                      streak: currentStreak,
                      badges: unlockedAbilities,
                      achievements: achievementsUnlocked,
                    ),
                    const SizedBox(height: 26),
                    _buildSectionLabel(
                      title: 'Unlocked Abilities',
                      subtitle:
                          'Personality insights revealed through learning',
                    ),
                    const SizedBox(height: 12),
                    _buildAbilitiesPanel(),
                    const SizedBox(height: 26),
                    _buildSectionLabel(
                      title: 'Learning Journey',
                      subtitle: 'How your Vedic path is unfolding',
                    ),
                    const SizedBox(height: 12),
                    _buildJourneyCard(
                      completedChapters: completedChapters,
                      currentStreak: currentStreak,
                      xpToNextLevel: xpToNextLevel,
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

  Widget _buildHeader({
    required String userName,
    required String? birthPlace,
    required int level,
    required int totalXP,
    required int currentXP,
    required int xpForNextLevel,
    required int streak,
    required int xpToNextLevel,
  }) {
    final initial = userName.trim().isNotEmpty ? userName.trim()[0] : 'V';

    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AstroTheme.accentPurple.withValues(alpha: 0.45),
                AstroTheme.accentCyan.withValues(alpha: 0.25),
                Colors.transparent,
              ],
              stops: const [0.0, 0.55, 1.0],
            ),
          ),
        ),
        Positioned(
          top: -40,
          right: -20,
          child: _glowOrb(AstroTheme.accentCyan.withValues(alpha: 0.25), 150),
        ),
        Positioned(
          top: 80,
          left: -30,
          child: _glowOrb(AstroTheme.accentPurple.withValues(alpha: 0.22), 120),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _frostedCard(
                  child: Row(
                    children: [
                      Hero(
                        tag: 'profile_pic',
                        child: Container(
                          width: 76,
                          height: 76,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: AstroTheme.primaryGradient,
                            boxShadow: [
                              BoxShadow(
                                color: AstroTheme.accentPurple
                                    .withValues(alpha: 0.45),
                                blurRadius: 24,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Container(
                              width: 70,
                              height: 70,
                              decoration: const BoxDecoration(
                                color: AstroTheme.surfaceColor,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  initial.toUpperCase(),
                                  style: GoogleFonts.outfit(
                                    color: Colors.white,
                                    fontSize: 30,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userName,
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                height: 1.1,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              birthPlace == null
                                  ? 'Astro seeker'
                                  : 'Born in $birthPlace',
                              style: GoogleFonts.quicksand(
                                color: Colors.white.withValues(alpha: 0.62),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _headerChip(
                                  icon: Icons.stars_rounded,
                                  label: 'Lv $level',
                                  color: AstroTheme.accentGold,
                                ),
                                _headerChip(
                                  icon: Icons.local_fire_department_rounded,
                                  label: '$streak day streak',
                                  color: Colors.orangeAccent,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                _frostedCard(
                  child: Column(
                    children: [
                      LevelProgressBar(
                        currentLevel: level,
                        currentXP: currentXP,
                        xpForNextLevel: xpForNextLevel,
                        showDetails: true,
                        height: 9,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _metaStat(
                              title: 'Total XP',
                              value: '$totalXP',
                              color: AstroTheme.accentCyan,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _metaStat(
                              title: 'To Next Level',
                              value: '$xpToNextLevel XP',
                              color: AstroTheme.accentPurple,
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
        ),
      ],
    );
  }

  Widget _buildSectionLabel({
    required String title,
    required String subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: GoogleFonts.outfit(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.4,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: GoogleFonts.quicksand(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewBand({
    required int completedChapters,
    required int unlockedAbilities,
    required int totalAbilities,
  }) {
    final completionRatio =
        totalAbilities == 0 ? 0.0 : unlockedAbilities / totalAbilities;
    final percent = (completionRatio * 100).round();

    return _frostedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AstroTheme.accentCyan.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.auto_graph_rounded,
                  color: AstroTheme.accentCyan,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '$completedChapters chapters completed and climbing',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '$percent%',
                style: GoogleFonts.jetBrainsMono(
                  color: AstroTheme.accentGold,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: completionRatio.clamp(0.0, 1.0),
              minHeight: 7,
              backgroundColor: Colors.white.withValues(alpha: 0.08),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AstroTheme.accentPurple),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$unlockedAbilities of $totalAbilities abilities unlocked',
            style: GoogleFonts.quicksand(
              color: Colors.white.withValues(alpha: 0.58),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid({
    required int completedChapters,
    required int streak,
    required int badges,
    required int achievements,
  }) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.25,
      children: [
        _buildStatCard(
          icon: Icons.menu_book_rounded,
          label: 'Chapters',
          value: '$completedChapters',
          color: AstroTheme.accentCyan,
        ),
        _buildStatCard(
          icon: Icons.local_fire_department_rounded,
          label: 'Current Streak',
          value: '$streak',
          color: Colors.orangeAccent,
        ),
        _buildStatCard(
          icon: Icons.military_tech_rounded,
          label: 'Badges',
          value: '$badges',
          color: AstroTheme.accentGold,
        ),
        _buildStatCard(
          icon: Icons.verified_rounded,
          label: 'Achievements',
          value: '$achievements',
          color: AstroTheme.accentPurple,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return _frostedCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: GoogleFonts.outfit(
                  color: color,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: GoogleFonts.quicksand(
                  color: Colors.white.withValues(alpha: 0.64),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAbilitiesPanel() {
    return _frostedCard(
      padding: const EdgeInsets.all(12),
      child: _buildAbilitiesGrid(),
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
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.08,
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

  Widget _buildJourneyCard({
    required int completedChapters,
    required int currentStreak,
    required int xpToNextLevel,
  }) {
    final milestones = [
      _JourneyMilestone(
        title: 'Learning started',
        subtitle: 'You are actively building your Vedic foundation.',
        color: AstroTheme.accentCyan,
      ),
      _JourneyMilestone(
        title: '$completedChapters chapters completed',
        subtitle: 'Each completed chapter unlocks deeper patterns.',
        color: AstroTheme.accentPurple,
      ),
      _JourneyMilestone(
        title: '$currentStreak day streak',
        subtitle: '$xpToNextLevel XP left to hit your next level.',
        color: AstroTheme.accentGold,
      ),
    ];

    return _frostedCard(
      child: Column(
        children: [
          for (var i = 0; i < milestones.length; i++)
            _buildMilestoneItem(
              item: milestones[i],
              showConnector: i != milestones.length - 1,
            ),
        ],
      ),
    );
  }

  Widget _buildMilestoneItem({
    required _JourneyMilestone item,
    required bool showConnector,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 20,
            child: Column(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: item.color,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: item.color.withValues(alpha: 0.5),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
                if (showConnector)
                  Container(
                    width: 1.2,
                    height: 36,
                    margin: const EdgeInsets.only(top: 4),
                    color: Colors.white.withValues(alpha: 0.16),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.subtitle,
                    style: GoogleFonts.quicksand(
                      color: Colors.white.withValues(alpha: 0.58),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _frostedCard({
    required Widget child,
    EdgeInsets padding = const EdgeInsets.all(16),
  }) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.07),
            Colors.white.withValues(alpha: 0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: child,
    );
  }

  Widget _headerChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.32)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.outfit(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _metaStat({
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.quicksand(
              color: Colors.white.withValues(alpha: 0.65),
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: GoogleFonts.outfit(
              color: color,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _glowOrb(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}

class _JourneyMilestone {
  final String title;
  final String subtitle;
  final Color color;

  const _JourneyMilestone({
    required this.title,
    required this.subtitle,
    required this.color,
  });
}
