import '../astro/astro_pet_engine.dart';
import '../astro/kundali_engine.dart';
import '../models/friend_model.dart';
import 'friends_service.dart';
import 'user_session.dart';

/// Builds structured interaction data between the user pet and friend pets.
class FriendsInteractionService {
  static final FriendsInteractionService _instance =
      FriendsInteractionService._();
  factory FriendsInteractionService() => _instance;
  FriendsInteractionService._();

  /// Generate interaction data for one friend.
  FriendPetInteractionData generateForFriend(FriendProfile friend) {
    final userDetails = UserSession().birthDetails;
    if (userDetails == null) {
      throw StateError(
        'Your birth chart is not available. Generate it before pet interactions.',
      );
    }

    final userChart = KundaliEngine.calculateChart(
      birthTime: userDetails.birthDateTime,
      latitude: userDetails.latitude,
      longitude: userDetails.longitude,
      timezoneOffset: userDetails.timezoneOffset,
    );

    final friendChart = KundaliEngine.calculateChart(
      birthTime: friend.dateOfBirth,
      latitude: friend.latitude,
      longitude: friend.longitude,
      timezoneOffset: friend.timezoneOffset,
    );

    final userPet = AstroPetEngine.generatePet(
        chart: userChart, ownerName: userDetails.name);
    final friendPet =
        AstroPetEngine.generatePet(chart: friendChart, ownerName: friend.name);
    final interaction = AstroPetEngine.interact(userPet, friendPet);

    return _toInteractionData(friend, interaction);
  }

  /// Generate interactions for every friend, sorted by synergy (desc).
  Future<List<FriendPetInteractionData>> generateForAllFriends({
    RelationshipType? relationshipFilter,
  }) async {
    final friendsService = FriendsService();
    await friendsService.initialize();

    final friends = relationshipFilter == null
        ? friendsService.getAllFriends()
        : friendsService.getFriendsByRelationship(relationshipFilter);

    final data = <FriendPetInteractionData>[];
    for (final friend in friends) {
      try {
        data.add(generateForFriend(friend));
      } catch (_) {
        // Skip invalid entries; callers can still show available interactions.
      }
    }

    data.sort((a, b) => b.synergyScore.compareTo(a.synergyScore));
    return data;
  }

  FriendPetInteractionData _toInteractionData(
    FriendProfile friend,
    PetInteractionResult result,
  ) {
    return FriendPetInteractionData(
      friendId: friend.id,
      friendName: friend.name,
      relationship: friend.relationship,
      generatedAt: DateTime.now(),
      synergyScore: result.synergyScore,
      overallNarrative: result.overallNarrative,
      userPetName: result.pet1.petName,
      userPetSpeciesKey: _speciesKey(result.pet1.species),
      userPetSpeciesLabel: result.pet1.species.displayName,
      userPetSpeciesEmoji: result.pet1.species.emoji,
      friendPetName: result.pet2.petName,
      friendPetSpeciesKey: _speciesKey(result.pet2.species),
      friendPetSpeciesLabel: result.pet2.species.displayName,
      friendPetSpeciesEmoji: result.pet2.species.emoji,
      effects: result.effects.map(_toEffectData).toList(),
    );
  }

  FriendInteractionEffectData _toEffectData(InteractionEffect effect) {
    return FriendInteractionEffectData(
      giverName: effect.giverName,
      receiverName: effect.receiverName,
      giverSpeciesKey: _speciesKey(effect.giverSpecies),
      giverSpeciesLabel: effect.giverSpecies.displayName,
      giverSpeciesEmoji: effect.giverSpecies.emoji,
      abilityName: effect.ability.name,
      abilityEmoji: effect.ability.emoji,
      abilityEffectType: effect.ability.effectType,
      targetStat: effect.targetStat,
      giverStrength: effect.giverStrength,
      receiverWeakness: effect.receiverWeakness,
      boostAmount: effect.boostAmount,
      narrative: effect.narrative,
    );
  }

  String _speciesKey(PetSpecies species) {
    return species.toString().split('.').last;
  }
}
