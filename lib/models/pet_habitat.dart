import 'package:flutter/material.dart';
import 'pet.dart';
import 'weather_system.dart';

enum HabitatTheme {
  jungle,
  savannah,
  arctic,
  forest,
  bambooGrove,
  mountain,
  desert,
  ocean,
  house,
  garden,
  park,
}

class HabitatItem {
  final String name;
  final String description;
  final double cost;
  final IconData icon;
  final List<PetType> suitableFor;
  final HabitatTheme theme;
  bool isOwned;

  HabitatItem({
    required this.name,
    required this.description,
    required this.cost,
    required this.icon,
    required this.suitableFor,
    required this.theme,
    this.isOwned = false,
  });

  static List<HabitatItem> getItemsForPetType(PetType type) {
    return allItems.where((item) => item.suitableFor.contains(type)).toList();
  }

  static final List<HabitatItem> allItems = [
    // Lion habitat items
    HabitatItem(
      name: 'Savannah Rock',
      description: 'A perfect lounging spot for lions',
      cost: 100,
      icon: Icons.landscape,
      suitableFor: [PetType.lion],
      theme: HabitatTheme.savannah,
    ),
    HabitatItem(
      name: 'Pride Tree',
      description: 'Shady acacia tree to rest under',
      cost: 150,
      icon: Icons.park,
      suitableFor: [PetType.lion],
      theme: HabitatTheme.savannah,
    ),
    HabitatItem(
      name: 'Watering Hole',
      description: 'A refreshing water source',
      cost: 200,
      icon: Icons.water_drop,
      suitableFor: [PetType.lion, PetType.giraffe],
      theme: HabitatTheme.savannah,
    ),

    // Giraffe habitat items
    HabitatItem(
      name: 'Tall Tree',
      description: 'Acacia tree with delicious leaves',
      cost: 150,
      icon: Icons.park,
      suitableFor: [PetType.giraffe],
      theme: HabitatTheme.savannah,
    ),
    HabitatItem(
      name: 'Feeding Station',
      description: 'High platform with fresh leaves',
      cost: 175,
      icon: Icons.restaurant,
      suitableFor: [PetType.giraffe],
      theme: HabitatTheme.savannah,
    ),

    // Penguin habitat items
    HabitatItem(
      name: 'Ice Block',
      description: 'Cool ice block for sliding',
      cost: 75,
      icon: Icons.ac_unit,
      suitableFor: [PetType.penguin],
      theme: HabitatTheme.arctic,
    ),
    HabitatItem(
      name: 'Fishing Spot',
      description: 'Area with fresh fish to catch',
      cost: 125,
      icon: Icons.waves,
      suitableFor: [PetType.penguin],
      theme: HabitatTheme.arctic,
    ),
    HabitatItem(
      name: 'Igloo',
      description: 'Cozy shelter from the cold',
      cost: 200,
      icon: Icons.home,
      suitableFor: [PetType.penguin],
      theme: HabitatTheme.arctic,
    ),

    // Panda habitat items
    HabitatItem(
      name: 'Bamboo Grove',
      description: 'Dense bamboo forest section',
      cost: 200,
      icon: Icons.forest,
      suitableFor: [PetType.panda],
      theme: HabitatTheme.bambooGrove,
    ),
    HabitatItem(
      name: 'Climbing Tree',
      description: 'Sturdy tree perfect for climbing',
      cost: 150,
      icon: Icons.nature,
      suitableFor: [PetType.panda],
      theme: HabitatTheme.bambooGrove,
    ),
    HabitatItem(
      name: 'Stream',
      description: 'Fresh mountain stream',
      cost: 175,
      icon: Icons.water,
      suitableFor: [PetType.panda],
      theme: HabitatTheme.bambooGrove,
    ),

    // Dog habitat items
    HabitatItem(
      name: 'Dog Bed',
      description: 'Comfortable bed for your dog',
      cost: 100,
      icon: Icons.bed,
      suitableFor: [PetType.dog],
      theme: HabitatTheme.house,
    ),
    HabitatItem(
      name: 'Doggy Door',
      description: 'Special door for outdoor access',
      cost: 150,
      icon: Icons.door_sliding,
      suitableFor: [PetType.dog],
      theme: HabitatTheme.house,
    ),
    HabitatItem(
      name: 'Toy Basket',
      description: 'Storage for all dog toys',
      cost: 75,
      icon: Icons.toys,
      suitableFor: [PetType.dog],
      theme: HabitatTheme.house,
    ),

    // Cat habitat items
    HabitatItem(
      name: 'Cat Tower',
      description: 'Multilevel tower with scratching posts',
      cost: 200,
      icon: Icons.apartment,
      suitableFor: [PetType.cat],
      theme: HabitatTheme.house,
    ),
    HabitatItem(
      name: 'Window Perch',
      description: 'Comfortable spot to watch outside',
      cost: 100,
      icon: Icons.weekend,
      suitableFor: [PetType.cat],
      theme: HabitatTheme.house,
    ),
    HabitatItem(
      name: 'Scratching Post',
      description: 'Essential for healthy claws',
      cost: 75,
      icon: Icons.format_color_text,
      suitableFor: [PetType.cat],
      theme: HabitatTheme.house,
    ),

    // Bird habitat items
    HabitatItem(
      name: 'Bird Perch',
      description: 'Natural branch for perching',
      cost: 50,
      icon: Icons.holiday_village,
      suitableFor: [PetType.bird],
      theme: HabitatTheme.forest,
    ),
    HabitatItem(
      name: 'Nest',
      description: 'Cozy nest for resting',
      cost: 75,
      icon: Icons.filter_drama,
      suitableFor: [PetType.bird],
      theme: HabitatTheme.forest,
    ),
    HabitatItem(
      name: 'Birdbath',
      description: 'Water for bathing and drinking',
      cost: 100,
      icon: Icons.water_drop,
      suitableFor: [PetType.bird],
      theme: HabitatTheme.forest,
    ),

    // Rabbit habitat items
    HabitatItem(
      name: 'Rabbit Warren',
      description: 'Underground tunnel system',
      cost: 150,
      icon: Icons.travel_explore,
      suitableFor: [PetType.rabbit],
      theme: HabitatTheme.garden,
    ),
    HabitatItem(
      name: 'Veggie Patch',
      description: 'Fresh vegetables to nibble on',
      cost: 100,
      icon: Icons.eco,
      suitableFor: [PetType.rabbit],
      theme: HabitatTheme.garden,
    ),
    HabitatItem(
      name: 'Hideaway',
      description: 'Safe place to rest and hide',
      cost: 75,
      icon: Icons.cottage,
      suitableFor: [PetType.rabbit],
      theme: HabitatTheme.garden,
    ),
  ];
}

class PetHabitat {
  final PetType petType;
  HabitatTheme theme;
  List<HabitatItem> items;
  double happiness;
  double comfort;
  double cleanliness;
  int insectCount;
  bool hasWaste;
  DateTime lastCleaned;
  bool hasWater;
  bool hasFood;
  Color floorColor;
  Color wallColor;
  String background;
  WeatherType currentWeather;

  // Interactive elements
  bool hasInteractiveElements;
  List<String> interactiveElements;

  PetHabitat({
    required this.petType,
    HabitatTheme? theme,
    List<HabitatItem>? items,
    this.hasInteractiveElements = false,
    Color? floorColor,
    Color? wallColor,
    String? background,
    WeatherType? weather,
  }) : theme = theme ?? getDefaultTheme(petType),
       currentWeather = weather ?? getDefaultWeather(petType),
       items = items ?? [],
       happiness = 50.0,
       comfort = 50.0,
       cleanliness = 100.0,
       insectCount = 0,
       hasWaste = false,
       lastCleaned = DateTime.now(),
       hasWater = true,
       hasFood = true,
       floorColor =
           floorColor ??
           _getDefaultFloorColor(theme ?? getDefaultTheme(petType)),
       wallColor =
           wallColor ?? _getDefaultWallColor(theme ?? getDefaultTheme(petType)),
       background =
           background ??
           _getDefaultBackground(petType, theme ?? getDefaultTheme(petType)),
       interactiveElements = [];

  void addItem(HabitatItem item) {
    if (item.suitableFor.contains(petType)) {
      items.add(item);
      calculateHappinessAndComfort();
    }
  }

  void removeItem(HabitatItem item) {
    items.remove(item);
    calculateHappinessAndComfort();
  }

  void changeWeather(WeatherType newWeather) {
    currentWeather = newWeather;

    // Update habitat based on weather
    if (newWeather == WeatherType.rainy) {
      // Rain helps clean the habitat slightly
      updateCleanliness(5.0);
      // Water is automatically refilled
      hasWater = true;
    } else if (newWeather == WeatherType.sunny) {
      // Sun dries up water faster
      hasWater = false;
    } else if (newWeather == WeatherType.snowy) {
      // Snow provides water but decreases comfort for some pets
      hasWater = true;
      if (petType != PetType.penguin) {
        comfort = (comfort - 5).clamp(0.0, 100.0);
      }
    }
  }

  void updateCleanliness(double amount) {
    cleanliness += amount;
    cleanliness = cleanliness.clamp(0.0, 100.0);

    // Generate insects if cleanliness is low
    if (cleanliness < 30.0 &&
        DateTime.now().difference(lastCleaned).inHours > 1) {
      insectCount = (5 * (1 - cleanliness / 100)).round();
    } else if (cleanliness > 70.0) {
      insectCount = 0;
    }

    // Update waste based on cleanliness
    if (cleanliness < 20.0) {
      hasWaste = true;
    }

    calculateHappinessAndComfort();
  }

  void clean() {
    cleanliness = 100.0;
    insectCount = 0;
    hasWaste = false;
    lastCleaned = DateTime.now();
    calculateHappinessAndComfort();
  }

  void addWater() {
    hasWater = true;
    calculateHappinessAndComfort();
  }

  void addFood() {
    hasFood = true;
    calculateHappinessAndComfort();
  }

  void consumeResources() {
    if (hasWater) {
      hasWater = false;
    }

    if (hasFood) {
      hasFood = false;
    }

    calculateHappinessAndComfort();
  }

  void addInteractiveElement(String element) {
    if (!interactiveElements.contains(element)) {
      interactiveElements.add(element);
      hasInteractiveElements = true;
    }
  }

  void removeInteractiveElement(String element) {
    interactiveElements.remove(element);
    if (interactiveElements.isEmpty) {
      hasInteractiveElements = false;
    }
  }

  // Calculate happiness and comfort based on habitat conditions
  void calculateHappinessAndComfort() {
    // Base values from items
    happiness = 50.0 + (items.length * 5.0);
    comfort = 50.0 + (items.where((item) => item.theme == theme).length * 10.0);

    // Additional factors affecting happiness and comfort
    if (hasWater) happiness += 5.0;
    if (hasFood) happiness += 5.0;
    if (!hasWaste) happiness += 10.0;
    if (insectCount == 0) comfort += 10.0;

    // Cleanliness affects both
    happiness += cleanliness / 10;
    comfort += cleanliness / 10;

    // Interactive elements boost happiness
    if (hasInteractiveElements) {
      happiness += interactiveElements.length * 3.0;
    }

    // Cap at 100
    happiness = happiness.clamp(0.0, 100.0);
    comfort = comfort.clamp(0.0, 100.0);
  }

  static HabitatTheme getDefaultTheme(PetType type) {
    return switch (type) {
      PetType.lion => HabitatTheme.savannah,
      PetType.giraffe => HabitatTheme.savannah,
      PetType.penguin => HabitatTheme.arctic,
      PetType.panda => HabitatTheme.bambooGrove,
      PetType.dog => HabitatTheme.house,
      PetType.cat => HabitatTheme.house,
      PetType.bird => HabitatTheme.forest,
      PetType.rabbit => HabitatTheme.garden,
    };
  }

  static Color _getDefaultFloorColor(HabitatTheme theme) {
    return switch (theme) {
      HabitatTheme.savannah => Colors.amber.shade200, // Sandy color
      HabitatTheme.arctic => Colors.white, // Snow
      HabitatTheme.bambooGrove => Colors.green.shade900, // Dark forest floor
      HabitatTheme.forest => Colors.brown.shade300, // Dirt
      HabitatTheme.jungle => Colors.green.shade800, // Dark green jungle floor
      HabitatTheme.mountain => Colors.grey.shade700, // Rocky
      HabitatTheme.desert => Colors.orange.shade300, // Sand
      HabitatTheme.ocean => Colors.blue.shade900, // Deep blue
      HabitatTheme.house => Colors.brown.shade100, // Light wooden floor
      HabitatTheme.garden => Colors.green.shade400, // Grass
      HabitatTheme.park => Colors.green.shade300, // Light grass
    };
  }

  static Color _getDefaultWallColor(HabitatTheme theme) {
    return switch (theme) {
      HabitatTheme.savannah => Colors.blue.shade200, // Sky blue
      HabitatTheme.arctic => Colors.blue.shade100, // Light blue sky
      HabitatTheme.bambooGrove => Colors.green.shade100, // Light green
      HabitatTheme.forest => Colors.green.shade400, // Forest green
      HabitatTheme.jungle => Colors.green.shade600, // Dark green
      HabitatTheme.mountain => Colors.grey.shade300, // Mountain gray
      HabitatTheme.desert => Colors.orange.shade100, // Light sand color
      HabitatTheme.ocean => Colors.blue.shade300, // Ocean blue
      HabitatTheme.house => Colors.grey.shade100, // Light wall color
      HabitatTheme.garden => Colors.blue.shade100, // Sky blue
      HabitatTheme.park => Colors.blue.shade200, // Sky blue
    };
  }

  static String _getDefaultBackground(PetType type, HabitatTheme theme) {
    // Default background based on pet type
    return switch (type) {
      PetType.lion => 'assets/images/habitats/savannah_background.png',
      PetType.giraffe => 'assets/images/habitats/savannah_background.png',
      PetType.penguin => 'assets/images/habitats/arctic_background.png',
      PetType.panda => 'assets/images/habitats/bamboo_background.png',
      PetType.dog => 'assets/images/habitats/house_background.png',
      PetType.cat => 'assets/images/habitats/house_background.png',
      PetType.bird => 'assets/images/habitats/forest_background.png',
      PetType.rabbit => 'assets/images/habitats/garden_background.png',
    };
  }

  // Public methods to access theme-related settings
  static Color getFloorColorForTheme(HabitatTheme theme) {
    return _getDefaultFloorColor(theme);
  }

  static Color getWallColorForTheme(HabitatTheme theme) {
    return _getDefaultWallColor(theme);
  }

  static String getBackgroundForPetAndTheme(PetType type, HabitatTheme theme) {
    return _getDefaultBackground(type, theme);
  }

  static WeatherType getDefaultWeather(PetType petType) {
    switch (petType) {
      case PetType.lion:
      case PetType.giraffe:
        return WeatherType.sunny;
      case PetType.penguin:
        return WeatherType.snowy;
      case PetType.panda:
        return WeatherType.rainy;
      default:
        return WeatherType.sunny;
    }
  }
}
