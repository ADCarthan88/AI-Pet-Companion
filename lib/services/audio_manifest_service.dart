import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/pet.dart';

/// Loads and provides access to audio variant data from assets/audio_manifest.json
class AudioManifestService {
  static final AudioManifestService _instance =
      AudioManifestService._internal();
  factory AudioManifestService() => _instance;
  AudioManifestService._internal();

  Map<String, Map<String, List<String>>> _data = {};
  bool _loaded = false;
  Future<void>? _loadingFuture;

  Future<void> ensureLoaded() async {
    if (_loaded) return;
    _loadingFuture ??= _load();
    await _loadingFuture;
  }

  Future<void> _load() async {
    try {
      final raw = await rootBundle.loadString('assets/audio_manifest.json');
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      _data = decoded.map((species, actions) {
        final actMap = <String, List<String>>{};
        (actions as Map<String, dynamic>).forEach((action, listOrSingle) {
          if (listOrSingle is List) {
            actMap[action] = listOrSingle.map((e) => e.toString()).toList();
          } else if (listOrSingle is String) {
            actMap[action] = [listOrSingle];
          } else {
            actMap[action] = [];
          }
        });
        return MapEntry(species, actMap);
      });
      _loaded = true;
    } catch (_) {
      // If manifest missing or invalid, keep empty data (fallback logic will handle)
      _data = {};
      _loaded = true;
    }
  }

  List<String> getVariants(PetType type, String action) {
    final speciesKey = type.name;
    final speciesMap = _data[speciesKey];
    if (speciesMap == null) return const [];
    return speciesMap[action] ?? const [];
  }
}
