import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/pet.dart';

class RealisticTextureService {
  static Paint getFurTexture(PetType petType, Color baseColor, PetMood mood) {
    switch (petType) {
      case PetType.dog:
        return _getDogFurTexture(baseColor, mood);
      case PetType.cat:
        return _getCatFurTexture(baseColor, mood);
      case PetType.bird:
        return _getFeatherTexture(baseColor, mood);
      default:
        return Paint()..color = baseColor;
    }
  }

  static Paint _getDogFurTexture(Color baseColor, PetMood mood) {
    final paint = Paint();
    
    // Create gradient for fur depth
    final colors = [
      baseColor.withOpacity(0.9),
      baseColor,
      baseColor.withOpacity(0.7),
      baseColor.withOpacity(0.8),
    ];
    
    final stops = [0.0, 0.3, 0.7, 1.0];
    
    paint.shader = RadialGradient(
      colors: colors,
      stops: stops,
      center: const Alignment(-0.3, -0.4), // Light source from top-left
    ).createShader(const Rect.fromLTWH(0, 0, 100, 100));
    
    return paint;
  }

  static Paint _getCatFurTexture(Color baseColor, PetMood mood) {
    final paint = Paint();
    
    // Cats have softer, more uniform fur
    final colors = [
      baseColor.withOpacity(0.95),
      baseColor,
      baseColor.withOpacity(0.85),
    ];
    
    paint.shader = LinearGradient(
      colors: colors,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      stops: const [0.0, 0.5, 1.0],
    ).createShader(const Rect.fromLTWH(0, 0, 100, 100));
    
    return paint;
  }

  static Paint _getFeatherTexture(Color baseColor, PetMood mood) {
    final paint = Paint();
    
    // Feathers have iridescent quality
    final colors = [
      baseColor.withOpacity(0.8),
      baseColor,
      baseColor.withOpacity(0.9),
      _getIridescentColor(baseColor),
    ];
    
    paint.shader = SweepGradient(
      colors: colors,
      stops: const [0.0, 0.3, 0.6, 1.0],
    ).createShader(const Rect.fromLTWH(0, 0, 100, 100));
    
    return paint;
  }

  static Color _getIridescentColor(Color baseColor) {
    final hsl = HSLColor.fromColor(baseColor);
    return hsl.withHue((hsl.hue + 30) % 360).withSaturation(0.8).toColor();
  }

  static List<Shadow> getFurShadows(PetType petType) {
    switch (petType) {
      case PetType.dog:
        return [
          Shadow(
            color: Colors.black.withOpacity(0.3),
            offset: const Offset(2, 2),
            blurRadius: 4,
          ),
          Shadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(1, 1),
            blurRadius: 2,
          ),
        ];
      case PetType.cat:
        return [
          Shadow(
            color: Colors.black.withOpacity(0.2),
            offset: const Offset(1, 2),
            blurRadius: 3,
          ),
        ];
      case PetType.bird:
        return [
          Shadow(
            color: Colors.black.withOpacity(0.15),
            offset: const Offset(1, 1),
            blurRadius: 2,
          ),
        ];
      default:
        return [];
    }
  }

  static Paint getEyeTexture(PetType petType, PetMood mood) {
    final paint = Paint();
    
    Color eyeColor;
    switch (petType) {
      case PetType.dog:
        eyeColor = Colors.brown.shade700;
        break;
      case PetType.cat:
        eyeColor = Colors.green.shade400;
        break;
      case PetType.bird:
        eyeColor = Colors.black;
        break;
      default:
        eyeColor = Colors.brown;
    }
    
    // Add mood-based eye effects
    switch (mood) {
      case PetMood.loving:
        eyeColor = eyeColor.withOpacity(0.9);
        break;
      case PetMood.excited:
        eyeColor = Color.lerp(eyeColor, Colors.amber, 0.1)!;
        break;
      case PetMood.sad:
        eyeColor = eyeColor.withOpacity(0.7);
        break;
      default:
        break;
    }
    
    paint.color = eyeColor;
    return paint;
  }

  static Paint getNoseTexture(PetType petType) {
    final paint = Paint();
    
    switch (petType) {
      case PetType.dog:
        paint.shader = RadialGradient(
          colors: [
            Colors.black.withOpacity(0.9),
            Colors.black,
            Colors.grey.shade800,
          ],
          stops: const [0.0, 0.7, 1.0],
        ).createShader(const Rect.fromLTWH(0, 0, 10, 10));
        break;
      case PetType.cat:
        paint.color = Colors.pink.shade300;
        break;
      case PetType.bird:
        paint.shader = LinearGradient(
          colors: [
            Colors.orange.shade600,
            Colors.orange.shade400,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(const Rect.fromLTWH(0, 0, 10, 10));
        break;
      default:
        paint.color = Colors.black;
    }
    
    return paint;
  }

  static List<Color> getCoatPatterns(PetType petType, Color baseColor) {
    switch (petType) {
      case PetType.dog:
        return _getDogCoatPatterns(baseColor);
      case PetType.cat:
        return _getCatCoatPatterns(baseColor);
      case PetType.bird:
        return _getBirdPlumagePatterns(baseColor);
      default:
        return [baseColor];
    }
  }

  static List<Color> _getDogCoatPatterns(Color baseColor) {
    final patterns = <Color>[];
    patterns.add(baseColor);
    
    // Add common dog coat variations
    patterns.add(baseColor.withOpacity(0.8));
    patterns.add(Color.lerp(baseColor, Colors.white, 0.3)!);
    patterns.add(Color.lerp(baseColor, Colors.black, 0.2)!);
    
    return patterns;
  }

  static List<Color> _getCatCoatPatterns(Color baseColor) {
    final patterns = <Color>[];
    patterns.add(baseColor);
    
    // Add tabby-like patterns
    patterns.add(Color.lerp(baseColor, Colors.black, 0.3)!);
    patterns.add(Color.lerp(baseColor, Colors.white, 0.4)!);
    patterns.add(baseColor.withOpacity(0.9));
    
    return patterns;
  }

  static List<Color> _getBirdPlumagePatterns(Color baseColor) {
    final patterns = <Color>[];
    patterns.add(baseColor);
    
    // Add colorful bird patterns
    final hsl = HSLColor.fromColor(baseColor);
    patterns.add(hsl.withHue((hsl.hue + 60) % 360).toColor());
    patterns.add(hsl.withHue((hsl.hue + 120) % 360).toColor());
    patterns.add(Color.lerp(baseColor, Colors.white, 0.3)!);
    
    return patterns;
  }

  static Paint getEnvironmentalLighting(TimeOfDay timeOfDay) {
    final paint = Paint();
    
    Color lightColor;
    double intensity;
    
    final hour = timeOfDay.hour;
    if (hour >= 6 && hour < 10) {
      // Morning light - warm and soft
      lightColor = Colors.orange.shade100;
      intensity = 0.3;
    } else if (hour >= 10 && hour < 16) {
      // Midday light - bright and neutral
      lightColor = Colors.white;
      intensity = 0.5;
    } else if (hour >= 16 && hour < 19) {
      // Evening light - warm and golden
      lightColor = Colors.amber.shade100;
      intensity = 0.4;
    } else {
      // Night - cool and dim
      lightColor = Colors.blue.shade100;
      intensity = 0.1;
    }
    
    paint.color = lightColor.withOpacity(intensity);
    paint.blendMode = BlendMode.overlay;
    
    return paint;
  }
}