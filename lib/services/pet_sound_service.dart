import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import '../models/pet.dart';
import 'sound_settings_service.dart';
import 'dart:async';
import 'dart:convert';
// dart:typed_data not needed; Uint8List available via foundation
import 'dart:io';
import 'audio_manifest_service.dart';

class PetSoundService {
  final Pet pet;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _soundEnabled = true;
  DateTime _lastPlay = DateTime.fromMillisecondsSinceEpoch(0);
  String? _lastKey;
  static const Duration _minGap = Duration(seconds: 5);
  static bool testingMode = false; // When true, suppress actual audio
  final SoundSettingsService _settings = SoundSettingsService();
  StreamSubscription? _settingsSub;
  double _currentVolume = 1.0;
  bool _sleepLoopActive = false;
  Timer? _fadeTimer;
  static const String _silentMp3Base64 =
      'SUQzAwAAAAAAQlRDTgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA//uQZAAAAAAAAAAAAAAAAAAAAAASW5mbwAAAA8AAAACAAACcQCAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgP//7kGQBUAAAADAAAABAAAARKgAAAAAAAASW5mbwAAABwAAAABAAABNwCqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqv/7kGQBcAAAAGAAAABAAAARKgAAAAAAAEluZm8AAAASAAAAAQAAAQcAqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqr/+5BkAXAAAABgAAAAQAAABEqAAAAAAAAA==';
  final Uint8List _silentBytes = base64Decode(_silentMp3Base64);
  static final Set<String> _missingLogged = <String>{};

  PetSoundService({required this.pet}) {
    _currentVolume = _settings.effectiveVolume;
    _settingsSub = _settings.changes.listen((_) {
      _applyVolume();
    });
  }

  Future<void> playSound(String action) async {
    if (!_soundEnabled || testingMode) return;

    // Web is now supported; attempt playback as normal. If it fails we'll log once.

    // Get the appropriate sound file based on pet type and action
    final soundFile = await _resolveFromManifestOrLegacy(pet.type, action);

    await _playAssetOrFallback(soundFile);
  }

  /// Convenience: play a mood-based sound using current pet mood.
  Future<void> playMoodSound({bool force = false}) async {
    final moodAction = switch (pet.mood) {
      PetMood.happy => 'happy',
      PetMood.neutral => 'idle',
      PetMood.sad => 'sad',
      PetMood.excited => 'play',
      PetMood.tired => 'sleep',
      PetMood.loving => 'happy',
    };
    final key = '${pet.type.name}_$moodAction';
    final now = DateTime.now();
    if (!force) {
      if (now.difference(_lastPlay) < _minGap) return;
      if (_lastKey == key && pet.mood != PetMood.excited) return;
    }
    _lastKey = key;
    _lastPlay = now;
    await playSound(moodAction);
  }

  /// Optional loop for sleeping (soft snore) - stops when waking.
  Future<void> playSleepLoop({bool fadeIn = true}) async {
    if (pet.currentActivity != PetActivity.sleeping || testingMode) return;
    final file = _getSoundFileName(pet.type, 'sleep');
    try {
      _sleepLoopActive = true;
      await _audioPlayer.stop();
      if (fadeIn) {
        // Start silent then fade in either asset or fallback
        await _playAssetOrFallback(file, initialVolume: 0.0);
      } else {
        await _playAssetOrFallback(
          file,
          initialVolume: _settings.effectiveVolume,
        );
      }
      if (fadeIn) {
        _startFade(
          target: _settings.effectiveVolume,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (_) {}
  }

  Future<void> _playAssetOrFallback(
    String assetPath, {
    double? initialVolume,
  }) async {
    final vol = initialVolume ?? _settings.effectiveVolume;
    try {
      await _audioPlayer.play(AssetSource(assetPath), volume: vol);
    } catch (e) {
      if (!_missingLogged.contains(assetPath)) {
        _missingLogged.add(assetPath);
  debugPrint('AUDIO WARN: Missing or failed asset $assetPath ($e) -> silent fallback');
      }
      await _audioPlayer.play(BytesSource(_silentBytes), volume: vol);
    }
  }

  void stopSleepLoop({bool fadeOut = true}) {
    if (!_sleepLoopActive) return;
    if (fadeOut) {
      _startFade(
        target: 0.0,
        duration: const Duration(milliseconds: 800),
        onDone: () {
          _audioPlayer.stop();
          _sleepLoopActive = false;
        },
      );
    } else {
      _audioPlayer.stop();
      _sleepLoopActive = false;
    }
  }

  void _startFade({
    required double target,
    required Duration duration,
    VoidCallback? onDone,
  }) {
    _fadeTimer?.cancel();
    final start = _currentVolume;
    final diff = target - start;
    if (diff.abs() < 0.001) {
      onDone?.call();
      return;
    }
    final steps = 20;
    int tick = 0;
    final stepDuration = duration ~/ steps;
    _fadeTimer = Timer.periodic(stepDuration, (t) {
      tick++;
      final v = (start + diff * (tick / steps)).clamp(0.0, 1.0);
      _audioPlayer.setVolume(v);
      _currentVolume = v;
      if (tick >= steps) {
        t.cancel();
        onDone?.call();
      }
    });
  }

  void _applyVolume() {
    final newVol = _settings.effectiveVolume;
    _currentVolume = newVol;
    _audioPlayer.setVolume(newVol);
  }

  String _getSoundFileName(PetType type, String action) {
    // Map pet types and actions to sound file names
    // Preferred folder-based mapping: sounds/<species>/<action>.mp3
    final folderCandidate = 'sounds/${type.name}/$action.mp3';
    // Keep legacy flat mapping as fallback below
    switch (type) {
      case PetType.dog:
        switch (action) {
          case 'happy':
            return folderCandidate; // dog/happy.mp3
          case 'sad':
            return folderCandidate;
          case 'eat':
            return folderCandidate;
          case 'sleep':
            return folderCandidate;
          case 'play':
            return folderCandidate;
          case 'lick':
            return folderCandidate;
          case 'clean':
            return folderCandidate;
          case 'idle':
            return folderCandidate;
          default:
            return 'sounds/${type.name}/bark.mp3';
        }

      case PetType.cat:
        switch (action) {
          case 'happy':
            return folderCandidate; // cat/happy/mp3 (purr concept)
          case 'sad':
            return folderCandidate;
          case 'eat':
            return folderCandidate;
          case 'sleep':
            return folderCandidate;
          case 'play':
            return folderCandidate;
          case 'lick':
            return folderCandidate;
          case 'clean':
            return folderCandidate;
          case 'idle':
            return folderCandidate;
          default:
            return 'sounds/${type.name}/meow.mp3';
        }

      case PetType.bird:
        switch (action) {
          case 'happy':
            return folderCandidate;
          case 'sad':
            return folderCandidate;
          case 'eat':
            return folderCandidate;
          case 'sleep':
            return folderCandidate;
          case 'play':
            return folderCandidate;
          case 'idle':
            return folderCandidate;
          default:
            return 'sounds/${type.name}/chirp.mp3';
        }

      case PetType.rabbit:
        switch (action) {
          case 'happy':
            return folderCandidate;
          case 'eat':
            return folderCandidate;
          case 'play':
            return folderCandidate;
          default:
            return 'sounds/${type.name}/sound.mp3';
        }

      case PetType.lion:
        switch (action) {
          case 'happy':
            return folderCandidate;
          case 'angry':
            return folderCandidate; // roar as angry mapping
          case 'eat':
            return folderCandidate;
          default:
            return 'sounds/${type.name}/sound.mp3';
        }

      case PetType.giraffe:
        switch (action) {
          case 'happy':
            return folderCandidate;
          case 'eat':
            return folderCandidate;
          default:
            return 'sounds/${type.name}/sound.mp3';
        }

      case PetType.penguin:
        switch (action) {
          case 'happy':
            return folderCandidate;
          case 'slide':
            return folderCandidate;
          default:
            return 'sounds/${type.name}/call.mp3';
        }

      default: // Covers PetType.panda and any future pet types
        switch (action) {
          case 'happy':
            return folderCandidate;
          case 'eat':
            return folderCandidate;
          default:
            return 'sounds/${type.name}/sound.mp3';
        }
    }
  }

  Future<String> _resolveFromManifestOrLegacy(
    PetType type,
    String action,
  ) async {
    final manifest = AudioManifestService();
    await manifest.ensureLoaded();
    final variants = manifest.getVariants(type, action);
    if (variants.isNotEmpty) {
      // Random pick
      variants.shuffle();
      return 'sounds/${type.name}/${variants.first}';
    }
    return _resolveLegacyVariants(type, action);
  }

  String _resolveLegacyVariants(PetType type, String action) {
    final base = _getSoundFileName(type, action);
    final folder = 'assets/sounds/${type.name}';
    try {
      final dir = Directory(folder);
      if (!dir.existsSync()) return base;
      final candidates = dir
          .listSync()
          .whereType<File>()
          .map((f) => f.path.split(Platform.pathSeparator).last)
          .where((name) => name.startsWith('$action') && name.endsWith('.mp3'))
          .toList();
      if (candidates.isEmpty) return base;
      candidates.shuffle();
      return 'sounds/${type.name}/${candidates.first}';
    } catch (_) {
      return base;
    }
  }

  void toggleSound(bool enabled) {
    _soundEnabled = enabled;
    if (!enabled) {
      _audioPlayer.stop();
    }
  }

  void dispose() {
    _audioPlayer.dispose();
    _settingsSub?.cancel();
    _fadeTimer?.cancel();
  }
}
