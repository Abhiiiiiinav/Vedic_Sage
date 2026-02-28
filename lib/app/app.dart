import 'package:flutter/material.dart';
import '../features/home/screens/home_screen.dart';
import '../features/chart/screens/chart_api_demo_screen.dart';
import '../features/chart/screens/divisional_charts_table_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/signup_screen.dart';
import '../features/landing/screens/landing_page.dart';
import '../features/yogas/screens/yoga_screen.dart';
import '../features/yogas/screens/monthly_yogas_screen.dart';
import '../features/yogas/screens/annual_yogas_screen.dart';
import 'theme.dart';

class AstroLearnApp extends StatelessWidget {
  const AstroLearnApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AstroLearn',
      debugShowCheckedModeBanner: false,
      theme: AstroTheme.darkTheme,
      home: const LandingPage(),
      routes: {
        '/home': (context) => const HomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/chart-demo': (context) => const ChartApiDemoScreen(),
        '/divisional-charts-table': (context) =>
            const DivisionalChartsTableScreen(),
        '/landing': (context) => const LandingPage(),
        '/yogas': (context) => const YogaScreen(),
        '/yogas/monthly': (context) => const MonthlyYogasScreen(),
        '/yogas/annual': (context) => const AnnualYogasScreen(),
      },
    );
  }
}
