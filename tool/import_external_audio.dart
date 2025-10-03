// import_external_audio tool script
library import_external_audio;

/// Utility script to copy/normalize external animal sound files
/// from a user-provided directory (outside repo) into the structured
/// `assets/sounds/<species>/` directories.
///
/// Usage: 
///   dart tool/import_external_audio.dart --source "C:/Users/adamc/animal-sounds" \
///       --species dog --map happy=dog_happy1.mp3 sleep=dog_sleep.mp3
///
/// You can specify multiple --map entries or a YAML manifest instead:
///   dart tool/import_external_audio.dart --source "C:/.../animal-sounds" --species dog \
///       --manifest mapping.yaml
///
/// mapping.yaml example: 
/// ```yaml
/// dog:
///   happy:
///     - dog_happy1.mp3
///     - dog_happy2.mp3
///   sleep: dog_sleep.mp3
/// cat:
///   happy: cat_purr.mp3
/// ```
///
/// The script will:
/// 1. Verify source files exist.
/// 2. Copy to assets/sounds/<species>/<action>[_N].mp3 (preserving numbering if variants).
/// 3. Skip copy if destination identical size & modified not newer.
/// 4. Print a summary of imported files.
///
/// After importing, run (if new folders added):
///   flutter pub get 
/// Then rebuild the app.
import 'dart:io';
import 'package:yaml/yaml.dart';

void main(List<String> args) async {
  final argMap = _parseArgs(args);
  if (argMap.containsKey('help') ||
      (!argMap.containsKey('source') && !argMap.containsKey('manifest'))) {
    _printHelp();
    return;
  }
  final sourceDir = Directory(argMap['source'] ?? '');
  if (!sourceDir.existsSync()) {
    stderr.writeln('Source directory not found: ${sourceDir.path}');
    exit(2);
  }

  final manifestPath = argMap['manifest'];
  Map<String, Map<String, List<String>>> mapping = {};

  if (manifestPath != null) {
    final file = File(manifestPath);
    if (!file.existsSync()) {
      stderr.writeln('Manifest not found: $manifestPath');
      exit(2);
    }
    final yamlContent = loadYaml(await file.readAsString());
    if (yamlContent is YamlMap) {
      yamlContent.forEach((sp, actions) {
        if (actions is YamlMap) {
          actions.forEach((action, value) {
            final list = <String>[];
            if (value is YamlList) {
              for (final v in value) list.add(v.toString());
            } else {
              list.add(value.toString());
            }
            mapping.putIfAbsent(sp.toString(), () => {});
            mapping[sp.toString()]![action.toString()] = list;
          });
        }
      });
    }
  }

  // Parse inline --map entries: action=filename.mp3
  final inlineMaps = argMap['map'] as List<String>?;
  final singleSpecies = argMap['species'];
  if (inlineMaps != null && singleSpecies == null) { 
    stderr.writeln('ERROR: --map requires --species');
    exit(2);
  }
  if (singleSpecies != null) {
    mapping.putIfAbsent(singleSpecies, () => {});
    inlineMaps?.forEach((m) {
      final parts = m.split('=');
      if (parts.length != 2) {
        stderr.writeln('WARN: Skipping malformed map entry: $m');
      } else {
        mapping[singleSpecies]![parts[0]] = [parts[1]];
      }
    });
  }

  if (mapping.isEmpty) {
    stderr.writeln('No mappings provided. Use --map or --manifest.');
    exit(2);
  }

  final destRoot = Directory('assets/sounds');
  if (!destRoot.existsSync()) {
    stderr.writeln('ERROR: assets/sounds not found (run from project root).');
    exit(2);
  }

  final summary = <String, List<String>>{};
  int copied = 0;
  int skipped = 0;

  for (final sp in mapping.keys) { 
    final speciesDest = Directory('${destRoot.path}/$sp');
    if (!speciesDest.existsSync()) {
      speciesDest.createSync(recursive: true);
    }
    final actions = mapping[sp]!;
    for (final action in actions.keys) {
      final files = actions[action]!;
      for (int i = 0; i < files.length; i++) {
        final srcName = files[i];
        final srcFile = File('${sourceDir.path}/$srcName');
          if (!srcFile.existsSync()) { 
          stderr.writeln(
            'WARN: Source file missing for $sp/$action -> $srcName',
          );
          continue;
        }
        final destName = files.length == 1
            ? '$action.mp3'
            : '${action}_${i + 1}.mp3';
        final destFile = File('${speciesDest.path}/$destName');
        if (destFile.existsSync()) {
          // Simple heuristic: skip if same length and src not newer.
          final srcStat = srcFile.statSync();
          final destStat = destFile.statSync();
          if (srcStat.size == destStat.size &&
              !srcStat.modified.isAfter(destStat.modified)) {
            skipped++;
            summary.putIfAbsent(sp, () => []).add('$action (skipped existing)');
            continue;
          }
        }
        srcFile.copySync(destFile.path);
        copied++;
        summary.putIfAbsent(sp, () => []).add('$action -> $destName');
      }
    }
  }

  stdout.writeln('Import complete. Copied: $copied Skipped: $skipped');
  summary.forEach((sp, entries) {
    stdout.writeln('  $sp:');
    for (final e in entries) {
      stdout.writeln('    - $e');
    }
  });
  stdout.writeln(
    'Run: dart tool/validate_audio_assets.dart  (add --strict to enforce)',
  );
}

Map<String, dynamic> _parseArgs(List<String> args) {
  final result = <String, dynamic>{};
  for (int i = 0; i < args.length; i++) {
    final a = args[i];
    if (a.startsWith('--')) {
      final key = a.substring(2);
      if (key == 'map') {
        result.putIfAbsent('map', () => <String>[]);
        if (i + 1 < args.length) {
          (result['map'] as List<String>).add(args[++i]);
        }
      } else if (i + 1 < args.length && !args[i + 1].startsWith('--')) {
        result[key] = args[++i];
      } else {
        result[key] = true;
      }
    }
  }
  return result;
}

void _printHelp() {
  stdout.writeln('Audio Import Helper');
  stdout.writeln('Options:');
  stdout.writeln(
    '  --source <dir>          Source directory containing raw mp3 files',
  );
  stdout.writeln('  --species <name>        Species for inline --map entries');
  stdout.writeln(
    '  --map action=filename   Map a single action to a source file (repeatable)',
  );
  stdout.writeln(
    '  --manifest mapping.yaml Provide YAML manifest for bulk import',
  );
  stdout.writeln('  --help                  Show this help');
}
