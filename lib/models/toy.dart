import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'pet.dart';

enum ToyType {
  ball, // For dogs
  laserPointer, // For cats
  bell, // For birds
  carrot, // For rabbits
  rope, // For lions
  leaves, // For giraffes
  slide, // For penguins
  bamboo, // For pandas
}

class Toy {
  final ToyType type;
  final String name;
  final Color color;
  final List<PetType> suitableFor;
  bool isInUse;
  Offset? throwPosition; // Position where the toy was thrown

  // Interactive play properties
  bool isBeingHeldByPet = false;
  bool isBeingPulledByUser = false;
  double pullStrength = 0.0; // 0.0 to 1.0, representing pull strength
  double wobbleAngle = 0.0; // For animating toy wobbling during tug-of-war
  Offset velocity = Offset.zero; // Basic physics velocity
  // Extended behavior properties
  final double elasticity; // For bouncing (ball)
  final double sizeMultiplier; // For visual scaling (rope etc.)
  final bool isChaseTarget; // For laser pointer style toys

  // Internal timestamp for physics (optional future use)
  DateTime _lastUpdate = DateTime.now();

  Toy({
    required this.type,
    required this.name,
    required this.color,
    required this.suitableFor,
    this.isInUse = false,
    this.throwPosition,
    this.elasticity = 0.0,
    this.sizeMultiplier = 1.0,
    this.isChaseTarget = false,
  });

  // Methods for interactive play
  void startPulling() {
    isBeingPulledByUser = true;
    pullStrength = 0.3; // Start with a moderate pull strength
  }

  void updatePullStrength(double strength) {
    pullStrength = strength.clamp(0.0, 1.0);
  }

  void stopPulling() {
    isBeingPulledByUser = false;
    pullStrength = 0.0;
  }

  void grabByPet() {
    isBeingHeldByPet = true;
  }

  void releaseByPet() {
    isBeingHeldByPet = false;
  }

  // Calculate a wobble effect for tug of war animation
  void updateWobble() {
    if (isBeingPulledByUser && isBeingHeldByPet) {
      wobbleAngle =
          math.sin(DateTime.now().millisecondsSinceEpoch / 100) *
          0.2 *
          pullStrength;
    } else {
      wobbleAngle = 0.0;
    }
  }

  void applyPhysics({double? floorY}) {
    if (throwPosition == null) return;
    final now = DateTime.now();
    final dtMs = now.difference(_lastUpdate).inMilliseconds.clamp(1, 40);
    _lastUpdate = now;
    final dt = dtMs / 16.0; // relative step (16ms baseline)

    // Apply gravity (simple)
    velocity = Offset(velocity.dx * math.pow(0.94, dt).toDouble(),
        velocity.dy * math.pow(0.94, dt).toDouble() + 0.18 * dt);

    var nextPos = throwPosition! + velocity;
    final ground = floorY ?? 420.0; // fallback floor

    // Bounce for ball only
    if (type == ToyType.ball && nextPos.dy >= ground) {
      nextPos = Offset(nextPos.dx, ground);
      if (velocity.dy > 0) {
        final newVy = -velocity.dy * (elasticity > 0 ? elasticity : 0.65);
        velocity = Offset(velocity.dx * 0.82, newVy);
        // Stop if minimal bounce left
        if (newVy.abs() < 0.9) {
          velocity = Offset.zero;
        }
      }
    }
    // Horizontal slow down if nearly resting
    if (velocity.dy.abs() < 0.2) {
      velocity = Offset(velocity.dx * 0.9, velocity.dy);
      if (velocity.distance < 0.05) velocity = Offset.zero;
    }
    throwPosition = nextPos;
  }

  static List<Toy> getToysForPetType(PetType petType) {
    switch (petType) {
      case PetType.dog:
        return [
          Toy(
            type: ToyType.ball,
            name: 'Bouncy Ball',
            color: Colors.red,
            suitableFor: [PetType.dog],
            elasticity: 0.68,
          ),
        ];
      case PetType.cat:
        return [
          Toy(
            type: ToyType.laserPointer,
            name: 'Laser Pointer',
            color: Colors.red,
            suitableFor: [PetType.cat],
            isChaseTarget: true,
            sizeMultiplier: 0.4,
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
      case PetType.lion:
        return [
          Toy(
            type: ToyType.rope,
            name: 'Giant Rope',
            color: Colors.brown,
            suitableFor: [PetType.lion],
            sizeMultiplier: 6.0,
          ),
        ];
      case PetType.giraffe:
        return [
          Toy(
            type: ToyType.leaves,
            name: 'Acacia Leaves',
            color: Colors.green,
            suitableFor: [PetType.giraffe],
          ),
        ];
      case PetType.penguin:
        return [
          Toy(
            type: ToyType.slide,
            name: 'Ice Slide',
            color: Colors.lightBlue,
            suitableFor: [PetType.penguin],
          ),
        ];
      case PetType.panda:
        return [
          Toy(
            type: ToyType.bamboo,
            name: 'Bamboo Stick',
            color: Colors.lightGreen,
            suitableFor: [PetType.panda],
          ),
        ];
    }
  }
}
