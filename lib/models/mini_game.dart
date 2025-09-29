import 'package:flutter/material.dart';
import 'pet.dart';

class MiniGame {
  final String name;
  final String description;
  final List<PetType> playablePets;
  final int maxScore;
  int highScore;
  bool isUnlocked;

  MiniGame({
    required this.name,
    required this.description,
    required this.playablePets,
    required this.maxScore,
    this.highScore = 0,
    this.isUnlocked = false,
  });

  static List<MiniGame> getGamesForPetType(PetType type) {
    return allGames.where((game) => game.playablePets.contains(type)).toList();
  }

  static final List<MiniGame> allGames = [
    // Lion games
    MiniGame(
      name: 'Savannah Chase',
      description: 'Chase prey across the savannah in this exciting adventure!',
      playablePets: [PetType.lion],
      maxScore: 1000,
    ),
    // Giraffe games
    MiniGame(
      name: 'Treetop Treats',
      description: 'Collect delicious leaves from the highest branches!',
      playablePets: [PetType.giraffe],
      maxScore: 500,
    ),
    // Penguin games
    MiniGame(
      name: 'Ice Slide Race',
      description: 'Slide through an icy course and collect fish!',
      playablePets: [PetType.penguin],
      maxScore: 750,
    ),
    // Panda games
    MiniGame(
      name: 'Bamboo Forest Maze',
      description: 'Navigate through a maze while collecting bamboo!',
      playablePets: [PetType.panda],
      maxScore: 600,
    ),
  ];
}

class GameReward {
  final String name;
  final String description;
  final int requiredScore;
  final IconData icon;
  bool isUnlocked;

  GameReward({
    required this.name,
    required this.description,
    required this.requiredScore,
    required this.icon,
    this.isUnlocked = false,
  });
}
