import 'dart:math';
import 'package:flutter/material.dart';
import '../models/pet.dart';
import 'pet_visualizations/pet_visualization_factory.dart';

/// Provides subtle, mood-weighted idle animation variants around the core pet visualization.
/// Variants include: blink (drives isBlinking), bob (vertical float), wag (horizontal tail sway proxy via small rotation),
/// tilt (head tilt rotation), hop (quick upward translate) restricted to happier moods.
class PetIdleAnimator extends StatefulWidget {
  const PetIdleAnimator({
    super.key,
    required this.pet,
    this.baseSize = 150,
    this.active = true,
  });

  final Pet pet;
  final double baseSize;
  final bool active; // allows parent to disable during intense interactions (pounce, chase, etc.)

  @override
  State<PetIdleAnimator> createState() => _PetIdleAnimatorState();
}

enum _IdleVariant { none, blink, bob, wag, tilt, hop }

class _PetIdleAnimatorState extends State<PetIdleAnimator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final Random _rand = Random();

  _IdleVariant _current = _IdleVariant.none;
  Duration _variantDuration = const Duration(seconds: 2);
  DateTime _lastChange = DateTime.now();
  bool _blinkFlag = false; // drives isBlinking parameter

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 4))
      ..addListener(_tick)
      ..repeat();
  }

  @override
  void dispose() {
    _controller.removeListener(_tick);
    _controller.dispose();
    super.dispose();
  }

  void _tick() {
    if (!mounted) return;
    final now = DateTime.now();
    if (now.difference(_lastChange) >= _variantDuration) {
      _selectNextVariant();
    }
    // Blink handling (short window ~200ms)
    if (_current == _IdleVariant.blink) {
      final phase = (now.millisecondsSinceEpoch % 400) / 400.0;
      _blinkFlag = phase < 0.25; // eyes closed first quarter
      if (phase >= 0.95) {
        // end blink early so we rotate variants sooner if needed
        _current = _IdleVariant.none;
        _blinkFlag = false;
      }
    } else {
      _blinkFlag = false;
    }
    // Request rebuild each frame for transform updates
    setState(() {});
  }

  void _selectNextVariant() {
    _lastChange = DateTime.now();
    // Weighted probabilities based on mood
    final mood = widget.pet.mood;
    final List<_IdleVariant> pool;
    switch (mood) {
      case PetMood.happy:
      case PetMood.loving:
        pool = [
          _IdleVariant.blink,
          _IdleVariant.bob,
          _IdleVariant.wag,
          _IdleVariant.tilt,
          _IdleVariant.hop,
          _IdleVariant.none,
        ];
        break;
      case PetMood.excited:
        pool = [
          _IdleVariant.hop,
          _IdleVariant.bob,
          _IdleVariant.wag,
          _IdleVariant.blink,
          _IdleVariant.none,
        ];
        break;
      case PetMood.neutral:
        pool = [
          _IdleVariant.blink,
          _IdleVariant.none,
          _IdleVariant.bob,
          _IdleVariant.tilt,
        ];
        break;
      case PetMood.tired:
        pool = [
          _IdleVariant.blink,
          _IdleVariant.none,
          _IdleVariant.bob,
        ];
        break;
      case PetMood.sad:
        pool = [
          _IdleVariant.none,
          _IdleVariant.blink,
        ];
        break;
    }
    _current = pool[_rand.nextInt(pool.length)];
    _variantDuration = _deriveDuration(_current);
  }

  Duration _deriveDuration(_IdleVariant v) {
    switch (v) {
      case _IdleVariant.none:
        return Duration(milliseconds: 1500 + _rand.nextInt(2000));
      case _IdleVariant.blink:
        return const Duration(milliseconds: 400);
      case _IdleVariant.bob:
        return const Duration(seconds: 2);
      case _IdleVariant.wag:
        return const Duration(seconds: 2);
      case _IdleVariant.tilt:
        return const Duration(seconds: 2);
      case _IdleVariant.hop:
        return const Duration(milliseconds: 900);
    }
  }

  @override
  Widget build(BuildContext context) {
    final base = widget.baseSize;
    final t = _controller.value; // 0..1 cycle

    // Derived transform parameters
    double dy = 0;
    double rotation = 0;
    double scale = 1;

    if (!widget.active) {
      _current = _IdleVariant.none;
    }

    switch (_current) {
      case _IdleVariant.none:
        break;
      case _IdleVariant.blink:
        break; // handled by flag only
      case _IdleVariant.bob:
        dy = sin(t * 2 * pi) * (base * 0.02); // gentle vertical motion
        break;
      case _IdleVariant.wag:
        rotation = sin(t * 2 * pi) * 0.04; // small radians
        break;
      case _IdleVariant.tilt:
        rotation = sin(t * pi) * 0.03; // slower one-way tilt
        break;
      case _IdleVariant.hop:
        final phase = (t * 2) % 1; // faster cycle
        dy = phase < 0.4
            ? -sin(phase / 0.4 * pi) * (base * 0.10)
            : 0; // quick up then settle
        scale = phase < 0.4 ? 1 + (sin(phase / 0.4 * pi) * 0.02) : 1;
        break;
    }

    Widget petVis = PetVisualizationFactory.getPetVisualization(
      pet: widget.pet,
      isBlinking: _blinkFlag,
      mouthOpen: false,
      size: base,
    );

    petVis = Transform.translate(
      offset: Offset(0, dy),
      child: Transform.rotate(
        angle: rotation,
        child: Transform.scale(scale: scale, child: petVis),
      ),
    );

    return petVis;
  }
}
