import 'package:flutter/material.dart';
import '../../models/pet.dart';

class CatVisual extends StatelessWidget {
  final Pet pet;
  final bool isBlinking;
  final bool mouthOpen;
  final double size;

  const CatVisual({
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
          // Cat body
          Positioned.fill(
            child: CustomPaint(
              painter: CatPainter(
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

class CatPainter extends CustomPainter {
  final Color color;
  final bool isBlinking;
  final bool mouthOpen;

  CatPainter({
    required this.color,
    required this.isBlinking,
    required this.mouthOpen,
  });

  void _drawLeg(Canvas canvas, Size size, Offset position, Paint paint) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: position,
          width: size.width * 0.06,
          height: size.height * 0.18,
        ),
        Radius.circular(size.width * 0.03),
      ),
      paint,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final catColor = color;
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
      ..color = catColor
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

    // Body (oval)
    final bodyRect = Rect.fromLTWH(
      size.width * 0.2,
      size.height * 0.45,
      size.width * 0.6,
      size.height * 0.3,
    );
    canvas.drawOval(bodyRect, paint);

    // Draw legs
    // Front legs
    _drawLeg(
      canvas,
      size,
      Offset(size.width * 0.3, size.height * 0.7),
      darkPaint,
    );
    _drawLeg(
      canvas,
      size,
      Offset(size.width * 0.4, size.height * 0.7),
      darkPaint,
    );

    // Back legs
    _drawLeg(
      canvas,
      size,
      Offset(size.width * 0.6, size.height * 0.7),
      darkPaint,
    );
    _drawLeg(
      canvas,
      size,
      Offset(size.width * 0.7, size.height * 0.7),
      darkPaint,
    );

    // Tail
    final tailPath = Path()
      ..moveTo(size.width * 0.8, size.height * 0.55)
      ..quadraticBezierTo(
        size.width * 0.9,
        size.height * 0.4,
        size.width * 0.9,
        size.height * 0.25,
      );

    final tailStroke = Paint()
      ..color = catColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.05
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(tailPath, tailStroke);

    // Head (circle)
    final headCenter = Offset(size.width * 0.5, size.height * 0.35);
    final headRadius = size.width * 0.3;
    canvas.drawCircle(headCenter, headRadius, paint);

    // Cat ears (triangles)
    // Left ear
    final leftEarPath = Path()
      ..moveTo(size.width * 0.35, size.height * 0.25)
      ..lineTo(size.width * 0.25, size.height * 0.05)
      ..lineTo(size.width * 0.45, size.height * 0.2)
      ..close();
    canvas.drawPath(leftEarPath, paint);

    // Inner left ear
    final innerLeftEarPath = Path()
      ..moveTo(size.width * 0.37, size.height * 0.23)
      ..lineTo(size.width * 0.3, size.height * 0.1)
      ..lineTo(size.width * 0.43, size.height * 0.2)
      ..close();
    canvas.drawPath(innerLeftEarPath, darkPaint);

    // Right ear
    final rightEarPath = Path()
      ..moveTo(size.width * 0.65, size.height * 0.25)
      ..lineTo(size.width * 0.75, size.height * 0.05)
      ..lineTo(size.width * 0.55, size.height * 0.2)
      ..close();
    canvas.drawPath(rightEarPath, paint);

    // Inner right ear
    final innerRightEarPath = Path()
      ..moveTo(size.width * 0.63, size.height * 0.23)
      ..lineTo(size.width * 0.7, size.height * 0.1)
      ..lineTo(size.width * 0.57, size.height * 0.2)
      ..close();
    canvas.drawPath(innerRightEarPath, darkPaint);

    // Muzzle (smaller circle)
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.45),
      size.width * 0.2,
      darkPaint,
    );

    // Nose
    final nosePath = Path()
      ..moveTo(size.width * 0.5, size.height * 0.4)
      ..lineTo(size.width * 0.45, size.height * 0.45)
      ..lineTo(size.width * 0.55, size.height * 0.45)
      ..close();
    canvas.drawPath(nosePath, blackPaint);

    // Whiskers
    // Left whiskers
    canvas.drawLine(
      Offset(size.width * 0.35, size.height * 0.45),
      Offset(size.width * 0.2, size.height * 0.4),
      blackPaint..strokeWidth = 1,
    );
    canvas.drawLine(
      Offset(size.width * 0.35, size.height * 0.45),
      Offset(size.width * 0.2, size.height * 0.45),
      blackPaint..strokeWidth = 1,
    );
    canvas.drawLine(
      Offset(size.width * 0.35, size.height * 0.45),
      Offset(size.width * 0.2, size.height * 0.5),
      blackPaint..strokeWidth = 1,
    );

    // Right whiskers
    canvas.drawLine(
      Offset(size.width * 0.65, size.height * 0.45),
      Offset(size.width * 0.8, size.height * 0.4),
      blackPaint..strokeWidth = 1,
    );
    canvas.drawLine(
      Offset(size.width * 0.65, size.height * 0.45),
      Offset(size.width * 0.8, size.height * 0.45),
      blackPaint..strokeWidth = 1,
    );
    canvas.drawLine(
      Offset(size.width * 0.65, size.height * 0.45),
      Offset(size.width * 0.8, size.height * 0.5),
      blackPaint..strokeWidth = 1,
    );

    // Eyes
    if (!isBlinking) {
      // Cat eyes (ovals with slits)
      // Left eye
      canvas.drawOval(
        Rect.fromLTWH(
          size.width * 0.35,
          size.height * 0.3,
          size.width * 0.1,
          size.height * 0.08,
        ),
        whitePaint,
      );

      // Left pupil (vertical slit)
      canvas.drawOval(
        Rect.fromLTWH(
          size.width * 0.39,
          size.height * 0.31,
          size.width * 0.02,
          size.height * 0.06,
        ),
        blackPaint,
      );

      // Right eye
      canvas.drawOval(
        Rect.fromLTWH(
          size.width * 0.55,
          size.height * 0.3,
          size.width * 0.1,
          size.height * 0.08,
        ),
        whitePaint,
      );

      // Right pupil (vertical slit)
      canvas.drawOval(
        Rect.fromLTWH(
          size.width * 0.59,
          size.height * 0.31,
          size.width * 0.02,
          size.height * 0.06,
        ),
        blackPaint,
      );
    } else {
      // Closed eyes (curved lines)
      final leftEyePath = Path();
      leftEyePath.moveTo(size.width * 0.35, size.height * 0.33);
      leftEyePath.quadraticBezierTo(
        size.width * 0.4,
        size.height * 0.36,
        size.width * 0.45,
        size.height * 0.33,
      );
      canvas.drawPath(
        leftEyePath,
        blackPaint
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );

      final rightEyePath = Path();
      rightEyePath.moveTo(size.width * 0.55, size.height * 0.33);
      rightEyePath.quadraticBezierTo(
        size.width * 0.6,
        size.height * 0.36,
        size.width * 0.65,
        size.height * 0.33,
      );
      canvas.drawPath(
        rightEyePath,
        blackPaint
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }

    // Mouth
    if (mouthOpen) {
      // Open mouth
      final mouthPath = Path();
      mouthPath.moveTo(size.width * 0.45, size.height * 0.48);
      mouthPath.quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.53,
        size.width * 0.55,
        size.height * 0.48,
      );
      mouthPath.close();
      canvas.drawPath(mouthPath, blackPaint);
    } else {
      // Closed mouth
      final mouthPath = Path();
      mouthPath.moveTo(size.width * 0.45, size.height * 0.48);
      mouthPath.lineTo(size.width * 0.55, size.height * 0.48);
      canvas.drawPath(
        mouthPath,
        blackPaint
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CatPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.isBlinking != isBlinking ||
        oldDelegate.mouthOpen != mouthOpen;
  }
}
