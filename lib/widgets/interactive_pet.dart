import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/pet.dart';

class InteractivePet extends StatefulWidget {
  final Pet pet;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const InteractivePet({
    super.key,
    required this.pet,
    this.onTap,
    this.onLongPress,
  });

  @override
  State<InteractivePet> createState() => _InteractivePetState();
}

class _InteractivePetState extends State<InteractivePet>
    with SingleTickerProviderStateMixin {
  // Controllers for Rive animations
  Artboard? _riveArtboard;
  StateMachineController? _stateMachineController;
  SMITrigger? _idleTrigger;
  SMITrigger? _walkTrigger;
  SMITrigger? _runTrigger;
  SMITrigger? _eatTrigger;
  SMITrigger? _sleepTrigger;
  SMITrigger? _cleanTrigger;
  SMITrigger? _playTrigger;
  SMITrigger? _lickTrigger;

  // Audio player for pet sounds
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Animation controller for custom animations
  late AnimationController _animationController;

  // Track cursor position for following behavior
  Offset? _cursorPosition;
  bool _isFollowingCursor = false;

  // Pet position
  Offset _petPosition = const Offset(0, 0);
  Size _petSize = const Size(150, 150);

  @override
  void initState() {
    super.initState();

    _loadRiveAsset();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // Set up periodic state check for the pet
    Future.delayed(const Duration(milliseconds: 500), _updatePetState);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _audioPlayer.dispose();
    _stateMachineController?.dispose();
    super.dispose();
  }

  Future<void> _loadRiveAsset() async {
    // This will be replaced with the actual Rive asset loading
    // For now, we're setting up a placeholder
    try {
      final asset = await RiveFile.asset(
        'assets/animations/${_getPetTypeAssetName()}.riv',
      );

      final artboard = asset.mainArtboard;
      var controller = StateMachineController.fromArtboard(
        artboard,
        'PetStateMachine',
      );

      if (controller != null) {
        artboard.addController(controller);
        _stateMachineController = controller;
        _idleTrigger = controller.findSMI('idle');
        _walkTrigger = controller.findSMI('walk');
        _runTrigger = controller.findSMI('run');
        _eatTrigger = controller.findSMI('eat');
        _sleepTrigger = controller.findSMI('sleep');
        _cleanTrigger = controller.findSMI('clean');
        _playTrigger = controller.findSMI('play');
        _lickTrigger = controller.findSMI('lick');
      }

      setState(() => _riveArtboard = artboard);
    } catch (e) {
      debugPrint('Error loading Rive asset: $e');
      // Fallback to default animations
    }
  }

  String _getPetTypeAssetName() {
    switch (widget.pet.type) {
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

  void _updatePetState() {
    if (!mounted) return;

    setState(() {
      // Update animation state based on pet's activity
      _updatePetAnimation();

      // Update position if following cursor
      _updatePosition();
    });

    // Schedule next update
    Future.delayed(const Duration(milliseconds: 50), _updatePetState);
  }

  void _updatePetAnimation() {
    switch (widget.pet.currentActivity) {
      case PetActivity.idle:
        _idleTrigger?.fire();
        break;
      case PetActivity.playing:
      case PetActivity.playingWithToy:
        _playTrigger?.fire();
        break;
      case PetActivity.sleeping:
        _sleepTrigger?.fire();
        break;
      case PetActivity.eating:
        _eatTrigger?.fire();
        break;
      case PetActivity.licking:
        _lickTrigger?.fire();
        break;
      case PetActivity.beingCleaned:
        _cleanTrigger?.fire();
        break;
      case PetActivity.beingBrushed:
        _cleanTrigger?.fire();
        break;
    }
  }

  void _updatePosition() {
    if (_cursorPosition != null && _isFollowingCursor) {
      // Calculate direction to cursor
      final dx = _cursorPosition!.dx - _petPosition.dx;
      final dy = _cursorPosition!.dy - _petPosition.dy;
      final distance = math.sqrt(dx * dx + dy * dy);

      // Only move if cursor is not too close
      if (distance > 10) {
        // Determine speed based on distance
        final speed = math.min(5, distance / 10);

        // Calculate new position with easing
        _petPosition = Offset(
          _petPosition.dx + (dx * speed / distance),
          _petPosition.dy + (dy * speed / distance),
        );

        // Trigger walk or run animation based on distance
        if (distance > 100) {
          _runTrigger?.fire();
        } else {
          _walkTrigger?.fire();
        }

        // Play movement sound occasionally
        if (math.Random().nextInt(50) == 0) {
          _playPetSound('move');
        }
      } else {
        // If cursor is close, go back to idle
        _idleTrigger?.fire();
      }
    }
  }

  Future<void> _playPetSound(String action) async {
    // Define the sound based on pet type and action
    String soundFile;

    switch (widget.pet.type) {
      case PetType.dog:
        soundFile = action == 'happy'
            ? 'dog_bark.mp3'
            : action == 'eat'
            ? 'dog_eat.mp3'
            : 'dog_move.mp3';
        break;
      case PetType.cat:
        soundFile = action == 'happy'
            ? 'cat_meow.mp3'
            : action == 'eat'
            ? 'cat_purr.mp3'
            : 'cat_move.mp3';
        break;
      case PetType.bird:
        soundFile = action == 'happy'
            ? 'bird_chirp.mp3'
            : action == 'eat'
            ? 'bird_eat.mp3'
            : 'bird_flap.mp3';
        break;
      case PetType.rabbit:
        soundFile = action == 'happy'
            ? 'rabbit_happy.mp3'
            : action == 'eat'
            ? 'rabbit_eat.mp3'
            : 'rabbit_hop.mp3';
        break;
      case PetType.lion:
        soundFile = action == 'happy'
            ? 'lion_roar.mp3'
            : action == 'eat'
            ? 'lion_eat.mp3'
            : 'lion_move.mp3';
        break;
      case PetType.giraffe:
        soundFile = action == 'happy'
            ? 'giraffe_happy.mp3'
            : action == 'eat'
            ? 'giraffe_eat.mp3'
            : 'giraffe_move.mp3';
        break;
      case PetType.penguin:
        soundFile = action == 'happy'
            ? 'penguin_call.mp3'
            : action == 'eat'
            ? 'penguin_eat.mp3'
            : 'penguin_slide.mp3';
        break;
      case PetType.panda:
        soundFile = action == 'happy'
            ? 'panda_call.mp3'
            : action == 'eat'
            ? 'panda_eat.mp3'
            : 'panda_move.mp3';
        break;
      default:
        soundFile = 'generic_pet.mp3';
    }

    try {
      await _audioPlayer.play(AssetSource('sounds/$soundFile'));
    } catch (e) {
      debugPrint('Error playing sound: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (PointerDownEvent event) {
        setState(() {
          _cursorPosition = event.localPosition;
          _isFollowingCursor = true;
          _playPetSound('happy');
        });
      },
      onPointerMove: (PointerMoveEvent event) {
        setState(() => _cursorPosition = event.localPosition);
      },
      onPointerUp: (PointerUpEvent event) {
        setState(() => _isFollowingCursor = false);
      },
      child: GestureDetector(
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return CustomPaint(
              painter: PetBackgroundPainter(widget.pet.mood),
              child: SizedBox.expand(
                child: Stack(
                  children: [
                    // The pet itself
                    Positioned(
                      left: _petPosition.dx,
                      top: _petPosition.dy,
                      width: _petSize.width,
                      height: _petSize.height,
                      child: _buildPetWidget(),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPetWidget() {
    // If Rive asset is loaded, use it
    if (_riveArtboard != null) {
      return Transform.scale(
        scale: widget.pet.currentActivity == PetActivity.licking
            ? 1.0 + 0.2 * _animationController.value
            : 1.0,
        child: RiveAnimation.direct(_riveArtboard!, fit: BoxFit.contain),
      );
    }

    // Fallback to a temporary icon-based pet
    return _buildFallbackPet();
  }

  Widget _buildFallbackPet() {
    // Create a temporarily more engaging version of the pet icon
    final petIcon = _getPetIcon(widget.pet.type);
    final mouthIcon =
        widget.pet.currentActivity == PetActivity.eating ||
            widget.pet.currentActivity == PetActivity.licking
        ? Icons.voice_chat
        : Icons.remove;

    return Stack(
      children: [
        // Pet body
        Icon(petIcon, size: 120, color: widget.pet.color),

        // Pet mouth (animates based on activity)
        Positioned(
          bottom: 30,
          left: 35,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width:
                widget.pet.currentActivity == PetActivity.eating ||
                    widget.pet.currentActivity == PetActivity.licking
                ? 50
                : 30,
            height:
                widget.pet.currentActivity == PetActivity.eating ||
                    widget.pet.currentActivity == PetActivity.licking
                ? 30
                : 10,
            child: Icon(
              mouthIcon,
              size:
                  widget.pet.currentActivity == PetActivity.eating ||
                      widget.pet.currentActivity == PetActivity.licking
                  ? 30
                  : 20,
              color: Colors.black87,
            ),
          ),
        ),

        // Eyes (blink occasionally)
        Positioned(top: 40, left: 30, child: _buildEye()),
        Positioned(top: 40, right: 30, child: _buildEye()),
      ],
    );
  }

  Widget _buildEye() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 15,
      height: math.Random().nextInt(100) < 5 ? 1 : 15, // Occasional blink
      decoration: BoxDecoration(color: Colors.black87, shape: BoxShape.circle),
    );
  }

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
      default:
        return Icons.pets;
    }
  }
}

// Custom painter for the pet's background/environment
class PetBackgroundPainter extends CustomPainter {
  final PetMood mood;

  PetBackgroundPainter(this.mood);

  @override
  void paint(Canvas canvas, Size size) {
    // We'll draw a simple background based on the pet's mood
    final paint = Paint();

    switch (mood) {
      case PetMood.happy:
        paint.color = Colors.lightBlue.withOpacity(0.2);
        break;
      case PetMood.sad:
        paint.color = Colors.blueGrey.withOpacity(0.2);
        break;
      case PetMood.excited:
        paint.color = Colors.amber.withOpacity(0.2);
        break;
      case PetMood.tired:
        paint.color = Colors.indigo.withOpacity(0.2);
        break;
      case PetMood.loving:
        paint.color = Colors.pink.withOpacity(0.2);
        break;
      case PetMood.neutral:
      default:
        paint.color = Colors.green.withOpacity(0.2);
    }

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Draw some mood elements
    if (mood == PetMood.happy ||
        mood == PetMood.excited ||
        mood == PetMood.loving) {
      _drawHappyElements(canvas, size);
    } else if (mood == PetMood.sad) {
      _drawSadElements(canvas, size);
    } else if (mood == PetMood.tired) {
      _drawTiredElements(canvas, size);
    }
  }

  void _drawHappyElements(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.yellow
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Draw some sun rays or stars
    for (var i = 0; i < 10; i++) {
      final x = math.Random().nextDouble() * size.width;
      final y = math.Random().nextDouble() * size.height / 2;
      final radius = math.Random().nextDouble() * 10 + 5;

      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  void _drawSadElements(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blueGrey
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Draw some rain drops
    for (var i = 0; i < 20; i++) {
      final x = math.Random().nextDouble() * size.width;
      final y = math.Random().nextDouble() * size.height;

      canvas.drawLine(Offset(x, y), Offset(x + 2, y + 10), paint);
    }
  }

  void _drawTiredElements(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.indigo
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Draw some z's for sleepiness
    for (var i = 0; i < 5; i++) {
      final x = math.Random().nextDouble() * size.width;
      final y = math.Random().nextDouble() * size.height / 3;
      final offset = i * 5.0;

      final path = Path()
        ..moveTo(x, y)
        ..lineTo(x + 10 + offset, y)
        ..lineTo(x, y + 10 + offset)
        ..lineTo(x + 15 + offset, y + 10 + offset);

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(PetBackgroundPainter oldDelegate) {
    return oldDelegate.mood != mood;
  }
}
