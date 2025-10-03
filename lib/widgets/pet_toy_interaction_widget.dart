import 'package:flutter/material.dart';
import '../models/pet.dart';
import '../models/toy.dart';

class PetToyInteractionWidget extends StatefulWidget {
  final Pet pet;
  final Size screenSize;
  final Function(Offset) onPositionChange;

  const PetToyInteractionWidget({
    Key? key,
    required this.pet,
    required this.screenSize,
    required this.onPositionChange,
  }) : super(key: key);

  @override
  State<PetToyInteractionWidget> createState() =>
      _PetToyInteractionWidgetState();
}

class _PetToyInteractionWidgetState extends State<PetToyInteractionWidget>
    with SingleTickerProviderStateMixin {
  Offset _petPosition = Offset.zero;
  Offset? _targetPosition;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    // Initialize pet position to center of screen
    _petPosition = Offset(
      widget.screenSize.width / 2,
      widget.screenSize.height / 2,
    );

    // Set up animation controller for movements
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _controller.addListener(() {
      if (_targetPosition != null) {
        // Calculate new position based on animation value
        final newPosition = Offset.lerp(
          _petPosition,
          _targetPosition!,
          _controller.value,
        );

        if (newPosition != null) {
          setState(() {
            _petPosition = newPosition;
            widget.onPositionChange(newPosition);
          });
        }
      }
    });

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // We've reached the target
        if (_targetPosition != null &&
            widget.pet.currentToy != null &&
            widget.pet.currentToy!.throwPosition != null) {
          // Play with the toy for a while
          Future.delayed(const Duration(seconds: 3), () {
            // Return to center
            if (mounted) {
              _moveTo(
                Offset(
                  widget.screenSize.width / 2,
                  widget.screenSize.height / 2,
                ),
              );

              // Clear toy throw position
              if (widget.pet.currentToy != null) {
                setState(() {
                  widget.pet.currentToy!.throwPosition = null;
                });
              }
            }
          });
        }
      }
    });

    // Check for toy throws periodically
    _checkForToyThrows();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _checkForToyThrows() {
    if (!mounted) return;

    // If there's a toy with a throw position, go to it
    if (widget.pet.currentToy != null &&
        widget.pet.currentToy!.throwPosition != null &&
        widget.pet.currentActivity == PetActivity.playingWithToy) {
      _moveTo(widget.pet.currentToy!.throwPosition!);
    }

    // Check again after a short delay
    Future.delayed(const Duration(milliseconds: 500), _checkForToyThrows);
  }

  void _moveTo(Offset target) {
    setState(() {
      _targetPosition = target;
      _controller.reset();
      _controller.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Thrown toy visualization
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
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                _getToyIcon(widget.pet.currentToy!.type),
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
      ],
    );
  }

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
}
