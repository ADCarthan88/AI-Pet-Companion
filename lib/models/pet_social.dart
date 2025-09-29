import 'package:flutter/material.dart';
import 'pet.dart';
import 'pet_trick.dart';

class PetSocialProfile {
  final String id;
  final String ownerName;
  final Pet pet;
  final List<PetTrick> masteredTricks;
  final List<String> achievements;
  final List<String> friendIds;
  final DateTime joinDate;
  int socialScore;

  PetSocialProfile({
    required this.id,
    required this.ownerName,
    required this.pet,
    List<PetTrick>? masteredTricks,
    List<String>? achievements,
    List<String>? friendIds,
    DateTime? joinDate,
    this.socialScore = 0,
  }) : masteredTricks = masteredTricks ?? [],
       achievements = achievements ?? [],
       friendIds = friendIds ?? [],
       joinDate = joinDate ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ownerName': ownerName,
      'pet': {
        'name': pet.name,
        'type': pet.type.toString(),
        'gender': pet.gender.toString(),
      },
      'masteredTricks': masteredTricks.map((t) => t.name).toList(),
      'achievements': achievements,
      'friendIds': friendIds,
      'joinDate': joinDate.toIso8601String(),
      'socialScore': socialScore,
    };
  }
}

class SocialEvent {
  final String id;
  final String name;
  final String description;
  final DateTime startTime;
  final Duration duration;
  final List<PetType> allowedPetTypes;
  final int maxParticipants;
  final List<String> participantIds;
  bool isActive;

  SocialEvent({
    required this.id,
    required this.name,
    required this.description,
    required this.startTime,
    required this.duration,
    required this.allowedPetTypes,
    required this.maxParticipants,
    List<String>? participantIds,
    this.isActive = true,
  }) : participantIds = participantIds ?? [];

  bool canJoin(Pet pet) {
    return isActive &&
        participantIds.length < maxParticipants &&
        allowedPetTypes.contains(pet.type);
  }

  void addParticipant(String profileId) {
    if (participantIds.length < maxParticipants) {
      participantIds.add(profileId);
    }
  }

  static List<SocialEvent> getEventsForPetType(PetType type) {
    return [
      if (type == PetType.lion)
        SocialEvent(
          id: 'pride_gathering',
          name: 'Pride Gathering',
          description: 'Join other lions for a majestic meetup!',
          startTime: DateTime.now().add(const Duration(days: 1)),
          duration: const Duration(hours: 2),
          allowedPetTypes: [PetType.lion],
          maxParticipants: 6,
        ),
      if (type == PetType.penguin)
        SocialEvent(
          id: 'penguin_party',
          name: 'Penguin Party',
          description: 'Slide, swim and celebrate with fellow penguins!',
          startTime: DateTime.now().add(const Duration(days: 2)),
          duration: const Duration(hours: 3),
          allowedPetTypes: [PetType.penguin],
          maxParticipants: 8,
        ),
      // Add more events for other pet types...
    ];
  }
}
