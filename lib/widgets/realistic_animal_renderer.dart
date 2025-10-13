import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/pet.dart';

class RealisticAnimalRenderer extends StatefulWidget {
  final Pet pet;
  final double size;
  final bool isBlinking;
  final bool mouthOpen;
  final double walkingPhase;
  final bool facingRight;

  const RealisticAnimalRenderer({
    super.key,
    required this.pet,
    required this.size,
    this.isBlinking = false,
    this.mouthOpen = false,
    this.walkingPhase = 0.0,
    this.facingRight = true,
  });

  @override
  State<RealisticAnimalRenderer> createState() => _RealisticAnimalRendererState();
}

class _RealisticAnimalRendererState extends State<RealisticAnimalRenderer>
    with SingleTickerProviderStateMixin {
  late AnimationController _breathingController;
  late Animation<double> _breathingAnimation;

  @override
  void initState() {
    super.initState();
    _breathingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    _breathingAnimation = Tween<double>(begin: 0.98, end: 1.02).animate(
      CurvedAnimation(parent: _breathingController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _breathingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _breathingAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _breathingAnimation.value,
          child: Transform.scale(
            scaleX: widget.facingRight ? 1.0 : -1.0,
            child: CustomPaint(
              size: Size(widget.size, widget.size),
              painter: _getAnimalPainter(),
            ),
          ),
        );
      },
    );
  }

  CustomPainter _getAnimalPainter() {
    switch (widget.pet.type) {
      case PetType.dog:
        return RealisticDogPainter(
          mood: widget.pet.mood,
          isBlinking: widget.isBlinking,
          mouthOpen: widget.mouthOpen,
          walkingPhase: widget.walkingPhase,
          color: widget.pet.color,
        );
      case PetType.cat:
        return RealisticCatPainter(
          mood: widget.pet.mood,
          isBlinking: widget.isBlinking,
          mouthOpen: widget.mouthOpen,
          walkingPhase: widget.walkingPhase,
          color: widget.pet.color,
        );
      case PetType.bird:
        return RealisticBirdPainter(
          mood: widget.pet.mood,
          isBlinking: widget.isBlinking,
          mouthOpen: widget.mouthOpen,
          walkingPhase: widget.walkingPhase,
          color: widget.pet.color,
        );
      default:
        return RealisticDogPainter(
          mood: widget.pet.mood,
          isBlinking: widget.isBlinking,
          mouthOpen: widget.mouthOpen,
          walkingPhase: widget.walkingPhase,
          color: widget.pet.color,
        );
    }
  }
}

class RealisticDogPainter extends CustomPainter {
  final PetMood mood;
  final bool isBlinking;
  final bool mouthOpen;
  final double walkingPhase;
  final Color color;

  RealisticDogPainter({
    required this.mood,
    required this.isBlinking,
    required this.mouthOpen,
    required this.walkingPhase,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final center = Offset(size.width / 2, size.height / 2);

    // Body
    paint.color = color;
    canvas.drawOval(
      Rect.fromCenter(center: center + Offset(0, 10), width: size.width * 0.6, height: size.height * 0.4),
      paint,
    );

    // Head
    canvas.drawOval(
      Rect.fromCenter(center: center - Offset(0, 20), width: size.width * 0.5, height: size.height * 0.4),
      paint,
    );

    // Ears
    paint.color = color.withOpacity(0.8);
    _drawEar(canvas, center - Offset(15, 35), size.width * 0.15, size.height * 0.2);
    _drawEar(canvas, center - Offset(-15, 35), size.width * 0.15, size.height * 0.2);

    // Legs with walking animation
    paint.color = color.withOpacity(0.9);
    _drawLegs(canvas, center, size, walkingPhase);

    // Tail with mood-based movement
    _drawTail(canvas, center, size, mood);

    // Snout
    paint.color = Colors.black87;
    canvas.drawOval(
      Rect.fromCenter(center: center - Offset(0, 10), width: size.width * 0.25, height: size.height * 0.15),
      paint,
    );

    // Eyes
    _drawEyes(canvas, center - Offset(0, 25), size, isBlinking, mood);

    // Mouth
    _drawMouth(canvas, center - Offset(0, 5), size, mouthOpen, mood);

    // Nose
    paint.color = Colors.black;
    canvas.drawCircle(center - Offset(0, 15), size.width * 0.02, paint);
  }

  void _drawEar(Canvas canvas, Offset position, double width, double height) {
    final paint = Paint()..color = color.withOpacity(0.8);
    canvas.drawOval(Rect.fromCenter(center: position, width: width, height: height), paint);
  }

  void _drawLegs(Canvas canvas, Offset center, Size size, double phase) {
    final paint = Paint()..color = color.withOpacity(0.9);
    final legWidth = size.width * 0.08;
    final legHeight = size.height * 0.25;
    
    // Front legs
    final frontLeftOffset = math.sin(phase * 2 * math.pi) * 3;
    final frontRightOffset = math.sin((phase + 0.5) * 2 * math.pi) * 3;
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: center + Offset(-10, 25) + Offset(0, frontLeftOffset),
          width: legWidth,
          height: legHeight,
        ),
        Radius.circular(legWidth / 2),
      ),
      paint,
    );
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: center + Offset(10, 25) + Offset(0, frontRightOffset),
          width: legWidth,
          height: legHeight,
        ),
        Radius.circular(legWidth / 2),
      ),
      paint,
    );
  }

  void _drawTail(Canvas canvas, Offset center, Size size, PetMood mood) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.05
      ..strokeCap = StrokeCap.round;

    final tailStart = center + Offset(size.width * 0.25, 5);
    final tailEnd = mood == PetMood.happy || mood == PetMood.excited
        ? tailStart + Offset(15, -20)
        : tailStart + Offset(10, 10);

    canvas.drawLine(tailStart, tailEnd, paint);
  }

  void _drawEyes(Canvas canvas, Offset center, Size size, bool blinking, PetMood mood) {
    final paint = Paint()..color = Colors.white;
    final eyeSize = size.width * 0.06;
    
    if (!blinking) {
      // Left eye
      canvas.drawCircle(center - Offset(8, 0), eyeSize, paint);
      // Right eye  
      canvas.drawCircle(center + Offset(8, 0), eyeSize, paint);
      
      // Pupils
      paint.color = Colors.black;
      final pupilSize = eyeSize * 0.6;
      canvas.drawCircle(center - Offset(8, 0), pupilSize, paint);
      canvas.drawCircle(center + Offset(8, 0), pupilSize, paint);
      
      // Eye shine
      paint.color = Colors.white;
      canvas.drawCircle(center - Offset(8, -1), pupilSize * 0.3, paint);
      canvas.drawCircle(center + Offset(8, -1), pupilSize * 0.3, paint);
    } else {
      // Blinking - draw lines
      paint.color = Colors.black;
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = 2;
      canvas.drawLine(
        center - Offset(12, 0),
        center - Offset(4, 0),
        paint,
      );
      canvas.drawLine(
        center + Offset(4, 0),
        center + Offset(12, 0),
        paint,
      );
    }
  }

  void _drawMouth(Canvas canvas, Offset center, Size size, bool open, PetMood mood) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    if (open) {
      // Open mouth - panting
      paint.style = PaintingStyle.fill;
      paint.color = Colors.pink.withOpacity(0.8);
      canvas.drawOval(
        Rect.fromCenter(center: center, width: size.width * 0.1, height: size.height * 0.08),
        paint,
      );
      
      // Tongue
      paint.color = Colors.pink;
      canvas.drawOval(
        Rect.fromCenter(center: center + Offset(0, 3), width: size.width * 0.06, height: size.height * 0.04),
        paint,
      );
    } else {
      // Closed mouth - smile based on mood
      final path = Path();
      if (mood == PetMood.happy || mood == PetMood.loving) {
        path.moveTo(center.dx - 8, center.dy);
        path.quadraticBezierTo(center.dx, center.dy + 4, center.dx + 8, center.dy);
      } else {
        path.moveTo(center.dx - 6, center.dy);
        path.lineTo(center.dx + 6, center.dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class RealisticCatPainter extends CustomPainter {
  final PetMood mood;
  final bool isBlinking;
  final bool mouthOpen;
  final double walkingPhase;
  final Color color;

  RealisticCatPainter({
    required this.mood,
    required this.isBlinking,
    required this.mouthOpen,
    required this.walkingPhase,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final center = Offset(size.width / 2, size.height / 2);

    // Body - more elongated for cat
    paint.color = color;
    canvas.drawOval(
      Rect.fromCenter(center: center + Offset(0, 8), width: size.width * 0.55, height: size.height * 0.35),
      paint,
    );

    // Head - rounder for cat
    canvas.drawCircle(center - Offset(0, 18), size.width * 0.22, paint);

    // Ears - pointed triangular ears
    _drawCatEars(canvas, center - Offset(0, 18), size);

    // Legs - more delicate
    _drawCatLegs(canvas, center, size, walkingPhase);

    // Tail - long and expressive
    _drawCatTail(canvas, center, size, mood);

    // Eyes - almond shaped
    _drawCatEyes(canvas, center - Offset(0, 22), size, isBlinking, mood);

    // Nose - small triangle
    _drawCatNose(canvas, center - Offset(0, 15), size);

    // Mouth - small cat mouth
    _drawCatMouth(canvas, center - Offset(0, 12), size, mouthOpen, mood);

    // Whiskers
    _drawWhiskers(canvas, center - Offset(0, 15), size);
  }

  void _drawCatEars(Canvas canvas, Offset center, Size size) {
    final paint = Paint()..color = color;
    final earSize = size.width * 0.08;
    
    // Left ear
    final leftEarPath = Path();
    leftEarPath.moveTo(center.dx - 12, center.dy - 15);
    leftEarPath.lineTo(center.dx - 18, center.dy - 25);
    leftEarPath.lineTo(center.dx - 6, center.dy - 20);
    leftEarPath.close();
    canvas.drawPath(leftEarPath, paint);
    
    // Right ear
    final rightEarPath = Path();
    rightEarPath.moveTo(center.dx + 12, center.dy - 15);
    rightEarPath.lineTo(center.dx + 18, center.dy - 25);
    rightEarPath.lineTo(center.dx + 6, center.dy - 20);
    rightEarPath.close();
    canvas.drawPath(rightEarPath, paint);
    
    // Inner ears
    paint.color = Colors.pink.withOpacity(0.6);
    canvas.drawCircle(center + Offset(-10, -18), earSize * 0.3, paint);
    canvas.drawCircle(center + Offset(10, -18), earSize * 0.3, paint);
  }

  void _drawCatLegs(Canvas canvas, Offset center, Size size, double phase) {
    final paint = Paint()..color = color;
    final legWidth = size.width * 0.06;
    final legHeight = size.height * 0.2;
    
    // More subtle walking animation for cats
    final frontLeftOffset = math.sin(phase * 2 * math.pi) * 2;
    final frontRightOffset = math.sin((phase + 0.5) * 2 * math.pi) * 2;
    
    // Front legs
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: center + Offset(-8, 20) + Offset(0, frontLeftOffset),
          width: legWidth,
          height: legHeight,
        ),
        Radius.circular(legWidth / 2),
      ),
      paint,
    );
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: center + Offset(8, 20) + Offset(0, frontRightOffset),
          width: legWidth,
          height: legHeight,
        ),
        Radius.circular(legWidth / 2),
      ),
      paint,
    );
  }

  void _drawCatTail(Canvas canvas, Offset center, Size size, PetMood mood) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.04
      ..strokeCap = StrokeCap.round;

    final tailStart = center + Offset(size.width * 0.22, 0);
    
    // Tail position based on mood
    Offset tailMid, tailEnd;
    switch (mood) {
      case PetMood.happy:
      case PetMood.excited:
        tailMid = tailStart + Offset(8, -15);
        tailEnd = tailMid + Offset(5, -10);
        break;
      case PetMood.sad:
        tailMid = tailStart + Offset(5, 10);
        tailEnd = tailMid + Offset(3, 8);
        break;
      default:
        tailMid = tailStart + Offset(10, -5);
        tailEnd = tailMid + Offset(8, 0);
    }
    
    final path = Path();
    path.moveTo(tailStart.dx, tailStart.dy);
    path.quadraticBezierTo(tailMid.dx, tailMid.dy, tailEnd.dx, tailEnd.dy);
    canvas.drawPath(path, paint);
  }

  void _drawCatEyes(Canvas canvas, Offset center, Size size, bool blinking, PetMood mood) {
    final paint = Paint();
    
    if (!blinking) {
      // Almond-shaped eyes
      paint.color = Colors.green.shade300;
      _drawAlmondEye(canvas, center - Offset(6, 0), size.width * 0.05, paint);
      _drawAlmondEye(canvas, center + Offset(6, 0), size.width * 0.05, paint);
      
      // Pupils - vertical slits
      paint.color = Colors.black;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: center - Offset(6, 0), width: 1, height: size.width * 0.03),
          Radius.circular(0.5),
        ),
        paint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: center + Offset(6, 0), width: 1, height: size.width * 0.03),
          Radius.circular(0.5),
        ),
        paint,
      );
    } else {
      // Blinking
      paint.color = Colors.black;
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = 1.5;
      canvas.drawLine(center - Offset(9, 0), center - Offset(3, 0), paint);
      canvas.drawLine(center + Offset(3, 0), center + Offset(9, 0), paint);
    }
  }

  void _drawAlmondEye(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    path.moveTo(center.dx - size, center.dy);
    path.quadraticBezierTo(center.dx, center.dy - size * 0.7, center.dx + size, center.dy);
    path.quadraticBezierTo(center.dx, center.dy + size * 0.7, center.dx - size, center.dy);
    canvas.drawPath(path, paint);
  }

  void _drawCatNose(Canvas canvas, Offset center, Size size) {
    final paint = Paint()..color = Colors.pink;
    final path = Path();
    path.moveTo(center.dx, center.dy - 2);
    path.lineTo(center.dx - 3, center.dy + 2);
    path.lineTo(center.dx + 3, center.dy + 2);
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawCatMouth(Canvas canvas, Offset center, Size size, bool open, PetMood mood) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    if (open) {
      // Meowing
      paint.style = PaintingStyle.fill;
      paint.color = Colors.pink.withOpacity(0.7);
      canvas.drawOval(
        Rect.fromCenter(center: center, width: size.width * 0.06, height: size.width * 0.08),
        paint,
      );
    } else {
      // Cat mouth - inverted Y shape
      canvas.drawLine(center, center + Offset(-4, 3), paint);
      canvas.drawLine(center, center + Offset(4, 3), paint);
    }
  }

  void _drawWhiskers(Canvas canvas, Offset center, Size size) {
    final paint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Left whiskers
    canvas.drawLine(center + Offset(-15, -2), center + Offset(-8, -1), paint);
    canvas.drawLine(center + Offset(-15, 2), center + Offset(-8, 1), paint);
    
    // Right whiskers
    canvas.drawLine(center + Offset(8, -1), center + Offset(15, -2), paint);
    canvas.drawLine(center + Offset(8, 1), center + Offset(15, 2), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class RealisticBirdPainter extends CustomPainter {
  final PetMood mood;
  final bool isBlinking;
  final bool mouthOpen;
  final double walkingPhase;
  final Color color;

  RealisticBirdPainter({
    required this.mood,
    required this.isBlinking,
    required this.mouthOpen,
    required this.walkingPhase,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final center = Offset(size.width / 2, size.height / 2);

    // Body - oval for bird
    paint.color = color;
    canvas.drawOval(
      Rect.fromCenter(center: center + Offset(0, 5), width: size.width * 0.4, height: size.height * 0.5),
      paint,
    );

    // Head - round
    canvas.drawCircle(center - Offset(0, 15), size.width * 0.18, paint);

    // Wings
    _drawWings(canvas, center, size, walkingPhase);

    // Tail feathers
    _drawTailFeathers(canvas, center, size, mood);

    // Beak
    _drawBeak(canvas, center - Offset(0, 15), size, mouthOpen);

    // Eyes
    _drawBirdEyes(canvas, center - Offset(0, 18), size, isBlinking);

    // Legs
    _drawBirdLegs(canvas, center, size);
  }

  void _drawWings(Canvas canvas, Offset center, Size size, double phase) {
    final paint = Paint()..color = color.withOpacity(0.8);
    
    // Wing flapping animation
    final wingFlap = math.sin(phase * 4 * math.pi) * 0.2;
    
    // Left wing
    final leftWingPath = Path();
    leftWingPath.moveTo(center.dx - 5, center.dy);
    leftWingPath.quadraticBezierTo(
      center.dx - 20, center.dy - 5 + wingFlap * 10,
      center.dx - 15, center.dy + 10,
    );
    leftWingPath.lineTo(center.dx - 8, center.dy + 8);
    leftWingPath.close();
    canvas.drawPath(leftWingPath, paint);
    
    // Right wing
    final rightWingPath = Path();
    rightWingPath.moveTo(center.dx + 5, center.dy);
    rightWingPath.quadraticBezierTo(
      center.dx + 20, center.dy - 5 + wingFlap * 10,
      center.dx + 15, center.dy + 10,
    );
    rightWingPath.lineTo(center.dx + 8, center.dy + 8);
    rightWingPath.close();
    canvas.drawPath(rightWingPath, paint);
  }

  void _drawTailFeathers(Canvas canvas, Offset center, Size size, PetMood mood) {
    final paint = Paint()..color = color.withOpacity(0.9);
    
    final tailStart = center + Offset(0, 20);
    final tailLength = mood == PetMood.excited ? 15.0 : 12.0;
    
    // Multiple tail feathers
    for (int i = -1; i <= 1; i++) {
      final featherPath = Path();
      featherPath.moveTo(tailStart.dx + i * 3, tailStart.dy);
      featherPath.quadraticBezierTo(
        tailStart.dx + i * 2, tailStart.dy + tailLength / 2,
        tailStart.dx + i * 4, tailStart.dy + tailLength,
      );
      featherPath.quadraticBezierTo(
        tailStart.dx + i * 2, tailStart.dy + tailLength / 2,
        tailStart.dx + i * 3, tailStart.dy,
      );
      canvas.drawPath(featherPath, paint);
    }
  }

  void _drawBeak(Canvas canvas, Offset center, Size size, bool open) {
    final paint = Paint()..color = Colors.orange;
    
    if (open) {
      // Open beak
      final upperBeak = Path();
      upperBeak.moveTo(center.dx - 8, center.dy);
      upperBeak.lineTo(center.dx - 2, center.dy - 3);
      upperBeak.lineTo(center.dx - 4, center.dy + 1);
      upperBeak.close();
      canvas.drawPath(upperBeak, paint);
      
      final lowerBeak = Path();
      lowerBeak.moveTo(center.dx - 8, center.dy + 2);
      lowerBeak.lineTo(center.dx - 2, center.dy + 1);
      lowerBeak.lineTo(center.dx - 4, center.dy + 4);
      lowerBeak.close();
      canvas.drawPath(lowerBeak, paint);
    } else {
      // Closed beak
      final beakPath = Path();
      beakPath.moveTo(center.dx - 8, center.dy);
      beakPath.lineTo(center.dx - 2, center.dy - 1);
      beakPath.lineTo(center.dx - 2, center.dy + 1);
      beakPath.close();
      canvas.drawPath(beakPath, paint);
    }
  }

  void _drawBirdEyes(Canvas canvas, Offset center, Size size, bool blinking) {
    final paint = Paint()..color = Colors.white;
    
    if (!blinking) {
      // Eyes
      canvas.drawCircle(center - Offset(4, 0), size.width * 0.04, paint);
      canvas.drawCircle(center + Offset(4, 0), size.width * 0.04, paint);
      
      // Pupils
      paint.color = Colors.black;
      canvas.drawCircle(center - Offset(4, 0), size.width * 0.025, paint);
      canvas.drawCircle(center + Offset(4, 0), size.width * 0.025, paint);
      
      // Shine
      paint.color = Colors.white;
      canvas.drawCircle(center - Offset(4, -1), size.width * 0.01, paint);
      canvas.drawCircle(center + Offset(4, -1), size.width * 0.01, paint);
    } else {
      // Blinking
      paint.color = Colors.black;
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = 1;
      canvas.drawLine(center - Offset(6, 0), center - Offset(2, 0), paint);
      canvas.drawLine(center + Offset(2, 0), center + Offset(6, 0), paint);
    }
  }

  void _drawBirdLegs(Canvas canvas, Offset center, Size size) {
    final paint = Paint()
      ..color = Colors.orange
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    // Left leg
    canvas.drawLine(center + Offset(-5, 20), center + Offset(-5, 30), paint);
    // Left foot
    canvas.drawLine(center + Offset(-5, 30), center + Offset(-8, 32), paint);
    canvas.drawLine(center + Offset(-5, 30), center + Offset(-2, 32), paint);
    
    // Right leg
    canvas.drawLine(center + Offset(5, 20), center + Offset(5, 30), paint);
    // Right foot
    canvas.drawLine(center + Offset(5, 30), center + Offset(2, 32), paint);
    canvas.drawLine(center + Offset(5, 30), center + Offset(8, 32), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}