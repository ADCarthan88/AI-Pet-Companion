import 'package:flutter_test/flutter_test.dart';
import 'package:ai_pet_companion/models/store_catalog.dart';
import 'package:ai_pet_companion/models/store_item.dart';
import 'package:ai_pet_companion/models/pet.dart';

void main() {
  group('Store Catalog Tests', () {
    late List<StoreItem> catalog;

    setUp(() {
      catalog = StoreCatalog.generateFullCatalog();
    });

    test('Catalog contains items of all categories', () {
      expect(
        catalog.any((item) => item.category == ItemCategory.food),
        isTrue,
        reason: 'Catalog should contain food items',
      );
      expect(
        catalog.any((item) => item.category == ItemCategory.toys),
        isTrue,
        reason: 'Catalog should contain toy items',
      );
      expect(
        catalog.any((item) => item.category == ItemCategory.furniture),
        isTrue,
        reason: 'Catalog should contain furniture items',
      );
      expect(
        catalog.any((item) => item.category == ItemCategory.accessories),
        isTrue,
        reason: 'Catalog should contain accessory items',
      );
      expect(
        catalog.any((item) => item.category == ItemCategory.grooming),
        isTrue,
        reason: 'Catalog should contain grooming items',
      );
    });

    test('Catalog contains items of different price tiers', () {
      // Food items price tiers
      var foodItems = catalog.where(
        (item) => item.category == ItemCategory.food,
      );
      expect(
        foodItems.any((item) => item.price <= 100), // Basic
        isTrue,
        reason: 'Should have basic food items',
      );
      expect(
        foodItems.any(
          (item) => item.price > 500 && item.price <= 1000,
        ), // Luxury
        isTrue,
        reason: 'Should have luxury food items',
      );
      expect(
        foodItems.any((item) => item.price > 1000), // Exotic
        isTrue,
        reason: 'Should have exotic food items',
      );

      // Toy items price tiers
      var toyItems = catalog.where(
        (item) => item.category == ItemCategory.toys,
      );
      expect(
        toyItems.any((item) => item.price <= 300), // Basic
        isTrue,
        reason: 'Should have basic toy items',
      );
      expect(
        toyItems.any(
          (item) => item.price > 800 && item.price <= 2000,
        ), // Luxury
        isTrue,
        reason: 'Should have luxury toy items',
      );
      expect(
        toyItems.any((item) => item.price > 2000), // Ultimate
        isTrue,
        reason: 'Should have ultimate toy items',
      );
    });

    test('Items have appropriate effects based on price tier', () {
      // Test food items
      var basicFood = catalog
          .where(
            (item) => item.category == ItemCategory.food && item.price <= 100,
          )
          .first;
      var luxuryFood = catalog
          .where(
            (item) => item.category == ItemCategory.food && item.price > 1000,
          )
          .first;

      expect(
        basicFood.energyBoost,
        lessThan(luxuryFood.energyBoost),
        reason: 'Luxury food should provide more energy than basic food',
      );

      // Test toy items
      var basicToy = catalog
          .where(
            (item) => item.category == ItemCategory.toys && item.price <= 300,
          )
          .first;
      var ultimateToy = catalog
          .where(
            (item) => item.category == ItemCategory.toys && item.price > 2000,
          )
          .first;

      expect(
        basicToy.happinessBoost,
        lessThan(ultimateToy.happinessBoost),
        reason: 'Ultimate toys should provide more happiness than basic toys',
      );
    });

    test('Items are suitable for appropriate pet types', () {
      // Test arctic items are suitable for penguins
      var arcticItems = catalog.where(
        (item) => item.name.toLowerCase().contains('arctic'),
      );
      for (var item in arcticItems) {
        expect(
          item.suitableFor.contains(PetType.penguin),
          isTrue,
          reason: 'Arctic items should be suitable for penguins',
        );
      }

      // Test savannah items are suitable for lions
      var savannahItems = catalog.where(
        (item) => item.name.toLowerCase().contains('savannah'),
      );
      for (var item in savannahItems) {
        expect(
          item.suitableFor.contains(PetType.lion),
          isTrue,
          reason: 'Savannah items should be suitable for lions',
        );
      }
    });

    test('Premium items have appropriate colors', () {
      var premiumItems = catalog.where((item) => item.price > 1000);
      for (var item in premiumItems) {
        expect(
          item.availableColors.length,
          greaterThanOrEqualTo(2),
          reason: 'Premium items should have multiple color options',
        );
      }
    });
  });
}
