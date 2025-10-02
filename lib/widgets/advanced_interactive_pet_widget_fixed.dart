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
  double _petSize = 150;
  bool _isBlinking = false;
  bool _mouthOpen = false;
  Offset _petPosition = Offset.zero;

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

    // Start animation loop for blinking
    _startBlinkingAnimation();
  }

  @override
  void dispose() {
    _animController.dispose();
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

  @override
  Widget build(BuildContext context) {
    final petSize = _petSize;
    final screenSize = MediaQuery.of(context).size;

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
        });
      }
    }

    // Create the visualization widget
    final visualization = PetVisualizationFactory.createVisualization(
      pet: widget.pet,
      size: petSize,
      isBlinking: _isBlinking,
      mouthOpen: _mouthOpen,
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
            child: visualization,
          ),

          // Show the toy if it's being used
          if (widget.pet.currentToy != null &&
              widget.pet.currentToy!.throwPosition != null)
            Positioned(
              left: widget.pet.currentToy!.throwPosition!.dx - 15,
              top: widget.pet.currentToy!.throwPosition!.dy - 15,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: widget.pet.currentToy!.color,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getToyIcon(widget.pet.currentToy!.type),
                  color: Colors.white,
                  size: 18,
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
