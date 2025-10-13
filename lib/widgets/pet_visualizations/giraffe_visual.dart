import 'package:flutter/material.dart';
import '../../models/pet.dart';

class GiraffeVisual extends StatelessWidget {
  const GiraffeVisual({
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
          // Giraffe body
          Positioned.fill(
            child: CustomPaint(
              painter: GiraffePainter(
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

class GiraffePainter extends CustomPainter {
  final Color color;
  final bool isBlinking;
  final bool mouthOpen;

  GiraffePainter({
    required this.color,
    required this.isBlinking,
    required this.mouthOpen,
  });

  void _drawLeg(
    Canvas canvas,
    Size size,
    Offset position,
    Paint paint,
    Paint spotPaint,
  ) {
    // Draw the leg
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: position,
          width: size.width * 0.08,
          height: size.height * 0.25,
        ),
        Radius.circular(size.width * 0.04),
      ),
      paint,
    );

    // Add spots to the leg
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(position.dx, position.dy - size.height * 0.08),
        width: size.width * 0.06,
        height: size.height * 0.04,
      ),
      spotPaint,
    );

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(position.dx, position.dy + size.height * 0.04),
        width: size.width * 0.06,
        height: size.height * 0.04,
      ),
      spotPaint,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.3;

    // Colors
    final baseColor = color;
  // Replace deprecated channel getters .red/.green using fractional components .r/.g
    final int redCh = (color.r * 255.0).round();
    final int greenCh = (color.g * 255.0).round();
    final spotColor = color
        .withValues(red: ((redCh - 40).clamp(0, 255)) / 255.0)
        .withValues(green: ((greenCh - 40).clamp(0, 255)) / 255.0);
    final darkColor = HSLColor.fromColor(color)
        .withLightness(
          (HSLColor.fromColor(color).lightness - 0.2).clamp(0.0, 1.0),
        )
        .toColor();

    final Paint mainPaint = Paint()
      ..color = baseColor
      ..style = PaintingStyle.fill;

    // Body
    final bodyPath = Path()
      ..addOval(
        Rect.fromCenter(
          center: Offset(center.dx, center.dy + radius * 1.2),
          width: radius * 1.8,
          height: radius * 1.2,
        ),
      );

    canvas.drawPath(bodyPath, mainPaint);

    // Body spots
    for (int i = 0; i < 8; i++) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(
            center.dx - radius * 0.6 + (i % 3) * radius * 0.6,
            center.dy + radius * 0.9 + (i ~/ 3) * radius * 0.6,
          ),
          width: radius * 0.25,
          height: radius * 0.2,
        ),
        Paint()
          ..color = spotColor
          ..style = PaintingStyle.fill,
      );
    }

    // Tail
    final tailPath = Path()
      ..moveTo(center.dx, center.dy + radius * 1.7)
      ..lineTo(center.dx, center.dy + radius * 2.2);

    final tailPaint = Paint()
      ..color = darkColor
      ..strokeWidth = radius * 0.08
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawPath(tailPath, tailPaint);

    // Tail tuft
    canvas.drawCircle(
      Offset(center.dx, center.dy + radius * 2.2),
      radius * 0.1,
      Paint()..color = darkColor,
    );

    // Legs
    _drawLeg(
      canvas,
      size,
      Offset(center.dx - radius * 0.5, center.dy + radius * 2.0),
      mainPaint,
      Paint()
        ..color = spotColor
        ..style = PaintingStyle.fill,
    );
    _drawLeg(
      canvas,
      size,
      Offset(center.dx - radius * 0.2, center.dy + radius * 2.0),
      mainPaint,
      Paint()
        ..color = spotColor
        ..style = PaintingStyle.fill,
    );
    _drawLeg(
      canvas,
      size,
      Offset(center.dx + radius * 0.2, center.dy + radius * 2.0),
      mainPaint,
      Paint()
        ..color = spotColor
        ..style = PaintingStyle.fill,
    );
    _drawLeg(
      canvas,
      size,
      Offset(center.dx + radius * 0.5, center.dy + radius * 2.0),
      mainPaint,
      Paint()
        ..color = spotColor
        ..style = PaintingStyle.fill,
    );

    // Neck
    final neckPaint = Paint()
      ..color = baseColor
      ..style = PaintingStyle.fill;

    final neckPath = Path()
      ..moveTo(center.dx - radius * 0.3, center.dy + radius * 0.5)
      ..lineTo(center.dx - radius * 0.3, center.dy - radius * 1.0)
      ..lineTo(center.dx + radius * 0.3, center.dy - radius * 1.0)
      ..lineTo(center.dx + radius * 0.3, center.dy + radius * 0.5)
      ..close();

    canvas.drawPath(neckPath, neckPaint);

    // Neck spots (pattern)
    final spotPaint = Paint()
      ..color = spotColor
      ..style = PaintingStyle.fill;

    // Draw spots on neck
    for (int i = 0; i < 5; i++) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(
            center.dx - radius * 0.15 + (i % 2) * radius * 0.3,
            center.dy - i * radius * 0.3,
          ),
          width: radius * 0.25,
          height: radius * 0.2,
        ),
        spotPaint,
      );
    }

    // Head
    final headPaint = Paint()
      ..color = baseColor
      ..style = PaintingStyle.fill;

    // Slightly elongated head for giraffe
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy - radius * 1.3),
        width: radius * 1.3,
        height: radius * 1.0,
      ),
      headPaint,
    );

    // Head spots
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx - radius * 0.3, center.dy - radius * 1.2),
        width: radius * 0.3,
        height: radius * 0.2,
      ),
      spotPaint,
    );

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx + radius * 0.3, center.dy - radius * 1.4),
        width: radius * 0.3,
        height: radius * 0.2,
      ),
      spotPaint,
    );

    // Horns/ossicones
    final hornPaint = Paint()
  ..color = baseColor.withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;

    // Left horn
    final leftHornPath = Path()
      ..moveTo(center.dx - radius * 0.4, center.dy - radius * 1.7)
      ..lineTo(center.dx - radius * 0.5, center.dy - radius * 2.0)
      ..lineTo(center.dx - radius * 0.3, center.dy - radius * 2.0)
      ..close();

    // Right horn
    final rightHornPath = Path()
      ..moveTo(center.dx + radius * 0.4, center.dy - radius * 1.7)
      ..lineTo(center.dx + radius * 0.5, center.dy - radius * 2.0)
      ..lineTo(center.dx + radius * 0.3, center.dy - radius * 2.0)
      ..close();

    canvas.drawPath(leftHornPath, hornPaint);
    canvas.drawPath(rightHornPath, hornPaint);

    // Horn tips
    final hornTipPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(center.dx - radius * 0.4, center.dy - radius * 2.0),
      radius * 0.1,
      hornTipPaint,
    );

    canvas.drawCircle(
      Offset(center.dx + radius * 0.4, center.dy - radius * 2.0),
      radius * 0.1,
      hornTipPaint,
    );

    // Eyes
    final eyePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Positions for eyes
    final leftEyePosition = Offset(
      center.dx - radius * 0.5,
      center.dy - radius * 1.4,
    );
    final rightEyePosition = Offset(
      center.dx + radius * 0.5,
      center.dy - radius * 1.4,
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
        Offset(leftEyePosition.dx - radius * 0.1, leftEyePosition.dy),
        Offset(leftEyePosition.dx + radius * 0.1, leftEyePosition.dy),
        closedEyePaint,
      );

      canvas.drawLine(
        Offset(rightEyePosition.dx - radius * 0.1, rightEyePosition.dy),
        Offset(rightEyePosition.dx + radius * 0.1, rightEyePosition.dy),
        closedEyePaint,
      );
    }

    // Ears
    final earPaint = Paint()
      ..color = baseColor
      ..style = PaintingStyle.fill;

    // Left ear
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx - radius * 0.7, center.dy - radius * 1.6),
        width: radius * 0.3,
        height: radius * 0.4,
      ),
      earPaint,
    );

    // Right ear
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx + radius * 0.7, center.dy - radius * 1.6),
        width: radius * 0.3,
        height: radius * 0.4,
      ),
      earPaint,
    );

    // Nose
    final nosePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy - radius * 1.0),
        width: radius * 0.4,
        height: radius * 0.2,
      ),
      nosePaint,
    );

    // Mouth
    final mouthPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    if (mouthOpen) {
      // Open mouth
      final mouthPath = Path()
        ..moveTo(center.dx - radius * 0.2, center.dy - radius * 0.9)
        ..quadraticBezierTo(
          center.dx,
          center.dy - radius * 0.7,
          center.dx + radius * 0.2,
          center.dy - radius * 0.9,
        );

      canvas.drawPath(mouthPath, mouthPaint);

      // Tongue
      final tonguePaint = Paint()
        ..color = Colors.pink
        ..style = PaintingStyle.fill;

      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(center.dx, center.dy - radius * 0.8),
          width: radius * 0.15,
          height: radius * 0.1,
        ),
        tonguePaint,
      );
    } else {
      // Closed mouth (simple line)
      final mouthPath = Path()
        ..moveTo(center.dx - radius * 0.2, center.dy - radius * 0.8)
        ..quadraticBezierTo(
          center.dx,
          center.dy - radius * 0.75,
          center.dx + radius * 0.2,
          center.dy - radius * 0.8,
        );

      canvas.drawPath(mouthPath, mouthPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
