import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../app/theme.dart';
import '../../../core/models/cosmic_pet_models.dart';
import '../../../core/astro/cosmic_pet_engine.dart';
import '../../../core/astro/daily_swot_engine.dart';
import '../../../core/services/panchang_service.dart';
import '../../../core/services/pet_state_service.dart';
import '../../../core/services/user_session.dart';
import '../../../core/services/share_card_service.dart';
import '../../../shared/widgets/swot_share_card.dart';
import '../../../shared/widgets/cosmic_pet_share_card.dart';
import '../../../shared/widgets/user_code_share_card.dart';

/// Cosmic Pet Dashboard — Main Screen
///
/// Shows: Pet Hero Card, Vitality Bar, Daily SWOT, Micro-Actions,
/// "Why Today" explainability panel, and Quick Recovery button.
class CosmicPetScreen extends StatefulWidget {
  const CosmicPetScreen({super.key});

  @override
  State<CosmicPetScreen> createState() => _CosmicPetScreenState();
}

class _CosmicPetScreenState extends State<CosmicPetScreen>
    with SingleTickerProviderStateMixin {
  CosmicPet? _pet;
  DailySWOT? _swot;
  List<MicroAction> _actions = [];
  List<WhyTodayCue> _whyToday = [];
  Map<String, dynamic> _panchangData = {};
  bool _isLoading = true;
  String? _error;
  bool _isSharing = false;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _initialize();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    try {
      await PetStateService().initialize();

      final session = UserSession();
      if (!session.hasData || session.birthChart == null) {
        setState(() {
          _error = 'Generate your birth chart first to meet your Cosmic Pet!';
          _isLoading = false;
        });
        return;
      }

      final chart = session.birthChart!;
      final ownerName = session.birthDetails?.name ?? 'Traveler';

      // Generate pet personality
      final pet = CosmicPetPersonalityEngine.generatePet(
        chartData: chart,
        ownerName: ownerName,
      );

      // Get today's Panchang
      final details = session.birthDetails!;
      _panchangData = PanchangService.getLocalPanchang(
        date: DateTime.now(),
        latitude: details.latitude,
        longitude: details.longitude,
        timezone: details.timezoneOffset,
      );

      // Generate SWOT & actions
      final swot = DailySWOTEngine.generateSWOT(_panchangData);
      final actions = DailySWOTEngine.generateMicroActions(_panchangData);

      // Generate "Why Today"
      final whyToday = CosmicPetPersonalityEngine.generateWhyToday(
        pet: pet,
        panchangData: _panchangData,
      );

      // Check in automatically on screen open
      if (!PetStateService().hasCheckedInToday) {
        await PetStateService().checkIn();
      }

      // Get state
      final stateService = PetStateService();
      final fullPet = CosmicPet(
        name: pet.name,
        temperament: pet.temperament,
        activeHouseThemes: pet.activeHouseThemes,
        planetaryTone: pet.planetaryTone,
        toneExplanation: pet.toneExplanation,
        vitality: stateService.currentVitality,
        evolutionStage: stateService.evolutionStage,
        level: stateService.petLevel,
        totalXP: stateService.petXP,
        todaySWOT: swot,
        todayActions: actions,
      );

      setState(() {
        _pet = fullPet;
        _swot = swot;
        _actions = actions;
        _whyToday = whyToday;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _completeAction(int index) async {
    if (_actions[index].isCompleted) return;

    await PetStateService().completeAction(_actions[index].id);

    setState(() {
      _actions[index] = _actions[index].copyWith(isCompleted: true);
      _pet = CosmicPet(
        name: _pet!.name,
        temperament: _pet!.temperament,
        activeHouseThemes: _pet!.activeHouseThemes,
        planetaryTone: _pet!.planetaryTone,
        toneExplanation: _pet!.toneExplanation,
        vitality: PetStateService().currentVitality,
        evolutionStage: PetStateService().evolutionStage,
        level: PetStateService().petLevel,
        totalXP: PetStateService().petXP,
        todaySWOT: _swot,
        todayActions: _actions,
      );
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('+${_actions[index].xpReward} XP earned! ✨'),
          backgroundColor: AstroTheme.accentGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _recover() async {
    await PetStateService().performRecovery();
    setState(() {
      _pet = CosmicPet(
        name: _pet!.name,
        temperament: _pet!.temperament,
        activeHouseThemes: _pet!.activeHouseThemes,
        planetaryTone: _pet!.planetaryTone,
        toneExplanation: _pet!.toneExplanation,
        vitality: PetStateService().currentVitality,
        evolutionStage: PetStateService().evolutionStage,
        level: PetStateService().petLevel,
        totalXP: PetStateService().petXP,
        todaySWOT: _swot,
        todayActions: _actions,
      );
    });
  }

  // ════════════════════════════════════════════════════════════
  // SHARE SYSTEM
  // ════════════════════════════════════════════════════════════

  void _showShareSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AstroTheme.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Share Your Cosmic Profile',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Choose a card to share',
              style: GoogleFonts.quicksand(color: Colors.white54, fontSize: 13),
            ),
            const SizedBox(height: 20),
            _shareOption(
              emoji: '📊',
              title: 'Daily SWOT',
              subtitle:
                  'Share your Strengths, Weaknesses, Opportunities & Threats',
              color: AstroTheme.accentGreen,
              onTap: () {
                Navigator.pop(ctx);
                _captureAndShareCard('swot');
              },
            ),
            const SizedBox(height: 10),
            _shareOption(
              emoji: _pet?.temperament.petEmoji ?? '🐉',
              title: 'Cosmic Pet',
              subtitle: 'Share your pet profile, mood & vitality',
              color: AstroTheme.accentPurple,
              onTap: () {
                Navigator.pop(ctx);
                _captureAndShareCard('pet');
              },
            ),
            const SizedBox(height: 10),
            _shareOption(
              emoji: '🌟',
              title: 'Your Cosmic Code',
              subtitle: 'Share your chart placements & element balance',
              color: AstroTheme.accentGold,
              onTap: () {
                Navigator.pop(ctx);
                _captureAndShareCard('code');
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _shareOption({
    required String emoji,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.15)),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.quicksand(
                      color: Colors.white54,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.share_rounded, color: color, size: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _captureAndShareCard(String type) async {
    if (_isSharing) return;
    setState(() => _isSharing = true);

    // Build the share card widget
    Widget card;
    String fileName;
    String shareText;

    final session = UserSession();

    switch (type) {
      case 'swot':
        if (_swot == null) {
          _showShareError('SWOT data not available');
          return;
        }
        card = SWOTShareCard(
          swot: _swot!,
          userName: session.birthDetails?.name ?? 'Cosmic Traveler',
        );
        fileName = 'astrolearn_swot';
        shareText = 'My Cosmic SWOT for today ✨ #AstroLearn #CosmicSWOT';
        break;
      case 'pet':
        if (_pet == null) {
          _showShareError('Pet data not available');
          return;
        }
        card = CosmicPetShareCard(pet: _pet!);
        fileName = 'astrolearn_pet';
        shareText =
            'Meet my Cosmic Pet: ${_pet!.name} ${_pet!.temperament.petEmoji} #AstroLearn';
        break;
      case 'code':
        if (session.birthChart == null) {
          _showShareError('Chart data not available');
          return;
        }
        card = UserCodeShareCard(
          chartData: session.birthChart!,
          userName: session.birthDetails?.name ?? 'Cosmic Traveler',
        );
        fileName = 'astrolearn_code';
        shareText = 'My Cosmic Code 🌟 #AstroLearn #VedicAstrology';
        break;
      default:
        setState(() => _isSharing = false);
        return;
    }

    // Render off-screen using OverlayEntry
    final overlayState = Overlay.of(context);
    final shareKey = GlobalKey();

    final entry = OverlayEntry(
      builder: (_) => Positioned(
        left: -9999,
        top: -9999,
        child: RepaintBoundary(
          key: shareKey,
          child: MediaQuery(
            data: const MediaQueryData(),
            child: Material(
              color: Colors.transparent,
              child: card,
            ),
          ),
        ),
      ),
    );

    overlayState.insert(entry);

    // Wait for render
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      final success = await ShareCardService.instance.captureAndShare(
        shareKey,
        fileName: fileName,
        shareText: shareText,
      );

      if (!success && mounted) {
        _showShareError('Failed to create share card');
      }
    } finally {
      entry.remove();
      if (mounted) setState(() => _isSharing = false);
    }
  }

  void _showShareError(String message) {
    setState(() => _isSharing = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AstroTheme.scaffoldBackground,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AstroTheme.accentPurple))
          : _error != null
              ? _buildError()
              : _buildBody(),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🥚', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                  color: Colors.white70, fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 24),
            TextButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Go Back'),
              style:
                  TextButton.styleFrom(foregroundColor: AstroTheme.accentCyan),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    final pet = _pet!;
    return CustomScrollView(
      slivers: [
        // App Bar
        SliverAppBar(
          expandedHeight: 60,
          floating: true,
          pinned: true,
          backgroundColor: AstroTheme.scaffoldBackground,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Cosmic Pet',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),
          actions: [
            // Share button
            IconButton(
              icon: const Icon(Icons.share_rounded,
                  color: Colors.white70, size: 22),
              onPressed: _pet != null ? _showShareSheet : null,
              tooltip: 'Share',
            ),
            // Level badge
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Lv ${pet.level}',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),

        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 8),

              // 1. Pet Hero Card
              _buildPetHero(pet),
              const SizedBox(height: 16),

              // 2. Vitality Bar
              _buildVitalityCard(pet),
              const SizedBox(height: 16),

              // 3. Daily SWOT
              if (_swot != null) ...[
                _sectionLabel('📊  Daily SWOT'),
                const SizedBox(height: 8),
                _buildSWOTGrid(_swot!),
                const SizedBox(height: 16),
              ],

              // 4. Micro-Actions
              _sectionLabel('⚡  Today\'s Micro-Actions'),
              const SizedBox(height: 8),
              ..._actions.asMap().entries.map(
                    (e) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _buildActionCard(e.value, e.key),
                    ),
                  ),
              const SizedBox(height: 16),

              // 5. "Why Today" Panel
              _sectionLabel('🧠  Why Your Pet Feels This Way'),
              const SizedBox(height: 8),
              _buildWhyTodayPanel(),
              const SizedBox(height: 32),
            ]),
          ),
        ),
      ],
    );
  }

  // ════════════════════════════════════════════════════════════
  // PET HERO CARD
  // ════════════════════════════════════════════════════════════

  Widget _buildPetHero(CosmicPet pet) {
    final mood = pet.vitality.mood;
    final accentColor = _moodColor(mood);

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AstroTheme.cardBackground,
                accentColor.withValues(alpha: 0.15),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: accentColor.withValues(alpha: 0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color:
                    accentColor.withValues(alpha: 0.15 * _pulseAnimation.value),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            children: [
              // Pet emoji with glow
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withValues(
                          alpha: 0.4 * _pulseAnimation.value),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    pet.temperament.petEmoji,
                    style: const TextStyle(fontSize: 64),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Pet name
              Text(
                pet.name,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),

              // Temperament badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: accentColor.withValues(alpha: 0.4),
                  ),
                ),
                child: Text(
                  '${pet.temperament.name} • ${pet.temperament.element}',
                  style: GoogleFonts.outfit(
                    color: accentColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Core traits
              Text(
                pet.temperament.coreTraits,
                style: GoogleFonts.outfit(
                  color: Colors.white60,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),

              // Evolution + Mood row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _chip(
                      '${pet.evolutionStage.emoji} ${pet.evolutionStage.label}',
                      AstroTheme.accentGold),
                  const SizedBox(width: 8),
                  _chip('${mood.emoji} ${mood.label}', _moodColor(mood)),
                ],
              ),

              // Mood description
              const SizedBox(height: 8),
              Text(
                mood.description,
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  color: Colors.white54,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _chip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: GoogleFonts.outfit(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════
  // VITALITY CARD
  // ════════════════════════════════════════════════════════════

  Widget _buildVitalityCard(CosmicPet pet) {
    final v = pet.vitality.vitality;
    final color = v > 60
        ? AstroTheme.accentGreen
        : v > 30
            ? AstroTheme.accentGold
            : const Color(0xFFff3b30);
    final stateService = PetStateService();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AstroTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.favorite_rounded, color: color, size: 18),
              const SizedBox(width: 8),
              Text('Vitality',
                  style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15)),
              const Spacer(),
              Text('$v / 100',
                  style: GoogleFonts.outfit(
                      color: color, fontWeight: FontWeight.w700, fontSize: 15)),
            ],
          ),
          const SizedBox(height: 10),

          // Vitality bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: v / 100,
              backgroundColor: Colors.white10,
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 8),

          // Status text
          Row(
            children: [
              Text(
                v > 50 ? 'In sync with today' : 'Needs gentle recovery',
                style: GoogleFonts.outfit(color: Colors.white54, fontSize: 12),
              ),
              const Spacer(),
              // XP progress
              Text(
                '${stateService.petXP} XP',
                style: GoogleFonts.outfit(
                  color: AstroTheme.accentPurple,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          // Alignment score
          const SizedBox(height: 6),
          Row(
            children: [
              Text('Today\'s Alignment: ',
                  style:
                      GoogleFonts.outfit(color: Colors.white38, fontSize: 11)),
              Text(
                '${stateService.currentAlignmentScore}/100',
                style: GoogleFonts.outfit(
                  color: Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (stateService.hasCheckedInToday)
                const Padding(
                  padding: EdgeInsets.only(left: 6),
                  child: Icon(Icons.check_circle,
                      color: AstroTheme.accentGreen, size: 14),
                ),
            ],
          ),

          // Recovery button if vitality is low
          if (v < 50) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _recover,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text('Quick Recovery (+30 Vitality)',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: color.withValues(alpha: 0.2),
                  foregroundColor: color,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════
  // SWOT GRID
  // ════════════════════════════════════════════════════════════

  Widget _buildSWOTGrid(DailySWOT swot) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildSWOTQuadrant(
                title: 'Strengths',
                emoji: '💪',
                items: swot.strengths,
                color: AstroTheme.accentGreen,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildSWOTQuadrant(
                title: 'Weaknesses',
                emoji: '⚠️',
                items: swot.weaknesses,
                color: AstroTheme.accentGold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildSWOTQuadrant(
                title: 'Opportunities',
                emoji: '🌟',
                items: swot.opportunities,
                color: AstroTheme.accentCyan,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildSWOTQuadrant(
                title: 'Threats',
                emoji: '🛡️',
                items: swot.threats,
                color: AstroTheme.accentPink,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSWOTQuadrant({
    required String title,
    required String emoji,
    required List<SWOTItem> items,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.outfit(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.text,
                      style: GoogleFonts.outfit(
                        color: Colors.white70,
                        fontSize: 11,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${item.sourceEmoji} ${item.source}',
                      style: GoogleFonts.outfit(
                        color: Colors.white30,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════
  // MICRO-ACTION CARDS
  // ════════════════════════════════════════════════════════════

  Widget _buildActionCard(MicroAction action, int index) {
    final done = action.isCompleted;
    return GestureDetector(
      onTap: done ? null : () => _completeAction(index),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: done
              ? AstroTheme.accentGreen.withValues(alpha: 0.1)
              : AstroTheme.cardBackground,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: done
                ? AstroTheme.accentGreen.withValues(alpha: 0.3)
                : Colors.white10,
          ),
        ),
        child: Row(
          children: [
            // Checkbox
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: done
                    ? AstroTheme.accentGreen
                    : Colors.white.withValues(alpha: 0.08),
                border: Border.all(
                  color: done ? AstroTheme.accentGreen : Colors.white24,
                  width: 2,
                ),
              ),
              child: done
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    action.title,
                    style: GoogleFonts.outfit(
                      color: done ? Colors.white54 : Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      decoration: done ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    action.description,
                    style: GoogleFonts.outfit(
                      color: Colors.white38,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '📎 ${action.source} · +${action.xpReward} XP',
                    style: GoogleFonts.outfit(
                      color: AstroTheme.accentPurple.withValues(alpha: 0.7),
                      fontSize: 10,
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

  // ════════════════════════════════════════════════════════════
  // "WHY TODAY" PANEL
  // ════════════════════════════════════════════════════════════

  Widget _buildWhyTodayPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AstroTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ..._whyToday.map((cue) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(cue.emoji, style: const TextStyle(fontSize: 18)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cue.factor,
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            cue.effect,
                            style: GoogleFonts.outfit(
                              color: Colors.white54,
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
          const Divider(color: Colors.white12, height: 16),
          Text(
            'Your pet reflects your chart\'s tendencies — not destiny. You always choose.',
            style: GoogleFonts.outfit(
              color: Colors.white30,
              fontSize: 11,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════
  // HELPERS
  // ════════════════════════════════════════════════════════════

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.outfit(
        color: Colors.white,
        fontWeight: FontWeight.w600,
        fontSize: 16,
      ),
    );
  }

  Color _moodColor(PetMood mood) {
    switch (mood) {
      case PetMood.energized:
        return AstroTheme.accentGreen;
      case PetMood.calm:
        return AstroTheme.accentCyan;
      case PetMood.focused:
        return AstroTheme.accentPurple;
      case PetMood.playful:
        return AstroTheme.accentPink;
      case PetMood.reflective:
        return AstroTheme.accentGold;
      case PetMood.fatigued:
        return const Color(0xFFff9500);
      case PetMood.dormant:
        return const Color(0xFF8e8e93);
      case PetMood.reviving:
        return const Color(0xFF00d4ff);
    }
  }
}
