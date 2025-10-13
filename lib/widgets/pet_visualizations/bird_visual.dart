import 'package:flutter/material.dart';
import '../../models/pet.dart';

class BirdVisual extends StatelessWidget {
  const BirdVisual({
    super.key,
    required this.pet,
    required this.isBlinking,
    required this.mouthOpen,
    required this.size,
  });

  final Pet pet;
  final bool isBlinking;
  final bool mouthOpen;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          // Bird body
          Positioned.fill(
            child: CustomPaint(
              painter: BirdPainter(
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

class BirdPainter extends CustomPainter {
  final Color color;
  final bool isBlinking;
  final bool mouthOpen;

  BirdPainter({
    required this.color,
    required this.isBlinking,
    required this.mouthOpen,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final birdColor = color;
    final accentColor = HSLColor.fromColor(color)
        .withLightness(
          (HSLColor.fromColor(color).lightness - 0.3).clamp(0.0, 1.0),
        )
        .withSaturation(
          (HSLColor.fromColor(color).saturation + 0.2).clamp(0.0, 1.0),
        )
        .toColor();

    final paint = Paint()
      ..color = birdColor
      ..style = PaintingStyle.fill;

    final accentPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.fill;

    final blackPaint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.fill;

    final whitePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final orangePaint = Paint()
      ..color = Colors.orange
      ..style = PaintingStyle.fill;

    // Body (oval)
    final bodyRect = Rect.fromLTWH(
      size.width * 0.2,
      size.height * 0.3,
      size.width * 0.6,
      size.height * 0.4,
    );
    canvas.drawOval(bodyRect, paint);

    // Wings
    final leftWingPath = Path()
      ..moveTo(size.width * 0.3, size.height * 0.4)
      ..quadraticBezierTo(
        size.width * 0.1,
        size.height * 0.5,
        size.width * 0.2,
        size.height * 0.6,
      )
      ..quadraticBezierTo(
        size.width * 0.3,
        size.height * 0.55,
        size.width * 0.35,
        size.height * 0.5,
      )
      ..close();

    final rightWingPath = Path()
      ..moveTo(size.width * 0.7, size.height * 0.4)
      ..quadraticBezierTo(
        size.width * 0.9,
        size.height * 0.5,
        size.width * 0.8,
        size.height * 0.6,
      )
      ..quadraticBezierTo(
        size.width * 0.7,
        size.height * 0.55,
        size.width * 0.65,
        size.height * 0.5,
      )
      ..close();

    canvas.drawPath(leftWingPath, accentPaint);
    canvas.drawPath(rightWingPath, accentPaint);

    // Legs
    // Left leg
    canvas.drawLine(
      Offset(size.width * 0.4, size.height * 0.7),
      Offset(size.width * 0.35, size.height * 0.85),
      Paint()
        ..color = Colors.orange
        ..strokeWidth = size.width * 0.02
        ..strokeCap = StrokeCap.round,
    );

    // Right leg
    canvas.drawLine(
      Offset(size.width * 0.6, size.height * 0.7),
      Offset(size.width * 0.65, size.height * 0.85),
      Paint()
        ..color = Colors.orange
        ..strokeWidth = size.width * 0.02
        ..strokeCap = StrokeCap.round,
    );

    // Feet
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.35, size.height * 0.85),
        width: size.width * 0.08,
        height: size.width * 0.04,
      ),
      orangePaint,
    );

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.65, size.height * 0.85),
        width: size.width * 0.08,
        height: size.width * 0.04,
      ),
      orangePaint,
    );

    // Head (circle)
    canvas.drawCircle(
      Offset(size.width * 0.7, size.height * 0.3),
      size.width * 0.2,
      paint,
    );

    // Wings
    final wingPath = Path()
      ..moveTo(size.width * 0.3, size.height * 0.35)
      ..quadraticBezierTo(
        size.width * 0.15,
        size.height * 0.5,
        size.width * 0.3,
        size.height * 0.65,
      )
      ..lineTo(size.width * 0.6, size.height * 0.55)
      ..lineTo(size.width * 0.6, size.height * 0.45)
      ..close();
    canvas.drawPath(wingPath, accentPaint);

    // Tail feathers
    final tailPath = Path()
      ..moveTo(size.width * 0.2, size.height * 0.55)
      ..lineTo(size.width * 0.05, size.height * 0.6)
      ..lineTo(size.width * 0.2, size.height * 0.5)
      ..close();
    canvas.drawPath(tailPath, accentPaint);

    // Beak
    final beakPath = Path()
      ..moveTo(size.width * 0.9, size.height * 0.3)
      ..lineTo(size.width * 1.0, size.height * 0.35)
      ..lineTo(
        size.width * 0.9,
        mouthOpen ? size.height * 0.4 : size.height * 0.38,
      )
      ..close();
    canvas.drawPath(beakPath, orangePaint);

    // Eyes
    if (!isBlinking) {
      canvas.drawCircle(
        Offset(size.width * 0.8, size.height * 0.25),
        size.width * 0.05,
        whitePaint,
      );
      canvas.drawCircle(
        Offset(size.width * 0.8, size.height * 0.25),
        size.width * 0.025,
        blackPaint,
      );
    } else {
      // Closed eye
      canvas.drawLine(
        Offset(size.width * 0.75, size.height * 0.25),
        Offset(size.width * 0.85, size.height * 0.25),
        blackPaint..strokeWidth = 2,
      );
    }

    // Feet
    final leftFootPath = Path()
      ..moveTo(size.width * 0.4, size.height * 0.8)
      ..lineTo(size.width * 0.45, size.height * 0.9)
      ..lineTo(size.width * 0.5, size.height * 0.8)
      ..close();
    canvas.drawPath(leftFootPath, orangePaint);

    final rightFootPath = Path()
      ..moveTo(size.width * 0.6, size.height * 0.8)
      ..lineTo(size.width * 0.65, size.height * 0.9)
      ..lineTo(size.width * 0.7, size.height * 0.8)
      ..close();
    canvas.drawPath(rightFootPath, orangePaint);
  }

  @override
  bool shouldRepaint(covariant BirdPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.isBlinking != isBlinking ||
        oldDelegate.mouthOpen != mouthOpen;
  }
}
