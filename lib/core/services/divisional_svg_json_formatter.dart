import 'svg_chart_parser.dart';

/// Formats SVG chart API output into a normalized JSON shape.
///
/// This is intended for divisional charts (D1, D2, ... D60).
class DivisionalSvgJsonFormatter {
  DivisionalSvgJsonFormatter._();

  /// Supported divisions in the app.
  static const List<String> supportedDivisions = [
    'd1',
    'd2',
    'd3',
    'd4',
    'd5',
    'd6',
    'd7',
    'd8',
    'd9',
    'd10',
    'd11',
    'd12',
    'd16',
    'd20',
    'd24',
    'd27',
    'd30',
    'd40',
    'd45',
    'd60',
  ];

  /// Process one chart API result.
  ///
  /// [apiResult] expects a payload like:
  /// `{ success: true, svg: "<svg...>", chart_name: "..." }`
  static Map<String, dynamic> formatSingleChart({
    required String division,
    required Map<String, dynamic> apiResult,
  }) {
    final normalizedDivision = division.toLowerCase();
    final svg = (apiResult['svg'] as String?)?.trim();

    if (svg == null || svg.isEmpty) {
      return {
        'success': false,
        'division': normalizedDivision,
        'error': 'Missing SVG in API result',
      };
    }

    final parsed = SvgChartParser.extractPositions(svg);

    return {
      'success': true,
      'division': normalizedDivision,
      'chart_name': (apiResult['chart_name'] as String?) ??
          normalizedDivision.toUpperCase(),
      'svg': svg,
      'ascendant_sign': parsed.ascendantSign,
      'ascendant_name': parsed.ascendantName,
      'planet_signs': parsed.planetSigns,
      'planets_in_houses':
          parsed.planetsInHouses.map((k, v) => MapEntry(k.toString(), v)),
      'meta': {
        'has_data': parsed.hasData,
        'planet_count': parsed.planetCount,
      },
    };
  }

  /// Process all divisional chart API results.
  ///
  /// [apiResultsByDivision] shape:
  /// `{ "d1": {...apiResult...}, "d9": {...apiResult...} }`
  ///
  /// Returns:
  /// `{ "divisions": {...formatted...}, "errors": {...}, "count": N }`
  static Map<String, dynamic> formatAllCharts(
    Map<String, Map<String, dynamic>> apiResultsByDivision,
  ) {
    final divisions = <String, dynamic>{};
    final errors = <String, String>{};

    for (final entry in apiResultsByDivision.entries) {
      final division = entry.key.toLowerCase();
      final result = entry.value;

      if (result['success'] != true) {
        errors[division] = (result['error'] as String?) ?? 'Unknown error';
        continue;
      }

      final formatted = formatSingleChart(
        division: division,
        apiResult: result,
      );

      if (formatted['success'] == true) {
        divisions[division] = formatted;
      } else {
        errors[division] =
            (formatted['error'] as String?) ?? 'Failed to process SVG';
      }
    }

    return {
      'divisions': divisions,
      'errors': errors.isEmpty ? null : errors,
      'count': divisions.length,
      'success': divisions.isNotEmpty,
    };
  }
}
