import 'dart:math' as math;
import 'dart:async';
import 'package:flutter/material.dart';
import '../models/pet.dart';
import '../models/toy.dart';
import 'pet_visualizations/pet_visualization_factory.dart';
import '../services/pet_sound_service.dart';
import '../utils/pet_anchors.dart';

/// A more advanced widget for displaying interactive pets
/// This is a simplified version to get the basic app working
class AdvancedInteractivePetWidget extends StatefulWidget {
  const AdvancedInteractivePetWidget({
    super.key,
    required this.pet,
    this.onTap,
    this.onLongPress,
  });

  final Pet pet;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  State<AdvancedInteractivePetWidget> createState() =>
      _AdvancedInteractivePetWidgetState();
}

class _AdvancedInteractivePetWidgetState
    extends State<AdvancedInteractivePetWidget>
    with TickerProviderStateMixin {
  late AnimationController _animController;
  // Breathing (subtle scale) animation
  late AnimationController _breathingController;
  late Animation<double> _breathingAnimation;
  double _petSize = 150;
  bool _isBlinking = false;
  bool _mouthOpen = false;
  late AnimationController _mouthGrabController; // squash & stretch when grabbing
  late Animation<double> _mouthGrabScale;
  Offset _petPosition = Offset.zero;

  // Interactive toy properties
  bool _isPullingToy = false;
  Offset? _userPullPosition;
  double _pullDistance = 0.0;
  bool _petHasToy = false;
  bool _showMoodBubble = false;
  // Idle micro-animations
  late AnimationController _idleMicroController;
  double _headTilt = 0.0; // target tilt radians
  bool _microActive = false;
  late AnimationController _pounceController;
  late Animation<double> _pounceAnim;
  Offset? _pounceStart;
  Offset? _pounceTarget;
  DateTime _lastPounce = DateTime.fromMillisecondsSinceEpoch(0);
  // Dynamic world bounds captured from layout
  double? _worldWidth;
  double? _worldHeight;
  // Pounce directional tilt state
  double _pounceBaseAngle = 0.0; // radians
  double _pounceTiltMagnitude = 0.0; // scales with dash distance
  late AnimationController _pounceAnticipationController; // pre-pounce lean
  // Sleep / idle tracking
  DateTime _lastActive = DateTime.now();
  DateTime _lastEnergyRegen = DateTime.now();
  static const Duration _sleepIdleThreshold = Duration(seconds: 15);
  static const int _lowEnergyThreshold = 25;
  bool get _isSleeping => widget.pet.currentActivity == PetActivity.sleeping;

  // Timers we create (instead of raw Future.delayed) so tests can dispose cleanly
  final Set<Timer> _timers = {};
  Timer? _toyTimer;
  Timer? _blinkOuterTimer;
  Timer? _blinkInnerTimer;

  void _registerTimer(Timer t) {
    _timers.add(t);
  }

  void _cancelAllTimers() {
    for (final t in _timers) {
      t.cancel();
    }
    _timers.clear();
    _toyTimer?.cancel();
    _blinkOuterTimer?.cancel();
    _blinkInnerTimer?.cancel();
  }

  void _markActive() {
    _lastActive = DateTime.now();
    if (_isSleeping) _wakeIfSleeping();
  }

  // Helper method to get appropriate icon for toy type
  IconData _getToyIcon(ToyType type) {
    switch (type) {
      case ToyType.ball:
        return Icons.sports_baseball;
      case ToyType.laserPointer:
        return Icons.control_point;
      case ToyType.bell:
        return Icons.notifications;
      case ToyType.carrot:
        return Icons.eco;
      case ToyType.rope:
        return Icons.line_weight;
      case ToyType.leaves:
        return Icons.park;
      case ToyType.slide:
        return Icons.waves;
      case ToyType.bamboo:
        return Icons.grass;
    }
  }

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _breathingAnimation = Tween<double>(begin: 0.97, end: 1.03).animate(
      CurvedAnimation(parent: _breathingController, curve: Curves.easeInOut),
    );

    // Start animation loop for blinking
    _startBlinkingAnimation();

    // Setup toy interaction timer
    _setupToyInteractionTimer();

    _scheduleMoodBubble();
    _idleMicroController =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 900),
        )..addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            _idleMicroController.reverse();
          } else if (status == AnimationStatus.dismissed) {
            _microActive = false;
            _scheduleNextMicro();
          }
        });
    _scheduleNextMicro();

    // Mouth grab animation setup
    _mouthGrabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 230),
    );
    _mouthGrabScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.9).chain(
          CurveTween(curve: Curves.easeOut),
        ),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.9, end: 1.05).chain(
          CurveTween(curve: Curves.elasticOut),
        ),
        weight: 60,
      ),
    ]).animate(_mouthGrabController);

    // Species-specific mouth movement pattern
    _scheduleNextMouthMotion();
    // Pounce controller & anticipation
    _pounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _pounceAnim = CurvedAnimation(
      parent: _pounceController,
      curve: Curves.easeOutBack, // overshoot variant (ease + overshoot)
    )..addListener(() {
        if (_pounceStart != null && _pounceTarget != null) {
          setState(() {
            _petPosition = Offset.lerp(
              _pounceStart!,
              _pounceTarget!,
              _pounceAnim.value,
            )!;
            // Directional tilt now computed dynamically in AnimatedBuilder
          });
        }
      });
    _pounceAnticipationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 110),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _pounceController.forward(from: 0);
        }
      });
  }

  // Setup a timer to update toy interactions
  void _setupToyInteractionTimer() {
    _toyTimer?.cancel();
    _toyTimer = Timer.periodic(const Duration(milliseconds: 32), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      _updateToyInteractions();
    });
  }

  // Update toy interactions
  void _updateToyInteractions() {
    if (!mounted) return;

    if (widget.pet.currentToy != null) {
      // Update toy wobble animation
      widget.pet.currentToy!.updateWobble();

      // Apply physics if toy is in motion and not held
      if (!widget.pet.currentToy!.isBeingHeldByPet &&
          !widget.pet.currentToy!.isBeingPulledByUser &&
          widget.pet.currentToy!.velocity != Offset.zero) {
        // Provide floor and walls context (simple logical bounds)
        widget.pet.currentToy!.applyPhysics();
        _handleWallCollisions();
        setState(() {}); // toy position updated
      }

      // Update mouth state based on toy interaction
      if (widget.pet.currentToy!.isBeingHeldByPet) {
        setState(() {
          _mouthOpen = true; // Keep mouth open while holding toy
        });
      }

      // Update pulling mechanics if pet has toy and user is pulling
      if (_isPullingToy && _petHasToy && _userPullPosition != null) {
        _updatePullMechanics();
      }
    }
    _evaluateSleepState();
    _maybePlayMoodSound();
    _maybePounce();
  }

  // Pet pounce logic – quick dash toward laser pointer or moving toy then decelerate
  void _maybePounce() {
    if (widget.pet.currentToy == null) return;
    final toy = widget.pet.currentToy!;
    if (toy.throwPosition == null) return;
    if (_pounceController.isAnimating || _pounceAnticipationController.isAnimating) return;

    final now = DateTime.now();
    final isLaser = toy.type == ToyType.laserPointer;
    final isMovingBall = toy.type == ToyType.ball && toy.velocity.distance > 1.2;
    if (_petHasToy || _isSleeping) return; // no pounce if holding or sleeping

    final cooldown = isLaser
        ? const Duration(milliseconds: 260)
        : (isMovingBall
            ? const Duration(milliseconds: 620)
            : const Duration(milliseconds: 520));
    if (now.difference(_lastPounce) < cooldown) return;

    final dist = (_petPosition - toy.throwPosition!).distance;
    final trigger = (isLaser && dist > _petSize * 0.30) || (isMovingBall && dist > _petSize * 0.55);
    if (!trigger) return;

    final direction = (toy.throwPosition! - _petPosition);
    if (direction == Offset.zero) return;
    final norm = direction / direction.distance;
    final dashDistance = isLaser ? _petSize * 0.38 : _petSize * 0.60;
    _pounceStart = _petPosition;
    _pounceTarget = _petPosition + norm * dashDistance;
    // Clamp target inside world (fallback if not yet sized)
    const fallbackW = 500.0;
    const fallbackH = 440.0;
    final worldW = _worldWidth ?? fallbackW;
    final worldH = _worldHeight ?? fallbackH;
    final margin = _petSize * 0.1;
    if (_pounceTarget != null) {
      final cx = _pounceTarget!.dx.clamp(margin, worldW - _petSize + margin);
      final cy = _pounceTarget!.dy.clamp(margin, worldH - _petSize);
      _pounceTarget = Offset(cx, cy);
    }
    _pounceBaseAngle = math.atan2(norm.dy, norm.dx);
    final normalized = (dashDistance / (_petSize * 0.75)).clamp(0.0, 1.0);
    _pounceTiltMagnitude = 0.35 * normalized; // up to ~0.35 rad
    _lastPounce = now;
    _pounceAnticipationController.forward(from: 0); // play anticipation then launch
  }

  void _handleWallCollisions() {
    final toy = widget.pet.currentToy;
    if (toy == null || toy.throwPosition == null) return;
  // Dynamic bounds fallback to previous hard-coded if layout not yet captured
  const double fallbackRight = 500;
  const double fallbackBottom = 440;
  const double left = 0;
  const double top = 0;
  final double right = (_worldWidth ?? fallbackRight).clamp(200, 4000).toDouble();
  final double bottom = (_worldHeight ?? fallbackBottom).clamp(200, 4000).toDouble() - 10; // margin from bottom

    var pos = toy.throwPosition!;
    var vel = toy.velocity;
    bool collided = false;

    if (pos.dx < left) {
      pos = Offset(left, pos.dy);
      vel = Offset(-vel.dx * 0.6, vel.dy * 0.92);
      collided = true;
    } else if (pos.dx > right) {
      pos = Offset(right, pos.dy);
      vel = Offset(-vel.dx * 0.6, vel.dy * 0.92);
      collided = true;
    }
    if (pos.dy < top) {
      pos = Offset(pos.dx, top);
      vel = Offset(vel.dx * 0.85, -vel.dy * 0.55);
      collided = true;
    } else if (pos.dy > bottom) {
      pos = Offset(pos.dx, bottom);
      vel = Offset(vel.dx * 0.85, -vel.dy.abs() * 0.65);
      collided = true;
    }

    if (collided) {
      toy.throwPosition = pos;
      toy.velocity = vel;
    }
  }

  // Update pull mechanics when user is pulling toy
  void _updatePullMechanics() {
    if (widget.pet.currentToy == null || _userPullPosition == null) return;

    // Calculate pull distance
    final petMouthPosition = _currentMouthPosition();
    _pullDistance = (_userPullPosition! - petMouthPosition).distance;

    // Calculate pull strength based on distance
    final normalizedStrength = (_pullDistance / 200).clamp(0.0, 1.0);
    widget.pet.currentToy!.updatePullStrength(normalizedStrength);

    // Chance for pet to release toy based on pull strength
    if (normalizedStrength > 0.7 &&
        math.Random().nextDouble() < normalizedStrength * 0.01) {
      _petReleaseToy();
    }

    // Make pet "fight back" by moving toward the toy
    if (_petHasToy && widget.pet.currentToy!.isBeingHeldByPet) {
      setState(() {
        // Move pet slightly toward the user's pull position
        final moveVector = (_userPullPosition! - petMouthPosition) * 0.01;
        _petPosition = _petPosition + moveVector;
      });
    }
    _markActive();
  }

  // Pet releases the toy
  void _petReleaseToy() {
    setState(() {
      _petHasToy = false;
      _mouthOpen = false;
      if (widget.pet.currentToy != null) {
        widget.pet.currentToy!.releaseByPet();
      }
    });
    _markActive();
  }

  // Helper method for pet grabbing toy
  void _petGrabToy() {
    setState(() {
      _petHasToy = true;
      _mouthOpen = true;
      if (widget.pet.currentToy != null) {
        widget.pet.currentToy!.grabByPet();

        // Add a random chance for the pet to start tugging or playing with the toy
        if (math.Random().nextDouble() < 0.3) {
          // Pet might start tugging the toy around
          _startPetToyTugging();
        }
      }
    });
    _mouthGrabController.forward(from: 0); // trigger squash & stretch
    _markActive();
  }

  // Schedule species-specific mouth motions to create unique idle animations per pet
  void _scheduleNextMouthMotion() {
    // Avoid scheduling if widget disposed
    if (!mounted) return;

    // If pet is sleeping keep mouth closed and retry later
    if (_isSleeping) {
      final t = Timer(const Duration(seconds: 3), _scheduleNextMouthMotion);
      _registerTimer(t);
      return;
    }

    // If actively holding toy or eating, maintain open state and reschedule
    final isOverridden = _petHasToy || widget.pet.currentActivity == PetActivity.eating;
    if (isOverridden) {
      setState(() => _mouthOpen = true);
      final t = Timer(const Duration(milliseconds: 900), _scheduleNextMouthMotion);
      _registerTimer(t);
      return;
    }

    Duration nextDelay = const Duration(seconds: 2);
    bool toggleNow = false;
    bool setOpenMomentarily = false;
    int burstTotal = 0;
    Duration burstInterval = const Duration(milliseconds: 120);

    // Species patterns
    switch (widget.pet.type) {
      case PetType.dog: // Panting cycle
        toggleNow = true;
        nextDelay = Duration(milliseconds: 350 + math.Random().nextInt(200));
        break;
      case PetType.cat: // Rare small meow
        if (!_mouthOpen && math.Random().nextDouble() < 0.25) {
          setOpenMomentarily = true;
          nextDelay = Duration(milliseconds: 180 + math.Random().nextInt(120));
        } else {
          nextDelay = Duration(seconds: 4 + math.Random().nextInt(4));
        }
        break;
      case PetType.bird: // Beak taps burst
        if (math.Random().nextDouble() < 0.35) {
          burstTotal = 3 + math.Random().nextInt(2);
          burstInterval = const Duration(milliseconds: 140);
          _runBurstMouth(burstTotal, burstInterval);
          nextDelay = Duration(seconds: 5 + math.Random().nextInt(4));
        } else {
          nextDelay = Duration(seconds: 3 + math.Random().nextInt(3));
        }
        break;
      case PetType.rabbit: // Nibble bursts
        if (math.Random().nextDouble() < 0.5) {
          burstTotal = 5 + math.Random().nextInt(3);
          burstInterval = const Duration(milliseconds: 90);
          _runBurstMouth(burstTotal, burstInterval);
          nextDelay = Duration(seconds: 4 + math.Random().nextInt(3));
        } else {
          nextDelay = Duration(seconds: 3 + math.Random().nextInt(3));
        }
        break;
      case PetType.lion: // Occasional slow yawn
        if (math.Random().nextDouble() < 0.3) {
          setState(() => _mouthOpen = true);
          final closeT = Timer(const Duration(milliseconds: 1400), () {
            if (mounted) setState(() => _mouthOpen = false);
          });
          _registerTimer(closeT);
          nextDelay = Duration(seconds: 10 + math.Random().nextInt(6));
        } else {
          nextDelay = Duration(seconds: 5 + math.Random().nextInt(5));
        }
        break;
      case PetType.giraffe: // Slow chew
        toggleNow = true;
        nextDelay = Duration(seconds: 1 + math.Random().nextInt(2));
        break;
      case PetType.penguin: // Gentle small opens
        if (!_mouthOpen) {
          setOpenMomentarily = true;
          nextDelay = const Duration(milliseconds: 260);
        } else {
          nextDelay = Duration(seconds: 2 + math.Random().nextInt(3));
        }
        break;
      case PetType.panda: // Slow munch rhythm
        toggleNow = true;
        nextDelay = Duration(milliseconds: 1200 + math.Random().nextInt(600));
        break;
    }

    if (toggleNow) {
      setState(() => _mouthOpen = !_mouthOpen);
    } else if (setOpenMomentarily) {
      setState(() => _mouthOpen = true);
      final close = Timer(const Duration(milliseconds: 200), () {
        if (mounted && !_petHasToy && widget.pet.currentActivity != PetActivity.eating) {
          setState(() => _mouthOpen = false);
        }
      });
      _registerTimer(close);
    }

    final t = Timer(nextDelay, _scheduleNextMouthMotion);
    _registerTimer(t);
  }

  void _runBurstMouth(int total, Duration interval) {
    for (int i = 0; i < total; i++) {
      final t = Timer(interval * i, () {
        if (!mounted) return;
        if (_petHasToy || widget.pet.currentActivity == PetActivity.eating) return;
        setState(() => _mouthOpen = !_mouthOpen);
      });
      _registerTimer(t);
    }
    // Ensure ends closed
    final endT = Timer(interval * total + const Duration(milliseconds: 40), () {
      if (mounted && !_petHasToy && widget.pet.currentActivity != PetActivity.eating) {
        setState(() => _mouthOpen = false);
      }
    });
    _registerTimer(endT);
  }

  // Pet starts tugging or playing with the toy
  void _startPetToyTugging() {
    if (widget.pet.currentToy == null) return;

    // Animate the pet moving slightly in random directions while holding the toy
    final t = Timer(
      Duration(milliseconds: 500 + math.Random().nextInt(1000)),
      () {
        if (!mounted) return;
        if (_petHasToy && !_isPullingToy) {
          setState(() {
            final randomOffset = Offset(
              (math.Random().nextDouble() - 0.5) * 20,
              (math.Random().nextDouble() - 0.5) * 20,
            );
            _petPosition = _petPosition + randomOffset;
            if (widget.pet.currentToy != null) {
              widget.pet.currentToy!.throwPosition = _currentMouthPosition();
            }
            if (_petHasToy && !_isPullingToy) {
              _startPetToyTugging();
            }
          });
        }
      },
    );
    _registerTimer(t);
  }

  @override
  void dispose() {
    if (_sleepLoopStarted) {
      _soundService?.stopSleepLoop(fadeOut: false);
      _sleepLoopStarted = false;
    }
    _soundService?.dispose();
    _cancelAllTimers();
    _animController.dispose();
    _breathingController.dispose();
    _idleMicroController.dispose();
    _mouthGrabController.dispose();
    _pounceController.dispose();
    _pounceAnticipationController.dispose();
    super.dispose();
  }

  void _startBlinkingAnimation() {
    _blinkOuterTimer?.cancel();
    _blinkOuterTimer = Timer(
      Duration(seconds: 2 + math.Random().nextInt(5)),
      () {
        if (!mounted) return;
        setState(() => _isBlinking = true);
        _blinkInnerTimer?.cancel();
        _blinkInnerTimer = Timer(const Duration(milliseconds: 150), () {
          if (!mounted) return;
          setState(() => _isBlinking = false);
          _startBlinkingAnimation();
        });
      },
    );
    if (_blinkOuterTimer != null) _registerTimer(_blinkOuterTimer!);
    if (_blinkInnerTimer != null) _registerTimer(_blinkInnerTimer!);
  }

  void _scheduleNextMicro() {
    final t = Timer(Duration(seconds: 4 + math.Random().nextInt(6)), () {
      if (!mounted) return;
      if (_microActive) return;
      if (widget.pet.currentActivity == PetActivity.idle) {
        _microActive = true;
        _headTilt = (math.Random().nextBool() ? 1 : -1) * 0.12;
        _idleMicroController.forward(from: 0);
      } else {
        _scheduleNextMicro();
      }
    });
    _registerTimer(t);
  }

  void _evaluateSleepState() {
    final now = DateTime.now();
    final idleTooLong = now.difference(_lastActive) > _sleepIdleThreshold;
    if (!_isSleeping && widget.pet.currentActivity == PetActivity.idle) {
      if (widget.pet.energy < _lowEnergyThreshold || idleTooLong) {
        setState(() {
          widget.pet.currentActivity = PetActivity.sleeping;
          _mouthOpen = false;
        });
      }
    }
    if (_isSleeping) {
      if (now.difference(_lastEnergyRegen).inSeconds >= 2) {
        _lastEnergyRegen = now;
        if (widget.pet.energy < 100) {
          setState(
            () => widget.pet.energy = (widget.pet.energy + 2).clamp(0, 100),
          );
        }
      }
      if (widget.pet.energy >= 95) {
        _wakeIfSleeping();
      }
    }
  }

  void _wakeIfSleeping() {
    if (_isSleeping) {
      setState(() => widget.pet.currentActivity = PetActivity.idle);
    }
    _lastActive = DateTime.now();
  }

  PetSoundService? _soundService; // lazily created when first needed
  PetMood? _lastMood;
  PetActivity? _lastActivity;
  bool _sleepLoopStarted = false;

  void _maybePlayMoodSound() {
    _soundService ??= PetSoundService(pet: widget.pet);
    if (_lastMood != widget.pet.mood) {
      _soundService!.playMoodSound();
      _lastMood = widget.pet.mood;
    }
    // Sleep transition
    if (_lastActivity != widget.pet.currentActivity) {
      if (widget.pet.currentActivity == PetActivity.sleeping) {
        if (!_sleepLoopStarted) {
          _sleepLoopStarted = true;
          _soundService!.playSleepLoop(fadeIn: true);
        }
      } else if (_lastActivity == PetActivity.sleeping) {
        if (_sleepLoopStarted) {
          _soundService!.stopSleepLoop(fadeOut: true);
          _sleepLoopStarted = false;
        }
        // On wake, play a neutral/idle or happy sound depending on mood
        _soundService!.playMoodSound(force: true);
      }
      _lastActivity = widget.pet.currentActivity;
    }
  }

  @override
  Widget build(BuildContext context) {
    final petSize = _petSize;

    // Move pet toward toy if playing with toy
    if (widget.pet.currentToy != null &&
        widget.pet.currentToy!.throwPosition != null &&
        widget.pet.currentActivity == PetActivity.playingWithToy) {
      final targetPosition = widget.pet.currentToy!.throwPosition!;

      // Simple movement calculation toward toy
      if (_petPosition != targetPosition) {
        setState(() {
          // Move toward target
          final dx = (targetPosition.dx - _petPosition.dx) * 0.1;
          final dy = (targetPosition.dy - _petPosition.dy) * 0.1;

          _petPosition = Offset(_petPosition.dx + dx, _petPosition.dy + dy);

          // Check if pet reached the toy
          final distance = (_petPosition - targetPosition).distance;
          if (distance < _petSize * 0.3 && !_petHasToy && widget.pet.currentToy?.type != ToyType.laserPointer) {
            _petGrabToy();
          }
        });
      }
    }

    // Create the visualization widget
    final baseVisualization = PetVisualizationFactory.createVisualization(
      pet: widget.pet,
      size: petSize,
      isBlinking: _isBlinking,
      mouthOpen: _mouthOpen,
    );

    final visualization = AnimatedBuilder(
      animation: Listenable.merge([
        _idleMicroController,
        _mouthGrabController,
        _pounceController,
        _pounceAnticipationController,
      ]),
      builder: (context, child) {
        final microFactor = _microActive ? _idleMicroController.value : 0.0;
        final grabScale = _mouthGrabScale.value;
        double squashX = 1.0;
        double squashY = 1.0;
        if (_pounceAnticipationController.isAnimating) {
          final a = _pounceAnticipationController.value;
          squashX *= 1 + 0.08 * a;
          squashY *= 1 - 0.08 * a;
        } else if (_pounceController.isAnimating) {
          final p = _pounceAnim.value;
          double pulse;
          if (p < 0.5) {
            pulse = p / 0.5;
          } else {
            pulse = 1 - (p - 0.5) / 0.5;
          }
          squashX *= 1 + 0.07 * pulse;
          squashY *= 1 - 0.07 * pulse;
        }
        double directionalTilt = 0.0;
        if (_pounceAnticipationController.isAnimating) {
          directionalTilt = _pounceBaseAngle * _pounceTiltMagnitude * _pounceAnticipationController.value * 1.1;
        } else if (_pounceController.isAnimating) {
          final p = _pounceAnim.value;
          directionalTilt = _pounceBaseAngle * _pounceTiltMagnitude * (1 - p);
        }
        return Transform.rotate(
          angle: _headTilt * microFactor + directionalTilt,
          alignment: Alignment.bottomCenter,
          child: Transform.scale(
            scale: grabScale,
            alignment: Alignment.center,
            child: Transform.scale(
              scaleX: squashX,
              scaleY: squashY,
              alignment: Alignment.center,
              child: child,
            ),
          ),
        );
      },
      child: baseVisualization,
    );

    // Aura dimming logic when tired or sleeping
    final isTired = widget.pet.mood == PetMood.tired && !_isSleeping;
    final auraBaseOpacity = 0.55;
    final auraOpacity = _isSleeping
        ? auraBaseOpacity *
              0.25 // dim further while sleeping
        : (isTired ? auraBaseOpacity * 0.4 : auraBaseOpacity);
  final auraColor = _moodColor(widget.pet.mood).withValues(alpha: auraOpacity);

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxW = constraints.maxWidth.isFinite ? constraints.maxWidth : null;
        final maxH = constraints.maxHeight.isFinite ? constraints.maxHeight : null;
        if (maxW != null && maxH != null && (maxW != _worldWidth || maxH != _worldHeight)) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _worldWidth = maxW;
                _worldHeight = maxH;
              });
            }
          });
        }
        return GestureDetector(
      onTap: () {
        _markActive();
        widget.onTap?.call();
      },
      onLongPress: () {
        _markActive();
        widget.onLongPress?.call();
      },
          child: Stack(
        children: [
          // The pet visualization
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            left: _petPosition.dx,
            top: _petPosition.dy,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Shadow ellipse
                Positioned(
                  left: petSize * 0.15,
                  top: petSize * 0.82,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: petSize * 0.7,
                    height: petSize * 0.18,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: _petHasToy ? 0.25 : 0.18),
                      borderRadius: BorderRadius.circular(petSize),
                    ),
                  ),
                ),
                // Breathing + visualization
                ScaleTransition(
                  scale: _breathingAnimation,
                  child: visualization,
                ),
                // Mood-based light aura
                Positioned(
                  left: -petSize * 0.15,
                  top: -petSize * 0.2,
                  child: IgnorePointer(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 700),
                      width: petSize * 1.3,
                      height: petSize * 1.3,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [auraColor, Colors.transparent],
                        ),
                      ),
                    ),
                  ),
                ),
                if (_showMoodBubble)
                  Positioned(
                    left: petSize * 0.6,
                    top: -petSize * 0.15,
                    child: _buildMoodBubble(),
                  ),
                if (_isSleeping)
                  Positioned(
                    left: petSize * 0.25,
                    top: -petSize * 0.28,
                    child: _SleepZBubble(size: petSize * 0.28),
                  ),
              ],
            ),
          ),

          // Show the toy if it's being used
          if (widget.pet.currentToy != null &&
              widget.pet.currentToy!.throwPosition != null)
            Positioned(
              left: widget.pet.currentToy!.throwPosition!.dx - (widget.pet.currentToy!.type == ToyType.rope ? 40 : 15),
              top: widget.pet.currentToy!.throwPosition!.dy - (widget.pet.currentToy!.type == ToyType.rope ? 40 : 15),
              child: GestureDetector(
                // Enable user interaction with the toy
                onPanStart: (details) {
                  setState(() {
                    _isPullingToy = true;
                    _userPullPosition = details.localPosition;
                    if (widget.pet.currentToy == null) return;
                    final toy = widget.pet.currentToy!;
                    if (toy.throwPosition == null) return;
                    if (_petHasToy || _isSleeping) return;
                    if (_pounceController.isAnimating) return;

                    final isLaser = toy.type == ToyType.laserPointer;
                    final isMovingBall = toy.type == ToyType.ball && toy.velocity.distance > 1.2;
                    final dist = (_petPosition - toy.throwPosition!).distance;
                    final now = DateTime.now();
                    final cooldown = isLaser
                        ? const Duration(milliseconds: 280)
                        : (isMovingBall
                            ? const Duration(milliseconds: 700)
                            : const Duration(milliseconds: 520));
                    if (now.difference(_lastPounce) < cooldown) return;
                    final trigger = (isLaser && dist > _petSize * 0.28) ||
                        (isMovingBall && dist > _petSize * 0.55);
                    if (!trigger) return;

                    final direction = (toy.throwPosition! - _petPosition);
                    if (direction == Offset.zero) return;
                    final norm = direction / direction.distance;
                    final dashDistance = isLaser ? _petSize * 0.34 : _petSize * 0.58;
                    _pounceStart = _petPosition;
                    _pounceTarget = _petPosition + norm * dashDistance;
                    _lastPounce = now;
                    _pounceController.forward(from: 0);
                  });
                  _markActive();
                },
                child: Transform.rotate(
                  // Apply wobble effect during tug-of-war
                  angle: widget.pet.currentToy!.wobbleAngle,
                  child: _buildToyVisual(widget.pet.currentToy!),
                ),
              ),
            ),

          // Show pet status indicators at the bottom
          Positioned(
            bottom: 20,
            left: 20,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildStatusBadge(
                  Icons.favorite,
                  widget.pet.happiness,
                  Colors.red,
                ),
                const SizedBox(width: 8),
                _buildStatusBadge(Icons.bolt, widget.pet.energy, Colors.amber),
                const SizedBox(width: 8),
                _buildStatusBadge(
                  Icons.restaurant_menu,
                  100 - widget.pet.hunger,
                  Colors.green,
                ),
                const SizedBox(width: 8),
                _buildStatusBadge(
                  Icons.wash,
                  widget.pet.cleanliness,
                  Colors.blue,
                ),
              ],
            ),
          ),
        ],
          ),
        );
      },
    );
  }

  // Absolute mouth position in the widget's coordinate space
  Offset _currentMouthPosition() {
    final rel = mouthAnchorRelative(widget.pet.type);
    return _petPosition + Offset(_petSize * rel.dx, _petSize * rel.dy);
  }

  void _scheduleMoodBubble() {
    final t = Timer(Duration(seconds: 6 + math.Random().nextInt(8)), () {
      if (!mounted) return;
      if (widget.pet.currentActivity == PetActivity.idle ||
          widget.pet.currentActivity == PetActivity.playingWithToy) {
        setState(() => _showMoodBubble = true);
        final hide = Timer(const Duration(seconds: 2), () {
          if (mounted) setState(() => _showMoodBubble = false);
        });
        _registerTimer(hide);
      }
      if (mounted) _scheduleMoodBubble();
    });
    _registerTimer(t);
  }

  Widget _buildMoodBubble() {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: _showMoodBubble ? 1 : 0,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 6,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: Icon(
          _moodIcon(widget.pet.mood),
          color: _moodColor(widget.pet.mood),
          size: 20,
        ),
      ),
    );
  }

  IconData _moodIcon(PetMood mood) {
    switch (mood) {
      case PetMood.happy:
        return Icons.tag_faces;
      case PetMood.sad:
        return Icons.sentiment_dissatisfied;
      case PetMood.excited:
        return Icons.emoji_events;
      case PetMood.tired:
        return Icons.bedtime;
      case PetMood.loving:
        return Icons.favorite;
      case PetMood.neutral:
        return Icons.sentiment_neutral;
    }
  }

  Color _moodColor(PetMood mood) {
    switch (mood) {
      case PetMood.happy:
        return Colors.orangeAccent;
      case PetMood.sad:
        return Colors.blueGrey;
      case PetMood.excited:
        return Colors.amber;
      case PetMood.tired:
        return Colors.indigo;
      case PetMood.loving:
        return Colors.pinkAccent;
      case PetMood.neutral:
        return Colors.grey;
    }
  }

  Widget _buildStatusBadge(IconData icon, int value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
  color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 4),
          Text('$value%', style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // Build visual for current toy with special cases
  Widget _buildToyVisual(Toy toy) {
    // Laser pointer: small glowing dot
    if (toy.type == ToyType.laserPointer) {
      return Container(
        width: 14,
        height: 14,
        decoration: BoxDecoration(
          color: Colors.redAccent,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.redAccent.withValues(alpha: 0.8),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
      );
    }

    // Rope: render as a long rounded rectangle behind an icon accent
    if (toy.type == ToyType.rope) {
      final base = 30.0 * toy.sizeMultiplier;
      return Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: base,
            height: base * 0.22,
            decoration: BoxDecoration(
              color: toy.color.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(base),
              boxShadow: [
                BoxShadow(
                  color: Colors.brown.withValues(alpha: 0.35),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
          ),
          Icon(Icons.line_weight, color: Colors.white, size: base * 0.3),
        ],
      );
    }

    // Default circular toy (ball / others)
    final size = 30.0 * toy.sizeMultiplier;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: toy.color,
        shape: BoxShape.circle,
        boxShadow: toy.isBeingPulledByUser
            ? [
                BoxShadow(
                  color: Colors.yellow.withValues(alpha: 0.6),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Icon(
        _getToyIcon(toy.type),
        color: Colors.white,
        size: size * 0.6,
      ),
    );
  }
}

class _SleepZBubble extends StatefulWidget {
  final double size;
  const _SleepZBubble({Key? key, required this.size}) : super(key: key);

  @override
  State<_SleepZBubble> createState() => _SleepZBubbleState();
}

class _SleepZBubbleState extends State<_SleepZBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = _controller.value; // 0..1
          // Three Z's rising at staggered intervals
          List<Widget> zWidgets = [];
          for (int i = 0; i < 3; i++) {
            final localT = (t + i * 0.33) % 1.0;
            final dy = (1 - localT) * widget.size * 0.6; // rise up
            final opacity = (1 - localT).clamp(0.0, 1.0);
            final scale = 0.6 + localT * 0.4;
            zWidgets.add(
              Positioned(
                left: (widget.size * 0.15) + i * 6,
                top: dy,
                child: Opacity(
                  opacity: opacity,
                  child: Transform.scale(
                    scale: scale,
                    child: Text(
                      'Z',
                      style: TextStyle(
                        fontSize: widget.size * 0.28,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo.withValues(alpha: 0.8),
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.25),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }
          return Stack(children: zWidgets);
        },
      ),
    );
  }
}
