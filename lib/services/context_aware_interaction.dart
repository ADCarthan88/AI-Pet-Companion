import 'dart:math' as math;
import 'dart:async';
import 'package:flutter/material.dart';
import '../models/pet.dart';
import '../models/emotional_memory.dart';

/// Context-aware interaction system that adapts pet responses based on situation
class ContextAwareInteraction {
  final Pet pet;
  Timer? _contextTimer;
  
  // Context tracking
  String _currentContext = 'neutral';
  DateTime _contextStartTime = DateTime.now();
  final Map<String, int> _contextHistory = {};
  
  // Environmental awareness
  TimeOfDay? _lastInteractionTime;
  String _environmentalMood = 'calm';
  double _userAttentionLevel = 0.5;
  
  // Adaptive response patterns
  final Map<String, Map<String, double>> _contextResponseModifiers = {};

  ContextAwareInteraction({required this.pet}) {
    _initializeContextSystem();
  }

  void _initializeContextSystem() {
    _setupContextResponseModifiers();
    _startContextMonitoring();
  }

  void _setupContextResponseModifiers() {
    // Define how different contexts modify pet responses
    _contextResponseModifiers['morning'] = {
      'energy_boost': 1.2,
      'happiness_modifier': 1.1,
      'playfulness_boost': 1.3,
      'attention_seeking': 1.4,
    };
    
    _contextResponseModifiers['evening'] = {
      'energy_boost': 0.8,
      'happiness_modifier': 1.0,
      'playfulness_boost': 0.7,
      'attention_seeking': 1.2,
    };
    
    _contextResponseModifiers['night'] = {
      'energy_boost': 0.5,
      'happiness_modifier': 0.9,
      'playfulness_boost': 0.3,
      'attention_seeking': 0.6,
    };
    
    _contextResponseModifiers['weekend'] = {
      'energy_boost': 1.1,
      'happiness_modifier': 1.2,
      'playfulness_boost': 1.4,
      'attention_seeking': 1.3,
    };
    
    _contextResponseModifiers['stressed_user'] = {
      'energy_boost': 0.9,
      'happiness_modifier': 1.3,
      'playfulness_boost': 0.8,
      'attention_seeking': 1.5,
    };
    
    _contextResponseModifiers['happy_user'] = {
      'energy_boost': 1.2,
      'happiness_modifier': 1.3,
      'playfulness_boost': 1.5,
      'attention_seeking': 1.1,
    };
  }

  void _startContextMonitoring() {
    _contextTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => _updateContext(),
    );
  }

  /// Update current context based on various factors
  void _updateContext() {
    final newContext = _analyzeCurrentContext();
    
    if (newContext != _currentContext) {
      _transitionToContext(newContext);
    }
    
    _updateEnvironmentalMood();
    _updateUserAttentionLevel();
  }

  String _analyzeCurrentContext() {
    final now = DateTime.now();
    final hour = now.hour;
    final isWeekend = now.weekday >= 6;
    
    // Time-based context
    String timeContext;
    if (hour >= 6 && hour < 12) {
      timeContext = 'morning';
    } else if (hour >= 12 && hour < 18) {
      timeContext = 'afternoon';
    } else if (hour >= 18 && hour < 22) {
      timeContext = 'evening';
    } else {
      timeContext = 'night';
    }
    
    // Weekend modifier
    if (isWeekend) {
      timeContext = 'weekend_$timeContext';
    }
    
    // User state modifier (inferred from interaction patterns)
    if (_userAttentionLevel > 0.8) {
      timeContext = 'engaged_$timeContext';
    } else if (_userAttentionLevel < 0.3) {
      timeContext = 'distracted_$timeContext';
    }
    
    return timeContext;
  }

  void _transitionToContext(String newContext) {
    print('🌍 Context Transition: $_currentContext → $newContext');
    
    _currentContext = newContext;
    _contextStartTime = DateTime.now();
    
    // Track context history
    _contextHistory[newContext] = (_contextHistory[newContext] ?? 0) + 1;
    
    // Apply immediate context effects
    _applyContextEffects(newContext);
  }

  void _applyContextEffects(String context) {
    final modifiers = _getContextModifiers(context);
    
    // Apply energy modifications
    if (modifiers.containsKey('energy_boost')) {
      final energyMod = modifiers['energy_boost']! - 1.0;
      pet.energy = (pet.energy + (energyMod * 10)).clamp(0, 100).round();
    }
    
    // Apply happiness modifications
    if (modifiers.containsKey('happiness_modifier')) {
      final happinessMod = modifiers['happiness_modifier']! - 1.0;
      pet.happiness = (pet.happiness + (happinessMod * 5)).clamp(0, 100).round();
    }
    
    // Adjust pet behavior based on context
    _adjustBehaviorForContext(context);
  }

  void _adjustBehaviorForContext(String context) {
    if (context.contains('morning')) {
      // Morning energy and alertness
      if (pet.mood == PetMood.tired) {
        pet.mood = PetMood.neutral;
      }
      if (pet.currentActivity == PetActivity.sleeping && pet.energy > 40) {
        pet.currentActivity = PetActivity.idle;
      }
    } else if (context.contains('night')) {
      // Evening wind-down
      if (pet.energy < 30 && pet.currentActivity != PetActivity.sleeping) {
        pet.currentActivity = PetActivity.sleeping;
        pet.mood = PetMood.tired;
      }
    } else if (context.contains('weekend')) {
      // Weekend relaxation and play
      if (pet.energy > 60 && pet.emotionalMemory.playfulness > 50) {
        pet.mood = PetMood.excited;
      }
    }
  }

  void _updateEnvironmentalMood() {
    // Analyze pet's recent emotional state to infer environmental mood
    final recentHappiness = pet.happiness;
    final trustLevel = pet.emotionalMemory.trustLevel;
    
    if (recentHappiness > 80 && trustLevel > 70) {
      _environmentalMood = 'joyful';
    } else if (recentHappiness > 60) {
      _environmentalMood = 'positive';
    } else if (recentHappiness < 40) {
      _environmentalMood = 'subdued';
    } else {
      _environmentalMood = 'calm';
    }
  }

  void _updateUserAttentionLevel() {
    // Infer user attention level from interaction frequency
    final timeSinceLastInteraction = _lastInteractionTime != null
        ? DateTime.now().difference(DateTime(
            DateTime.now().year,
            DateTime.now().month,
            DateTime.now().day,
            _lastInteractionTime!.hour,
            _lastInteractionTime!.minute,
          ))
        : Duration(hours: 1);
    
    if (timeSinceLastInteraction.inMinutes < 2) {
      _userAttentionLevel = (_userAttentionLevel + 0.1).clamp(0.0, 1.0);
    } else if (timeSinceLastInteraction.inMinutes > 10) {
      _userAttentionLevel = (_userAttentionLevel - 0.05).clamp(0.0, 1.0);
    }
  }

  /// Process interaction with context awareness
  Map<String, dynamic> processContextualInteraction(
    InteractionType type,
    Map<String, dynamic>? baseContext,
  ) {
    final contextModifiers = _getContextModifiers(_currentContext);
    final enhancedContext = Map<String, dynamic>.from(baseContext ?? {});
    
    // Add contextual information
    enhancedContext['current_context'] = _currentContext;
    enhancedContext['environmental_mood'] = _environmentalMood;
    enhancedContext['user_attention_level'] = _userAttentionLevel;
    enhancedContext['time_in_context'] = DateTime.now().difference(_contextStartTime).inMinutes;
    
    // Apply context modifiers to interaction effects
    enhancedContext['context_modifiers'] = contextModifiers;
    
    // Calculate contextual response intensity
    enhancedContext['response_intensity'] = _calculateContextualIntensity(type);
    
    // Update interaction time
    _lastInteractionTime = TimeOfDay.now();
    
    return enhancedContext;
  }

  double _calculateContextualIntensity(InteractionType type) {
    double baseIntensity = 0.5;
    final modifiers = _getContextModifiers(_currentContext);
    
    // Apply context-specific intensity modifications
    switch (type) {
      case InteractionType.playing:
        baseIntensity *= modifiers['playfulness_boost'] ?? 1.0;
        break;
      case InteractionType.petting:
      case InteractionType.gentleTouch:
        baseIntensity *= modifiers['attention_seeking'] ?? 1.0;
        break;
      case InteractionType.feeding:
        // Feeding is more appreciated at certain times
        if (_currentContext.contains('morning') || _currentContext.contains('evening')) {
          baseIntensity *= 1.2;
        }
        break;
      default:
        baseIntensity *= modifiers['happiness_modifier'] ?? 1.0;
    }
    
    // User attention level affects intensity
    baseIntensity *= (0.5 + _userAttentionLevel * 0.5);
    
    return baseIntensity.clamp(0.1, 1.5);
  }

  Map<String, double> _getContextModifiers(String context) {
    // Find the best matching context modifiers
    for (final key in _contextResponseModifiers.keys) {
      if (context.contains(key)) {
        return _contextResponseModifiers[key]!;
      }
    }
    
    // Default modifiers
    return {
      'energy_boost': 1.0,
      'happiness_modifier': 1.0,
      'playfulness_boost': 1.0,
      'attention_seeking': 1.0,
    };
  }

  /// Get contextual recommendations for user
  List<String> getContextualRecommendations() {
    final recommendations = <String>[];
    final modifiers = _getContextModifiers(_currentContext);
    
    if (_currentContext.contains('morning')) {
      recommendations.add('${pet.name} is naturally more energetic in the morning - great time for play!');
      if (pet.hunger > 50) {
        recommendations.add('Morning feeding would be especially appreciated right now.');
      }
    } else if (_currentContext.contains('evening')) {
      recommendations.add('Evening is perfect for gentle bonding activities with ${pet.name}.');
      if (pet.emotionalMemory.attachment > 60) {
        recommendations.add('${pet.name} loves evening cuddle time - they feel most connected to you now.');
      }
    } else if (_currentContext.contains('night')) {
      recommendations.add('${pet.name} is winding down for the night - gentle interactions work best.');
      if (pet.energy < 40) {
        recommendations.add('Help ${pet.name} find a cozy spot to rest for the night.');
      }
    }
    
    if (_currentContext.contains('weekend')) {
      recommendations.add('Weekend vibes! ${pet.name} is extra playful and social today.');
    }
    
    if (_userAttentionLevel > 0.8) {
      recommendations.add('${pet.name} notices you\'re very engaged - they\'re responding more enthusiastically!');
    } else if (_userAttentionLevel < 0.3) {
      recommendations.add('${pet.name} senses you might be busy - they\'re being more independent.');
    }
    
    // Environmental mood recommendations
    switch (_environmentalMood) {
      case 'joyful':
        recommendations.add('The atmosphere is joyful - ${pet.name} is radiating happiness!');
        break;
      case 'subdued':
        recommendations.add('${pet.name} seems to need some extra care and attention right now.');
        break;
    }
    
    return recommendations;
  }

  /// Get current context summary
  Map<String, dynamic> getContextSummary() {
    return {
      'current_context': _currentContext,
      'time_in_context': DateTime.now().difference(_contextStartTime).inMinutes,
      'environmental_mood': _environmentalMood,
      'user_attention_level': _userAttentionLevel,
      'context_modifiers': _getContextModifiers(_currentContext),
      'recommendations': getContextualRecommendations(),
    };
  }

  void dispose() {
    _contextTimer?.cancel();
  }
}