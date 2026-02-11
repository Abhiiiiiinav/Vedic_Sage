import 'package:flutter/material.dart';
import '../../../app/theme.dart';
import '../../../shared/widgets/astro_card.dart';
import '../../../shared/widgets/section_card.dart';
import '../../../core/constants/astro_data.dart';
import '../../chart/screens/planet_detail_screen.dart';
import '../../../shared/widgets/astro_background.dart';

class QuestionsScreen extends StatefulWidget {
  const QuestionsScreen({super.key});

  @override
  State<QuestionsScreen> createState() => _QuestionsScreenState();
}

class _QuestionsScreenState extends State<QuestionsScreen> {
  String? _selectedCategory;

  final List<QuestionCategory> _categories = [
    QuestionCategory(
      id: 'career',
      name: 'Career',
      icon: '💼',
      description: 'Profession, success, and work life',
      houses: [10, 6, 2, 11],
      planets: ['Sun', 'Saturn', 'Mercury'],
      sampleQuestions: [
        'What career suits me best?',
        'When will I get a promotion?',
        'Should I change my job?',
      ],
    ),
    QuestionCategory(
      id: 'marriage',
      name: 'Marriage',
      icon: '💍',
      description: 'Relationships and partnerships',
      houses: [7, 2, 8, 12],
      planets: ['Venus', 'Jupiter', 'Moon'],
      sampleQuestions: [
        'When will I get married?',
        'What kind of partner suits me?',
        'How will my married life be?',
      ],
    ),
    QuestionCategory(
      id: 'money',
      name: 'Wealth',
      icon: '💰',
      description: 'Finances, income, and prosperity',
      houses: [2, 11, 5, 9],
      planets: ['Jupiter', 'Venus', 'Mercury'],
      sampleQuestions: [
        'How to increase my income?',
        'Am I destined for wealth?',
        'What blocks my financial growth?',
      ],
    ),
    QuestionCategory(
      id: 'health',
      name: 'Health',
      icon: '🏥',
      description: 'Physical and mental wellbeing',
      houses: [1, 6, 8, 12],
      planets: ['Sun', 'Moon', 'Mars'],
      sampleQuestions: [
        'What health issues should I watch for?',
        'How to improve my vitality?',
        'What is my mental health pattern?',
      ],
    ),
    QuestionCategory(
      id: 'education',
      name: 'Education',
      icon: '📚',
      description: 'Learning, skills, and knowledge',
      houses: [4, 5, 9, 2],
      planets: ['Mercury', 'Jupiter', 'Moon'],
      sampleQuestions: [
        'What subjects suit me best?',
        'Will I succeed in higher education?',
        'What skills should I develop?',
      ],
    ),
    QuestionCategory(
      id: 'relationships',
      name: 'Relationships',
      icon: '❤️',
      description: 'Family, friends, and connections',
      houses: [7, 4, 11, 3],
      planets: ['Venus', 'Moon', 'Mercury'],
      sampleQuestions: [
        'How are my family relationships?',
        'Will I have good friendships?',
        'What affects my connections?',
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return AstroBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: _selectedCategory == null
              ? _buildCategorySelection()
              : _buildAnalysisGuide(),
        ),
      ),
    );
  }

  Widget _buildCategorySelection() {
    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final category = _categories[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildCategoryCard(category),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: AstroTheme.cyanGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AstroTheme.accentCyan.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.help_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Find Answers in Your Chart',
                  style: AstroTheme.headingMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  'Learn which planets & houses to analyze',
                  style: AstroTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(QuestionCategory category) {
    return AstroCard(
      onTap: () => setState(() => _selectedCategory = category.id),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AstroTheme.accentPurple.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                category.icon,
                style: const TextStyle(fontSize: 28),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.name,
                  style: AstroTheme.headingSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  category.description,
                  style: AstroTheme.bodyMedium,
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
    );
  }

  Widget _buildAnalysisGuide() {
    final category = _categories.firstWhere((c) => c.id == _selectedCategory);
    
    return AstroBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              _buildAnalysisHeader(category),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    _buildHousesCard(category),
                    const SizedBox(height: 16),
                    _buildPlanetsCard(category),
                    const SizedBox(height: 16),
                    _buildQuestionsCard(category),
                    const SizedBox(height: 16),
                    _buildLearnMoreCard(category),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnalysisHeader(QuestionCategory category) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => setState(() => _selectedCategory = null),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AstroTheme.cardBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white),
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: AstroTheme.primaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                category.icon,
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${category.name} Analysis',
                  style: AstroTheme.headingSmall,
                ),
                Text(
                  'Chart areas to examine',
                  style: AstroTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHousesCard(QuestionCategory category) {
    return SectionCard(
      title: 'Relevant Houses',
      icon: Icons.home_outlined,
      accentColor: AstroTheme.accentGold,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Analyze these houses for ${category.name.toLowerCase()} matters:',
            style: AstroTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: category.houses.asMap().entries.map((entry) {
              final index = entry.key;
              final house = entry.value;
              final isMain = index == 0;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  gradient: isMain ? AstroTheme.primaryGradient : null,
                  color: isMain ? null : AstroTheme.cardBackgroundLight,
                  borderRadius: BorderRadius.circular(12),
                  border: isMain
                      ? null
                      : Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Column(
                  children: [
                    Text(
                      'H$house',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isMain ? Colors.white : Colors.white70,
                      ),
                    ),
                    if (isMain)
                      Text(
                        'Primary',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AstroTheme.accentGold.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AstroTheme.accentGold.withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.lightbulb_outline,
                  color: AstroTheme.accentGold,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'The ${_getOrdinal(category.houses[0])} house is the primary house for ${category.name.toLowerCase()}',
                    style: AstroTheme.bodyMedium.copyWith(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanetsCard(QuestionCategory category) {
    return SectionCard(
      title: 'Key Planets',
      icon: Icons.auto_awesome,
      accentColor: AstroTheme.accentCyan,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'These planets significantly influence ${category.name.toLowerCase()}:',
            style: AstroTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          ...category.planets.map((planet) {
            final color = AstroTheme.getPlanetColor(planet);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PlanetDetailScreen(planetId: planet.toLowerCase()),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: color.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            planet[0],
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          planet,
                          style: AstroTheme.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: color,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildQuestionsCard(QuestionCategory category) {
    return SectionCard(
      title: 'Sample Questions',
      icon: Icons.quiz_outlined,
      accentColor: AstroTheme.accentPink,
      child: Column(
        children: category.sampleQuestions.map((question) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.question_mark,
                size: 18,
                color: AstroTheme.accentPink,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  question,
                  style: AstroTheme.bodyLarge,
                ),
              ),
            ],
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildLearnMoreCard(QuestionCategory category) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AstroTheme.accentPurple.withOpacity(0.2),
            AstroTheme.accentPurple.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AstroTheme.accentPurple.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.school_outlined,
            color: AstroTheme.accentPurple,
            size: 40,
          ),
          const SizedBox(height: 16),
          Text(
            'Learning Tip',
            style: AstroTheme.headingSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'To analyze ${category.name.toLowerCase()}, first look at the ${_getOrdinal(category.houses[0])} house lord\'s placement, then check for any planets placed in the ${_getOrdinal(category.houses[0])} house, and finally examine the aspects on this house.',
            style: AstroTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getOrdinal(int number) {
    if (number == 1) return '1st';
    if (number == 2) return '2nd';
    if (number == 3) return '3rd';
    return '${number}th';
  }
}

class QuestionCategory {
  final String id;
  final String name;
  final String icon;
  final String description;
  final List<int> houses;
  final List<String> planets;
  final List<String> sampleQuestions;

  QuestionCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.description,
    required this.houses,
    required this.planets,
    required this.sampleQuestions,
  });
}
