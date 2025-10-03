import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:ai_pet_companion/models/pet.dart';
import 'package:ai_pet_companion/models/pet_habitat.dart';
import 'package:ai_pet_companion/models/toy.dart';
import 'package:ai_pet_companion/services/pet_sound_service.dart';

void main() {
  PetSoundService.testingMode = true;
  group('Toy play & feeding habitat integration', () {
    late Pet pet;
    late Toy ball;

    setUp(() {
      pet = Pet(
        name: 'Tester',
        type: PetType.dog,
        gender: PetGender.male,
        color: Colors.brown,
      );
      pet.habitat = PetHabitat(petType: pet.type);
      ball = Toy(
        type: ToyType.ball,
        name: 'Ball',
        color: Colors.red,
        suitableFor: [PetType.dog],
        elasticity: 0.6,
      );
    });

    test('playWithToy sets non-null throwPosition even if none provided', () {
      expect(ball.throwPosition, isNull);
      pet.playWithToy(ball); // no throwPosition argument
      expect(pet.currentToy, equals(ball));
      expect(ball.throwPosition, isNotNull, reason: 'Default position should be assigned');
    });

    test('feed() toggles habitat hasFood and reduces hunger', () {
      pet.hunger = 60;
      expect(pet.habitat!.hasFood, isFalse);
      pet.feed();
      expect(pet.hunger, lessThan(60));
      expect(pet.habitat!.hasFood, isTrue);
    });

    test('refillFoodBowl only sets habitat food without large hunger drop', () {
      pet.hunger = 40;
      pet.habitat!.hasFood = false;
      pet.refillFoodBowl();
      expect(pet.habitat!.hasFood, isTrue);
      // Hunger unchanged (refill does not feed pet directly)
      expect(pet.hunger, 40);
    });

    test('refillWaterBowl sets habitat water', () {
      pet.habitat!.hasWater = false;
      pet.refillWaterBowl();
      expect(pet.habitat!.hasWater, isTrue);
    });

    test('hunger > 75 shifts mood away from happy', () {
      pet.hunger = 80;
      pet.updateState();
      expect(pet.mood, isNot(equals(PetMood.happy)));
    });
  });
}
