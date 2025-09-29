import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../models/pet.dart';

class PetSoundService {
  final Pet pet;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _soundEnabled = true;

  PetSoundService({required this.pet});

  Future<void> playSound(String action) async {
    if (!_soundEnabled) return;

    // For web platform, we'll just use a silent approach for now
    // since we're using placeholder audio files
    if (kIsWeb) {
      debugPrint(
        'Playing sound: $action for ${pet.type} (web platform - sound disabled)',
      );
      return;
    }

    // Get the appropriate sound file based on pet type and action
    final soundFile = _getSoundFileName(pet.type, action);

    try {
      await _audioPlayer.play(AssetSource('sounds/$soundFile'));
    } catch (e) {
      debugPrint('Error playing sound: $e');
    }
  }

  String _getSoundFileName(PetType type, String action) {
    // Map pet types and actions to sound file names
    switch (type) {
      case PetType.dog:
        switch (action) {
          case 'happy':
            return 'dog_happy.mp3';
          case 'sad':
            return 'dog_sad.mp3';
          case 'eat':
            return 'dog_eat.mp3';
          case 'sleep':
            return 'dog_sleep.mp3';
          case 'play':
            return 'dog_play.mp3';
          case 'lick':
            return 'dog_lick.mp3';
          case 'clean':
            return 'dog_clean.mp3';
          case 'idle':
            return 'dog_idle.mp3';
          default:
            return 'dog_bark.mp3';
        }

      case PetType.cat:
        switch (action) {
          case 'happy':
            return 'cat_purr.mp3';
          case 'sad':
            return 'cat_sad.mp3';
          case 'eat':
            return 'cat_eat.mp3';
          case 'sleep':
            return 'cat_sleep.mp3';
          case 'play':
            return 'cat_play.mp3';
          case 'lick':
            return 'cat_lick.mp3';
          case 'clean':
            return 'cat_clean.mp3';
          case 'idle':
            return 'cat_idle.mp3';
          default:
            return 'cat_meow.mp3';
        }

      case PetType.bird:
        switch (action) {
          case 'happy':
            return 'bird_happy.mp3';
          case 'sad':
            return 'bird_sad.mp3';
          case 'eat':
            return 'bird_eat.mp3';
          case 'sleep':
            return 'bird_sleep.mp3';
          case 'play':
            return 'bird_play.mp3';
          case 'idle':
            return 'bird_idle.mp3';
          default:
            return 'bird_chirp.mp3';
        }

      case PetType.rabbit:
        switch (action) {
          case 'happy':
            return 'rabbit_happy.mp3';
          case 'eat':
            return 'rabbit_eat.mp3';
          case 'play':
            return 'rabbit_play.mp3';
          default:
            return 'rabbit_sound.mp3';
        }

      case PetType.lion:
        switch (action) {
          case 'happy':
            return 'lion_happy.mp3';
          case 'angry':
            return 'lion_roar.mp3';
          case 'eat':
            return 'lion_eat.mp3';
          default:
            return 'lion_sound.mp3';
        }

      case PetType.giraffe:
        switch (action) {
          case 'happy':
            return 'giraffe_happy.mp3';
          case 'eat':
            return 'giraffe_eat.mp3';
          default:
            return 'giraffe_sound.mp3';
        }

      case PetType.penguin:
        switch (action) {
          case 'happy':
            return 'penguin_happy.mp3';
          case 'slide':
            return 'penguin_slide.mp3';
          default:
            return 'penguin_call.mp3';
        }

      default: // Covers PetType.panda and any future pet types
        switch (action) {
          case 'happy':
            return 'panda_happy.mp3';
          case 'eat':
            return 'panda_eat.mp3';
          default:
            return 'panda_sound.mp3';
        }
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
  }
}
