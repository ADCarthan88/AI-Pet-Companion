import 'package:flutter/material.dart';
import 'pet.dart';

enum TrickDifficulty { easy, medium, hard }

class PetTrick {
  final String name;
  final String description;
  final TrickDifficulty difficulty;
  final List<PetType> compatiblePets;
  final int experienceToMaster;
  int currentExperience;
  bool isUnlocked;

  PetTrick({
    required this.name,
    required this.description,
    required this.difficulty,
    required this.compatiblePets,
    required this.experienceToMaster,
    this.currentExperience = 0,
    this.isUnlocked = false,
  });

  double get masteryPercentage =>
      (currentExperience / experienceToMaster).clamp(0.0, 1.0);

  bool get isMastered => currentExperience >= experienceToMaster;

  static List<PetTrick> getTricksForPetType(PetType type) {
    return allTricks
        .where((trick) => trick.compatiblePets.contains(type))
        .toList();
  }

  static final List<PetTrick> allTricks = [
    // Dog tricks
    PetTrick(
      name: 'Sit',
      description: 'Train your pet to sit on command',
      difficulty: TrickDifficulty.easy,
      compatiblePets: [PetType.dog],
      experienceToMaster: 100,
    ),
    // Cat tricks
    PetTrick(
      name: 'Paw Wave',
      description: 'Your pet waves their paw at you',
      difficulty: TrickDifficulty.medium,
      compatiblePets: [PetType.cat],
      experienceToMaster: 150,
    ),
    // Bird tricks
    PetTrick(
      name: 'Sing',
      description: 'Your bird sings a melody',
      difficulty: TrickDifficulty.medium,
      compatiblePets: [PetType.bird],
      experienceToMaster: 200,
    ),
    // Lion tricks
    PetTrick(
      name: 'Mighty Roar',
      description: 'A powerful roar that commands respect',
      difficulty: TrickDifficulty.hard,
      compatiblePets: [PetType.lion],
      experienceToMaster: 300,
    ),
    // Giraffe tricks
    PetTrick(
      name: 'Graceful Bow',
      description: 'Your giraffe bows with elegance',
      difficulty: TrickDifficulty.medium,
      compatiblePets: [PetType.giraffe],
      experienceToMaster: 200,
    ),
    // Penguin tricks
    PetTrick(
      name: 'Belly Slide',
      description: 'A playful slide on the belly',
      difficulty: TrickDifficulty.easy,
      compatiblePets: [PetType.penguin],
      experienceToMaster: 100,
    ),
    // Panda tricks
    PetTrick(
      name: 'Roll Over',
      description: 'A cute rolling motion',
      difficulty: TrickDifficulty.easy,
      compatiblePets: [PetType.panda],
      experienceToMaster: 100,
    ),
  ];
}
