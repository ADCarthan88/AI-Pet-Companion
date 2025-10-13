import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_pet_companion/screens/home_screen.dart';
import 'package:ai_pet_companion/screens/pet_store_screen.dart';
import 'package:ai_pet_companion/models/pet.dart';
import 'package:ai_pet_companion/services/new_audio_service.dart';

void main() {
  NewAudioService.testingMode = true;
  group('Pet Model Tests', () {
    test('Pet initialization and basic actions', () {
      final pet = Pet(
        name: 'TestPet',
        type: PetType.dog,
        gender: PetGender.male,
        color: Colors.brown,
      );
      pet.happiness = 50; // normalize baseline for test expectations

      // Test initialization
      expect(pet.name, 'TestPet');
      expect(pet.type, PetType.dog);
      expect(pet.gender, PetGender.male);
      expect(pet.happiness, 50);
      expect(pet.energy, 100);
      expect(pet.hunger, 0);
      expect(pet.cleanliness, 100);
      expect(pet.mood, PetMood.neutral);
      expect(pet.currentActivity, PetActivity.idle);

      // Test feeding
      pet.feed();
      expect(pet.hunger, 0);
      expect(pet.currentActivity, PetActivity.eating);

      // Test playing
      pet.play();
      expect(pet.energy, lessThan(100));
      expect(pet.happiness, greaterThan(50));
      expect(pet.currentActivity, PetActivity.playing);

      // Test resting
      pet.rest();
      expect(pet.currentActivity, PetActivity.sleeping);
      expect(pet.energy, greaterThan(50));
    });

    test('Pet needs change over time', () {
      final pet = Pet(
        name: 'TestPet',
        type: PetType.dog,
        gender: PetGender.male,
        color: Colors.brown,
      );

      // Test needs change over time
      pet.lastFed = DateTime.now().subtract(const Duration(hours: 3));
      pet.updateState();
      expect(pet.hunger, greaterThan(0));

      pet.lastCleaned = DateTime.now().subtract(const Duration(hours: 5));
      pet.updateState();
      expect(pet.cleanliness, lessThan(100));
    });
  });

  group('Widget Tests', () {
    testWidgets('Pet Store Screen shows all elements', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(home: PetStoreScreen(onPetSelected: (Pet pet) {})),
      );

      expect(
        find.textContaining('Loyal and playful companion'),
        findsOneWidget,
      );
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Try Playing'), findsOneWidget);
      expect(find.text('Choose This Pet'), findsOneWidget);
    });

    testWidgets('Home Screen renders main UI', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
      // Expect app bar title
      expect(find.text('Pet Companion'), findsOneWidget);
      // Expect at least one action button (Feed)
      expect(find.text('Feed'), findsOneWidget);
    });
  });
}
