import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/pet.dart';
import '../models/toy.dart';
import '../services/badge_service.dart';

class PetToyInteractionWidget extends StatefulWidget {
  const PetToyInteractionWidget({
    super.key,
    required this.pet,
    required this.screenSize,
    required this.onPositionChange,
  });

  final Pet pet;
  final Size screenSize;
  final Function(Offset) onPositionChange;

  @override
  State<PetToyInteractionWidget> createState() =>
      _PetToyInteractionWidgetState();
}

class _PetToyInteractionWidgetState extends State<PetToyInteractionWidget>
    with SingleTickerProviderStateMixin {
  Offset _petPosition = Offset.zero;
  Offset? _targetPosition;
  late AnimationController _controller;
  final List<_ToyParticle> _particles = [];

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
                  BadgeService.instance.increment(
                    'toy_play',
                    threshold: 5,
                    badgeId: 'Playtime Novice',
                  );
                  BadgeService.instance.increment(
                    'toy_play',
                    threshold: 20,
                    badgeId: 'Playtime Pro',
                  );
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
      // Spawn a small burst of particles when target reached soon (anticipatory)
      _spawnParticles(target);
    });
  }

  void _spawnParticles(Offset center) {
    // Create 8 particles in random small radius
    final rand = math.Random();
    for (int i = 0; i < 8; i++) {
      final dx = (rand.nextDouble() - 0.5) * 30;
      final dy = (rand.nextDouble() - 0.5) * 30;
      _particles.add(_ToyParticle(center + Offset(dx, dy)));
    }
    // Clean old particles after a frame
    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      setState(() {
        _particles.removeWhere((p) => p.opacity <= 0);
      });
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
                  // Base shadow
                  const BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                  // Pulse highlight when pet is moving toward toy
                  if (_targetPosition != null)
                    BoxShadow(
                      color: widget.pet.currentToy!.color.withValues(alpha: 0.7),
                      blurRadius: 12 + (6 * _controller.value),
                      spreadRadius: 2 + (2 * _controller.value),
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
        // Particles
        ..._particles.map((p) => Positioned(
              left: p.position.dx,
              top: p.position.dy,
              child: Opacity(
                opacity: p.opacity,
                child: Transform.scale(
                  scale: p.scale,
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: widget.pet.currentToy?.color ?? Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            )),
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

class _ToyParticle {
  _ToyParticle(this.position)
      : created = DateTime.now(),
        scale = 0.5 + math.Random().nextDouble() * 0.5;
  Offset position;
  final DateTime created;
  double scale;
  double get opacity {
    final ageMs = DateTime.now().difference(created).inMilliseconds;
    final life = 600; // ms
    final remaining = (1 - (ageMs / life)).clamp(0.0, 1.0);
    return remaining;
  }
}

