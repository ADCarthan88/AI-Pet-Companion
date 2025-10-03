import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/pet.dart';

class PetBehaviorService {
  final Pet pet;

  // Properties for tracking pet behavior state
  bool isFollowingCursor = false;
  bool isPlayingAnimation = false;
  double moodFactor = 1.0; // Modifies behavior based on mood
  double energyFactor = 1.0; // Modifies behavior based on energy

  // Animation state
  String currentAnimationState = 'idle';
  double currentDirection = 1.0; // 1.0 = right, -1.0 = left

  // Movement parameters
  double movementSpeed = 1.0;
  double maxSpeed = 5.0;
  double minDistanceToTarget = 10.0;
  double maxFollowDistance = 300.0;
  double wanderRadius = 100.0;

  // Behavior timing parameters
  DateTime lastMoodChange = DateTime.now();
  DateTime lastRandomAction = DateTime.now();
  DateTime lastSound = DateTime.now();

  PetBehaviorService({required this.pet}) {
    _initializeFactors();
  }

  void _initializeFactors() {
    // Set behavior factors based on pet attributes
    updateMoodFactor();
    updateEnergyFactor();
  }

  void updateMoodFactor() {
    switch (pet.mood) {
      case PetMood.happy:
        moodFactor = 1.2; // More active and responsive
        return;
      case PetMood.sad:
        moodFactor = 0.7; // Less active, slower movements
        return;
      case PetMood.excited:
        moodFactor = 1.5; // Very active, faster movements
        return;
      case PetMood.tired:
        moodFactor = 0.5; // Very slow, minimal movements
        return;
      case PetMood.loving:
        moodFactor = 1.3; // More likely to follow cursor
        return;
      case PetMood.neutral:
        moodFactor = 1.0; // Normal behavior
        return;
    }
  }

  void updateEnergyFactor() {
    // Scale the energy factor based on pet's energy level (0-100)
    energyFactor = 0.5 + (pet.energy / 100.0);

    // Cap the speed based on energy
    maxSpeed = 2.0 + (pet.energy / 20.0);
  }

  // Calculate movement towards a target point
  Offset calculateMovement(Offset currentPosition, Offset targetPosition) {
    final dx = targetPosition.dx - currentPosition.dx;
    final dy = targetPosition.dy - currentPosition.dy;
    final distance = math.sqrt(dx * dx + dy * dy);

    // Update direction facing
    if (dx.abs() > 5) {
      currentDirection = dx > 0 ? 1.0 : -1.0;
    }

    // Determine if we should move
    if (distance < minDistanceToTarget) {
      return currentPosition; // Stay in place if close enough
    }

    // Calculate speed based on distance, mood, and energy
    final speed = math.min(
      maxSpeed,
      distance / 40.0 * moodFactor * energyFactor,
    );

    // Return new position with easing
    return Offset(
      currentPosition.dx + (dx * speed / distance),
      currentPosition.dy + (dy * speed / distance),
    );
  }

  // Determine if pet should follow cursor based on mood and energy
  bool shouldFollowCursor() {
    if (pet.energy < 20) return false; // Too tired to follow
    if (pet.currentActivity == PetActivity.sleeping) return false; // Sleeping

    // Probability based on mood and energy
    final baseProbability = 0.7; // Base chance to follow
    final moodModifier = pet.mood == PetMood.loving
        ? 0.3
        : pet.mood == PetMood.sad
        ? -0.3
        : 0.0;
    final energyModifier = (pet.energy - 50) / 100; // -0.5 to 0.5

    final followProbability = (baseProbability + moodModifier + energyModifier)
        .clamp(0.2, 0.95);

    return math.Random().nextDouble() < followProbability;
  }

  // Generate a random position for autonomous movement
  Offset getWanderTarget(Offset currentPosition, Size containerSize) {
    final boundaryPadding = 50.0;

    // Respect the container boundaries
    final maxX = containerSize.width - boundaryPadding;
    final maxY = containerSize.height - boundaryPadding;
    final minX = boundaryPadding;
    final minY = boundaryPadding;

    // Random offset within wanderRadius
    final randomAngle = math.Random().nextDouble() * 2 * math.pi;
    final randomDistance = math.Random().nextDouble() * wanderRadius;

    // Calculate new target position
    double newX = currentPosition.dx + math.cos(randomAngle) * randomDistance;
    double newY = currentPosition.dy + math.sin(randomAngle) * randomDistance;

    // Ensure target is within bounds
    newX = newX.clamp(minX, maxX);
    newY = newY.clamp(minY, maxY);

    return Offset(newX, newY);
  }

  // Determine if pet should make a sound
  bool shouldMakeSound() {
    // Don't make sounds too often
    final now = DateTime.now();
    if (now.difference(lastSound).inSeconds < 5) return false;

    // Probability based on mood
    final probability = pet.mood == PetMood.happy || pet.mood == PetMood.excited
        ? 0.3
        : pet.mood == PetMood.loving
        ? 0.4
        : 0.1;

    if (math.Random().nextDouble() < probability) {
      lastSound = now;
      return true;
    }
    return false;
  }

  // Return a suitable animation state based on pet's activity and mood
  String getAnimationState() {
    switch (pet.currentActivity) {
      case PetActivity.idle:
        if (shouldPlayIdleVariant()) {
          return pet.mood == PetMood.happy
              ? 'idle_happy'
              : pet.mood == PetMood.sad
                  ? 'idle_sad'
                  : 'idle_variant';
        }
        return 'idle';
      case PetActivity.playing:
      case PetActivity.playingWithToy:
        return 'play';
      case PetActivity.sleeping:
        return 'sleep';
      case PetActivity.eating:
        return 'eat';
      case PetActivity.licking:
        return 'lick';
      case PetActivity.beingCleaned:
        return 'clean';
      case PetActivity.beingBrushed:
        return 'brush';
    }
  }

  // Decide if we should play an idle variant based on mood and randomness
  bool shouldPlayIdleVariant() {
    final now = DateTime.now();
    if (now.difference(lastRandomAction).inSeconds < 3) return false;

    final probability = pet.mood == PetMood.happy
        ? 0.3
        : pet.mood == PetMood.loving
        ? 0.4
        : pet.mood == PetMood.excited
        ? 0.5
        : 0.1;

    if (math.Random().nextDouble() < probability) {
      lastRandomAction = now;
      return true;
    }
    return false;
  }

  // Update the pet's behavior state
  void update() {
    updateMoodFactor();
    updateEnergyFactor();

    // Randomly trigger idle animations
    if (pet.currentActivity == PetActivity.idle) {
      shouldPlayIdleVariant();
    }

    // Check for sound opportunity
    if (shouldMakeSound()) {
      // The sound will be played by the pet sound service
    }
  }
}
