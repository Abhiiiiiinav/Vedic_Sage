import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AstroTheme {
  // Primary Colors
  static const Color scaffoldBackground = Color(0xFF0F1023);
  static const Color cardBackground = Color(0xFF1E2145);
  static const Color cardBackgroundLight = Color(0xFF2d2e43);
  static const Color surfaceColor = Color(0xFF1A1C3A);
  
  // Accent Colors
  static const Color accentGold = Color(0xFFf5a623);
  static const Color accentCyan = Color(0xFF00d4ff);
  static const Color accentPurple = Color(0xFF7B61FF);
  static const Color accentPink = Color(0xFFff6b9d);
  
  // Planet Colors
  static const Color sunColor = Color(0xFFff9500);
  static const Color moonColor = Color(0xFFc7c7cc);
  static const Color marsColor = Color(0xFFff3b30);
  static const Color mercuryColor = Color(0xFF34c759);
  static const Color jupiterColor = Color(0xFFffcc00);
  static const Color venusColor = Color(0xFFff2d55);
  static const Color saturnColor = Color(0xFF5856d6);
  static const Color rahuColor = Color(0xFFa2a1b5);
  static const Color ketuColor = Color(0xFF8e8e93);
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
  );
  
  static const LinearGradient cosmicGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF0F1023),
      Color(0xFF1A1C3A),
      Color(0xFF10122B),
    ],
  );
  
  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFf5a623), Color(0xFFf7931e)],
  );

  static const LinearGradient cyanGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF00d4ff), Color(0xFF0099cc)],
  );

  // Text Styles — Fun fonts via Google Fonts
  static TextStyle get headingLarge => GoogleFonts.outfit(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    letterSpacing: -0.5,
  );
  
  static TextStyle get headingMedium => GoogleFonts.outfit(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
  
  static TextStyle get headingSmall => GoogleFonts.outfit(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
  
  static TextStyle get bodyLarge => GoogleFonts.quicksand(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: Colors.white70,
    height: 1.6,
  );
  
  static TextStyle get bodyMedium => GoogleFonts.quicksand(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Colors.white60,
    height: 1.5,
  );
  
  static TextStyle get labelText => GoogleFonts.quicksand(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: Colors.white54,
    letterSpacing: 0.5,
  );

  // Theme Data
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: scaffoldBackground,
      primaryColor: accentPurple,
      colorScheme: const ColorScheme.dark(
        primary: accentPurple,
        secondary: accentGold,
        surface: cardBackground,
        background: scaffoldBackground,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onSurface: Colors.white,
        onBackground: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: headingSmall,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      cardTheme: CardThemeData(
        color: cardBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surfaceColor,
        selectedItemColor: accentGold,
        unselectedItemColor: Colors.white38,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: GoogleFonts.quicksand(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.quicksand(
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
      textTheme: TextTheme(
        headlineLarge: headingLarge,
        headlineMedium: headingMedium,
        headlineSmall: headingSmall,
        bodyLarge: bodyLarge,
        bodyMedium: bodyMedium,
        labelSmall: labelText,
      ),
      iconTheme: const IconThemeData(
        color: Colors.white70,
        size: 24,
      ),
      dividerTheme: const DividerThemeData(
        color: Colors.white12,
        thickness: 1,
      ),
    );
  }

  // Helper method to get planet color
  static Color getPlanetColor(String planet) {
    switch (planet.toLowerCase()) {
      case 'sun':
      case 'surya':
        return sunColor;
      case 'moon':
      case 'chandra':
        return moonColor;
      case 'mars':
      case 'mangal':
        return marsColor;
      case 'mercury':
      case 'budha':
        return mercuryColor;
      case 'jupiter':
      case 'guru':
        return jupiterColor;
      case 'venus':
      case 'shukra':
        return venusColor;
      case 'saturn':
      case 'shani':
        return saturnColor;
      case 'rahu':
        return rahuColor;
      case 'ketu':
        return ketuColor;
      default:
        return accentGold;
    }
  }
}
