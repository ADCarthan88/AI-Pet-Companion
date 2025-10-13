import '../models/pet.dart';

void demonstrateEmotionalFeatures() {
  print('🎭 === EMOTIONAL PET COMPANION DEMO ===');
  print('');
  
  // Create a new pet
  final pet = Pet(
    name: 'Buddy',
    type: PetType.dog,
    gender: PetGender.male,
  );
  
  print('🐕 Meet ${pet.name}! A ${pet.type.name} with a unique personality:');
  print('   Extroversion: ${pet.emotionalMemory.personalityExtroversion.toStringAsFixed(1)}');
  print('   Emotional Sensitivity: ${pet.emotionalMemory.personalityNeuroticism.toStringAsFixed(1)}');
  print('   Openness: ${pet.emotionalMemory.personalityOpenness.toStringAsFixed(1)}');
  print('   Cooperativeness: ${pet.emotionalMemory.personalityAgreeableness.toStringAsFixed(1)}');
  print('   Loves Routine: ${pet.emotionalMemory.personalityConscientiousness.toStringAsFixed(1)}');
  print('');
  
  print(pet.getEmotionalState());
  print('');
  
  // Demonstrate feeding interactions
  print('🍽️ === FEEDING INTERACTIONS ===');
  pet.hunger = 80; // Make pet very hungry
  print('${pet.name} is very hungry (${pet.hunger}/100)...');
  pet.feed();
  print('After feeding: ${pet.getEmotionalState()}');
  print('Trust Level: ${pet.getTrustLevel().toStringAsFixed(1)}');
  print('Bond Strength: ${pet.getBondStrength().toStringAsFixed(1)}');
  print('');
  
  // Demonstrate emotional interactions
  print('💝 === EMOTIONAL INTERACTIONS ===');
  pet.gentleTouch(location: 'behind ears');
  print('After gentle touch: ${pet.getEmotionalState()}');
  
  pet.talkToPet('You\'re such a good doggy!');
  print('After talking sweetly: ${pet.getEmotionalState()}');
  
  pet.giveSurpriseGift('favorite squeaky toy');
  print('After surprise gift: ${pet.getEmotionalState()}');
  print('');
  
  // Show personality-based reactions
  print('🎭 === PERSONALITY-BASED REACTIONS ===');
  if (pet.emotionalMemory.personalityExtroversion > 60) {
    print('${pet.name} is naturally social and loves all this attention!');
  } else {
    print('${pet.name} is more reserved but still appreciates your gentle care.');
  }
  
  if (pet.emotionalMemory.personalityOpenness > 60) {
    print('${pet.name} is curious and would love trying new activities!');
  } else {
    print('${pet.name} prefers familiar routines and consistent care.');
  }
  print('');
  
  // Show current emotional stats
  print('📊 === CURRENT EMOTIONAL STATE ===');
  print('Trust Level: ${pet.getTrustLevel().toStringAsFixed(1)}/100');
  print('Bond Strength: ${pet.getBondStrength().toStringAsFixed(1)}/100');
  print('Attachment: ${pet.emotionalMemory.attachment.toStringAsFixed(1)}/100');
  print('Confidence: ${pet.emotionalMemory.confidenceLevel.toStringAsFixed(1)}/100');
  print('Playfulness: ${pet.emotionalMemory.playfulness.toStringAsFixed(1)}/100');
  print('Curiosity: ${pet.emotionalMemory.curiosity.toStringAsFixed(1)}/100');
  print('Social Needs: ${pet.emotionalMemory.socialability.toStringAsFixed(1)}/100');
  print('Current Mood: ${pet.emotionalMemory.currentMoodDescription}');
  print('');
  
  // Show behavioral recommendations
  print('💡 === BEHAVIORAL RECOMMENDATIONS ===');
  final recommendations = pet.getBehavioralRecommendations();
  if (recommendations.isNotEmpty) {
    for (int i = 0; i < recommendations.length; i++) {
      print('${i + 1}. ${recommendations[i]}');
    }
  } else {
    print('Keep up the great care! No specific recommendations at this time.');
  }
  print('');
  
  // Show favorite memories
  print('⭐ === SPECIAL MEMORIES ===');
  final favoriteMemories = pet.emotionalMemory.favoriteMemories;
  if (favoriteMemories.isNotEmpty) {
    print('${pet.name} cherishes these moments:');
    for (final memory in favoriteMemories) {
      print('  • $memory');
    }
  } else {
    print('${pet.name} is still creating special memories with you!');
  }
  print('');
  
  // Demonstrate habitat aging
  print('🏠 === HABITAT AGING SYSTEM ===');
  if (pet.habitat != null) {
    print('Habitat condition: ${pet.getHabitatCondition()}');
    print('Needs maintenance: ${pet.habitatNeedsMaintenance() ? "Yes" : "No"}');
    if (pet.habitatNeedsMaintenance()) {
      print('Maintenance cost: ${pet.getHabitatMaintenanceCost().toStringAsFixed(1)} coins');
    }
    print('Overall wear: ${pet.habitat!.overallWear.toStringAsFixed(1)}/100');
    print('Mold level: ${pet.habitat!.moldLevel.toStringAsFixed(1)}/10');
    print('Damage marks: ${pet.habitat!.damageMarks.length}');
  }
  print('');
  
  // Show how emotions affect happiness
  print('🎯 === EMOTIONAL INFLUENCE ON HAPPINESS ===');
  final emotionalModifiers = pet.emotionalMemory.getEmotionalStatModifiers();
  print('Base happiness: ${pet.happiness}');
  print('Emotional happiness bonus: ${emotionalModifiers['happiness']?.toStringAsFixed(1) ?? "0.0"}');
  print('Stress impact: ${emotionalModifiers['stress']?.toStringAsFixed(1) ?? "0.0"}');
  print('Loneliness reduction: ${emotionalModifiers['loneliness']?.toStringAsFixed(1) ?? "0.0"}');
  print('');
  
  print('✨ === CONCLUSION ===');
  print('${pet.name} now has deep emotional complexity!');
  print('• Unique personality traits that affect all interactions');
  print('• Rich emotional memory system that remembers your care');
  print('• Dynamic mood descriptions that reflect personality');
  print('• Behavioral recommendations based on emotional needs');
  print('• Habitat aging that requires ongoing maintenance');
  print('• Trust, bond, and attachment systems that grow over time');
  print('');
  print('Every interaction now has lasting emotional impact! 🎉');
}