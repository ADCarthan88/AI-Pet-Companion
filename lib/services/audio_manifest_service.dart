import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/pet.dart';

class AudioManifestService {
  static final AudioManifestService _instance = AudioManifestService._internal();
  factory AudioManifestService() => _instance;
  AudioManifestService._internal();

  Map<String, List<String>>? _manifest;
  bool _isLoaded = false;

  Future<void> ensureLoaded() async {
    await loadManifest();
  }

  Future<void> loadManifest() async {
    if (_isLoaded) return;

    try {
      final manifestString = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> assetManifest = json.decode(manifestString);

      _manifest = <String, List<String>>{};
      print('NEW AUDIO V2 DEBUG: Loading asset manifest...');
      
      for (final entry in assetManifest.entries) {
        if (entry.key.startsWith('assets/sounds/') && entry.key.endsWith('.mp3')) {
          final path = entry.key;
          print('NEW AUDIO V2 DEBUG: Found asset: $path');
          final pathParts = path.split('/');
          if (pathParts.length >= 4) {
            final petType = pathParts[2];
            
            // Store WITHOUT assets/ prefix to prevent doubling
            final cleanPath = path.replaceFirst('assets/', '');
            print('NEW AUDIO V2 DEBUG: Clean path for $petType: $cleanPath');

            _manifest!.putIfAbsent(petType, () => <String>[]).add(cleanPath);
          }
        }
      }
      
      print('NEW AUDIO V2 DEBUG: Manifest loaded with ${_manifest!.keys.length} pet types');
      for (final entry in _manifest!.entries) {
        print('NEW AUDIO V2 DEBUG: ${entry.key}: ${entry.value.length} sounds');
      }
      _isLoaded = true;
    } catch (e) {
      print('Failed to load audio manifest: $e');
      _manifest = {};
      _isLoaded = true;
    }
  }

  List<String> getVariants(PetType petType, String action) {
    if (!_isLoaded || _manifest == null) return [];

    final petSounds = _manifest![petType.name] ?? [];
    return petSounds.where((fullPath) {
      final filename = fullPath.split('/').last;
      return filename.startsWith(action);
    }).toList();
  }

  String? getRandomVariant(PetType petType, String action) {
    final variants = getVariants(petType, action);
    if (variants.isEmpty) return null;

    variants.shuffle();
    final selectedVariant = variants.first;
    print('NEW AUDIO V2 DEBUG: Selected variant: $selectedVariant');
    return selectedVariant;
  }

  bool hasSound(PetType petType, String action) {
    return getVariants(petType, action).isNotEmpty;
  }
}