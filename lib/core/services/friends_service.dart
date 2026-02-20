import 'dart:math';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/friend_model.dart';

/// Service for managing friend connections stored in Hive.
class FriendsService {
  static final FriendsService _instance = FriendsService._();
  factory FriendsService() => _instance;
  FriendsService._();

  static const String _boxName = 'friends';
  Box? _box;

  /// Initialize — call once at app start
  Future<void> initialize() async {
    if (_box != null && _box!.isOpen) return;
    _box = await Hive.openBox(_boxName);
  }

  Box get _safeBox {
    if (_box == null || !_box!.isOpen) {
      throw StateError(
          'FriendsService not initialized. Call initialize() first.');
    }
    return _box!;
  }

  // ── CRUD ──

  /// Add a new friend
  Future<FriendProfile> addFriend({
    required String name,
    required DateTime dateOfBirth,
    required String placeOfBirth,
    required double latitude,
    required double longitude,
    double timezoneOffset = 5.5,
    required RelationshipType relationship,
    String? notes,
  }) async {
    final id = _generateId();
    final friendCode = _generateFriendCode(name, dateOfBirth);

    final friend = FriendProfile(
      id: id,
      name: name,
      dateOfBirth: dateOfBirth,
      placeOfBirth: placeOfBirth,
      latitude: latitude,
      longitude: longitude,
      timezoneOffset: timezoneOffset,
      relationship: relationship,
      addedAt: DateTime.now(),
      friendCode: friendCode,
      notes: notes,
    );

    await _safeBox.put(id, friend.toMap());
    print('👥 Friend added: ${friend.name} (${friend.relationship.label})');
    return friend;
  }

  /// Get all friends
  List<FriendProfile> getAllFriends() {
    return _safeBox.values.map((v) => FriendProfile.fromMap(v as Map)).toList()
      ..sort((a, b) => b.addedAt.compareTo(a.addedAt));
  }

  /// Get a friend by ID
  FriendProfile? getFriend(String id) {
    final data = _safeBox.get(id);
    if (data == null) return null;
    return FriendProfile.fromMap(data as Map);
  }

  /// Get friends by relationship type
  List<FriendProfile> getFriendsByRelationship(RelationshipType type) {
    return getAllFriends().where((f) => f.relationship == type).toList();
  }

  /// Update a friend's profile
  Future<void> updateFriend(FriendProfile friend) async {
    await _safeBox.put(friend.id, friend.toMap());
    print('✏️ Friend updated: ${friend.name}');
  }

  /// Update chart data for a friend (after chart calculation)
  Future<FriendProfile?> updateChartData(
    String friendId, {
    String? ascendantSign,
    String? moonSign,
    String? sunSign,
    String? moonNakshatra,
  }) async {
    final friend = getFriend(friendId);
    if (friend == null) return null;

    final updated = friend.copyWith(
      ascendantSign: ascendantSign,
      moonSign: moonSign,
      sunSign: sunSign,
      moonNakshatra: moonNakshatra,
    );

    await _safeBox.put(friendId, updated.toMap());
    return updated;
  }

  /// Delete a friend
  Future<void> deleteFriend(String id) async {
    final friend = getFriend(id);
    await _safeBox.delete(id);
    print('🗑️ Friend removed: ${friend?.name ?? id}');
  }

  /// Total friends count
  int get friendCount => _safeBox.length;

  /// Count by relationship type
  Map<RelationshipType, int> get relationshipCounts {
    final counts = <RelationshipType, int>{};
    for (final type in RelationshipType.values) {
      counts[type] = 0;
    }
    for (final friend in getAllFriends()) {
      counts[friend.relationship] = (counts[friend.relationship] ?? 0) + 1;
    }
    return counts;
  }

  // ── Helpers ──

  String _generateId() {
    final now = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(9999).toString().padLeft(4, '0');
    return 'friend_${now}_$random';
  }

  String _generateFriendCode(String name, DateTime dob) {
    final cleanName = name.trim().toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
    final nameCode = (cleanName.isEmpty ? 'FRND' : cleanName).padRight(4, 'X').substring(0, 4);
    final seed = '${dob.millisecondsSinceEpoch}${Random().nextInt(9999)}';
    int hash = 0x811C9DC5;
    for (int i = 0; i < seed.length; i++) {
      hash ^= seed.codeUnitAt(i);
      hash = (hash * 0x01000193) & 0xFFFFFFFF;
    }
    final suffix = (hash & 0xFFFF).toRadixString(36).toUpperCase().padLeft(4, '0').substring(0, 4);
    return '$nameCode$suffix';
  }
}
