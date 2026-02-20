import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../app/theme.dart';
import '../../../shared/widgets/bento_tile.dart';
import '../../../shared/widgets/astro_background.dart';
import '../../../shared/widgets/streak_widget.dart';
import '../../../shared/widgets/app_drawer.dart';
import '../../../core/services/user_session.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/services/gamification_service.dart';
import '../../../core/services/app_update_service.dart';
import '../../../core/constants/learning_roadmap.dart';
import '../../../core/models/gamification_models.dart';
import '../../roadmap/screens/roadmap_screen.dart';
import '../../roadmap/screens/chapter_detail_screen.dart';
import '../../chart/screens/chart_screen.dart';
import '../../nakshatra/screens/nakshatra_screen.dart';
import '../../questions/screens/questions_screen.dart';
import '../../names/screens/names_screen.dart';
import '../../growth/screens/growth_screen.dart';
import '../../arudha/screens/arudha_screen.dart';
import '../../calculator/screens/birth_details_screen.dart';
import '../../dasha/screens/dasha_screen.dart';
import '../../panchang/screens/panchang_screen.dart';
import '../../daily/screens/day_ahead_screen.dart';
import '../../relationship/screens/relationship_report_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../roadmap/screens/achievements_screen.dart';
import '../../friends/screens/friends_screen.dart';
import '../../pet/screens/cosmic_pet_screen.dart';
import '../../realm/screens/realm_map_screen.dart';
import '../../../core/services/daily_tasks_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  int _drawerNavIndex = -1;

  void _push(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => screen,
        transitionsBuilder: (_, anim, __, child) {
          return FadeTransition(
            opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 250),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = UserSession();
    final userName = session.birthDetails?.name ?? 'Explorer';
    final greeting = _getGreeting();
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = screenWidth < 380 ? 14.0 : 18.0;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AstroTheme.scaffoldBackground,
      drawer: AppDrawer(
        currentIndex: _drawerNavIndex,
        onNavigate: (index) {
          setState(() => _drawerNavIndex = index);
        },
      ),
      body: AstroBackground(
        child: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ─── Top Header ───
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(padding, 16, padding, 8),
                  child: Row(
                    children: [
                      // Hamburger menu with update dot
                      GestureDetector(
                        onTap: () => _scaffoldKey.currentState?.openDrawer(),
                        child: Stack(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: Colors.white12,
                                  width: 1,
                                ),
                              ),
                              child: const Center(
                                child: Icon(Icons.menu,
                                    color: Colors.white70, size: 22),
                              ),
                            ),
                            // Green dot if update available
                            if (AppUpdateService().isUpdateAvailable)
                              Positioned(
                                right: 2,
                                top: 2,
                                child: Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AstroTheme.scaffoldBackground,
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              greeting,
                              style: GoogleFonts.quicksand(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.white54,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              userName,
                              style: GoogleFonts.outfit(
                                fontSize: 26,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Streak counter
                      StreakWidget(
                        streakDays: GamificationService().currentStreak,
                        isAtRisk: GamificationService().isStreakAtRisk,
                      ),
                      const SizedBox(width: 10),
                      // Profile avatar
                      GestureDetector(
                        onTap: () => _push(context, const ProfileScreen()),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            gradient: AstroTheme.primaryGradient,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Colors.white24,
                              width: 1,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              userName.isNotEmpty
                                  ? userName[0].toUpperCase()
                                  : '✦',
                              style: GoogleFonts.outfit(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ─── Engagement Banner ───
              SliverToBoxAdapter(
                child: _buildEngagementBanner(context),
              ),

              // ─── Continue Learning Card ───
              SliverToBoxAdapter(
                child: _buildContinueLearningCard(context),
              ),

              // ─── Daily Tasks Card ───
              SliverToBoxAdapter(
                child: _buildDailyTasksCard(context),
              ),

              // ─── Section Label ───
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(padding, 16, padding, 10),
                  child: Text(
                    '✦  YOUR COSMOS',
                    style: GoogleFonts.quicksand(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AstroTheme.accentGold.withOpacity(0.7),
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),

              // ─── Bento Grid ───
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: padding),
                sliver: SliverToBoxAdapter(
                  child: _buildBentoGrid(context),
                ),
              ),

              // ─── Bottom Spacer ───
              const SliverToBoxAdapter(
                child: SizedBox(height: 24),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBentoGrid(BuildContext context) {
    const gap = 20.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: [
          // ─── Row 1: My Chart + Dasha (equal) ───
          SizedBox(
            height: 180,
            child: Row(
              children: [
                Expanded(
                  child: BentoTile(
                    title: 'My Chart',
                    subtitle: UserSession().hasData
                        ? '${UserSession().birthChart?['ascSign'] ?? 'Chart'} Lagna'
                        : 'Tap to generate',
                    icon: Icons.auto_awesome,
                    accentColor: const Color(0xFF667eea),
                    imagePath: 'assets/images/features/chart_scroll.jpg',
                    onTap: () => _push(context, const ChartScreen()),
                  ),
                ),
                const SizedBox(width: gap),
                Expanded(
                  child: BentoTile(
                    title: 'Dasha',
                    subtitle: 'Time periods',
                    icon: Icons.timeline_rounded,
                    accentColor: const Color(0xFFf5a623),
                    onTap: () => _push(context, const DashaScreen()),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: gap),

          // ─── Row 2: Day Ahead (hero full-width) ───
          SizedBox(
            height: 140,
            child: BentoTile(
              title: 'Day Ahead',
              subtitle: 'Today\'s cosmic forecast & guidance',
              icon: Icons.wb_sunny_rounded,
              accentColor: const Color(0xFFff6b9d),
              size: BentoTileSize.hero,
              onTap: () => _push(context, const DayAheadScreen()),
            ),
          ),
          const SizedBox(height: gap),

          // ─── Row 3: Learn + Panchang ───
          SizedBox(
            height: 180,
            child: Row(
              children: [
                Expanded(
                  child: BentoTile(
                    title: 'Learn',
                    subtitle: 'Vedic roadmap',
                    icon: Icons.menu_book_rounded,
                    accentColor: const Color(0xFF34c759),
                    onTap: () => _push(context, const RoadmapScreen()),
                  ),
                ),
                const SizedBox(width: gap),
                Expanded(
                  child: BentoTile(
                    title: 'Panchang',
                    subtitle: 'Hindu almanac',
                    icon: Icons.calendar_month_rounded,
                    accentColor: const Color(0xFF00d4ff),
                    imagePath: 'assets/images/features/panchang_temple.jpg',
                    onTap: () => _push(context, const PanchangScreen()),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: gap),

          // ─── Row 4: Ask AI + Names ───
          SizedBox(
            height: 180,
            child: Row(
              children: [
                Expanded(
                  child: BentoTile(
                    title: 'Ask AI',
                    subtitle: 'Chart Q&A',
                    icon: Icons.chat_bubble_rounded,
                    accentColor: const Color(0xFF7B61FF),
                    onTap: () => _push(context, const QuestionsScreen()),
                  ),
                ),
                const SizedBox(width: gap),
                Expanded(
                  child: BentoTile(
                    title: 'Names',
                    subtitle: 'Vedic analysis',
                    icon: Icons.text_fields_rounded,
                    accentColor: const Color(0xFFff2d55),
                    onTap: () => _push(context, const EnhancedNamesScreen()),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: gap),

          // ─── Row 5: Relationships + Arudha ───
          SizedBox(
            height: 180,
            child: Row(
              children: [
                Expanded(
                  child: BentoTile(
                    title: 'Relations',
                    subtitle: 'Compatibility',
                    icon: Icons.favorite_rounded,
                    accentColor: const Color(0xFFe91e63),
                    imagePath: 'assets/images/features/relations_rings.jpg',
                    onTap: () =>
                        _push(context, const RelationshipReportScreen()),
                  ),
                ),
                const SizedBox(width: gap),
                Expanded(
                  child: BentoTile(
                    title: 'Arudha',
                    subtitle: 'Perception',
                    icon: Icons.visibility_rounded,
                    accentColor: const Color(0xFF5856d6),
                    onTap: () => _push(context, const ArudhaScreen()),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: gap),

          // ─── Row 5.5: Cosmic Pet (hero full-width) ───
          SizedBox(
            height: 140,
            child: BentoTile(
              title: 'Cosmic Pet',
              subtitle: 'Daily guidance & growth',
              icon: Icons.pets_rounded,
              accentColor: const Color(0xFF7B61FF),
              size: BentoTileSize.hero,
              onTap: () => _push(context, const CosmicPetScreen()),
            ),
          ),
          const SizedBox(height: gap),

          // ─── Row 5.6: Friends (hero full-width) ───
          SizedBox(
            height: 140,
            child: BentoTile(
              title: 'Friends',
              subtitle: 'Add friends & compare charts',
              icon: Icons.people_rounded,
              accentColor: const Color(0xFF667eea),
              size: BentoTileSize.hero,
              onTap: () => _push(context, const FriendsScreen()),
            ),
          ),
          const SizedBox(height: gap),

          // ─── Row 5.7: Realm Map (hero full-width) ───
          SizedBox(
            height: 140,
            child: BentoTile(
              title: 'Realm Map',
              subtitle: 'Explore elemental worlds & visit friends',
              icon: Icons.map_rounded,
              accentColor: const Color(0xFF00d4ff),
              size: BentoTileSize.hero,
              onTap: () => _push(context, const RealmMapScreen()),
            ),
          ),
          const SizedBox(height: gap),

          // ─── Row 6: Growth + Nakshatra ───
          SizedBox(
            height: 180,
            child: Row(
              children: [
                Expanded(
                  child: BentoTile(
                    title: 'Growth',
                    subtitle: 'Exercises',
                    icon: Icons.spa_rounded,
                    accentColor: const Color(0xFF0d9488),
                    onTap: () => _push(context, const GrowthScreen()),
                  ),
                ),
                const SizedBox(width: gap),
                Expanded(
                  child: BentoTile(
                    title: 'Nakshatra',
                    subtitle: 'Star signs',
                    icon: Icons.stars_rounded,
                    accentColor: const Color(0xFFffcc00),
                    imagePath: 'assets/images/features/nakshatra_stars.jpg',
                    onTap: () => _push(context, const NakshatraScreen()),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: gap),

          // ─── Row 7: Calculator + Achievements (bottom row) ───
          SizedBox(
            height: 180,
            child: Row(
              children: [
                Expanded(
                  child: BentoTile(
                    title: 'Calculator',
                    subtitle: 'New chart',
                    icon: Icons.calculate_rounded,
                    accentColor: const Color(0xFF8e99a4),
                    onTap: () => _push(context, const BirthDetailsScreen()),
                  ),
                ),
                const SizedBox(width: gap),
                Expanded(
                  child: BentoTile(
                    title: 'Badges',
                    subtitle: 'Achievements',
                    icon: Icons.emoji_events_rounded,
                    accentColor: const Color(0xFFf5a623),
                    imagePath: 'assets/images/features/badges_medal.jpg',
                    onTap: () => _push(context, const AchievementsScreen()),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 5) return '🌙 Good night';
    if (hour < 12) return '🌅 Good morning';
    if (hour < 17) return '☀️ Good afternoon';
    if (hour < 21) return '🌇 Good evening';
    return '🌙 Good night';
  }

  Widget _buildEngagementBanner(BuildContext context) {
    final gamification = GamificationService();
    final nearestAbility = gamification.nearestUnlockableAbility;
    final banner = NotificationService().getEngagementBanner(
      lastActivityDate: gamification.lastActivityDate,
      currentStreak: gamification.currentStreak,
      totalXP: gamification.totalXP,
      nearestAbilityTitle: nearestAbility?.title,
      nearestAbilityChapter: nearestAbility != null
          ? LearningRoadmap.getChapterById(nearestAbility.unlockChapterId)
              ?.title
          : null,
    );

    if (banner == null) return const SizedBox.shrink();

    return EngagementBannerWidget(
      message: banner.message,
      icon: banner.icon,
      color: banner.color,
      onTap: () => _push(context, const RoadmapScreen()),
    );
  }

  Widget _buildContinueLearningCard(BuildContext context) {
    // Find first chapter that's not completed (mock: chapter 3 in progress)
    final activeChapter = LearningRoadmap.chapters.length > 2
        ? LearningRoadmap.chapters[2] // Moon deep dive
        : LearningRoadmap.chapters.first;

    return GestureDetector(
      onTap: () => _push(context, ChapterDetailScreen(chapter: activeChapter)),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AstroTheme.accentPurple.withOpacity(0.2),
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
                gradient: AstroTheme.primaryGradient,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(activeChapter.icon,
                  style: const TextStyle(fontSize: 24)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'CONTINUE LEARNING',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white38,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    activeChapter.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: 0.33,
                      backgroundColor: Colors.white10,
                      valueColor: AlwaysStoppedAnimation(AstroTheme.accentCyan),
                      minHeight: 4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AstroTheme.accentCyan.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child:
                  const Icon(Icons.play_arrow, color: Colors.white, size: 20),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyTasksCard(BuildContext context) {
    final taskService = DailyTasksService();
    final tasks = taskService.tasks;
    final completed = taskService.completedCount;
    final total = taskService.totalCount;

    if (total == 0) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1a1040).withOpacity(0.9),
            const Color(0xFF0d1b2a).withOpacity(0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AstroTheme.accentGold.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: AstroTheme.accentPurple.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row: title + progress ring
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: AstroTheme.goldGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.task_alt_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TASKS OF THE DAY',
                      style: GoogleFonts.quicksand(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AstroTheme.accentGold.withOpacity(0.8),
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$completed of $total completed',
                      style: GoogleFonts.quicksand(
                        fontSize: 12,
                        color: Colors.white54,
                      ),
                    ),
                  ],
                ),
              ),
              // Progress ring
              SizedBox(
                width: 44,
                height: 44,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 42,
                      height: 42,
                      child: CircularProgressIndicator(
                        value: total > 0 ? completed / total : 0,
                        strokeWidth: 3.5,
                        backgroundColor: Colors.white.withOpacity(0.08),
                        valueColor: AlwaysStoppedAnimation(
                          completed == total
                              ? const Color(0xFF34c759)
                              : AstroTheme.accentGold,
                        ),
                      ),
                    ),
                    Text(
                      completed == total ? '✓' : '$completed',
                      style: GoogleFonts.outfit(
                        fontSize: completed == total ? 16 : 14,
                        fontWeight: FontWeight.w700,
                        color: completed == total
                            ? const Color(0xFF34c759)
                            : Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Divider
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.white.withOpacity(0.1),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Task list
          ...tasks.asMap().entries.map((entry) {
            final task = entry.value;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: GestureDetector(
                onTap: () async {
                  await DailyTasksService().toggleTask(task.id);
                  setState(() {});
                },
                child: Row(
                  children: [
                    // Task icon
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: task.color
                            .withOpacity(task.isCompleted ? 0.1 : 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        task.icon,
                        size: 16,
                        color: task.isCompleted
                            ? task.color.withOpacity(0.4)
                            : task.color,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Task title & description
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task.title,
                            style: GoogleFonts.outfit(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w500,
                              color: task.isCompleted
                                  ? Colors.white38
                                  : Colors.white.withOpacity(0.85),
                              decoration: task.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                              decorationColor: Colors.white38,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (task.description.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              task.description,
                              style: GoogleFonts.quicksand(
                                fontSize: 11,
                                color: task.isCompleted
                                    ? Colors.white24
                                    : Colors.white38,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // XP badge
                    if (!task.isCompleted)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AstroTheme.accentGold.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '+15 XP',
                          style: GoogleFonts.quicksand(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: AstroTheme.accentGold,
                          ),
                        ),
                      ),
                    const SizedBox(width: 8),
                    // Checkbox
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: task.isCompleted
                            ? const Color(0xFF34c759)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(7),
                        border: Border.all(
                          color: task.isCompleted
                              ? const Color(0xFF34c759)
                              : Colors.white24,
                          width: 1.5,
                        ),
                      ),
                      child: task.isCompleted
                          ? const Icon(Icons.check,
                              size: 14, color: Colors.white)
                          : null,
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
