import 'package:flutter/material.dart';
import '../../models/pet.dart';
import 'enhanced_dog_visual.dart';
import 'dog_visual.dart';
import 'cat_visual.dart';
import 'bird_visual.dart';
import 'rabbit_visual.dart';
import 'lion_visual.dart';
import 'giraffe_visual.dart';
import 'penguin_visual.dart';
import 'panda_visual.dart';

/// Enhanced factory class for creating pet visualizations with walking animations
class EnhancedPetVisualizationFactory {
  /// Creates a proper visualization for a pet based on its type with walking support
  static Widget createVisualization({
    required Pet pet,
    required bool isBlinking,
    required bool mouthOpen,
    required double size,
    double walkingPhase = 0.0,
    bool facingRight = true,
  }) {
    // Return the appropriate visualization widget based on the pet type
    switch (pet.type) {
      case PetType.dog:
        // Use enhanced dog visual with walking animation
        return EnhancedDogVisual(
          pet: pet,
          isBlinking: isBlinking,
          mouthOpen: mouthOpen,
          size: size,
          walkingPhase: walkingPhase,
          facingRight: facingRight,
        );
      case PetType.cat:
        // For now, use the existing cat visual (can be enhanced later)
        return Transform.scale(
          scaleX: facingRight ? 1.0 : -1.0,
          child: CatVisual(
            pet: pet,
            isBlinking: isBlinking,
            mouthOpen: mouthOpen,
            size: size,
          ),
        );
      case PetType.bird:
        return Transform.scale(
          scaleX: facingRight ? 1.0 : -1.0,
          child: BirdVisual(
            pet: pet,
            isBlinking: isBlinking,
            mouthOpen: mouthOpen,
            size: size,
          ),
        );
      case PetType.rabbit:
        return Transform.scale(
          scaleX: facingRight ? 1.0 : -1.0,
          child: RabbitVisual(
            pet: pet,
            isBlinking: isBlinking,
            mouthOpen: mouthOpen,
            size: size,
          ),
        );
      case PetType.lion:
        return Transform.scale(
          scaleX: facingRight ? 1.0 : -1.0,
          child: LionVisual(
            pet: pet,
            isBlinking: isBlinking,
            mouthOpen: mouthOpen,
            size: size,
          ),
        );
      case PetType.giraffe:
        return Transform.scale(
          scaleX: facingRight ? 1.0 : -1.0,
          child: GiraffeVisual(
            pet: pet,
            isBlinking: isBlinking,
            mouthOpen: mouthOpen,
            size: size,
          ),
        );
      case PetType.penguin:
        return Transform.scale(
          scaleX: facingRight ? 1.0 : -1.0,
          child: PenguinVisual(
            pet: pet,
            isBlinking: isBlinking,
            mouthOpen: mouthOpen,
            size: size,
          ),
        );
      case PetType.panda:
        return Transform.scale(
          scaleX: facingRight ? 1.0 : -1.0,
          child: PandaVisual(
            pet: pet,
            isBlinking: isBlinking,
            mouthOpen: mouthOpen,
            size: size,
          ),
        );
    }
  }

  /// Creates a basic visualization without walking enhancements (fallback)
  static Widget createBasicVisualization({
    required Pet pet,
    required bool isBlinking,
    required bool mouthOpen,
    required double size,
  }) {
    // Use the original factory for basic visualizations
    return PetVisualizationFactory.createVisualization(
      pet: pet,
      isBlinking: isBlinking,
      mouthOpen: mouthOpen,
      size: size,
    );
  }
}

/// Original factory class for creating pet visualizations (preserved for compatibility)
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
}