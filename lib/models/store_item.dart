import 'package:flutter/material.dart';
import 'pet.dart';
import 'store_catalog.dart';

// AppColors for custom colors not in Flutter's Colors class
class AppColors {
  static const Color bronze = Color(0xFFCD7F32);
  static const Color silver = Color(0xFFC0C0C0);
  static const Color gold = Color(0xFFFFD700);
  static const Color roseGold = Color(0xFFB76E79);
  static const Color platinum = Color(0xFFE5E4E2);
  static const Color copper = Color(0xFFB87333);
}

enum ItemCategory {
  food,
  toys,
  furniture,
  accessories,
  grooming,
  beds,
  treats,
  healthCare,
  weatherItems,
}

class StoreItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final ItemCategory category;
  final List<PetType> suitableFor;
  final List<Color> availableColors;
  final IconData icon;
  final double happinessBoost;
  final double energyBoost;
  final double healthBoost;
  final double cleanlinessBoost;
  bool isOwned;
  Color? selectedColor;

  StoreItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.suitableFor,
    required this.availableColors,
    required this.icon,
    this.happinessBoost = 0,
    this.energyBoost = 0,
    this.healthBoost = 0,
    this.cleanlinessBoost = 0,
    this.isOwned = false,
    this.selectedColor,
  });

  // Base items for each category
  static final List<StoreItem> foodItems = [
    // Premium Foods (10 variants)
    StoreItem(
      id: 'premium_kibble',
      name: 'Premium Kibble',
      description: 'High-quality dry food',
      price: 100,
      category: ItemCategory.food,
      suitableFor: [PetType.dog, PetType.cat],
      availableColors: [
        Colors.brown[400]!,
        AppColors.gold,
        AppColors.silver,
        AppColors.bronze,
        AppColors.platinum,
      ],
      icon: Icons.restaurant,
      energyBoost: 30,
      healthBoost: 20,
    ),
    StoreItem(
      id: 'fresh_bamboo',
      name: 'Fresh Bamboo',
      description: 'Premium bamboo shoots',
      price: 150,
      category: ItemCategory.food,
      suitableFor: [PetType.panda],
      availableColors: [
        Colors.green[300]!,
        Colors.green[500]!,
        AppColors.copper,
      ],
      icon: Icons.grass,
      energyBoost: 40,
      healthBoost: 25,
    ),
    // Add more food items...
  ];

  static final List<StoreItem> toyItems = [
    // Interactive Toys (15 variants)
    StoreItem(
      id: 'smart_ball',
      name: 'Smart Interactive Ball',
      description: 'Ball that responds to pet movement',
      price: 200,
      category: ItemCategory.toys,
      suitableFor: [PetType.dog, PetType.cat, PetType.lion],
      availableColors: [
        Colors.red,
        Colors.blue,
        Colors.green,
        Colors.yellow,
        Colors.purple,
        Colors.orange,
        AppColors.gold,
        AppColors.silver,
        AppColors.bronze,
        AppColors.roseGold,
      ],
      icon: Icons.sports_baseball,
      happinessBoost: 25,
      energyBoost: -10,
    ),
    // Add more toy items...
  ];

  static final List<StoreItem> furnitureItems = [
    // Luxury Furniture (12 variants)
    StoreItem(
      id: 'deluxe_bed',
      name: 'Deluxe Pet Bed',
      description: 'Premium memory foam pet bed',
      price: 300,
      category: ItemCategory.furniture,
      suitableFor: [PetType.dog, PetType.cat, PetType.rabbit],
      availableColors: [
        Colors.grey[300]!,
        Colors.blue[100]!,
        Colors.pink[100]!,
        Colors.brown[200]!,
        AppColors.platinum,
        AppColors.gold,
        AppColors.silver,
      ],
      icon: Icons.bed,
      happinessBoost: 15,
      energyBoost: 20,
    ),
    // Add more furniture items...
  ];

  static final List<StoreItem> accessoryItems = [
    // Fashion Accessories (15 variants)
    StoreItem(
      id: 'bow_tie',
      name: 'Fancy Bow Tie',
      description: 'Elegant bow tie for formal occasions',
      price: 50,
      category: ItemCategory.accessories,
      suitableFor: [PetType.dog, PetType.cat, PetType.penguin],
      availableColors: [
        Colors.red,
        Colors.black,
        Colors.blue,
        Colors.purple,
        Colors.green,
        AppColors.gold,
        AppColors.roseGold,
        AppColors.silver,
        AppColors.bronze,
      ],
      icon: Icons.bookmark,
      happinessBoost: 10,
    ),
    // Add more accessory items...
  ];

  static final List<StoreItem> groomingItems = [
    // Grooming Tools (10 variants)
    StoreItem(
      id: 'luxury_brush',
      name: 'Luxury Grooming Brush',
      description: 'Professional-grade grooming brush',
      price: 150,
      category: ItemCategory.grooming,
      suitableFor: [PetType.dog, PetType.cat, PetType.rabbit],
      availableColors: [
        Colors.grey[300]!,
        Colors.amber[400]!,
        Colors.brown[400]!,
        AppColors.copper,
        AppColors.gold,
        AppColors.silver,
      ],
      icon: Icons.brush,
      cleanlinessBoost: 30,
      happinessBoost: 15,
    ),
    // Add more grooming items...
  ];

  // Helper method to get all items for a specific pet type
  static List<StoreItem> getItemsForPet(PetType petType) {
    // Import the store catalog to access all items including beds
    var catalog = StoreCatalog.generateFullCatalog();

    return catalog.where((item) => item.suitableFor.contains(petType)).toList();
  }

  // Helper method to get items by category
  static List<StoreItem> getItemsByCategory(
    ItemCategory category,
    PetType petType,
  ) {
    return getItemsForPet(
      petType,
    ).where((item) => item.category == category).toList();
  }
}
