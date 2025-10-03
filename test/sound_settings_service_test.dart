import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ai_pet_companion/services/sound_settings_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SoundSettingsService Persistence', () {
    setUp(() async {
      // Clear any previous mock values before each test
      SharedPreferences.setMockInitialValues({});
    });

    test('loads initial values from shared preferences', () async {
      SharedPreferences.setMockInitialValues({
        'sound_master_volume': 0.4,
        'sound_muted': true,
      });
      final service = SoundSettingsService();
      await service.ensureLoaded();
      expect(service.masterVolume, closeTo(0.4, 0.0001));
      expect(service.muted, isTrue);
    });

    test('setVolume persists value', () async {
      final service = SoundSettingsService();
      await service.ensureLoaded();
      await service.setVolume(0.33);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getDouble('sound_master_volume'), closeTo(0.33, 0.0001));
      expect(service.masterVolume, closeTo(0.33, 0.0001));
    });

    test('setMuted persists value', () async {
      final service = SoundSettingsService();
      await service.ensureLoaded();
      await service.setMuted(true);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('sound_muted'), isTrue);
      expect(service.muted, isTrue);
    });
  });
}
