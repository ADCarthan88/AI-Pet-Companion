import 'package:flutter/material.dart';
import '../../models/pet.dart';
import 'dog_visual.dart';
import 'cat_visual.dart';
import 'bird_visual.dart';
import 'rabbit_visual.dart';
import 'lion_visual.dart';
import 'giraffe_visual.dart';
import 'penguin_visual.dart';
import 'panda_visual.dart';

class PetVisualizationFactory {
  static Widget getPetVisualization({
    required Pet pet,
    required bool isBlinking,
    required bool mouthOpen,
    required double size,
  }) {
    switch (pet.type) {
      case PetType.dog:
        return DogVisual(
          pet: pet,
          isBlinking: isBlinking,
          mouthOpen: mouthOpen,
          size: size,
        );
      case PetType.cat:
        return CatVisual(
          pet: pet,
          isBlinking: isBlinking,
          mouthOpen: mouthOpen,
          size: size,
        );
      case PetType.bird:
        return BirdVisual(
          pet: pet,
          isBlinking: isBlinking,
          mouthOpen: mouthOpen,
          size: size,
        );
      case PetType.rabbit:
        return RabbitVisual(
          pet: pet,
          isBlinking: isBlinking,
          mouthOpen: mouthOpen,
          size: size,
        );
      case PetType.lion:
        return LionVisual(
          pet: pet,
          isBlinking: isBlinking,
          mouthOpen: mouthOpen,
          size: size,
        );
      case PetType.giraffe:
        return GiraffeVisual(
          pet: pet,
          isBlinking: isBlinking,
          mouthOpen: mouthOpen,
          size: size,
        );
      case PetType.penguin:
        return PenguinVisual(
          pet: pet,
          isBlinking: isBlinking,
          mouthOpen: mouthOpen,
          size: size,
        );
      case PetType.panda:
        return PandaVisual(
          pet: pet,
          isBlinking: isBlinking,
          mouthOpen: mouthOpen,
          size: size,
        );
    }
  }

  // Helper method for animals we haven't created custom visuals for yet
  static Widget _buildPlaceholderPet({
    required Pet pet,
    required bool isBlinking,
    required bool mouthOpen,
    required double size,
    required String petName,
    required IconData icon,
  }) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          // Center aligned icon
          Center(
            child: Icon(icon, size: size * 0.6, color: pet.color),
          ),

          // Pet name
          Positioned(
            bottom: size * 0.1,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                petName,
                style: TextStyle(
                  fontSize: size * 0.12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Eyes
          if (!isBlinking)
            Positioned(
              top: size * 0.3,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: size * 0.1,
                    height: size * 0.1,
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                    margin: EdgeInsets.symmetric(horizontal: size * 0.05),
                  ),
                  Container(
                    width: size * 0.1,
                    height: size * 0.1,
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                    margin: EdgeInsets.symmetric(horizontal: size * 0.05),
                  ),
                ],
              ),
            ),

          // Mouth
          Positioned(
            top: size * 0.5,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: size * 0.2,
                height: mouthOpen ? size * 0.15 : size * 0.03,
                decoration: BoxDecoration(
                  color: mouthOpen ? Colors.black87 : Colors.transparent,
                  border: mouthOpen
                      ? null
                      : Border.all(color: Colors.black87, width: 2),
                  borderRadius: BorderRadius.circular(size * 0.1),
                ),
              ),
            ),
          ),

          // Activity indicator
          if (pet.currentActivity == PetActivity.sleeping)
            Positioned(
              top: size * 0.1,
              right: size * 0.2,
              child: Text('💤', style: TextStyle(fontSize: size * 0.2)),
            ),
        ],
      ),
    );
  }
}
