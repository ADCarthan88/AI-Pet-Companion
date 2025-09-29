import 'package:flutter/material.dart';
import '../../models/pet.dart';

class PenguinVisual extends StatelessWidget {
  final Pet pet;
  final bool isBlinking;
  final bool mouthOpen;
  final double size;

  const PenguinVisual({
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
          // Penguin body
          Positioned.fill(
            child: CustomPaint(
              painter: PenguinPainter(
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

class PenguinPainter extends CustomPainter {
  final Color color;
  final bool isBlinking;
  final bool mouthOpen;

  PenguinPainter({
    required this.color,
    required this.isBlinking,
    required this.mouthOpen,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.4;

    // Colors - regardless of the user color, we'll make a proper penguin
    final blackColor = Colors.black;
    final whiteColor = Colors.white;
    final orangeColor = Colors.orange.shade700;

    // Body (oval)
    final bodyPaint = Paint()
      ..color = blackColor
      ..style = PaintingStyle.fill;

    canvas.drawOval(
      Rect.fromCenter(
        center: center,
        width: radius * 1.7,
        height: radius * 2.2,
      ),
      bodyPaint,
    );

    // White belly
    final bellyPaint = Paint()
      ..color = whiteColor
      ..style = PaintingStyle.fill;

    final bellyPath = Path()
      ..addOval(
        Rect.fromCenter(
          center: Offset(center.dx, center.dy + radius * 0.3),
          width: radius * 1.4,
          height: radius * 1.6,
        ),
      );

    canvas.drawPath(bellyPath, bellyPaint);

    // Wings (flippers)
    final wingPaint = Paint()
      ..color = blackColor
      ..style = PaintingStyle.fill;

    // Left wing
    canvas.save();
    canvas.translate(center.dx - radius * 0.85, center.dy);
    canvas.rotate(-0.2);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(0, 0),
        width: radius * 0.5,
        height: radius * 1.4,
      ),
      wingPaint,
    );
    canvas.restore();

    // Right wing
    canvas.save();
    canvas.translate(center.dx + radius * 0.85, center.dy);
    canvas.rotate(0.2);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(0, 0),
        width: radius * 0.5,
        height: radius * 1.4,
      ),
      wingPaint,
    );
    canvas.restore();

    // Feet
    final feetPaint = Paint()
      ..color = orangeColor
      ..style = PaintingStyle.fill;

    // Left foot
    canvas.save();
    canvas.translate(center.dx - radius * 0.3, center.dy + radius * 1.05);
    canvas.rotate(-0.3);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(0, 0),
        width: radius * 0.6,
        height: radius * 0.2,
      ),
      feetPaint,
    );
    canvas.restore();

    // Right foot
    canvas.save();
    canvas.translate(center.dx + radius * 0.3, center.dy + radius * 1.05);
    canvas.rotate(0.3);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(0, 0),
        width: radius * 0.6,
        height: radius * 0.2,
      ),
      feetPaint,
    );
    canvas.restore();

    // Head
    final headPaint = Paint()
      ..color = blackColor
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(center.dx, center.dy - radius * 0.5),
      radius * 0.75,
      headPaint,
    );

    // Face (white patch)
    final facePaint = Paint()
      ..color = whiteColor
      ..style = PaintingStyle.fill;

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy - radius * 0.4),
        width: radius * 1.2,
        height: radius * 0.9,
      ),
      facePaint,
    );

    // Eyes
    final eyePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Positions for eyes
    final leftEyePosition = Offset(
      center.dx - radius * 0.35,
      center.dy - radius * 0.7,
    );
    final rightEyePosition = Offset(
      center.dx + radius * 0.35,
      center.dy - radius * 0.7,
    );

    // Draw eyes
    if (!isBlinking) {
      // White part of eyes
      canvas.drawCircle(leftEyePosition, radius * 0.15, eyePaint);
      canvas.drawCircle(rightEyePosition, radius * 0.15, eyePaint);

      // Pupils
      final pupilPaint = Paint()
        ..color = Colors.black
        ..style = PaintingStyle.fill;

      canvas.drawCircle(leftEyePosition, radius * 0.07, pupilPaint);
      canvas.drawCircle(rightEyePosition, radius * 0.07, pupilPaint);
    } else {
      // Closed eyes (simple lines)
      final closedEyePaint = Paint()
        ..color = Colors.black
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke;

      canvas.drawLine(
        Offset(leftEyePosition.dx - radius * 0.12, leftEyePosition.dy),
        Offset(leftEyePosition.dx + radius * 0.12, leftEyePosition.dy),
        closedEyePaint,
      );

      canvas.drawLine(
        Offset(rightEyePosition.dx - radius * 0.12, rightEyePosition.dy),
        Offset(rightEyePosition.dx + radius * 0.12, rightEyePosition.dy),
        closedEyePaint,
      );
    }

    // Beak
    final beakPaint = Paint()
      ..color = orangeColor
      ..style = PaintingStyle.fill;

    final beakPath = Path()
      ..moveTo(center.dx, center.dy - radius * 0.4)
      ..lineTo(center.dx - radius * 0.2, center.dy - radius * 0.3)
      ..lineTo(center.dx + radius * 0.2, center.dy - radius * 0.3)
      ..close();

    canvas.drawPath(beakPath, beakPaint);

    // Add a small black tail
    final tailPaint = Paint()
      ..color = blackColor
      ..style = PaintingStyle.fill;

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy + radius * 1.1),
        width: radius * 0.8,
        height: radius * 0.3,
      ),
      tailPaint,
    );

    // Mouth/Beak opening
    if (mouthOpen) {
      final mouthPaint = Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      final mouthPath = Path()
        ..moveTo(center.dx - radius * 0.1, center.dy - radius * 0.25)
        ..lineTo(center.dx, center.dy - radius * 0.15)
        ..lineTo(center.dx + radius * 0.1, center.dy - radius * 0.25);

      canvas.drawPath(mouthPath, mouthPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
