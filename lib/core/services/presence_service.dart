/// Presence Service — syncs friend locations on the Realm Map.
///
/// Locally caches presence in Hive. Uses mock data derived from
/// FriendsService until a real backend is connected.
///
/// Sync protocol:
///   Pull friend locations every 45 seconds.
///   Push updates when user changes realm or visits central land.

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/friend_presence_model.dart';
import '../models/realm_models.dart';
import '../models/friend_model.dart';
import 'friends_service.dart';
import 'realm_service.dart';

class PresenceService {
  static final PresenceService _instance = PresenceService._();
  factory PresenceService() => _instance;
  PresenceService._();

  static const String _boxName = 'friend_presence';
  static const Duration _syncInterval = Duration(seconds: 45);

  Box? _box;
  Timer? _syncTimer;
  VoidCallback? _onPresenceUpdated;

  // ── Initialize ──

  Future<void> initialize() async {
    if (_box != null && _box!.isOpen) return;
    _box = await Hive.openBox(_boxName);
    await syncFriendPresences();
    _startAutoSync();
  }

  /// Register a callback for UI refresh when presence data changes
  void setOnPresenceUpdated(VoidCallback callback) {
    _onPresenceUpdated = callback;
  }

  void _startAutoSync() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(_syncInterval, (_) async {
      await syncFriendPresences();
    });
  }

  void dispose() {
    _syncTimer?.cancel();
    _syncTimer = null;
    _onPresenceUpdated = null;
  }

  Box get _safeBox {
    if (_box == null || !_box!.isOpen) {
      throw StateError(
          'PresenceService not initialized. Call initialize() first.');
    }
    return _box!;
  }

  // ── My Presence ──

  /// Update the local user's presence (queued for push in production)
  Future<void> updateMyPresence({
    required RealmType realm,
    required double x,
    required double y,
    String? petMood,
  }) async {
    final payload = {
      'realm': realm.name,
      'position': {'x': x, 'y': y},
      'pet_mood': petMood,
      'updated_at': DateTime.now().toIso8601String(),
    };
    await _safeBox.put('my_presence', payload);
    // In production: POST /world/update-presence with payload
  }

  // ── Friend Presences ──

  /// Get all cached friend presences
  List<FriendPresence> getFriendPresences() {
    final presences = <FriendPresence>[];
    for (final key in _safeBox.keys) {
      if (key == 'my_presence') continue;
      final data = _safeBox.get(key);
      if (data != null && data is Map) {
        try {
          presences.add(FriendPresence.fromMap(data));
        } catch (_) {
          // Skip corrupt entries
        }
      }
    }
    return presences;
  }

  /// Get presences filtered by realm
  List<FriendPresence> getPresencesByRealm(RealmType realm) {
    return getFriendPresences().where((p) => p.realm == realm).toList();
  }

  /// Sync friend presences.
  ///
  /// Currently generates mock positions from local friend data.
  /// Replace the body with HTTP call to `GET /world/presence` in production.
  Future<void> syncFriendPresences() async {
    try {
      final friendsService = FriendsService();
      final realmService = RealmService();
      final friends = friendsService.getAllFriends();

      for (final friend in friends) {
        final realm = realmService.getFriendRealm(friend);
        final presence = _generateMockPresence(friend, realm);
        await _safeBox.put(friend.id, presence.toMap());
      }

      _onPresenceUpdated?.call();
    } catch (e) {
      // Silently fail — cached data remains valid
      debugPrint('⚠️ Presence sync failed: $e');
    }
  }

  /// Generate a mock presence for a friend.
  /// Uses deterministic positioning based on friend ID hash so
  /// positions are stable across syncs but vary between friends.
  FriendPresence _generateMockPresence(FriendProfile friend, RealmType realm) {
    final hash = friend.id.hashCode;
    final rng = Random(hash);

    // Slight position jitter on each sync to simulate movement
    final jitterSeed = DateTime.now().minute ~/ 5; // Changes every 5 min
    final jitterRng = Random(hash + jitterSeed);
    final baseX = 60.0 + rng.nextDouble() * 180;
    final baseY = 80.0 + rng.nextDouble() * 200;
    final jitterX = (jitterRng.nextDouble() - 0.5) * 20;
    final jitterY = (jitterRng.nextDouble() - 0.5) * 20;

    // Simulate online/away status
    final minutesSinceHour = DateTime.now().minute;
    final isActive = (hash + minutesSinceHour) % 3 != 0;

    return FriendPresence(
      friendId: friend.id,
      displayName: friend.name,
      realm: realm,
      x: baseX + jitterX,
      y: baseY + jitterY,
      lastActive: DateTime.now().subtract(
        Duration(minutes: isActive ? 0 : rng.nextInt(30) + 5),
      ),
      status: isActive ? PresenceStatus.online : PresenceStatus.away,
      visibility: PresenceVisibility.friendsOnly,
      pet: PetPresence(
        petId: 'pet_${friend.id}',
        skinId: 'skin_${realm.name}_01',
        mood: _randomMood(rng),
        level: 1 + rng.nextInt(10),
      ),
    );
  }

  String _randomMood(Random rng) {
    const moods = ['energetic', 'calm', 'focused', 'playful', 'reflective'];
    return moods[rng.nextInt(moods.length)];
  }
}
