import 'package:flutter/material.dart';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:ai_pet_companion/models/pet.dart';

// Custom Flame game component to handle pet animations
class PetAnimationManager extends FlameGame {
  final Pet pet;
  late SpriteAnimationComponent _idleAnimation;
  late SpriteAnimationComponent _walkAnimation;
  late SpriteAnimationComponent _runAnimation;
  late SpriteAnimationComponent _eatAnimation;
  late SpriteAnimationComponent _sleepAnimation;
  late SpriteAnimationComponent _playAnimation;
  late SpriteAnimationComponent _lickAnimation;

  // Current position and target position for movement
  Vector2 _currentPosition = Vector2(0, 0);
  Vector2? _targetPosition;

  // Current animation state
  PetActivity _currentActivity = PetActivity.idle;

  // Animation speed control
  double _walkSpeed = 60.0;
  double _runSpeed = 120.0;

  PetAnimationManager({required this.pet});

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Load sprite sheets
    final String petTypeStr = _getPetTypeAsString();

    try {
      // Define the sprite animations for each activity
      _idleAnimation = await _createAnimation(
        petTypeStr,
        'idle',
        frameCount: 4,
        stepTime: 0.2,
      );

      _walkAnimation = await _createAnimation(
        petTypeStr,
        'walk',
        frameCount: 6,
        stepTime: 0.1,
      );

      _runAnimation = await _createAnimation(
        petTypeStr,
        'run',
        frameCount: 6,
        stepTime: 0.07,
      );

      _eatAnimation = await _createAnimation(
        petTypeStr,
        'eat',
        frameCount: 4,
        stepTime: 0.15,
      );

      _sleepAnimation = await _createAnimation(
        petTypeStr,
        'sleep',
        frameCount: 3,
        stepTime: 0.3,
      );

      _playAnimation = await _createAnimation(
        petTypeStr,
        'play',
        frameCount: 5,
        stepTime: 0.1,
      );

      _lickAnimation = await _createAnimation(
        petTypeStr,
        'lick',
        frameCount: 4,
        stepTime: 0.1,
      );

      // Add the idle animation initially
      add(_idleAnimation);
    } catch (e) {
      debugPrint('Error loading pet animations: $e');
      // Create a fallback animation
      _createFallbackAnimations();
    }
  }

  Future<SpriteAnimationComponent> _createAnimation(
    String petType,
    String action, {
    required int frameCount,
    required double stepTime,
  }) async {
    final sprites = await Flame.images.loadAll(
      List.generate(frameCount, (i) => 'animations/$petType/${action}_$i.png'),
    );

    final animation = SpriteAnimation.spriteList(
      sprites.map((sprite) => Sprite(sprite)).toList(),
      stepTime: stepTime,
    );

    return SpriteAnimationComponent(
      animation: animation,
      size: Vector2(150, 150),
      position: _currentPosition.clone(),
    );
  }

  void _createFallbackAnimations() {
    // Create a simple colored circle as fallback
    final circleComponent = CircleComponent(
      radius: 50,
      paint: Paint()..color = pet.color,
      position: _currentPosition,
    );

    add(circleComponent);
    _idleAnimation = SpriteAnimationComponent(
      animation: SpriteAnimation.empty(stepTime: 0.1),
      size: Vector2(100, 100),
    );
    _walkAnimation = _idleAnimation;
    _runAnimation = _idleAnimation;
    _eatAnimation = _idleAnimation;
    _sleepAnimation = _idleAnimation;
    _playAnimation = _idleAnimation;
    _lickAnimation = _idleAnimation;
  }

  String _getPetTypeAsString() {
    switch (pet.type) {
      case PetType.dog:
        return 'dog';
      case PetType.cat:
        return 'cat';
      case PetType.bird:
        return 'bird';
      case PetType.rabbit:
        return 'rabbit';
      case PetType.lion:
        return 'lion';
      case PetType.giraffe:
        return 'giraffe';
      case PetType.penguin:
        return 'penguin';
      case PetType.panda:
        return 'panda';
      default:
        return 'dog';
    }
  }

  void updateActivity(PetActivity activity) {
    if (_currentActivity == activity) return;

    _currentActivity = activity;
    _updateActiveAnimation();
  }

  void _updateActiveAnimation() {
    // Remove all animations first
    _removeAllAnimations();

    // Add the appropriate animation based on activity
    switch (_currentActivity) {
      case PetActivity.idle:
        add(_idleAnimation);
        break;
      case PetActivity.walking:
        add(_walkAnimation);
        break;
      case PetActivity.running:
        add(_runAnimation);
        break;
      case PetActivity.eating:
        add(_eatAnimation);
        break;
      case PetActivity.sleeping:
        add(_sleepAnimation);
        break;
      case PetActivity.playing:
      case PetActivity.playingWithToy:
        add(_playAnimation);
        break;
      case PetActivity.licking:
        add(_lickAnimation);
        break;
      case PetActivity.beingCleaned:
      case PetActivity.beingBrushed:
        add(_idleAnimation); // Placeholder for cleaning animation
        break;
    }
  }

  void _removeAllAnimations() {
    remove(_idleAnimation);
    remove(_walkAnimation);
    remove(_runAnimation);
    remove(_eatAnimation);
    remove(_sleepAnimation);
    remove(_playAnimation);
    remove(_lickAnimation);
  }

  void moveTo(Vector2 targetPosition) {
    _targetPosition = targetPosition;

    // Calculate distance to determine if we should walk or run
    final distance = _currentPosition.distanceTo(_targetPosition!);

    if (distance > 100) {
      _currentActivity = PetActivity.running;
    } else {
      _currentActivity = PetActivity.walking;
    }

    _updateActiveAnimation();
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Update position if we have a target
    if (_targetPosition != null) {
      final Vector2 direction = _targetPosition! - _currentPosition;
      final double distance = direction.length;

      if (distance > 5) {
        // Normalize and scale by speed
        direction.normalize();
        final double speed = _currentActivity == PetActivity.running
            ? _runSpeed
            : _walkSpeed;

        _currentPosition += direction * speed * dt;

        // Update all animation positions
        _updateAllPositions();

        // Flip sprites based on direction
        final bool isFacingLeft = direction.x < 0;
        _setFlip(isFacingLeft);
      } else {
        // We've arrived at the target
        _targetPosition = null;
        _currentActivity = PetActivity.idle;
        _updateActiveAnimation();
      }
    }
  }

  void _updateAllPositions() {
    _idleAnimation.position = _currentPosition.clone();
    _walkAnimation.position = _currentPosition.clone();
    _runAnimation.position = _currentPosition.clone();
    _eatAnimation.position = _currentPosition.clone();
    _sleepAnimation.position = _currentPosition.clone();
    _playAnimation.position = _currentPosition.clone();
    _lickAnimation.position = _currentPosition.clone();
  }

  void _setFlip(bool isFacingLeft) {
    _idleAnimation.flipHorizontally = isFacingLeft;
    _walkAnimation.flipHorizontally = isFacingLeft;
    _runAnimation.flipHorizontally = isFacingLeft;
    _eatAnimation.flipHorizontally = isFacingLeft;
    _sleepAnimation.flipHorizontally = isFacingLeft;
    _playAnimation.flipHorizontally = isFacingLeft;
    _lickAnimation.flipHorizontally = isFacingLeft;
  }
}

// Extension to add walking and running activities
extension PetActivityExtension on PetActivity {
  static const walking = PetActivity.playing;
  static const running = PetActivity.playingWithToy;
}
