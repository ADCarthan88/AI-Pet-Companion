import 'package:flutter/material.dart';
import 'toy.dart';

enum PetType { 
  dog, 
  cat, 
  bird, 
  rabbit,
  lion,
  giraffe,
  penguin,
  panda
}

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
  }) : lastFed = DateTime.now(),
       lastCleaned = DateTime.now(),
       lastBrushed = DateTime.now();

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

    // Update mood based on stats
    if (happiness > 75 && energy > 50 && cleanliness > 70) {
      mood = PetMood.loving;
      if (!isLicking && currentActivity == PetActivity.idle) {
        startLicking();
      }
    } else if (happiness > 75 && energy > 50) {
      mood = PetMood.happy;
    } else if (hunger > 75 || cleanliness < 30) {
      mood = PetMood.sad;
    } else if (energy < 25) {
      mood = PetMood.tired;
    } else {
      mood = PetMood.neutral;
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
    updateState();
  }

  void clean() {
    cleanliness = 100;
    happiness = (happiness + 10).clamp(0, 100);
    lastCleaned = DateTime.now();
    currentActivity = PetActivity.beingCleaned;
    updateState();
  }

  void brush() {
    cleanliness = (cleanliness + 20).clamp(0, 100);
    happiness = (happiness + 15).clamp(0, 100);
    lastBrushed = DateTime.now();
    currentActivity = PetActivity.beingBrushed;
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
      happiness = (happiness + 20).clamp(0, 100);
      energy = (energy - 15).clamp(0, 100);
      currentActivity = PetActivity.playing;
      updateState();
    }
  }

  void rest() {
    energy = (energy + 30).clamp(0, 100);
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
    happiness = (happiness + 30).clamp(0, 100); // Playing with appropriate toy gives more happiness
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
}
