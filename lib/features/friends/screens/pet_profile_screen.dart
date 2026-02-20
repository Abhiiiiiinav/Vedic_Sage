import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../app/theme.dart';
import '../../../core/astro/astro_pet_engine.dart';
import '../../../core/astro/kundali_engine.dart';
import '../../../core/models/friend_model.dart';
import '../../../core/services/user_session.dart';

class PetProfileScreen extends StatefulWidget {
  /// If provided, shows the friend's pet. Otherwise shows the user's own pet.
  final FriendProfile? friend;

  const PetProfileScreen({super.key, this.friend});

  @override
  State<PetProfileScreen> createState() => _PetProfileScreenState();
}

class _PetProfileScreenState extends State<PetProfileScreen>
    with SingleTickerProviderStateMixin {
  AstroPet? _pet;
  bool _isLoading = true;
  String? _error;
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _generate();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  void _generate() {
    try {
      KundaliResult chart;
      String name;

      if (widget.friend != null) {
        final f = widget.friend!;
        chart = KundaliEngine.calculateChart(
          birthTime: f.dateOfBirth,
          latitude: f.latitude,
          longitude: f.longitude,
          timezoneOffset: f.timezoneOffset,
        );
        name = f.name;
      } else {
        final session = UserSession();
        final d = session.birthDetails;
        if (d == null) {
          setState(() {
            _error = 'Generate your birth chart first to meet your Astro Pet!';
            _isLoading = false;
          });
          return;
        }
        chart = KundaliEngine.calculateChart(
          birthTime: d.birthDateTime,
          latitude: d.latitude,
          longitude: d.longitude,
          timezoneOffset: d.timezoneOffset,
        );
        name = d.name;
      }

      _pet = AstroPetEngine.generatePet(chart: chart, ownerName: name);
      setState(() => _isLoading = false);
      _animCtrl.forward();
    } catch (e) {
      setState(() {
        _error = 'Error generating pet: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AstroTheme.scaffoldBackground,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            backgroundColor: AstroTheme.scaffoldBackground,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white70, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Astro Pet',
                style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF764ba2).withOpacity(0.35),
                      const Color(0xFF667eea).withOpacity(0.15),
                      AstroTheme.scaffoldBackground,
                    ],
                  ),
                ),
              ),
            ),
          ),

          if (_isLoading)
            const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(
                    color: Color(0xFF764ba2), strokeWidth: 2.5),
              ),
            )
          else if (_error != null)
            SliverFillRemaining(child: _buildError())
          else ...[
            SliverToBoxAdapter(child: _buildPetHero()),
            SliverToBoxAdapter(child: _buildPersonalityBadge()),
            SliverToBoxAdapter(child: _buildStatsSection()),
            SliverToBoxAdapter(child: _buildAbilitiesSection()),
            SliverToBoxAdapter(child: _buildLore()),
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ],
      ),
    );
  }

  // ════════════════════════════════════════
  // WIDGETS
  // ════════════════════════════════════════

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🥚', style: TextStyle(fontSize: 60)),
            const SizedBox(height: 16),
            Text(_error!,
                textAlign: TextAlign.center,
                style: GoogleFonts.quicksand(
                    color: Colors.white60, fontSize: 15, height: 1.5)),
          ],
        ),
      ),
    );
  }

  Widget _buildPetHero() {
    final pet = _pet!;
    return FadeTransition(
      opacity: _fadeAnim,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _speciesColor(pet.species).withOpacity(0.15),
                const Color(0xFF764ba2).withOpacity(0.08),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: _speciesColor(pet.species).withOpacity(0.25),
            ),
          ),
          child: Column(
            children: [
              // Species emoji — large
              Text(pet.species.emoji, style: const TextStyle(fontSize: 72)),
              const SizedBox(height: 16),

              // Pet name
              Text(
                pet.petName,
                style: GoogleFonts.outfit(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 6),

              // Species label
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                decoration: BoxDecoration(
                  color: _speciesColor(pet.species).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  pet.species.displayName,
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _speciesColor(pet.species),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Owner + astro tag
              Text(
                '${pet.ownerName}\'s companion',
                style:
                    GoogleFonts.quicksand(fontSize: 12, color: Colors.white38),
              ),
              const SizedBox(height: 4),
              Text(
                '${pet.ascendantSign} Asc · ${pet.moonSign} Moon · ${pet.sunSign} Sun',
                style:
                    GoogleFonts.quicksand(fontSize: 11, color: Colors.white24),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPersonalityBadge() {
    final p = _pet!.personality;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        child: Row(
          children: [
            Text(p.emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.label,
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    p.description,
                    style: GoogleFonts.quicksand(
                        fontSize: 12, color: Colors.white38, height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    final stats = _pet!.stats;
    final statsList = [
      _StatItem('❤️', 'Vitality', stats.vitality, Colors.redAccent),
      _StatItem('🌙', 'Empathy', stats.empathy, Colors.lightBlue),
      _StatItem('⚔️', 'Valor', stats.valor, Colors.orangeAccent),
      _StatItem('📚', 'Wisdom', stats.wisdom, AstroTheme.accentGold),
      _StatItem('🛡️', 'Resilience', stats.resilience, AstroTheme.accentCyan),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('STATS'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.06)),
            ),
            child: Column(
              children: statsList.map((s) => _buildStatBar(s)).toList(),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Total Power: ${stats.total}  ·  Average: ${stats.average}',
              style: GoogleFonts.jetBrainsMono(
                  fontSize: 11, color: Colors.white24),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBar(_StatItem stat) {
    final fraction = stat.value / 100;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(stat.emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          SizedBox(
            width: 68,
            child: Text(
              stat.label,
              style: GoogleFonts.outfit(
                  fontSize: 12,
                  color: Colors.white54,
                  fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: fraction,
                  child: Container(
                    height: 10,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          stat.color.withOpacity(0.6),
                          stat.color,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(5),
                      boxShadow: [
                        BoxShadow(
                          color: stat.color.withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 28,
            child: Text(
              '${stat.value}',
              textAlign: TextAlign.right,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: stat.value >= 70
                    ? AstroTheme.accentGreen
                    : stat.value >= 45
                        ? AstroTheme.accentGold
                        : AstroTheme.accentPink,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAbilitiesSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('ABILITIES'),
          const SizedBox(height: 12),
          ..._pet!.abilities.map((a) => _buildAbilityCard(a)),
        ],
      ),
    );
  }

  Widget _buildAbilityCard(PetAbility ability) {
    final powerColor = ability.power >= 70
        ? AstroTheme.accentGreen
        : ability.power >= 45
            ? AstroTheme.accentGold
            : AstroTheme.accentPink;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            powerColor.withOpacity(0.08),
            Colors.white.withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: powerColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Text(ability.emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      ability.name,
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: powerColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'PWR ${ability.power}',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: powerColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${ability.planet} ability · ${ability.effectType.toUpperCase()}',
                  style: GoogleFonts.quicksand(
                      fontSize: 10, color: Colors.white30),
                ),
                const SizedBox(height: 6),
                Text(
                  ability.description,
                  style: GoogleFonts.quicksand(
                    fontSize: 12,
                    color: Colors.white54,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLore() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF764ba2).withOpacity(0.08),
              const Color(0xFF667eea).withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF764ba2).withOpacity(0.15)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('📜', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ORIGIN LORE',
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AstroTheme.accentGold.withOpacity(0.7),
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _pet!.species.lore,
                    style: GoogleFonts.quicksand(
                      fontSize: 13,
                      color: Colors.white54,
                      height: 1.5,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.outfit(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AstroTheme.accentGold.withOpacity(0.7),
        letterSpacing: 1.5,
      ),
    );
  }

  Color _speciesColor(PetSpecies species) {
    switch (species) {
      case PetSpecies.cosmicDragon:
        return Colors.orangeAccent;
      case PetSpecies.crystalStag:
        return AstroTheme.accentGreen;
      case PetSpecies.stormPhoenix:
        return AstroTheme.accentCyan;
      case PetSpecies.mysticSerpent:
        return AstroTheme.accentPurple;
    }
  }
}

class _StatItem {
  final String emoji;
  final String label;
  final int value;
  final Color color;
  const _StatItem(this.emoji, this.label, this.value, this.color);
}
