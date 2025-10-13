import 'models/pet.dart';

/// Demonstration of the enhanced emotional system
/// Shows all the new features we've added for "more emotions"
void main() {
  print('🎭 AI Pet Companion - Enhanced Emotional System Demo');
  print('=' * 60);
  
  // Create a pet with our enhanced emotional system
  Pet myPet = Pet(
    name: 'Luna',
    type: PetType.cat,
    gender: PetGender.female,
    happiness: 75,
    energy: 80,
    hunger: 30,
  );
  
  print('\n🐾 Meet ${myPet.name} - A ${myPet.type.name} with Unique Personality');
  
  // Show personality traits
  print('\n📊 PERSONALITY PROFILE:');
  print('Extroversion: ${myPet.emotionalMemory.personalityExtroversion.toStringAsFixed(1)}');
  print('Neuroticism: ${myPet.emotionalMemory.personalityNeuroticism.toStringAsFixed(1)}');
  print('Openness: ${myPet.emotionalMemory.personalityOpenness.toStringAsFixed(1)}');
  print('Agreeableness: ${myPet.emotionalMemory.personalityAgreeableness.toStringAsFixed(1)}');
  print('Conscientiousness: ${myPet.emotionalMemory.personalityConscientiousness.toStringAsFixed(1)}');
  
  // Show emotional traits
  print('\n💫 EMOTIONAL TRAITS:');
  print('Confidence: ${myPet.emotionalMemory.confidenceLevel.toStringAsFixed(1)}');
  print('Playfulness: ${myPet.emotionalMemory.playfulness.toStringAsFixed(1)}');
  print('Curiosity: ${myPet.emotionalMemory.curiosity.toStringAsFixed(1)}');
  print('Attachment: ${myPet.emotionalMemory.attachment.toStringAsFixed(1)}');
  print('Independence: ${myPet.emotionalMemory.independence.toStringAsFixed(1)}');
  print('Socialability: ${myPet.emotionalMemory.socialability.toStringAsFixed(1)}');
  print('Sensitivity: ${myPet.emotionalMemory.sensitivity.toStringAsFixed(1)}');
  print('Resilience: ${myPet.emotionalMemory.resilience.toStringAsFixed(1)}');
  
  // Demonstrate new emotional interactions
  print('\n🎯 EMOTIONAL INTERACTIONS:');
  
  // Gentle touch
  myPet.gentleTouch();
  print('After gentle touch: ${myPet.emotionalMemory.currentMoodDescription}');
  
  // Talk to pet
  myPet.talkToPet("You're such a good ${myPet.type.name.toLowerCase()}!");
  print('After talking: ${myPet.emotionalMemory.currentMoodDescription}');
  
  // Give surprise gift
  myPet.giveSurpriseGift("Special treat");
  print('After surprise gift: ${myPet.emotionalMemory.currentMoodDescription}');
  
  // Show recent emotional contexts
  print('\n💭 RECENT EMOTIONAL EXPERIENCES:');
  var recentMemories = myPet.emotionalMemory.memories.take(5);
  for (var memory in recentMemories) {
    print('• ${memory.type.name} - ${memory.context.name} (${memory.intensityLevel.toStringAsFixed(1)})');
  }
  
  // Show favorite memories
  print('\n⭐ FAVORITE MEMORIES:');
  var favorites = myPet.emotionalMemory.favoriteMemories;
  for (var memory in favorites.take(3)) {
    print('• $memory');
  }
  
  // Show trust and bond levels
  print('\n🤝 RELATIONSHIP STATUS:');
  print('Trust Level: ${myPet.emotionalMemory.trustLevel.toStringAsFixed(1)}');
  print('Bond Strength: ${myPet.emotionalMemory.bondStrength.toStringAsFixed(1)}');
  
  // Show fear triggers
  if (myPet.emotionalMemory.fearTriggers.isNotEmpty) {
    print('\n⚠️ THINGS TO AVOID:');
    for (var fear in myPet.emotionalMemory.fearTriggers) {
      print('• $fear');
    }
  }
  
  print('\n${'=' * 60}');
  print('🌟 Your pet now has 15 emotional contexts, unique personality');
  print('   traits, and dynamic emotional responses that evolve over time!');
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}