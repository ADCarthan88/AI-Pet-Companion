import 'package:flutter/material.dart';
import '../../models/pet.dart';

class RabbitVisual extends StatelessWidget {
  final Pet pet;
  final bool isBlinking;
  final bool mouthOpen;
  final double size;

  const RabbitVisual({
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
          // Rabbit body
          Positioned.fill(
            child: CustomPaint(
              painter: RabbitPainter(
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

class RabbitPainter extends CustomPainter {
  final Color color;
  final bool isBlinking;
  final bool mouthOpen;

  RabbitPainter({
    required this.color,
    required this.isBlinking,
    required this.mouthOpen,
  });

  void _drawLeg(Canvas canvas, Size size, Offset position, Paint paint) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: position,
          width: size.width * 0.07,
          height: size.height * 0.15,
        ),
        Radius.circular(size.width * 0.035),
      ),
      paint,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.4;

    // Colors
    final rabbitColor = color;
    final darkColor = HSLColor.fromColor(color)
        .withLightness(
          (HSLColor.fromColor(color).lightness - 0.2).clamp(0.0, 1.0),
        )
        .toColor();

    final Paint paint = Paint()
      ..color = rabbitColor
      ..style = PaintingStyle.fill;

    final Paint darkPaint = Paint()
      ..color = darkColor
      ..style = PaintingStyle.fill;

    // Body (rounded oval for rabbit)
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy + radius * 0.4),
        width: radius * 2.0,
        height: radius * 1.4,
      ),
      paint,
    );

    // Fluffy tail
    canvas.drawCircle(
      Offset(center.dx + radius * 0.8, center.dy + radius * 0.5),
      radius * 0.25,
      Paint()..color = Colors.white.withOpacity(0.9),
    );

    // Front legs
    _drawLeg(
      canvas,
      size,
      Offset(center.dx - radius * 0.5, center.dy + radius * 0.9),
      darkPaint,
    );
    _drawLeg(
      canvas,
      size,
      Offset(center.dx - radius * 0.3, center.dy + radius * 0.9),
      darkPaint,
    );

    // Back legs (slightly bigger)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(center.dx + radius * 0.3, center.dy + radius * 1.0),
          width: size.width * 0.09,
          height: size.height * 0.18,
        ),
        Radius.circular(size.width * 0.04),
      ),
      darkPaint,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(center.dx + radius * 0.5, center.dy + radius * 1.0),
          width: size.width * 0.09,
          height: size.height * 0.18,
        ),
        Radius.circular(size.width * 0.04),
      ),
      darkPaint,
    );

    // Head (slightly oval for rabbit)
    final Paint headPaint = Paint()
      ..color = rabbitColor
      ..style = PaintingStyle.fill;

    // Draw slightly oval head
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx - radius * 0.1, center.dy - radius * 0.2),
        width: radius * 1.7,
        height: radius * 1.9,
      ),
      headPaint,
    ); // Ears (long and upright)
    final earPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Left ear
    final leftEarPath = Path()
      ..moveTo(center.dx - radius * 0.5, center.dy - radius * 0.6)
      ..lineTo(center.dx - radius * 0.8, center.dy - radius * 1.8)
      ..lineTo(center.dx - radius * 0.2, center.dy - radius * 1.7)
      ..close();

    // Right ear
    final rightEarPath = Path()
      ..moveTo(center.dx + radius * 0.5, center.dy - radius * 0.6)
      ..lineTo(center.dx + radius * 0.8, center.dy - radius * 1.8)
      ..lineTo(center.dx + radius * 0.2, center.dy - radius * 1.7)
      ..close();

    canvas.drawPath(leftEarPath, earPaint);
    canvas.drawPath(rightEarPath, earPaint);

    // Inner ear color
    final innerEarPaint = Paint()
      ..color = color.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    // Left inner ear
    final leftInnerEarPath = Path()
      ..moveTo(center.dx - radius * 0.5, center.dy - radius * 0.7)
      ..lineTo(center.dx - radius * 0.7, center.dy - radius * 1.6)
      ..lineTo(center.dx - radius * 0.3, center.dy - radius * 1.5)
      ..close();

    // Right inner ear
    final rightInnerEarPath = Path()
      ..moveTo(center.dx + radius * 0.5, center.dy - radius * 0.7)
      ..lineTo(center.dx + radius * 0.7, center.dy - radius * 1.6)
      ..lineTo(center.dx + radius * 0.3, center.dy - radius * 1.5)
      ..close();

    canvas.drawPath(leftInnerEarPath, innerEarPaint);
    canvas.drawPath(rightInnerEarPath, innerEarPaint);

    // Eyes
    final eyePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Positions for eyes
    final leftEyePosition = Offset(
      center.dx - radius * 0.5,
      center.dy - radius * 0.2,
    );
    final rightEyePosition = Offset(
      center.dx + radius * 0.5,
      center.dy - radius * 0.2,
    );

    // Draw eyes
    if (!isBlinking) {
      // White part of eyes
      canvas.drawCircle(leftEyePosition, radius * 0.2, eyePaint);
      canvas.drawCircle(rightEyePosition, radius * 0.2, eyePaint);

      // Pupils
      final pupilPaint = Paint()
        ..color = Colors.black
        ..style = PaintingStyle.fill;

      canvas.drawCircle(leftEyePosition, radius * 0.1, pupilPaint);
      canvas.drawCircle(rightEyePosition, radius * 0.1, pupilPaint);
    } else {
      // Closed eyes (simple lines)
      final closedEyePaint = Paint()
        ..color = Colors.black
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke;

      canvas.drawLine(
        Offset(leftEyePosition.dx - radius * 0.15, leftEyePosition.dy),
        Offset(leftEyePosition.dx + radius * 0.15, leftEyePosition.dy),
        closedEyePaint,
      );

      canvas.drawLine(
        Offset(rightEyePosition.dx - radius * 0.15, rightEyePosition.dy),
        Offset(rightEyePosition.dx + radius * 0.15, rightEyePosition.dy),
        closedEyePaint,
      );
    }

    // Nose (small triangle for rabbit)
    final nosePaint = Paint()
      ..color = Colors.pink[200]!
      ..style = PaintingStyle.fill;

    final nosePath = Path()
      ..moveTo(center.dx, center.dy + radius * 0.1)
      ..lineTo(center.dx - radius * 0.15, center.dy - radius * 0.05)
      ..lineTo(center.dx + radius * 0.15, center.dy - radius * 0.05)
      ..close();

    canvas.drawPath(nosePath, nosePaint);

    // Mouth
    final mouthPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    if (mouthOpen) {
      // Open mouth for rabbit (small oval)
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(center.dx, center.dy + radius * 0.3),
          width: radius * 0.3,
          height: radius * 0.2,
        ),
        mouthPaint,
      );
    } else {
      // Closed mouth (simple curve)
      final mouthPath = Path()
        ..moveTo(center.dx - radius * 0.15, center.dy + radius * 0.3)
        ..quadraticBezierTo(
          center.dx,
          center.dy + radius * 0.4,
          center.dx + radius * 0.15,
          center.dy + radius * 0.3,
        );

      canvas.drawPath(mouthPath, mouthPaint);
    }

    // Whiskers
    final whiskerPaint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Left whiskers
    canvas.drawLine(
      Offset(center.dx - radius * 0.2, center.dy + radius * 0.1),
      Offset(center.dx - radius * 0.7, center.dy),
      whiskerPaint,
    );

    canvas.drawLine(
      Offset(center.dx - radius * 0.2, center.dy + radius * 0.2),
      Offset(center.dx - radius * 0.7, center.dy + radius * 0.2),
      whiskerPaint,
    );

    // Right whiskers
    canvas.drawLine(
      Offset(center.dx + radius * 0.2, center.dy + radius * 0.1),
      Offset(center.dx + radius * 0.7, center.dy),
      whiskerPaint,
    );

    canvas.drawLine(
      Offset(center.dx + radius * 0.2, center.dy + radius * 0.2),
      Offset(center.dx + radius * 0.7, center.dy + radius * 0.2),
      whiskerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
