import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import '../models/pet.dart';
import '../models/weather_system.dart';
import 'sound_settings_service.dart';
import 'dart:async';

/// Clean PetSoundService without any base64 issues
class PetSoundService {
  final Pet pet;
  final AudioPlayer _audioPlayer = AudioPlayer();
  final SoundSettingsService _settings = SoundSettingsService();
  bool _soundEnabled = true;
  static bool testingMode = false;

  PetSoundService({required this.pet});

  Future<void> playSound(String action) async {
    if (!_soundEnabled || _settings.isMuted) return;

    final soundFile = 'sounds/${pet.type.name}/$action.mp3';

    try {
      await _audioPlayer.play(AssetSource(soundFile), volume: _settings.effectiveVolume);
      debugPrint('Played: $soundFile');
    } catch (e) {
      debugPrint('Audio error: $e');
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
    await playSound(moodAction);
  }

  void toggleSound(bool enabled) {
    _soundEnabled = enabled;
  }

  void dispose() {
    _audioPlayer.dispose();
  }

  // Compatibility methods
  Future<void> ensureAmbient({WeatherType? weather}) async {}
  Future<void> stopAmbient({bool fade = true}) async {}
  void refreshAmbientVolume() {}
  Future<void> playSleepLoop({bool fadeIn = true}) async {}
  void stopSleepLoop({bool fadeOut = true}) {}
}
