import 'package:flutter/material.dart';
import '../../../app/theme.dart';
import '../../../core/constants/learning_roadmap.dart';
import '../../../core/models/gamification_models.dart';
import '../../../core/services/gamification_service.dart';
import '../../../shared/widgets/section_card.dart';
import 'quiz_screen.dart';

class ChapterDetailScreen extends StatelessWidget {
  final LearningChapter chapter;

  const ChapterDetailScreen({super.key, required this.chapter});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildOverviewCard(),
                const SizedBox(height: 16),
                _buildLessonsCard(context),
                const SizedBox(height: 16),
                _buildXPCard(),
                const SizedBox(height: 16),
                _buildPrerequisitesCard(),
                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final categoryColor = _getCategoryColor(chapter.category);
    
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: AstroTheme.scaffoldBackground,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black26,
borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                categoryColor.withOpacity(0.3),
                AstroTheme.scaffoldBackground,
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 60),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    chapter.icon,
                    style: const TextStyle(fontSize: 50),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      chapter.title,
                      style: AstroTheme.headingMedium,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewCard() {
    return SectionCard(
      title: 'About This Chapter',
      icon: Icons.info_outline,
      accentColor: AstroTheme.accentCyan,
      child: Text(
        chapter.description,
        style: AstroTheme.bodyLarge.copyWith(height: 1.6),
      ),
    );
  }

  Widget _buildLessonsCard(BuildContext context) {
    return SectionCard(
      title: 'Lessons',
      icon: Icons.school_outlined,
      accentColor: AstroTheme.accentPurple,
      child: Column(
        children: chapter.lessons.asMap().entries.map((entry) {
          final index = entry.key;
          final lesson = entry.value;
          final isQuiz = lesson.type == LessonType.quiz;
          final isCompleted = lesson.quizId != null && 
              GamificationService().completedLessons.contains(lesson.quizId);
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                   if (isQuiz && lesson.quizId != null) {
                     Navigator.push(
                       context,
                       MaterialPageRoute(builder: (_) => QuizScreen(quizId: lesson.quizId!)),
                     ).then((_) {
                       // Refresh state when coming back from quiz
                       (context as Element).markNeedsBuild();
                     });
                   } else {
                     // Handle other lesson types (currently just placeholder)
                     ScaffoldMessenger.of(context).showSnackBar(
                       const SnackBar(content: Text('This lesson content is under development.')),
                     );
                   }
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isCompleted 
                        ? AstroTheme.accentPurple.withOpacity(0.05) 
                        : AstroTheme.accentPurple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isCompleted 
                          ? AstroTheme.accentGreen.withOpacity(0.5)
                          : AstroTheme.accentPurple.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: AstroTheme.primaryGradient,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: isCompleted
                              ? const Icon(Icons.check, color: Colors.white, size: 24)
                              : (isQuiz 
                                  ? const Icon(Icons.quiz, color: Colors.white, size: 20)
                                  : Text(
                                      '${index + 1}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Colors.white,
                                      ),
                                    )),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              lesson.title,
                              style: AstroTheme.headingSmall.copyWith(fontSize: 16),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _getLessonTypeLabel(lesson.type),
                              style: AstroTheme.bodyMedium.copyWith(
                                color: AstroTheme.accentPurple,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right,
                        color: Colors.white38,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildXPCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AstroTheme.goldGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.stars, color: Colors.white, size: 40),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Chapter Reward',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '+${chapter.xpReward} XP',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrerequisitesCard() {
    if (chapter.prerequisites.isEmpty) {
      return SectionCard(
        title: 'Prerequisites',
        icon: Icons.check_circle_outline,
        accentColor: const Color(0xFF4caf50),
        child: Row(
          children: const [
            Icon(Icons.celebration, color: Color(0xFF4caf50)),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'No prerequisites! You can start this chapter right away.',
                style: TextStyle(color: Color(0xFF4caf50), fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      );
    }

    return SectionCard(
      title: 'Prerequisites',
      icon: Icons.lock_outline,
      accentColor: AstroTheme.accentGold,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Complete these chapters first:',
            style: AstroTheme.bodyMedium.copyWith(
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 12),
          ...chapter.prerequisites.map((prereqId) {
            final prereq = LearningRoadmap.getChapterById(prereqId);
            if (prereq == null) return const SizedBox.shrink();
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Text(prereq.icon, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      prereq.title,
                      style: AstroTheme.bodyLarge,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  String _getLessonTypeLabel(LessonType type) {
    switch (type) {
      case LessonType.reading:
        return '📖 Reading';
      case LessonType.interactive:
        return '🎮 Interactive';
      case LessonType.quiz:
        return '❓ Quiz';
      case LessonType.practice:
        return '✍️ Practice';
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
      default:
        return AstroTheme.accentPurple;
    }
  }
}
