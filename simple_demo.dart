import 'dart:math';

// Simple demonstration without Flutter dependencies
class EmotionalMemory {
  Map<String, double> personalityTraits = {};
  Map<String, double> emotionalTraits = {};
  List<String> recentContexts = [];
  Set<String> fearTriggers = {};
  
  EmotionalMemory() {
    _initializePersonalityTraits();
    _initializeEmotionalTraits();
  }
  
  void _initializePersonalityTraits() {
    Random random = Random();
    personalityTraits = {
      'extroversion': random.nextDouble() * 10,
      'neuroticism': random.nextDouble() * 10,
      'openness': random.nextDouble() * 10,
      'agreeableness': random.nextDouble() * 10,
      'conscientiousness': random.nextDouble() * 10,
    };
  }
  
  void _initializeEmotionalTraits() {
    Random random = Random();
    emotionalTraits = {
      'confidence': 5.0 + random.nextDouble() * 3,
      'playfulness': 5.0 + random.nextDouble() * 3,
      'curiosity': 5.0 + random.nextDouble() * 3,
      'attachment': 5.0 + random.nextDouble() * 3,
      'independence': 5.0 + random.nextDouble() * 3,
      'socialability': 5.0 + random.nextDouble() * 3,
      'sensitivity': 5.0 + random.nextDouble() * 3,
      'resilience': 5.0 + random.nextDouble() * 3,
    };
  }
  
  void updateEmotionalContext(String context, double intensity) {
    recentContexts.add('$context (intensity: ${intensity.toStringAsFixed(1)})');
    if (recentContexts.length > 10) {
      recentContexts.removeAt(0);
    }
  }
  
  String getCurrentMoodDescription() {
    List<String> moods = [
      'feeling incredibly joyful and content',
      'bursting with playful energy',
      'radiating pure happiness',
      'feeling deeply grateful and loved',
      'showing bright curiosity about everything',
      'displaying confident independence',
      'seeking warm social connection',
      'feeling protective and alert',
      'in a gentle, contemplative mood',
      'expressing creative playfulness'
    ];
    
    Random random = Random();
    return moods[random.nextInt(moods.length)];
  }
  
  List<String> getFavoriteMemories() {
    return [
      'Playing with a feather toy for the first time',
      'Getting gentle pets behind the ears',
      'Discovering a sunny spot by the window',
      'Being talked to in a loving voice',
      'Receiving a special surprise treat'
    ];
  }
}

class Pet {
  String name;
  String species;
  int age;
  double happiness;
  double energy;
  double hunger;
  EmotionalMemory emotionalMemory;
  
  Pet({
    required this.name,
    required this.species,
    required this.age,
    required this.happiness,
    required this.energy,
    required this.hunger,
  }) : emotionalMemory = EmotionalMemory();
  
  void gentleTouch() {
    happiness = (happiness + 10).clamp(0, 100);
    emotionalMemory.updateEmotionalContext('gentle_touch_received', 8.5);
  }
  
  void talkToPet(String message) {
    happiness = (happiness + 5).clamp(0, 100);
    emotionalMemory.updateEmotionalContext('loving_words_heard', 7.0);
  }
  
  void giveSurpriseGift(String gift) {
    happiness = (happiness + 15).clamp(0, 100);
    emotionalMemory.updateEmotionalContext('surprise_gift_received', 9.0);
  }
}

void main() {
  print('🎭 AI Pet Companion - Enhanced Emotional System Demo');
  print('=' * 60);
  
  Pet myPet = Pet(
    name: 'Luna',
    species: 'Cat',
    age: 2,
    happiness: 75,
    energy: 80,
    hunger: 30,
  );
  
  print('\\n🐾 Meet ${myPet.name} - A ${myPet.species} with Unique Personality');
  
  // Show personality traits
  print('\\n📊 PERSONALITY PROFILE:');
  myPet.emotionalMemory.personalityTraits.forEach((trait, value) {
    print('${trait.capitalize()}: ${value.toStringAsFixed(1)}');
  });
  
  // Show emotional traits
  print('\\n💫 EMOTIONAL TRAITS:');
  myPet.emotionalMemory.emotionalTraits.forEach((trait, value) {
    print('${trait.capitalize()}: ${value.toStringAsFixed(1)}');
  });
  
  // Demonstrate interactions
  print('\\n🎯 EMOTIONAL INTERACTIONS:');
  
  myPet.gentleTouch();
  print('After gentle touch: ${myPet.emotionalMemory.getCurrentMoodDescription()}');
  
  myPet.talkToPet("You're such a good ${myPet.species.toLowerCase()}!");
  print('After talking: ${myPet.emotionalMemory.getCurrentMoodDescription()}');
  
  myPet.giveSurpriseGift("Special treat");
  print('After surprise gift: ${myPet.emotionalMemory.getCurrentMoodDescription()}');
  
  // Show recent contexts
  print('\\n💭 RECENT EMOTIONAL EXPERIENCES:');
  for (var context in myPet.emotionalMemory.recentContexts) {
    print('• $context');
  }
  
  // Show favorite memories
  print('\\n⭐ FAVORITE MEMORIES:');
  var favorites = myPet.emotionalMemory.getFavoriteMemories();
  for (var memory in favorites) {
    print('• $memory');
  }
  
  print('\\n${'=' * 60}');
  print('🌟 Your pet now has rich personality traits and emotional depth!');
  print('   Happiness level: ${myPet.happiness.toStringAsFixed(1)}');
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}