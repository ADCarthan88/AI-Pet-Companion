import 'package:flutter/material.dart';
import 'pet.dart';

enum ToyType {
  ball,         // For dogs
  laserPointer, // For cats
  bell,         // For birds
  carrot,       // For rabbits
}

class Toy {
  final ToyType type;
  final String name;
  final Color color;
  final List<PetType> suitableFor;
  bool isInUse;

  Toy({
    required this.type,
    required this.name,
    required this.color,
    required this.suitableFor,
    this.isInUse = false,
  });

  static List<Toy> getToysForPetType(PetType petType) {
    switch (petType) {
      case PetType.dog:
        return [
          Toy(
            type: ToyType.ball,
            name: 'Bouncy Ball',
            color: Colors.red,
            suitableFor: [PetType.dog],
          ),
        ];
      case PetType.cat:
        return [
          Toy(
            type: ToyType.laserPointer,
            name: 'Laser Pointer',
            color: Colors.red,
            suitableFor: [PetType.cat],
          ),
        ];
      case PetType.bird:
        return [
          Toy(
            type: ToyType.bell,
            name: 'Jingle Bell',
            color: Colors.yellow,
            suitableFor: [PetType.bird],
          ),
        ];
      case PetType.rabbit:
        return [
          Toy(
            type: ToyType.carrot,
            name: 'Carrot Toy',
            color: Colors.orange,
            suitableFor: [PetType.rabbit],
          ),
        ];
    }
  }
}