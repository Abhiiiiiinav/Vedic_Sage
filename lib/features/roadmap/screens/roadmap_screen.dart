import 'package:flutter/material.dart';
import 'dart:ui';
import '../../../app/theme.dart';
import '../../../core/constants/learning_roadmap.dart';
import '../../../core/models/gamification_models.dart';
import '../../../shared/widgets/astro_card.dart';
import '../../../shared/widgets/astro_background.dart';
import 'chapter_detail_screen.dart';

// Navigation Targets
import '../../chart/screens/chart_screen.dart';
import '../../nakshatra/screens/nakshatra_screen.dart';
import '../../questions/screens/questions_screen.dart';
import '../../names/screens/names_screen.dart';
import '../../growth/screens/growth_screen.dart';
import '../../arudha/screens/arudha_screen.dart';
import '../../daily/screens/day_ahead_screen.dart';
import '../../calculator/screens/birth_details_screen.dart';
import 'achievements_screen.dart';

class RoadmapScreen extends StatefulWidget {
  const RoadmapScreen({super.key});

  @override
  State<RoadmapScreen> createState() => _RoadmapScreenState();
}

class _RoadmapScreenState extends State<RoadmapScreen> with SingleTickerProviderStateMixin {
  late UserProgress _userProgress;
  String _selectedCategory = 'all';
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();
    
    // Initialize mock data (would come from service/provider in real app)
    _userProgress = UserProgress(
      totalXP: 850,
      currentLevel: 5,
      chapterProgress: {
        'planets_intro': ChapterProgress(
            chapterId: 'planets_intro', isUnlocked: true, isCompleted: true, completedLessons: 5, totalLessons: 5, earnedXP: 100, completedDate: DateTime.now()),
        'sun_deep_dive': ChapterProgress(
            chapterId: 'sun_deep_dive', isUnlocked: true, isCompleted: true, completedLessons: 6, totalLessons: 6, earnedXP: 150, completedDate: DateTime.now()),
        'moon_deep_dive': ChapterProgress(
            chapterId: 'moon_deep_dive', isUnlocked: true, isCompleted: false, completedLessons: 2, totalLessons: 6, earnedXP: 50),
      },
      unlockedBadges: ['seeker', 'first_step'],
      completedAchievements: [],
      lastActivityDate: DateTime.now(),
      currentStreak: 4,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AstroBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(),
          _buildQuickNavSection(),
          _buildSectionTitle("Current Module"),
          _buildActiveChapter(),
          _buildSectionTitle("Your Journey"),
          _buildTimelineList(),
          const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
        ],
      ),
    ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 280.0,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Header Gradient Background
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AstroTheme.scaffoldBackground,
                    AstroTheme.scaffoldBackground.withOpacity(0.0),
                  ],
                ),
              ),
            ),
            // User Stats Content
            SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   const SizedBox(height: 20),
                   Hero(
                     tag: 'profile_pic',
                     child: Container(
                       padding: const EdgeInsets.all(4),
                       decoration: BoxDecoration(
                         shape: BoxShape.circle,
                         gradient: AstroTheme.primaryGradient,
                         boxShadow: [BoxShadow(color: AstroTheme.accentPurple.withOpacity(0.5), blurRadius: 20)],
                       ),
                       child: const CircleAvatar(
                         radius: 40,
                         backgroundColor: Colors.black26, // Added background color for contrast
                         child: Icon(Icons.person, size: 40, color: Colors.white),
                       ),
                     ),
                   ),
                   const SizedBox(height: 12),
                   Text("Vedic Sage", style: AstroTheme.headingMedium),
                   Text("Level ${_userProgress.currentLevel} • ${_userProgress.totalXP} XP", 
                     style: AstroTheme.bodyMedium.copyWith(color: AstroTheme.accentCyan, fontWeight: FontWeight.bold)
                   ),
                   const SizedBox(height: 20),
                   Row(
                     mainAxisAlignment: MainAxisAlignment.center,
                     children: [
                       _buildStatChip(Icons.local_fire_department, "${_userProgress.currentStreak} Day Streak", Colors.orange),
                       const SizedBox(width: 12),
                       _buildStatChip(Icons.stars, "${_userProgress.unlockedBadges.length} Badges", Colors.purpleAccent),
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

  Widget _buildStatChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildQuickNavSection() {
    return SliverToBoxAdapter(
      child: Container(
        height: 110,
        margin: const EdgeInsets.symmetric(vertical: 20),
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          physics: const BouncingScrollPhysics(),
          children: [
            _buildNavCard("Chart", Icons.auto_awesome, AstroTheme.accentCyan, () => _navTo(const ChartScreen())),
            _buildNavCard("Nakshatra", Icons.star_outline, AstroTheme.accentPink, () => _navTo(const NakshatraScreen())),
            _buildNavCard("Q&A", Icons.help_outline, Colors.tealAccent, () => _navTo(const QuestionsScreen())),
            _buildNavCard("Names", Icons.badge, AstroTheme.accentGold, () => _navTo(const EnhancedNamesScreen())),
            _buildNavCard("Calc", Icons.calculate_outlined, Colors.orangeAccent, () => _navTo(const BirthDetailsScreen())),
            _buildNavCard("Growth", Icons.trending_up, Colors.greenAccent, () => _navTo(const GrowthScreen())),
            _buildNavCard("Arudha", Icons.visibility, Colors.deepPurpleAccent, () => _navTo(const ArudhaScreen())),
          ],
        ),
      ),
    );
  }

  Widget _buildNavCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: AstroTheme.cardBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white70)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Text(
          title.toUpperCase(),
          style: const TextStyle(
            color: Colors.white38,
            fontSize: 13,
            letterSpacing: 1.5,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildActiveChapter() {
    // Find first incomplete or last active
    final activeChapter = LearningRoadmap.chapters.firstWhere(
      (c) => _userProgress.chapterProgress[c.id]?.isCompleted == false,
      orElse: () => LearningRoadmap.chapters.first,
    );
    final progress = _userProgress.chapterProgress[activeChapter.id] ?? 
        ChapterProgress(chapterId: activeChapter.id, isUnlocked: true, isCompleted: false, completedLessons: 0, totalLessons: activeChapter.lessons.length, earnedXP: 0);

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverToBoxAdapter(
        child: GestureDetector(
          onTap: () => _navTo(ChapterDetailScreen(chapter: activeChapter)),
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [AstroTheme.accentPurple, AstroTheme.accentCyan]),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: AstroTheme.accentPurple.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 10))],
            ),
            child: Stack(
              children: [
                Positioned(right: -30, top: -30, child: Icon(Icons.explore, size: 150, color: Colors.white.withOpacity(0.1))),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(10)),
                        child: const Text("CONTINUE LEARNING", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                      const Spacer(),
                      Text(activeChapter.title, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, height: 1.2)),
                      const SizedBox(height: 8),
                      Text("Lesson ${progress.completedLessons + 1} of ${progress.totalLessons}", style: const TextStyle(color: Colors.white70)),
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: (progress.completedLessons / (progress.totalLessons > 0 ? progress.totalLessons : 1)),
                          backgroundColor: Colors.black26,
                          valueColor: const AlwaysStoppedAnimation(Colors.white),
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineList() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final chapter = LearningRoadmap.chapters[index];
            final progress = _userProgress.chapterProgress[chapter.id];
            final isLocked = false; // UNLOCKED: All modules are now accessible
            final isCompleted = progress?.isCompleted ?? false;
            
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: _buildTimelineItem(chapter, isLocked, isCompleted, index == LearningRoadmap.chapters.length - 1),
            );
          },
          childCount: LearningRoadmap.chapters.length,
        ),
      ),
    );
  }

  Widget _buildTimelineItem(LearningChapter chapter, bool isLocked, bool isCompleted, bool isLast) {
    final color = isLocked ? Colors.white12 : (isCompleted ? AstroTheme.accentGold : Colors.white);
    
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline Line & Dot
          SizedBox(
            width: 40,
            child: Column(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: isCompleted ? AstroTheme.accentGold : AstroTheme.scaffoldBackground,
                    shape: BoxShape.circle,
                    border: Border.all(color: isCompleted ? AstroTheme.accentGold : Colors.white24, width: 2),
                  ),
                  child: isCompleted ? const Icon(Icons.check, size: 10, color: Colors.black) : null,
                ),
                if (!isLast) 
                  Expanded(
                    child: Container(
                      width: 2,
                      color: Colors.white12,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                    ),
                  ),
              ],
            ),
          ),
          
          // Content Card
          Expanded(
            child: GestureDetector(
              onTap: isLocked ? null : () => _navTo(ChapterDetailScreen(chapter: chapter)),
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AstroTheme.cardBackground,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isLocked ? Colors.transparent : Colors.white10),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isLocked ? Colors.white10 : Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(chapter.icon, style: TextStyle(fontSize: 24, color: isLocked ? Colors.white24 : Colors.white)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            chapter.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isLocked ? Colors.white38 : Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${chapter.xpReward} XP Reward",
                            style: TextStyle(fontSize: 12, color: isLocked ? Colors.white12 : AstroTheme.accentGold),
                          ),
                        ],
                      ),
                    ),
                    if (isLocked) const Icon(Icons.lock_outline, color: Colors.white12),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navTo(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }
}
