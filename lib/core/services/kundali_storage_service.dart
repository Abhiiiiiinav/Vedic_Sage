import 'dart:convert';
import '../database/hive_database_service.dart';
import '../database/models/kundali_record_model.dart';
import '../astro/darakaraka_engine.dart';
import 'chart_api_service.dart';
import 'svg_chart_parser.dart';

/// Orchestration service: fetch → parse → calculate karakas → store in Hive
///
/// Usage:
/// ```dart
/// final service = KundaliStorageService();
/// final record = await service.fetchAndStore(
///   name: 'Test',
///   dateOfBirth: DateTime(2003, 11, 22, 13, 30),
///   placeOfBirth: 'Goa, India',
///   latitude: 14.82,
///   longitude: 74.14,
///   timezoneOffset: 5.5,
/// );
/// print(record.planetNakshatras); // {Sun: Jyeshtha, Moon: Rohini, ...}
/// ```
class KundaliStorageService {
  final ChartApiService _chartApi;
  final HiveDatabaseService _db;

  KundaliStorageService({
    ChartApiService? chartApi,
    HiveDatabaseService? db,
  })  : _chartApi = chartApi ?? ChartApiService(),
        _db = db ?? HiveDatabaseService();

  /// Fetch full kundali data from backend, calculate karakas, and store in Hive
  ///
  /// [divisions] - List of divisions to fetch (e.g. ['d1', 'd9', 'd10']).
  ///               If null, fetches all available divisions.
  Future<KundaliRecordModel> fetchAndStore({
    required String name,
    required DateTime dateOfBirth,
    required String placeOfBirth,
    required double latitude,
    required double longitude,
    double timezoneOffset = 5.5,
    List<String>? divisions,
  }) async {
    print('📿 Fetching full kundali for: $name');

    // 1. Call the /kundali/full endpoint
    final response = await _chartApi.fetchFullKundali(
      year: dateOfBirth.year,
      month: dateOfBirth.month,
      date: dateOfBirth.day,
      hours: dateOfBirth.hour,
      minutes: dateOfBirth.minute,
      seconds: dateOfBirth.second,
      latitude: latitude,
      longitude: longitude,
      timezone: timezoneOffset,
      divisions: divisions,
    );

    if (response == null || response['success'] != true) {
      throw Exception('Failed to fetch kundali data: ${response?['errors']}');
    }

    // 2. Parse the response
    final divisionsData = response['divisions'] as Map<String, dynamic>? ?? {};
    final d1Planets = response['d1_planets'] as Map<String, dynamic>? ?? {};
    final nakshatrasData =
        response['nakshatras'] as Map<String, dynamic>? ?? {};

    // 3. Extract ascendants per division
    final ascendants = <String, int>{};
    for (final entry in divisionsData.entries) {
      final divData = entry.value as Map<String, dynamic>;
      ascendants[entry.key] = (divData['ascendant_sign'] as num?)?.toInt() ?? 0;
    }

    // 4. Extract planet nakshatras, padas, lords
    final planetNakshatras = <String, String>{};
    final planetNakshatraPadas = <String, int>{};
    final planetNakshatraLords = <String, String>{};

    for (final entry in nakshatrasData.entries) {
      final nakData = entry.value as Map<String, dynamic>;
      planetNakshatras[entry.key] = nakData['nakshatra']?.toString() ?? '';
      planetNakshatraPadas[entry.key] = (nakData['pada'] as num?)?.toInt() ?? 0;
      planetNakshatraLords[entry.key] = nakData['lord']?.toString() ?? '';
    }

    // 5. Extract D1 planet degrees and retrogrades
    final planetDegrees = <String, double>{};
    final planetRetrogrades = <String, bool>{};

    for (final entry in d1Planets.entries) {
      final planetData = entry.value as Map<String, dynamic>;
      planetDegrees[entry.key] =
          (planetData['fullDegree'] as num?)?.toDouble() ?? 0.0;
      planetRetrogrades[entry.key] = planetData['isRetro'] as bool? ?? false;
    }

    // 6. Build per-division planet signs
    final planetSignsMap = <String, Map<String, int>>{};
    for (final entry in divisionsData.entries) {
      final divData = entry.value as Map<String, dynamic>;
      final signs = divData['planet_signs'] as Map<String, dynamic>? ?? {};
      planetSignsMap[entry.key] = signs.map(
        (k, v) => MapEntry(k, (v as num).toInt()),
      );
    }

    // 7. Calculate Karakas using DarakarakaEngine
    Map<String, String> karakas = {};
    try {
      final chartData = {
        'planetDegrees': planetDegrees,
        'ascDegree': planetDegrees['Ascendant'] ?? 0.0,
      };
      final jaiminiKarakas = DarakarakaEngine.calculateCharakarakas(
        chartData: chartData,
      );
      for (final karaka in jaiminiKarakas) {
        karakas[karaka.karakaName] = karaka.planet;
      }
      print('🔮 Calculated ${karakas.length} Jaimini Karakas');
    } catch (e) {
      print('⚠️ Karaka calculation failed: $e');
    }

    // 8. Create and store the kundali record
    final record = await _db.createKundaliRecord(
      name: name,
      dateOfBirth: dateOfBirth,
      placeOfBirth: placeOfBirth,
      latitude: latitude,
      longitude: longitude,
      timezoneOffset: timezoneOffset,
      ascendants: ascendants,
      planetNakshatras: planetNakshatras,
      planetNakshatraPadas: planetNakshatraPadas,
      planetNakshatraLords: planetNakshatraLords,
      planetSignsJson: jsonEncode(planetSignsMap),
      planetDegrees: planetDegrees,
      planetRetrogrades: planetRetrogrades,
      karakas: karakas,
    );

    print('✅ Kundali record stored: ${record.id}');
    print('   Divisions: ${ascendants.length}');
    print('   Planets: ${planetDegrees.length}');
    print('   Nakshatras: ${planetNakshatras.length}');
    print('   Karakas: ${karakas.length}');

    return record;
  }

  /// Get a stored kundali record by ID
  KundaliRecordModel? getRecord(String id) => _db.getKundaliRecord(id);

  /// Get all stored kundali records
  List<KundaliRecordModel> getAllRecords() => _db.getAllKundaliRecords();

  /// Search records by name
  List<KundaliRecordModel> searchByName(String query) =>
      _db.searchKundaliByName(query);

  /// Delete a record
  Future<void> deleteRecord(String id) => _db.deleteKundaliRecord(id);

  /// Client-side alternative: extract positions from SVGs locally.
  ///
  /// Use this when:
  /// - Backend only returns raw SVGs (no pre-extracted positions)
  /// - Backend is unavailable and you have cached SVGs
  /// - Testing without a running backend
  ///
  /// [svgsByDivision]: Map of division key → SVG string
  /// [d1PlanetDegrees]: Full degrees for D1 planets (from API /planets)
  /// [d1PlanetRetrogrades]: Retrograde status for D1 planets
  Future<KundaliRecordModel> fetchAndStoreLocal({
    required String name,
    required DateTime dateOfBirth,
    required String placeOfBirth,
    required double latitude,
    required double longitude,
    double timezoneOffset = 5.5,
    required Map<String, String> svgsByDivision,
    required Map<String, double> d1PlanetDegrees,
    Map<String, bool>? d1PlanetRetrogrades,
  }) async {
    print('📿 Local extraction for: $name');

    // 1. Client-side SVG extraction
    final kundaliData = SvgChartParser.buildKundaliData(
      svgsByDivision: svgsByDivision,
      d1PlanetDegrees: d1PlanetDegrees,
    );

    final ascendants = kundaliData['ascendants'] as Map<String, int>;
    final planetSignsMap =
        kundaliData['planetSigns'] as Map<String, Map<String, int>>;
    final planetNakshatras =
        kundaliData['planetNakshatras'] as Map<String, String>;
    final planetNakshatraPadas =
        kundaliData['planetNakshatraPadas'] as Map<String, int>;
    final planetNakshatraLords =
        kundaliData['planetNakshatraLords'] as Map<String, String>;

    // 2. Calculate Karakas
    Map<String, String> karakas = {};
    try {
      final jaiminiKarakas = DarakarakaEngine.calculateCharakarakasFromDegrees(
        planetDegrees: d1PlanetDegrees,
        ascendantDegree: d1PlanetDegrees['Ascendant'] ?? 0.0,
      );
      for (final karaka in jaiminiKarakas) {
        karakas[karaka.karakaName] = karaka.planet;
      }
      print('🔮 Calculated ${karakas.length} Jaimini Karakas (local)');
    } catch (e) {
      print('⚠️ Karaka calculation failed: $e');
    }

    // 3. Store in Hive
    final record = await _db.createKundaliRecord(
      name: name,
      dateOfBirth: dateOfBirth,
      placeOfBirth: placeOfBirth,
      latitude: latitude,
      longitude: longitude,
      timezoneOffset: timezoneOffset,
      ascendants: ascendants,
      planetNakshatras: planetNakshatras,
      planetNakshatraPadas: planetNakshatraPadas,
      planetNakshatraLords: planetNakshatraLords,
      planetSignsJson: jsonEncode(planetSignsMap),
      planetDegrees: d1PlanetDegrees,
      planetRetrogrades: d1PlanetRetrogrades ?? {},
      karakas: karakas,
    );

    print('✅ Kundali record stored (local): ${record.id}');
    print('   Divisions: ${ascendants.length}');
    print('   Planets: ${d1PlanetDegrees.length}');
    print('   Nakshatras: ${planetNakshatras.length}');

    return record;
  }

  /// Recalculate karakas for an existing record and update it
  Future<KundaliRecordModel?> recalculateKarakas(String recordId) async {
    final record = _db.getKundaliRecord(recordId);
    if (record == null) return null;

    final chartData = {
      'planetDegrees': record.planetDegrees,
      'ascDegree': record.planetDegrees['Ascendant'] ?? 0.0,
    };
    final jaiminiKarakas = DarakarakaEngine.calculateCharakarakas(
      chartData: chartData,
    );

    final newKarakas = <String, String>{};
    for (final karaka in jaiminiKarakas) {
      newKarakas[karaka.karakaName] = karaka.planet;
    }

    final updated = record.copyWith(karakas: newKarakas);
    await _db.updateKundaliRecord(updated);
    return _db.getKundaliRecord(recordId);
  }
}
