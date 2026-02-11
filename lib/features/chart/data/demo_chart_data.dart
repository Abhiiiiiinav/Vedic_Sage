import '../models/chart_models.dart';

class DemoChartData {
  static final planets = [
    PlanetPlacement(id: 'sun', name: 'Sun', symbol: '☉', house: 1),
    PlanetPlacement(id: 'moon', name: 'Moon', symbol: '☽', house: 4),
    PlanetPlacement(id: 'mars', name: 'Mars', symbol: '♂', house: 7),
    PlanetPlacement(id: 'mer', name: 'Mercury', symbol: '☿', house: 10),
    PlanetPlacement(id: 'jup', name: 'Jupiter', symbol: '♃', house: 1),
    PlanetPlacement(id: 'ven', name: 'Venus', symbol: '♀', house: 5),
    PlanetPlacement(id: 'sat', name: 'Saturn', symbol: '♄', house: 9),
    PlanetPlacement(id: 'rahu', name: 'Rahu', symbol: '☊', house: 3),
    PlanetPlacement(id: 'ketu', name: 'Ketu', symbol: '☋', house: 9),
  ];

  // Convert to kundali_chart format
  // Returns List<List<String>> where each inner list represents planets in that house
  static List<List<String>> toKundaliFormat() {
    // Initialize 12 empty houses
    final houses = List<List<String>>.generate(12, (_) => []);
    
    // Map planet IDs to standard abbreviations
    final planetAbbreviations = {
      'sun': 'Su',
      'moon': 'Mo',
      'mars': 'Ma',
      'mer': 'Me',
      'jup': 'Ju',
      'ven': 'Ve',
      'sat': 'Sa',
      'rahu': 'Ra',
      'ketu': 'Ke',
    };
    
    // Place planets in their respective houses
    for (final planet in planets) {
      final houseIndex = planet.house - 1; // Convert to 0-indexed
      if (houseIndex >= 0 && houseIndex < 12) {
        final abbr = planetAbbreviations[planet.id] ?? planet.id;
        houses[houseIndex].add(abbr);
      }
    }
    
    return houses;
  }
}
