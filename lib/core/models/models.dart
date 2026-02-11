import 'package:flutter/material.dart';

/// Planet model representing a Vedic astrological planet (Graha)
class Planet {
  final String id;
  final String name;
  final String sanskritName;
  final String symbol;
  final List<String> karakas;
  final String naturalRole;
  final String functionalRole;
  final List<String> psychologicalTendencies;
  final List<String> dailyBehaviors;
  final List<String> strengtheningActions;
  final List<String> observationPrompts;
  final String journalPrompt;
  final String element;
  final String nature;

  const Planet({
    required this.id,
    required this.name,
    required this.sanskritName,
    required this.symbol,
    required this.karakas,
    required this.naturalRole,
    required this.functionalRole,
    required this.psychologicalTendencies,
    required this.dailyBehaviors,
    required this.strengtheningActions,
    required this.observationPrompts,
    required this.journalPrompt,
    required this.element,
    required this.nature,
  });
}

/// House model representing one of the 12 astrological houses (Bhavas)
class House {
  final int number;
  final String name;
  final String sanskritName;
  final List<String> lifeAreas;
  final List<String> realWorldExamples;
  final List<String> problemManifestations;
  final List<String> growthOpportunities;
  final String naturalSign;
  final String naturalPlanet;
  final String description;

  const House({
    required this.number,
    required this.name,
    required this.sanskritName,
    required this.lifeAreas,
    required this.realWorldExamples,
    required this.problemManifestations,
    required this.growthOpportunities,
    required this.naturalSign,
    required this.naturalPlanet,
    required this.description,
  });
}

/// Sign model representing one of the 12 zodiac signs (Rashis)
class Sign {
  final String id;
  final String name;
  final String sanskritName;
  final String symbol;
  final String element;
  final String modality;
  final String rulingPlanet;
  final List<String> behavioralStyles;
  final List<String> motivationPatterns;
  final List<String> strengths;
  final List<String> blindSpots;
  final String description;
  final int houseNumber;

  const Sign({
    required this.id,
    required this.name,
    required this.sanskritName,
    required this.symbol,
    required this.element,
    required this.modality,
    required this.rulingPlanet,
    required this.behavioralStyles,
    required this.motivationPatterns,
    required this.strengths,
    required this.blindSpots,
    required this.description,
    required this.houseNumber,
  });
}

/// Nakshatra model representing one of the 27 lunar mansions
class Nakshatra {
  final int number;
  final String name;
  final String lord;
  final String deity;
  final String symbol;
  final List<String> syllables;
  final String signSpan;
  final List<String> psychologicalDrivers;
  final List<String> unconsciousBehaviors;
  final List<String> strengtheningPractices;
  final String nature;
  final String gana;
  final String animal;
  final String description;

  const Nakshatra({
    required this.number,
    required this.name,
    required this.lord,
    required this.deity,
    required this.symbol,
    required this.syllables,
    required this.signSpan,
    required this.psychologicalDrivers,
    required this.unconsciousBehaviors,
    required this.strengtheningPractices,
    required this.nature,
    required this.gana,
    required this.animal,
    required this.description,
  });
}

/// Planet placement in a birth chart
class PlanetPlacement {
  final String planetId;
  final int house;
  final String sign;
  final double degrees;
  final String nakshatra;
  final int nakshatraPada;
  final bool isRetrograde;
  final String dignity;

  const PlanetPlacement({
    required this.planetId,
    required this.house,
    required this.sign,
    required this.degrees,
    required this.nakshatra,
    required this.nakshatraPada,
    required this.isRetrograde,
    required this.dignity,
  });
}

/// Complete birth chart data
class BirthChart {
  final DateTime birthDateTime;
  final String birthPlace;
  final double latitude;
  final double longitude;
  final String ascendantSign;
  final int ascendantDegrees;
  final Map<String, PlanetPlacement> planetPlacements;

  const BirthChart({
    required this.birthDateTime,
    required this.birthPlace,
    required this.latitude,
    required this.longitude,
    required this.ascendantSign,
    required this.ascendantDegrees,
    required this.planetPlacements,
  });
}

/// Question category for the Q&A module
class QuestionCategory {
  final String id;
  final String name;
  final String icon;
  final String description;
  final List<int> relevantHouses;
  final List<String> relevantPlanets;
  final List<String> sampleQuestions;

  const QuestionCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.description,
    required this.relevantHouses,
    required this.relevantPlanets,
    required this.sampleQuestions,
  });
}

/// Growth exercise for self-improvement module
class GrowthExercise {
  final String id;
  final String planetId;
  final String title;
  final String description;
  final String duration;
  final String frequency;
  final List<String> steps;
  final String expectedBenefit;

  const GrowthExercise({
    required this.id,
    required this.planetId,
    required this.title,
    required this.description,
    required this.duration,
    required this.frequency,
    required this.steps,
    required this.expectedBenefit,
  });
}


/// Birth details for chart calculation
class BirthDetails {
  final DateTime dateTime;
  final double latitude;
  final double longitude;
  final String placeName;

  const BirthDetails({
    required this.dateTime,
    required this.latitude,
    required this.longitude,
    required this.placeName,
  });
}

