import 'package:flutter/material.dart';
import '../../../app/theme.dart';
import '../../../shared/widgets/astro_background.dart';
import '../../../shared/widgets/app_drawer.dart';
import '../../roadmap/screens/roadmap_screen.dart';
import '../../chart/screens/chart_screen.dart';
import '../../nakshatra/screens/nakshatra_screen.dart';
import '../../questions/screens/questions_screen.dart';
import '../../names/screens/names_screen.dart';
import '../../growth/screens/growth_screen.dart';
import '../../arudha/screens/arudha_screen.dart';
import '../../calculator/screens/birth_details_screen.dart';
import '../../dasha/screens/dasha_screen.dart';
import '../../panchang/screens/panchang_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late final List<Widget> _screens;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  final List<String> _screenTitles = [
    'Learning Roadmap',
    'Birth Chart',
    'Nakshatra Explorer',
    'Q&A',
    'Name Analysis',
    'Growth Tracker',
    'Arudha Lagna',
    'Calculator',
    'Dasha Periods',
    'Panchang',
  ];

  @override
  void initState() {
    super.initState();
    _screens = [
      const RoadmapScreen(),
      const ChartScreen(),
      const NakshatraScreen(),
      const QuestionsScreen(),
      const EnhancedNamesScreen(),
      const GrowthScreen(),
      const ArudhaScreen(),
      const BirthDetailsScreen(),
      const DashaScreen(),
      const PanchangScreen(),
    ];
    
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _onNavigate(int index) {
    if (index != _currentIndex) {
      _fadeController.reverse().then((_) {
        setState(() {
          _currentIndex = index;
        });
        _fadeController.forward();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          _screenTitles[_currentIndex],
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: AstroTheme.surfaceColor.withOpacity(0.8),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: AppDrawer(
        currentIndex: _currentIndex,
        onNavigate: _onNavigate,
      ),
      body: AstroBackground(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: _screens[_currentIndex],
        ),
      ),
    );
  }
}
