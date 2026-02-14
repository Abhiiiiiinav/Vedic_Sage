import 'package:flutter/material.dart';
import '../../../app/theme.dart';
import '../../../shared/widgets/section_card.dart';
import '../../../shared/widgets/astro_background.dart';
import '../../../core/services/user_session.dart';
import '../../../core/astro/arudha_engine.dart';
import '../../../core/constants/arudha_education_data.dart';

class ArudhaScreen extends StatefulWidget {
  const ArudhaScreen({super.key});

  @override
  State<ArudhaScreen> createState() => _ArudhaScreenState();
}

class _ArudhaScreenState extends State<ArudhaScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<ArudhaPada>? _arudhas;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadArudhas();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadArudhas() {
    final session = UserSession();
    if (session.hasData && session.birthChart != null) {
      setState(() {
        _arudhas = ArudhaEngine.calculateFromChart(session.birthChart!);
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AstroBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 12),
              _buildTabBar(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildMyArudhasTab(),
                    _buildLearnTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AstroTheme.accentPurple.withOpacity(0.3),
            AstroTheme.accentCyan.withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ),
          const SizedBox(height: 8),
          const Icon(Icons.visibility, color: AstroTheme.accentCyan, size: 48),
          const SizedBox(height: 12),
          Text('Arudhas: Your Public Image', style: AstroTheme.headingLarge),
          const SizedBox(height: 8),
          Text(
            'How others perceive you vs. your true self',
            style: AstroTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: AstroTheme.primaryGradient,
          borderRadius: BorderRadius.circular(10),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white60,
        tabs: const [
          Tab(text: 'My Arudhas'),
          Tab(text: 'Learn'),
        ],
      ),
    );
  }

  Widget _buildMyArudhasTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_arudhas == null || _arudhas!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_outline, size: 64, color: Colors.white38),
            const SizedBox(height: 16),
            Text(
              'Birth details needed',
              style: AstroTheme.headingSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Enter your birth details in Profile\nto see your Arudha Padas',
              textAlign: TextAlign.center,
              style: AstroTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    final arudhaLagna = ArudhaEngine.getArudhaLagna(_arudhas!);
    final importantArudhas = ArudhaEngine.getImportantArudhas(_arudhas!);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (arudhaLagna != null) ...[
          _buildArudhaLagnaHighlight(arudhaLagna),
          const SizedBox(height: 20),
        ],
        Text('Important Arudhas', style: AstroTheme.headingSmall),
        const SizedBox(height: 12),
        ...importantArudhas.map((a) => _buildArudhaCard(a)),
        const SizedBox(height: 20),
        Text('All Arudha Padas', style: AstroTheme.headingSmall),
        const SizedBox(height: 12),
        ..._arudhas!.map((a) => _buildCompactArudhaRow(a)),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildArudhaLagnaHighlight(ArudhaPada al) {
    final education = ArudhaEducationData.getArudha(1);
    final interpretation = education?.signInterpretations[al.signName] ?? '';
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AstroTheme.goldGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AstroTheme.accentGold.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.account_circle, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your Arudha Lagna (AL)',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      al.signName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'House ${al.housePosition}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              interpretation,
              style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.5),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.lightbulb_outline, color: Colors.white70, size: 16),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'This is how people first perceive you',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildArudhaCard(ArudhaPada arudha) {
    final education = ArudhaEducationData.getArudha(arudha.houseNumber);
    final interpretation = education?.signInterpretations[arudha.signName] ?? '';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AstroTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AstroTheme.accentCyan.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  arudha.abbreviation,
                  style: const TextStyle(
                    color: AstroTheme.accentCyan,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      arudha.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: Colors.white,
                      ),
                    ),
                    if (education != null)
                      Text(
                        education.domain,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white60,
                        ),
                      ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    arudha.signName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AstroTheme.accentGold,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    'House ${arudha.housePosition}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white54,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (interpretation.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              interpretation,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 13,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => _showStrengtheningTips(arudha),
            child: Row(
              children: [
                Icon(Icons.fitness_center, color: Colors.green.withOpacity(0.7), size: 16),
                const SizedBox(width: 6),
                Text(
                  'View strengthening tips',
                  style: TextStyle(
                    color: Colors.green.withOpacity(0.8),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Icon(Icons.arrow_forward_ios, size: 12, color: Colors.white38),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactArudhaRow(ArudhaPada arudha) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AstroTheme.accentPurple.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${arudha.houseNumber}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AstroTheme.accentPurple,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  arudha.name,
                  style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
                ),
                Text(
                  arudha.abbreviation,
                  style: TextStyle(fontSize: 12, color: Colors.white54),
                ),
              ],
            ),
          ),
          Text(
            arudha.signName,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AstroTheme.accentGold,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'H${arudha.housePosition}',
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ],
      ),
    );
  }

  void _showStrengtheningTips(ArudhaPada arudha) {
    final education = ArudhaEducationData.getArudha(arudha.houseNumber);
    if (education == null) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: AstroTheme.scaffoldBackground,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white30,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.fitness_center, color: Colors.green),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Strengthen ${arudha.abbreviation}',
                        style: AstroTheme.headingSmall,
                      ),
                      Text(
                        '${arudha.name} in ${arudha.signName}',
                        style: TextStyle(color: Colors.white60),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              education.description,
              style: AstroTheme.bodyLarge.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: 20),
            Text('Strengthening Tips', style: AstroTheme.headingSmall.copyWith(color: Colors.green)),
            const SizedBox(height: 12),
            ...education.strengtheningTips.map((tip) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(tip, style: AstroTheme.bodyMedium),
                  ),
                ],
              ),
            )),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AstroTheme.accentGold.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AstroTheme.accentGold.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.auto_awesome, color: AstroTheme.accentGold, size: 18),
                      const SizedBox(width: 8),
                      const Text(
                        'Astrologer\'s Note',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AstroTheme.accentGold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    education.masterNote,
                    style: TextStyle(
                      color: Colors.white,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildLearnTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildIntroCard(),
        const SizedBox(height: 16),
        _buildArudhaLagnaCard(),
        const SizedBox(height: 16),
        _buildArudhaPadaCard(),
        const SizedBox(height: 16),
        _buildHowToCalculateCard(),
        const SizedBox(height: 16),
        _buildPerceptionTypesCard(),
        const SizedBox(height: 16),
        _buildImprovementTipsCard(),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildIntroCard() {
    return SectionCard(
      title: 'What are Arudhas?',
      icon: Icons.psychology,
      accentColor: AstroTheme.accentPurple,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Arudha literally means "mounted" or "reflected image" in Sanskrit. It represents how the world perceives you, which can be very different from your true nature.',
            style: AstroTheme.bodyLarge.copyWith(height: 1.8),
          ),
          const SizedBox(height: 16),
          Text(
            'Key Concepts:',
            style: AstroTheme.headingSmall.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 12),
          _buildBulletPoint('🎭 Arudha = Your projected image, the mask you wear'),
          _buildBulletPoint('💫 Lagna = Your true self, inner reality'),
          _buildBulletPoint('🔄 The gap between these creates your public persona'),
          _buildBulletPoint('🎯 Understanding this helps manage reputation and image'),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AstroTheme.accentPurple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AstroTheme.accentPurple.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.lightbulb, color: AstroTheme.accentPurple),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Example: Your ascendant is Aries (warrior, direct) but Arudha Lagna in Libra makes people see you as diplomatic and balanced.',
                    style: AstroTheme.bodyMedium.copyWith(fontStyle: FontStyle.italic),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArudhaLagnaCard() {
    return SectionCard(
      title: 'Arudha Lagna (AL)',
      icon: Icons.account_circle,
      accentColor: AstroTheme.accentCyan,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Arudha Lagna represents your overall public image and how society perceives your personality and status.',
            style: AstroTheme.bodyLarge.copyWith(height: 1.8),
          ),
          const SizedBox(height: 16),
          Text('What It Reveals:', style: AstroTheme.headingSmall.copyWith(fontSize: 16)),
          const SizedBox(height: 12),
          _buildNumberedPoint('1', 'Your social status and reputation'),
          _buildNumberedPoint('2', 'How people judge your character at first glance'),
          _buildNumberedPoint('3', 'Your public persona in professional settings'),
          _buildNumberedPoint('4', 'The "mask" you unconsciously project'),
          _buildNumberedPoint('5', 'Material success and worldly achievements'),
        ],
      ),
    );
  }

  Widget _buildArudhaPadaCard() {
    return SectionCard(
      title: 'Arudha Padas for Each House',
      icon: Icons.home_work,
      accentColor: AstroTheme.accentGold,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Each house has an Arudha Pada (AP) that shows how that life area appears to others:',
            style: AstroTheme.bodyLarge.copyWith(height: 1.8),
          ),
          const SizedBox(height: 16),
          _buildArudhaPadaItem('A2 (Dhana Pada)', 'Wealth & family image', 'How rich/successful you appear'),
          _buildArudhaPadaItem('A4 (Sukha Pada)', 'Happiness & property', 'Perceived comfort and luxury'),
          _buildArudhaPadaItem('A5 (Mantra Pada)', 'Intelligence & children', 'How smart/talented you seem'),
          _buildArudhaPadaItem('A7 (Dara Pada)', 'Marriage & partnerships', 'Your relationships in public eye'),
          _buildArudhaPadaItem('A9 (Bhagya Pada)', 'Luck & dharma', 'How fortunate people think you are'),
          _buildArudhaPadaItem('A10 (Karma Pada)', 'Career & authority', 'Your professional reputation'),
          _buildArudhaPadaItem('A11 (Labha Pada)', 'Gains & income', 'Perceived financial success'),
        ],
      ),
    );
  }

  Widget _buildHowToCalculateCard() {
    return SectionCard(
      title: 'How to Calculate Arudhas',
      icon: Icons.calculate,
      accentColor: const Color(0xFF4caf50),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Arudha calculation is a unique Jyotish technique:',
            style: AstroTheme.bodyLarge.copyWith(height: 1.8),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF4caf50).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF4caf50).withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Basic Formula:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF4caf50)),
                ),
                const SizedBox(height: 12),
                _buildCalculationStep('1', 'Count houses from Lagna to sign\'s lord'),
                _buildCalculationStep('2', 'Count the same number from that lord\'s position'),
                _buildCalculationStep('3', 'The resulting sign is the Arudha'),
                _buildCalculationStep('4', 'Apply special rules for houses 1,4,7,10'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerceptionTypesCard() {
    return SectionCard(
      title: 'Types of Perception Gaps',
      icon: Icons.loop,
      accentColor: AstroTheme.accentPink,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPerceptionType(
            'The Underestimated',
            'You\'re more capable than people think',
            'Strong Lagna, weak Arudha Lagna',
            AstroTheme.accentCyan,
          ),
          const SizedBox(height: 12),
          _buildPerceptionType(
            'The Overestimated',
            'Your image exceeds your actual abilities',
            'Weak Lagna, strong Arudha Lagna',
            AstroTheme.accentGold,
          ),
          const SizedBox(height: 12),
          _buildPerceptionType(
            'The Authentic',
            'Your image matches your reality',
            'Aligned Lagna and Arudha Lagna',
            const Color(0xFF4caf50),
          ),
          const SizedBox(height: 12),
          _buildPerceptionType(
            'The Misunderstood',
            'People see you completely differently',
            'Lagna and Arudha in opposite signs',
            AstroTheme.accentPurple,
          ),
        ],
      ),
    );
  }

  Widget _buildImprovementTipsCard() {
    return SectionCard(
      title: 'Improving Your Public Image',
      icon: Icons.trending_up,
      accentColor: const Color(0xFF4caf50),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Practical ways to align your image with your goals:',
            style: AstroTheme.bodyLarge.copyWith(height: 1.8),
          ),
          const SizedBox(height: 16),
          _buildTipCard('1. Strengthen Arudha Lagna', [
            'Wear colors of that sign',
            'Follow remedies for ruling planet',
            'Be conscious of first impressions',
          ], Icons.color_lens),
          const SizedBox(height: 12),
          _buildTipCard('2. Work on Relevant Padas', [
            'A10 for career reputation',
            'A7 for relationship image',
            'A2 for wealth perception',
          ], Icons.work),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: AstroTheme.bodyLarge.copyWith(height: 1.6)),
    );
  }

  Widget _buildNumberedPoint(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AstroTheme.accentCyan.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(fontWeight: FontWeight.bold, color: AstroTheme.accentCyan),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: AstroTheme.bodyLarge)),
        ],
      ),
    );
  }

  Widget _buildArudhaPadaItem(String pada, String represents, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AstroTheme.accentGold.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AstroTheme.accentGold.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              pada,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AstroTheme.accentGold),
            ),
            const SizedBox(height: 4),
            Text(represents, style: AstroTheme.bodyMedium),
            const SizedBox(height: 2),
            Text(
              description,
              style: AstroTheme.bodyMedium.copyWith(color: Colors.white60, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalculationStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$number. ',
            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4caf50)),
          ),
          Expanded(child: Text(text, style: const TextStyle(color: Colors.white))),
        ],
      ),
    );
  }

  Widget _buildPerceptionType(String title, String description, String condition, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color),
          ),
          const SizedBox(height: 6),
          Text(description, style: AstroTheme.bodyLarge),
          const SizedBox(height: 4),
          Text(
            condition,
            style: AstroTheme.bodyMedium.copyWith(color: Colors.white60, fontSize: 13, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  Widget _buildTipCard(String title, List<String> tips, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF4caf50).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF4caf50).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF4caf50), size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF4caf50)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...tips.map((tip) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• ', style: TextStyle(color: Color(0xFF4caf50))),
                Expanded(child: Text(tip, style: AstroTheme.bodyMedium)),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
