import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class AmbientParticles extends StatefulWidget {
  final bool fireflies;
  final bool dust;
  final bool snow;
  final int maxParticles;
  const AmbientParticles({
    super.key,
    this.fireflies = false,
    this.dust = true,
    this.snow = false,
    this.maxParticles = 38,
  });
  @override
  State<AmbientParticles> createState() => _AmbientParticlesState();
}

class _Particle {
  Offset pos;
  double r;
  double vx;
  double vy;
  double life;
  double maxLife;
  Color color;
  _Particle({
    required this.pos,
    required this.r,
    required this.vx,
    required this.vy,
    required this.life,
    required this.maxLife,
    required this.color,
  });
}

class _AmbientParticlesState extends State<AmbientParticles> {
  final math.Random _rand = math.Random();
  final List<_Particle> _particles = [];
  late final Ticker _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Ticker(_tick)..start();
  }

  void _tick(Duration _) => setState(() {});

  void _spawn(Size size) {
    if (_particles.length >= widget.maxParticles) return;
    final roll = _rand.nextDouble();
    final isFirefly = widget.fireflies && roll < 0.25;
    final isSnow = widget.snow && roll > 0.78;
    final base = Offset(
      _rand.nextDouble() * size.width,
      _rand.nextDouble() * size.height,
    );
    _particles.add(
      _Particle(
        pos: base,
        r: isFirefly
            ? 2.5 + _rand.nextDouble() * 2.5
            : isSnow
            ? 3 + _rand.nextDouble() * 3
            : 1 + _rand.nextDouble() * 2,
        vx: isSnow
            ? (_rand.nextDouble() - 0.5) * 0.4
            : (isFirefly ? (_rand.nextDouble() - 0.5) * 0.9 : 0),
        vy: isSnow
            ? (0.4 + _rand.nextDouble() * 0.6)
            : (isFirefly
                  ? (_rand.nextDouble() - 0.5) * 0.9
                  : (0.05 + _rand.nextDouble() * 0.15)),
        life: 0,
  maxLife: (3500 + _rand.nextInt(5500)).toDouble(),
        color: isFirefly
            ? Colors.yellowAccent.withOpacity(0.85)
            : isSnow
            ? Colors.white.withOpacity(0.95)
            : Colors.white.withOpacity(0.18 + _rand.nextDouble() * 0.15),
      ),
    );
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = Size(constraints.maxWidth, constraints.maxHeight);
          if (_rand.nextDouble() < 0.28) _spawn(size);
          _particles.removeWhere((p) => p.life > p.maxLife);
          for (final p in _particles) {
            p.life += 16; // approx frame
            final t = DateTime.now().millisecondsSinceEpoch / 1000.0;
            p.pos = Offset(
              (p.pos.dx + p.vx + math.sin(t * 0.6 + p.hashCode) * 0.12) %
                  size.width,
              (p.pos.dy + p.vy + 0.02) % size.height,
            );
          }
          return CustomPaint(
            size: size,
            painter: _ParticlesPainter(_particles),
          );
        },
      ),
    );
  }
}

class _ParticlesPainter extends CustomPainter {
  final List<_Particle> particles;
  _ParticlesPainter(this.particles);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..blendMode = BlendMode.plus;
    for (final p in particles) {
      final lifeT = (p.life / p.maxLife).clamp(0.0, 1.0);
      final fade = lifeT < 0.1
          ? (lifeT / 0.1)
          : lifeT > 0.9
          ? (1 - (lifeT - 0.9) / 0.1)
          : 1.0;
      paint.color = p.color.withOpacity(p.color.opacity * fade);
      canvas.drawCircle(p.pos, p.r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlesPainter oldDelegate) => true;
}
