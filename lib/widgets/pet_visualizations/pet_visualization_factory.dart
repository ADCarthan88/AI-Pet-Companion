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

/// Factory class for creating pet visualizations
class PetVisualizationFactory {
  /// Creates a proper visualization for a pet based on its type
  static Widget createVisualization({
    required Pet pet,
    required bool isBlinking,
    required bool mouthOpen,
    required double size,
  }) {
    // Return the appropriate visualization widget based on the pet type
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

  /// Backwards compatibility method with the original name
  static Widget getPetVisualization({
    required Pet pet,
    required bool isBlinking,
    required bool mouthOpen,
    required double size,
  }) {
    return createVisualization(
      pet: pet,
      isBlinking: isBlinking,
      mouthOpen: mouthOpen,
      size: size,
    );
  }

  // No need for the _getPetTypeIcon method anymore since we're using custom visualizations
}
