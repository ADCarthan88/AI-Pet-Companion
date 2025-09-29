import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:ai_pet_companion/models/pet.dart';
import 'package:ai_pet_companion/models/pet_habitat.dart';

void main() {
  group('Habitat Tests', () {
    late PetHabitat habitat;
    late HabitatItem testItem;

    setUp(() {
      habitat = PetHabitat(petType: PetType.lion, theme: HabitatTheme.savannah);

      testItem = HabitatItem(
        name: 'Test Rock',
        description: 'A test rock',
        cost: 100,
        icon: Icons.landscape,
        suitableFor: [PetType.lion],
        theme: HabitatTheme.savannah,
      );
    });

    test('Habitat initialization', () {
      expect(habitat.petType, PetType.lion);
      expect(habitat.theme, HabitatTheme.savannah);
      expect(habitat.items, isEmpty);
      expect(habitat.happiness, 50.0);
      expect(habitat.comfort, 50.0);
    });

    test('Adding suitable item', () {
      habitat.addItem(testItem);
      expect(habitat.items.length, 1);
      expect(habitat.items.first, testItem);
      expect(habitat.happiness, greaterThan(50.0));
      expect(habitat.comfort, greaterThan(50.0));
    });

    test('Adding unsuitable item', () {
      final unsuitableItem = HabitatItem(
        name: 'Ice Block',
        description: 'An ice block',
        cost: 75,
        icon: Icons.ac_unit,
        suitableFor: [PetType.penguin],
        theme: HabitatTheme.arctic,
      );

      habitat.addItem(unsuitableItem);
      expect(habitat.items, isEmpty);
      expect(habitat.happiness, 50.0);
      expect(habitat.comfort, 50.0);
    });

    test('Removing item', () {
      habitat.addItem(testItem);
      expect(habitat.items.length, 1);

      habitat.removeItem(testItem);
      expect(habitat.items, isEmpty);
      expect(habitat.happiness, 50.0);
      expect(habitat.comfort, 50.0);
    });

    test('Theme bonus calculation', () {
      // Add matching theme item
      habitat.addItem(testItem);
      double happinessWithThemeBonus = habitat.happiness;

      // Add non-matching theme item
      final otherItem = HabitatItem(
        name: 'Plant',
        description: 'A plant',
        cost: 50,
        icon: Icons.park,
        suitableFor: [PetType.lion],
        theme: HabitatTheme.jungle,
      );
      habitat.addItem(otherItem);

      // The happiness bonus from the themed item should be higher
      expect(happinessWithThemeBonus, greaterThan(50.0));
      expect(habitat.happiness, greaterThanOrEqualTo(happinessWithThemeBonus));
    });
  });
}
