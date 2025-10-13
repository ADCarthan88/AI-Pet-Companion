import 'dart:async';

class SoundSettingsService {
  static bool _isMuted = false;
  static double _volume = 1.0;

  // All the getters your code needs
  bool get isMuted => _isMuted;
  bool get muted => _isMuted;
  double get volume => _volume;
  double get masterVolume => _volume;
  double get effectiveVolume => _isMuted ? 0.0 : _volume;

  // Stream for changes (your pet_sound_service.dart expects this)
  static final StreamController<void> _changesController =
      StreamController<void>.broadcast();
  Stream<void> get changes => _changesController.stream;

  void setMuted(bool muted) {
    _isMuted = muted;
    _changesController.add(null);
  }

  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0);
    _changesController.add(null);
  }

  void ensureLoaded() {
    // Placeholder for loading settings from storage
  }
}
