import 'package:flutter/material.dart';
import '../../../app/theme.dart';
import '../../../core/data/quiz_data.dart';
import '../../../core/models/gamification_models.dart';
import '../../../core/services/gamification_service.dart';
import '../../../core/constants/learning_roadmap.dart';
import '../../../shared/widgets/astro_background.dart';
import '../../../shared/widgets/astro_card.dart';

class QuizScreen extends StatefulWidget {
  final String quizId;

  const QuizScreen({super.key, required this.quizId});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late Quiz? _quiz;
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _showExplanation = false;
  String? _selectedOptionId;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    _quiz = QuizData.getQuiz(widget.quizId);
  }

  void _handleOptionSelect(String optionId, bool isCorrect) {
    if (_showExplanation) return; // Prevent changing answer

    setState(() {
      _selectedOptionId = optionId;
      _showExplanation = true;
      if (isCorrect) {
        _score++;
      }
    });
  }

  void _nextQuestion() {
    if (_quiz == null) return;

    if (_currentQuestionIndex < _quiz!.questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _showExplanation = false;
        _selectedOptionId = null;
      });
    } else {
      _completeQuiz();
    }
  }

  Future<void> _completeQuiz() async {
    setState(() {
      _isCompleted = true;
    });

    final gamification = GamificationService();
    await gamification.initialize();
    final xpEarned =
        (_score / _quiz!.questions.length * _quiz!.xpReward).round();

    // Award XP
    await gamification.addXP(xpEarned);

    // Record activity for streak
    await gamification.recordActivity();

    // Mark lesson as completed
    await gamification.completeLesson(widget.quizId);

    // Check if this quiz completion triggers an ability unlock
    // Find which chapter this quiz belongs to
    for (final chapter in LearningRoadmap.chapters) {
      final hasQuiz = chapter.lessons.any(
        (l) => l.quizId == widget.quizId,
      );
      if (hasQuiz) {
        // Check if all lessons in this chapter are completed
        final allLessonsDone = chapter.lessons.every(
          (l) => gamification.completedLessons.contains(_lessonProgressKey(l)),
        );

        if (allLessonsDone) {
          final previousAbilities =
              List<String>.from(gamification.unlockedAbilities);
          await gamification.completeChapter(chapter.id);
          final newAbilities = gamification.unlockedAbilities;

          // Show ability unlock celebration if a new ability was earned
          final newlyUnlocked = newAbilities
              .where((a) => !previousAbilities.contains(a))
              .toList();
          if (newlyUnlocked.isNotEmpty && mounted) {
            final ability = AbilityRegistry.getAbilityById(newlyUnlocked.first);
            if (ability != null) {
              _showAbilityUnlockCelebration(ability);
            }
          }
        }
        break;
      }
    }
  }

  String _lessonProgressKey(Lesson lesson) => lesson.quizId ?? lesson.id;

  @override
  Widget build(BuildContext context) {
    if (_quiz == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('Error'),
        ),
        body: const Center(child: Text('Quiz not found')),
      );
    }

    return AstroBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          backgroundColor: Colors.transparent,
          title:
              Text(_quiz!.title, style: const TextStyle(color: Colors.white)),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: _isCompleted ? _buildCompletionScreen() : _buildQuizContent(),
      ),
    );
  }

  Widget _buildQuizContent() {
    final question = _quiz!.questions[_currentQuestionIndex];
    final totalQuestions = _quiz!.questions.length;
    final progress = (_currentQuestionIndex + 1) / totalQuestions;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white12,
              valueColor: AlwaysStoppedAnimation(AstroTheme.accentCyan),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Question ${_currentQuestionIndex + 1} of $totalQuestions',
            style: const TextStyle(color: Colors.white70),
            textAlign: TextAlign.right,
          ),

          const SizedBox(height: 32),

          // Question Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AstroTheme.cardBackground,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white10),
            ),
            child: Text(
              question.text,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 24),

          // Options
          ...question.options
              .map((option) => _buildOptionCard(option))
              .toList(),

          const SizedBox(height: 24),

          // Explanation & Next Button
          if (_showExplanation) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _selectedOptionId == null
                    ? Colors.transparent
                    : (question.options
                            .firstWhere((o) => o.id == _selectedOptionId)
                            .isCorrect
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1)),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _selectedOptionId == null
                      ? Colors.transparent
                      : (question.options
                              .firstWhere((o) => o.id == _selectedOptionId)
                              .isCorrect
                          ? Colors.green
                          : Colors.red),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        question.options
                                .firstWhere((o) => o.id == _selectedOptionId)
                                .isCorrect
                            ? Icons.check_circle
                            : Icons.cancel,
                        color: question.options
                                .firstWhere((o) => o.id == _selectedOptionId)
                                .isCorrect
                            ? Colors.green
                            : Colors.red,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          question.options
                                  .firstWhere((o) => o.id == _selectedOptionId)
                                  .isCorrect
                              ? 'Correct!'
                              : 'Incorrect',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: question.options
                                    .firstWhere(
                                        (o) => o.id == _selectedOptionId)
                                    .isCorrect
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    question.explanation,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _nextQuestion,
              style: ElevatedButton.styleFrom(
                backgroundColor: AstroTheme.accentCyan,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                _currentQuestionIndex < totalQuestions - 1
                    ? 'Next Question'
                    : 'Finish Quiz',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOptionCard(QuizOption option) {
    final isSelected = _selectedOptionId == option.id;
    final isShowAnswer = _showExplanation;

    Color borderColor = Colors.white10;
    Color backgroundColor = Colors.white.withOpacity(0.05);
    IconData? icon;
    Color? iconColor;

    if (isShowAnswer) {
      if (option.isCorrect) {
        borderColor = Colors.green;
        backgroundColor = Colors.green.withOpacity(0.1);
        icon = Icons.check_circle;
        iconColor = Colors.green;
      } else if (isSelected) {
        borderColor = Colors.red;
        backgroundColor = Colors.red.withOpacity(0.1);
        icon = Icons.cancel;
        iconColor = Colors.red;
      }
    } else if (isSelected) {
      borderColor = AstroTheme.accentCyan;
      backgroundColor = AstroTheme.accentCyan.withOpacity(0.1);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _handleOptionSelect(option.id, option.isCorrect),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: borderColor,
                width:
                    isSelected || (isShowAnswer && option.isCorrect) ? 2 : 1),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  option.text,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
              if (icon != null) ...[
                const SizedBox(width: 12),
                Icon(icon, color: iconColor),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompletionScreen() {
    final totalQuestions = _quiz!.questions.length;
    final percentage = _score / totalQuestions;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.emoji_events, size: 80, color: Colors.amber),
          const SizedBox(height: 20),
          const Text(
            'Quiz Completed!',
            style: TextStyle(
                fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 12),
          Text(
            'You scored $_score out of $totalQuestions',
            style: TextStyle(
                fontSize: 18,
                color: percentage >= 0.7
                    ? Colors.greenAccent
                    : Colors.orangeAccent),
          ),
          const SizedBox(height: 40),
          _buildScoreCard(),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AstroTheme.accentCyan,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Continue Learning',
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  void _showAbilityUnlockCelebration(Ability ability) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: AstroTheme.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Celebration icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AstroTheme.primaryGradient,
                  boxShadow: [
                    BoxShadow(
                      color: AstroTheme.accentPurple.withOpacity(0.5),
                      blurRadius: 24,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Center(
                  child:
                      Text(ability.icon, style: const TextStyle(fontSize: 40)),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                '✨ ABILITY UNLOCKED! ✨',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: Colors.amber,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                ability.title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                ability.description,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AstroTheme.accentPurple.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AstroTheme.accentPurple.withOpacity(0.3)),
                ),
                child: Text(
                  ability.personalityReveal,
                  style: const TextStyle(
                      color: Colors.white, fontSize: 13, height: 1.5),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AstroTheme.accentCyan,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Amazing!',
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AstroTheme.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        children: [
          const Text("XP Earned", style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 8),
          Text(
            "+${(_score / _quiz!.questions.length * _quiz!.xpReward).round()}",
            style: const TextStyle(
                fontSize: 32, fontWeight: FontWeight.bold, color: Colors.amber),
          ),
        ],
      ),
    );
  }
}
