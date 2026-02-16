import 'dart:convert';
import 'package:http/http.dart' as http;

/// Service for communicating with the Python Flask backend
/// which proxies requests to the Free Astrology API for SVG chart generation
class ChartApiService {
  // Base URL for the Flask API
  // Use 10.0.2.2 for Android Emulator
  // Use localhost for Web/iOS Simulator
  // Use your machine's IP for physical devices
  static const String _androidEmulatorUrl = 'http://10.0.2.2:5000';
  static const String _localHostUrl = 'http://localhost:5000';
  static const String _webUrl = 'http://127.0.0.1:5000';
  static const String _physicalDeviceUrl =
      'http://10.245.213.212:5000'; // PC's WiFi IP

  final String baseUrl;
  final http.Client _client;

  ChartApiService({
    String? customBaseUrl,
    http.Client? client,
  })  : baseUrl = customBaseUrl ?? _getDefaultBaseUrl(),
        _client = client ?? http.Client();

  /// Determine the appropriate base URL based on platform
  static String _getDefaultBaseUrl() {
    // For physical Android devices, use PC's IP address
    // For web, use localhost
    // For Android emulator, use 10.0.2.2
    // For iOS simulator, use localhost
    return _physicalDeviceUrl; // Changed to use PC's IP for phone
  }

  /// Check if the backend is running
  Future<bool> healthCheck() async {
    try {
      final response = await _client
          .get(
            Uri.parse('$baseUrl/'),
          )
          .timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      print('ChartApiService: Health check failed - $e');
      return false;
    }
  }

  /// Generate D1 Rasi Chart (Birth Chart) SVG using GET endpoint
  /// This is useful for simpler use cases with query parameters
  Future<ChartResponse> getKundaliChartViaGet(BirthDetails birthDetails,
      {String division = 'd1'}) async {
    try {
      final uri = Uri.parse('$baseUrl/kundali').replace(queryParameters: {
        'year': birthDetails.year.toString(),
        'month': birthDetails.month.toString(),
        'date': birthDetails.date.toString(),
        'hours': birthDetails.hours.toString(),
        'minutes': birthDetails.minutes.toString(),
        'seconds': birthDetails.seconds.toString(),
        'latitude': birthDetails.latitude.toString(),
        'longitude': birthDetails.longitude.toString(),
        'timezone': birthDetails.timezone.toString(),
        'ayanamsha': birthDetails.ayanamsha,
        'division': division,
      });

      final response =
          await _client.get(uri).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ChartResponse(
          success: data['success'] ?? false,
          svg: data['svg'],
          chartType: data['chart_type'],
          name: data['chart_name'],
        );
      } else {
        final error = jsonDecode(response.body);
        return ChartResponse(
          success: false,
          error: error['error'] ?? 'Unknown error',
        );
      }
    } catch (e) {
      return ChartResponse(
        success: false,
        error: 'Failed to connect to chart server: $e',
      );
    }
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
      print('📡 Fetching batch charts: ${charts.join(", ")}');

      final response = await _client
          .post(
            Uri.parse('$baseUrl/charts/batch'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              ...birthDetails.toJson(),
              'charts': charts,
            }),
          )
          .timeout(const Duration(seconds: 90));

      print('📥 Batch response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Parse charts from response
        Map<String, ChartData> parsedCharts = {};
        if (data['charts'] != null) {
          (data['charts'] as Map<String, dynamic>).forEach((key, value) {
            parsedCharts[key] = ChartData(
              svg: value['svg'],
              name: value['name'],
            );
          });
        }

        print('✅ Batch received: ${parsedCharts.length} charts');

        return BatchChartResponse(
          success: data['success'] ?? false,
          charts: parsedCharts,
          count: data['count'] ?? 0,
          errors: data['errors'] != null
              ? Map<String, String>.from(data['errors'])
              : null,
        );
      } else {
        print('❌ Batch error: ${response.body}');
        final error = jsonDecode(response.body);
        return BatchChartResponse(
          success: false,
          error: error['error'] ?? 'Unknown error',
        );
      }
    } catch (e) {
      print('❌ Batch network error: $e');
      return BatchChartResponse(
        success: false,
        error: 'Failed to connect to chart server: $e',
      );
    }
  }

  /// Common method to fetch a chart
  Future<ChartResponse> _fetchChart(
    String endpoint,
    BirthDetails birthDetails,
  ) async {
    try {
      print('📡 Fetching chart from: $baseUrl$endpoint');

      final response = await _client
          .post(
            Uri.parse('$baseUrl$endpoint'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(birthDetails.toJson()),
          )
          .timeout(const Duration(seconds: 30));

      print('📥 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final svgContent = data['svg'] as String?;

        print('✅ Chart received: ${svgContent?.length ?? 0} chars');

        return ChartResponse(
          success: data['success'] ?? true,
          svg: svgContent,
          chartType: data['chart_type'],
          name: data['chart_name'] ?? data['name'],
        );
      } else {
        print('❌ Error response: ${response.body}');
        final error = jsonDecode(response.body);
        return ChartResponse(
          success: false,
          error: error['error'] ?? 'Unknown error',
        );
      }
    } catch (e) {
      print('❌ Network error: $e');
      return ChartResponse(
        success: false,
        error: 'Failed to connect to chart server: $e',
      );
    }
  }

  /// Fetch details about planetary positions
  Future<Map<String, dynamic>> getPlanetaryData(
      BirthDetails birthDetails) async {
    try {
      final response = await _client
          .post(
            Uri.parse('$baseUrl/planets'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(birthDetails.toJson()),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['output'] != null) {
          // Flatten the list of maps [{"0": {...}}, {"1": {...}}] into a single map
          final outputList = data['output'] as List;
          final Map<String, dynamic> planets = {};

          for (var item in outputList) {
            if (item is Map) {
              item.forEach((key, value) {
                if (value is Map && value.containsKey('name')) {
                  planets[value['name']] = value;
                } else if (key == 'ayanamsa') {
                  planets['ayanamsa'] = value;
                }
              });
            }
          }
          return planets;
        }
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
      final body = {
        'year': year,
        'month': month,
        'date': date,
        'hours': hours,
        'minutes': minutes,
        'seconds': seconds,
        'latitude': latitude,
        'longitude': longitude,
        'timezone': timezone,
        'ayanamsha': ayanamsha,
        if (divisions != null) 'divisions': divisions,
      };

      final response = await _client.post(
        Uri.parse('$baseUrl/kundali/full'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          print('✅ Full kundali fetched: ${data['count']} divisions');
          return data;
        }
      }

      print('❌ Full kundali fetch failed: ${response.statusCode}');
      return null;
    } catch (e) {
      print('❌ Error fetching full kundali: $e');
      return null;
    }
  }

  /// Dispose of HTTP client
  void dispose() {
    _client.close();
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
