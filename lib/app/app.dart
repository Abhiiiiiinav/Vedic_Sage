import 'package:flutter/material.dart';
import '../features/home/screens/home_screen.dart';
import '../features/chart/screens/flask_chart_demo_screen.dart';
import 'theme.dart';

class AstroLearnApp extends StatelessWidget {
  const AstroLearnApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AstroLearn',
      debugShowCheckedModeBanner: false,
      theme: AstroTheme.darkTheme,
      home: const HomeScreen(),
      routes: {
        '/home': (context) => const HomeScreen(),
        '/chart-demo': (context) => const FlaskChartDemoScreen(),
      },
    );
  }
}
