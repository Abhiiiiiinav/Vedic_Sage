import 'package:flutter/material.dart';
import '../../../app/theme.dart';
import '../../../core/constants/astro_data.dart';
import '../../../core/constants/planet_education_data.dart';
import '../../../core/models/models.dart';
import '../../../shared/widgets/section_card.dart';

class PlanetDetailScreen extends StatelessWidget {
  final String planetId;

  const PlanetDetailScreen({super.key, required this.planetId});

  @override
  Widget build(BuildContext context) {
    final planet = AstroData.getPlanetById(planetId);
    
    if (planet == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Not Found')),
        body: const Center(child: Text('Planet not found')),
      );
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AstroTheme.cosmicGradient,
        ),
        child: CustomScrollView(
          slivers: [
            _buildAppBar(context, planet),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildOverviewCard(planet),
                  const SizedBox(height: 16),
                  _buildKarakasCard(planet),
                  const SizedBox(height: 16),
                  _buildPsychologyCard(planet),
                  const SizedBox(height: 16),
                  _buildDailyBehaviorsCard(planet),
                  const SizedBox(height: 16),
                  _buildStrengtheningCard(planet),
                  const SizedBox(height: 16),
                  _buildWeaknessCard(planet),
                  const SizedBox(height: 16),
                  _buildMasterNoteCard(planet),
                  const SizedBox(height: 16),
                  _buildObservationCard(planet),
                  const SizedBox(height: 16),
                  _buildJournalCard(planet),
                  const SizedBox(height: 40),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, Planet planet) {
    return SliverAppBar(
      expandedHeight: 300,
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
                AstroTheme.getPlanetColor(planet.id).withOpacity(0.3),
                AstroTheme.scaffoldBackground,
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AstroTheme.getPlanetColor(planet.id).withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AstroTheme.getPlanetColor(planet.id).withOpacity(0.5),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AstroTheme.getPlanetColor(planet.id).withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      planet.symbol,
                      style: TextStyle(
                        fontSize: 40,
                        color: AstroTheme.getPlanetColor(planet.id),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  planet.name,
                  style: AstroTheme.headingLarge,
                ),
                Text(
                  planet.sanskritName,
                  style: AstroTheme.bodyMedium.copyWith(
                    color: AstroTheme.accentGold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewCard(Planet planet) {
    return SectionCard(
      title: 'Overview',
      icon: Icons.info_outline,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow('Natural Role', planet.naturalRole),
          const SizedBox(height: 12),
          _buildInfoRow('Element', planet.element),
          const SizedBox(height: 12),
          _buildInfoRow('Nature', planet.nature),
        ],
      ),
    );
  }

  Widget _buildKarakasCard(Planet planet) {
    return SectionCard(
      title: 'What It Governs (Karakas)',
      icon: Icons.category_outlined,
      accentColor: AstroTheme.accentGold,
      child: Column(
        children: planet.karakas.map((karaka) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 6),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AstroTheme.accentGold,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  karaka,
                  style: AstroTheme.bodyLarge,
                ),
              ),
            ],
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildPsychologyCard(Planet planet) {
    return SectionCard(
      title: 'Psychological Tendencies',
      icon: Icons.psychology_outlined,
      accentColor: AstroTheme.accentCyan,
      child: Column(
        children: planet.psychologicalTendencies.map((tendency) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.fiber_manual_record,
                size: 8,
                color: AstroTheme.accentCyan,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  tendency,
                  style: AstroTheme.bodyLarge,
                ),
              ),
            ],
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildDailyBehaviorsCard(Planet planet) {
    return SectionCard(
      title: 'How It Shows in Daily Life',
      icon: Icons.calendar_today_outlined,
      accentColor: AstroTheme.accentPink,
      child: Column(
        children: planet.dailyBehaviors.map((behavior) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.arrow_right,
                size: 20,
                color: AstroTheme.accentPink,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  behavior,
                  style: AstroTheme.bodyLarge,
                ),
              ),
            ],
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildStrengtheningCard(Planet planet) {
    return SectionCard(
      title: 'How to Strengthen',
      icon: Icons.fitness_center,
      accentColor: const Color(0xFF4caf50),
      child: Column(
        children: planet.strengtheningActions.map((action) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFF4caf50).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.check,
                  size: 14,
                  color: Color(0xFF4caf50),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  action,
                  style: AstroTheme.bodyLarge,
                ),
              ),
            ],
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildWeaknessCard(Planet planet) {
    final educationData = PlanetEducationData.getPlanet(planet.id);
    if (educationData == null) return const SizedBox.shrink();
    
    return SectionCard(
      title: 'Signs of Weakness',
      icon: Icons.warning_amber_outlined,
      accentColor: const Color(0xFFff6b35),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Watch for these patterns in your life:',
            style: AstroTheme.bodyMedium.copyWith(
              fontStyle: FontStyle.italic,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 12),
          ...educationData.weaknessIndicators.take(5).map((indicator) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.remove_circle_outline,
                  size: 16,
                  color: const Color(0xFFff6b35).withOpacity(0.8),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    indicator,
                    style: AstroTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          )),
          if (educationData.weaknessIndicators.length > 5)
            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              title: Text(
                'Show ${educationData.weaknessIndicators.length - 5} more...',
                style: TextStyle(
                  color: const Color(0xFFff6b35).withOpacity(0.8),
                  fontSize: 14,
                ),
              ),
              children: educationData.weaknessIndicators.skip(5).map((indicator) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.remove_circle_outline,
                      size: 16,
                      color: const Color(0xFFff6b35).withOpacity(0.8),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        indicator,
                        style: AstroTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              )).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildMasterNoteCard(Planet planet) {
    final educationData = PlanetEducationData.getPlanet(planet.id);
    if (educationData == null) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AstroTheme.accentGold.withOpacity(0.15),
            AstroTheme.accentGold.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AstroTheme.accentGold.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, color: AstroTheme.accentGold, size: 20),
              const SizedBox(width: 8),
              Text(
                'Astrologer\'s Insight',
                style: AstroTheme.labelText.copyWith(
                  color: AstroTheme.accentGold,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            educationData.masterNote,
            style: AstroTheme.bodyLarge.copyWith(
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AstroTheme.accentGold.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.lightbulb, color: AstroTheme.accentGold, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    educationData.coreRule,
                    style: TextStyle(
                      color: AstroTheme.accentGold,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildObservationCard(Planet planet) {
    return SectionCard(
      title: 'Observe in Your Life',
      icon: Icons.visibility_outlined,
      accentColor: AstroTheme.accentPurple,
      child: Column(
        children: planet.observationPrompts.map((prompt) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AstroTheme.accentPurple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AstroTheme.accentPurple.withOpacity(0.2),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.help_outline,
                  size: 18,
                  color: AstroTheme.accentPurple,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    prompt,
                    style: AstroTheme.bodyLarge.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildJournalCard(Planet planet) {
    return SectionCard(
      title: 'Journal Prompt',
      icon: Icons.edit_note,
      accentColor: AstroTheme.accentGold,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AstroTheme.accentGold.withOpacity(0.1),
              AstroTheme.accentGold.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AstroTheme.accentGold.withOpacity(0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '"${planet.journalPrompt}"',
              style: AstroTheme.bodyLarge.copyWith(
                fontStyle: FontStyle.italic,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  size: 16,
                  color: AstroTheme.accentGold,
                ),
                const SizedBox(width: 8),
                Text(
                  'Reflect on this in your journal',
                  style: AstroTheme.labelText.copyWith(
                    color: AstroTheme.accentGold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: AstroTheme.labelText,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AstroTheme.bodyLarge,
          ),
        ),
      ],
    );
  }
}
