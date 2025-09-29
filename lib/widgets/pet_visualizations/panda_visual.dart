import 'package:flutter/material.dart';
import '../../models/pet.dart';

class PandaVisual extends StatelessWidget {
  final Pet pet;
  final bool isBlinking;
  final bool mouthOpen;
  final double size;

  const PandaVisual({
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
          // Panda body
          Positioned.fill(
            child: CustomPaint(
              painter: PandaPainter(
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

class PandaPainter extends CustomPainter {
  final Color color;
  final bool isBlinking;
  final bool mouthOpen;

  PandaPainter({
    required this.color,
    required this.isBlinking,
    required this.mouthOpen,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.4;

    // Colors - regardless of the user color, we'll make a proper panda
    final whiteColor = Colors.white;
    final blackColor = Colors.black;

    // Body (oval - white)
    final bodyPaint = Paint()
      ..color = whiteColor
      ..style = PaintingStyle.fill;

    // Draw the body
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy + radius * 0.6),
        width: radius * 1.8,
        height: radius * 1.6,
      ),
      bodyPaint,
    );

    // Black patches on body
    final blackPatch = Paint()
      ..color = blackColor
      ..style = PaintingStyle.fill;

    // Draw black belly patch
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy + radius * 0.8),
        width: radius * 1.2,
        height: radius * 0.8,
      ),
      blackPatch,
    );

    // Arms/front legs (black)
    // Left arm
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(center.dx - radius * 0.7, center.dy + radius * 0.5),
          width: radius * 0.5,
          height: radius * 1.0,
        ),
        Radius.circular(radius * 0.2),
      ),
      blackPatch,
    );

    // Right arm
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(center.dx + radius * 0.7, center.dy + radius * 0.5),
          width: radius * 0.5,
          height: radius * 1.0,
        ),
        Radius.circular(radius * 0.2),
      ),
      blackPatch,
    );

    // Back legs (black)
    // Left leg
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(center.dx - radius * 0.5, center.dy + radius * 1.3),
          width: radius * 0.5,
          height: radius * 0.7,
        ),
        Radius.circular(radius * 0.2),
      ),
      blackPatch,
    );

    // Right leg
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(center.dx + radius * 0.5, center.dy + radius * 1.3),
          width: radius * 0.5,
          height: radius * 0.7,
        ),
        Radius.circular(radius * 0.2),
      ),
      blackPatch,
    );

    // Head (white circle)
    final headPaint = Paint()
      ..color = whiteColor
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(center.dx, center.dy - radius * 0.1),
      radius * 0.9,
      headPaint,
    ); // Ears (black circles)
    final earPaint = Paint()
      ..color = blackColor
      ..style = PaintingStyle.fill;

    // Left ear
    canvas.drawCircle(
      Offset(center.dx - radius * 0.7, center.dy - radius * 0.7),
      radius * 0.3,
      earPaint,
    );

    // Right ear
    canvas.drawCircle(
      Offset(center.dx + radius * 0.7, center.dy - radius * 0.7),
      radius * 0.3,
      earPaint,
    );

    // Eye patches (black ovals)
    // Left eye patch
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx - radius * 0.4, center.dy - radius * 0.2),
        width: radius * 0.7,
        height: radius * 0.6,
      ),
      earPaint,
    );

    // Right eye patch
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx + radius * 0.4, center.dy - radius * 0.2),
        width: radius * 0.7,
        height: radius * 0.6,
      ),
      earPaint,
    );

    // Eyes (white circles inside the black patches)
    final eyePaint = Paint()
      ..color = whiteColor
      ..style = PaintingStyle.fill;

    // Positions for eyes
    final leftEyePosition = Offset(
      center.dx - radius * 0.4,
      center.dy - radius * 0.2,
    );
    final rightEyePosition = Offset(
      center.dx + radius * 0.4,
      center.dy - radius * 0.2,
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

      canvas.drawCircle(leftEyePosition, radius * 0.08, pupilPaint);
      canvas.drawCircle(rightEyePosition, radius * 0.08, pupilPaint);
    } else {
      // Closed eyes (white lines on black patches)
      final closedEyePaint = Paint()
        ..color = Colors.white
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

    // Nose (black oval)
    final nosePaint = Paint()
      ..color = blackColor
      ..style = PaintingStyle.fill;

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy + radius * 0.1),
        width: radius * 0.5,
        height: radius * 0.3,
      ),
      nosePaint,
    );

    // Mouth
    final mouthPaint = Paint()
      ..color = blackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    if (mouthOpen) {
      // Open mouth
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(center.dx, center.dy + radius * 0.35),
          width: radius * 0.4,
          height: radius * 0.3,
        ),
        mouthPaint,
      );

      // Tongue
      final tonguePaint = Paint()
        ..color = Colors.pink[300]!
        ..style = PaintingStyle.fill;

      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(center.dx, center.dy + radius * 0.4),
          width: radius * 0.2,
          height: radius * 0.15,
        ),
        tonguePaint,
      );
    } else {
      // Closed mouth (simple curved line)
      final mouthPath = Path()
        ..moveTo(center.dx - radius * 0.2, center.dy + radius * 0.3)
        ..quadraticBezierTo(
          center.dx,
          center.dy + radius * 0.4,
          center.dx + radius * 0.2,
          center.dy + radius * 0.3,
        );

      canvas.drawPath(mouthPath, mouthPaint);
    }

    // Add small black paws at the ends of the limbs
    final pawPaint = Paint()
      ..color = blackColor
      ..style = PaintingStyle.fill;

    // Front paws
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx - radius * 0.7, center.dy + radius * 0.9),
        width: radius * 0.5,
        height: radius * 0.3,
      ),
      pawPaint,
    );

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx + radius * 0.7, center.dy + radius * 0.9),
        width: radius * 0.5,
        height: radius * 0.3,
      ),
      pawPaint,
    );

    // Back paws
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx - radius * 0.5, center.dy + radius * 1.6),
        width: radius * 0.5,
        height: radius * 0.3,
      ),
      pawPaint,
    );

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx + radius * 0.5, center.dy + radius * 1.6),
        width: radius * 0.5,
        height: radius * 0.3,
      ),
      pawPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
