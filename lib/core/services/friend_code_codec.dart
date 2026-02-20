import 'dart:convert';

import 'package:hive/hive.dart';

import '../database/hive_database_service.dart';
import '../database/hive_boxes.dart';
import '../database/models/hive_models.dart';
import '../models/friend_model.dart';
import 'user_session.dart';

/// Encodes/decodes friend profile data into shareable strings.
///
/// Format:  <8-char hex key>#<base64 payload>
/// Example: A3F7C02E#eyJuIjoiQWJo...
///
/// The hex key is a deterministic hash of the user's name + DOB,
/// displayed prominently for easy verbal sharing. The payload
/// after the `#` carries the full birth data.
class FriendCodeCodec {
  static const _separator = '#';

  // ── Generate ───────────────────────────────────────────────

  /// Generate a shareable code from the current user's birth details.
  /// Tries three sources in order:
  ///   1. In-memory UserSession
  ///   2. Hive primary profile
  ///   3. Hive saved charts (first chart)
  static String? generateMyCode() {
    Map<String, dynamic>? data;

    // ─── Source 1: UserSession (in-memory) ───
    final session = UserSession();
    final details = session.birthDetails;

    if (details != null) {
      data = <String, dynamic>{
        'n': details.name,
        'd': details.birthDateTime.millisecondsSinceEpoch,
        'p': details.cityName,
        'la': details.latitude,
        'lo': details.longitude,
        'tz': details.timezoneOffset,
      };

      // Include chart summary if available
      final chart = session.birthChart;
      if (chart != null) {
        data['asc'] = chart['ascSign'] ?? '';
        final positions = chart['planetPositions'] as Map<String, dynamic>?;
        if (positions != null) {
          final moonData = positions['Moon'] as Map<String, dynamic>?;
          final sunData = positions['Sun'] as Map<String, dynamic>?;
          if (moonData != null) data['moon'] = moonData['sign'] ?? '';
          if (sunData != null) data['sun'] = sunData['sign'] ?? '';
        }
      }
      print('🔑 Friend code: using UserSession');
    }

    // ─── Source 2: Hive primary profile ───
    if (data == null) {
      try {
        final profile = HiveDatabaseService().getPrimaryProfile();
        if (profile != null && profile.birthDateTime != null) {
          data = <String, dynamic>{
            'n': profile.name,
            'd': profile.birthDateTime!.millisecondsSinceEpoch,
            'p': profile.birthPlace ?? 'Unknown',
            'la': profile.latitude ?? 28.6139,
            'lo': profile.longitude ?? 77.2090,
            'tz': profile.timezoneOffset ?? 5.5,
          };
          print('🔑 Friend code: using Hive profile "${profile.name}"');
        } else {
          print('🔑 Friend code: Hive profile is null or has no DOB');
        }
      } catch (e) {
        print('🔑 Friend code: Hive profile error: $e');
      }
    }

    // ─── Source 3: Hive saved charts (first available) ───
    if (data == null) {
      try {
        final chartsBox = Hive.box<SavedChartModel>(HiveBoxes.savedCharts);
        if (chartsBox.isNotEmpty) {
          final chart = chartsBox.values.first;
          data = <String, dynamic>{
            'n': chart.name,
            'd': chart.birthDateTime.millisecondsSinceEpoch,
            'p': chart.birthPlace,
            'la': chart.latitude,
            'lo': chart.longitude,
            'tz': chart.timezoneOffset,
          };
          if (chart.ascendantSign != null) data['asc'] = chart.ascendantSign;
          // Extract Moon/Sun from planet placements
          for (final planet in chart.planetPlacements) {
            if (planet.planetId == 'Moon') data['moon'] = planet.sign;
            if (planet.planetId == 'Sun') data['sun'] = planet.sign;
          }
          print('🔑 Friend code: using saved chart "${chart.name}"');
        } else {
          print('🔑 Friend code: saved_charts box is empty too');
        }
      } catch (e) {
        print('🔑 Friend code: saved charts error: $e');
      }
    }

    if (data == null) {
      print('🔑 Friend code: ALL sources empty — cannot generate');
      return null;
    }

    final jsonStr = jsonEncode(data);
    final payload = base64Encode(utf8.encode(jsonStr));
    final hexKey = _generateHexKey(data);
    return '$hexKey$_separator$payload';
  }

  /// Deterministic 8-char uppercase hex key from name + DOB.
  static String _generateHexKey(Map<String, dynamic> data) {
    final seed = '${data['n']}|${data['d']}';
    int hash = 0x811c9dc5; // FNV-1a offset basis (32-bit)
    for (int i = 0; i < seed.length; i++) {
      hash ^= seed.codeUnitAt(i);
      hash = (hash * 0x01000193) & 0xFFFFFFFF; // FNV prime, keep 32 bits
    }
    return hash.toRadixString(16).toUpperCase().padLeft(8, '0');
  }

  /// Extract just the 8-char hex key from a full code
  static String? extractHexKey(String code) {
    final idx = code.indexOf(_separator);
    if (idx == 8) return code.substring(0, 8);
    return null;
  }

  // ── Decode ─────────────────────────────────────────────────

  /// Decode a friend code into a FriendProfile
  static FriendProfile? decode(String code) {
    try {
      String raw = code.trim();

      // Extract payload after the # separator
      final idx = raw.indexOf(_separator);
      String hexKey;
      String payload;

      if (idx >= 0) {
        hexKey = raw.substring(0, idx);
        payload = raw.substring(idx + 1);
      } else {
        // Legacy: try entire string as base64
        hexKey = '';
        payload = raw;
      }

      final jsonStr = utf8.decode(base64Decode(payload));
      final data = jsonDecode(jsonStr) as Map<String, dynamic>;

      final name = data['n'] as String? ?? 'Unknown';
      final dobMs = data['d'] as int? ?? 0;
      final place = data['p'] as String? ?? 'Unknown';
      final lat = (data['la'] as num?)?.toDouble() ?? 0.0;
      final lon = (data['lo'] as num?)?.toDouble() ?? 0.0;
      final tz = (data['tz'] as num?)?.toDouble() ?? 5.5;
      final asc = data['asc'] as String?;
      final moon = data['moon'] as String?;
      final sun = data['sun'] as String?;

      final id = 'friend_${DateTime.now().millisecondsSinceEpoch}';

      return FriendProfile(
        id: id,
        name: name,
        dateOfBirth: DateTime.fromMillisecondsSinceEpoch(dobMs),
        placeOfBirth: place,
        latitude: lat,
        longitude: lon,
        timezoneOffset: tz,
        relationship: RelationshipType.friend,
        addedAt: DateTime.now(),
        ascendantSign: asc,
        moonSign: moon,
        sunSign: sun,
        friendCode: hexKey.isNotEmpty ? hexKey : null,
      );
    } catch (e) {
      return null;
    }
  }

  // ── Validation ─────────────────────────────────────────────

  /// Validate if a string looks like a valid friend code.
  /// Format: 8 hex chars + # + base64 payload (20+ chars)
  static bool isValidCode(String code) {
    final raw = code.trim();
    if (raw.isEmpty) return false;
    final idx = raw.indexOf(_separator);
    if (idx != 8) return false;
    final payload = raw.substring(idx + 1);
    return payload.length >= 20;
  }

  // ── Share ──────────────────────────────────────────────────

  /// Format a human-friendly share message
  static String formatShareMessage(String code) {
    final session = UserSession();
    final name = session.birthDetails?.name ?? 'Someone';
    final hexKey = extractHexKey(code) ?? code.substring(0, 8);
    return '🔮 $name wants to connect on AstroLearn!\n\n'
        'Friend Key: $hexKey\n\n'
        'Paste this full code in the app:\n$code\n\n'
        '✨ Compare charts, Dashas & cosmic compatibility!';
  }
}
