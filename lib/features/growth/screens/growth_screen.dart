import 'package:flutter/material.dart';
import '../../../app/theme.dart';
import '../../../shared/widgets/astro_card.dart';
import '../../../shared/widgets/section_card.dart';
import '../../../core/constants/astro_data.dart';
import '../../../shared/widgets/astro_background.dart';

class GrowthScreen extends StatefulWidget {
  const GrowthScreen({super.key});

  @override
  State<GrowthScreen> createState() => _GrowthScreenState();
}

class _GrowthScreenState extends State<GrowthScreen> {
  String? _selectedPlanet;

  final Map<String, List<GrowthExercise>> _exercises = {
    'mercury': [
      GrowthExercise('Read for 30 minutes daily', 'Improves analytical thinking'),
      GrowthExercise('Write in a journal', 'Enhances communication clarity'),
      GrowthExercise('Learn a new word daily', 'Expands vocabulary and wit'),
      GrowthExercise('Play word puzzles', 'Sharpens mental agility'),
    ],
    'mars': [
      GrowthExercise('30 min physical exercise', 'Builds discipline and energy'),
      GrowthExercise('Set daily challenges', 'Develops courage and initiative'),
      GrowthExercise('Practice assertive speech', 'Strengthens confidence'),
      GrowthExercise('Learn self-defense', 'Channels aggression positively'),
    ],
    'jupiter': [
      GrowthExercise('Study philosophy/spirituality', 'Expands wisdom'),
      GrowthExercise('Teach someone something', 'Develops mentoring ability'),
      GrowthExercise('Practice gratitude daily', 'Cultivates optimism'),
      GrowthExercise('Give without expecting return', 'Builds generosity'),
    ],
    'venus': [
      GrowthExercise('Appreciate art daily', 'Refines aesthetic sense'),
      GrowthExercise('Practice kindness in relationships', 'Improves harmony'),
      GrowthExercise('Create something beautiful', 'Develops creativity'),
      GrowthExercise('Dress mindfully', 'Enhances self-presentation'),
    ],
    'saturn': [
      GrowthExercise('Maintain strict routine', 'Builds discipline'),
      GrowthExercise('Complete difficult tasks first', 'Develops perseverance'),
      GrowthExercise('Serve those in need', 'Cultivates humility'),
      GrowthExercise('Practice patience exercises', 'Strengthens endurance'),
    ],
    'moon': [
      GrowthExercise('10 min meditation daily', 'Calms the mind'),
      GrowthExercise('Track emotional patterns', 'Builds self-awareness'),
      GrowthExercise('Connect with mother/nurturers', 'Heals emotional roots'),
      GrowthExercise('Create calming environment', 'Improves mental peace'),
    ],
    'sun': [
      GrowthExercise('Wake at sunrise', 'Boosts vitality'),
      GrowthExercise('Take leadership in small ways', 'Builds confidence'),
      GrowthExercise('Practice self-affirmations', 'Strengthens identity'),
      GrowthExercise('Set clear personal goals', 'Develops willpower'),
    ],
    'rahu': [
      GrowthExercise('Explore new technologies', 'Embraces innovation'),
      GrowthExercise('Challenge social norms mindfully', 'Develops uniqueness'),
      GrowthExercise('Practice detachment from outcomes', 'Reduces obsession'),
      GrowthExercise('Study foreign cultures', 'Expands worldview'),
    ],
    'ketu': [
      GrowthExercise('Practice meditation & silence', 'Deepens spirituality'),
      GrowthExercise('Let go of material attachments', 'Cultivates detachment'),
      GrowthExercise('Study ancient wisdom', 'Connects to past knowledge'),
      GrowthExercise('Serve without recognition', 'Develops humility'),
    ],
  };

  @override
  Widget build(BuildContext context) {
    return AstroBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: _selectedPlanet == null ? _buildPlanetSelection() : _buildExercises(),
        ),
      ),
    );
  }

  Widget _buildPlanetSelection() {
    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _buildZonesCard(),
              const SizedBox(height: 20),
              Text('Select a Planet to Strengthen', style: AstroTheme.headingSmall),
              const SizedBox(height: 12),
              ...['sun', 'moon', 'mars', 'mercury', 'jupiter', 'venus', 'saturn', 'rahu', 'ketu'].map((id) {
                final planet = AstroData.getPlanetById(id)!;
                final color = AstroTheme.getPlanetColor(id);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: AstroCard(
                    onTap: () => setState(() => _selectedPlanet = id),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(planet.symbol, style: TextStyle(fontSize: 24, color: color)),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(planet.name, style: AstroTheme.headingSmall),
                              Text(planet.karakas.first, style: AstroTheme.bodyMedium),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right, color: Colors.white38),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 40),
            ],
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
              gradient: const LinearGradient(colors: [Color(0xFF4caf50), Color(0xFF2e7d32)]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.rocket_launch, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Self-Improvement', style: AstroTheme.headingMedium),
                Text('Strengthen planets through action', style: AstroTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildZonesCard() {
    return SectionCard(
      title: 'Understanding Growth Zones',
      icon: Icons.info_outline,
      child: Text(
        'Each planet governs specific abilities. By practicing related behaviors, you strengthen that planet\'s influence in your life. This is behavioral astrology - effort modifies destiny.',
        style: AstroTheme.bodyLarge,
      ),
    );
  }

  Widget _buildExercises() {
    final planet = AstroData.getPlanetById(_selectedPlanet!)!;
    final color = AstroTheme.getPlanetColor(_selectedPlanet!);
    final exercises = _exercises[_selectedPlanet] ?? [];

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => setState(() => _selectedPlanet = null),
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
                decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                child: Center(child: Text(planet.symbol, style: TextStyle(fontSize: 24, color: color))),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${planet.name} Exercises', style: AstroTheme.headingSmall),
                    Text('Daily practices', style: AstroTheme.bodyMedium),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              ...exercises.asMap().entries.map((e) {
                final i = e.key;
                final ex = e.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AstroTheme.cardBackground,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: color.withOpacity(0.2)),
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
                            child: Text('${i + 1}', style: TextStyle(fontWeight: FontWeight.bold, color: color)),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(ex.title, style: AstroTheme.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
                              Text(ex.benefit, style: AstroTheme.bodyMedium),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF4caf50).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lightbulb_outline, color: Color(0xFF4caf50)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Consistency matters more than intensity. Small daily actions compound over time.',
                        style: AstroTheme.bodyMedium.copyWith(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ],
    );
  }
}

class GrowthExercise {
  final String title;
  final String benefit;
  GrowthExercise(this.title, this.benefit);
}
