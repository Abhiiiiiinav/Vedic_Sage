import 'dart:math';
import 'package:flutter/material.dart';
import '../models/realm_models.dart';
import '../models/friend_presence_model.dart';
import 'user_session.dart';
import 'friends_service.dart';
import '../models/friend_model.dart';

/// Service that assigns users and friends to elemental realms
/// based on their dominant zodiac element from chart data.
class RealmService {
  static final RealmService _instance = RealmService._();
  factory RealmService() => _instance;
  RealmService._();

  // Sign → Element mapping
  static const Map<String, AstroElement> _signElements = {
    'Aries': AstroElement.fire,
    'Leo': AstroElement.fire,
    'Sagittarius': AstroElement.fire,
    'Cancer': AstroElement.water,
    'Scorpio': AstroElement.water,
    'Pisces': AstroElement.water,
    'Taurus': AstroElement.earth,
    'Virgo': AstroElement.earth,
    'Capricorn': AstroElement.earth,
    'Gemini': AstroElement.air,
    'Libra': AstroElement.air,
    'Aquarius': AstroElement.air,
  };

  // Predefined avatar colors
  static const _avatarColors = [
    Color(0xFFff6b9d),
    Color(0xFF00d4ff),
    Color(0xFF69F0AE),
    Color(0xFFf5a623),
    Color(0xFF7B61FF),
    Color(0xFFff3b30),
    Color(0xFFffcc00),
    Color(0xFF5856d6),
  ];

  /// Get the user's home realm based on their birth chart
  RealmType getUserRealm() {
    final session = UserSession();
    if (!session.hasData || session.birthChart == null) {
      return RealmType.central; // Default to central if no chart
    }

    final chart = session.birthChart!;
    final element = _getDominantElement(chart);
    return element.realm;
  }

  /// Get a friend's realm based on their sun sign
  RealmType getFriendRealm(FriendProfile friend) {
    final sign = friend.sunSign ?? friend.moonSign ?? friend.ascendantSign;
    if (sign == null) return RealmType.central;
    final element = _signElements[sign];
    return element?.realm ?? RealmType.central;
  }

  /// Build markers for all friends positioned in their realms (static fallback)
  List<FriendMapMarker> buildFriendMarkers() {
    final friends = FriendsService().getAllFriends();
    final random = Random(42); // deterministic seed for consistent positioning
    final markers = <FriendMapMarker>[];

    for (int i = 0; i < friends.length; i++) {
      final friend = friends[i];
      final realm = getFriendRealm(friend);

      // Position friends within their realm zone with some randomness
      final xOffset = 60.0 + random.nextDouble() * 180;
      final yOffset = 80.0 + random.nextDouble() * 200;

      markers.add(FriendMapMarker(
        friendId: friend.id,
        name: friend.name,
        initial: friend.name.isNotEmpty ? friend.name[0].toUpperCase() : '?',
        realm: realm,
        x: xOffset,
        y: yOffset,
        avatarColor: _avatarColors[i % _avatarColors.length],
      ));
    }

    return markers;
  }

  /// Build markers from live presence data
  List<FriendMapMarker> buildFriendMarkersFromPresence(
      List<FriendPresence> presences) {
    final markers = <FriendMapMarker>[];

    for (int i = 0; i < presences.length; i++) {
      final p = presences[i];
      // Skip hidden friends
      if (p.visibility == PresenceVisibility.hidden) continue;

      markers.add(FriendMapMarker(
        friendId: p.friendId,
        name: p.displayName,
        initial:
            p.displayName.isNotEmpty ? p.displayName[0].toUpperCase() : '?',
        realm: p.realm,
        x: p.x,
        y: p.y,
        petSpecies: p.pet?.skinId,
        avatarColor: _avatarColors[i % _avatarColors.length],
      ));
    }

    return markers;
  }

  /// Determine the dominant element from planet positions in the chart
  AstroElement _getDominantElement(Map<String, dynamic> chart) {
    final counts = <AstroElement, int>{
      AstroElement.fire: 0,
      AstroElement.water: 0,
      AstroElement.earth: 0,
      AstroElement.air: 0,
    };

    // Count planets per element
    final positions = chart['planetPositions'] as Map<String, dynamic>?;
    if (positions != null) {
      for (final entry in positions.entries) {
        final data = entry.value;
        if (data is Map<String, dynamic>) {
          final sign = data['sign'] as String?;
          if (sign != null && _signElements.containsKey(sign)) {
            counts[_signElements[sign]!] = counts[_signElements[sign]!]! + 1;
          }
        }
      }
    }

    // Ascendant sign breaks ties (weighted +2)
    final ascSign = chart['ascSign'] as String?;
    if (ascSign != null && _signElements.containsKey(ascSign)) {
      counts[_signElements[ascSign]!] = counts[_signElements[ascSign]!]! + 2;
    }

    // Find dominant element
    AstroElement dominant = AstroElement.fire;
    int maxCount = 0;
    counts.forEach((element, count) {
      if (count > maxCount) {
        maxCount = count;
        dominant = element;
      }
    });

    return dominant;
  }

  /// Get element for a sign string
  static AstroElement? elementForSign(String? sign) {
    if (sign == null) return null;
    return _signElements[sign];
  }
}
