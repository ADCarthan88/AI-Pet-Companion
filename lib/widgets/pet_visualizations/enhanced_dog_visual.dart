import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../models/pet.dart';

class EnhancedDogVisual extends StatelessWidget {
  const EnhancedDogVisual({
    super.key,
    required this.pet,
    required this.isBlinking,
    required this.mouthOpen,
    required this.size,
    required this.walkingPhase, // 0.0 to 1.0 for leg animation cycle
    required this.facingRight,
  });

  final Pet pet;
  final bool isBlinking;
  final bool mouthOpen;
  final double size;
  final double walkingPhase;
  final bool facingRight;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          // Dog body with walking animation
          Positioned.fill(
            child: CustomPaint(
              painter: WalkingDogPainter(
                color: pet.color,
                isBlinking: isBlinking,
                mouthOpen: mouthOpen,
                isLicking: pet.isLicking,
                currentActivity: pet.currentActivity,
                walkingPhase: walkingPhase,
                facingRight: facingRight,
              ),
            ),
          ),

          // Additional features based on current activity
          if (pet.currentActivity == PetActivity.sleeping)
            Positioned(
              top: size * 0.1,
              right: facingRight ? size * 0.2 : size * 0.6,
              child: Text('💤', style: TextStyle(fontSize: size * 0.2)),
            ),

          // Show licking animation
          if (pet.isLicking && pet.currentActivity == PetActivity.licking)
            Positioned(
              bottom: size * 0.3,
              left: facingRight ? size * 0.25 : size * 0.45,
              child: _buildLickingAnimation(),
            ),
        ],
      ),
    );
  }

  // Builds the licking animation with a small animated tongue
  Widget _buildLickingAnimation() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return CustomPaint(
          size: Size(size * 0.2, size * 0.1),
          painter: _TonguePainter(
            progress: value,
            facingRight: facingRight,
          ),
        );
      },
    );
  }
}

// Custom painter for the tongue animation with direction awareness
class _TonguePainter extends CustomPainter {
  final double progress;
  final bool facingRight;

  const _TonguePainter({
    required this.progress,
    required this.facingRight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.pinkAccent
      ..style = PaintingStyle.fill;

    final path = Path();

    // Animated tongue extending and retracting
    final extension = size.width * 0.7 * progress;
    final direction = facingRight ? 1.0 : -1.0;

    path.moveTo(facingRight ? 0 : size.width, size.height * 0.5);
    path.quadraticBezierTo(
      (facingRight ? 0 : size.width) + direction * extension * 0.5,
      size.height * (progress > 0.5 ? 0.1 : 0.9),
      (facingRight ? 0 : size.width) + direction * extension,
      size.height * 0.5,
    );
    path.quadraticBezierTo(
      (facingRight ? 0 : size.width) + direction * extension * 0.5,
      size.height * (progress > 0.5 ? 0.9 : 0.1),
      facingRight ? 0 : size.width,
      size.height * 0.5,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_TonguePainter oldDelegate) => 
      oldDelegate.progress != progress || oldDelegate.facingRight != facingRight;
}

// Enhanced dog painter with walking animation and optimized rendering
class WalkingDogPainter extends CustomPainter {
  final Color color;
  final bool isBlinking;
  final bool mouthOpen;
  final bool isLicking;
  final PetActivity currentActivity;
  final double walkingPhase; // 0.0 to 1.0 for leg animation cycle
  final bool facingRight;

  // Cache Paint objects for better performance
  static final Map<Color, Paint> _paintCache = {};
  static final Map<String, Paint> _staticPaintCache = {};

  WalkingDogPainter({
    required this.color,
    required this.isBlinking,
    required this.mouthOpen,
    required this.isLicking,
    required this.currentActivity,
    required this.walkingPhase,
    required this.facingRight,
  });

  // Optimized paint getter with caching
  Paint _getCachedPaint(Color color, PaintingStyle style) {
    final key = '${color.value}_${style.index}';
    return _staticPaintCache.putIfAbsent(key, () => Paint()
      ..color = color
      ..style = style);
  }

  Paint _getColorPaint(Color color) {
    return _paintCache.putIfAbsent(color, () => Paint()
      ..color = color
      ..style = PaintingStyle.fill);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.25;
    
    // Save canvas state for transformations
    canvas.save();
    
    // Apply horizontal flip if facing left
    if (!facingRight) {
      canvas.translate(size.width, 0);
      canvas.scale(-1.0, 1.0);
    }

    final isWalking = currentActivity == PetActivity.walking;
    
    // Calculate leg positions based on walking phase
    final legOffset = isWalking ? math.sin(walkingPhase * 2 * math.pi) * radius * 0.15 : 0.0;
    final legOffset2 = isWalking ? math.sin((walkingPhase * 2 * math.pi) + math.pi) * radius * 0.15 : 0.0;
    
    // Body bounce during walking
    final bodyBounce = isWalking ? math.sin(walkingPhase * 4 * math.pi).abs() * radius * 0.05 : 0.0;
    final adjustedCenter = Offset(center.dx, center.dy - bodyBounce);

    _drawDogBody(canvas, size, adjustedCenter, radius, legOffset, legOffset2, isWalking);
    
    // Restore canvas state
    canvas.restore();
  }

  void _drawDogBody(Canvas canvas, Size size, Offset center, double radius, 
                   double legOffset, double legOffset2, bool isWalking) {
    
    // Get cached paints for better performance
    final bodyPaint = _getColorPaint(color);
    final darkPaint = _getCachedPaint(color.withValues(alpha: 0.7), PaintingStyle.fill);
    final lightPaint = _getCachedPaint(Colors.white.withValues(alpha: 0.9), PaintingStyle.fill);
    final blackPaint = _getCachedPaint(Colors.black, PaintingStyle.fill);
    final whitePaint = _getCachedPaint(Colors.white, PaintingStyle.fill);
    final pinkPaint = _getCachedPaint(Colors.pink[300]!, PaintingStyle.fill);

    // Draw simple legs first (behind body) - more like a cute cartoon
    if (isWalking) {
      _drawSimpleLegs(canvas, center, radius, legOffset, legOffset2, darkPaint);
    } else {
      _drawStaticLegs(canvas, center, radius, darkPaint);
    }
    
    // Draw main body - oval-shaped for natural dog appearance
    final bodyCenter = Offset(center.dx, center.dy + radius * 0.1);
    final bodyRect = Rect.fromCenter(
      center: bodyCenter,
      width: radius * 2.4,  // Wider for oval shape
      height: radius * 1.8,  // Less tall for oval shape
    );
    canvas.drawOval(bodyRect, bodyPaint);
    
    // Add oval belly marking
    final bellyRect = Rect.fromCenter(
      center: Offset(bodyCenter.dx, bodyCenter.dy + radius * 0.3),
      width: radius * 1.6,
      height: radius * 1.2,
    );
    canvas.drawOval(bellyRect, lightPaint);

    // Draw head - larger and more proportional
    final headCenter = Offset(center.dx, center.dy - radius * 0.8);
    
    // Draw cute ears first (behind head) - floppy dog ears
    _drawCuteEars(canvas, headCenter, radius * 0.9, darkPaint);
    
    // Then draw head on top
    canvas.drawCircle(headCenter, radius * 0.9, bodyPaint);

    // Draw snout - smaller and cuter
    final snoutCenter = Offset(headCenter.dx, headCenter.dy + radius * 0.4);
    canvas.drawCircle(snoutCenter, radius * 0.35, bodyPaint);
    
    // Add snout highlight
    canvas.drawCircle(snoutCenter, radius * 0.25, lightPaint);

    // Draw eyes - bigger and more expressive
    _drawCuteEyes(canvas, headCenter, radius * 0.2, blackPaint, whitePaint);

    // Draw nose - small black triangle
    _drawCuteNose(canvas, snoutCenter, radius * 0.1, blackPaint);

    // Draw mouth
    if (mouthOpen) {
      _drawCuteMouth(canvas, snoutCenter, radius, blackPaint, pinkPaint);
    }

    // Draw tail - simple and happy
    final tailWag = isWalking ? math.sin(walkingPhase * 6 * math.pi) * 0.3 : 0.1;
    _drawHappyTail(canvas, bodyCenter, radius, tailWag, darkPaint);
  }

  // Simple animated legs for walking - all four legs visible
  void _drawSimpleLegs(Canvas canvas, Offset center, double radius, double legOffset, 
                      double legOffset2, Paint legPaint) {
    final legWidth = radius * 0.12;
    final legHeight = radius * 0.4;
    
    // Create paw paint (darker shade)
    final pawPaint = Paint()
      ..color = legPaint.color.withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;
    
    // All four legs with slight depth positioning
    final frontLeftLeg = Offset(center.dx + radius * 0.5, center.dy + radius * 1.0 + legOffset);
    final frontRightLeg = Offset(center.dx + radius * 0.2, center.dy + radius * 1.0 + legOffset2);
    final backLeftLeg = Offset(center.dx - radius * 0.2, center.dy + radius * 1.0 + legOffset2);
    final backRightLeg = Offset(center.dx - radius * 0.5, center.dy + radius * 1.0 + legOffset);

    // Draw all four legs
    for (final legPos in [backRightLeg, backLeftLeg, frontRightLeg, frontLeftLeg]) {
      // Draw leg
      canvas.drawOval(
        Rect.fromCenter(center: legPos, width: legWidth, height: legHeight),
        legPaint,
      );
      
      // Draw paw with different shade
      final pawCenter = Offset(legPos.dx, legPos.dy + legHeight * 0.3);
      canvas.drawCircle(pawCenter, legWidth * 0.9, pawPaint);
    }
  }

  // Static legs when not walking - all four legs visible
  void _drawStaticLegs(Canvas canvas, Offset center, double radius, Paint legPaint) {
    final legWidth = radius * 0.12;
    final legHeight = radius * 0.4;
    
    // Create paw paint (darker shade)
    final pawPaint = Paint()
      ..color = legPaint.color.withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;
    
    // Static positions for all four legs
    final frontLeftLeg = Offset(center.dx + radius * 0.5, center.dy + radius * 1.0);
    final frontRightLeg = Offset(center.dx + radius * 0.2, center.dy + radius * 1.0);
    final backLeftLeg = Offset(center.dx - radius * 0.2, center.dy + radius * 1.0);
    final backRightLeg = Offset(center.dx - radius * 0.5, center.dy + radius * 1.0);

    for (final legPos in [backRightLeg, backLeftLeg, frontRightLeg, frontLeftLeg]) {
      // Draw leg
      canvas.drawOval(
        Rect.fromCenter(center: legPos, width: legWidth, height: legHeight),
        legPaint,
      );
      
      // Draw paw with different shade
      final pawCenter = Offset(legPos.dx, legPos.dy + legHeight * 0.3);
      canvas.drawCircle(pawCenter, legWidth * 0.9, pawPaint);
    }
  }

  // Cute floppy ears - more prominent and visible
  void _drawCuteEars(Canvas canvas, Offset headCenter, double earSize, Paint earPaint) {
    // Left ear - positioned higher and more to the side
    final leftEar = Offset(headCenter.dx - earSize * 0.5, headCenter.dy - earSize * 0.5);
    canvas.drawOval(
      Rect.fromCenter(center: leftEar, width: earSize * 0.6, height: earSize * 1.0),
      earPaint,
    );
    
    // Right ear - positioned higher and more to the side
    final rightEar = Offset(headCenter.dx + earSize * 0.5, headCenter.dy - earSize * 0.5);
    canvas.drawOval(
      Rect.fromCenter(center: rightEar, width: earSize * 0.6, height: earSize * 1.0),
      earPaint,
    );
  }

  // Big expressive eyes
  void _drawCuteEyes(Canvas canvas, Offset headCenter, double eyeSize, Paint blackPaint, Paint whitePaint) {
    final leftEye = Offset(headCenter.dx - eyeSize * 1.2, headCenter.dy - eyeSize * 0.3);
    final rightEye = Offset(headCenter.dx + eyeSize * 1.2, headCenter.dy - eyeSize * 0.3);
    
    for (final eyeCenter in [leftEye, rightEye]) {
      if (isBlinking) {
        // Closed eye - curved line
        final eyePath = Path()
          ..moveTo(eyeCenter.dx - eyeSize * 0.8, eyeCenter.dy)
          ..quadraticBezierTo(
            eyeCenter.dx, eyeCenter.dy + eyeSize * 0.2,
            eyeCenter.dx + eyeSize * 0.8, eyeCenter.dy,
          );
        canvas.drawPath(
          eyePath,
          blackPaint..style = PaintingStyle.stroke..strokeWidth = 3,
        );
        blackPaint.style = PaintingStyle.fill;
      } else {
        // Open eye with shine
        canvas.drawCircle(eyeCenter, eyeSize, whitePaint);
        canvas.drawCircle(eyeCenter, eyeSize * 0.6, blackPaint);
        
        // Eye shine
        final shineCenter = Offset(eyeCenter.dx - eyeSize * 0.3, eyeCenter.dy - eyeSize * 0.3);
        canvas.drawCircle(shineCenter, eyeSize * 0.25, whitePaint);
      }
    }
  }

  // Small triangular nose
  void _drawCuteNose(Canvas canvas, Offset snoutCenter, double noseSize, Paint blackPaint) {
    final nosePath = Path()
      ..moveTo(snoutCenter.dx, snoutCenter.dy - noseSize)
      ..lineTo(snoutCenter.dx - noseSize, snoutCenter.dy + noseSize * 0.5)
      ..lineTo(snoutCenter.dx + noseSize, snoutCenter.dy + noseSize * 0.5)
      ..close();
    
    canvas.drawPath(nosePath, blackPaint);
  }

  // Happy mouth with tongue
  void _drawCuteMouth(Canvas canvas, Offset snoutCenter, double radius, Paint blackPaint, Paint pinkPaint) {
    // Mouth curve
    final mouthPath = Path()
      ..moveTo(snoutCenter.dx - radius * 0.2, snoutCenter.dy + radius * 0.3)
      ..quadraticBezierTo(
        snoutCenter.dx, snoutCenter.dy + radius * 0.5,
        snoutCenter.dx + radius * 0.2, snoutCenter.dy + radius * 0.3,
      );
    
    canvas.drawPath(
      mouthPath,
      blackPaint..style = PaintingStyle.stroke..strokeWidth = 2,
    );
    blackPaint.style = PaintingStyle.fill;
    
    // Pink tongue
    if (mouthOpen) {
      final tongueCenter = Offset(snoutCenter.dx, snoutCenter.dy + radius * 0.4);
      canvas.drawOval(
        Rect.fromCenter(center: tongueCenter, width: radius * 0.3, height: radius * 0.2),
        pinkPaint,
      );
    }
  }

  // Wagging tail
  void _drawHappyTail(Canvas canvas, Offset bodyCenter, double radius, double tailWag, Paint tailPaint) {
    final tailStart = Offset(bodyCenter.dx - radius * 0.9, bodyCenter.dy - radius * 0.3);
    final tailMid = Offset(
      bodyCenter.dx - radius * 1.3, 
      bodyCenter.dy - radius * 0.8 + tailWag
    );
    final tailEnd = Offset(
      bodyCenter.dx - radius * 1.1, 
      bodyCenter.dy - radius * 1.2 + tailWag * 0.8
    );
    
    final tailPath = Path()
      ..moveTo(tailStart.dx, tailStart.dy)
      ..quadraticBezierTo(tailMid.dx, tailMid.dy, tailEnd.dx, tailEnd.dy);
    
    canvas.drawPath(
      tailPath,
      tailPaint..style = PaintingStyle.stroke..strokeWidth = radius * 0.15,
    );
    tailPaint.style = PaintingStyle.fill;
  }

  @override
  bool shouldRepaint(covariant WalkingDogPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.isBlinking != isBlinking ||
        oldDelegate.mouthOpen != mouthOpen ||
        oldDelegate.isLicking != isLicking ||
        oldDelegate.currentActivity != currentActivity ||
        oldDelegate.walkingPhase != walkingPhase ||
        oldDelegate.facingRight != facingRight;
  }

  // Clear paint cache when needed (memory management)
  static void clearPaintCache() {
    _paintCache.clear();
    _staticPaintCache.clear();
  }
}