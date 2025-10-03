import 'package:flutter/material.dart';
import '../models/pet.dart';

class EmotionBackdrop extends StatelessWidget {
  const EmotionBackdrop({super.key, required this.mood});
  final PetMood mood;

  String _getBackdropAsset(PetMood mood) {
    switch (mood) {
      case PetMood.happy:
        return 'assets/images/backdrop_happy.png';
      case PetMood.sad:
        return 'assets/images/backdrop_sad.png';
      case PetMood.loving:
        return 'assets/images/backdrop_loving.png';
      case PetMood.excited:
        return 'assets/images/backdrop_excited.png';
      case PetMood.tired:
        return 'assets/images/backdrop_tired.png';
      case PetMood.neutral:
        return 'assets/images/backdrop_neutral.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(_getBackdropAsset(mood)),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withValues(alpha: 0.15),
            BlendMode.darken,
          ),
        ),
      ),
      child: Container(), // For future overlays (e.g., user photo)
    );
  }
}
