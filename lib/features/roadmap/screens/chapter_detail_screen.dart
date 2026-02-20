import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../app/theme.dart';
import '../../../core/constants/learning_roadmap.dart';
import '../../../core/models/gamification_models.dart';
import '../../../core/services/gamification_service.dart';
import '../../../shared/widgets/astro_background.dart';
import 'lesson_detail_screen.dart';
import 'quiz_screen.dart';

class ChapterDetailScreen extends StatefulWidget {
  final LearningChapter chapter;

  const ChapterDetailScreen({super.key, required this.chapter});

  @override
  State<ChapterDetailScreen> createState() => _ChapterDetailScreenState();
}

class _ChapterDetailScreenState extends State<ChapterDetailScreen> {
  final GamificationService _gamification = GamificationService();
  bool _isLoading = true;
  Set<String> _completedLessonKeys = {};
  Set<String> _completedChapterIds = {};

  LearningChapter get chapter => widget.chapter;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    await _gamification.initialize();
    if (!mounted) return;
    setState(() {
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
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: AstroTheme.accentCyan,
                  strokeWidth: 2.4,
                ),
              )
            : _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    final categoryColor = _getCategoryColor(chapter.category);
    final totalLessons = chapter.lessons.length;
    final completedLessons =
        chapter.lessons.where((l) => _isLessonCompleted(l)).length;
    final isCompleted = _completedChapterIds.contains(chapter.id) ||
        (totalLessons > 0 && completedLessons >= totalLessons);
    final ratio = totalLessons == 0 ? 0.0 : completedLessons / totalLessons;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverAppBar(
          expandedHeight: 260,
          pinned: true,
          backgroundColor:
              AstroTheme.scaffoldBackground.withValues(alpha: 0.93),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Module',
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
                        categoryColor.withValues(alpha: 0.35),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 64, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.2),
                                ),
                              ),
                              child: Center(
                                child: Text(chapter.icon,
                                    style: const TextStyle(fontSize: 30)),
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
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700,
                                      height: 1.1,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    chapter.description,
                                    style: GoogleFonts.quicksand(
                                      color:
                                          Colors.white.withValues(alpha: 0.7),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            _infoChip(
                              icon: Icons.stars_rounded,
                              text: '+${chapter.xpReward} XP',
                              color: AstroTheme.accentGold,
                            ),
                            const SizedBox(width: 8),
                            _infoChip(
                              icon: isCompleted
                                  ? Icons.verified_rounded
                                  : Icons.play_circle_fill_rounded,
                              text: isCompleted ? 'Completed' : 'In Progress',
                              color: isCompleted
                                  ? AstroTheme.accentGreen
                                  : AstroTheme.accentCyan,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            value: ratio.clamp(0.0, 1.0),
                            minHeight: 7,
                            backgroundColor:
                                Colors.white.withValues(alpha: 0.15),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isCompleted
                                  ? AstroTheme.accentGreen
                                  : AstroTheme.accentCyan,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '$completedLessons / $totalLessons lessons completed',
                          style: GoogleFonts.quicksand(
                            color: Colors.white.withValues(alpha: 0.68),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: _buildSectionLabel('Lesson Plan'),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final lesson = chapter.lessons[index];
                final isQuiz = lesson.type == LessonType.quiz;
                final isDone = _isLessonCompleted(lesson);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _buildLessonTile(
                    lesson: lesson,
                    index: index,
                    isQuiz: isQuiz,
                    isDone: isDone,
                    accentColor: categoryColor,
                  ),
                );
              },
              childCount: chapter.lessons.length,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: _buildSectionLabel('Prerequisites'),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 32),
            child: _buildPrerequisitesCard(),
          ),
        ),
      ],
    );
  }

  Widget _buildLessonTile({
    required Lesson lesson,
    required int index,
    required bool isQuiz,
    required bool isDone,
    required Color accentColor,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _openLesson(lesson),
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AstroTheme.cardBackground.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDone
                  ? AstroTheme.accentGreen.withValues(alpha: 0.5)
                  : Colors.white.withValues(alpha: 0.09),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isDone
                      ? AstroTheme.accentGreen.withValues(alpha: 0.2)
                      : accentColor.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Center(
                  child: isDone
                      ? const Icon(Icons.check_rounded,
                          color: AstroTheme.accentGreen, size: 20)
                      : Icon(
                          isQuiz ? Icons.quiz_rounded : Icons.menu_book_rounded,
                          color: isQuiz ? AstroTheme.accentGold : accentColor,
                          size: 19,
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lesson.title,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${index + 1}. ${_lessonTypeLabel(lesson.type)}  ·  +${lesson.xpReward} XP',
                      style: GoogleFonts.quicksand(
                        color: Colors.white54,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white.withValues(alpha: 0.35),
                size: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrerequisitesCard() {
    if (chapter.prerequisites.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AstroTheme.cardBackground,
          borderRadius: BorderRadius.circular(14),
          border:
              Border.all(color: AstroTheme.accentGreen.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            const Icon(Icons.check_circle_rounded,
                color: AstroTheme.accentGreen, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'No prerequisites required for this module.',
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

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AstroTheme.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: chapter.prerequisites.map((id) {
          final prereq = LearningRoadmap.getChapterById(id);
          if (prereq == null) return const SizedBox.shrink();
          final done = _completedChapterIds.contains(id);
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Icon(
                  done
                      ? Icons.check_circle_rounded
                      : Icons.lock_outline_rounded,
                  color: done ? AstroTheme.accentGreen : Colors.white38,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(prereq.icon, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    prereq.title,
                    style: GoogleFonts.quicksand(
                      color: done ? Colors.white : Colors.white60,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label.toUpperCase(),
      style: GoogleFonts.outfit(
        color: Colors.white60,
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _infoChip({
    required IconData icon,
    required String text,
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
            text,
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

  bool _isLessonCompleted(Lesson lesson) {
    return _completedLessonKeys.contains(_lessonProgressKey(lesson));
  }

  String _lessonProgressKey(Lesson lesson) => lesson.quizId ?? lesson.id;

  Future<void> _openLesson(Lesson lesson) async {
    if (lesson.type == LessonType.quiz && lesson.quizId != null) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => QuizScreen(quizId: lesson.quizId!)),
      );
    } else {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => LessonDetailScreen(
            chapter: chapter,
            lesson: lesson,
          ),
        ),
      );
    }
    await _loadProgress();
  }

  String _lessonTypeLabel(LessonType type) {
    switch (type) {
      case LessonType.reading:
        return 'Reading';
      case LessonType.interactive:
        return 'Interactive';
      case LessonType.quiz:
        return 'Quiz';
      case LessonType.practice:
        return 'Practice';
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'planets':
        return AstroTheme.accentPurple;
      case 'houses':
        return AstroTheme.accentGold;
      case 'signs':
        return AstroTheme.accentCyan;
      case 'nakshatras':
        return AstroTheme.accentPink;
      case 'analysis':
        return const Color(0xFF4caf50);
      case 'dasha':
        return Colors.orange;
      case 'diagnostic':
        return const Color(0xFF00A88A);
      default:
        return AstroTheme.accentPurple;
    }
  }
}
