
import 'package:test/test.dart';
import 'package:astro_learn/core/data/nakshatra_extended_data.dart';
import 'package:astro_learn/core/utils/name_analysis_engine.dart';

void main() {
  group('Advanced Nakshatra Sound Analysis', () {
    test('Should identify primary Nakshatra for simple name', () {
      // "Chu" is a classic Ashwini sound
      final result = NameAnalysisEngine.analyzeNakshatraSounds("Chunmun");
      
      expect(result['name'], equals("Chunmun"));
      expect(result['influences'], isNotEmpty);
      
      final primary = result['primary_influence'];
      expect(primary['name'], equals('Ashwini'));
      expect(primary['matched_sounds'], contains('Chu'));
    });

    test('Should handle complex names with multiple influences', () {
      // "Vi" -> Rohini, "Sha" -> Hasta/Shatabhisha? 
      // Let's check "Vishal"
      final result = NameAnalysisEngine.analyzeNakshatraSounds("Vishal");
      
      // Rohini has "Vi", so it should be present
      final influences = result['influences'] as List;
      final rohini = influences.firstWhere((i) => i['name'] == 'Rohini', orElse: () => null);
      
      expect(rohini, isNotNull);
      expect(rohini['matched_sounds'], contains('Vi'));
    });

    test('Should handle names with foreign sounds normalized', () {
      // Logic now handles:
      // Z -> J
      // X -> S
      // Q -> K
      // PH -> F
      
      // "Zara" -> "Jara"
      // "Ja" is in Uttara Ashadha (Bhe, Bho, Ja, Ji...)
      final resultZ = NameAnalysisEngine.analyzeNakshatraSounds("Zara");
      final influencesZ = resultZ['influences'] as List;
      final uttaraAshadha = influencesZ.firstWhere((i) => i['name'] == 'Uttara Ashadha', orElse: () => null);
      
      expect(uttaraAshadha, isNotNull);
      expect(uttaraAshadha['matched_sounds'], contains('Ja'));

      // "Xavier" -> "Savier"
      // "Sa" is in Shatabhisha (Go, Sa, Si, Su...)
      final resultX = NameAnalysisEngine.analyzeNakshatraSounds("Xavier");
      final influencesX = resultX['influences'] as List;
      final shatabhisha = influencesX.firstWhere((i) => i['name'] == 'Shatabhisha', orElse: () => null);
      
      expect(shatabhisha, isNotNull);
    });

    test('Should return empty result for empty name', () {
      final result = NameAnalysisEngine.analyzeNakshatraSounds("");
      expect(result['total_matches'], equals(0));
    });
  });
}
