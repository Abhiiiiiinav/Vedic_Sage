import 'package:flutter/material.dart';
import '../../../app/theme.dart';
import '../../../core/constants/nakshatra_data.dart';
import '../../../core/models/models.dart';
import '../../../shared/widgets/section_card.dart';

class NakshatraDetailScreen extends StatelessWidget {
  final int nakshatraNumber;

  const NakshatraDetailScreen({super.key, required this.nakshatraNumber});

  @override
  Widget build(BuildContext context) {
    final nakshatra = NakshatraData.getNakshatraByNumber(nakshatraNumber);
    
    if (nakshatra == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Not Found')),
        body: const Center(child: Text('Nakshatra not found')),
      );
    }

    final lordColor = AstroTheme.getPlanetColor(nakshatra.lord);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AstroTheme.cosmicGradient,
        ),
        child: CustomScrollView(
          slivers: [
            _buildAppBar(context, nakshatra, lordColor),
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildOverviewCard(nakshatra),
                  const SizedBox(height: 16),
                  _buildSyllablesCard(nakshatra, lordColor),
                  const SizedBox(height: 16),
                  _buildPsychologyCard(nakshatra),
                  const SizedBox(height: 16),
                  _buildBehaviorsCard(nakshatra),
                  const SizedBox(height: 16),
                  _buildStrengtheningCard(nakshatra, lordColor),
                  const SizedBox(height: 40),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, Nakshatra nakshatra, Color lordColor) {
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
                lordColor.withOpacity(0.3),
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
                    color: lordColor.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: lordColor.withOpacity(0.5),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: lordColor.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '${nakshatra.number}',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: lordColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  nakshatra.name,
                  style: AstroTheme.headingLarge,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildBadge('Lord: ${nakshatra.lord}', lordColor),
                    const SizedBox(width: 8),
                    _buildBadge(nakshatra.gana, AstroTheme.accentPurple),
                  ],
                ),
              ],
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

  Widget _buildOverviewCard(Nakshatra nakshatra) {
    return SectionCard(
      title: 'Overview',
      icon: Icons.info_outline,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            nakshatra.description,
            style: AstroTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Symbol', nakshatra.symbol),
          const SizedBox(height: 8),
          _buildInfoRow('Deity', nakshatra.deity),
          const SizedBox(height: 8),
          _buildInfoRow('Sign Span', nakshatra.signSpan),
          const SizedBox(height: 8),
          _buildInfoRow('Nature', nakshatra.nature),
          const SizedBox(height: 8),
          _buildInfoRow('Animal', nakshatra.animal),
        ],
      ),
    );
  }

  Widget _buildSyllablesCard(Nakshatra nakshatra, Color lordColor) {
    return SectionCard(
      title: 'Name Syllables',
      icon: Icons.text_fields,
      accentColor: AstroTheme.accentGold,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recommended starting sounds for names:',
            style: AstroTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: nakshatra.syllables.map((syllable) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    lordColor.withOpacity(0.3),
                    lordColor.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: lordColor.withOpacity(0.4),
                ),
              ),
              child: Text(
                syllable,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: lordColor,
                ),
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPsychologyCard(Nakshatra nakshatra) {
    return SectionCard(
      title: 'Psychological Drivers',
      icon: Icons.psychology_outlined,
      accentColor: AstroTheme.accentCyan,
      child: Column(
        children: nakshatra.psychologicalDrivers.map((driver) => Padding(
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
                    driver,
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

  Widget _buildBehaviorsCard(Nakshatra nakshatra) {
    return SectionCard(
      title: 'Unconscious Behaviors',
      icon: Icons.visibility_off_outlined,
      accentColor: const Color(0xFFff6b35),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Patterns to be aware of:',
            style: AstroTheme.bodyMedium.copyWith(
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 12),
          ...nakshatra.unconsciousBehaviors.map((behavior) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  size: 18,
                  color: const Color(0xFFff6b35).withOpacity(0.8),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    behavior,
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

  Widget _buildStrengtheningCard(Nakshatra nakshatra, Color lordColor) {
    return SectionCard(
      title: 'Strengthening Practices',
      icon: Icons.fitness_center,
      accentColor: const Color(0xFF4caf50),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: lordColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: lordColor.withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.star,
                  color: lordColor,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Strengthen the Nakshatra Lord (${nakshatra.lord}) for better results',
                    style: AstroTheme.bodyMedium.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ...nakshatra.strengtheningPractices.map((practice) => Padding(
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
                    practice,
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

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
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
