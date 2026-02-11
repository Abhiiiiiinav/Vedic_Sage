/// Gamification and progress tracking models for AstroLearn

/// User progress and gamification data
class UserProgress {
  final int totalXP;
  final int currentLevel;
  final Map<String, ChapterProgress> chapterProgress;
  final List<String> unlockedBadges;
  final List<String> completedAchievements;
  final DateTime lastActivityDate;
  final int currentStreak;

  const UserProgress({
    required this.totalXP,
    required this.currentLevel,
    required this.chapterProgress,
    required this.unlockedBadges,
    required this.completedAchievements,
    required this.lastActivityDate,
    required this.currentStreak,
  });

  int get xpForNextLevel => (currentLevel * 100) + 100;
  int get xpInCurrentLevel => totalXP - _xpForLevel(currentLevel);
  double get progressToNextLevel => xpInCurrentLevel / xpForNextLevel;

  int _xpForLevel(int level) {
    int total = 0;
    for (int i = 1; i <= level; i++) {
      total += (i * 100);
    }
    return total;
  }
}

/// Progress for a specific learning chapter
class ChapterProgress {
  final String chapterId;
  final bool isUnlocked;
  final bool isCompleted;
  final int completedLessons;
  final int totalLessons;
  final int earnedXP;
  final DateTime? completedDate;

  const ChapterProgress({
    required this.chapterId,
    required this.isUnlocked,
    required this.isCompleted,
    required this.completedLessons,
    required this.totalLessons,
    required this.earnedXP,
    this.completedDate,
  });

  double get progress => totalLessons > 0 ? completedLessons / totalLessons : 0;
}

/// Learning chapter/module definition
class LearningChapter {
  final String id;
  final String title;
  final String description;
  final String icon;
  final int orderIndex;
  final int xpReward;
  final List<String> prerequisites;
  final List<Lesson> lessons;
  final String category; // 'planets', 'houses', 'signs', 'nakshatras', 'analysis', 'dasha'

  const LearningChapter({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.orderIndex,
    required this.xpReward,
    required this.prerequisites,
    required this.lessons,
    required this.category,
  });
}

/// Individual lesson within a chapter
class Lesson {
  final String id;
  final String title;
  final String content;
  final int xpReward;
  final LessonType type;
  final String? quizId;

  const Lesson({
    required this.id,
    required this.title,
    required this.content,
    required this.xpReward,
    required this.type,
    this.quizId,
  });
}

enum LessonType {
  reading,
  interactive,
  quiz,
  practice,
}

/// Achievement/Badge definition
class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  final int xpReward;
  final AchievementType type;
  final int targetValue;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.xpReward,
    required this.type,
    required this.targetValue,
  });
}

enum AchievementType {
  chaptersCompleted,
  planetsLearned,
  housesLearned,
  signsLearned,
  nakshatrasLearned,
  daysStreak,
  totalXP,
  levelReached,
}

/// Daily challenge
class DailyChallenge {
  final String id;
  final String title;
  final String description;
  final int xpReward;
  final DateTime date;
  final bool isCompleted;

  const DailyChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.xpReward,
    required this.date,
    required this.isCompleted,
  });
}

/// Quiz definition
class Quiz {
  final String id;
  final String title;
  final String description;
  final List<QuizQuestion> questions;
  final int xpReward;

  const Quiz({
    required this.id,
    required this.title,
    required this.description,
    required this.questions,
    required this.xpReward,
  });
}

class QuizQuestion {
  final String id;
  final String text;
  final List<QuizOption> options;
  final String explanation;

  const QuizQuestion({
    required this.id,
    required this.text,
    required this.options,
    required this.explanation,
  });
}

class QuizOption {
  final String id;
  final String text;
  final bool isCorrect;

  const QuizOption({
    required this.id,
    required this.text,
    required this.isCorrect,
  });
}
