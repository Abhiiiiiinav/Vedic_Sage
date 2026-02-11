import 'package:flutter/material.dart';
import '../../../app/theme.dart';
import '../../../core/constants/astro_data.dart';
import '../../../core/constants/house_education_data.dart';
import '../../../core/models/models.dart';
import '../../../shared/widgets/section_card.dart';

class HouseDetailScreen extends StatelessWidget {
  final int houseNumber;

  const HouseDetailScreen({super.key, required this.houseNumber});

  @override
  Widget build(BuildContext context) {
    final house = AstroData.getHouseByNumber(houseNumber);
    
    if (house == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Not Found')),
        body: const Center(child: Text('House not found')),
      );
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AstroTheme.cosmicGradient,
        ),
        child: CustomScrollView(
          slivers: [
            _buildAppBar(context, house),
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildOverviewCard(house),
                  const SizedBox(height: 16),
                  _buildLifeAreasCard(house),
                  const SizedBox(height: 16),
                  _buildRealWorldCard(house),
                  const SizedBox(height: 16),
                  _buildProblemsCard(house),
                  const SizedBox(height: 16),
                  _buildStrengtheningCard(house),
                  const SizedBox(height: 16),
                  _buildWeaknessCard(house),
                  const SizedBox(height: 16),
                  _buildMasterNoteCard(house),
                  const SizedBox(height: 16),
                  _buildGrowthCard(house),
                  const SizedBox(height: 40),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, House house) {
    return SliverAppBar(
      expandedHeight: 250,
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
                AstroTheme.accentPurple.withOpacity(0.3),
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
                    gradient: AstroTheme.primaryGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AstroTheme.accentPurple.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '${house.number}',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  house.name,
                  style: AstroTheme.headingLarge,
                ),
                Text(
                  house.sanskritName,
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

  Widget _buildOverviewCard(House house) {
    return SectionCard(
      title: 'Overview',
      icon: Icons.info_outline,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            house.description,
            style: AstroTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Natural Sign', house.naturalSign),
          const SizedBox(height: 8),
          _buildInfoRow('Natural Planet', house.naturalPlanet),
        ],
      ),
    );
  }

  Widget _buildLifeAreasCard(House house) {
    return SectionCard(
      title: 'Life Areas Governed',
      icon: Icons.category_outlined,
      accentColor: AstroTheme.accentGold,
      child: Column(
        children: house.lifeAreas.map((area) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 6),
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AstroTheme.accentGold,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  area,
                  style: AstroTheme.bodyLarge,
                ),
              ),
            ],
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildRealWorldCard(House house) {
    return SectionCard(
      title: 'Real-World Examples',
      icon: Icons.public,
      accentColor: AstroTheme.accentCyan,
      child: Column(
        children: house.realWorldExamples.map((example) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AstroTheme.accentCyan.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AstroTheme.accentCyan.withOpacity(0.2),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.lightbulb_outline,
                  size: 18,
                  color: AstroTheme.accentCyan,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    example,
                    style: AstroTheme.bodyLarge,
                  ),
                ),
              ],
            ),
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildProblemsCard(House house) {
    return SectionCard(
      title: 'How Problems Appear Here',
      icon: Icons.warning_amber_outlined,
      accentColor: const Color(0xFFff6b35),
      child: Column(
        children: house.problemManifestations.map((problem) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.remove_circle_outline,
                size: 18,
                color: const Color(0xFFff6b35).withOpacity(0.8),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  problem,
                  style: AstroTheme.bodyLarge,
                ),
              ),
            ],
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildGrowthCard(House house) {
    return SectionCard(
      title: 'Growth Opportunities',
      icon: Icons.trending_up,
      accentColor: const Color(0xFF4caf50),
      child: Column(
        children: house.growthOpportunities.map((opportunity) => Padding(
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
                  Icons.arrow_upward,
                  size: 14,
                  color: Color(0xFF4caf50),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  opportunity,
                  style: AstroTheme.bodyLarge,
                ),
              ),
            ],
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildStrengtheningCard(House house) {
    final educationData = HouseEducationData.getHouse(house.number);
    if (educationData == null) return const SizedBox.shrink();
    
    return SectionCard(
      title: 'How to Strengthen',
      icon: Icons.fitness_center,
      accentColor: const Color(0xFF4caf50),
      child: Column(
        children: educationData.strengtheningTips.take(5).map((tip) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
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
                  tip,
                  style: AstroTheme.bodyMedium,
                ),
              ),
            ],
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildWeaknessCard(House house) {
    final educationData = HouseEducationData.getHouse(house.number);
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
        ],
      ),
    );
  }

  Widget _buildMasterNoteCard(House house) {
    final educationData = HouseEducationData.getHouse(house.number);
    if (educationData == null) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AstroTheme.accentPurple.withOpacity(0.15),
            AstroTheme.accentPurple.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AstroTheme.accentPurple.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, color: AstroTheme.accentPurple, size: 20),
              const SizedBox(width: 8),
              Text(
                'Astrologer\'s Insight',
                style: AstroTheme.labelText.copyWith(
                  color: AstroTheme.accentPurple,
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
              color: AstroTheme.accentPurple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.lightbulb, color: AstroTheme.accentPurple, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    educationData.coreRule,
                    style: TextStyle(
                      color: AstroTheme.accentPurple,
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

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: AstroTheme.labelText,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AstroTheme.bodyLarge.copyWith(
              color: AstroTheme.accentGold,
            ),
          ),
        ),
      ],
    );
  }
}

