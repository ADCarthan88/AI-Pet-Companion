import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import '../models/pet.dart';
import '../services/pet_sound_service.dart';
import 'pet_animation_manager.dart';

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
  State<AdvancedInteractivePetWidget> createState() =>
      _AdvancedInteractivePetWidgetState();
}

class _AdvancedInteractivePetWidgetState
    extends State<AdvancedInteractivePetWidget>
    with SingleTickerProviderStateMixin {
  // Pet animation manager
  late PetAnimationManager _petAnimationManager;

  // Pet sound service
  late PetSoundService _soundService;

  // Mouth animation controller
  late AnimationController _mouthController;
  late Animation<double> _mouthAnimation;

  // Track cursor position for following behavior
  Offset? _cursorPosition;
  bool _isFollowingCursor = false;
  bool _isMouthOpen = false;

  // Track emotion display
  String? _currentEmotionText;
  bool _showingEmotion = false;

  @override
  void initState() {
    super.initState();

    // Initialize pet animation manager
    _petAnimationManager = PetAnimationManager(pet: widget.pet);

    // Initialize sound service
    _soundService = PetSoundService(pet: widget.pet);

    // Initialize mouth animation controller
    _mouthController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _mouthAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _mouthController, curve: Curves.easeInOut),
    );

    // Set up periodic emotion displays
    _scheduleRandomEmotionDisplay();
  }

  @override
  void dispose() {
    _mouthController.dispose();
    _soundService.dispose();
    super.dispose();
  }

  void _scheduleRandomEmotionDisplay() {
    // Display random emotions periodically based on pet's state
    Future.delayed(Duration(seconds: math.Random().nextInt(10) + 5), () {
      if (!mounted) return;

      // Decide whether to show an emotion based on the pet's current state
      final shouldShowEmotion = math.Random().nextDouble() < 0.7;

      if (shouldShowEmotion) {
        _showRandomEmotion();
      }

      // Schedule next emotion
      _scheduleRandomEmotionDisplay();
    });
  }

  void _showRandomEmotion() {
    setState(() {
      _showingEmotion = true;

      // Select emotion based on pet state
      if (widget.pet.hunger > 70) {
        _currentEmotionText = '🍗';
        _soundService.playSound('hungry');
      } else if (widget.pet.cleanliness < 30) {
        _currentEmotionText = '💦';
        _soundService.playSound('dirty');
      } else if (widget.pet.happiness > 80) {
        _currentEmotionText = '❤️';
        _soundService.playSound('happy');
      } else if (widget.pet.energy < 30) {
        _currentEmotionText = '💤';
        _soundService.playSound('tired');
      } else {
        // Random emotions
        final emotions = ['😊', '🎾', '🦴', '🐾', '?', '!'];
        _currentEmotionText = emotions[math.Random().nextInt(emotions.length)];
        _soundService.playSound('idle');
      }

      // Animate mouth with emotion
      _mouthController.forward();

      // Hide emotion after delay
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _showingEmotion = false;
            _mouthController.reverse();
          });
        }
      });
    });
  }

  void _handlePetInteraction(Offset position) {
    setState(() {
      _cursorPosition = position;
      _isFollowingCursor = true;

      // Update pet animation manager
      _petAnimationManager.moveTo(Vector2(position.dx, position.dy));

      // Play appropriate sound
      _soundService.playSound('happy');

      // Show visual response
      _showEmotionResponse();

      // Animate mouth
      _toggleMouth();
    });
  }

  void _showEmotionResponse() {
    setState(() {
      _showingEmotion = true;
      _currentEmotionText = '❤️';

      // Hide after delay
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() => _showingEmotion = false);
        }
      });
    });
  }

  void _toggleMouth() {
    setState(() {
      _isMouthOpen = !_isMouthOpen;

      if (_isMouthOpen) {
        _mouthController.forward();
      } else {
        _mouthController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Create the flame game widget for our pet animations
    final gameWidget = GameWidget(game: _petAnimationManager);

    return GestureDetector(
      onTapDown: (TapDownDetails details) =>
          _handlePetInteraction(details.localPosition),
      onPanUpdate: (DragUpdateDetails details) =>
          _handlePetInteraction(details.localPosition),
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Pet animation
          gameWidget,

          // Emotion bubble (only shown when needed)
          if (_showingEmotion && _currentEmotionText != null)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              top: 50,
              right: 50,
              child: Container(
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
                  _currentEmotionText!,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),

          // Pet status overlay
          Positioned(
            bottom: 10,
            left: 10,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatusBadge(
                  Icons.favorite,
                  widget.pet.happiness,
                  Colors.red,
                ),
                const SizedBox(height: 5),
                _buildStatusBadge(Icons.bolt, widget.pet.energy, Colors.amber),
                const SizedBox(height: 5),
                _buildStatusBadge(
                  Icons.restaurant,
                  100 - widget.pet.hunger,
                  Colors.green,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

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
}
