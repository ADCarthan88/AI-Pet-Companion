import 'dart:math' as math;
import 'dart:async';
import 'package:flutter/material.dart';
import '../models/pet.dart';

class NaturalMovementEngine {
  final Pet pet;
  Timer? _movementTimer;
  
  // Movement state
  Offset _currentPosition = Offset.zero;
  Offset _targetPosition = Offset.zero;
  bool _isMoving = false;
  double _movementSpeed = 1.0;
  
  // Natural behavior patterns
  String _currentBehavior = 'idle';
  DateTime _behaviorStartTime = DateTime.now();
  final Map<String, Duration> _behaviorDurations = {
    'idle': Duration(seconds: 8),
    'exploring': Duration(seconds: 12),
    'resting': Duration(seconds: 15),
    'alert': Duration(seconds: 5),
    'playing': Duration(seconds: 10),
  };
  
  // Realistic movement patterns
  final Map<PetType, Map<String, dynamic>> _movementPatterns = {};

  NaturalMovementEngine({required this.pet}) {
    _initializeMovementPatterns();
    _startMovementEngine();
  }

  void _initializeMovementPatterns() {
    _movementPatterns[PetType.dog] = {
      'walk_speed': 2.0,
      'run_speed': 4.0,
      'step_frequency': 0.8,
      'body_sway': 0.1,
      'tail_wag_frequency': 1.2,
      'preferred_activities': ['exploring', 'playing', 'alert'],
    };
    
    _movementPatterns[PetType.cat] = {
      'walk_speed': 1.5,
      'run_speed': 3.5,
      'step_frequency': 0.6,
      'body_sway': 0.05,
      'tail_wag_frequency': 0.3,
      'preferred_activities': ['resting', 'exploring', 'alert'],
    };
    
    _movementPatterns[PetType.bird] = {
      'walk_speed': 1.0,
      'run_speed': 2.0,
      'step_frequency': 1.5,
      'body_sway': 0.15,
      'tail_wag_frequency': 0.0,
      'preferred_activities': ['exploring', 'playing', 'alert'],
    };
  }

  void _startMovementEngine() {
    _movementTimer = Timer.periodic(
      const Duration(milliseconds: 50),
      (_) => _updateMovement(),
    );
  }

  void _updateMovement() {
    _updateBehavior();
    _updatePosition();
    _updateMovementSpeed();
  }

  void _updateBehavior() {
    final now = DateTime.now();
    final timeSinceBehaviorStart = now.difference(_behaviorStartTime);
    final currentDuration = _behaviorDurations[_currentBehavior] ?? Duration(seconds: 5);
    
    if (timeSinceBehaviorStart >= currentDuration) {
      _selectNewBehavior();
    }
  }

  void _selectNewBehavior() {
    final patterns = _movementPatterns[pet.type] ?? _movementPatterns[PetType.dog]!;
    final preferredActivities = patterns['preferred_activities'] as List<String>;
    
    // Weight behaviors based on pet state
    final behaviorWeights = <String, double>{};
    
    // Base weights
    behaviorWeights['idle'] = 0.3;
    behaviorWeights['exploring'] = 0.2;
    behaviorWeights['resting'] = 0.2;
    behaviorWeights['alert'] = 0.1;
    behaviorWeights['playing'] = 0.2;
    
    // Adjust based on pet state
    if (pet.energy < 30) {
      behaviorWeights['resting'] = (behaviorWeights['resting']! * 3).clamp(0, 1);
      behaviorWeights['playing'] = (behaviorWeights['playing']! * 0.2).clamp(0, 1);
    } else if (pet.energy > 80) {
      behaviorWeights['playing'] = (behaviorWeights['playing']! * 2).clamp(0, 1);
      behaviorWeights['exploring'] = (behaviorWeights['exploring']! * 1.5).clamp(0, 1);
    }
    
    if (pet.mood == PetMood.excited) {
      behaviorWeights['playing'] = (behaviorWeights['playing']! * 2).clamp(0, 1);
      behaviorWeights['alert'] = (behaviorWeights['alert']! * 1.5).clamp(0, 1);
    } else if (pet.mood == PetMood.tired) {
      behaviorWeights['resting'] = (behaviorWeights['resting']! * 2.5).clamp(0, 1);
    }
    
    // Prefer species-specific behaviors
    for (final activity in preferredActivities) {
      if (behaviorWeights.containsKey(activity)) {
        behaviorWeights[activity] = (behaviorWeights[activity]! * 1.3).clamp(0, 1);
      }
    }
    
    _currentBehavior = _selectWeightedBehavior(behaviorWeights);
    _behaviorStartTime = DateTime.now();
    
    print('🚶 Movement Behavior: $_currentBehavior');
    _applyBehaviorEffects();
  }

  String _selectWeightedBehavior(Map<String, double> weights) {
    final totalWeight = weights.values.fold(0.0, (sum, weight) => sum + weight);
    final random = math.Random().nextDouble() * totalWeight;
    
    double currentWeight = 0.0;
    for (final entry in weights.entries) {
      currentWeight += entry.value;
      if (random <= currentWeight) {
        return entry.key;
      }
    }
    
    return 'idle';
  }

  void _applyBehaviorEffects() {
    switch (_currentBehavior) {
      case 'exploring':
        _setRandomTarget();
        _isMoving = true;
        break;
      case 'playing':
        _setRandomTarget();
        _isMoving = true;
        _movementSpeed = 1.5;
        break;
      case 'alert':
        _isMoving = false;
        break;
      case 'resting':
        _isMoving = false;
        break;
      case 'idle':
        if (math.Random().nextDouble() < 0.3) {
          _setNearbyTarget();
          _isMoving = true;
        } else {
          _isMoving = false;
        }
        break;
    }
  }

  void _setRandomTarget() {
    final bounds = Size(400, 300); // Default bounds
    final margin = 50.0;
    
    _targetPosition = Offset(
      margin + math.Random().nextDouble() * (bounds.width - 2 * margin),
      margin + math.Random().nextDouble() * (bounds.height - 2 * margin),
    );
  }

  void _setNearbyTarget() {
    final maxDistance = 80.0;
    final angle = math.Random().nextDouble() * 2 * math.pi;
    final distance = math.Random().nextDouble() * maxDistance;
    
    _targetPosition = _currentPosition + Offset(
      math.cos(angle) * distance,
      math.sin(angle) * distance,
    );
  }

  void _updatePosition() {
    if (!_isMoving) return;
    
    final distance = (_targetPosition - _currentPosition).distance;
    if (distance < 5.0) {
      _isMoving = false;
      return;
    }
    
    final direction = (_targetPosition - _currentPosition) / distance;
    final patterns = _movementPatterns[pet.type] ?? _movementPatterns[PetType.dog]!;
    final baseSpeed = patterns['walk_speed'] as double;
    
    final moveStep = direction * baseSpeed * _movementSpeed;
    _currentPosition += moveStep;
  }

  void _updateMovementSpeed() {
    final patterns = _movementPatterns[pet.type] ?? _movementPatterns[PetType.dog]!;
    final baseSpeed = patterns['walk_speed'] as double;
    
    switch (_currentBehavior) {
      case 'playing':
        _movementSpeed = (patterns['run_speed'] as double) / baseSpeed;
        break;
      case 'exploring':
        _movementSpeed = 1.2;
        break;
      case 'alert':
        _movementSpeed = 0.5;
        break;
      default:
        _movementSpeed = 1.0;
    }
    
    // Adjust for pet energy
    final energyFactor = (pet.energy / 100.0).clamp(0.3, 1.0);
    _movementSpeed *= energyFactor;
  }

  // Getters for animation system
  Offset get currentPosition => _currentPosition;
  bool get isMoving => _isMoving;
  String get currentBehavior => _currentBehavior;
  double get movementSpeed => _movementSpeed;
  
  // Get walking phase for animation
  double get walkingPhase {
    if (!_isMoving) return 0.0;
    
    final patterns = _movementPatterns[pet.type] ?? _movementPatterns[PetType.dog]!;
    final frequency = patterns['step_frequency'] as double;
    final time = DateTime.now().millisecondsSinceEpoch / 1000.0;
    
    return (time * frequency * _movementSpeed) % 1.0;
  }
  
  // Get body sway for realistic movement
  double get bodySway {
    if (!_isMoving) return 0.0;
    
    final patterns = _movementPatterns[pet.type] ?? _movementPatterns[PetType.dog]!;
    final swayAmount = patterns['body_sway'] as double;
    
    return math.sin(walkingPhase * 2 * math.pi) * swayAmount;
  }
  
  // Get tail movement
  double get tailMovement {
    final patterns = _movementPatterns[pet.type] ?? _movementPatterns[PetType.dog]!;
    final frequency = patterns['tail_wag_frequency'] as double;
    
    if (frequency == 0.0) return 0.0;
    
    final time = DateTime.now().millisecondsSinceEpoch / 1000.0;
    double baseMovement = math.sin(time * frequency * 2 * math.pi);
    
    // Adjust tail movement based on mood
    switch (pet.mood) {
      case PetMood.happy:
      case PetMood.excited:
        return baseMovement * 1.5;
      case PetMood.loving:
        return baseMovement * 1.2;
      case PetMood.sad:
        return baseMovement * 0.3;
      case PetMood.tired:
        return baseMovement * 0.1;
      default:
        return baseMovement;
    }
  }

  void setPosition(Offset position) {
    _currentPosition = position;
  }

  void setBounds(Size bounds) {
    // Update movement bounds for target selection
  }

  void dispose() {
    _movementTimer?.cancel();
  }
}