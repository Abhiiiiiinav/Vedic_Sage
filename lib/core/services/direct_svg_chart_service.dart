import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'free_astrology_api_service.dart';

class DirectSvgChartService {
  DirectSvgChartService({
    List<String>? apiKeys,
    http.Client? client,
    String? baseUrl,
  })  : _apiKeys = _resolveApiKeys(apiKeys),
        _client = client ?? http.Client(),
        _baseUrl = (baseUrl ?? _defaultBaseUrl).replaceAll(RegExp(r'/$'), '');

  static const String _defaultBaseUrl = 'https://json.freeastrologyapi.com';
  static const String _storageKeyPrefix = 'astro_svg_chart_';
  static int _rotationIndex = 0;

  static const Map<String, String> chartEndpoints = {
    'd1': 'horoscope-chart-svg-code',
    'd2': 'd2-chart-svg-code',
    'd3': 'd3-chart-svg-code',
    'd4': 'd4-chart-svg-code',
    'd5': 'd5-chart-svg-code',
    'd6': 'd6-chart-svg-code',
    'd7': 'd7-chart-svg-code',
    'd8': 'd8-chart-svg-code',
    'd9': 'navamsa-chart-svg-code',
    'd10': 'd10-chart-svg-code',
    'd11': 'd11-chart-svg-code',
    'd12': 'd12-chart-svg-code',
    'd16': 'd16-chart-svg-code',
    'd20': 'd20-chart-svg-code',
    'd24': 'd24-chart-svg-code',
    'd27': 'd27-chart-svg-code',
    'd30': 'd30-chart-svg-code',
    'd40': 'd40-chart-svg-code',
    'd45': 'd45-chart-svg-code',
    'd60': 'd60-chart-svg-code',
  };

  static const Map<String, String> chartNames = {
    'd1': 'Rasi Chart (Birth Chart)',
    'd2': 'Hora Chart',
    'd3': 'Drekkana Chart',
    'd4': 'Chaturthamsa Chart',
    'd5': 'Panchamsa Chart',
    'd6': 'Shasthamsa Chart',
    'd7': 'Saptamsa Chart',
    'd8': 'Ashtamsa Chart',
    'd9': 'Navamsa Chart',
    'd10': 'Dasamsa Chart',
    'd11': 'Rudramsa Chart',
    'd12': 'Dwadasamsa Chart',
    'd16': 'Shodasamsa Chart',
    'd20': 'Vimsamsa Chart',
    'd24': 'Siddhamsa Chart',
    'd27': 'Nakshatramsa Chart',
    'd30': 'Trimsamsa Chart',
    'd40': 'Khavedamsa Chart',
    'd45': 'Akshavedamsa Chart',
    'd60': 'Shashtyamsa Chart',
  };

  final List<String> _apiKeys;
  final http.Client _client;
  final String _baseUrl;

  Future<Map<String, dynamic>> fetchChartAsJson({
    required String division,
    required SvgChartRequest request,
    bool useStoredCache = true,
    bool persist = true,
  }) async {
    final normalizedDivision = division.toLowerCase();
    final endpoint = chartEndpoints[normalizedDivision];

    if (endpoint == null) {
      return {
        'success': false,
        'error': 'Unknown division: $division',
        'available': chartEndpoints.keys.toList(),
      };
    }

    if (_apiKeys.isEmpty) {
      return {
        'success': false,
        'error': 'No API keys found. Add ASTRO_API_KEY_1/2/3 or ASTRO_API_KEY in .env.',
      };
    }

    final payload = request.toApiPayload();
    final chartId = _buildChartId(normalizedDivision, payload);

    if (useStoredCache) {
      final cached = await loadStoredChart(chartId);
      if (cached != null) {
        return {
          ...cached,
          'cached': true,
        };
      }
    }

    final url = Uri.parse('$_baseUrl/$endpoint');
    String? lastError;
    String? lastDetails;

    final rotatedKeys = _rotatedApiKeys();
    for (var i = 0; i < rotatedKeys.length; i++) {
      try {
        final response = await _client
            .post(
              url,
              headers: {
                'Content-Type': 'application/json',
                'x-api-key': rotatedKeys[i],
              },
              body: jsonEncode(payload),
            )
            .timeout(const Duration(seconds: 30));

        if (response.statusCode == 200) {
          final svg = _extractSvg(response.body);
          if (svg == null) {
            lastError = 'SVG not found in API response';
            lastDetails = _truncate(response.body);
            continue;
          }

          final result = {
            'success': true,
            'chart_id': chartId,
            'chart_type': normalizedDivision.toUpperCase(),
            'chart_name': chartNames[normalizedDivision] ?? normalizedDivision,
            'endpoint': endpoint,
            'svg': svg,
            'birth_details': request.toJson(),
            'fetched_at': DateTime.now().toUtc().toIso8601String(),
            'source': 'freeastrologyapi',
            'cached': false,
          };

          if (persist) {
            await storeChartJson(result);
          }

          return result;
        }

        if (response.statusCode == 429 || response.statusCode == 401 || response.statusCode == 403) {
          lastError = 'API key rejected or rate-limited (${response.statusCode})';
          lastDetails = _truncate(response.body);
          continue;
        }

        lastError = 'API error: ${response.statusCode}';
        lastDetails = _truncate(response.body);
      } on TimeoutException {
        lastError = 'Request timed out';
      } catch (e) {
        lastError = 'Request failed: $e';
      }
    }

    return {
      'success': false,
      'error': lastError ?? 'All API keys failed',
      'details': lastDetails,
      'chart_id': chartId,
      'chart_type': normalizedDivision.toUpperCase(),
    };
  }

  Future<void> storeChartJson(Map<String, dynamic> chartJson) async {
    final chartId = chartJson['chart_id']?.toString();
    if (chartId == null || chartId.isEmpty) {
      throw ArgumentError('chartJson must contain a non-empty chart_id');
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_storageKeyPrefix$chartId', jsonEncode(chartJson));
  }

  Future<Map<String, dynamic>?> loadStoredChart(String chartId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_storageKeyPrefix$chartId');
    if (raw == null || raw.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      if (decoded is Map) {
        return decoded.map((key, value) => MapEntry(key.toString(), value));
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<bool> deleteStoredChart(String chartId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.remove('$_storageKeyPrefix$chartId');
  }

  static List<String> _resolveApiKeys(List<String>? provided) {
    final envListRaw = dotenv.env['ASTRO_API_KEYS'] ?? '';
    final envList = envListRaw
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final candidates = <String>[
      ...?provided,
      ...envList,
      dotenv.env['ASTRO_API_KEY_1'] ?? '',
      dotenv.env['ASTRO_API_KEY_2'] ?? '',
      dotenv.env['ASTRO_API_KEY_3'] ?? '',
      dotenv.env['ASTRO_API_KEY'] ?? '',
      FreeAstrologyApiService.fallbackApiKey,
    ];

    final seen = <String>{};
    final keys = <String>[];
    for (final key in candidates) {
      final trimmed = key.trim();
      if (trimmed.isNotEmpty && seen.add(trimmed)) {
        keys.add(trimmed);
      }
    }
    return keys;
  }

  List<String> _rotatedApiKeys() {
    if (_apiKeys.isEmpty) return const [];
    final normalized = _rotationIndex % _apiKeys.length;
    final start = normalized == 0 ? 0 : normalized;
    _rotationIndex++;

    return List<String>.generate(
      _apiKeys.length,
      (index) => _apiKeys[(start + index) % _apiKeys.length],
    );
  }

  void useNextApiKey() {
    _rotationIndex++;
  }

  String _buildChartId(String division, Map<String, dynamic> payload) {
    final stable = jsonEncode({
      'division': division,
      ...payload,
    });
    return sha256.convert(utf8.encode(stable)).toString().substring(0, 16);
  }

  String? _extractSvg(String rawBody) {
    final directSvg = _sliceSvg(rawBody);
    if (directSvg != null) {
      return directSvg;
    }

    dynamic decoded;
    try {
      decoded = jsonDecode(rawBody);
    } catch (_) {
      return null;
    }

    final svg = _findSvgInNode(decoded);
    return svg == null ? null : _sliceSvg(svg);
  }

  String? _findSvgInNode(dynamic node) {
    if (node == null) return null;

    if (node is String) {
      final sliced = _sliceSvg(node);
      if (sliced != null) {
        return sliced;
      }

      final trimmed = node.trim();
      if ((trimmed.startsWith('{') && trimmed.endsWith('}')) ||
          (trimmed.startsWith('[') && trimmed.endsWith(']'))) {
        try {
          final nested = jsonDecode(trimmed);
          return _findSvgInNode(nested);
        } catch (_) {
          return null;
        }
      }

      return null;
    }

    if (node is List) {
      for (final item in node) {
        final found = _findSvgInNode(item);
        if (found != null) return found;
      }
      return null;
    }

    if (node is Map) {
      for (final value in node.values) {
        final found = _findSvgInNode(value);
        if (found != null) return found;
      }
      return null;
    }

    return null;
  }

  String? _sliceSvg(String text) {
    final start = text.indexOf('<svg');
    if (start < 0) return null;

    final endTag = '</svg>';
    final end = text.lastIndexOf(endTag);
    if (end >= 0 && end + endTag.length > start) {
      return text.substring(start, end + endTag.length).trim();
    }

    return text.substring(start).trim();
  }

  String _truncate(String input, {int maxLength = 600}) {
    if (input.length <= maxLength) return input;
    return '${input.substring(0, maxLength)}...';
  }

  void dispose() => _client.close();
}

class SvgChartRequest {
  const SvgChartRequest({
    required this.year,
    required this.month,
    required this.date,
    required this.hours,
    required this.minutes,
    required this.latitude,
    required this.longitude,
    required this.timezone,
    this.seconds = 0,
    this.observationPoint = 'topocentric',
    this.ayanamsha = 'lahiri',
  });

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

  Map<String, dynamic> toApiPayload() {
    return {
      'year': year,
      'month': month,
      'date': date,
      'hours': hours,
      'minutes': minutes,
      'seconds': seconds,
      'latitude': latitude,
      'longitude': longitude,
      'timezone': timezone,
      'config': {
        'observation_point': observationPoint,
        'ayanamsha': ayanamsha,
      },
    };
  }

  Map<String, dynamic> toJson() {
    return {
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
  }
}
