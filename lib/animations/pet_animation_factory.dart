import 'package:flutter/material.dart';
import '../models/pet.dart';

/// Generic fallback pet animation widget; the specific per-species sprite
/// animation implementations were removed / not yet implemented. This keeps
/// the build green while preserving an extension point.
class GenericPetAnimation extends StatefulWidget {
  final Pet pet;
  final Function(PetActivity) onActivityChanged;
  const GenericPetAnimation({
    super.key,
    required this.pet,
    required this.onActivityChanged,
  });

  @override
  State<GenericPetAnimation> createState() => _GenericPetAnimationState();
}

class _GenericPetAnimationState extends State<GenericPetAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _breath;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _breath = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Simple animated container that subtly scales to simulate breathing.
    return AnimatedBuilder(
      animation: _breath,
      builder: (context, child) {
        final scale = 1 + (_breath.value * 0.04);
        return Transform.scale(scale: scale, child: child);
      },
      child: _buildPetShape(widget.pet),
    );
  }

  Widget _buildPetShape(Pet pet) {
    // Very lightweight placeholder visualization using shape + icon.
    final shapeColor = pet.color.withValues(alpha: 0.85);
    IconData icon;
    switch (pet.type) {
      case PetType.dog:
        icon = Icons.pets;
        break;
      case PetType.cat:
        icon = Icons.pets; // Could swap with custom icon
        break;
      case PetType.bird:
        icon = Icons.flight;
        break;
      case PetType.rabbit:
        icon = Icons.grass;
        break;
      case PetType.lion:
        icon = Icons.sunny;
        break;
      case PetType.giraffe:
        icon = Icons.park;
        break;
      case PetType.penguin:
        icon = Icons.ac_unit;
        break;
      case PetType.panda:
        icon = Icons.eco;
        break;
    }
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        color: shapeColor,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Icon(icon, size: 72, color: Colors.white),
    );
  }
}

class PetAnimationFactory {
  static Widget createPetAnimation(
    Pet pet, {
    required Function(PetActivity) onActivityChanged,
  }) {
    // All species use the generic placeholder until specialized animations exist again.
    return GenericPetAnimation(pet: pet, onActivityChanged: onActivityChanged);
  }
}
