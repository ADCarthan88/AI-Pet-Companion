import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import '../models/pet.dart';
import '../models/weather_system.dart';
import 'sound_settings_service.dart';
import 'audio_manifest_service.dart';
import 'test_audio_data.dart';
import 'dart:async';

/// Brand new audio service to bypass any cached corruption
class NewAudioService {
  final Pet pet;
  final AudioPlayer _audioPlayer = AudioPlayer();
  final AudioPlayer _ambientPlayer = AudioPlayer();
  bool _soundEnabled = true;
  DateTime _lastPlay = DateTime.fromMillisecondsSinceEpoch(0);
  String? _lastKey;
  static const Duration _minGap = Duration(seconds: 5);
  static bool testingMode = false;
  final SoundSettingsService _settings = SoundSettingsService();
  final AudioManifestService _manifestService = AudioManifestService();
  StreamSubscription? _settingsSub;
  double _currentVolume = 1.0;
  static final Set<String> _missingLogged = <String>{};

  NewAudioService({required this.pet}) {
    _currentVolume = _settings.effectiveVolume;
    _settingsSub = _settings.changes.listen((_) {
      _applyVolume();
    });
    _manifestService.ensureLoaded();
  }

  Future<void> playSound(String action) async {
    // Check if sound is disabled via settings or local toggle
    if (!_soundEnabled || _settings.isMuted) return;

    debugPrint('NEW AUDIO V2: Attempting to play $action for ${pet.type.name}');

    // Ensure manifest is loaded
    await _manifestService.ensureLoaded();

    // Try to get a variant from the manifest service first
    String? soundFile = _manifestService.getRandomVariant(pet.type, action);
    debugPrint('NEW AUDIO V2: Manifest returned: $soundFile');

    // Fallback to simple filename if manifest doesn't have it
    soundFile ??= 'sounds/${pet.type.name}/$action.mp3';

    debugPrint('NEW AUDIO V2: Final sound file path: $soundFile');

    try {
      await _audioPlayer.play(AssetSource(soundFile), volume: _currentVolume);
      debugPrint('NEW AUDIO: Successfully played $soundFile');
    } catch (e) {
      if (!_missingLogged.contains(soundFile)) {
        _missingLogged.add(soundFile);
        debugPrint('NEW AUDIO V2 WARN: Failed to play $soundFile - $e');
        debugPrint(
          'NEW AUDIO V2 WARN: Available variants: ${_manifestService.getVariants(pet.type, action)}',
        );

        // Try fallback to test beep sound
        try {
          debugPrint('NEW AUDIO V2: Trying fallback test beep...');
          await _audioPlayer.play(
            BytesSource(Uint8List.fromList(testBeepData)),
            volume: _currentVolume,
          );
          debugPrint(
            'NEW AUDIO V2: Fallback beep worked - audio system is functional',
          );
        } catch (fallbackError) {
          debugPrint(
            'NEW AUDIO V2 ERROR: Even fallback beep failed - $fallbackError',
          );
        }
      }
    }
  }

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
      if (now.difference(_lastPlay) < _minGap) {
        debugPrint('🔇 Audio cooldown: ${_minGap.inSeconds - now.difference(_lastPlay).inSeconds}s remaining');
        return;
      }
      if (_lastKey == key && pet.mood != PetMood.excited) {
        return; // Silent skip for same mood
      }
    }

    debugPrint('🎵 Playing: $moodAction sound for ${pet.type.name}');
    _lastKey = key;
    _lastPlay = now;
    await playSound(moodAction);
  }

  void _applyVolume() {
    final newVol = _settings.effectiveVolume;
    _currentVolume = newVol;
    _audioPlayer.setVolume(newVol);
  }

  void toggleSound(bool enabled) {
    _soundEnabled = enabled;
    if (!enabled) {
      _audioPlayer.stop();
    }
  }

  void dispose() {
    _audioPlayer.dispose();
    _ambientPlayer.dispose();
    _settingsSub?.cancel();
  }

  // Compatibility methods for existing API
  Future<void> ensureAmbient({WeatherType? weather}) async {
    // Simplified - no ambient for now
  }

  Future<void> stopAmbient({bool fade = true}) async {
    await _ambientPlayer.stop();
  }

  void refreshAmbientVolume() {
    // No-op for now
  }

  Future<void> playSleepLoop({bool fadeIn = true}) async {
    await playSound('sleep');
  }

  void stopSleepLoop({bool fadeOut = true}) {
    _audioPlayer.stop();
  }
}

// Compatibility alias for existing code
typedef PetSoundService = NewAudioService;
