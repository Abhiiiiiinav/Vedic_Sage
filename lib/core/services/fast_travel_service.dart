/// Fast Travel Service
///
/// Tracks daily fast-travel usage and enforces rules:
///   - 3 free travels per day
///   - Central Land is always free
///   - Bonus travels from streaks (via GamificationService)
///   - Day rollover resets

import 'package:shared_preferences/shared_preferences.dart';
import '../models/realm_models.dart';
import 'gamification_service.dart';

class FastTravelService {
  static final FastTravelService _instance = FastTravelService._();
  factory FastTravelService() => _instance;
  FastTravelService._();

  SharedPreferences? _prefs;

  static const _keyTravelsUsed = 'fast_travel_used_today';
  static const _keyTravelDate = 'fast_travel_date';
  static const _keyCurrentRealm = 'fast_travel_current_realm';
  static const int _baseFreeTravel = 3;

  /// Initialize — call once at app start
  Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
    _checkDayRollover();
  }

  // ── State ──

  int get travelsUsedToday => _prefs?.getInt(_keyTravelsUsed) ?? 0;

  /// Max free travels = base (3) + streak bonus
  int get maxFreeTravels {
    final streakBonus = _getStreakBonus();
    return _baseFreeTravel + streakBonus;
  }

  int get travelsRemaining => (maxFreeTravels - travelsUsedToday).clamp(0, 99);

  /// Current realm the user is in
  RealmType get currentRealm {
    final name = _prefs?.getString(_keyCurrentRealm);
    if (name == null) return RealmType.central;
    for (final r in RealmType.values) {
      if (r.name == name) return r;
    }
    return RealmType.central;
  }

  // ── Travel Logic ──

  /// Check if the user can travel to a destination
  bool canTravel(RealmType destination) {
    // Central Land is always free
    if (destination == RealmType.central) return true;
    // Already in this realm
    if (destination == currentRealm) return false;
    // Check remaining travels
    return travelsRemaining > 0;
  }

  /// Record a travel event
  Future<TravelResult> recordTravel(RealmType destination) async {
    if (destination == currentRealm) {
      return TravelResult(
        success: false,
        message: 'You are already in ${destination.label}',
        travelsRemaining: travelsRemaining,
      );
    }

    final isFree = destination == RealmType.central;

    if (!isFree && travelsRemaining <= 0) {
      return TravelResult(
        success: false,
        message: 'No travels remaining today! Visit Central Land for free, '
            'or extend your streak for bonus travels.',
        travelsRemaining: 0,
      );
    }

    // Deduct a travel unless it's free
    if (!isFree) {
      await _prefs?.setInt(_keyTravelsUsed, travelsUsedToday + 1);
    }

    // Update current realm
    await _prefs?.setString(_keyCurrentRealm, destination.name);
    await _prefs?.setString(_keyTravelDate, _todayString());

    final remaining = travelsRemaining;
    return TravelResult(
      success: true,
      message: _travelMessage(destination),
      travelsRemaining: remaining,
    );
  }

  // ── Streak Bonus ──

  int _getStreakBonus() {
    try {
      final streak = GamificationService().currentStreak;
      if (streak >= 30) return 3;
      if (streak >= 14) return 2;
      if (streak >= 7) return 1;
    } catch (_) {
      // GamificationService not initialized
    }
    return 0;
  }

  // ── Day Rollover ──

  void _checkDayRollover() {
    final lastDate = _prefs?.getString(_keyTravelDate);
    final today = _todayString();
    if (lastDate != null && lastDate != today) {
      _prefs?.setInt(_keyTravelsUsed, 0);
    }
  }

  String _todayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  // ── Copy ──

  String _travelMessage(RealmType realm) {
    switch (realm) {
      case RealmType.fire:
        return 'Travel to Fire Realm (Energetic Zone)';
      case RealmType.water:
        return 'Travel to Water Realm (Deep Flow Zone)';
      case RealmType.forest:
        return 'Travel to Forest Realm (Growth Zone)';
      case RealmType.air:
        return 'Travel to Air Realm (Clarity Zone)';
      case RealmType.central:
        return 'Visit Central Land (Friends Hangout)';
    }
  }
}

/// Result of a travel attempt
class TravelResult {
  final bool success;
  final String message;
  final int travelsRemaining;

  const TravelResult({
    required this.success,
    required this.message,
    required this.travelsRemaining,
  });
}
