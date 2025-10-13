import 'package:audioplayers/audioplayers.dart';
import 'dart:async';
import 'dart:typed_data';
import '../models/pet_habitat.dart';
import 'sound_settings_service.dart';
import 'new_audio_service.dart';

enum DayPeriod { morning, afternoon, evening, night }

class AmbientAudioService {
  final AudioPlayer _playerA = AudioPlayer();
  final AudioPlayer _playerB = AudioPlayer();
  AudioPlayer? _active;
  AudioPlayer? _fading;
  DayPeriod? _currentPeriod;
  HabitatTheme? _currentTheme;
  final SoundSettingsService _settings = SoundSettingsService();
  Timer? _fadeTimer;
  static const _fadeDuration = Duration(seconds: 3);
  // bool _initialized = false; // reserved for future warm-up logic

  late final Uint8List _silentBytes = Uint8List(
    0,
  ); // Use empty bytes to avoid base64 issues

  // Removed _initSilent method - using empty bytes directly

  Future<void> setContext({
    required HabitatTheme theme,
    required DayPeriod period,
  }) async {
    if (NewAudioService.testingMode) return; // Suppress ambient in tests
    final changed = theme != _currentTheme || period != _currentPeriod;
    if (!changed) return;
    _currentTheme = theme;
    _currentPeriod = period;
    await _playForContext(theme, period);
  }

  Future<void> _playForContext(HabitatTheme theme, DayPeriod period) async {
    _fadeTimer?.cancel();
    final next = _active == _playerA ? _playerB : _playerA;
    final asset = _mapToAsset(theme, period);
    try {
      await next.stop();
      await next.play(AssetSource(asset), volume: 0.0);
      await next.setReleaseMode(ReleaseMode.loop);
    } catch (_) {
      await next.play(BytesSource(_silentBytes), volume: 0.0);
      await next.setReleaseMode(ReleaseMode.loop);
    }
    _fading = _active;
    _active = next;
    _startFade();
  }

  String _mapToAsset(HabitatTheme theme, DayPeriod period) {
    // Placeholder mapping; expect files like assets/sounds/ambient/<theme>_<period>.mp3
    final themeName = theme.name;
    final periodName = period.name;
    return 'sounds/ambient/${themeName}_$periodName.mp3';
  }

  void _startFade() {
    final totalMs = _fadeDuration.inMilliseconds;
    final tick = 50;
    int elapsed = 0;
    _fadeTimer = Timer.periodic(Duration(milliseconds: tick), (t) {
      elapsed += tick;
      final ratio = (elapsed / totalMs).clamp(0.0, 1.0);
      final vol = _settings.effectiveVolume * 0.5; // ambient at 50% of master
      _active?.setVolume(vol * ratio);
      _fading?.setVolume(vol * (1 - ratio));
      if (ratio >= 1) {
        _fading?.stop();
        _fading = null;
        t.cancel();
      }
    });
  }

  void dispose() {
    _fadeTimer?.cancel();
    _playerA.dispose();
    _playerB.dispose();
  }
}
