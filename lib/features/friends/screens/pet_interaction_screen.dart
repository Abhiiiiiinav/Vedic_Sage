import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../app/theme.dart';
import '../../../core/models/friend_model.dart';
import '../../../core/services/friends_interaction_service.dart';

class PetInteractionScreen extends StatefulWidget {
  final FriendProfile friend;

  const PetInteractionScreen({super.key, required this.friend});

  @override
  State<PetInteractionScreen> createState() => _PetInteractionScreenState();
}

class _PetInteractionScreenState extends State<PetInteractionScreen>
    with SingleTickerProviderStateMixin {
  final _interactionService = FriendsInteractionService();
  FriendPetInteractionData? _interaction;
  bool _isLoading = true;
  String? _error;
  late AnimationController _animCtrl;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _generate();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    try {
      _interaction = _interactionService.generateForFriend(widget.friend);
      setState(() => _isLoading = false);
      _animCtrl.forward();
    } catch (e) {
      final message = e is StateError
          ? e.message.toString()
          : 'Error during pet interaction: $e';
      setState(() {
        _error = message;
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
          SliverAppBar(
            expandedHeight: 100,
            pinned: true,
            backgroundColor: AstroTheme.scaffoldBackground,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white70, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Pet Arena',
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
                      const Color(0xFFff6b9d).withOpacity(0.25),
                      const Color(0xFF764ba2).withOpacity(0.15),
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                        color: Color(0xFFff6b9d), strokeWidth: 2.5),
                    SizedBox(height: 16),
                    Text('Summoning pets...',
                        style: TextStyle(color: Colors.white38, fontSize: 13)),
                  ],
                ),
              ),
            )
          else if (_error != null)
            SliverFillRemaining(child: _buildError())
          else ...[
            // Two pets face-off
            SliverToBoxAdapter(child: _buildPetFaceOff()),

            // Synergy score
            SliverToBoxAdapter(child: _buildSynergyScore()),

            // Overall narrative
            SliverToBoxAdapter(child: _buildOverallNarrative()),

            // Interaction effects
            if (_interaction!.effects.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                  child: Text(
                    'INTERACTION EFFECTS',
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AstroTheme.accentGold.withOpacity(0.7),
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) => _buildEffectCard(_interaction!.effects[i]),
                    childCount: _interaction!.effects.length,
                  ),
                ),
              ),
            ] else
              SliverToBoxAdapter(child: _buildNoEffects()),

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

  Widget _buildPetFaceOff() {
    final data = _interaction!;

    return FadeTransition(
      opacity: CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _speciesColor(data.userPetSpeciesKey).withOpacity(0.1),
                Colors.white.withOpacity(0.02),
                _speciesColor(data.friendPetSpeciesKey).withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Row(
            children: [
              // Pet 1
              Expanded(
                child: Column(
                  children: [
                    Text(data.userPetSpeciesEmoji,
                        style: const TextStyle(fontSize: 52)),
                    const SizedBox(height: 8),
                    Text(
                      data.userPetName,
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: _speciesColor(data.userPetSpeciesKey),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      data.userPetSpeciesLabel,
                      style: GoogleFonts.quicksand(
                          fontSize: 10, color: Colors.white30),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'You',
                      style: GoogleFonts.quicksand(
                          fontSize: 11, color: Colors.white54),
                    ),
                  ],
                ),
              ),

              // VS
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFff6b9d).withOpacity(0.3),
                          const Color(0xFF764ba2).withOpacity(0.3),
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '⚡',
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'MEET',
                    style: GoogleFonts.outfit(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Colors.white24,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),

              // Pet 2
              Expanded(
                child: Column(
                  children: [
                    Text(data.friendPetSpeciesEmoji,
                        style: const TextStyle(fontSize: 52)),
                    const SizedBox(height: 8),
                    Text(
                      data.friendPetName,
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: _speciesColor(data.friendPetSpeciesKey),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      data.friendPetSpeciesLabel,
                      style: GoogleFonts.quicksand(
                          fontSize: 10, color: Colors.white30),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      data.friendName,
                      style: GoogleFonts.quicksand(
                          fontSize: 11, color: Colors.white54),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSynergyScore() {
    final synergy = _interaction!.synergyScore;
    final color = synergy >= 75
        ? AstroTheme.accentGreen
        : synergy >= 50
            ? AstroTheme.accentGold
            : AstroTheme.accentPink;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('✨', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 10),
            Text(
              'Synergy Score',
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white60,
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$synergy',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ),
            Text(
              '/100',
              style: GoogleFonts.jetBrainsMono(
                  fontSize: 12, color: Colors.white24),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverallNarrative() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
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
            const Text('📖', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _interaction!.overallNarrative,
                style: GoogleFonts.quicksand(
                  fontSize: 13,
                  color: Colors.white60,
                  height: 1.5,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEffectCard(FriendInteractionEffectData effect) {
    final isHeal = effect.abilityEffectType == 'heal';
    final isShield = effect.abilityEffectType == 'shield';
    final cardColor = isHeal
        ? Colors.lightBlue
        : isShield
            ? AstroTheme.accentCyan
            : AstroTheme.accentGold;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cardColor.withOpacity(0.1),
            Colors.white.withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: who helps whom
          Row(
            children: [
              Text(effect.giverSpeciesEmoji,
                  style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Icon(Icons.arrow_forward_rounded, color: cardColor, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${effect.giverName} helps ${effect.receiverName}',
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '${effect.abilityName} -> ${effect.targetStat} +${effect.boostAmount}',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 10,
                        color: cardColor,
                      ),
                    ),
                  ],
                ),
              ),
              // Boost badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AstroTheme.accentGreen.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.arrow_upward_rounded,
                        color: AstroTheme.accentGreen, size: 12),
                    Text(
                      '+${effect.boostAmount}',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AstroTheme.accentGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Strength vs weakness bar
          Row(
            children: [
              Text('💪', style: const TextStyle(fontSize: 12)),
              const SizedBox(width: 6),
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: effect.giverStrength / 100,
                      child: Container(
                        height: 6,
                        decoration: BoxDecoration(
                          color: AstroTheme.accentGreen,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${effect.giverStrength}',
                style: GoogleFonts.jetBrainsMono(
                    fontSize: 10, color: AstroTheme.accentGreen),
              ),
              Text(' vs ',
                  style: GoogleFonts.quicksand(
                      fontSize: 10, color: Colors.white24)),
              Text(
                '${effect.receiverWeakness}',
                style: GoogleFonts.jetBrainsMono(
                    fontSize: 10, color: AstroTheme.accentPink),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Narrative
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              effect.narrative,
              style: GoogleFonts.quicksand(
                fontSize: 12,
                color: Colors.white54,
                height: 1.5,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoEffects() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        child: Column(
          children: [
            const Text('🤝', style: TextStyle(fontSize: 40)),
            const SizedBox(height: 12),
            Text(
              'Balanced Encounter',
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Both pets are evenly matched! Neither has a clear area where they can boost the other. This is a harmonious cosmic truce.',
              textAlign: TextAlign.center,
              style: GoogleFonts.quicksand(
                fontSize: 12,
                color: Colors.white38,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _speciesColor(String speciesKey) {
    switch (speciesKey) {
      case 'cosmicDragon':
        return Colors.orangeAccent;
      case 'crystalStag':
        return AstroTheme.accentGreen;
      case 'stormPhoenix':
        return AstroTheme.accentCyan;
      case 'mysticSerpent':
        return AstroTheme.accentPurple;
      default:
        return AstroTheme.accentPurple;
    }
  }
}
