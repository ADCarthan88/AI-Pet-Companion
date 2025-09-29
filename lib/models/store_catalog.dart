import 'package:flutter/material.dart';
import 'store_item.dart';
import 'pet.dart';

class StoreCatalog {
  static List<StoreItem> generateFullCatalog() {
    List<StoreItem> catalog = [];

    // Generate Food Items
    catalog.addAll(_generateFoodItems());

    // Generate Toy Items
    catalog.addAll(_generateToyItems());

    // Generate Furniture Items
    catalog.addAll(_generateFurnitureItems());

    // Generate Accessory Items
    catalog.addAll(_generateAccessoryItems());

    // Generate Grooming Items
    catalog.addAll(_generateGroomingItems());

    return catalog;
  }

  static List<StoreItem> _generateFoodItems() {
    return [
      // Basic Foods (50-100 coins)
      _createFoodItem(
        'basic_kibble',
        'Basic Kibble',
        'Standard dry food',
        50,
        [PetType.dog, PetType.cat],
        [Colors.brown[400]!],
        15,
        10,
      ),

      // Premium Foods (100-500 coins)
      _createFoodItem(
        'premium_kibble',
        'Premium Kibble',
        'High-quality dry food with vitamins',
        200,
        [PetType.dog, PetType.cat],
        [Colors.brown[600]!, Colors.brown[800]!],
        30,
        25,
      ),
      _createFoodItem(
        'organic_feast',
        'Organic Pet Feast',
        'All-natural organic ingredients',
        350,
        [PetType.dog, PetType.cat, PetType.rabbit],
        [Colors.green[700]!, Colors.brown[500]!],
        40,
        35,
      ),

      // Luxury Foods (500-1000 coins)
      _createFoodItem(
        'gourmet_dinner',
        'Gourmet Pet Dinner',
        'Chef-prepared premium meal',
        750,
        [PetType.dog, PetType.cat],
        [Colors.purple[300]!, Colors.purple[500]!],
        50,
        45,
      ),

      // Exotic Foods (1000+ coins)
      _createFoodItem(
        'royal_bamboo',
        'Royal Bamboo Selection',
        'Hand-picked premium bamboo shoots with rare varieties',
        1200,
        [PetType.panda],
        [Colors.green[300]!, Colors.green[500]!, Colors.green[700]!],
        60,
        50,
      ),
      _createFoodItem(
        'arctic_delicacy',
        'Arctic Delicacy',
        'Premium fish selection from arctic waters',
        1500,
        [PetType.penguin],
        [Colors.blue[100]!, Colors.blue[300]!],
        65,
        55,
      ),
      _createFoodItem(
        'savannah_feast',
        'Ultimate Savannah Feast',
        'Premium meat selection fit for the king of beasts',
        2000,
        [PetType.lion],
        [Colors.red[300]!, Colors.red[500]!],
        70,
        60,
      ),
    ];
  }

  static List<StoreItem> _generateToyItems() {
    return [
      // Basic Toys (100-300 coins)
      _createToyItem(
        'smart_ball',
        'Smart Ball',
        'Interactive ball that responds to movement',
        200,
        [PetType.dog, PetType.cat, PetType.lion],
        [Colors.red, Colors.blue, Colors.green, Colors.yellow],
        25,
      ),

      // Premium Toys (300-800 coins)
      _createToyItem(
        'laser_system',
        'Automated Laser Play System',
        'Smart laser toy with multiple play patterns',
        500,
        [PetType.dog, PetType.cat],
        [Colors.red[400]!, Colors.blue[400]!],
        40,
      ),
      _createToyItem(
        'climbing_gym',
        'Advanced Climbing Gym',
        'Multi-level exercise structure',
        750,
        [PetType.cat, PetType.panda],
        [Colors.brown[300]!, Colors.grey[400]!],
        45,
      ),

      // Luxury Toys (800-2000 coins)
      _createToyItem(
        'smart_playground',
        'Smart Pet Playground',
        'Interactive playground with AI-driven games',
        1500,
        [PetType.dog, PetType.cat],
        [Colors.blue[600]!, Colors.green[600]!],
        60,
      ),

      // Ultimate Toys (2000+ coins)
      _createToyItem(
        'vr_playground',
        'Virtual Reality Pet Paradise',
        'Next-gen VR playground with immersive experiences',
        2500,
        [PetType.dog, PetType.cat, PetType.lion, PetType.penguin],
        [Colors.purple[400]!, Colors.blue[500]!, Colors.green[500]!],
        75,
      ),
      _createToyItem(
        'arctic_simulator',
        'Arctic Environment Simulator',
        'Creates a perfect arctic playground',
        3000,
        [PetType.penguin],
        [Colors.blue[100]!, Colors.white70],
        80,
      ),
      _createToyItem(
        'savannah_simulator',
        'Savannah Hunt Simulator',
        'Ultimate hunting and exercise experience',
        3500,
        [PetType.lion],
        [Colors.orange[300]!, Colors.amber[500]!],
        85,
      ),
    ];
  }

  static List<StoreItem> _generateFurnitureItems() {
    return [
      // Basic Furniture (100-300 coins)
      _createFurnitureItem(
        'comfort_bed',
        'Comfort Pet Bed',
        'Cozy bed with soft materials',
        200,
        [PetType.dog, PetType.cat, PetType.rabbit],
        [Colors.grey[300]!, Colors.blue[100]!, Colors.pink[100]!],
        20,
      ),

      // Premium Furniture (300-800 coins)
      _createFurnitureItem(
        'luxury_bed',
        'Luxury Memory Foam Bed',
        'Premium memory foam bed with orthopedic support',
        500,
        [PetType.dog, PetType.cat],
        [Colors.grey[400]!, Colors.blue[200]!, Colors.purple[100]!],
        35,
      ),
      _createFurnitureItem(
        'cat_mansion',
        'Deluxe Cat Mansion',
        'Multi-level luxury climbing structure',
        750,
        [PetType.cat],
        [Color(0xFFF5F5DC), Colors.grey[300]!, Colors.brown[200]!],
        40,
      ),

      // Luxury Furniture (800-2000 coins)
      _createFurnitureItem(
        'smart_bed',
        'Smart Comfort System',
        'Temperature-controlled bed with health monitoring',
        1500,
        [PetType.dog, PetType.cat, PetType.rabbit],
        [Colors.blue[500]!, Colors.grey[400]!],
        55,
      ),

      // Ultimate Furniture (2000+ coins)
      _createFurnitureItem(
        'zen_suite',
        'Zen Relaxation Suite',
        'Complete relaxation system with massage and aromatherapy',
        2500,
        [PetType.dog, PetType.cat],
        [Colors.teal[300]!, Colors.brown[300]!],
        70,
      ),
      _createFurnitureItem(
        'bamboo_paradise',
        'Bamboo Paradise Structure',
        'Authentic bamboo climbing and relaxation system',
        3000,
        [PetType.panda],
        [Colors.green[700]!, Colors.brown[600]!],
        75,
      ),
      _createFurnitureItem(
        'climate_pod',
        'Climate-Controlled Pod',
        'Advanced sleeping pod with perfect temperature control',
        3500,
        [PetType.penguin, PetType.lion],
        [Colors.blue[400]!, Colors.grey[600]!],
        80,
      ),
    ];
  }

  static List<StoreItem> _generateAccessoryItems() {
    return [
      // Basic Accessories (50-200 coins)
      _createAccessoryItem(
        'bow_tie',
        'Fancy Bow Tie',
        'Elegant bow tie for formal occasions',
        50,
        [PetType.dog, PetType.cat, PetType.penguin],
        [Colors.red, Colors.black, Colors.blue, Colors.purple],
        10,
      ),
      _createAccessoryItem(
        'led_collar',
        'LED Safety Collar',
        'Light-up collar for night safety',
        150,
        [PetType.dog, PetType.cat],
        [Colors.blue, Colors.green, Colors.pink, Colors.orange],
        15,
      ),

      // Premium Accessories (200-500 coins)
      _createAccessoryItem(
        'smart_collar',
        'Smart Health Collar',
        'Collar with health monitoring features',
        400,
        [PetType.dog, PetType.cat],
        [Colors.blue[400]!, Colors.grey[600]!, Colors.purple[300]!],
        25,
      ),
      _createAccessoryItem(
        'royal_crown',
        'Royal Pet Crown',
        'Jeweled crown for the most distinguished pets',
        500,
        [PetType.dog, PetType.cat, PetType.lion],
        [Colors.yellow[600]!, Colors.purple[400]!],
        30,
      ),

      // Luxury Accessories (500-1500 coins)
      _createAccessoryItem(
        'designer_wear',
        'Designer Pet Collection',
        'Exclusive designer pet fashion line',
        1000,
        [PetType.dog, PetType.cat],
        [Colors.black, Colors.amber[100]!, Colors.pink[300]!],
        40,
      ),

      // Ultimate Accessories (1500+ coins)
      _createAccessoryItem(
        'tech_wearable',
        'Advanced Pet Wearable',
        'Smart wearable with health tracking and GPS',
        2000,
        [PetType.dog, PetType.cat, PetType.lion],
        [Colors.blue[600]!, Colors.grey[800]!],
        50,
      ),
      _createAccessoryItem(
        'climate_suit',
        'Environmental Suit',
        'Advanced climate control wearable',
        2500,
        [PetType.penguin, PetType.lion],
        [Colors.white, Colors.blue[200]!],
        55,
      ),
    ];
  }

  static List<StoreItem> _generateGroomingItems() {
    return [
      // Basic Grooming (50-200 coins)
      _createGroomingItem(
        'basic_brush',
        'Basic Grooming Brush',
        'Standard grooming brush',
        50,
        [PetType.dog, PetType.cat, PetType.rabbit],
        [Colors.grey[400]!],
        10,
        20,
      ),

      // Premium Grooming (200-500 coins)
      _createGroomingItem(
        'pro_brush',
        'Professional Grooming Kit',
        'Complete grooming kit with premium tools',
        300,
        [PetType.dog, PetType.cat, PetType.rabbit],
        [Colors.grey[700]!],
        20,
        40,
      ),
      _createGroomingItem(
        'spa_essentials',
        'Pet Spa Essentials',
        'Luxury grooming and spa treatment kit',
        450,
        [PetType.dog, PetType.cat],
        [Colors.purple[200]!, Colors.blue[200]!],
        25,
        45,
      ),

      // Luxury Grooming (500-1500 coins)
      _createGroomingItem(
        'grooming_station',
        'Professional Grooming Station',
        'Complete grooming station with advanced tools',
        1000,
        [PetType.dog, PetType.cat, PetType.rabbit],
        [Colors.grey[800]!, Colors.blue[400]!],
        35,
        60,
      ),

      // Ultimate Grooming (1500+ coins)
      _createGroomingItem(
        'smart_grooming',
        'Smart Grooming System',
        'AI-powered grooming system with automatic features',
        2000,
        [PetType.dog, PetType.cat],
        [Colors.blue[600]!, Colors.grey[600]!],
        45,
        70,
      ),
      _createGroomingItem(
        'luxury_spa',
        'Luxury Pet Spa System',
        'Complete spa and grooming system with aromatherapy',
        2500,
        [PetType.dog, PetType.cat, PetType.rabbit],
        [Colors.purple[400]!, Colors.pink[200]!],
        50,
        80,
      ),
    ];
  }

  // Helper methods to create items
  static StoreItem _createFoodItem(
    String id,
    String name,
    String description,
    double price,
    List<PetType> suitableFor,
    List<Color> colors,
    double energyBoost,
    double healthBoost,
  ) {
    return StoreItem(
      id: id,
      name: name,
      description: description,
      price: price,
      category: ItemCategory.food,
      suitableFor: suitableFor,
      availableColors: colors,
      icon: Icons.restaurant,
      energyBoost: energyBoost,
      healthBoost: healthBoost,
    );
  }

  static StoreItem _createToyItem(
    String id,
    String name,
    String description,
    double price,
    List<PetType> suitableFor,
    List<Color> colors,
    double happinessBoost,
  ) {
    return StoreItem(
      id: id,
      name: name,
      description: description,
      price: price,
      category: ItemCategory.toys,
      suitableFor: suitableFor,
      availableColors: colors,
      icon: Icons.toys,
      happinessBoost: happinessBoost,
      energyBoost: -5, // Playing with toys uses energy
    );
  }

  static StoreItem _createFurnitureItem(
    String id,
    String name,
    String description,
    double price,
    List<PetType> suitableFor,
    List<Color> colors,
    double comfortBoost,
  ) {
    return StoreItem(
      id: id,
      name: name,
      description: description,
      price: price,
      category: ItemCategory.furniture,
      suitableFor: suitableFor,
      availableColors: colors,
      icon: Icons.chair,
      happinessBoost: comfortBoost / 2,
      energyBoost: comfortBoost,
    );
  }

  static StoreItem _createAccessoryItem(
    String id,
    String name,
    String description,
    double price,
    List<PetType> suitableFor,
    List<Color> colors,
    double happinessBoost,
  ) {
    return StoreItem(
      id: id,
      name: name,
      description: description,
      price: price,
      category: ItemCategory.accessories,
      suitableFor: suitableFor,
      availableColors: colors,
      icon: Icons.style,
      happinessBoost: happinessBoost,
    );
  }

  static StoreItem _createGroomingItem(
    String id,
    String name,
    String description,
    double price,
    List<PetType> suitableFor,
    List<Color> colors,
    double happinessBoost,
    double cleanlinessBoost,
  ) {
    return StoreItem(
      id: id,
      name: name,
      description: description,
      price: price,
      category: ItemCategory.grooming,
      suitableFor: suitableFor,
      availableColors: colors,
      icon: Icons.brush,
      happinessBoost: happinessBoost,
      cleanlinessBoost: cleanlinessBoost,
    );
  }
}
