import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

/// Simple sound settings persistence placeholder.
/// In a real app you'd use SharedPreferences or Hive. For now keeps in-memory.
class SoundSettingsService {
  static final SoundSettingsService _instance = SoundSettingsService._();
  factory SoundSettingsService() => _instance;
  SoundSettingsService._();

  double _masterVolume = 1.0; // 0.0 - 1.0
  bool _muted = false;
  bool _loaded = false;

  final StreamController<void> _changes = StreamController.broadcast();
  Stream<void> get changes => _changes.stream;

  double get effectiveVolume => _muted ? 0.0 : _masterVolume;
  double get masterVolume => _masterVolume;
  bool get muted => _muted;

  Future<void> ensureLoaded() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    _masterVolume = prefs.getDouble('sound_master_volume') ?? 1.0;
    _muted = prefs.getBool('sound_muted') ?? false;
    _loaded = true;
    _changes.add(null); // notify listeners of initial load
  }

  Future<void> setVolume(double v) async {
    _masterVolume = v.clamp(0.0, 1.0);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('sound_master_volume', _masterVolume);
    _changes.add(null);
  }

  Future<void> setMuted(bool value) async {
    _muted = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sound_muted', _muted);
    _changes.add(null);
  }

  void dispose() {
    _changes.close();
  }
}
