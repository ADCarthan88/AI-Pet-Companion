import 'dart:math';
import 'package:flutter/material.dart';
import '../models/pet.dart';
import '../services/pet_sound_service.dart';

class PetInteractionManager {
  final Pet pet;
  final PetSoundService soundService;

  // Interaction state
  Offset _petPosition = Offset.zero;
  double _petSize = 150;

  // Movement parameters
  double _movementSpeed = 2.0; // pixels per frame
  double _movementSpeedBoost = 2.0; // multiplier for running

  // Animation state
  bool _isMoving = false;
  bool _isRunning = false;
  bool _isFacingLeft = false;

  // Target location
  Offset? _targetLocation;

  // Mouse hover tracking
  bool _isFollowingMouse = false;

  // Interaction cooldown
  DateTime _lastInteractionTime = DateTime.now();
  final int _interactionCooldown = 2000; // milliseconds

  // Mood-based movement
  final Map<PetMood, double> _moodMovementChance = {
    PetMood.happy: 0.8,
    PetMood.excited: 0.9,
    PetMood.neutral: 0.5,
    PetMood.loving: 0.7,
    PetMood.sad: 0.3,
    PetMood.tired: 0.1,
  };

  // Constructor
  PetInteractionManager({required this.pet, required this.soundService});

  // Setters
  void setPosition(Offset position) => _petPosition = position;
  void setSize(double size) => _petSize = size;

  // Getters
  Offset get position => _petPosition;
  double get size => _petSize;
  bool get isMoving => _isMoving;
  bool get isRunning => _isRunning;
  bool get isFacingLeft => _isFacingLeft;

  // Update pet position and state based on user interaction or autonomous movement
  void update() {
    _updateMovement();
    _checkRandomActions();
  }

  // Handle mouse movement for following behavior
  void handleMouseMove(Offset position) {
    // Determine if we should follow the cursor
    if (_isFollowingMouse) {
      _targetLocation = position;

      // Calculate distance to determine walk/run
      final distance = (_targetLocation! - _petPosition).distance;
      _isRunning = distance > 100;
      _isMoving = true;
    }
  }

  // Handle tap/click events
  void handleTap(Offset position) {
    // Play sound
    _playInteractionSound();

    // Move to the tapped location
    _targetLocation = position;
    _isMoving = true;
    _isRunning = false;
  }

  // Handle pet attraction to cursor
  void startFollowingMouse() {
    if (_canInteract()) {
      _isFollowingMouse = true;
      _lastInteractionTime = DateTime.now();

      // Play appropriate sound
      soundService.playSound('happy');

      // Update the pet's happiness
      if (pet.happiness < 100) {
        pet.happiness += 5;
        pet.updateState();
      }
    }
  }

  // Stop following mouse
  void stopFollowingMouse() {
    _isFollowingMouse = false;

    // Return to idle after a short delay
    Future.delayed(Duration(milliseconds: 500), () {
      if (_targetLocation == null && _isMoving) {
        _isMoving = false;
        pet.currentActivity = PetActivity.idle;
      }
    });
  }

  // Update pet movement based on target location
  void _updateMovement() {
    if (_targetLocation != null && _isMoving) {
      // Calculate direction vector to target
      final direction = _targetLocation! - _petPosition;
      final distance = direction.distance;

      // If we're close enough to the target, stop moving
      if (distance < 5) {
        _isMoving = false;
        _targetLocation = null;
        pet.currentActivity = PetActivity.idle;
        return;
      }

      // Update facing direction
      _isFacingLeft = direction.dx < 0;

      // Normalize direction and apply speed
      final normalizedDirection = Offset(
        direction.dx / distance,
        direction.dy / distance,
      );

      // Calculate speed based on running state and pet energy
      double speed = _movementSpeed;
      if (_isRunning) {
        speed *= _movementSpeedBoost;
        pet.currentActivity = PetActivity.playing;
      } else {
        pet.currentActivity =
            PetActivity.idle; // Use idle since there's no walking
      }

      // Adjust speed based on energy
      speed *= (pet.energy / 100);

      // Update position
      _petPosition = Offset(
        _petPosition.dx + normalizedDirection.dx * speed,
        _petPosition.dy + normalizedDirection.dy * speed,
      );

      // Reduce energy while moving
      if (pet.energy > 0 && Random().nextInt(30) == 0) {
        pet.energy--;
        pet.updateState();
      }
    }
  }

  // Periodically trigger random autonomous behaviors
  void _checkRandomActions() {
    // Only perform random actions when not following mouse and not moving
    if (_isFollowingMouse || _isMoving) return;

    final random = Random();

    // Chance to perform a random action based on mood
    final movementChance = _moodMovementChance[pet.mood] ?? 0.3;

    // Check for random movement
    if (random.nextDouble() < movementChance * 0.01) {
      _moveRandomly();
    }

    // Check for random licking when happy or loving
    if ((pet.mood == PetMood.happy || pet.mood == PetMood.loving) &&
        random.nextDouble() < 0.005) {
      _performLick();
    }

    // Handle other mood-specific actions
    if (pet.mood == PetMood.tired && random.nextDouble() < 0.01) {
      pet.currentActivity = PetActivity.sleeping;
      soundService.playSound('sleep');
    }
  }

  // Move to a random position on screen
  void _moveRandomly() {
    // Generate random coordinates within a reasonable range around pet
    final random = Random();
    final rangeX = random.nextDouble() * 200 - 100; // -100 to 100
    final rangeY = random.nextDouble() * 200 - 100; // -100 to 100

    _targetLocation = Offset(
      _petPosition.dx + rangeX,
      _petPosition.dy + rangeY,
    );

    _isMoving = true;
    _isRunning = false;
  }

  // Perform licking animation
  void _performLick() {
    pet.startLicking();
    soundService.playSound('happy');
  }

  // Play interaction sound based on pet state
  void _playInteractionSound() {
    if (pet.mood == PetMood.happy) {
      soundService.playSound('happy');
    } else if (pet.mood == PetMood.sad) {
      soundService.playSound('sad');
    } else if (pet.mood == PetMood.tired) {
      soundService.playSound('tired');
    } else {
      soundService.playSound('idle');
    }
  }

  // Check if we can interact (cooldown)
  bool _canInteract() {
    final now = DateTime.now();
    return now.difference(_lastInteractionTime).inMilliseconds >
        _interactionCooldown;
  }
}
