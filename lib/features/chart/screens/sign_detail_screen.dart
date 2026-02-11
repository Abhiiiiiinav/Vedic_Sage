import 'package:flutter/material.dart';
import '../../../app/theme.dart';
import '../../../core/constants/astro_data.dart';
import '../../../core/constants/sign_education_data.dart';
import '../../../core/models/models.dart';
import '../../../shared/widgets/section_card.dart';

class SignDetailScreen extends StatelessWidget {
  final String signId;

  const SignDetailScreen({super.key, required this.signId});

  Color _getElementColor(String element) {
    switch (element.toLowerCase()) {
      case 'fire':
        return const Color(0xFFff6b35);
      case 'earth':
        return const Color(0xFF4caf50);
      case 'air':
        return const Color(0xFF03a9f4);
      case 'water':
        return const Color(0xFF9c27b0);
      default:
        return AstroTheme.accentGold;
    }
  }

  @override
  Widget build(BuildContext context) {
    final sign = AstroData.getSignById(signId);
    
    if (sign == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Not Found')),
        body: const Center(child: Text('Sign not found')),
      );
    }

    final elementColor = _getElementColor(sign.element);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AstroTheme.cosmicGradient,
        ),
        child: CustomScrollView(
          slivers: [
            _buildAppBar(context, sign, elementColor),
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildOverviewCard(sign, elementColor),
                  const SizedBox(height: 16),
                  _buildBehavioralCard(sign),
                  const SizedBox(height: 16),
                  _buildMotivationCard(sign),
                  const SizedBox(height: 16),
                  _buildStrengthsCard(sign),
                  const SizedBox(height: 16),
                  _buildBlindSpotsCard(sign),
                  const SizedBox(height: 16),
                  _buildStrengtheningCard(sign),
                  const SizedBox(height: 16),
                  _buildWeaknessCard(sign),
                  const SizedBox(height: 16),
                  _buildMasterNoteCard(sign),
                  const SizedBox(height: 40),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, Sign sign, Color elementColor) {
    return SliverAppBar(
      expandedHeight: 220,
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
                elementColor.withOpacity(0.3),
                AstroTheme.scaffoldBackground,
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: elementColor.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: elementColor.withOpacity(0.5),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        sign.symbol,
                        style: TextStyle(
                          fontSize: 36,
                          color: elementColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    sign.name,
                    style: AstroTheme.headingMedium,
                  ),
                  Text(
                    sign.sanskritName,
                    style: AstroTheme.bodyMedium.copyWith(
                      color: AstroTheme.accentGold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildBadge(sign.element, elementColor),
                      const SizedBox(width: 8),
                      _buildBadge(sign.modality, AstroTheme.accentPurple),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildOverviewCard(Sign sign, Color elementColor) {
    return SectionCard(
      title: 'Overview',
      icon: Icons.info_outline,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            sign.description,
            style: AstroTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Ruling Planet', sign.rulingPlanet, elementColor),
          const SizedBox(height: 8),
          _buildInfoRow('Natural House', '${sign.houseNumber}', elementColor),
          const SizedBox(height: 8),
          _buildInfoRow('Element', sign.element, elementColor),
          const SizedBox(height: 8),
          _buildInfoRow('Modality', sign.modality, elementColor),
        ],
      ),
    );
  }

  Widget _buildBehavioralCard(Sign sign) {
    return SectionCard(
      title: 'Behavioral Style',
      icon: Icons.person_outline,
      accentColor: AstroTheme.accentCyan,
      child: Column(
        children: sign.behavioralStyles.map((style) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.arrow_right,
                size: 20,
                color: AstroTheme.accentCyan,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  style,
                  style: AstroTheme.bodyLarge,
                ),
              ),
            ],
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildMotivationCard(Sign sign) {
    return SectionCard(
      title: 'Motivation Patterns',
      icon: Icons.flash_on_outlined,
      accentColor: AstroTheme.accentGold,
      child: Column(
        children: sign.motivationPatterns.map((pattern) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AstroTheme.accentGold.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AstroTheme.accentGold.withOpacity(0.2),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.bolt,
                  size: 18,
                  color: AstroTheme.accentGold,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    pattern,
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

  Widget _buildStrengthsCard(Sign sign) {
    return SectionCard(
      title: 'Strengths',
      icon: Icons.star_outline,
      accentColor: const Color(0xFF4caf50),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: sign.strengths.map((strength) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF4caf50).withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF4caf50).withOpacity(0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle_outline,
                size: 16,
                color: Color(0xFF4caf50),
              ),
              const SizedBox(width: 8),
              Text(
                strength,
                style: AstroTheme.bodyMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildBlindSpotsCard(Sign sign) {
    return SectionCard(
      title: 'Blind Spots',
      icon: Icons.visibility_off_outlined,
      accentColor: const Color(0xFFff6b35),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Areas to be mindful of for personal growth:',
            style: AstroTheme.bodyMedium.copyWith(
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 12),
          ...sign.blindSpots.map((blindSpot) => Padding(
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
                    blindSpot,
                    style: AstroTheme.bodyLarge,
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildStrengtheningCard(Sign sign) {
    final educationData = SignEducationData.getSign(sign.id);
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

  Widget _buildWeaknessCard(Sign sign) {
    final educationData = SignEducationData.getSign(sign.id);
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

  Widget _buildMasterNoteCard(Sign sign) {
    final educationData = SignEducationData.getSign(sign.id);
    if (educationData == null) return const SizedBox.shrink();
    
    final elementColor = _getElementColor(sign.element);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            elementColor.withOpacity(0.15),
            elementColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: elementColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, color: elementColor, size: 20),
              const SizedBox(width: 8),
              Text(
                'Astrologer\'s Insight',
                style: AstroTheme.labelText.copyWith(
                  color: elementColor,
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
              color: elementColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.lightbulb, color: elementColor, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    educationData.coreRule,
                    style: TextStyle(
                      color: elementColor,
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

  Widget _buildInfoRow(String label, String value, Color accentColor) {
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
              color: accentColor,
            ),
          ),
        ),
      ],
    );
  }
}

