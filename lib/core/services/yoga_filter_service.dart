import '../models/yoga_models.dart';

/// Service for filtering yoga results by purpose and auspiciousness
class YogaFilterService {
  /// Filter yogas by a specific purpose
  /// 
  /// Returns only yogas that are applicable for the given purpose.
  /// Inauspicious yogas (which have empty purposes list) are excluded.
  /// 
  /// Returns an empty list if input is null or empty.
  /// 
  /// Example:
  /// ```dart
  /// final marriageYogas = filterByPurpose(allYogas, YogaPurpose.marriage);
  /// ```
  List<YogaResult> filterByPurpose(
    List<YogaResult>? yogas,
    YogaPurpose purpose,
  ) {
    if (yogas == null || yogas.isEmpty) {
      return [];
    }
    
    try {
      return yogas.where((yoga) {
        return yoga.purposes.contains(purpose);
      }).toList();
    } catch (e) {
      print('Error filtering yogas by purpose: $e');
      return [];
    }
  }

  /// Get only auspicious yogas from the list
  /// 
  /// Returns yogas where isAuspicious is true.
  /// Returns an empty list if input is null or empty.
  /// 
  /// Example:
  /// ```dart
  /// final goodYogas = getAuspiciousYogas(allYogas);
  /// ```
  List<YogaResult> getAuspiciousYogas(List<YogaResult>? yogas) {
    if (yogas == null || yogas.isEmpty) {
      return [];
    }
    
    try {
      return yogas.where((yoga) => yoga.isAuspicious).toList();
    } catch (e) {
      print('Error filtering auspicious yogas: $e');
      return [];
    }
  }

  /// Get only inauspicious yogas from the list
  /// 
  /// Returns yogas where isAuspicious is false.
  /// Returns an empty list if input is null or empty.
  /// 
  /// Example:
  /// ```dart
  /// final badYogas = getInauspiciousYogas(allYogas);
  /// ```
  List<YogaResult> getInauspiciousYogas(List<YogaResult>? yogas) {
    if (yogas == null || yogas.isEmpty) {
      return [];
    }
    
    try {
      return yogas.where((yoga) => !yoga.isAuspicious).toList();
    } catch (e) {
      print('Error filtering inauspicious yogas: $e');
      return [];
    }
  }

  /// Filter yogas by multiple purposes (OR logic)
  /// 
  /// Returns yogas that are applicable for at least one of the given purposes.
  /// Returns all yogas if purposes list is empty.
  /// Returns an empty list if yogas is null or empty.
  /// 
  /// Example:
  /// ```dart
  /// final relevantYogas = filterByPurposes(
  ///   allYogas, 
  ///   [YogaPurpose.marriage, YogaPurpose.business]
  /// );
  /// ```
  List<YogaResult> filterByPurposes(
    List<YogaResult>? yogas,
    List<YogaPurpose>? purposes,
  ) {
    if (yogas == null || yogas.isEmpty) {
      return [];
    }
    
    if (purposes == null || purposes.isEmpty) {
      return yogas;
    }
    
    try {
      return yogas.where((yoga) {
        return yoga.purposes.any((purpose) => purposes.contains(purpose));
      }).toList();
    } catch (e) {
      print('Error filtering yogas by purposes: $e');
      return [];
    }
  }

  /// Get yogas grouped by auspiciousness
  /// 
  /// Returns a map with 'auspicious' and 'inauspicious' keys.
  /// Returns empty lists if input is null or empty.
  /// 
  /// Example:
  /// ```dart
  /// final grouped = groupByAuspiciousness(allYogas);
  /// print('Auspicious: ${grouped['auspicious']?.length}');
  /// print('Inauspicious: ${grouped['inauspicious']?.length}');
  /// ```
  Map<String, List<YogaResult>> groupByAuspiciousness(List<YogaResult>? yogas) {
    return {
      'auspicious': getAuspiciousYogas(yogas),
      'inauspicious': getInauspiciousYogas(yogas),
    };
  }

  /// Get count of yogas by purpose
  /// 
  /// Returns a map showing how many yogas are applicable for each purpose.
  /// Returns zero counts if input is null or empty.
  /// 
  /// Example:
  /// ```dart
  /// final counts = getCountByPurpose(allYogas);
  /// print('Marriage yogas: ${counts[YogaPurpose.marriage]}');
  /// ```
  Map<YogaPurpose, int> getCountByPurpose(List<YogaResult>? yogas) {
    final counts = <YogaPurpose, int>{};
    
    if (yogas == null || yogas.isEmpty) {
      // Return zero counts for all purposes
      for (final purpose in YogaPurpose.values) {
        counts[purpose] = 0;
      }
      return counts;
    }
    
    try {
      for (final purpose in YogaPurpose.values) {
        counts[purpose] = filterByPurpose(yogas, purpose).length;
      }
    } catch (e) {
      print('Error counting yogas by purpose: $e');
      // Return zero counts on error
      for (final purpose in YogaPurpose.values) {
        counts[purpose] = 0;
      }
    }
    
    return counts;
  }
}
