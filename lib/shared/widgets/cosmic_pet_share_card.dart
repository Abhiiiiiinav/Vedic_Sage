import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app/theme.dart';
import '../../core/models/cosmic_pet_models.dart';

/// Cosmic Pet Share Card — Premium 9:16 story-format card.
///
/// Shows pet emoji, name, temperament, mood, vitality, evolution,
/// XP, and core traits in a shareable format.
class CosmicPetShareCard extends StatelessWidget {
  final CosmicPet pet;

  const CosmicPetShareCard({super.key, required this.pet});

  @override
  Widget build(BuildContext context) {
    final mood = pet.vitality.mood;
    final moodColor = _moodColor(mood);
    final vColor = pet.vitality.vitality > 60
        ? AstroTheme.accentGreen
        : pet.vitality.vitality > 30
            ? AstroTheme.accentGold
            : const Color(0xFFff3b30);

    return SizedBox(
      width: 360,
      height: 640,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0D0D2B),
              Color(0xFF1E1040),
              Color(0xFF0F1023),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 28),
          child: Column(
            children: [
              // ── Header ──
              _buildHeader(),
              const SizedBox(height: 24),

              // ── Pet Emoji with Glow ──
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: moodColor.withOpacity(0.4),
                      blurRadius: 40,
                      spreadRadius: 8,
                    ),
                    BoxShadow(
                      color: moodColor.withOpacity(0.15),
                      blurRadius: 80,
                      spreadRadius: 20,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    pet.temperament.petEmoji,
                    style: const TextStyle(fontSize: 72),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ── Pet Name ──
              Text(
                pet.name,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),

              // ── Temperament + Element ──
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                decoration: BoxDecoration(
                  color: moodColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: moodColor.withOpacity(0.3)),
                ),
                child: Text(
                  '${pet.temperament.name} • ${pet.temperament.element}',
                  style: GoogleFonts.outfit(
                    color: moodColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // ── Core Traits ──
              Text(
                pet.temperament.coreTraits,
                style: GoogleFonts.quicksand(
                  color: Colors.white54,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),

              // ── Stats Grid ──
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _statChip(
                      '${pet.evolutionStage.emoji} ${pet.evolutionStage.label}',
                      AstroTheme.accentGold),
                  const SizedBox(width: 8),
                  _statChip('${mood.emoji} ${mood.label}', moodColor),
                  const SizedBox(width: 8),
                  _statChip('Lv ${pet.level}', AstroTheme.accentPurple),
                ],
              ),
              const SizedBox(height: 20),

              // ── Vitality Bar ──
              _buildVitalityBar(vColor),
              const SizedBox(height: 14),

              // ── XP ──
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '⚡ ${pet.totalXP} XP',
                    style: GoogleFonts.outfit(
                      color: AstroTheme.accentPurple,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // ── Mood Description ──
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.06)),
                ),
                child: Text(
                  mood.description,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.quicksand(
                    color: Colors.white54,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              const Spacer(),

              // ── Footer ──
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            gradient: AstroTheme.primaryGradient,
            borderRadius: BorderRadius.circular(7),
          ),
          child: const Center(
            child: Text('✨', style: TextStyle(fontSize: 14)),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'AstroLearn',
          style: GoogleFonts.outfit(
            color: AstroTheme.accentGold,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        Text(
          'Cosmic Pet',
          style: GoogleFonts.quicksand(
            color: Colors.white38,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _statChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        text,
        style: GoogleFonts.outfit(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildVitalityBar(Color vColor) {
    final v = pet.vitality.vitality;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.favorite_rounded, color: vColor, size: 14),
                const SizedBox(width: 5),
                Text(
                  'Vitality',
                  style: GoogleFonts.outfit(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            Text(
              '$v / 100',
              style: GoogleFonts.outfit(
                color: vColor,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: LinearProgressIndicator(
            value: v / 100,
            backgroundColor: Colors.white10,
            valueColor: AlwaysStoppedAnimation(vColor),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(height: 1, width: 40, color: Colors.white12),
        const SizedBox(width: 10),
        Text(
          'AstroLearn • Your Cosmic Code',
          style: GoogleFonts.quicksand(
            color: Colors.white30,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 10),
        Container(height: 1, width: 40, color: Colors.white12),
      ],
    );
  }

  Color _moodColor(PetMood mood) {
    switch (mood) {
      case PetMood.energized:
        return AstroTheme.accentGold;
      case PetMood.calm:
        return AstroTheme.accentCyan;
      case PetMood.focused:
        return AstroTheme.accentPurple;
      case PetMood.playful:
        return AstroTheme.accentPink;
      case PetMood.reflective:
        return const Color(0xFF9B8FFF);
      case PetMood.fatigued:
        return const Color(0xFFff9500);
      case PetMood.dormant:
        return const Color(0xFF636366);
      case PetMood.reviving:
        return AstroTheme.accentGreen;
    }
  }
}
