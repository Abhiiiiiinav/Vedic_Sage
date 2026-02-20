/// Friend Presence — live location & status for the Realm Map.
///
/// Matches the backend JSON contract:
///   GET  /world/presence?realm=fire
///   POST /world/update-presence

import 'realm_models.dart';

// ════════════════════════════════════════════════════════════
// ENUMS
// ════════════════════════════════════════════════════════════

enum PresenceVisibility { public, friendsOnly, hidden }

extension PresenceVisibilityExt on PresenceVisibility {
  String get key {
    switch (this) {
      case PresenceVisibility.public:
        return 'public';
      case PresenceVisibility.friendsOnly:
        return 'friends_only';
      case PresenceVisibility.hidden:
        return 'hidden';
    }
  }

  static PresenceVisibility fromKey(String key) {
    switch (key) {
      case 'friends_only':
        return PresenceVisibility.friendsOnly;
      case 'hidden':
        return PresenceVisibility.hidden;
      default:
        return PresenceVisibility.public;
    }
  }
}

enum PresenceStatus { online, away, offline }

extension PresenceStatusExt on PresenceStatus {
  String get key => name;

  static PresenceStatus fromKey(String key) {
    switch (key) {
      case 'online':
        return PresenceStatus.online;
      case 'away':
        return PresenceStatus.away;
      default:
        return PresenceStatus.offline;
    }
  }

  String get emoji {
    switch (this) {
      case PresenceStatus.online:
        return '🟢';
      case PresenceStatus.away:
        return '🟡';
      case PresenceStatus.offline:
        return '⚫';
    }
  }
}

// ════════════════════════════════════════════════════════════
// PET PRESENCE (nested)
// ════════════════════════════════════════════════════════════

class PetPresence {
  final String petId;
  final String skinId;
  final String mood;
  final int level;

  const PetPresence({
    required this.petId,
    required this.skinId,
    required this.mood,
    required this.level,
  });

  Map<String, dynamic> toMap() => {
        'pet_id': petId,
        'skin_id': skinId,
        'mood': mood,
        'level': level,
      };

  factory PetPresence.fromMap(Map<dynamic, dynamic> map) {
    return PetPresence(
      petId: map['pet_id'] as String? ?? '',
      skinId: map['skin_id'] as String? ?? '',
      mood: map['mood'] as String? ?? 'calm',
      level: (map['level'] as num?)?.toInt() ?? 1,
    );
  }
}

// ════════════════════════════════════════════════════════════
// FRIEND PRESENCE
// ════════════════════════════════════════════════════════════

class FriendPresence {
  final String friendId;
  final String displayName;
  final String? avatarUrl;
  final PetPresence? pet;
  final RealmType realm;
  final double x;
  final double y;
  final DateTime lastActive;
  final PresenceVisibility visibility;
  final PresenceStatus status;

  const FriendPresence({
    required this.friendId,
    required this.displayName,
    this.avatarUrl,
    this.pet,
    required this.realm,
    required this.x,
    required this.y,
    required this.lastActive,
    this.visibility = PresenceVisibility.friendsOnly,
    this.status = PresenceStatus.online,
  });

  /// Serialize for Hive / JSON
  Map<String, dynamic> toMap() => {
        'friend_id': friendId,
        'display_name': displayName,
        'avatar_url': avatarUrl,
        'pet': pet?.toMap(),
        'realm': realm.name,
        'position': {'x': x, 'y': y},
        'last_active': lastActive.toIso8601String(),
        'visibility': visibility.key,
        'status': status.key,
      };

  factory FriendPresence.fromMap(Map<dynamic, dynamic> map) {
    final pos = map['position'] as Map<dynamic, dynamic>? ?? {};
    return FriendPresence(
      friendId: map['friend_id'] as String? ?? '',
      displayName: map['display_name'] as String? ?? '',
      avatarUrl: map['avatar_url'] as String?,
      pet: map['pet'] != null
          ? PetPresence.fromMap(map['pet'] as Map<dynamic, dynamic>)
          : null,
      realm: _realmFromString(map['realm'] as String? ?? 'central'),
      x: (pos['x'] as num?)?.toDouble() ?? 0,
      y: (pos['y'] as num?)?.toDouble() ?? 0,
      lastActive: DateTime.tryParse(map['last_active'] as String? ?? '') ??
          DateTime.now(),
      visibility:
          PresenceVisibilityExt.fromKey(map['visibility'] as String? ?? ''),
      status: PresenceStatusExt.fromKey(map['status'] as String? ?? ''),
    );
  }

  static RealmType _realmFromString(String s) {
    for (final r in RealmType.values) {
      if (r.name == s) return r;
    }
    return RealmType.central;
  }

  /// Client → Server update payload
  Map<String, dynamic> toUpdatePayload() => {
        'friend_id': friendId,
        'realm': realm.name,
        'position': {'x': x, 'y': y},
        'pet_state':
            pet != null ? {'mood': pet!.mood, 'xp_gained_today': 0} : null,
      };
}
