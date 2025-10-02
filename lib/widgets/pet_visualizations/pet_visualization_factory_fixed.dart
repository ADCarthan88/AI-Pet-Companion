import 'package:flutter/material.dart';
import '../../models/pet.dart';

/// A simplified factory class for creating pet visualizations
class PetVisualizationFactory {
  /// Creates a basic visualization for a pet
  static Widget createVisualization({
    required Pet pet,
    required bool isBlinking,
    required bool mouthOpen,
    required double size,
  }) {
    // Basic pet visualization with a colored circle and icon
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: pet.color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 10, spreadRadius: 2),
        ],
      ),
      child: Center(
        child: Icon(
          _getPetTypeIcon(pet.type),
          color: Colors.white,
          size: size * 0.6,
        ),
      ),
    );
  }

  static IconData _getPetTypeIcon(PetType type) {
    switch (type) {
      case PetType.dog:
        return Icons.pets;
      case PetType.cat:
        return Icons.content_cut;
      case PetType.bird:
        return Icons.flutter_dash;
      case PetType.rabbit:
        return Icons.cruelty_free;
      case PetType.lion:
        return Icons.assured_workload;
      case PetType.giraffe:
        return Icons.height;
      case PetType.penguin:
        return Icons.ac_unit;
      case PetType.panda:
        return Icons.nature;
    }
  }
}
