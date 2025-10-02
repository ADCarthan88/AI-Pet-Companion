import 'dart:async';
import 'package:flutter/material.dart';

class DayNightCycle extends ChangeNotifier {
  DayNightCycle({bool simulate = false, Duration simulatedFullDay = const Duration(minutes: 3)})
      : _simulate = simulate,
        _simulatedFullDay = simulatedFullDay {
    _timer = Timer.periodic(const Duration(seconds: 20), (_) => notifyListeners());
  }
  final bool _simulate; final Duration _simulatedFullDay; late final Timer _timer;
  double get progress {
    final now = DateTime.now();
    if (_simulate) {
      final ms = now.millisecondsSinceEpoch % _simulatedFullDay.inMilliseconds;
      return ms / _simulatedFullDay.inMilliseconds;
    }
    final seconds = now.hour*3600 + now.minute*60 + now.second; return seconds / 86400.0;
  }
  List<Color> get gradient {
    final p = progress;
    if (p < 0.2) { final t = p/0.2; return [Color.lerp(const Color(0xFF0D1B3A), const Color(0xFFFFB347), t)!, Color.lerp(const Color(0xFF132E4F), const Color(0xFFFFE29F), t)!]; }
    if (p < 0.5) { final t = (p-0.2)/0.3; return [Color.lerp(const Color(0xFFFFB347), const Color(0xFF87CEEB), t)!, Color.lerp(const Color(0xFFFFE29F), const Color(0xFFD4F1FF), t)!]; }
    if (p < 0.8) { final t = (p-0.5)/0.3; return [Color.lerp(const Color(0xFF87CEEB), const Color(0xFFFE8C00), t)!, Color.lerp(const Color(0xFFD4F1FF), const Color(0xFFF83600), t)!]; }
    final t = (p-0.8)/0.2; return [Color.lerp(const Color(0xFFFE8C00), const Color(0xFF0D1B2A), t)!, Color.lerp(const Color(0xFFF83600), const Color(0xFF1B263B), t)!];
  }
  Color get ambientLightColor { final p = progress; if (p < 0.25) return const Color(0xFFFFCFA5).withOpacity(0.45); if (p < 0.55) return const Color(0xFFFFFFFF).withOpacity(0.3); if (p < 0.8) return const Color(0xFFFF9F60).withOpacity(0.4); return const Color(0xFF4A6FA3).withOpacity(0.4); }
  bool get isNight => progress < 0.08 || progress > 0.87;
  @override void dispose() { _timer.cancel(); super.dispose(); }
}
