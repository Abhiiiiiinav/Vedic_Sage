/// Friend model and relationship types for AstroLearn social features

/// Relationship type between the user and a friend
enum RelationshipType {
  couple,
  parent,
  sibling,
  friend,
  colleague,
  other,
}

/// One pet-to-pet supportive interaction effect for a friend pairing.
class FriendInteractionEffectData {
  final String giverName;
  final String receiverName;
  final String giverSpeciesKey;
  final String giverSpeciesLabel;
  final String giverSpeciesEmoji;
  final String abilityName;
  final String abilityEmoji;
  final String abilityEffectType;
  final String targetStat;
  final int giverStrength;
  final int receiverWeakness;
  final int boostAmount;
  final String narrative;

  const FriendInteractionEffectData({
    required this.giverName,
    required this.receiverName,
    required this.giverSpeciesKey,
    required this.giverSpeciesLabel,
    required this.giverSpeciesEmoji,
    required this.abilityName,
    required this.abilityEmoji,
    required this.abilityEffectType,
    required this.targetStat,
    required this.giverStrength,
    required this.receiverWeakness,
    required this.boostAmount,
    required this.narrative,
  });

  Map<String, dynamic> toMap() {
    return {
      'giverName': giverName,
      'receiverName': receiverName,
      'giverSpeciesKey': giverSpeciesKey,
      'giverSpeciesLabel': giverSpeciesLabel,
      'giverSpeciesEmoji': giverSpeciesEmoji,
      'abilityName': abilityName,
      'abilityEmoji': abilityEmoji,
      'abilityEffectType': abilityEffectType,
      'targetStat': targetStat,
      'giverStrength': giverStrength,
      'receiverWeakness': receiverWeakness,
      'boostAmount': boostAmount,
      'narrative': narrative,
    };
  }

  factory FriendInteractionEffectData.fromMap(Map<dynamic, dynamic> map) {
    return FriendInteractionEffectData(
      giverName: map['giverName'] as String,
      receiverName: map['receiverName'] as String,
      giverSpeciesKey: map['giverSpeciesKey'] as String,
      giverSpeciesLabel: map['giverSpeciesLabel'] as String,
      giverSpeciesEmoji: map['giverSpeciesEmoji'] as String,
      abilityName: map['abilityName'] as String,
      abilityEmoji: map['abilityEmoji'] as String,
      abilityEffectType: map['abilityEffectType'] as String,
      targetStat: map['targetStat'] as String,
      giverStrength: map['giverStrength'] as int,
      receiverWeakness: map['receiverWeakness'] as int,
      boostAmount: map['boostAmount'] as int,
      narrative: map['narrative'] as String,
    );
  }
}

/// Computed pet interaction snapshot between user and one friend.
class FriendPetInteractionData {
  final String friendId;
  final String friendName;
  final RelationshipType relationship;
  final DateTime generatedAt;
  final int synergyScore;
  final String overallNarrative;
  final String userPetName;
  final String userPetSpeciesKey;
  final String userPetSpeciesLabel;
  final String userPetSpeciesEmoji;
  final String friendPetName;
  final String friendPetSpeciesKey;
  final String friendPetSpeciesLabel;
  final String friendPetSpeciesEmoji;
  final List<FriendInteractionEffectData> effects;

  const FriendPetInteractionData({
    required this.friendId,
    required this.friendName,
    required this.relationship,
    required this.generatedAt,
    required this.synergyScore,
    required this.overallNarrative,
    required this.userPetName,
    required this.userPetSpeciesKey,
    required this.userPetSpeciesLabel,
    required this.userPetSpeciesEmoji,
    required this.friendPetName,
    required this.friendPetSpeciesKey,
    required this.friendPetSpeciesLabel,
    required this.friendPetSpeciesEmoji,
    required this.effects,
  });

  Map<String, dynamic> toMap() {
    return {
      'friendId': friendId,
      'friendName': friendName,
      'relationship': relationship.index,
      'generatedAt': generatedAt.millisecondsSinceEpoch,
      'synergyScore': synergyScore,
      'overallNarrative': overallNarrative,
      'userPetName': userPetName,
      'userPetSpeciesKey': userPetSpeciesKey,
      'userPetSpeciesLabel': userPetSpeciesLabel,
      'userPetSpeciesEmoji': userPetSpeciesEmoji,
      'friendPetName': friendPetName,
      'friendPetSpeciesKey': friendPetSpeciesKey,
      'friendPetSpeciesLabel': friendPetSpeciesLabel,
      'friendPetSpeciesEmoji': friendPetSpeciesEmoji,
      'effects': effects.map((e) => e.toMap()).toList(),
    };
  }

  factory FriendPetInteractionData.fromMap(Map<dynamic, dynamic> map) {
    final rawEffects = map['effects'] as List<dynamic>? ?? [];
    return FriendPetInteractionData(
      friendId: map['friendId'] as String,
      friendName: map['friendName'] as String,
      relationship: RelationshipType.values[map['relationship'] as int],
      generatedAt:
          DateTime.fromMillisecondsSinceEpoch(map['generatedAt'] as int),
      synergyScore: map['synergyScore'] as int,
      overallNarrative: map['overallNarrative'] as String,
      userPetName: map['userPetName'] as String,
      userPetSpeciesKey: map['userPetSpeciesKey'] as String,
      userPetSpeciesLabel: map['userPetSpeciesLabel'] as String,
      userPetSpeciesEmoji: map['userPetSpeciesEmoji'] as String,
      friendPetName: map['friendPetName'] as String,
      friendPetSpeciesKey: map['friendPetSpeciesKey'] as String,
      friendPetSpeciesLabel: map['friendPetSpeciesLabel'] as String,
      friendPetSpeciesEmoji: map['friendPetSpeciesEmoji'] as String,
      effects: rawEffects
          .map((e) => FriendInteractionEffectData.fromMap(
              Map<dynamic, dynamic>.from(e as Map)))
          .toList(),
    );
  }
}

/// Extension for display names and icons
extension RelationshipTypeExt on RelationshipType {
  String get label {
    switch (this) {
      case RelationshipType.couple:
        return 'Partner';
      case RelationshipType.parent:
        return 'Parent / Child';
      case RelationshipType.sibling:
        return 'Sibling';
      case RelationshipType.friend:
        return 'Friend';
      case RelationshipType.colleague:
        return 'Colleague';
      case RelationshipType.other:
        return 'Other';
    }
  }

  String get icon {
    switch (this) {
      case RelationshipType.couple:
        return '💕';
      case RelationshipType.parent:
        return '👨‍👩‍👧';
      case RelationshipType.sibling:
        return '👫';
      case RelationshipType.friend:
        return '🤝';
      case RelationshipType.colleague:
        return '💼';
      case RelationshipType.other:
        return '🌟';
    }
  }
}

/// A friend's astrological profile stored locally
class FriendProfile {
  final String id;
  final String name;
  final DateTime dateOfBirth;
  final String placeOfBirth;
  final double latitude;
  final double longitude;
  final double timezoneOffset;
  final RelationshipType relationship;
  final DateTime addedAt;

  // Cached chart data (populated after first chart calculation)
  final String? ascendantSign;
  final String? moonSign;
  final String? sunSign;
  final String? moonNakshatra;
  final String? friendCode;
  final String? notes;

  const FriendProfile({
    required this.id,
    required this.name,
    required this.dateOfBirth,
    required this.placeOfBirth,
    required this.latitude,
    required this.longitude,
    this.timezoneOffset = 5.5,
    required this.relationship,
    required this.addedAt,
    this.ascendantSign,
    this.moonSign,
    this.sunSign,
    this.moonNakshatra,
    this.friendCode,
    this.notes,
  });

  /// Create a copy with updated fields
  FriendProfile copyWith({
    String? name,
    RelationshipType? relationship,
    String? ascendantSign,
    String? moonSign,
    String? sunSign,
    String? moonNakshatra,
    String? notes,
  }) {
    return FriendProfile(
      id: id,
      name: name ?? this.name,
      dateOfBirth: dateOfBirth,
      placeOfBirth: placeOfBirth,
      latitude: latitude,
      longitude: longitude,
      timezoneOffset: timezoneOffset,
      relationship: relationship ?? this.relationship,
      addedAt: addedAt,
      ascendantSign: ascendantSign ?? this.ascendantSign,
      moonSign: moonSign ?? this.moonSign,
      sunSign: sunSign ?? this.sunSign,
      moonNakshatra: moonNakshatra ?? this.moonNakshatra,
      friendCode: friendCode,
      notes: notes ?? this.notes,
    );
  }

  /// Convert to Map for Hive storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'dateOfBirth': dateOfBirth.millisecondsSinceEpoch,
      'placeOfBirth': placeOfBirth,
      'latitude': latitude,
      'longitude': longitude,
      'timezoneOffset': timezoneOffset,
      'relationship': relationship.index,
      'addedAt': addedAt.millisecondsSinceEpoch,
      'ascendantSign': ascendantSign,
      'moonSign': moonSign,
      'sunSign': sunSign,
      'moonNakshatra': moonNakshatra,
      'friendCode': friendCode,
      'notes': notes,
    };
  }

  /// Create from Map
  factory FriendProfile.fromMap(Map<dynamic, dynamic> map) {
    return FriendProfile(
      id: map['id'] as String,
      name: map['name'] as String,
      dateOfBirth:
          DateTime.fromMillisecondsSinceEpoch(map['dateOfBirth'] as int),
      placeOfBirth: map['placeOfBirth'] as String,
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      timezoneOffset: (map['timezoneOffset'] as num?)?.toDouble() ?? 5.5,
      relationship: RelationshipType.values[map['relationship'] as int],
      addedAt: DateTime.fromMillisecondsSinceEpoch(map['addedAt'] as int),
      ascendantSign: map['ascendantSign'] as String?,
      moonSign: map['moonSign'] as String?,
      sunSign: map['sunSign'] as String?,
      moonNakshatra: map['moonNakshatra'] as String?,
      friendCode: map['friendCode'] as String?,
      notes: map['notes'] as String?,
    );
  }

  /// Display initials
  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  /// Quick summary for display
  String get astroSummary {
    final parts = <String>[];
    if (ascendantSign != null) parts.add('${ascendantSign!} Asc');
    if (moonSign != null) parts.add('${moonSign!} Moon');
    if (sunSign != null) parts.add('${sunSign!} Sun');
    return parts.isEmpty ? 'Chart not calculated' : parts.join(' · ');
  }
}
