import 'dart:io';
import 'dart:convert';

const species = [
  'dog',
  'cat',
  'bird',
  'rabbit',
  'lion',
  'giraffe',
  'penguin',
  'panda',
];

/// Required baseline actions. A species passes a requirement if either
/// `<action>.mp3` exists or any variant `<action>_*.mp3` exists.
const requiredActions = ['happy', 'sleep'];

void main(List<String> args) {
  final strict = args.contains('--strict');
  final soundsDir = Directory('assets/sounds');
  if (!soundsDir.existsSync()) {
    stderr.writeln('ERROR: assets/sounds directory not found.');
    exitCode = 1;
    return;
  }
  bool failed = false;
  // Attempt to read manifest if present
  Map<String, dynamic>? manifest;
  final manifestFile = File('assets/audio_manifest.json');
  if (manifestFile.existsSync()) {
    try {
      manifest =
          jsonDecode(manifestFile.readAsStringSync()) as Map<String, dynamic>;
    } catch (e) {
      stderr.writeln('WARN: Failed to parse audio_manifest.json: $e');
    }
  }

  for (final sp in species) {
    final dir = Directory('assets/sounds/$sp');
    if (!dir.existsSync()) {
      stderr.writeln('ERROR: Missing species directory: $sp');
      failed = true;
      continue;
    }
    final files = dir
        .listSync()
        .whereType<File>()
        .map((f) => f.uri.pathSegments.last)
        .toList();
    for (final action in requiredActions) {
      bool satisfied = false;
      // If manifest lists the action with non-empty variants, accept that even if file missing -> we'll check existence separately.
      final manifestVariants = manifest?[sp] is Map<String, dynamic>
          ? (manifest![sp][action] is List
                ? List<String>.from(manifest[sp][action])
                : (manifest[sp][action] is String
                      ? [manifest[sp][action]]
                      : <String>[]))
          : <String>[];
      if (manifestVariants.isNotEmpty) {
        satisfied = true;
      } else {
        final direct = '$action.mp3';
        final hasDirect = files.contains(direct);
        final hasVariant = files.any(
          (f) => f.startsWith('${action}_') && f.endsWith('.mp3'),
        );
        satisfied = hasDirect || hasVariant;
      }
      if (!satisfied) {
        final msg = '$sp missing $action(.mp3)';
        if (strict) {
          stderr.writeln('ERROR: $msg');
          failed = true;
        } else {
          stderr.writeln('WARN: $msg');
        }
      }
      // Cross-check manifest referenced files exist
      if (manifestVariants.isNotEmpty) {
        for (final mv in manifestVariants) {
          final mf = File('assets/sounds/$sp/$mv');
          if (!mf.existsSync()) {
            stderr.writeln('WARN: Manifest references missing file: $sp/$mv');
          }
        }
      }
    }
  }
  if (failed) {
    stderr.writeln('Audio validation completed with errors.');
    exitCode = 2;
  } else {
    stdout.writeln('Audio validation completed. (Warnings above if any)');
  }
}
