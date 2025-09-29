import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/pet.dart';
import '../services/pet_sound_service.dart';
import '../services/pet_behavior_service.dart';
import 'pet_emotion_helper.dart';

class AdvancedInteractivePetWidget extends StatefulWidget {
  final Pet pet;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  
  const AdvancedInteractivePetWidget({
    super.key,
    required this.pet,
    this.onTap,
    this.onLongPress,
  });

  @override
  State<AdvancedInteractivePetWidget> createState() => _AdvancedInteractivePetWidgetState();
}

class _AdvancedInteractivePetWidgetState extends State<AdvancedInteractivePetWidget> 
    with SingleTickerProviderStateMixin {
  // Services
  late PetBehaviorService _behaviorService;
  late PetSoundService _soundService;
  
  // Animation controllers
  late AnimationController _animController;
  
  // Position state
  Offset _petPosition = Offset.zero;
  Offset? _targetPosition;
  double _petSize = 150.0;
  double _petDirection = 1.0; // 1.0 = right, -1.0 = left
  
  // Interaction state
  bool _isFollowingCursor = false;
  bool _isInteracting = false;
  String _currentEmotion = '';
  bool _showEmotion = false;
  
  // Animation state
  bool _mouthOpen = false;
  bool _isBlinking = false;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize services
    _behaviorService = PetBehaviorService(pet: widget.pet);
    _soundService = PetSoundService(pet: widget.pet);
    
    // Initialize animation controller
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    // Set initial position in center
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final size = MediaQuery.of(context).size;
        setState(() {
          _petPosition = Offset(size.width / 2, size.height / 2);
        });
      }
    });
    
    // Start update loop
    _startUpdateLoop();
    
    // Schedule random blinks
    _scheduleRandomBlinks();
    
    // Schedule random emotions
    _scheduleRandomEmotions();
  }
  
  @override
  void dispose() {
    _animController.dispose();
    _soundService.dispose();
    super.dispose();
  }
  
  // Set up a periodic update loop for pet behavior
  void _startUpdateLoop() {
    Future.delayed(const Duration(milliseconds: 33), () {
      if (!mounted) return;
      
      setState(() {
        _updatePetState();
      });
      
      _startUpdateLoop();
    });
  }
  
  // Schedule random blinking
  void _scheduleRandomBlinks() {
    final delay = Duration(milliseconds: math.Random().nextInt(4000) + 1000);
    Future.delayed(delay, () {
      if (!mounted) return;
      
      setState(() {
        _isBlinking = true;
      });
      
      // Stop blinking after short duration
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) {
          setState(() {
            _isBlinking = false;
          });
        }
      });
      
      // Schedule next blink
      _scheduleRandomBlinks();
    });
  }
  
  // Schedule random emotions
  void _scheduleRandomEmotions() {
    final delay = Duration(seconds: math.Random().nextInt(15) + 5);
    Future.delayed(delay, () {
      if (!mounted) return;
      
      // Show random emotion based on pet state
      if (math.Random().nextDouble() < 0.7) {
        _showRandomEmotion();
      }
      
      // Schedule next emotion
      _scheduleRandomEmotions();
    });
  }
  
  // Update pet state and animation
  void _updatePetState() {
    // Update pet behavior
    _behaviorService.update();
    
    // Move towards target if we have one
    if (_targetPosition != null) {
      final newPosition = _behaviorService.calculateMovement(
        _petPosition, 
        _targetPosition!,
      );
      
      if ((_targetPosition! - newPosition).distance < 10) {
        // We've reached the target
        _targetPosition = null;
        
        // Return to idle if not interacting
        if (!_isInteracting && widget.pet.currentActivity != PetActivity.sleeping) {
          widget.pet.currentActivity = PetActivity.idle;
        }
      } else {
        // Update pet position and direction
        _petPosition = newPosition;
        _petDirection = _behaviorService.currentDirection;
      }
    }
    
    // Random autonomous movement when idle
    if (_targetPosition == null && 
        !_isFollowingCursor &&
        widget.pet.currentActivity == PetActivity.idle && 
        math.Random().nextDouble() < 0.01) {
      // Get a random position to wander to
      _targetPosition = _behaviorService.getWanderTarget(
        _petPosition,
        MediaQuery.of(context).size,
      );
    }
    
    // Update sound based on activity
    if (_behaviorService.shouldMakeSound()) {
      _playActivitySound();
    }
    
    // Update animation state
    _updateAnimationState();
  }
  
  // Update the current animation state
  void _updateAnimationState() {
    // Determine if mouth should be open based on activity
    bool shouldOpenMouth = widget.pet.currentActivity == PetActivity.eating ||
                          widget.pet.currentActivity == PetActivity.licking;
    
    if (shouldOpenMouth != _mouthOpen) {
      setState(() {
        _mouthOpen = shouldOpenMouth;
        if (_mouthOpen) {
          _animController.forward();
        } else {
          _animController.reverse();
        }
      });
    }
  }
  
  // Play sound based on current activity
  void _playActivitySound() {
    switch (widget.pet.currentActivity) {
      case PetActivity.idle:
        _soundService.playSound('idle');
        break;
      case PetActivity.eating:
        _soundService.playSound('eat');
        break;
      case PetActivity.playing:
      case PetActivity.playingWithToy:
        _soundService.playSound('play');
        break;
      case PetActivity.sleeping:
        _soundService.playSound('sleep');
        break;
      case PetActivity.licking:
        _soundService.playSound('happy');
        break;
      case PetActivity.beingCleaned:
        _soundService.playSound('clean');
        break;
      case PetActivity.beingBrushed:
        _soundService.playSound('clean');
        break;
    }
  }
  
  // Show a random emotion bubble
  void _showRandomEmotion() {
    setState(() {
      _showEmotion = true;
      _currentEmotion = PetEmotionHelper.getRandomEmotionText(widget.pet);
    });
    
    // Hide emotion after delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showEmotion = false;
        });
      }
    });
  }
  
  // Handle user interaction with pet
  void _handlePetInteraction(Offset position) {
    _targetPosition = position;
    _isInteracting = true;
    
    // Play sound
    _soundService.playSound('happy');
    
    // Show love emoji
    setState(() {
      _showEmotion = true;
      _currentEmotion = '❤️';
    });
    
    // Update pet state
    widget.pet.happiness = math.min(100, widget.pet.happiness + 5);
    widget.pet.updateState();
    
    // Hide emotion after short delay
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() => _showEmotion = false);
      }
    });
    
    // Reset interaction state after delay
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _isInteracting = false;
        
        // If we're still moving, wait until we reach the target
        if (_targetPosition == null) {
          widget.pet.currentActivity = PetActivity.idle;
        }
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (PointerDownEvent event) {
        if (!_isFollowingCursor) {
          _handlePetInteraction(event.localPosition);
        }
      },
      onPointerMove: (PointerMoveEvent event) {
        if (_isFollowingCursor) {
          _targetPosition = event.localPosition;
        }
      },
      child: GestureDetector(
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        child: SizedBox.expand(
          child: Stack(
            fit: StackFit.expand,
            children: [
              // The pet
              Positioned(
                left: _petPosition.dx - _petSize / 2,
                top: _petPosition.dy - _petSize / 2,
                width: _petSize,
                height: _petSize,
                child: Transform.scale(
                  scaleX: _petDirection,
                  child: _buildPetWidget(),
                ),
              ),
              
              // Emotion bubble
              if (_showEmotion && _currentEmotion.isNotEmpty)
                Positioned(
                  left: _petPosition.dx - 30,
                  top: _petPosition.dy - _petSize,
                  child: _buildEmotionBubble(),
                ),
              
              // Status indicators
              Positioned(
                left: 10,
                bottom: 10,
                child: _buildStatusIndicators(),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // Build the pet visualization
  Widget _buildPetWidget() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Main pet body
        Icon(
          _getPetIcon(widget.pet.type),
          size: _petSize * 0.8,
          color: widget.pet.color,
        ),
        
        // Eyes
        Positioned(
          top: _petSize * 0.3,
          left: _petSize * 0.25,
          child: _buildEye(),
        ),
        Positioned(
          top: _petSize * 0.3,
          right: _petSize * 0.25,
          child: _buildEye(),
        ),
        
        // Mouth
        Positioned(
          bottom: _petSize * 0.3,
          left: _petSize * 0.3,
          right: _petSize * 0.3,
          child: AnimatedBuilder(
            animation: _animController,
            builder: (context, _) {
              return Container(
                height: _mouthOpen ? 20 + 10 * _animController.value : 5,
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(10),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
  
  // Build a pet eye with blinking
  Widget _buildEye() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      width: 15,
      height: _isBlinking ? 1 : 15,
      decoration: const BoxDecoration(
        color: Colors.black87,
        shape: BoxShape.circle,
      ),
    );
  }
  
  // Build emotion speech bubble
  Widget _buildEmotionBubble() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        _currentEmotion,
        style: const TextStyle(fontSize: 24),
      ),
    );
  }
  
  // Build pet status indicators
  Widget _buildStatusIndicators() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStatusBadge(
          Icons.favorite,
          widget.pet.happiness,
          Colors.red,
        ),
        const SizedBox(height: 5),
        _buildStatusBadge(
          Icons.bolt,
          widget.pet.energy,
          Colors.amber,
        ),
        const SizedBox(height: 5),
        _buildStatusBadge(
          Icons.restaurant,
          100 - widget.pet.hunger,
          Colors.green,
        ),
      ],
    );
  }
  
  // Build individual status badge
  Widget _buildStatusBadge(IconData icon, int value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 4),
          Text(
            '$value%',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
  
  // Get icon based on pet type
  IconData _getPetIcon(PetType type) {
    switch (type) {
      case PetType.dog:
        return Icons.pets;
      case PetType.cat:
        return Icons.catching_pokemon;
      case PetType.bird:
        return Icons.flutter_dash;
      case PetType.rabbit:
        return Icons.cruelty_free;
      case PetType.lion:
        return Icons.face;
      case PetType.giraffe:
        return Icons.auto_awesome;
      case PetType.penguin:
        return Icons.ac_unit;
      case PetType.panda:
        return Icons.circle;
    }
  }
}