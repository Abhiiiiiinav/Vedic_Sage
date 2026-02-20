import 'dart:convert';
import 'package:http/http.dart' as http;

/// Service to interact with Free Astrology API
/// https://freeastrologyapi.com
class FreeAstrologyApiService {
  static const String _baseUrl = "https://json.freeastrologyapi.com";
  static const String _apiKey = "O6sSA5hKu8atz6KDG3xQt1rlTLkUzUhJ6x1wwtLJ";
  static String get fallbackApiKey => _apiKey;

  /// Fetch birth chart planetary positions (planets endpoint)
  /// 
  /// [config] - Optional chart configuration (ayanamsha + observation point)
  ///            Defaults to Lahiri + Topocentric if not provided
  static Future<Map<String, dynamic>> fetchBirthChart({
    required int year,
    required int month,
    required int date,
    required int hours,
    required int minutes,
    required double latitude,
    required double longitude,
    required double timezone,
    Map<String, String>? config, // ✅ Optional config parameter
  }) async {
    // ✅ VALIDATE ALL PARAMETERS BEFORE API CALL
    if (year < 1900 || year > 2100) {
      throw Exception("Invalid year: $year (must be between 1900-2100)");
    }
    
    if (month < 1 || month > 12) {
      throw Exception("Invalid month: $month (must be between 1-12)");
    }
    
    if (date < 1 || date > 31) {
      throw Exception("Invalid date: $date (must be between 1-31)");
    }
    
    if (hours < 0 || hours > 23) {
      throw Exception("Invalid hours: $hours (must be between 0-23)");
    }
    
    if (minutes < 0 || minutes > 59) {
      throw Exception("Invalid minutes: $minutes (must be between 0-59)");
    }
    
    if (latitude < -90 || latitude > 90) {
      throw Exception("Invalid latitude: $latitude (must be between -90 and 90)");
    }
    
    if (longitude < -180 || longitude > 180) {
      throw Exception("Invalid longitude: $longitude (must be between -180 and 180)");
    }
    
    // Default config if not provided
    final apiConfig = config ?? {
      "observation_point": "geocentric",  // ✅ Changed to heliocentric
      "ayanamsha": "lahiri"
    };
    
    print("🌐 API REQUEST:");
    print("   Year: $year, Month: $month, Date: $date");
    print("   Time: $hours:$minutes");
    print("   Location: $latitude, $longitude");
    print("   Timezone: $timezone");
    print("   Ayanamsha: ${apiConfig['ayanamsha']}");
    print("   Observation: ${apiConfig['observation_point']}");
    
    final url = Uri.parse("$_baseUrl/planets");

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "x-api-key": _apiKey,
      },
      body: jsonEncode({
        "year": year,
        "month": month,
        "date": date,
        "hours": hours,
        "minutes": minutes,
        "seconds": 0,
        "latitude": latitude,
        "longitude": longitude,
        "timezone": timezone,
        "config": apiConfig, // ✅ Use provided or default config
      }),
    );

    if (response.statusCode != 200) {
      print("❌ API ERROR: ${response.statusCode}");
      print("Response: ${response.body}");
      throw Exception(
          "Failed to fetch birth chart: ${response.statusCode} - ${response.body}");
    }
    
    print("✅ API Response received (${response.body.length} bytes)");

    return jsonDecode(response.body);
  }

  /// Fetch horoscope chart as SVG code (D1/Rasi)
  /// Returns SVG string that can be displayed with flutter_svg
  static Future<String?> fetchHoroscopeChartSvg({
    required int year,
    required int month,
    required int date,
    required int hours,
    required int minutes,
    required double latitude,
    required double longitude,
    required double timezone,
    int seconds = 0,
  }) async {
    final url = Uri.parse("$_baseUrl/horoscope-chart-svg-code");

    print("🎨 Fetching horoscope SVG chart...");
    
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "x-api-key": _apiKey,
      },
      body: jsonEncode({
        "year": year,
        "month": month,
        "date": date,
        "hours": hours,
        "minutes": minutes,
        "seconds": seconds,
        "latitude": latitude,
        "longitude": longitude,
        "timezone": timezone,
        "observation_point": "geocentric",
      }),
    );

    if (response.statusCode != 200) {
      print("❌ SVG Chart API Error: ${response.statusCode}");
      print("Response: ${response.body}");
      throw Exception("Failed to fetch SVG chart: ${response.statusCode}");
    }

    final data = jsonDecode(response.body);
    // API returns SVG code in 'output' field
    final svgCode = data["output"] ?? data["svg"] ?? data["chart_svg"];
    
    if (svgCode != null && svgCode.toString().contains("<svg")) {
      print("✅ SVG chart received (${svgCode.toString().length} chars)");
      return svgCode.toString();
    } else {
      print("⚠️ No valid SVG code in response: $data");
      return null;
    }
  }

  /// Fetch divisional chart as SVG code (D3, D5, D9, D10, D12, D16, etc.)
  /// [chartType] - Type of divisional chart: "d3", "d5", "d9", "d10", "d12", "d16"
  static Future<String?> fetchDivisionalChartSvg({
    required String chartType,
    required int year,
    required int month,
    required int date,
    required int hours,
    required int minutes,
    required double latitude,
    required double longitude,
    required double timezone,
    int seconds = 0,
  }) async {
    // Endpoint format: d3-chart-svg-code, d5-chart-svg-code, etc.
    final endpoint = "${chartType.toLowerCase()}-chart-svg-code";
    final url = Uri.parse("$_baseUrl/$endpoint");

    print("🎨 Fetching $chartType SVG chart from $endpoint...");
    
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "x-api-key": _apiKey,
      },
      body: jsonEncode({
        "year": year,
        "month": month,
        "date": date,
        "hours": hours,
        "minutes": minutes,
        "seconds": seconds,
        "latitude": latitude,
        "longitude": longitude,
        "timezone": timezone,
        "observation_point": "geocentric",
      }),
    );

    if (response.statusCode != 200) {
      print("❌ $chartType SVG Chart API Error: ${response.statusCode}");
      print("Response: ${response.body}");
      throw Exception("Failed to fetch $chartType SVG chart: ${response.statusCode}");
    }

    final data = jsonDecode(response.body);
    // API returns SVG code in 'output' field
    final svgCode = data["output"] ?? data["svg"] ?? data["chart_svg"];
    
    if (svgCode != null && svgCode.toString().contains("<svg")) {
      print("✅ $chartType SVG chart received (${svgCode.toString().length} chars)");
      return svgCode.toString();
    } else {
      print("⚠️ No valid SVG code in $chartType response: $data");
      return null;
    }
  }

  /// Fetch all charts as SVG code
  /// Returns a map with keys: 'rasi', 'd3', 'd5', 'd9', 'd10', 'd12', 'd16'
  static Future<Map<String, String>> fetchAllChartSvgs({
    required int year,
    required int month,
    required int date,
    required int hours,
    required int minutes,
    required double latitude,
    required double longitude,
    required double timezone,
  }) async {
    print("📊 Fetching all chart SVGs (optimized parallel loading)...");
    print("   Date: $year-$month-$date $hours:$minutes");
    print("   Location: $latitude, $longitude");
    print("   Timezone: $timezone");
    
    final Map<String, String> charts = {};
    
    // Helper function to fetch a single chart
    Future<MapEntry<String, String>?> fetchChart(String chartType) async {
      try {
        String? svg;
        if (chartType == 'rasi') {
          svg = await fetchHoroscopeChartSvg(
            year: year, month: month, date: date,
            hours: hours, minutes: minutes,
            latitude: latitude, longitude: longitude, timezone: timezone,
          );
        } else {
          svg = await fetchDivisionalChartSvg(
            chartType: chartType,
            year: year, month: month, date: date,
            hours: hours, minutes: minutes,
            latitude: latitude, longitude: longitude, timezone: timezone,
          );
        }
        if (svg != null) return MapEntry(chartType, svg);
      } catch (e) {
        print("❌ Error fetching $chartType SVG: $e");
      }
      return null;
    }
    
    // Load charts in parallel batches of 2 to avoid rate limiting
    final allCharts = ['rasi', 'd3', 'd5', 'd9', 'd10', 'd12', 'd16'];
    
    // Process in batches of 2
    for (int i = 0; i < allCharts.length; i += 2) {
      final batch = allCharts.skip(i).take(2).toList();
      
      // Fetch batch in parallel
      final results = await Future.wait(
        batch.map((chartType) => fetchChart(chartType)),
      );
      
      // Add successful results
      for (final result in results) {
        if (result != null) charts[result.key] = result.value;
      }
      
      // Small delay between batches to avoid rate limiting (only if more batches remain)
      if (i + 2 < allCharts.length) {
        await Future.delayed(const Duration(milliseconds: 300));
      }
    }
    
    print("📊 Total SVG charts fetched: ${charts.length} (optimized)");
    return charts;
  }

  /// Fetch Vimshottari Mahadasha timeline
  static Future<Map<String, dynamic>> fetchVimsottariDasa({
    required int year,
    required int month,
    required int date,
    required int hours,
    required int minutes,
    required double latitude,
    required double longitude,
    required double timezone,
  }) async {
    final url = Uri.parse("$_baseUrl/vimsottari/maha-dasas");

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "x-api-key": _apiKey,
      },
      body: jsonEncode({
        "year": year,
        "month": month,
        "date": date,
        "hours": hours,
        "minutes": minutes,
        "seconds": 0,
        "latitude": latitude,
        "longitude": longitude,
        "timezone": timezone,
        "config": {
          "observation_point": "topocentric",
          "ayanamsha": "lahiri"
        }
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
          "Failed to fetch dasa: ${response.statusCode} - ${response.body}");
    }

    return jsonDecode(response.body);
  }

  /// Fetch all chart URLs for a given birth data
  /// Returns a map with keys: 'rasi', 'd5', 'd9', 'd10', 'd12', etc.
  static Future<Map<String, String>> fetchAllChartUrls({
    required int year,
    required int month,
    required int date,
    required int hours,
    required int minutes,
    required double latitude,
    required double longitude,
    double timezone = 0.0, // ✅ Added timezone parameter
  }) async {
    print("📊 Fetching all chart URLs...");
    print("   Date: $year-$month-$date $hours:$minutes");
    print("   Location: $latitude, $longitude");
    print("   Timezone: $timezone");
    
    final Map<String, String> charts = {};
    
    // Fetch main horoscope chart (Rasi/D1)
    try {
      print("🌟 Fetching Rasi chart...");
      charts['rasi'] = await fetchHoroscopeChartUrl(
        year: year,
        month: month,
        date: date,
        hours: hours,
        minutes: minutes,
        latitude: latitude,
        longitude: longitude,
        timezone: timezone, // ✅ Pass timezone
      );
      print("✅ Rasi chart URL: ${charts['rasi']}");
    } catch (e) {
      print("❌ Error fetching Rasi chart: $e");
    }
    
    // Fetch divisional charts
    final divisionalCharts = ['d5', 'd9', 'd10', 'd12', 'd16'];
    for (final chartType in divisionalCharts) {
      try {
        print("📈 Fetching $chartType chart...");
        charts[chartType] = await fetchDivisionalChartUrl(
          chartType: chartType,
          year: year,
          month: month,
          date: date,
          hours: hours,
          minutes: minutes,
          latitude: latitude,
          longitude: longitude,
          timezone: timezone, // ✅ Pass timezone
        );
        print("✅ $chartType chart URL: ${charts[chartType]}");
      } catch (e) {
        print("❌ Error fetching $chartType chart: $e");
      }
    }
    
    print("📊 Total charts fetched: ${charts.length}");
    return charts;
  }


  /// Fetch horoscope chart image URL
  /// Returns a URL to the chart image that can be displayed directly
  /// 
  /// API Documentation confirms timezone parameter is supported
  static Future<String> fetchHoroscopeChartUrl({
    required int year,
    required int month,
    required int date,
    required int hours,
    required int minutes,
    required double latitude,
    required double longitude,
    double timezone = 5.5, // ✅ Default to IST, should be passed explicitly
    int seconds = 0,
  }) async {
    final url = Uri.parse("$_baseUrl/horoscope-chart-url");

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "x-api-key": _apiKey,
      },
      body: jsonEncode({
        "year": year,
        "month": month,
        "date": date,
        "hours": hours,
        "minutes": minutes,
        "seconds": seconds,
        "latitude": latitude,
        "longitude": longitude,
        "timezone": timezone, // ✅ Timezone IS required per API docs
      }),
    );

    if (response.statusCode != 200) {
      print("❌ Chart URL API Error: ${response.statusCode}");
      print("Response: ${response.body}");
      throw Exception(
          "Failed to fetch chart URL: ${response.statusCode} - ${response.body}");
    }

    final data = jsonDecode(response.body);
    // API returns URL in 'output' field, not 'chart_url'
    final chartUrl = data["output"] ?? data["chart_url"] ?? data["url"] ?? "";
    
    if (chartUrl.isEmpty) {
      print("⚠️ WARNING: API returned empty chart URL");
      print("Response data: $data");
    } else {
      print("✅ Chart URL: $chartUrl");
    }
    
    return chartUrl;
  }

  /// Fetch divisional chart URL (D5, D9, D10, D12, D16, etc.)
  /// [chartType] - Type of divisional chart: "d5", "d9", "d10", "d12", "d16"
  /// 
  /// API Documentation confirms timezone parameter is supported
  static Future<String> fetchDivisionalChartUrl({
    required String chartType,
    required int year,
    required int month,
    required int date,
    required int hours,
    required int minutes,
    required double latitude,
    required double longitude,
    double timezone = 5.5, // ✅ Default to IST, should be passed explicitly
    int seconds = 0,
  }) async {
    // Map chart type to endpoint
    final endpoint = switch (chartType.toLowerCase()) {
      "d5" || "panchamsa" => "d5-chart-url",
      "d9" || "navamsa" => "navamsa-chart-url",
      "d10" || "dasamsa" => "d10-chart-url",
      "d12" || "dvadasamsa" => "d12-chart-url",
      "d16" || "shodasamsa" => "d16-chart-url",
      _ => "$chartType-chart-url",
    };

    final url = Uri.parse("$_baseUrl/$endpoint");

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "x-api-key": _apiKey,
      },
      body: jsonEncode({
        "year": year,
        "month": month,
        "date": date,
        "hours": hours,
        "minutes": minutes,
        "seconds": seconds,
        "latitude": latitude,
        "longitude": longitude,
        "timezone": timezone, // ✅ Timezone IS required per API docs
      }),
    );

    if (response.statusCode != 200) {
      print("❌ $chartType Chart URL API Error: ${response.statusCode}");
      print("Response: ${response.body}");
      throw Exception(
          "Failed to fetch $chartType chart URL: ${response.statusCode} - ${response.body}");
    }

    final data = jsonDecode(response.body);
    // API returns URL in 'output' field, not 'chart_url'
    final chartUrl = data["output"] ?? data["chart_url"] ?? data["url"] ?? "";
    
    if (chartUrl.isEmpty) {
      print("⚠️ WARNING: API returned empty $chartType chart URL");
      print("Response data: $data");
    } else {
      print("✅ $chartType Chart URL: $chartUrl");
    }
    
    return chartUrl;
  }
}
