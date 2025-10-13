import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/pet.dart';

class PettingDetectorWidget extends StatefulWidget {
  const PettingDetectorWidget({
    super.key,
    required this.pet,
    required this.child,
    required this.onPetting,
  });

  final Pet pet;
  final Widget child;
  final Function(bool isPetting) onPetting;

  @override
  State<PettingDetectorWidget> createState() => _PettingDetectorWidgetState();
}

class _PettingDetectorWidgetState extends State<PettingDetectorWidget> {
  // Track petting movements
  final List<Offset> _pettingPoints = [];
  bool _isPetting = false;
  int _pettingStrokes = 0;
  DateTime? _lastPettingTime;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _handlePanStart,
      onPanUpdate: _handlePanUpdate,
      onPanEnd: _handlePanEnd,
      child: Stack(
        children: [
          // The main content (pet visualization)
          widget.child,

          // Show petting trails if actively petting
          if (_isPetting)
            CustomPaint(
              painter: _PettingTrailPainter(points: _pettingPoints),
              size: Size.infinite,
            ),
        ],
      ),
    );
  }

  void _handlePanStart(DragStartDetails details) {
    setState(() {
      _pettingPoints.clear();
      _pettingPoints.add(details.localPosition);
    });
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    final now = DateTime.now();
    _lastPettingTime = now;

    setState(() {
      _pettingPoints.add(details.localPosition);

      // If we have enough points, check if this is a petting motion
      if (_pettingPoints.length > 5) {
        final isPettingMotion = _isPettingMotion();

        // If newly detected as petting, start the petting interaction
        if (isPettingMotion && !_isPetting) {
          _isPetting = true;
          _pettingStrokes = 1;
          widget.onPetting(true);

          // Boost happiness slightly
          widget.pet.happiness = math.min(100, widget.pet.happiness + 2);
        } else if (isPettingMotion && _isPetting) {
          // Continue the petting
          _pettingStrokes++;

          // Boost happiness for sustained petting
          if (_pettingStrokes % 3 == 0) {
            widget.pet.happiness = math.min(100, widget.pet.happiness + 1);
            widget.pet.updateState();
          }
        }
      }

      // Keep trail a reasonable length
      if (_pettingPoints.length > 20) {
        _pettingPoints.removeAt(0);
      }
    });
  }

  void _handlePanEnd(DragEndDetails details) {
    // Stop petting after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted && _lastPettingTime != null) {
        final timeSincePetting = DateTime.now().difference(_lastPettingTime!);

        if (timeSincePetting.inMilliseconds > 400) {
          setState(() {
            _isPetting = false;
            _pettingPoints.clear();
            widget.onPetting(false);
          });
        }
      }
    });
  }

  // Analyze motion to determine if it's a petting gesture
  bool _isPettingMotion() {
    // Need enough points to analyze
    if (_pettingPoints.length < 5) return false;

    // Look at the last few points to determine motion
    final recentPoints = _pettingPoints.sublist(_pettingPoints.length - 5);

    // Calculate how horizontal/vertical the motion is
    double horizontalMotion = 0;
    double verticalMotion = 0;

    for (int i = 1; i < recentPoints.length; i++) {
      horizontalMotion += (recentPoints[i].dx - recentPoints[i - 1].dx).abs();
      verticalMotion += (recentPoints[i].dy - recentPoints[i - 1].dy).abs();
    }

    // Petting is generally more horizontal than vertical
    // and should have some minimum motion
    return horizontalMotion > 10 && horizontalMotion > verticalMotion * 1.5;
  }
}

// Painter for the petting trail
class _PettingTrailPainter extends CustomPainter {
  final List<Offset> points;

  _PettingTrailPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    final paint = Paint()
  ..color = Colors.white.withValues(alpha: 0.3)
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Draw the trail
    final path = Path();
    path.moveTo(points.first.dx, points.first.dy);

    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    canvas.drawPath(path, paint);

    // Draw sparkle effects
    final sparklePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    for (int i = 0; i < points.length; i += 4) {
      if (i < points.length) {
        canvas.drawCircle(
          points[i],
          3 + math.Random().nextDouble() * 2,
          sparklePaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_PettingTrailPainter oldDelegate) => true;
}
