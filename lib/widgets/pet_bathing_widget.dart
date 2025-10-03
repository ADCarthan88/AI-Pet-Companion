import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/pet.dart';

class PetBathingWidget extends StatefulWidget {
  const PetBathingWidget({
    super.key,
    required this.pet,
    required this.onBathComplete,
  });

  final Pet pet;
  final VoidCallback onBathComplete;

  @override
  State<PetBathingWidget> createState() => _PetBathingWidgetState();
}

class _PetBathingWidgetState extends State<PetBathingWidget>
    with SingleTickerProviderStateMixin {
  bool _isPouring = false;
  bool _showBubbles = false;
  bool _isDrying = false;
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _startBathing();
  }

  void _startBathing() {
    // Start with pouring water
    setState(() {
      _isPouring = true;
      widget.pet.currentActivity = PetActivity.beingCleaned;
    });

    // After a short delay, show bubbles
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isPouring = false;
          _showBubbles = true;
        });
      }

      // Then start drying after scrubbing
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _showBubbles = false;
            _isDrying = true;
          });

          // Finally complete the bath
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              widget.onBathComplete();
            }
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // The pet
        Positioned.fill(
          child: Center(
            child: SizedBox(
              width: 150,
              height: 150,
              child: Transform.scale(
                scale: 1.2,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue.withValues(alpha: 0.2),
                  ),
                  child: AnimatedOpacity(
                    opacity: _isDrying ? 0.7 : 1.0,
                    duration: const Duration(milliseconds: 500),
                    child: Image.asset(
                      'assets/images/${widget.pet.type.toString().split('.').last}_bath.png',
                      errorBuilder: (context, error, stackTrace) {
                        // Fallback if image isn't available
                        return Icon(
                          Icons.pets,
                          size: 100,
                          color: widget.pet.color,
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        // Water pouring effect
        if (_isPouring)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 200,
            child: CustomPaint(painter: _WaterPainter()),
          ),

        // Bubble effects
        if (_showBubbles) Positioned.fill(child: _BubbleEffect(count: 20)),

        // Drying effect
        if (_isDrying)
          Positioned.fill(child: CustomPaint(painter: _DryingPainter())),

        // Instructions
        Positioned(
          bottom: 20,
          left: 0,
          right: 0,
          child: Center(
            child: Text(
              _isPouring
                  ? 'Rinsing...'
                  : _showBubbles
                  ? 'Scrubbing...'
                  : _isDrying
                  ? 'Drying...'
                  : '',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Water pouring effect painter
class _WaterPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
  ..color = Colors.blue.withValues(alpha: 0.6)
      ..strokeWidth = 2.0;

    // Draw water streams
    for (int i = 0; i < 10; i++) {
      final startX = size.width * (0.3 + i * 0.05);
      final path = Path();
      path.moveTo(startX, 0);

      // Wavy water path
      for (int j = 1; j < 20; j++) {
        path.lineTo(startX + sin(j * 0.2) * 5, j * 10);
      }

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_WaterPainter oldDelegate) => true;

  double sin(double value) {
    return math.sin(value);
  }
}

// Drying effect painter
class _DryingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
  ..color = Colors.white.withValues(alpha: 0.3)
      ..strokeWidth = 1.5;

    // Draw wind/air lines
    for (int i = 0; i < 20; i++) {
      final startY = size.height * (0.2 + i * 0.03);
      final path = Path();
      path.moveTo(0, startY);

      // Wavy air path
      for (int j = 1; j < 30; j++) {
        path.lineTo(j * 10, startY + sin(j * 0.3) * 3);
      }

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_DryingPainter oldDelegate) => true;

  double sin(double value) {
    return math.sin(value);
  }
}

// Bubble effect
class _BubbleEffect extends StatefulWidget {
  final int count;

  const _BubbleEffect({required this.count});

  @override
  State<_BubbleEffect> createState() => _BubbleEffectState();
}

class _BubbleEffectState extends State<_BubbleEffect>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;
  late List<Offset> _positions;
  late List<double> _sizes;

  @override
  void initState() {
    super.initState();

    // Initialize animations for each bubble
    _controllers = List.generate(
      widget.count,
      (index) => AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 500 + index * 100),
      )..repeat(reverse: true),
    );

    // Animations for bubble movement
    _animations = _controllers
        .map(
          (controller) => Tween<double>(begin: 0, end: 1).animate(controller),
        )
        .toList();

    // Random positions for bubbles
    _positions = List.generate(
      widget.count,
      (index) => Offset(
        math.Random().nextDouble() * 300,
        math.Random().nextDouble() * 300,
      ),
    );

    // Random sizes for bubbles
    _sizes = List.generate(
      widget.count,
      (index) => 5 + math.Random().nextDouble() * 15,
    );
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: List.generate(widget.count, (index) {
        return AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            return Positioned(
              left: _positions[index].dx,
              top: _positions[index].dy - 50 * _animations[index].value,
              child: Opacity(
                opacity: 1 - _animations[index].value,
                child: Container(
                  width: _sizes[index],
                  height: _sizes[index],
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.7),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
