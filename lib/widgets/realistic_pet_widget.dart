import 'package:flutter/material.dart';
import 'dart:async';
import '../models/pet.dart';
import '../services/natural_movement_engine.dart';
import 'realistic_animal_renderer.dart';

class RealisticPetWidget extends StatefulWidget {
  final Pet pet;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const RealisticPetWidget({
    super.key,
    required this.pet,
    this.onTap,
    this.onLongPress,
  });

  @override
  State<RealisticPetWidget> createState() => _RealisticPetWidgetState();
}

class _RealisticPetWidgetState extends State<RealisticPetWidget>
    with TickerProviderStateMixin {
  late NaturalMovementEngine _movementEngine;
  late AnimationController _blinkController;
  late AnimationController _breathingController;
  Timer? _blinkTimer;
  Timer? _updateTimer;
  
  bool _isBlinking = false;
  bool _mouthOpen = false;
  double _petSize = 120.0;

  @override
  void initState() {
    super.initState();
    
    _movementEngine = NaturalMovementEngine(pet: widget.pet);
    
    _blinkController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    _breathingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    
    _startBlinking();
    _startMouthMovement();
    _startUpdates();
  }

  @override
  void dispose() {
    _movementEngine.dispose();
    _blinkController.dispose();
    _breathingController.dispose();
    _blinkTimer?.cancel();
    _updateTimer?.cancel();
    super.dispose();
  }

  void _startBlinking() {
    _scheduleNextBlink();
  }

  void _scheduleNextBlink() {
    final delay = Duration(seconds: 2 + (DateTime.now().millisecond % 4));
    _blinkTimer = Timer(delay, () {
      if (mounted) {
        setState(() => _isBlinking = true);
        _blinkController.forward().then((_) {
          _blinkController.reverse().then((_) {
            if (mounted) {
              setState(() => _isBlinking = false);
              _scheduleNextBlink();
            }
          });
        });
      }
    });
  }

  void _startMouthMovement() {
    Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      
      // Mouth movement based on pet type and activity
      bool shouldOpenMouth = false;
      
      switch (widget.pet.type) {
        case PetType.dog:
          // Dogs pant when happy or energetic
          shouldOpenMouth = widget.pet.mood == PetMood.happy || 
                           widget.pet.mood == PetMood.excited ||
                           widget.pet.energy > 70;
          break;
        case PetType.cat:
          // Cats meow occasionally
          shouldOpenMouth = DateTime.now().second % 8 == 0;
          break;
        case PetType.bird:
          // Birds chirp more frequently
          shouldOpenMouth = DateTime.now().second % 4 == 0;
          break;
        default:
          shouldOpenMouth = DateTime.now().second % 6 == 0;
      }
      
      if (shouldOpenMouth != _mouthOpen) {
        setState(() => _mouthOpen = shouldOpenMouth);
      }
    });
  }

  void _startUpdates() {
    _updateTimer = Timer.periodic(
      const Duration(milliseconds: 100),
      (_) => _updatePetState(),
    );
  }

  void _updatePetState() {
    if (mounted) {
      setState(() {
        // Update movement engine position
        _movementEngine.setPosition(_getCurrentScreenPosition());
      });
    }
  }

  Offset _getCurrentScreenPosition() {
    // Get current position from movement engine
    return _movementEngine.currentPosition;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _movementEngine.setBounds(constraints.biggest);
        
        return Stack(
          children: [
            // Pet shadow
            Positioned(
              left: _movementEngine.currentPosition.dx - _petSize / 2 + 10,
              top: _movementEngine.currentPosition.dy + _petSize / 2 - 10,
              child: Container(
                width: _petSize * 0.8,
                height: _petSize * 0.2,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(_petSize),
                ),
              ),
            ),
            
            // Main pet widget
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              left: _movementEngine.currentPosition.dx - _petSize / 2,
              top: _movementEngine.currentPosition.dy - _petSize / 2,
              child: GestureDetector(
                onTap: widget.onTap,
                onLongPress: widget.onLongPress,
                child: Transform.translate(
                  offset: Offset(0, _movementEngine.bodySway * 5),
                  child: RealisticAnimalRenderer(
                    pet: widget.pet,
                    size: _petSize,
                    isBlinking: _isBlinking,
                    mouthOpen: _mouthOpen,
                    walkingPhase: _movementEngine.walkingPhase,
                    facingRight: _movementEngine.isMoving ? 
                        _movementEngine.currentPosition.dx < _movementEngine.currentPosition.dx : true,
                  ),
                ),
              ),
            ),
            
            // Mood indicator
            if (widget.pet.mood != PetMood.neutral)
              Positioned(
                left: _movementEngine.currentPosition.dx - 15,
                top: _movementEngine.currentPosition.dy - _petSize / 2 - 20,
                child: _buildMoodIndicator(),
              ),
            
            // Activity indicator
            if (_movementEngine.currentBehavior != 'idle')
              Positioned(
                left: _movementEngine.currentPosition.dx + 15,
                top: _movementEngine.currentPosition.dy - _petSize / 2 - 20,
                child: _buildActivityIndicator(),
              ),
          ],
        );
      },
    );
  }

  Widget _buildMoodIndicator() {
    IconData icon;
    Color color;
    
    switch (widget.pet.mood) {
      case PetMood.happy:
        icon = Icons.sentiment_satisfied;
        color = Colors.yellow;
        break;
      case PetMood.excited:
        icon = Icons.sentiment_very_satisfied;
        color = Colors.orange;
        break;
      case PetMood.loving:
        icon = Icons.favorite;
        color = Colors.pink;
        break;
      case PetMood.sad:
        icon = Icons.sentiment_dissatisfied;
        color = Colors.blue;
        break;
      case PetMood.tired:
        icon = Icons.bedtime;
        color = Colors.purple;
        break;
      default:
        return const SizedBox.shrink();
    }
    
    return AnimatedOpacity(
      opacity: 0.8,
      duration: const Duration(milliseconds: 300),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: color, size: 16),
      ),
    );
  }

  Widget _buildActivityIndicator() {
    IconData icon;
    Color color;
    
    switch (_movementEngine.currentBehavior) {
      case 'exploring':
        icon = Icons.explore;
        color = Colors.green;
        break;
      case 'playing':
        icon = Icons.sports_esports;
        color = Colors.red;
        break;
      case 'alert':
        icon = Icons.visibility;
        color = Colors.amber;
        break;
      case 'resting':
        icon = Icons.hotel;
        color = Colors.indigo;
        break;
      default:
        return const SizedBox.shrink();
    }
    
    return AnimatedOpacity(
      opacity: 0.7,
      duration: const Duration(milliseconds: 300),
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Icon(icon, color: color, size: 12),
      ),
    );
  }
}