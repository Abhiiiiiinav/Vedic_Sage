
import 'dart:math';
import 'astro_math.dart';

/// Calculator for Ascendant (Lagna) and House Cusps
class AscendantCalculator {
  
  /// Calculate RAMC (Right Ascension of Meridian Center)
  static double calculateRAMC(double lst) {
    return lst;
  }

  /// Calculate Ascendant
  static double calculateAscendant(double lst, double lat, double obliquity) {
    // tan(Asc) = cos(RAMC) / ( - (sin(e) * tan(lat) + cos(e) * sin(RAMC)) ) ? No
    // Standard formula:
    // tan(Asc) = -cos(RAMC) / (sin(obl)*tan(lat) + cos(obl)*sin(RAMC))
    
    // Convert to radians
    double ramcRad = AstroMath.toRad(lst);
    double latRad = AstroMath.toRad(lat);
    double oblRad = AstroMath.toRad(obliquity);
    
    double y = -cos(ramcRad);
    double x = sin(oblRad) * tan(latRad) + cos(oblRad) * sin(ramcRad);
    
    double asc = atan2(y, x) * AstroMath.rad2deg;
    return AstroMath.normalize(asc);
  }
  
  /// Calculate Midheaven (MC) - 10th House Cusp
  static double calculateMC(double ramc, double obliquity) {
    double ramcRad = AstroMath.toRad(ramc);
    double oblRad = AstroMath.toRad(obliquity);
    
    double y = tan(ramcRad);
    double x = cos(oblRad);
    
    double mc = atan2(y, x) * AstroMath.rad2deg;
    if (mc < 0) mc += 360;
    
    // Quadrant check
    if (sin(ramcRad) < 0) mc += 180;
    
    return AstroMath.normalize(mc);
  }

  /// Calculate Equal House Cusps (Vedic Standard)
  /// House 1 = Ascendant - 15 degrees? No, Vedic usually uses Whole Sign or Equal House from Asc degree.
  /// Method 1: Whole Sign (House 1 = 0 deg of Asc Sign)
  /// Method 2: Equal House (House 1 = Asc +/- 15 deg, usually Start of House = Asc - 15)
  /// Method 3: Shripati (Porphyry-like)
  
  static List<double> calculateHousesEqual(double ascendant) {
    List<double> cusps = [];
    for (int i = 0; i < 12; i++) {
        // Simple Equal House: Each house starts at Ascendant degree
        // Note: Some traditions define Asc as MIDPOINT. 
        // Here we implement: Cusp = Ascendant + (i*30)
        cusps.add(AstroMath.normalize(ascendant + (i * 30.0)));
    }
    return cusps;
  }
}
