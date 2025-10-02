import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/pet.dart';
import '../models/toy.dart';
import 'pet_visualizations/pet_visualization_factory.dart';

/// A more advanced widget for displaying interactive pets
/// This is a simplified version to get the basic app working
class AdvancedInteractivePetWidget extends StatefulWidget {
  final Pet pet;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const AdvancedInteractivePetWidget({
    Key? key,
    required this.pet,
    this.onTap,
    this.onLongPress,
  }) : super(key: key);

  @override
  State<AdvancedInteractivePetWidget> createState() =>
      _AdvancedInteractivePetWidgetState();
}

class _AdvancedInteractivePetWidgetState
    extends State<AdvancedInteractivePetWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  // Breathing (subtle scale) animation
  late AnimationController _breathingController;
  late Animation<double> _breathingAnimation;
  double _petSize = 150;
  bool _isBlinking = false;
  bool _mouthOpen = false;
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

  // Helper method to get appropriate icon for toy type
  IconData _getToyIcon(ToyType type) {
    switch (type) {
      case ToyType.ball:
        return Icons.sports_baseball;
      case ToyType.laserPointer:
        return Icons.radio_button_checked;
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
    _idleMicroController = AnimationController(
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
  }

  // Setup a timer to update toy interactions
  void _setupToyInteractionTimer() {
    // Update toy interaction status every frame
    Future.delayed(const Duration(milliseconds: 16), () {
      if (mounted) {
        _updateToyInteractions();
        _setupToyInteractionTimer(); // Loop
      }
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
        widget.pet.currentToy!.applyPhysics();
        // Trigger rebuild for updated toy position
        setState(() {});
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
  }

  // Update pull mechanics when user is pulling toy
  void _updatePullMechanics() {
    if (widget.pet.currentToy == null || _userPullPosition == null) return;

    // Calculate pull distance
    final petMouthPosition =
        _petPosition +
        Offset(_petSize * 0.7, _petSize * 0.5); // Approximate mouth position
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
  }

  // Pet starts tugging or playing with the toy
  void _startPetToyTugging() {
    if (widget.pet.currentToy == null) return;

    // Animate the pet moving slightly in random directions while holding the toy
    Future.delayed(
      Duration(milliseconds: 500 + math.Random().nextInt(1000)),
      () {
        if (mounted && _petHasToy && !_isPullingToy) {
          setState(() {
            // Random movement
            final randomOffset = Offset(
              (math.Random().nextDouble() - 0.5) * 20,
              (math.Random().nextDouble() - 0.5) * 20,
            );
            _petPosition = _petPosition + randomOffset;

            // Update toy position
            if (widget.pet.currentToy != null) {
              widget.pet.currentToy!.throwPosition =
                  _petPosition + Offset(_petSize * 0.7, _petSize * 0.5);
            }

            // Continue tugging if still holding toy
            if (_petHasToy && !_isPullingToy) {
              _startPetToyTugging();
            }
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    _breathingController.dispose();
    _idleMicroController.dispose();
    super.dispose();
  }

  void _startBlinkingAnimation() {
    // Random blinking at intervals
    Future.delayed(Duration(seconds: 2 + math.Random().nextInt(5)), () {
      if (mounted) {
        setState(() {
          _isBlinking = true;
        });

        Future.delayed(const Duration(milliseconds: 150), () {
          if (mounted) {
            setState(() {
              _isBlinking = false;
            });
            _startBlinkingAnimation();
          }
        });
      }
    });
  }

  void _scheduleNextMicro() {
    Future.delayed(Duration(seconds: 4 + math.Random().nextInt(6)), () {
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
          if (distance < _petSize * 0.3 && !_petHasToy) {
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
      animation: _idleMicroController,
      builder: (context, child) {
        final factor = _microActive ? _idleMicroController.value : 0.0;
        return Transform.rotate(
          angle: _headTilt * factor,
          alignment: Alignment.bottomCenter,
          child: child,
        );
      },
      child: baseVisualization,
    );

    return GestureDetector(
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
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
                      color: Colors.black.withOpacity(
                        _petHasToy ? 0.25 : 0.18,
                      ),
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
                          colors: [
                            _moodColor(widget.pet.mood).withOpacity(0.55),
                            Colors.transparent,
                          ],
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
              ],
            ),
          ),

          // Show the toy if it's being used
          if (widget.pet.currentToy != null &&
              widget.pet.currentToy!.throwPosition != null)
            Positioned(
              left: widget.pet.currentToy!.throwPosition!.dx - 15,
              top: widget.pet.currentToy!.throwPosition!.dy - 15,
              child: GestureDetector(
                // Enable user interaction with the toy
                onPanStart: (details) {
                  setState(() {
                    _isPullingToy = true;
                    _userPullPosition = details.localPosition;
                    if (widget.pet.currentToy != null) {
                      widget.pet.currentToy!.startPulling();
                    }
                  });
                },
                onPanUpdate: (details) {
                  setState(() {
                    _userPullPosition = details.localPosition;
                  });
                },
                onPanEnd: (_) {
                  setState(() {
                    _isPullingToy = false;
                    if (widget.pet.currentToy != null) {
                      widget.pet.currentToy!.stopPulling();
                    }
                  });
                },
                child: Transform.rotate(
                  // Apply wobble effect during tug-of-war
                  angle: widget.pet.currentToy!.wobbleAngle,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: widget.pet.currentToy!.color,
                      shape: BoxShape.circle,
                      // Add a glow effect when being pulled
                      boxShadow: widget.pet.currentToy!.isBeingPulledByUser
                          ? [
                              BoxShadow(
                                color: Colors.yellow.withOpacity(0.6),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ]
                          : null,
                    ),
                    child: Icon(
                      _getToyIcon(widget.pet.currentToy!.type),
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
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
  }
  void _scheduleMoodBubble() {
    Future.delayed(Duration(seconds: 6 + math.Random().nextInt(8)), () {
      if (!mounted) return;
      // Only show when pet is idle or happy activities
      if (widget.pet.currentActivity == PetActivity.idle ||
          widget.pet.currentActivity == PetActivity.playingWithToy) {
        setState(() => _showMoodBubble = true);
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) setState(() => _showMoodBubble = false);
        });
      }
      if (mounted) _scheduleMoodBubble();
    });
  }

  Widget _buildMoodBubble() {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: _showMoodBubble ? 1 : 0,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
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
        color: Colors.white.withOpacity(0.7),
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
}
