import 'package:flutter/material.dart';
import '../models/pet.dart';

/// Provides relative anchor points (0..1 in each axis) for various pet features.
/// Currently only exposes the mouth anchor; can be extended for eyes, ears, etc.
Offset mouthAnchorRelative(PetType type) {
  // Tuned anchors: horizontally centered; vertical adjusted for better bite alignment
  switch (type) {
    case PetType.dog:
      return const Offset(0.50, 0.535);
    case PetType.cat:
      return const Offset(0.50, 0.515);
    case PetType.bird:
      return const Offset(0.50, 0.43); // beak slightly higher
    case PetType.rabbit:
      return const Offset(0.50, 0.565);
    case PetType.lion:
      return const Offset(0.50, 0.525);
    case PetType.giraffe:
      return const Offset(0.50, 0.595); // longer neck lowers mouth area
    case PetType.penguin:
      return const Offset(0.50, 0.455);
    case PetType.panda:
      return const Offset(0.50, 0.535);
  }
}
