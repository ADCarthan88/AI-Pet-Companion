import 'package:flutter/material.dart';
import '../../models/pet.dart';

class LionVisual extends StatelessWidget {
  final Pet pet;
  final bool isBlinking;
  final bool mouthOpen;
  final double size;

  const LionVisual({
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
          // Lion body
          Positioned.fill(
            child: CustomPaint(
              painter: LionPainter(
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

class LionPainter extends CustomPainter {
  final Color color;
  final bool isBlinking;
  final bool mouthOpen;

  LionPainter({
    required this.color,
    required this.isBlinking,
    required this.mouthOpen,
  });

  void _drawLeg(Canvas canvas, Size size, Offset position, Paint paint) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: position,
          width: size.width * 0.09,
          height: size.height * 0.25,
        ),
        Radius.circular(size.width * 0.04),
      ),
      paint,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.4;

    // Colors
    final lionColor = color;
    final darkColor = HSLColor.fromColor(color)
        .withLightness(
          (HSLColor.fromColor(color).lightness - 0.2).clamp(0.0, 1.0),
        )
        .toColor();
    final maneColor = color.withRed((color.red + 20).clamp(0, 255));

    final Paint paint = Paint()
      ..color = lionColor
      ..style = PaintingStyle.fill;

    final Paint darkPaint = Paint()
      ..color = darkColor
      ..style = PaintingStyle.fill;

    // Body
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy + radius * 0.7),
        width: radius * 2.2,
        height: radius * 1.4,
      ),
      paint,
    );

    // Tail
    final tailPath = Path()
      ..moveTo(center.dx + radius * 0.8, center.dy + radius * 0.8)
      ..quadraticBezierTo(
        center.dx + radius * 1.2,
        center.dy + radius * 1.0,
        center.dx + radius * 0.9,
        center.dy + radius * 1.3,
      );

    final tailStroke = Paint()
      ..color = lionColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.1
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(tailPath, tailStroke);

    // Tail tuft
    canvas.drawCircle(
      Offset(center.dx + radius * 0.9, center.dy + radius * 1.3),
      radius * 0.15,
      Paint()..color = darkColor,
    );

    // Legs
    _drawLeg(
      canvas,
      size,
      Offset(center.dx - radius * 0.6, center.dy + radius * 1.2),
      darkPaint,
    );
    _drawLeg(
      canvas,
      size,
      Offset(center.dx - radius * 0.3, center.dy + radius * 1.2),
      darkPaint,
    );
    _drawLeg(
      canvas,
      size,
      Offset(center.dx + radius * 0.3, center.dy + radius * 1.2),
      darkPaint,
    );
    _drawLeg(
      canvas,
      size,
      Offset(center.dx + radius * 0.6, center.dy + radius * 1.2),
      darkPaint,
    );

    // Head
    final Paint headPaint = Paint()
      ..color = lionColor
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(center.dx, center.dy - radius * 0.1),
      radius * 0.9,
      headPaint,
    );

    // Lion's Mane
    final manePaint = Paint()
      ..color = maneColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.5;

    canvas.drawCircle(
      Offset(center.dx, center.dy - radius * 0.1),
      radius * 1.1,
      manePaint,
    ); // Face
    final facePaint = Paint()
  ..color = color.withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius * 0.85, facePaint);

    // Eyes
    final eyePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Positions for eyes
    final leftEyePosition = Offset(
      center.dx - radius * 0.4,
      center.dy - radius * 0.1,
    );
    final rightEyePosition = Offset(
      center.dx + radius * 0.4,
      center.dy - radius * 0.1,
    );

    // Draw eyes
    if (!isBlinking) {
      // White part of eyes
      canvas.drawCircle(leftEyePosition, radius * 0.18, eyePaint);
      canvas.drawCircle(rightEyePosition, radius * 0.18, eyePaint);

      // Pupils (vertical for lion)
      final pupilPaint = Paint()
        ..color = Colors.black
        ..style = PaintingStyle.fill;

      // Lion pupils (slightly elongated vertically)
      canvas.drawOval(
        Rect.fromCenter(
          center: leftEyePosition,
          width: radius * 0.1,
          height: radius * 0.2,
        ),
        pupilPaint,
      );

      canvas.drawOval(
        Rect.fromCenter(
          center: rightEyePosition,
          width: radius * 0.1,
          height: radius * 0.2,
        ),
        pupilPaint,
      );
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

    // Nose (triangle for lion)
    final nosePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    final nosePath = Path()
      ..moveTo(center.dx, center.dy + radius * 0.2)
      ..lineTo(center.dx - radius * 0.2, center.dy)
      ..lineTo(center.dx + radius * 0.2, center.dy)
      ..close();

    canvas.drawPath(nosePath, nosePaint);

    // Mouth
    final mouthPaint = Paint()
      ..color = Colors.black
      ..style = mouthOpen ? PaintingStyle.fill : PaintingStyle.stroke
      ..strokeWidth = 2;

    if (mouthOpen) {
      // Open mouth with teeth
      final mouthPath = Path()
        ..moveTo(center.dx - radius * 0.3, center.dy + radius * 0.3)
        ..quadraticBezierTo(
          center.dx,
          center.dy + radius * 0.6,
          center.dx + radius * 0.3,
          center.dy + radius * 0.3,
        )
        ..close();

      canvas.drawPath(mouthPath, mouthPaint);

      // Add teeth
      final teethPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;

      // Left fang
      final leftFangPath = Path()
        ..moveTo(center.dx - radius * 0.15, center.dy + radius * 0.3)
        ..lineTo(center.dx - radius * 0.1, center.dy + radius * 0.45)
        ..lineTo(center.dx - radius * 0.2, center.dy + radius * 0.45)
        ..close();

      // Right fang
      final rightFangPath = Path()
        ..moveTo(center.dx + radius * 0.15, center.dy + radius * 0.3)
        ..lineTo(center.dx + radius * 0.1, center.dy + radius * 0.45)
        ..lineTo(center.dx + radius * 0.2, center.dy + radius * 0.45)
        ..close();

      canvas.drawPath(leftFangPath, teethPaint);
      canvas.drawPath(rightFangPath, teethPaint);
    } else {
      // Closed mouth (simple curve)
      final mouthPath = Path()
        ..moveTo(center.dx - radius * 0.25, center.dy + radius * 0.3)
        ..quadraticBezierTo(
          center.dx,
          center.dy + radius * 0.4,
          center.dx + radius * 0.25,
          center.dy + radius * 0.3,
        );

      canvas.drawPath(mouthPath, mouthPaint);
    }

    // Whiskers for lion (subtle)
    final whiskerPaint = Paint()
  ..color = Colors.black.withValues(alpha: 0.5)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Left whiskers
    canvas.drawLine(
      Offset(center.dx - radius * 0.2, center.dy + radius * 0.2),
      Offset(center.dx - radius * 0.5, center.dy + radius * 0.15),
      whiskerPaint,
    );

    canvas.drawLine(
      Offset(center.dx - radius * 0.2, center.dy + radius * 0.3),
      Offset(center.dx - radius * 0.5, center.dy + radius * 0.35),
      whiskerPaint,
    );

    // Right whiskers
    canvas.drawLine(
      Offset(center.dx + radius * 0.2, center.dy + radius * 0.2),
      Offset(center.dx + radius * 0.5, center.dy + radius * 0.15),
      whiskerPaint,
    );

    canvas.drawLine(
      Offset(center.dx + radius * 0.2, center.dy + radius * 0.3),
      Offset(center.dx + radius * 0.5, center.dy + radius * 0.35),
      whiskerPaint,
    );

    // Lion ears
    final earPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Left ear
    final leftEarPath = Path()
      ..moveTo(center.dx - radius * 0.6, center.dy - radius * 0.5)
      ..lineTo(center.dx - radius * 0.8, center.dy - radius * 0.9)
      ..lineTo(center.dx - radius * 0.4, center.dy - radius * 0.7)
      ..close();

    // Right ear
    final rightEarPath = Path()
      ..moveTo(center.dx + radius * 0.6, center.dy - radius * 0.5)
      ..lineTo(center.dx + radius * 0.8, center.dy - radius * 0.9)
      ..lineTo(center.dx + radius * 0.4, center.dy - radius * 0.7)
      ..close();

    canvas.drawPath(leftEarPath, earPaint);
    canvas.drawPath(rightEarPath, earPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
