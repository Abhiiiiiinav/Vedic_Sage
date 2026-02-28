import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import '../../../app/theme.dart';
import '../../auth/screens/login_screen.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0a0e21),
      body: Stack(
        children: [
          // Animated background
          _buildAnimatedBackground(),

          // Main content
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  _buildHeroSection(),
                  const SizedBox(height: 60),
                  _buildFeaturesGrid(),
                  const SizedBox(height: 60),
                  _buildCTASection(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return Stack(
      children: [
        // Gradient base
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF0a0e21),
                Color(0xFF1a1a3e),
                Color(0xFF0d1b2a),
              ],
            ),
          ),
        ),
        // Animated orbs
        Positioned(
          top: -100,
          right: -100,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AstroTheme.accentPurple.withOpacity(0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -150,
          left: -100,
          child: Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AstroTheme.accentCyan.withOpacity(0.2),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroSection() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              // Logo/Icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: AstroTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: AstroTheme.accentPurple.withOpacity(0.5),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  size: 50,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 30),

              // Title
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [
                    AstroTheme.accentCyan,
                    AstroTheme.accentPurple,
                    AstroTheme.accentGold,
                  ],
                ).createShader(bounds),
                child: Text(
                  'AstroLearn',
                  style: GoogleFonts.outfit(
                    fontSize: 56,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -1,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Subtitle
              Text(
                'Master Vedic Astrology',
                style: GoogleFonts.quicksand(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white70,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),

              // Description
              Text(
                'Your personal journey through the cosmos.\nLearn, explore, and unlock ancient wisdom.',
                textAlign: TextAlign.center,
                style: GoogleFonts.quicksand(
                  fontSize: 15,
                  color: Colors.white54,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturesGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '✦  KEY FEATURES',
            style: GoogleFonts.quicksand(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AstroTheme.accentGold.withOpacity(0.8),
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 24),
          _buildFeatureCard(
            icon: Icons.auto_awesome,
            title: 'Birth Chart Analysis',
            description:
                'Generate and explore your complete Vedic birth chart with detailed planetary positions',
            gradient: LinearGradient(
              colors: [
                const Color(0xFF667eea).withOpacity(0.2),
                const Color(0xFF764ba2).withOpacity(0.1),
              ],
            ),
            accentColor: const Color(0xFF667eea),
            imagePath: 'assets/images/features/chart_scroll.jpg',
          ),
          const SizedBox(height: 16),
          _buildFeatureCard(
            icon: Icons.stars_rounded,
            title: 'Nakshatra Wisdom',
            description:
                'Discover the 27 lunar mansions and their profound influence on your life',
            gradient: LinearGradient(
              colors: [
                const Color(0xFFffcc00).withOpacity(0.2),
                const Color(0xFFff9500).withOpacity(0.1),
              ],
            ),
            accentColor: const Color(0xFFffcc00),
            imagePath: 'assets/images/features/nakshatra_stars.jpg',
          ),
          const SizedBox(height: 16),
          _buildFeatureCard(
            icon: Icons.favorite_rounded,
            title: 'Relationship Compatibility',
            description:
                'Analyze compatibility with friends, partners, and family through Vedic synastry',
            gradient: LinearGradient(
              colors: [
                const Color(0xFFe91e63).withOpacity(0.2),
                const Color(0xFFff6b9d).withOpacity(0.1),
              ],
            ),
            accentColor: const Color(0xFFe91e63),
            imagePath: 'assets/images/features/relations_rings.jpg',
          ),
          const SizedBox(height: 16),
          _buildFeatureCard(
            icon: Icons.calendar_month_rounded,
            title: 'Daily Panchang',
            description:
                'Access the Hindu almanac with auspicious timings, tithis, and planetary hours',
            gradient: LinearGradient(
              colors: [
                const Color(0xFF00d4ff).withOpacity(0.2),
                const Color(0xFF0099cc).withOpacity(0.1),
              ],
            ),
            accentColor: const Color(0xFF00d4ff),
            imagePath: 'assets/images/features/panchang_temple.jpg',
          ),
          const SizedBox(height: 16),
          _buildFeatureCard(
            icon: Icons.emoji_events_rounded,
            title: 'Gamified Learning',
            description:
                'Earn badges, maintain streaks, and unlock achievements as you master astrology',
            gradient: LinearGradient(
              colors: [
                const Color(0xFFf5a623).withOpacity(0.2),
                const Color(0xFFff9500).withOpacity(0.1),
              ],
            ),
            accentColor: const Color(0xFFf5a623),
            imagePath: 'assets/images/features/badges_medal.jpg',
          ),
          const SizedBox(height: 16),
          _buildFeatureCard(
            icon: Icons.chat_bubble_rounded,
            title: 'AI-Powered Insights',
            description:
                'Ask questions about your chart and get intelligent, personalized answers',
            gradient: LinearGradient(
              colors: [
                const Color(0xFF7B61FF).withOpacity(0.2),
                const Color(0xFF5856d6).withOpacity(0.1),
              ],
            ),
            accentColor: const Color(0xFF7B61FF),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required Gradient gradient,
    required Color accentColor,
    String? imagePath,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: accentColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon or Image
                if (imagePath != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      imagePath,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                accentColor,
                                accentColor.withOpacity(0.6)
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(icon, color: Colors.white, size: 28),
                        );
                      },
                    ),
                  )
                else
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [accentColor, accentColor.withOpacity(0.6)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(icon, color: Colors.white, size: 28),
                  ),
                const SizedBox(width: 16),

                // Text content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        description,
                        style: GoogleFonts.quicksand(
                          fontSize: 13,
                          color: Colors.white60,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCTASection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Main CTA Button
          GestureDetector(
            onTap: () {
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => const LoginScreen(),
                  transitionsBuilder: (_, anim, __, child) {
                    return FadeTransition(
                      opacity: anim,
                      child: ScaleTransition(
                        scale: Tween<double>(begin: 0.95, end: 1.0).animate(
                          CurvedAnimation(parent: anim, curve: Curves.easeOut),
                        ),
                        child: child,
                      ),
                    );
                  },
                  transitionDuration: const Duration(milliseconds: 600),
                ),
              );
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                gradient: AstroTheme.primaryGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AstroTheme.accentPurple.withOpacity(0.5),
                    blurRadius: 20,
                    spreadRadius: 2,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Begin Your Journey',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Feature highlights
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 20,
            runSpacing: 12,
            children: [
              _buildHighlightChip('🎯 Personalized Learning'),
              _buildHighlightChip('🌟 Daily Insights'),
              _buildHighlightChip('🏆 Achievements'),
              _buildHighlightChip('🤝 Community'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Text(
        text,
        style: GoogleFonts.quicksand(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.white70,
        ),
      ),
    );
  }
}
