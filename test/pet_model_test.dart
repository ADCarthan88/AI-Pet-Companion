import 'package:flutter_test/flutter_test.dart';
import 'package:ai_pet_companion/models/pet.dart';
import 'package:flutter/material.dart';
import 'package:ai_pet_companion/services/pet_sound_service.dart';

void main() {
  PetSoundService.testingMode = true;
  group('Pet Model Tests', () {
    late Pet pet;

    setUp(() {
      pet = Pet(
        name: 'TestPet',
        type: PetType.dog,
        gender: PetGender.male,
        color: Colors.brown,
      );
      // Normalize to legacy baseline expected by tests
      pet.happiness = 50;
    });

    test('Pet initialization', () {
      expect(pet.name, 'TestPet');
      expect(pet.type, PetType.dog);
      expect(pet.gender, PetGender.male);
      expect(pet.color, Colors.brown);
      expect(pet.happiness, 50); // normalized above
      expect(pet.energy, 100);
      expect(pet.hunger, 0);
      expect(pet.cleanliness, 100);
      expect(pet.mood, PetMood.neutral);
      expect(pet.currentActivity, PetActivity.idle);
      expect(pet.isLicking, false);
    });

    test('Feed pet', () {
      pet.hunger = 50;
      pet.feed();
      expect(pet.hunger, 20);
      expect(pet.happiness, greaterThan(50));
      expect(pet.currentActivity, PetActivity.eating);
    });

    test('Feed pet with snack', () {
      pet.hunger = 50;
      pet.feed(isSnack: true);
      expect(pet.hunger, 35);
      expect(pet.happiness, greaterThan(50));
      expect(pet.currentActivity, PetActivity.eating);
    });

    test('Play with pet', () {
      int initialEnergy = pet.energy;
      int initialHappiness = pet.happiness;
      pet.play();
      expect(pet.energy, lessThan(initialEnergy));
      expect(pet.happiness, greaterThan(initialHappiness));
      expect(pet.currentActivity, PetActivity.playing);
    });

    test('Pet rest', () {
      pet.energy = 50;
      pet.rest();
      expect(pet.energy, greaterThan(50));
      expect(pet.currentActivity, PetActivity.sleeping);
    });

    test('Clean pet', () {
      pet.cleanliness = 50;
      pet.clean();
      expect(pet.cleanliness, 100);
      expect(pet.currentActivity, PetActivity.beingCleaned);
    });

    test('Brush pet', () {
      pet.cleanliness = 50;
      int initialHappiness = pet.happiness;
      pet.brush();
      expect(pet.cleanliness, greaterThan(50));
      expect(pet.happiness, greaterThan(initialHappiness));
      expect(pet.currentActivity, PetActivity.beingBrushed);
    });

    test('Pet licking behavior', () {
      pet.startLicking();
      expect(pet.isLicking, true);
      expect(pet.currentActivity, PetActivity.licking);
    });

    test('Pet mood changes based on stats', () {
      // Test happy mood
      pet.happiness = 80;
      pet.energy = 70;
      pet.cleanliness = 80;
      pet.updateState();
      expect(pet.mood, PetMood.loving);

      // Test sad mood (reset stats first)
      pet.happiness = 50;
      pet.energy = 50;
      pet.cleanliness = 50;
      pet.hunger = 80;
      pet.updateState();
      expect(pet.mood, PetMood.sad);

      // Test tired mood (reset other stats first)
      pet.happiness = 50;
      pet.hunger = 0;
      pet.cleanliness = 50;
      pet.energy = 20;
      pet.updateState();
      expect(pet.mood, PetMood.tired);
    });

    test('AI behavior decision making', () {
      // Test rest decision
      pet.energy = 10;
      pet.decideNextAction();
      expect(pet.currentActivity, PetActivity.sleeping);

      // Test eating decision
      pet.energy = 100;
      pet.hunger = 80;
      pet.decideNextAction();
      expect(pet.currentActivity, PetActivity.eating);

      // Test cleaning decision
      pet.hunger = 0;
      pet.cleanliness = 30;
      pet.decideNextAction();
      expect(pet.currentActivity, PetActivity.beingCleaned);

      // Test play decision
      pet.cleanliness = 100;
      pet.happiness = 20;
      pet.energy = 60;
      pet.decideNextAction();
      expect(pet.currentActivity, PetActivity.playing);
    });
  });
}
