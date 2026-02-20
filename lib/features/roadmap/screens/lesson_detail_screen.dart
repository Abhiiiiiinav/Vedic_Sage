import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../app/theme.dart';
import '../../../core/models/gamification_models.dart';
import '../../../core/services/gamification_service.dart';
import '../../../shared/widgets/astro_background.dart';

class LessonDetailScreen extends StatefulWidget {
  final LearningChapter chapter;
  final Lesson lesson;

  const LessonDetailScreen({
    super.key,
    required this.chapter,
    required this.lesson,
  });

  @override
  State<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends State<LessonDetailScreen> {
  final GamificationService _gamification = GamificationService();
  bool _isLoading = true;
  bool _isCompleted = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    await _gamification.initialize();
    final key = _lessonProgressKey(widget.lesson);
    if (!mounted) return;
    setState(() {
      _isCompleted = _gamification.completedLessons.contains(key);
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AstroBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            _lessonTypeLabel(widget.lesson.type),
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: AstroTheme.accentCyan,
                  strokeWidth: 2.2,
                ),
              )
            : _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AstroTheme.cardBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AstroTheme.accentCyan.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        _lessonIcon(widget.lesson.type),
                        color: AstroTheme.accentCyan,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.chapter.title,
                            style: GoogleFonts.quicksand(
                              color: Colors.white54,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.lesson.title,
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  widget.lesson.content.trim().isEmpty
                      ? 'Detailed lesson content will be available soon. Complete this module to keep your learning streak active.'
                      : widget.lesson.content,
                  style: GoogleFonts.quicksand(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.55,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AstroTheme.cardBackground,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Row(
              children: [
                const Icon(Icons.stars_rounded,
                    color: AstroTheme.accentGold, size: 18),
                const SizedBox(width: 8),
                Text(
                  '+${widget.lesson.xpReward} XP on completion',
                  style: GoogleFonts.outfit(
                    color: AstroTheme.accentGold,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                if (_isCompleted)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AstroTheme.accentGreen.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'Completed',
                      style: GoogleFonts.outfit(
                        color: AstroTheme.accentGreen,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isSubmitting ? null : _completeLesson,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isCompleted
                    ? AstroTheme.accentGreen.withValues(alpha: 0.2)
                    : AstroTheme.accentCyan,
                foregroundColor:
                    _isCompleted ? AstroTheme.accentGreen : Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: Icon(
                _isCompleted ? Icons.check_circle_rounded : Icons.done_rounded,
                size: 18,
              ),
              label: Text(
                _isCompleted ? 'Already Completed' : 'Mark as Completed',
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _completeLesson() async {
    if (_isCompleted) {
      Navigator.pop(context, true);
      return;
    }
    setState(() => _isSubmitting = true);

    final lessonKey = _lessonProgressKey(widget.lesson);

    await _gamification.addXP(widget.lesson.xpReward);
    await _gamification.recordActivity();
    await _gamification.completeLesson(lessonKey);

    final updatedCompleted = _gamification.completedLessons.toSet()
      ..add(lessonKey);
    final chapterDone = widget.chapter.lessons.every(
        (lesson) => updatedCompleted.contains(_lessonProgressKey(lesson)));
    if (chapterDone) {
      await _gamification.completeChapter(widget.chapter.id);
    }

    if (!mounted) return;
    setState(() {
      _isSubmitting = false;
      _isCompleted = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Lesson completed! +${widget.lesson.xpReward} XP'),
        backgroundColor: AstroTheme.accentCyan,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _lessonProgressKey(Lesson lesson) => lesson.quizId ?? lesson.id;

  String _lessonTypeLabel(LessonType type) {
    switch (type) {
      case LessonType.reading:
        return 'Reading Lesson';
      case LessonType.interactive:
        return 'Interactive Lesson';
      case LessonType.quiz:
        return 'Quiz Lesson';
      case LessonType.practice:
        return 'Practice Lesson';
    }
  }

  IconData _lessonIcon(LessonType type) {
    switch (type) {
      case LessonType.reading:
        return Icons.menu_book_rounded;
      case LessonType.interactive:
        return Icons.touch_app_rounded;
      case LessonType.quiz:
        return Icons.quiz_rounded;
      case LessonType.practice:
        return Icons.edit_note_rounded;
    }
  }
}
