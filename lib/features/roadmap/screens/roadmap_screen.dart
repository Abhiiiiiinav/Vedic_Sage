import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../app/theme.dart';
import '../../../core/constants/learning_roadmap.dart';
import '../../../core/models/gamification_models.dart';
import '../../../core/services/gamification_service.dart';
import '../../../shared/widgets/astro_background.dart';
import '../../daily/screens/day_ahead_screen.dart';
import 'achievements_screen.dart';
import 'chapter_detail_screen.dart';

class RoadmapScreen extends StatefulWidget {
  const RoadmapScreen({super.key});

  @override
  State<RoadmapScreen> createState() => _RoadmapScreenState();
}

class _RoadmapScreenState extends State<RoadmapScreen> {
  final GamificationService _gamification = GamificationService();

  bool _isLoading = true;
  UserProgress? _progress;
  String _selectedCategory = 'all';
  Set<String> _completedLessonKeys = {};
  Set<String> _completedChapterIds = {};

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    await _gamification.initialize();
    final progress = _gamification.getProgress();

    if (!mounted) return;
    setState(() {
      _progress = progress;
      _completedLessonKeys = _gamification.completedLessons.toSet();
      _completedChapterIds = _gamification.completedChapters.toSet();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AstroBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: _isLoading ? _buildLoading() : _buildBody(),
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(
        color: AstroTheme.accentCyan,
        strokeWidth: 2.4,
      ),
    );
  }

  Widget _buildBody() {
    final progress = _progress!;
    final chapterStates = _buildChapterStates();
    final filtered = _selectedCategory == 'all'
        ? chapterStates
        : chapterStates
            .where((s) => s.chapter.category == _selectedCategory)
            .toList();
    final active = chapterStates.cast<_ChapterState?>().firstWhere(
          (s) => s != null && s.isUnlocked && !s.isCompleted,
          orElse: () => null,
        );

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        _buildAppBar(progress),
        SliverToBoxAdapter(child: _buildTopActions()),
        SliverToBoxAdapter(child: _buildSectionHeader('Continue Learning')),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: active == null
                ? _buildFinishedCard()
                : _buildActiveCard(active),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 22, 16, 10),
            child: _buildSectionHeader('Learning Path'),
          ),
        ),
        SliverToBoxAdapter(child: _buildCategoryChips()),
        if (filtered.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: _buildEmptyFilter(),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final item = filtered[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildChapterCard(item),
                  );
                },
                childCount: filtered.length,
              ),
            ),
          ),
      ],
    );
  }

  SliverAppBar _buildAppBar(UserProgress progress) {
    final completionPercent = (_completedChapterIds.length /
            (LearningRoadmap.chapters.isEmpty
                ? 1
                : LearningRoadmap.chapters.length) *
            100)
        .round();

    return SliverAppBar(
      expandedHeight: 260,
      pinned: true,
      backgroundColor: AstroTheme.scaffoldBackground.withValues(alpha: 0.92),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            color: Colors.white, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Learning Roadmap',
        style: GoogleFonts.outfit(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 19,
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AstroTheme.accentPurple.withValues(alpha: 0.36),
                    AstroTheme.accentCyan.withValues(alpha: 0.2),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            Positioned(
              right: -40,
              top: -20,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AstroTheme.accentCyan.withValues(alpha: 0.15),
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 58, 16, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Professional Jyotish Curriculum',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Structured modules, measurable progress, and milestone-based mastery.',
                      style: GoogleFonts.quicksand(
                        color: Colors.white.withValues(alpha: 0.66),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        _statPill(
                          icon: Icons.workspace_premium_rounded,
                          value: 'Lv ${progress.currentLevel}',
                          color: AstroTheme.accentGold,
                        ),
                        const SizedBox(width: 8),
                        _statPill(
                          icon: Icons.stars_rounded,
                          value: '${progress.totalXP} XP',
                          color: AstroTheme.accentCyan,
                        ),
                        const SizedBox(width: 8),
                        _statPill(
                          icon: Icons.timeline_rounded,
                          value: '$completionPercent%',
                          color: AstroTheme.accentPurple,
                        ),
                      ],
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

  Widget _buildTopActions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      child: Row(
        children: [
          Expanded(
            child: _actionButton(
              icon: Icons.emoji_events_rounded,
              label: 'Achievements',
              onTap: () => _openScreen(const AchievementsScreen()),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _actionButton(
              icon: Icons.wb_sunny_outlined,
              label: 'Daily Focus',
              onTap: () => _openScreen(const DayAheadScreen()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.outfit(
          color: Colors.white60,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildActiveCard(_ChapterState active) {
    final chapter = active.chapter;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _openChapter(chapter),
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF4D66FF), Color(0xFF00B6D9)],
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: AstroTheme.accentPurple.withValues(alpha: 0.35),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'IN PROGRESS',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(chapter.icon, style: const TextStyle(fontSize: 24)),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                chapter.title,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.w700,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                chapter.description,
                style: GoogleFonts.quicksand(
                  color: Colors.white.withValues(alpha: 0.82),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: active.lessonCompletionRatio,
                  minHeight: 7,
                  backgroundColor: Colors.white.withValues(alpha: 0.25),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    '${active.completedLessons}/${chapter.lessons.length} lessons',
                    style: GoogleFonts.quicksand(
                      color: Colors.white.withValues(alpha: 0.82),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '+${chapter.xpReward} XP',
                    style: GoogleFonts.jetBrainsMono(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFinishedCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AstroTheme.cardBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: AstroTheme.accentGreen.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.task_alt_rounded,
                color: AstroTheme.accentGreen, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'All unlocked modules are complete. Review completed chapters or keep a daily streak.',
              style: GoogleFonts.quicksand(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips() {
    final categories = <String>{
      'all',
      ...LearningRoadmap.chapters.map((c) => c.category),
    }.toList();

    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final selected = category == _selectedCategory;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(
                category == 'all'
                    ? 'All'
                    : category[0].toUpperCase() + category.substring(1),
                style: GoogleFonts.quicksand(
                  color: selected ? Colors.white : Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              selected: selected,
              onSelected: (_) => setState(() => _selectedCategory = category),
              showCheckmark: false,
              selectedColor: AstroTheme.accentPurple.withValues(alpha: 0.35),
              backgroundColor: Colors.white.withValues(alpha: 0.06),
              side: BorderSide(
                color: selected
                    ? AstroTheme.accentPurple.withValues(alpha: 0.7)
                    : Colors.white.withValues(alpha: 0.12),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyFilter() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AstroTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Text(
        'No modules in this category yet.',
        style: GoogleFonts.quicksand(
          color: Colors.white60,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildChapterCard(_ChapterState item) {
    final chapter = item.chapter;
    final statusColor = item.isCompleted
        ? AstroTheme.accentGreen
        : item.isUnlocked
            ? AstroTheme.accentCyan
            : Colors.white38;
    final statusLabel = item.isCompleted
        ? 'Completed'
        : item.isUnlocked
            ? 'Unlocked'
            : 'Locked';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: item.isUnlocked ? () => _openChapter(chapter) : null,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AstroTheme.cardBackground.withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: item.isUnlocked
                  ? Colors.white.withValues(alpha: 0.13)
                  : Colors.white.withValues(alpha: 0.06),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    chapter.icon,
                    style: TextStyle(
                      fontSize: 22,
                      color: item.isUnlocked ? null : Colors.white38,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      chapter.title,
                      style: GoogleFonts.outfit(
                        color: item.isUnlocked ? Colors.white : Colors.white54,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      chapter.description,
                      style: GoogleFonts.quicksand(
                        color: Colors.white.withValues(alpha: 0.52),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: item.lessonCompletionRatio,
                        minHeight: 5,
                        backgroundColor: Colors.white.withValues(alpha: 0.08),
                        valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      statusLabel,
                      style: GoogleFonts.outfit(
                        color: statusColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${item.completedLessons}/${chapter.lessons.length}',
                    style: GoogleFonts.jetBrainsMono(
                      color: Colors.white54,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    '+${chapter.xpReward} XP',
                    style: GoogleFonts.jetBrainsMono(
                      color: AstroTheme.accentGold,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statPill({
    required IconData icon,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 6),
          Text(
            value,
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

  Widget _actionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: AstroTheme.cardBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AstroTheme.accentCyan, size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.outfit(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<_ChapterState> _buildChapterStates() {
    final completedChapters = _completedChapterIds;
    final completedLessons = _completedLessonKeys;

    return LearningRoadmap.chapters.map((chapter) {
      final totalLessons = chapter.lessons.length;
      final doneLessons = chapter.lessons
          .where(
              (lesson) => completedLessons.contains(_lessonProgressKey(lesson)))
          .length;
      final isCompleted = completedChapters.contains(chapter.id) ||
          (totalLessons > 0 && doneLessons >= totalLessons);
      final isUnlocked = isCompleted ||
          chapter.prerequisites.every((p) => completedChapters.contains(p));

      return _ChapterState(
        chapter: chapter,
        isUnlocked: isUnlocked,
        isCompleted: isCompleted,
        completedLessons: doneLessons,
      );
    }).toList()
      ..sort((a, b) => a.chapter.orderIndex.compareTo(b.chapter.orderIndex));
  }

  String _lessonProgressKey(Lesson lesson) => lesson.quizId ?? lesson.id;

  Future<void> _openChapter(LearningChapter chapter) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ChapterDetailScreen(chapter: chapter)),
    );
    await _loadProgress();
  }

  Future<void> _openScreen(Widget screen) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
    await _loadProgress();
  }
}

class _ChapterState {
  final LearningChapter chapter;
  final bool isUnlocked;
  final bool isCompleted;
  final int completedLessons;

  const _ChapterState({
    required this.chapter,
    required this.isUnlocked,
    required this.isCompleted,
    required this.completedLessons,
  });

  double get lessonCompletionRatio =>
      chapter.lessons.isEmpty ? 0 : completedLessons / chapter.lessons.length;
}
