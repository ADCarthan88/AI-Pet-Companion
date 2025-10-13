import 'package:flutter/material.dart';
import 'dart:async';
import 'toy.dart';
import '../config/app_config.dart';
import 'pet_trick.dart';
import 'pet_habitat.dart';
import 'weather_system.dart';
import 'mini_game.dart';
import 'pet_social.dart';
import 'store_item.dart';
import 'emotional_memory.dart';
import '../services/ai_response_engine.dart';
import '../services/realistic_behavior_engine.dart';
import '../services/interactive_response_service.dart';
import '../services/context_aware_interaction.dart';
import '../services/natural_movement_engine.dart';

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
  walking,
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
  
  // Temporary mood system to preserve immediate reactions
  PetMood? _temporaryMood;
  DateTime? _temporaryMoodSet;
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
  EmotionalMemory emotionalMemory;
  
  // AI Enhancement Systems
  AIResponseEngine? _aiResponseEngine;
  RealisticBehaviorEngine? _behaviorEngine;
  InteractiveResponseService? _interactiveService;
  ContextAwareInteraction? _contextAwareSystem;
  NaturalMovementEngine? _movementEngine;

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
       coins = AppConfig.testMode
           ? AppConfig.testModeCoins
           : AppConfig.defaultStartingCoins,
       inventory = [],
       ownedItems = [],
       activeItem = null,
       emotionalMemory = EmotionalMemory() {
    // Initialize habitat with colors instead of background images
    habitat = PetHabitat(
      petType: type,
      theme: PetHabitat.getDefaultTheme(type),
      floorColor: Colors.brown.shade200,
      wallColor: Colors.blue.shade100,
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
    
    // Initialize AI enhancement systems
    _initializeAISystems();
  }

  // Track timers for cleanup (especially in tests)
  final Set<Timer> _timers = {};
  void _registerTimer(Timer t) => _timers.add(t);
  void cancelTimers() {
    for (final t in _timers) {
      t.cancel();
    }
    _timers.clear();
    
    // Dispose AI systems
    _aiResponseEngine?.dispose();
    _behaviorEngine?.dispose();
    _interactiveService?.dispose();
    _contextAwareSystem?.dispose();
    _movementEngine?.dispose();
  }
  
  /// Initialize AI enhancement systems
  void _initializeAISystems() {
    _aiResponseEngine = AIResponseEngine(pet: this);
    _behaviorEngine = RealisticBehaviorEngine(pet: this);
    _interactiveService = InteractiveResponseService(pet: this);
    _contextAwareSystem = ContextAwareInteraction(pet: this);
    _movementEngine = NaturalMovementEngine(pet: this);
    
    print('🤖 AI Systems initialized for ${name}');
  }

  // Set a temporary mood that persists for a short time
  void _setTemporaryMood(PetMood newMood) {
    _temporaryMood = newMood;
    _temporaryMoodSet = DateTime.now();
    mood = newMood;
    print('✨ INTERACTION: Pet feels $newMood!');
  }
  
  // Check if temporary mood should be cleared
  bool _shouldClearTemporaryMood() {
    if (_temporaryMood == null || _temporaryMoodSet == null) return false;
    return DateTime.now().difference(_temporaryMoodSet!).inSeconds > 10; // Clear after 10 seconds
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

    // Store previous mood for comparison
    final previousMood = mood;

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

    // Apply emotional memory modifiers to stats
    final emotionalModifiers = emotionalMemory.getEmotionalStatModifiers();
    happiness = (happiness + (emotionalModifiers['happiness'] ?? 0.0)).clamp(0, 100).round();
    
    // Apply stress and loneliness if we had those stats (for future expansion)
    // For now, high stress reduces happiness, low loneliness increases happiness
    final stressReduction = (emotionalModifiers['stress'] ?? 0.0) * -0.5; // Convert stress to happiness reduction
    final lonelinessReduction = (emotionalModifiers['loneliness'] ?? 0.0) * -1.0; // Convert loneliness reduction to happiness increase
    happiness = (happiness + stressReduction + lonelinessReduction).clamp(0, 100).round();

    // Clear temporary mood if expired
    if (_shouldClearTemporaryMood()) {
      _temporaryMood = null;
      _temporaryMoodSet = null;
    }
    
    // Update mood based on stats (but don't override temporary mood)
    if (_temporaryMood == null) {
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
    } else {
      // Still award coins based on stats
      if (happiness > 75 && energy > 50 && cleanliness > 70) {
        earnCoins(2.0);
      } else if (happiness > 75 && energy > 50) {
        earnCoins(1.0);
      } else {
        earnCoins(0.5);
      }
    }

    // Log significant mood changes
    if (previousMood != mood) {
      print('🐾 PET MOOD: $previousMood → $mood');
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

    // Immediate mood reaction to feeding
    _setTemporaryMood(PetMood.happy);

    // Record emotional memory with enhanced context
    final context = hunger > 80 ? EmotionalContext.grateful : // Starving = grateful
                   hunger > 70 ? EmotionalContext.bonding : // Very hungry = special care
                   hunger > 40 ? EmotionalContext.positive : // Moderately hungry = good timing
                   hunger > 20 ? EmotionalContext.neutral : // Not very hungry = routine
                   EmotionalContext.melancholy; // Force feeding = sad
    final intensity = hunger > 70 ? (isSnack ? 0.5 : 0.8) : // More memorable when hungry
                     isSnack ? 0.3 : 0.6; // Regular intensity otherwise
    final notes = isSnack ? 'Given healthy snack' : 'Fed full meal';
    emotionalMemory.recordInteraction(InteractionType.feeding, context, 
        intensity: intensity, notes: notes);

    // Update habitat food status when feeding the pet
    if (habitat != null) {
      // Replenish food in habitat
      habitat!.addFood();

      // Decrease cleanliness slightly from eating
      habitat!.updateCleanliness(-5);
    }
    
    // Trigger AI response to feeding with context awareness
    _aiResponseEngine?.recordUserInteraction(InteractionType.feeding);
    final contextualInfo = _contextAwareSystem?.processContextualInteraction(
        InteractionType.feeding, {'hunger_level': hunger, 'is_snack': isSnack});
    _interactiveService?.processInteraction(InteractionType.feeding, context: contextualInfo);

    updateState();
  }

  // Explicit habitat-only refills without directly feeding pet stats
  void refillFoodBowl() {
    if (habitat == null) return;
    habitat!.addFood();
    // Small happiness bump for provisioning
    happiness = (happiness + 3).clamp(0, 100);
    updateState();
  }

  void refillWaterBowl() {
    if (habitat == null) return;
    habitat!.addWater();
    happiness = (happiness + 2).clamp(0, 100);
    updateState();
  }

  void clean() {
    final previousCleanliness = cleanliness;
    cleanliness = 100;
    happiness = (happiness + 10).clamp(0, 100);
    lastCleaned = DateTime.now();
    currentActivity = PetActivity.beingCleaned;

    // Immediate mood reaction to cleaning
    _setTemporaryMood(PetMood.loving);

    // Record emotional memory - cleaning context depends on how dirty the pet was
    final context = previousCleanliness < 30 ? EmotionalContext.bonding : // Very dirty = caring gesture
                   previousCleanliness < 60 ? EmotionalContext.positive : // Moderately dirty = good care
                   EmotionalContext.neutral; // Clean = routine maintenance
    final intensity = previousCleanliness < 30 ? 0.8 : 0.5; // More memorable when really needed
    emotionalMemory.recordInteraction(InteractionType.cleaning, context, intensity: intensity);

    // Also clean the habitat when cleaning the pet
    if (habitat != null) {
      habitat!.clean();
    }
    
    // Trigger AI response to cleaning with context awareness
    _aiResponseEngine?.recordUserInteraction(InteractionType.cleaning);
    final contextualInfo = _contextAwareSystem?.processContextualInteraction(
        InteractionType.cleaning, {'previous_cleanliness': previousCleanliness});
    _interactiveService?.processInteraction(InteractionType.cleaning, context: contextualInfo);

    updateState();
  }

  void brush() {
    cleanliness = (cleanliness + 20).clamp(0, 100);
    happiness = (happiness + 15).clamp(0, 100);
    lastBrushed = DateTime.now();
    currentActivity = PetActivity.beingBrushed;
    
    // Immediate mood reaction to brushing
    _setTemporaryMood(PetMood.loving);
    
    // Record emotional memory - brushing with sensitivity awareness
    final daysSinceBrush = DateTime.now().difference(lastBrushed).inDays;
    final context = daysSinceBrush > 5 ? EmotionalContext.grateful : // Very overdue = grateful
                   daysSinceBrush > 3 ? EmotionalContext.bonding : // Long overdue = special care
                   emotionalMemory.sensitivity > 70 ? EmotionalContext.bonding : // Sensitive pets love gentle care
                   EmotionalContext.positive; // Regular brushing = good care
    final intensity = emotionalMemory.sensitivity > 70 ? 0.8 : // Sensitive pets find it more meaningful
                     daysSinceBrush > 3 ? 0.9 : 0.6; // More memorable when needed
    final notes = emotionalMemory.sensitivity > 70 ? 'Gentle, caring brushing session' : 
                 daysSinceBrush > 3 ? 'Much-needed grooming care' : 'Regular brushing';
    emotionalMemory.recordInteraction(InteractionType.brushing, context, 
        intensity: intensity, notes: notes);
    
    updateState();
  }

  // New emotional interaction methods
  void gentleTouch({String location = 'head'}) {
    cleanliness = (cleanliness + 5).clamp(0, 100);
    happiness = (happiness + 8).clamp(0, 100);
    
    // Immediate mood reaction to gentle touching
    _setTemporaryMood(PetMood.loving);
    
    // Record emotional memory - gentle touch is usually bonding
    final context = emotionalMemory.sensitivity > 70 ? EmotionalContext.grateful :
                   emotionalMemory.attachment > 60 ? EmotionalContext.bonding :
                   EmotionalContext.positive;
    final intensity = emotionalMemory.sensitivity > 70 ? 0.9 : 0.7;
    emotionalMemory.recordInteraction(InteractionType.gentleTouch, context, 
        intensity: intensity, notes: 'Gentle touch on $location');
    
    // Trigger AI response to gentle touch with context awareness
    _aiResponseEngine?.recordUserInteraction(InteractionType.gentleTouch);
    final contextualInfo = _contextAwareSystem?.processContextualInteraction(
        InteractionType.gentleTouch, {'location': location, 'sensitivity': emotionalMemory.sensitivity});
    _interactiveService?.processInteraction(InteractionType.gentleTouch, context: contextualInfo);
    
    print('💖 GENTLE TOUCH: $name feels cherished after gentle $location touching');
    updateState();
  }
  
  void talkToPet(String message) {
    happiness = (happiness + 5).clamp(0, 100);
    
    // Immediate mood reaction
    _setTemporaryMood(PetMood.happy);
    
    // Record emotional memory - talking builds social connection
    final context = emotionalMemory.socialability > 70 ? EmotionalContext.joyful :
                   emotionalMemory.bondStrength > 60 ? EmotionalContext.bonding :
                   EmotionalContext.positive;
    final intensity = emotionalMemory.personalityExtroversion > 60 ? 0.8 : 0.5;
    emotionalMemory.recordInteraction(InteractionType.talking, context, 
        intensity: intensity, notes: 'Talked to pet: "$message"');
    
    print('🗣️ TALKING: $name enjoys hearing your voice');
    updateState();
  }
  
  void giveSurpriseGift(String giftType) {
    happiness = (happiness + 15).clamp(0, 100);
    energy = (energy + 10).clamp(0, 100);
    
    // Immediate mood reaction
    _setTemporaryMood(PetMood.excited);
    
    // Record emotional memory - surprise gifts are special bonding moments
    final context = emotionalMemory.curiosity > 60 ? EmotionalContext.joyful :
                   EmotionalContext.bonding;
    final intensity = 0.9; // Always memorable
    emotionalMemory.recordInteraction(InteractionType.surpriseGift, context, 
        intensity: intensity, notes: 'Surprise gift: $giftType');
    
    print('🎁 SURPRISE GIFT: $name is delighted with the $giftType!');
    updateState();
  }
  
  void comfortPet() {
    // Only effective if pet is sad, stressed, or traumatized
    if (mood == PetMood.sad || emotionalMemory.traumaLevel > 30) {
      happiness = (happiness + 12).clamp(0, 100);
      
      // Immediate mood reaction
      _setTemporaryMood(PetMood.loving);
      
      // Record emotional memory - comforting during distress is deeply bonding
      final context = emotionalMemory.traumaLevel > 50 ? EmotionalContext.grateful :
                     EmotionalContext.bonding;
      final intensity = emotionalMemory.traumaLevel > 50 ? 1.0 : 0.8;
      emotionalMemory.recordInteraction(InteractionType.comforting, context, 
          intensity: intensity, notes: 'Comforted during difficult time');
      
      print('🤗 COMFORT: $name feels deeply cared for during this difficult moment');
    } else {
      happiness = (happiness + 3).clamp(0, 100);
      emotionalMemory.recordInteraction(InteractionType.comforting, EmotionalContext.positive, 
          intensity: 0.4, notes: 'Gentle comfort');
      print('🤗 COMFORT: $name appreciates the gentle comfort');
    }
    
    updateState();
  }
  
  void celebrateWithPet(String occasion) {
    happiness = (happiness + 20).clamp(0, 100);
    energy = (energy + 15).clamp(0, 100);
    
    // Immediate mood reaction
    _setTemporaryMood(PetMood.excited);
    
    // Record emotional memory - celebrations are joyful bonding experiences
    final context = EmotionalContext.joyful;
    final intensity = 0.9;
    emotionalMemory.recordInteraction(InteractionType.celebrating, context, 
        intensity: intensity, notes: 'Celebrated $occasion together');
    
    print('🎉 CELEBRATION: $name is overjoyed celebrating $occasion with you!');
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
    if (!AppConfig.testMode) {
      coins -= item.price;
    }
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
    if (!inventory.contains(item) && !ownedItems.any((i) => i.id == item.id)) {
      return;
    }

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
    final t = Timer(const Duration(seconds: 3), () {
      isLicking = false;
      currentActivity = PetActivity.idle;
    });
    _registerTimer(t);
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
      
      // Immediate mood reaction to playing
      mood = PetMood.excited;
      print('PET DEBUG: Pet played - immediate mood set to excited');
      
      // Record emotional memory - playing with personality awareness
      final context = energy < 30 ? EmotionalContext.stressful : // Too tired = not enjoyable
                     happinessBoost > 25 && emotionalMemory.playfulness > 70 ? EmotionalContext.joyful : // Playful pet + great conditions = joy
                     happinessBoost > 25 ? EmotionalContext.bonding : // Great habitat = special fun
                     emotionalMemory.playfulness > 60 ? EmotionalContext.playful : // Playful pet = playful context
                     EmotionalContext.positive; // Normal play = good time
      final intensity = emotionalMemory.playfulness > 70 ? 0.9 : // Highly playful pets love playing more
                       happinessBoost > 25 ? 0.8 : 0.6; // Better habitat = more memorable
      final notes = happinessBoost > 25 ? 'Played in excellent habitat conditions' : 'Regular play session';
      emotionalMemory.recordInteraction(InteractionType.playing, context, 
          intensity: intensity, notes: notes);
      
      // Trigger AI response to playing with context awareness
      _aiResponseEngine?.recordUserInteraction(InteractionType.playing);
      final contextualInfo = _contextAwareSystem?.processContextualInteraction(
          InteractionType.playing, {'happiness_boost': happinessBoost, 'energy_cost': energyCost});
      _interactiveService?.processInteraction(InteractionType.playing, context: contextualInfo);
      
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

  void playWithToy(Toy toy, {Offset? throwPosition}) {
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
    
    // Immediate mood reaction to playing
    _setTemporaryMood(PetMood.excited);

    // Establish a starting position so it can render even if not thrown.
    if (throwPosition != null) {
      toy.throwPosition = throwPosition;
    } else {
      // Default near pet (simple offset); real widget adjusts later.
      toy.throwPosition = const Offset(140, 140);
    }

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

    // Immediate mood reaction to playing with toys
    mood = PetMood.excited;
    print('PET DEBUG: Pet playing with toy - immediate mood set to excited');

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

          if (!bedExists) _addStoreItemToHabitat(item, asBed: true);
        }
      } else if (item.category == ItemCategory.furniture) {
        // Furniture increases happiness
        happiness = (happiness + 5).clamp(0, 100);
        if (habitat != null) {
          // Add furniture visually as habitat item if not present
          bool exists = habitat!.items.any((h) => h.name == item.name);
          if (!exists) _addStoreItemToHabitat(item);
        }
      }
    }

    // Ensure we always have at least one bed after activating items
    if (item.category == ItemCategory.beds) {
      ensureDefaultBedInHabitat();
    }

    updateState();
  }

  void _addStoreItemToHabitat(StoreItem item, {bool asBed = false}) {
    if (habitat == null) return;
    final HabitatItem habitatItem = HabitatItem(
      name: item.name,
      description: item.description,
      icon: item.icon,
      theme: habitat!.theme,
      cost: item.price,
      suitableFor: [type],
      isOwned: true,
    );
    habitat!.addItem(habitatItem);
  }

  void ensureDefaultBedInHabitat() {
    if (habitat == null) return;
    if (habitat!.items.any((i) => i.name.contains('Bed') || i.name.contains('Mat') || i.name.contains('Perch'))) return;
    // Re-add basic bed if lost
    final bed = _createBasicBed(type);
    if (!ownedItems.any((o) => o.id == bed.id)) {
      ownedItems.add(bed);
    }
    _addStoreItemToHabitat(bed, asBed: true);
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

    // Update habitat aging based on pet behavior and time
    habitat!.updateAging();

    // Recalculate habitat conditions (includes aging effects)
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

  // Emotional Memory access methods
  String getEmotionalState() => emotionalMemory.getEmotionalStateDescription();
  
  List<String> getBehavioralRecommendations() => emotionalMemory.getBehavioralRecommendations();
  
  InteractionType? getFavoriteActivity() => emotionalMemory.getFavoriteInteraction();
  
  InteractionType? getLeastFavoriteActivity() => emotionalMemory.getLeastFavoriteInteraction();
  
  double getTrustLevel() => emotionalMemory.trustLevel;
  
  double getBondStrength() => emotionalMemory.bondStrength;
  
  bool isReceptiveToActivity(InteractionType activity) => emotionalMemory.isReceptiveToInteraction(activity);

  // Habitat maintenance access methods
  String getHabitatCondition() => habitat?.getConditionDescription() ?? 'No habitat';
  
  bool habitatNeedsMaintenance() => habitat?.needsMaintenance() ?? false;
  
  bool habitatNeedsUrgentMaintenance() => habitat?.needsUrgentMaintenance() ?? false;
  
  double getHabitatMaintenanceCost() => habitat?.getMaintenanceCost() ?? 0.0;
  
  void performHabitatMaintenance() {
    if (habitat != null && canAfford(getHabitatMaintenanceCost())) {
      coins -= getHabitatMaintenanceCost();
      habitat!.performMaintenance();
      
      // Record positive emotional memory for habitat maintenance
      emotionalMemory.recordInteraction(
        InteractionType.cleaning, 
        EmotionalContext.bonding, 
        intensity: 0.7,
        notes: 'Habitat maintenance performed'
      );
      
      happiness = (happiness + 20).clamp(0, 100);
      updateState();
    }
  }
  
  /// Get contextual recommendations from AI system
  List<String> getContextualRecommendations() {
    return _contextAwareSystem?.getContextualRecommendations() ?? [];
  }
  
  /// Get current context summary
  Map<String, dynamic> getContextSummary() {
    return _contextAwareSystem?.getContextSummary() ?? {};
  }
  
  /// Get AI systems for external access (used by widgets)
  AIResponseEngine? get aiResponseEngine => _aiResponseEngine;
  RealisticBehaviorEngine? get behaviorEngine => _behaviorEngine;
  InteractiveResponseService? get interactiveService => _interactiveService;
  ContextAwareInteraction? get contextAwareSystem => _contextAwareSystem;
  NaturalMovementEngine? get movementEngine => _movementEngine;
}
