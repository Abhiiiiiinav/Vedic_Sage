
import 'dart:math';

/// Core Mathematical Constants and Utilities for Astrology
class AstroMath {
  static const double pi2 = 2 * pi;
  static const double rad2deg = 180 / pi;
  static const double deg2rad = pi / 180;

  /// Normalize angle to 0-360 degrees
  static double normalize(double angle) {
    angle = angle % 360;
    if (angle < 0) angle += 360;
    return angle;
  }

  /// Normalize angle to 0-2PI radians
  static double normalizeRad(double angle) {
    angle = angle % pi2;
    if (angle < 0) angle += pi2;
    return angle;
  }

  /// Convert degrees to radians
  static double toRad(double deg) => deg * deg2rad;

  /// Convert radians to degrees
  static double toDeg(double rad) => rad * rad2deg;

  /// Calculate sine of angle in degrees
  static double sind(double deg) => sin(toRad(deg));

  /// Calculate cosine of angle in degrees
  static double cosd(double deg) => cos(toRad(deg));

  /// Calculate tangent of angle in degrees
  static double tand(double deg) => tan(toRad(deg));
  
  /// Calculate arcsine returning degrees
  static double asind(double val) => toDeg(asin(val));

  /// Calculate arccosine returning degrees
  static double acosd(double val) => toDeg(acos(val));

  /// Calculate arctangent returning degrees
  static double atand(double val) => toDeg(atan(val));

  /// Calculate atan2 returning degrees
  static double atan2d(double y, double x) => toDeg(atan2(y, x));

  /// Julian Day from DateTime (UTC)
  static double julianDay(DateTime utc) {
    int y = utc.year;
    int m = utc.month;
    double d = utc.day + (utc.hour + utc.minute / 60.0 + utc.second / 3600.0) / 24.0;

    if (m <= 2) {
      y -= 1;
      m += 12;
    }

    int a = y ~/ 100;
    int b = 2 - a + (a ~/ 4);

    return (365.25 * (y + 4716)).floor() + (30.6001 * (m + 1)).floor() + d + b - 1524.5;
  }
}
