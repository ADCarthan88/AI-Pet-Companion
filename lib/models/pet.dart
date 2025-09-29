import 'package:flutter/material.dart';
import 'toy.dart';
import 'pet_trick.dart';
import 'pet_habitat.dart';
import 'weather_system.dart';
import 'mini_game.dart';
import 'pet_social.dart';
import 'store_item.dart';

enum PetType { dog, cat, bird, rabbit, lion, giraffe, penguin, panda }

enum PetMood { happy, neutral, sad, excited, tired, loving }

enum PetActivity {
  playing,
  playingWithToy,
  sleeping,
  eating,
  idle,
  licking,
  beingCleaned,
  beingBrushed,
}

enum PetGender { male, female }

class Pet {
  String name;
  final PetType type;
  int happiness;
  int energy;
  int hunger;
  int cleanliness;
  PetMood mood;
  PetActivity currentActivity;
  PetGender gender;
  Color color;
  DateTime lastFed;
  DateTime lastCleaned;
  DateTime lastBrushed;
  bool isLicking;
  Toy? currentToy;
  double coins;
  List<StoreItem> inventory;
  List<StoreItem> ownedItems; // Purchased items from the store
  StoreItem? activeItem; // Currently active/displayed item
  List<PetTrick> tricks;
  PetHabitat? habitat;
  WeatherType preferredWeather;
  List<MiniGame> unlockedGames;
  PetSocialProfile? socialProfile;

  Pet({
    required this.name,
    required this.type,
    required this.gender,
    this.happiness = 50,
    this.energy = 100,
    this.hunger = 0,
    this.cleanliness = 100,
    this.mood = PetMood.neutral,
    this.currentActivity = PetActivity.idle,
    this.color = Colors.brown,
    this.isLicking = false,
    String? socialId,
    String? ownerName,
  }) : lastFed = DateTime.now(),
       lastCleaned = DateTime.now(),
       lastBrushed = DateTime.now(),
       tricks = [],
       unlockedGames = [],
       preferredWeather = _getDefaultWeather(type),
       coins = 0,
       inventory = [],
       ownedItems = [],
       activeItem = null {
    // Initialize habitat
    habitat = PetHabitat(
      petType: type,
      theme: PetHabitat.getDefaultTheme(type),
    );

    // Initialize social profile if provided
    if (socialId != null && ownerName != null) {
      socialProfile = PetSocialProfile(
        id: socialId,
        ownerName: ownerName,
        pet: this,
      );
    }

    // Add a basic free bed based on pet type
    StoreItem basicBed = _createBasicBed(type);
    ownedItems.add(basicBed);
    setActiveItem(basicBed); // Make the bed active by default

    // Initialize available tricks
    tricks.addAll(PetTrick.getTricksForPetType(type));
  }

  // Create a basic bed for the given pet type
  StoreItem _createBasicBed(PetType type) {
    String id;
    String name;
    String description;
    List<Color> colors;

    switch (type) {
      case PetType.dog:
        id = 'basic_dog_bed';
        name = 'Basic Dog Bed';
        description = 'Simple cushion for your dog to rest on';
        colors = [Colors.brown[300]!, Colors.grey[400]!, Colors.blue[200]!];
        break;
      case PetType.cat:
        id = 'basic_cat_bed';
        name = 'Basic Cat Cushion';
        description = 'Small cushion for your cat';
        colors = [Colors.grey[300]!, Colors.orange[200]!, Colors.green[200]!];
        break;
      case PetType.bird:
        id = 'basic_bird_perch';
        name = 'Simple Perch';
        description = 'Basic wooden perch for your bird';
        colors = [Colors.brown[400]!];
        break;
      case PetType.rabbit:
        id = 'basic_rabbit_mat';
        name = 'Hay Mat';
        description = 'Simple mat for your rabbit to rest on';
        colors = [Colors.yellow[100]!];
        break;
      case PetType.lion:
        id = 'basic_lion_pad';
        name = 'Savannah Rest Pad';
        description = 'Basic pad for your lion to rest on';
        colors = [Colors.amber[200]!];
        break;
      case PetType.giraffe:
        id = 'basic_giraffe_mat';
        name = 'Giraffe Sleep Mat';
        description = 'Soft ground covering for your giraffe';
        colors = [Colors.amber[300]!];
        break;
      case PetType.penguin:
        id = 'basic_penguin_nest';
        name = 'Simple Ice Nest';
        description = 'Basic nest for your penguin';
        colors = [Colors.blue[100]!, Colors.white];
        break;
      case PetType.panda:
        id = 'basic_panda_mat';
        name = 'Bamboo Mat';
        description = 'Simple bamboo mat for your panda';
        colors = [Colors.green[200]!];
        break;
    }

    // Create the basic bed item (already owned, costs 0 since it's free)
    return StoreItem(
      id: id,
      name: name,
      description: description,
      price: 0, // Free with pet
      category: ItemCategory.beds,
      suitableFor: [type],
      availableColors: colors,
      icon: Icons.bed,
      happinessBoost: 5, // Low happiness boost
      energyBoost: 15, // Moderate energy boost
      isOwned: true, // Already owned
      selectedColor: colors.first, // Default color
    );
  }

  static WeatherType _getDefaultWeather(PetType type) {
    switch (type) {
      case PetType.lion:
        return WeatherType.sunny;
      case PetType.penguin:
        return WeatherType.snowy;
      case PetType.panda:
        return WeatherType.rainy;
      case PetType.giraffe:
        return WeatherType.sunny;
      default:
        return WeatherType.sunny;
    }
  }

  void updateState() {
    final now = DateTime.now();
    final timeSinceLastFed = now.difference(lastFed);
    final timeSinceLastCleaned = now.difference(lastCleaned);

    // Increase hunger over time
    if (timeSinceLastFed.inHours >= 2) {
      hunger = (hunger + 10).clamp(0, 100);
      lastFed = now.subtract(const Duration(hours: 2));
    }

    // Decrease cleanliness over time
    if (timeSinceLastCleaned.inHours >= 4) {
      cleanliness = (cleanliness - 5).clamp(0, 100);
      lastCleaned = now.subtract(const Duration(hours: 4));
    }

    // Update pet based on habitat conditions
    updateWithHabitat();

    // Update mood based on stats and award coins
    if (happiness > 75 && energy > 50 && cleanliness > 70) {
      mood = PetMood.loving;
      if (!isLicking && currentActivity == PetActivity.idle) {
        startLicking();
      }
      // Bonus coins for excellent care
      earnCoins(2.0);
    } else if (happiness > 75 && energy > 50) {
      mood = PetMood.happy;
      // Small bonus for good care
      earnCoins(1.0);
    } else if (hunger > 75 || cleanliness < 30) {
      mood = PetMood.sad;
    } else if (energy < 25) {
      mood = PetMood.tired;
    } else {
      mood = PetMood.neutral;
      // Small reward for stable condition
      earnCoins(0.5);
    }

    // Extra coins for consistent care
    final timeSinceLastBrushed = now.difference(lastBrushed);
    if (timeSinceLastFed.inHours < 4 &&
        timeSinceLastCleaned.inHours < 8 &&
        timeSinceLastBrushed.inHours < 12) {
      earnCoins(1.0);
    }
  }

  void feed({bool isSnack = false}) {
    if (isSnack) {
      hunger = (hunger - 15).clamp(0, 100);
      happiness = (happiness + 15).clamp(0, 100);
    } else {
      hunger = (hunger - 30).clamp(0, 100);
      happiness = (happiness + 10).clamp(0, 100);
    }
    lastFed = DateTime.now();
    currentActivity = PetActivity.eating;

    // Update habitat food status when feeding the pet
    if (habitat != null) {
      // Replenish food in habitat
      habitat!.addFood();

      // Decrease cleanliness slightly from eating
      habitat!.updateCleanliness(-5);
    }

    updateState();
  }

  void clean() {
    cleanliness = 100;
    happiness = (happiness + 10).clamp(0, 100);
    lastCleaned = DateTime.now();
    currentActivity = PetActivity.beingCleaned;

    // Also clean the habitat when cleaning the pet
    if (habitat != null) {
      habitat!.clean();
    }

    updateState();
  }

  void brush() {
    cleanliness = (cleanliness + 20).clamp(0, 100);
    happiness = (happiness + 15).clamp(0, 100);
    lastBrushed = DateTime.now();
    currentActivity = PetActivity.beingBrushed;
    updateState();
  }

  bool canAfford(double price) {
    return coins >= price;
  }

  void earnCoins(double amount) {
    coins += amount;
  }

  bool purchaseItem(StoreItem item) {
    if (!canAfford(item.price)) return false;
    if (inventory.any((i) => i.id == item.id)) return false;

    coins -= item.price;
    inventory.add(item);

    // Also add to owned items for display in the environment
    final ownedItem = StoreItem(
      id: item.id,
      name: item.name,
      description: item.description,
      price: item.price,
      category: item.category,
      suitableFor: item.suitableFor,
      availableColors: item.availableColors,
      icon: item.icon,
      happinessBoost: item.happinessBoost,
      energyBoost: item.energyBoost,
      healthBoost: item.healthBoost,
      cleanlinessBoost: item.cleanlinessBoost,
      isOwned: true,
      selectedColor:
          item.selectedColor ??
          (item.availableColors.isNotEmpty ? item.availableColors.first : null),
    );

    ownedItems.add(ownedItem);
    return true;
  }

  void useItem(StoreItem item) {
    if (!inventory.contains(item) && !ownedItems.any((i) => i.id == item.id))
      return;

    happiness = (happiness + item.happinessBoost).clamp(0, 100).toInt();
    energy = (energy + item.energyBoost).clamp(0, 100).toInt();
    cleanliness = (cleanliness + item.cleanlinessBoost).clamp(0, 100).toInt();

    // Set the item as active to display in the environment
    setActiveItem(item);

    // Some items might be consumable and should be removed after use
    if (item.category == ItemCategory.food ||
        item.category == ItemCategory.treats) {
      inventory.remove(item);
    }

    updateState();
  }

  void startLicking() {
    isLicking = true;
    currentActivity = PetActivity.licking;
    Future.delayed(const Duration(seconds: 3), () {
      isLicking = false;
      currentActivity = PetActivity.idle;
    });
  }

  void play() {
    if (energy > 20) {
      // Base happiness gain
      int happinessBoost = 20;
      int energyCost = 15;

      // Habitat affects play effectiveness
      if (habitat != null) {
        // Optimal habitat makes playtime more fun and less tiring
        if (hasOptimalHabitat()) {
          happinessBoost += 10;
          energyCost -= 5;
        }

        // Interactive elements make play more engaging
        if (habitat!.hasInteractiveElements) {
          happinessBoost += habitat!.interactiveElements.length * 2;
        }

        // Cleanliness affects enjoyment
        if (habitat!.cleanliness < 50) {
          happinessBoost -= 5;
        }

        // Playing makes habitat slightly dirty
        habitat!.updateCleanliness(-2);
      }

      happiness = (happiness + happinessBoost).clamp(0, 100);
      energy = (energy - energyCost).clamp(0, 100);
      currentActivity = PetActivity.playing;
      updateState();
    }
  }

  void rest() {
    // Base energy restoration
    int energyBoost = 30;

    // Habitat comfort increases rest effectiveness
    if (habitat != null) {
      // Recalculate habitat comfort
      habitat!.calculateHappinessAndComfort();

      // Add comfort bonus (up to +20 energy)
      energyBoost += (habitat!.comfort / 5).round();

      // Optimal habitat gives additional bonus
      if (hasOptimalHabitat()) {
        energyBoost += 10;
      }
    }

    energy = (energy + energyBoost).clamp(0, 100);
    currentActivity = PetActivity.sleeping;
    updateState();
  }

  // AI behavior method to determine next action
  void decideNextAction() {
    if (energy < 20) {
      rest();
    } else if (hunger > 70) {
      currentActivity = PetActivity.eating;
    } else if (cleanliness < 40) {
      currentActivity = PetActivity.beingCleaned;
    } else if (happiness < 30 && energy > 50) {
      play();
    } else {
      currentActivity = PetActivity.idle;
    }

    // Potentially update habitat condition
    updateHabitatOverTime();

    updateState();
  }

  // Method to simulate habitat changes over time
  void updateHabitatOverTime() {
    if (habitat == null) return;

    final now = DateTime.now();
    final timeSinceLastCleaned = now.difference(habitat!.lastCleaned);

    // Gradually decrease habitat cleanliness
    if (timeSinceLastCleaned.inHours >= 2) {
      habitat!.updateCleanliness(-5);

      // Chance to consume resources
      if (timeSinceLastCleaned.inHours >= 4) {
        if (habitat!.hasWater && DateTime.now().millisecond % 3 == 0) {
          habitat!.hasWater = false;
        }
        if (habitat!.hasFood && DateTime.now().millisecond % 5 == 0) {
          habitat!.hasFood = false;
        }
      }

      // Update habitat timestamp
      habitat!.lastCleaned = now.subtract(const Duration(hours: 1));
    }
  }

  void practiceTrick(PetTrick trick) {
    if (!tricks.contains(trick)) return;
    if (energy < 10) return;

    energy = (energy - 10).clamp(0, 100);
    trick.currentExperience += 10;

    if (trick.isMastered && !trick.isUnlocked) {
      trick.isUnlocked = true;
      happiness = (happiness + 20).clamp(0, 100);
    } else {
      happiness = (happiness + 5).clamp(0, 100);
    }

    updateState();
  }

  void playWithToy(Toy toy) {
    if (!toy.suitableFor.contains(type)) {
      // Pet doesn't like this type of toy
      happiness = (happiness - 5).clamp(0, 100);
      return;
    }

    toy.isInUse = true;
    currentToy = toy;
    energy = (energy - 15).clamp(0, 100);
    happiness = (happiness + 30).clamp(
      0,
      100,
    ); // Playing with appropriate toy gives more happiness
    currentActivity = PetActivity.playingWithToy;

    // Add type-specific behaviors
    switch (type) {
      case PetType.dog:
        if (toy.type == ToyType.ball) {
          // Dogs get extra energy boost from playing with balls
          energy = (energy + 5).clamp(0, 100);
        }
        break;
      case PetType.cat:
        if (toy.type == ToyType.laserPointer) {
          // Cats get extra happiness from chasing laser pointers
          happiness = (happiness + 5).clamp(0, 100);
        }
        break;
      case PetType.bird:
        if (toy.type == ToyType.bell) {
          // Birds get extra happiness from musical toys
          happiness = (happiness + 5).clamp(0, 100);
        }
        break;
      case PetType.rabbit:
        if (toy.type == ToyType.carrot) {
          // Rabbits get both happiness and energy from carrot toys
          happiness = (happiness + 5).clamp(0, 100);
          energy = (energy + 5).clamp(0, 100);
        }
        break;
      case PetType.lion:
        if (toy.type == ToyType.rope) {
          // Lions gain extra energy and happiness from rope toys
          energy = (energy + 10).clamp(0, 100);
          happiness = (happiness + 10).clamp(0, 100);
        }
        break;
      case PetType.giraffe:
        if (toy.type == ToyType.leaves) {
          // Giraffes are very content with leaves
          happiness = (happiness + 15).clamp(0, 100);
          hunger = (hunger - 5).clamp(0, 100);
        }
        break;
      case PetType.penguin:
        if (toy.type == ToyType.slide) {
          // Penguins love sliding and gain lots of happiness
          happiness = (happiness + 20).clamp(0, 100);
          energy = (energy - 5).clamp(0, 100);
        }
        break;
      case PetType.panda:
        if (toy.type == ToyType.bamboo) {
          // Pandas get both food and joy from bamboo
          happiness = (happiness + 10).clamp(0, 100);
          hunger = (hunger - 10).clamp(0, 100);
        }
        break;
    }

    updateState();
  }

  void stopPlayingWithToy() {
    if (currentToy != null) {
      currentToy!.isInUse = false;
      currentToy = null;
    }
    currentActivity = PetActivity.idle;
    updateState();
  }

  // Set the active item to display in the environment
  void setActiveItem(StoreItem item) {
    // Find the item in the owned items list
    final ownedItem = ownedItems.firstWhere(
      (ownedItem) => ownedItem.id == item.id,
      orElse: () => item,
    );

    activeItem = ownedItem;

    // Apply immediate effects for non-inventory items
    // For inventory items, effects are already applied in useItem
    if (!inventory.contains(item)) {
      if (item.category == ItemCategory.beds) {
        // Beds increase energy recovery
        energy = (energy + 10).clamp(0, 100);

        // Ensure the bed is in the habitat
        if (habitat != null) {
          // Import the converter using relative path
          bool bedExists = false;

          // Check if a bed with this name exists in habitat
          for (var habitatItem in habitat!.items) {
            if (habitatItem.name == item.name) {
              bedExists = true;
              break;
            }
          }

          if (!bedExists) {
            // Convert store item to habitat item
            final HabitatItem habitatItem = HabitatItem(
              name: item.name,
              description: item.description,
              icon: item.icon,
              theme: HabitatTheme.house, // Default theme
              cost: item.price,
              suitableFor: [type], // Suitable for this pet type
              isOwned: true,
            );

            // Add to habitat
            habitat!.addItem(habitatItem);
          }
        }
      } else if (item.category == ItemCategory.furniture) {
        // Furniture increases happiness
        happiness = (happiness + 5).clamp(0, 100);
      }
    }

    updateState();
  }

  // Remove the active item
  void clearActiveItem() {
    activeItem = null;
    updateState();
  }

  // Method to periodically update both pet and habitat states
  void periodicUpdate() {
    // First update habitat conditions
    updateHabitatOverTime();

    // Then update pet based on habitat
    updateState();

    // If habitat conditions are optimal, give periodic happiness boost
    if (hasOptimalHabitat()) {
      happiness = (happiness + 2).clamp(0, 100);
    }

    // Occasionally have pet interact with habitat elements
    final random = DateTime.now().millisecond;
    if (random % 10 == 0 &&
        habitat != null &&
        habitat!.hasInteractiveElements) {
      currentActivity = PetActivity.playing;
      happiness = (happiness + 3).clamp(0, 100);
    }
  }

  // Update pet based on habitat conditions
  void updateWithHabitat() {
    if (habitat == null) return;

    // Recalculate habitat conditions
    habitat!.calculateHappinessAndComfort();

    // Habitat cleanliness affects pet cleanliness
    if (habitat!.cleanliness < 50) {
      cleanliness = (cleanliness - 5).clamp(0, 100);
    }

    // Habitat comfort affects pet happiness
    happiness = ((happiness * 0.7) + (habitat!.comfort * 0.3)).toInt().clamp(
      0,
      100,
    );

    // Environmental factors
    if (habitat!.hasWaste) {
      happiness = (happiness - 5).clamp(0, 100);
    }

    if (habitat!.insectCount > 3) {
      happiness = (happiness - 5).clamp(0, 100);
    }

    // Theme matching with pet type gives happiness boost
    if (habitat!.theme == PetHabitat.getDefaultTheme(type)) {
      happiness = (happiness + 5).clamp(0, 100);
    }

    // Interactive elements increase energy
    if (habitat!.hasInteractiveElements) {
      energy = (energy + habitat!.interactiveElements.length * 2).clamp(0, 100);
    }

    // Water and food availability affects hunger
    if (!habitat!.hasWater) {
      hunger = (hunger + 10).clamp(0, 100);
    }

    if (!habitat!.hasFood) {
      hunger = (hunger + 15).clamp(0, 100);
    }
  }

  // Methods for maintaining the habitat

  void cleanHabitat() {
    if (habitat == null) return;

    habitat!.clean();
    happiness = (happiness + 15).clamp(0, 100);
    energy = (energy - 10).clamp(0, 100);
    updateState();
  }

  void addWaterToHabitat() {
    if (habitat == null) return;

    habitat!.addWater();
    happiness = (happiness + 5).clamp(0, 100);
    updateState();
  }

  void addFoodToHabitat() {
    if (habitat == null) return;

    habitat!.addFood();
    happiness = (happiness + 5).clamp(0, 100);
    updateState();
  }

  void changeHabitatTheme(HabitatTheme newTheme) {
    if (habitat == null) return;

    // Check if theme is suitable for this pet type
    final defaultTheme = PetHabitat.getDefaultTheme(type);

    habitat!.theme = newTheme;

    // Happiness boost if theme matches the pet's natural habitat
    if (newTheme == defaultTheme) {
      happiness = (happiness + 20).clamp(0, 100);
    } else {
      // Small happiness decrease for non-matching habitats
      happiness = (happiness - 5).clamp(0, 100);
    }

    // Update colors and background based on new theme
    habitat!.floorColor = PetHabitat.getFloorColorForTheme(newTheme);
    habitat!.wallColor = PetHabitat.getWallColorForTheme(newTheme);
    habitat!.background = PetHabitat.getBackgroundForPetAndTheme(
      type,
      newTheme,
    );

    updateState();
  }

  void addHabitatItem(HabitatItem item) {
    if (habitat == null) return;

    habitat!.addItem(item);
    happiness = (happiness + 10).clamp(0, 100);
    updateState();
  }

  void removeHabitatItem(HabitatItem item) {
    if (habitat == null) return;

    habitat!.removeItem(item);
    happiness = (happiness - 5).clamp(0, 100);
    updateState();
  }

  // Add an interactive element to habitat
  void addInteractiveElement(String element) {
    if (habitat == null) return;

    habitat!.addInteractiveElement(element);
    happiness = (happiness + 10).clamp(0, 100);
    energy = (energy + 5).clamp(0, 100);
    updateState();
  }

  // Check if the habitat is optimal for this pet type
  bool hasOptimalHabitat() {
    if (habitat == null) return false;

    // Check if theme matches natural environment
    final isNaturalTheme = habitat!.theme == PetHabitat.getDefaultTheme(type);

    // Check for suitable items
    final hasSuitableItems = habitat!.items.any(
      (item) => item.suitableFor.contains(type) && item.theme == habitat!.theme,
    );

    // Check environmental conditions
    final hasGoodConditions =
        habitat!.cleanliness > 70 &&
        habitat!.hasWater &&
        habitat!.hasFood &&
        !habitat!.hasWaste &&
        habitat!.insectCount < 2;

    // Check if it has interactive elements
    final hasInteractivity = habitat!.hasInteractiveElements;

    // Calculate overall suitability
    return isNaturalTheme &&
        hasSuitableItems &&
        hasGoodConditions &&
        hasInteractivity;
  }
}
