import 'package:flutter/material.dart';
import '../../models/pet.dart';

class DogVisual extends StatelessWidget {
  final Pet pet;
  final bool isBlinking;
  final bool mouthOpen;
  final double size;

  const DogVisual({
    required this.pet,
    required this.isBlinking,
    required this.mouthOpen,
    required this.size,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          // Dog body
          Positioned.fill(
            child: CustomPaint(
              painter: DogPainter(
                color: pet.color,
                isBlinking: isBlinking,
                mouthOpen: mouthOpen,
              ),
            ),
          ),

          // Additional features based on current activity
          if (pet.currentActivity == PetActivity.sleeping)
            Positioned(
              top: size * 0.1,
              right: size * 0.2,
              child: Text('💤', style: TextStyle(fontSize: size * 0.2)),
            ),
        ],
      ),
    );
  }
}

class DogPainter extends CustomPainter {
  final Color color;
  final bool isBlinking;
  final bool mouthOpen;

  DogPainter({
    required this.color,
    required this.isBlinking,
    required this.mouthOpen,
  });

  void _drawLeg(Canvas canvas, Size size, Offset position, Paint paint) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: position,
          width: size.width * 0.08,
          height: size.height * 0.2,
        ),
        Radius.circular(size.width * 0.04),
      ),
      paint,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final dogColor = color;
    final darkColor = HSLColor.fromColor(color)
        .withLightness(
          (HSLColor.fromColor(color).lightness - 0.2).clamp(0.0, 1.0),
        )
        .toColor();
    final lightColor = HSLColor.fromColor(color)
        .withLightness(
          (HSLColor.fromColor(color).lightness + 0.1).clamp(0.0, 1.0),
        )
        .toColor();

    final paint = Paint()
      ..color = dogColor
      ..style = PaintingStyle.fill;

    final darkPaint = Paint()
      ..color = darkColor
      ..style = PaintingStyle.fill;

    final lightPaint = Paint()
      ..color = lightColor
      ..style = PaintingStyle.fill;

    final blackPaint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.fill;

    final whitePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Draw body first (oval)
    final bodyRect = Rect.fromLTWH(
      size.width * 0.15,
      size.height * 0.45,
      size.width * 0.7,
      size.height * 0.35,
    );
    canvas.drawOval(bodyRect, paint);

    // Draw legs
    // Front legs
    _drawLeg(
      canvas,
      size,
      Offset(size.width * 0.25, size.height * 0.75),
      darkPaint,
    );
    _drawLeg(
      canvas,
      size,
      Offset(size.width * 0.35, size.height * 0.75),
      darkPaint,
    );

    // Back legs
    _drawLeg(
      canvas,
      size,
      Offset(size.width * 0.65, size.height * 0.75),
      darkPaint,
    );
    _drawLeg(
      canvas,
      size,
      Offset(size.width * 0.75, size.height * 0.75),
      darkPaint,
    );

    // Tail
    final tailPath = Path()
      ..moveTo(size.width * 0.85, size.height * 0.55)
      ..quadraticBezierTo(
        size.width * 0.95,
        size.height * 0.45,
        size.width * 0.9,
        size.height * 0.35,
      );

    final tailStroke = Paint()
      ..color = dogColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.07
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(tailPath, tailStroke);

    // Head (rounded rectangle)
    final headRect = Rect.fromLTWH(
      size.width * 0.2,
      size.height * 0.2,
      size.width * 0.6,
      size.height * 0.35,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(headRect, Radius.circular(size.width * 0.3)),
      paint,
    );

    // Snout
    final snoutRect = Rect.fromLTWH(
      size.width * 0.3,
      size.height * 0.4,
      size.width * 0.4,
      size.height * 0.3,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(snoutRect, Radius.circular(size.width * 0.15)),
      darkPaint,
    );

    // Nose
    canvas.drawOval(
      Rect.fromLTWH(
        size.width * 0.45,
        size.height * 0.45,
        size.width * 0.1,
        size.height * 0.08,
      ),
      blackPaint,
    );

    // Left ear
    final leftEarPath = Path()
      ..moveTo(size.width * 0.25, size.height * 0.25)
      ..lineTo(size.width * 0.1, size.height * 0.1)
      ..lineTo(size.width * 0.3, size.height * 0.2)
      ..close();
    canvas.drawPath(leftEarPath, darkPaint);

    // Right ear
    final rightEarPath = Path()
      ..moveTo(size.width * 0.75, size.height * 0.25)
      ..lineTo(size.width * 0.9, size.height * 0.1)
      ..lineTo(size.width * 0.7, size.height * 0.2)
      ..close();
    canvas.drawPath(rightEarPath, darkPaint);

    // Eyes
    if (!isBlinking) {
      // Left eye
      canvas.drawOval(
        Rect.fromLTWH(
          size.width * 0.35,
          size.height * 0.3,
          size.width * 0.08,
          size.height * 0.1,
        ),
        blackPaint,
      );

      // Right eye
      canvas.drawOval(
        Rect.fromLTWH(
          size.width * 0.57,
          size.height * 0.3,
          size.width * 0.08,
          size.height * 0.1,
        ),
        blackPaint,
      );

      // Eye highlights
      canvas.drawOval(
        Rect.fromLTWH(
          size.width * 0.36,
          size.height * 0.31,
          size.width * 0.03,
          size.height * 0.03,
        ),
        whitePaint,
      );
      canvas.drawOval(
        Rect.fromLTWH(
          size.width * 0.58,
          size.height * 0.31,
          size.width * 0.03,
          size.height * 0.03,
        ),
        whitePaint,
      );
    } else {
      // Closed eyes (lines)
      canvas.drawLine(
        Offset(size.width * 0.35, size.height * 0.35),
        Offset(size.width * 0.43, size.height * 0.35),
        blackPaint..strokeWidth = 2,
      );
      canvas.drawLine(
        Offset(size.width * 0.57, size.height * 0.35),
        Offset(size.width * 0.65, size.height * 0.35),
        blackPaint..strokeWidth = 2,
      );
    }

    // Mouth
    if (mouthOpen) {
      // Open mouth
      final mouthRect = Rect.fromLTWH(
        size.width * 0.4,
        size.height * 0.55,
        size.width * 0.2,
        size.height * 0.1,
      );
      canvas.drawOval(mouthRect, blackPaint);

      // Tongue
      final tongueRect = Rect.fromLTWH(
        size.width * 0.43,
        size.height * 0.58,
        size.width * 0.14,
        size.height * 0.05,
      );
      canvas.drawOval(tongueRect, Paint()..color = Colors.pinkAccent);
    } else {
      // Closed mouth (smile)
      final mouthPath = Path();
      mouthPath.moveTo(size.width * 0.4, size.height * 0.55);
      mouthPath.quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.6,
        size.width * 0.6,
        size.height * 0.55,
      );
      canvas.drawPath(
        mouthPath,
        blackPaint
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
  }

  @override
  bool shouldRepaint(covariant DogPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.isBlinking != isBlinking ||
        oldDelegate.mouthOpen != mouthOpen;
  }
}
