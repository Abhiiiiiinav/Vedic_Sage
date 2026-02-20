import 'package:http/http.dart' as http;
import 'direct_svg_chart_service.dart';
import 'free_astrology_api_service.dart';
import 'svg_chart_parser.dart';

/// Compatibility service for chart + planets APIs.
/// Internally this now calls Free Astrology API directly (no Flask dependency).
class ChartApiService {
  static const String _defaultBaseUrl = 'https://json.freeastrologyapi.com';
  static const List<String> _signNames = [
    'Aries',
    'Taurus',
    'Gemini',
    'Cancer',
    'Leo',
    'Virgo',
    'Libra',
    'Scorpio',
    'Sagittarius',
    'Capricorn',
    'Aquarius',
    'Pisces',
  ];

  final String baseUrl;
  final http.Client _client;
  final DirectSvgChartService _directSvgService;

  ChartApiService({
    String? customBaseUrl,
    http.Client? client,
  })  : baseUrl = customBaseUrl ?? _defaultBaseUrl,
        _client = client ?? http.Client(),
        _directSvgService = DirectSvgChartService();

  /// Check if the backend is running
  Future<bool> healthCheck() async {
    return true;
  }

  /// Generate D1 Rasi Chart (Birth Chart) SVG using GET endpoint
  /// This is useful for simpler use cases with query parameters
  Future<ChartResponse> getKundaliChartViaGet(BirthDetails birthDetails,
      {String division = 'd1'}) async {
    return _fetchChart('/chart/${division.toLowerCase()}', birthDetails);
  }

  /// Generate D1 Rasi Chart (Birth Chart) SVG
  Future<ChartResponse> getD1Chart(BirthDetails birthDetails) async {
    return _fetchChart('/chart/d1', birthDetails);
  }

  /// Generate D2 Hora Chart SVG
  Future<ChartResponse> getD2Chart(BirthDetails birthDetails) async {
    return _fetchChart('/chart/d2', birthDetails);
  }

  /// Generate D3 Drekkana Chart SVG
  Future<ChartResponse> getD3Chart(BirthDetails birthDetails) async {
    return _fetchChart('/chart/d3', birthDetails);
  }

  /// Generate D4 Chaturthamsa Chart SVG
  Future<ChartResponse> getD4Chart(BirthDetails birthDetails) async {
    return _fetchChart('/chart/d4', birthDetails);
  }

  /// Generate D7 Saptamsa Chart SVG
  Future<ChartResponse> getD7Chart(BirthDetails birthDetails) async {
    return _fetchChart('/chart/d7', birthDetails);
  }

  /// Generate D9 Navamsa Chart SVG
  Future<ChartResponse> getD9Chart(BirthDetails birthDetails) async {
    return _fetchChart('/chart/d9', birthDetails);
  }

  /// Generate D10 Dasamsa Chart SVG
  Future<ChartResponse> getD10Chart(BirthDetails birthDetails) async {
    return _fetchChart('/chart/d10', birthDetails);
  }

  /// Generate D12 Dwadasamsa Chart SVG
  Future<ChartResponse> getD12Chart(BirthDetails birthDetails) async {
    return _fetchChart('/chart/d12', birthDetails);
  }

  /// Generate any divisional chart by division number
  Future<ChartResponse> getChartByDivision(
    BirthDetails birthDetails,
    int division,
  ) async {
    return _fetchChart('/chart/d$division', birthDetails);
  }

  /// Generate multiple charts at once
  Future<BatchChartResponse> getMultipleCharts(
    BirthDetails birthDetails, {
    List<String> charts = const ['d1', 'd9', 'd10'],
  }) async {
    try {
      print('📡 Fetching batch charts directly: ${charts.join(", ")}');
      final parsedCharts = <String, ChartData>{};
      final errors = <String, String>{};

      final futures = charts.map((chartKey) async {
        final result = await _directSvgService.fetchChartAsJson(
          division: chartKey.toLowerCase(),
          request: _toSvgRequest(birthDetails),
        );
        return MapEntry(chartKey.toLowerCase(), result);
      }).toList();

      final results = await Future.wait(futures);
      for (final item in results) {
        final key = item.key;
        final result = item.value;
        if (result['success'] == true && result['svg'] != null) {
          parsedCharts[key] = ChartData(
            svg: result['svg'] as String,
            name: (result['chart_name'] as String?) ?? key.toUpperCase(),
          );
        } else {
          errors[key] = (result['error'] as String?) ?? 'Unknown error';
        }
      }

      return BatchChartResponse(
        success: parsedCharts.isNotEmpty,
        charts: parsedCharts,
        count: parsedCharts.length,
        errors: errors.isEmpty ? null : errors,
      );
    } catch (e) {
      print('❌ Batch network error: $e');
      return BatchChartResponse(
        success: false,
        error: 'Failed to fetch charts: $e',
      );
    }
  }

  /// Common method to fetch a chart
  Future<ChartResponse> _fetchChart(
    String endpoint,
    BirthDetails birthDetails,
  ) async {
    try {
      final division = endpoint.split('/').last.toLowerCase();
      final result = await _directSvgService.fetchChartAsJson(
        division: division,
        request: _toSvgRequest(birthDetails),
      );

      if (result['success'] == true) {
        final svgContent = result['svg'] as String?;
        return ChartResponse(
          success: true,
          svg: svgContent,
          chartType: result['chart_type'] as String?,
          name: result['chart_name'] as String?,
        );
      }

      return ChartResponse(
        success: false,
        error: (result['error'] as String?) ?? 'Unknown error',
      );
    } catch (e) {
      print('❌ Network error: $e');
      return ChartResponse(
        success: false,
        error: 'Failed to fetch chart: $e',
      );
    }
  }

  /// Fetch details about planetary positions
  Future<Map<String, dynamic>> getPlanetaryData(
      BirthDetails birthDetails) async {
    try {
      final data = await FreeAstrologyApiService.fetchBirthChart(
        year: birthDetails.year,
        month: birthDetails.month,
        date: birthDetails.date,
        hours: birthDetails.hours,
        minutes: birthDetails.minutes,
        latitude: birthDetails.latitude,
        longitude: birthDetails.longitude,
        timezone: birthDetails.timezone,
        config: {
          'observation_point': birthDetails.observationPoint,
          'ayanamsha': birthDetails.ayanamsha,
        },
      );

      final output = data['output'] ?? data;
      if (output is List) {
        final planets = <String, dynamic>{};
        for (final item in output) {
          if (item is Map) {
            item.forEach((key, value) {
              if (value is Map && value.containsKey('name')) {
                planets[value['name'].toString()] = value;
              } else if (key.toString() == 'ayanamsa') {
                planets['ayanamsa'] = value;
              }
            });
          }
        }
        return planets;
      }
      return {};
    } catch (e) {
      print('❌ Error fetching planets: $e');
      return {};
    }
  }

  /// Fetch full kundali data from the /kundali/full endpoint.
  ///
  /// Returns SVG + planet positions + degrees + nakshatras for all divisions.
  Future<Map<String, dynamic>?> fetchFullKundali({
    required int year,
    required int month,
    required int date,
    required int hours,
    required int minutes,
    int seconds = 0,
    required double latitude,
    required double longitude,
    required double timezone,
    String ayanamsha = 'lahiri',
    List<String>? divisions,
  }) async {
    try {
      final birthDetails = BirthDetails(
        year: year,
        month: month,
        date: date,
        hours: hours,
        minutes: minutes,
        seconds: seconds,
        latitude: latitude,
        longitude: longitude,
        timezone: timezone,
        ayanamsha: ayanamsha,
      );

      final requestedDivisions = divisions ??
          const [
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

      final divisionsResult = <String, dynamic>{};
      final errors = <String, String>{};
      for (final division in requestedDivisions) {
        final result = await _directSvgService.fetchChartAsJson(
          division: division.toLowerCase(),
          request: _toSvgRequest(birthDetails),
        );

        if (result['success'] == true && result['svg'] is String) {
          final svg = result['svg'] as String;
          final parsed = SvgChartParser.extractPositions(svg);
          divisionsResult[division.toLowerCase()] = {
            'svg': svg,
            'chart_name': result['chart_name'] ?? division.toUpperCase(),
            'ascendant_sign': parsed.ascendantSign,
            'ascendant_name': parsed.ascendantName,
            'planet_signs': parsed.planetSigns,
            'planets_in_houses': parsed.planetsInHouses
                .map((k, v) => MapEntry(k.toString(), v)),
          };
        } else {
          errors[division.toLowerCase()] =
              (result['error'] as String?) ?? 'Unknown error';
        }
      }

      final planetaryData = await getPlanetaryData(birthDetails);
      final d1Planets = <String, dynamic>{};
      final nakshatras = <String, dynamic>{};

      planetaryData.forEach((name, value) {
        if (value is! Map<String, dynamic>) return;
        final fullDegree =
            ((value['fullDegree'] ?? value['full_degree'] ?? 0) as num)
                .toDouble();
        final sign =
            ((value['current_sign'] ?? value['sign_num'] ?? 0) as num).toInt();
        final nak = SvgChartParser.calculateNakshatra(fullDegree);
        d1Planets[name] = {
          'fullDegree': fullDegree,
          'normDegree': ((value['normDegree'] ?? value['sign_degree'] ?? 0)
                  as num)
              .toDouble(),
          'sign': sign,
          'sign_name': sign > 0 ? _signNames[sign - 1] : 'Unknown',
          'house': ((value['house_number'] ?? value['house'] ?? 0) as num)
              .toInt(),
          'isRetro': (value['isRetro'] ?? value['is_retro'] ?? false) as bool,
          'nakshatra': nak.nakshatra,
          'nakshatra_pada': nak.pada,
          'nakshatra_lord': nak.lord,
        };

        if (name != 'Ascendant' && name != 'ayanamsa') {
          nakshatras[name] = {
            'nakshatra': nak.nakshatra,
            'pada': nak.pada,
            'lord': nak.lord,
          };
        }
      });

      return {
        'success': divisionsResult.isNotEmpty,
        'divisions': divisionsResult,
        'd1_planets': d1Planets,
        'nakshatras': nakshatras,
        'errors': errors.isEmpty ? null : errors,
        'count': divisionsResult.length,
      };
    } catch (e) {
      print('❌ Error fetching full kundali: $e');
      return null;
    }
  }

  /// Dispose of HTTP client
  void dispose() {
    _client.close();
    _directSvgService.dispose();
  }

  void useNextApiKey() {
    _directSvgService.useNextApiKey();
  }

  SvgChartRequest _toSvgRequest(BirthDetails birthDetails) {
    return SvgChartRequest(
      year: birthDetails.year,
      month: birthDetails.month,
      date: birthDetails.date,
      hours: birthDetails.hours,
      minutes: birthDetails.minutes,
      seconds: birthDetails.seconds,
      latitude: birthDetails.latitude,
      longitude: birthDetails.longitude,
      timezone: birthDetails.timezone,
      observationPoint: birthDetails.observationPoint,
      ayanamsha: birthDetails.ayanamsha,
    );
  }
}

/// Birth details model for chart generation
class BirthDetails {
  final int year;
  final int month;
  final int date;
  final int hours;
  final int minutes;
  final int seconds;
  final double latitude;
  final double longitude;
  final double timezone;
  final String observationPoint;
  final String ayanamsha;

  BirthDetails({
    required this.year,
    required this.month,
    required this.date,
    required this.hours,
    required this.minutes,
    this.seconds = 0,
    required this.latitude,
    required this.longitude,
    this.timezone = 5.5, // IST default
    this.observationPoint = 'topocentric',
    this.ayanamsha = 'lahiri',
  });

  Map<String, dynamic> toJson() => {
        'year': year,
        'month': month,
        'date': date,
        'hours': hours,
        'minutes': minutes,
        'seconds': seconds,
        'latitude': latitude,
        'longitude': longitude,
        'timezone': timezone,
        'observation_point': observationPoint,
        'ayanamsha': ayanamsha,
      };

  factory BirthDetails.fromJson(Map<String, dynamic> json) => BirthDetails(
        year: json['year'],
        month: json['month'],
        date: json['date'],
        hours: json['hours'],
        minutes: json['minutes'],
        seconds: json['seconds'] ?? 0,
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        timezone: (json['timezone'] as num?)?.toDouble() ?? 5.5,
        observationPoint: json['observation_point'] ?? 'topocentric',
        ayanamsha: json['ayanamsha'] ?? 'lahiri',
      );

  /// Create from DateTime and location
  factory BirthDetails.fromDateTime({
    required DateTime dateTime,
    required double latitude,
    required double longitude,
    double timezone = 5.5,
    String ayanamsha = 'lahiri',
  }) {
    return BirthDetails(
      year: dateTime.year,
      month: dateTime.month,
      date: dateTime.day,
      hours: dateTime.hour,
      minutes: dateTime.minute,
      seconds: dateTime.second,
      latitude: latitude,
      longitude: longitude,
      timezone: timezone,
      ayanamsha: ayanamsha,
    );
  }
}

/// Response model for single chart generation
class ChartResponse {
  final bool success;
  final String? svg;
  final String? chartType;
  final String? name;
  final String? error;

  ChartResponse({
    required this.success,
    this.svg,
    this.chartType,
    this.name,
    this.error,
  });
}

/// Individual chart data
class ChartData {
  final String svg;
  final String name;

  ChartData({
    required this.svg,
    required this.name,
  });
}

/// Response model for batch chart generation
class BatchChartResponse {
  final bool success;
  final Map<String, ChartData>? charts;
  final int? count;
  final Map<String, String>? errors;
  final String? error;

  BatchChartResponse({
    required this.success,
    this.charts,
    this.count,
    this.errors,
    this.error,
  });
}

/// Enum for available divisional charts
enum DivisionalChart {
  d1('D1', 'Rasi', 'Birth Chart - General life'),
  d2('D2', 'Hora', 'Wealth & prosperity'),
  d3('D3', 'Drekkana', 'Siblings & courage'),
  d4('D4', 'Chaturthamsa', 'Fortune & property'),
  d7('D7', 'Saptamsa', 'Children & progeny'),
  d9('D9', 'Navamsa', 'Marriage & dharma'),
  d10('D10', 'Dasamsa', 'Career & profession'),
  d12('D12', 'Dwadasamsa', 'Parents & lineage'),
  d16('D16', 'Shodasamsa', 'Vehicles & comforts'),
  d20('D20', 'Vimsamsa', 'Spiritual progress'),
  d24('D24', 'Chaturvimsamsa', 'Education & learning'),
  d27('D27', 'Saptavimsamsa', 'Strengths & weaknesses'),
  d30('D30', 'Trimsamsa', 'Misfortunes & evils'),
  d40('D40', 'Khavedamsa', 'Auspicious effects'),
  d45('D45', 'Akshavedamsa', 'General indications'),
  d60('D60', 'Shashtyamsa', 'Past life karma');

  final String code;
  final String name;
  final String description;

  const DivisionalChart(this.code, this.name, this.description);

  String get apiEndpoint => '/chart/${code.toLowerCase()}';
}
