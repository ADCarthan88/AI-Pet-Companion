import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/pet.dart';
import '../models/toy.dart';
import 'pet_visualizations/pet_visualization_factory.dart';

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

class _AdvancedInteractivePetWidgetState extends State<AdvancedInteractivePetWidget> {
  // Pet state
  double _petSize = 100;
  bool _isBlinking = false;
  bool _mouthOpen = false;
  
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
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: SizedBox(
        width: _petSize,
        height: _petSize,
        child: PetVisualizationFactory.getPetVisualization(
          pet: widget.pet,
          isBlinking: _isBlinking,
          mouthOpen: _mouthOpen,
          size: _petSize,
        ),
      ),
    );
  }
}