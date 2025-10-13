import 'dart:math' as math;
import 'dart:async';
import 'package:flutter/material.dart';
import '../models/pet.dart';
import '../models/emotional_memory.dart';

/// Engine for realistic pet behaviors that respond to context and build relationships
class RealisticBehaviorEngine {
  final Pet pet;
  Timer? _behaviorTimer;
  Timer? _microExpressionTimer;
  Timer? _adaptiveLearningTimer;
  
  // Behavior state tracking
  String _currentBehaviorState = 'idle';
  DateTime _lastBehaviorChange = DateTime.now();
  final List<String> _recentBehaviors = [];
  
  // Micro-expression and subtle behavior tracking
  bool _isShowingMicroExpression = false;
  String _currentMicroExpression = '';
  
  // Adaptive learning - pet learns user preferences
  final Map<String, double> _userPreferenceScores = {};
  final Map<String, int> _interactionCounts = {};
  
  // Realistic timing patterns
  final Map<String, Duration> _behaviorDurations = {
    'idle': Duration(seconds: 5),
    'alert': Duration(seconds: 3),
    'investigating': Duration(seconds: 8),
    'content': Duration(seconds: 12),
    'seeking_attention': Duration(seconds: 6),
    'resting': Duration(seconds: 15),
    'playful_energy': Duration(seconds: 10),
  };

  RealisticBehaviorEngine({required this.pet}) {
    _initializeBehaviorEngine();
  }

  void _initializeBehaviorEngine() {
    // Start behavior monitoring
    _behaviorTimer = Timer.periodic(
      const Duration(seconds: 3),
      (_) => _updateRealisticBehavior(),
    );
    
    // Start micro-expression system
    _microExpressionTimer = Timer.periodic(
      const Duration(seconds: 2),
      (_) => _updateMicroExpressions(),
    );
    
    // Start adaptive learning
    _adaptiveLearningTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => _updateAdaptiveLearning(),
    );
  }

  /// Update realistic behavior patterns
  void _updateRealisticBehavior() {
    final currentTime = DateTime.now();
    final timeSinceLastChange = currentTime.difference(_lastBehaviorChange);
    
    // Check if it's time to change behavior
    final currentDuration = _behaviorDurations[_currentBehaviorState] ?? Duration(seconds: 5);
    
    if (timeSinceLastChange >= currentDuration) {
      final newBehavior = _selectNextBehavior();
      _transitionToBehavior(newBehavior);
    }
    
    // Apply continuous behavior effects
    _applyContinuousBehaviorEffects();
  }

  /// Select next behavior based on realistic patterns
  String _selectNextBehavior() {
    final emotionalState = _analyzeCurrentEmotionalState();
    final environmentalContext = _analyzeEnvironmentalContext();
    final personalityFactors = _analyzePersonalityFactors();
    
    final behaviorProbabilities = <String, double>{};
    
    // Base behavior probabilities
    behaviorProbabilities['idle'] = 0.3;
    behaviorProbabilities['alert'] = 0.1;
    behaviorProbabilities['investigating'] = 0.15;
    behaviorProbabilities['content'] = 0.2;
    behaviorProbabilities['seeking_attention'] = 0.1;
    behaviorProbabilities['resting'] = 0.1;
    behaviorProbabilities['playful_energy'] = 0.05;
    
    // Adjust probabilities based on emotional state
    _adjustProbabilitiesForEmotion(behaviorProbabilities, emotionalState);
    
    // Adjust for environmental context
    _adjustProbabilitiesForEnvironment(behaviorProbabilities, environmentalContext);
    
    // Adjust for personality
    _adjustProbabilitiesForPersonality(behaviorProbabilities, personalityFactors);
    
    // Avoid repetitive behaviors
    _adjustProbabilitiesForVariety(behaviorProbabilities);
    
    return _selectWeightedRandomBehavior(behaviorProbabilities);
  }

  void _adjustProbabilitiesForEmotion(Map<String, double> probs, Map<String, dynamic> emotional) {
    switch (emotional['mood'] as PetMood) {
      case PetMood.happy:
        probs['content'] = (probs['content']! * 1.5).clamp(0.0, 1.0);
        probs['playful_energy'] = (probs['playful_energy']! * 2.0).clamp(0.0, 1.0);
        break;
      case PetMood.sad:
        probs['resting'] = (probs['resting']! * 2.0).clamp(0.0, 1.0);
        probs['seeking_attention'] = (probs['seeking_attention']! * 1.5).clamp(0.0, 1.0);
        probs['playful_energy'] = (probs['playful_energy']! * 0.3).clamp(0.0, 1.0);
        break;
      case PetMood.excited:
        probs['alert'] = (probs['alert']! * 2.0).clamp(0.0, 1.0);
        probs['investigating'] = (probs['investigating']! * 1.8).clamp(0.0, 1.0);
        probs['playful_energy'] = (probs['playful_energy']! * 3.0).clamp(0.0, 1.0);
        break;
      case PetMood.tired:
        probs['resting'] = (probs['resting']! * 3.0).clamp(0.0, 1.0);
        probs['idle'] = (probs['idle']! * 1.5).clamp(0.0, 1.0);
        probs['alert'] = (probs['alert']! * 0.2).clamp(0.0, 1.0);
        break;
      case PetMood.loving:
        probs['seeking_attention'] = (probs['seeking_attention']! * 2.5).clamp(0.0, 1.0);
        probs['content'] = (probs['content']! * 1.8).clamp(0.0, 1.0);
        break;
      case PetMood.neutral:
        // No major adjustments for neutral mood
        break;
    }
    
    // Energy level adjustments
    if (emotional['energy'] < 30) {
      probs['resting'] = (probs['resting']! * 2.0).clamp(0.0, 1.0);
      probs['playful_energy'] = (probs['playful_energy']! * 0.1).clamp(0.0, 1.0);
    } else if (emotional['energy'] > 80) {
      probs['playful_energy'] = (probs['playful_energy']! * 2.5).clamp(0.0, 1.0);
      probs['investigating'] = (probs['investigating']! * 1.5).clamp(0.0, 1.0);
    }
  }

  void _adjustProbabilitiesForEnvironment(Map<String, double> probs, Map<String, dynamic> env) {
    // Time of day adjustments
    final hour = DateTime.now().hour;
    if (hour >= 22 || hour <= 6) {
      probs['resting'] = (probs['resting']! * 2.5).clamp(0.0, 1.0);
      probs['playful_energy'] = (probs['playful_energy']! * 0.2).clamp(0.0, 1.0);
    } else if (hour >= 6 && hour <= 10) {
      probs['alert'] = (probs['alert']! * 1.8).clamp(0.0, 1.0);
      probs['investigating'] = (probs['investigating']! * 1.5).clamp(0.0, 1.0);
    }
    
    // Habitat condition adjustments
    if (env['habitat_cleanliness'] < 50) {
      probs['investigating'] = (probs['investigating']! * 0.7).clamp(0.0, 1.0);
      probs['content'] = (probs['content']! * 0.8).clamp(0.0, 1.0);
    }
    
    // Resource availability
    if (!env['has_food'] || !env['has_water']) {
      probs['investigating'] = (probs['investigating']! * 1.5).clamp(0.0, 1.0);
      probs['seeking_attention'] = (probs['seeking_attention']! * 1.3).clamp(0.0, 1.0);
    }
  }

  void _adjustProbabilitiesForPersonality(Map<String, double> probs, Map<String, dynamic> personality) {
    // Extroversion affects attention-seeking
    if (personality['extroversion'] > 60) {
      probs['seeking_attention'] = (probs['seeking_attention']! * 1.5).clamp(0.0, 1.0);
      probs['alert'] = (probs['alert']! * 1.3).clamp(0.0, 1.0);
    } else if (personality['extroversion'] < 40) {
      probs['resting'] = (probs['resting']! * 1.3).clamp(0.0, 1.0);
      probs['content'] = (probs['content']! * 1.2).clamp(0.0, 1.0);
    }
    
    // Openness affects investigating behavior
    if (personality['openness'] > 60) {
      probs['investigating'] = (probs['investigating']! * 1.8).clamp(0.0, 1.0);
      probs['playful_energy'] = (probs['playful_energy']! * 1.4).clamp(0.0, 1.0);
    }
    
    // Neuroticism affects alert and resting behaviors
    if (personality['neuroticism'] > 60) {
      probs['alert'] = (probs['alert']! * 1.6).clamp(0.0, 1.0);
      probs['resting'] = (probs['resting']! * 1.2).clamp(0.0, 1.0);
    }
  }

  void _adjustProbabilitiesForVariety(Map<String, double> probs) {
    // Reduce probability of recently used behaviors
    for (final recentBehavior in _recentBehaviors) {
      if (probs.containsKey(recentBehavior)) {
        probs[recentBehavior] = (probs[recentBehavior]! * 0.5).clamp(0.0, 1.0);
      }
    }
  }

  String _selectWeightedRandomBehavior(Map<String, double> probabilities) {
    final totalWeight = probabilities.values.fold(0.0, (sum, weight) => sum + weight);
    final random = math.Random().nextDouble() * totalWeight;
    
    double currentWeight = 0.0;
    for (final entry in probabilities.entries) {
      currentWeight += entry.value;
      if (random <= currentWeight) {
        return entry.key;
      }
    }
    
    return 'idle'; // Fallback
  }

  /// Transition to new behavior with realistic timing
  void _transitionToBehavior(String newBehavior) {
    if (newBehavior == _currentBehaviorState) return;
    
    print('🎭 Behavior Transition: $_currentBehaviorState → $newBehavior');
    
    _currentBehaviorState = newBehavior;
    _lastBehaviorChange = DateTime.now();
    
    // Track recent behaviors for variety
    _recentBehaviors.add(newBehavior);
    if (_recentBehaviors.length > 3) {
      _recentBehaviors.removeAt(0);
    }
    
    // Apply immediate behavior effects
    _applyBehaviorTransitionEffects(newBehavior);
    
    // Record emotional memory of behavior change
    _recordBehaviorMemory(newBehavior);
  }

  void _applyBehaviorTransitionEffects(String behavior) {
    switch (behavior) {
      case 'alert':
        pet.energy = (pet.energy - 2).clamp(0, 100);
        if (pet.mood == PetMood.neutral) {
          pet.mood = PetMood.excited;
        }
        break;
      case 'investigating':
        pet.energy = (pet.energy - 3).clamp(0, 100);
        pet.happiness = (pet.happiness + 2).clamp(0, 100);
        break;
      case 'content':
        pet.happiness = (pet.happiness + 3).clamp(0, 100);
        if (pet.mood == PetMood.sad) {
          pet.mood = PetMood.neutral;
        }
        break;
      case 'seeking_attention':
        if (pet.emotionalMemory.attachment > 50) {
          pet.happiness = (pet.happiness + 1).clamp(0, 100);
        }
        break;
      case 'resting':
        pet.energy = (pet.energy + 5).clamp(0, 100);
        if (pet.energy < 30) {
          pet.currentActivity = PetActivity.sleeping;
        }
        break;
      case 'playful_energy':
        pet.mood = PetMood.excited;
        pet.currentActivity = PetActivity.playing;
        break;
    }
  }

  /// Apply continuous effects while in current behavior
  void _applyContinuousBehaviorEffects() {
    switch (_currentBehaviorState) {
      case 'resting':
        // Gradual energy recovery
        if (math.Random().nextDouble() < 0.3) {
          pet.energy = (pet.energy + 1).clamp(0, 100);
        }
        break;
      case 'investigating':
        // Gradual curiosity satisfaction
        if (math.Random().nextDouble() < 0.2) {
          pet.happiness = (pet.happiness + 1).clamp(0, 100);
        }
        break;
      case 'seeking_attention':
        // Gradual loneliness if ignored
        if (DateTime.now().difference(_lastBehaviorChange).inMinutes > 2) {
          if (math.Random().nextDouble() < 0.1) {
            pet.happiness = (pet.happiness - 1).clamp(0, 100);
          }
        }
        break;
    }
  }

  /// Update micro-expressions for subtle realism
  void _updateMicroExpressions() {
    if (_shouldShowMicroExpression()) {
      final microExpression = _selectMicroExpression();
      _showMicroExpression(microExpression);
    } else if (_isShowingMicroExpression) {
      _hideMicroExpression();
    }
  }

  bool _shouldShowMicroExpression() {
    // Base probability
    double probability = 0.15;
    
    // Increase probability based on emotional state
    if (pet.mood == PetMood.happy || pet.mood == PetMood.loving) {
      probability += 0.1;
    }
    
    // Personality influences
    if (pet.emotionalMemory.personalityExtroversion > 60) {
      probability += 0.05;
    }
    
    if (pet.emotionalMemory.sensitivity > 60) {
      probability += 0.08;
    }
    
    return math.Random().nextDouble() < probability.clamp(0.05, 0.4);
  }

  String _selectMicroExpression() {
    final expressions = <String>[];
    
    // Mood-based micro-expressions
    switch (pet.mood) {
      case PetMood.happy:
        expressions.addAll(['subtle_smile', 'ear_perk', 'tail_twitch_happy']);
        break;
      case PetMood.sad:
        expressions.addAll(['ear_droop', 'slow_blink', 'head_lower']);
        break;
      case PetMood.excited:
        expressions.addAll(['quick_head_turn', 'alert_ears', 'body_lean_forward']);
        break;
      case PetMood.tired:
        expressions.addAll(['yawn_start', 'eye_droop', 'body_settle']);
        break;
      case PetMood.loving:
        expressions.addAll(['soft_gaze', 'gentle_head_tilt', 'relaxed_posture']);
        break;
      default:
        expressions.addAll(['ear_twitch', 'nose_twitch', 'subtle_head_turn']);
    }
    
    // Behavior-based micro-expressions
    switch (_currentBehaviorState) {
      case 'alert':
        expressions.addAll(['ear_focus', 'eye_widen', 'body_tense']);
        break;
      case 'investigating':
        expressions.addAll(['nose_work', 'head_tilt_curious', 'step_forward']);
        break;
      case 'content':
        expressions.addAll(['relaxed_breathing', 'soft_eyes', 'comfortable_settle']);
        break;
    }
    
    return expressions.isNotEmpty 
        ? expressions[math.Random().nextInt(expressions.length)]
        : 'subtle_head_turn';
  }

  void _showMicroExpression(String expression) {
    _isShowingMicroExpression = true;
    _currentMicroExpression = expression;
    
    print('😊 Micro-expression: $expression');
    
    // Schedule hiding the micro-expression
    Timer(Duration(milliseconds: 800 + math.Random().nextInt(1200)), () {
      _hideMicroExpression();
    });
  }

  void _hideMicroExpression() {
    _isShowingMicroExpression = false;
    _currentMicroExpression = '';
  }

  /// Update adaptive learning based on user interactions
  void _updateAdaptiveLearning() {
    // Analyze recent interaction patterns
    _analyzeUserPreferences();
    
    // Adjust behavior patterns based on learned preferences
    _adaptBehaviorToPreferences();
  }

  void _analyzeUserPreferences() {
    // This would analyze interaction history to learn user preferences
    // For now, we'll use simple heuristics based on emotional memory
    
    final favoriteInteraction = pet.emotionalMemory.getFavoriteInteraction();
    if (favoriteInteraction != null) {
      final key = favoriteInteraction.name;
      _userPreferenceScores[key] = (_userPreferenceScores[key] ?? 0.0) + 1.0;
    }
    
    // Analyze timing preferences
    final currentHour = DateTime.now().hour;
    final hourKey = 'hour_$currentHour';
    if (pet.happiness > 70) {
      _userPreferenceScores[hourKey] = (_userPreferenceScores[hourKey] ?? 0.0) + 0.5;
    }
  }

  void _adaptBehaviorToPreferences() {
    // Adjust behavior durations based on user engagement
    if (_userPreferenceScores['playing'] != null && _userPreferenceScores['playing']! > 5) {
      _behaviorDurations['playful_energy'] = Duration(seconds: 15); // Longer play sessions
    }
    
    if (_userPreferenceScores['petting'] != null && _userPreferenceScores['petting']! > 5) {
      _behaviorDurations['seeking_attention'] = Duration(seconds: 10); // More attention seeking
    }
  }

  void _recordBehaviorMemory(String behavior) {
    // Record the behavior change as a memory for learning
    final context = _getBehaviorEmotionalContext(behavior);
    
    pet.emotionalMemory.recordInteraction(
      InteractionType.playing, // Generic interaction type for behaviors
      context,
      intensity: 0.2,
      notes: 'Autonomous behavior: $behavior',
    );
  }

  EmotionalContext _getBehaviorEmotionalContext(String behavior) {
    switch (behavior) {
      case 'content':
      case 'resting':
        return EmotionalContext.positive;
      case 'playful_energy':
        return EmotionalContext.joyful;
      case 'seeking_attention':
        return EmotionalContext.bonding;
      case 'investigating':
        return EmotionalContext.curious;
      case 'alert':
        return EmotionalContext.anxious;
      default:
        return EmotionalContext.neutral;
    }
  }

  // Analysis methods
  Map<String, dynamic> _analyzeCurrentEmotionalState() {
    return {
      'mood': pet.mood,
      'energy': pet.energy,
      'happiness': pet.happiness,
      'trust': pet.emotionalMemory.trustLevel,
      'attachment': pet.emotionalMemory.attachment,
      'playfulness': pet.emotionalMemory.playfulness,
      'curiosity': pet.emotionalMemory.curiosity,
    };
  }

  Map<String, dynamic> _analyzeEnvironmentalContext() {
    return {
      'habitat_cleanliness': pet.habitat?.cleanliness ?? 50,
      'has_food': pet.habitat?.hasFood ?? false,
      'has_water': pet.habitat?.hasWater ?? false,
      'time_of_day': DateTime.now().hour,
      'has_toys': pet.currentToy != null,
    };
  }

  Map<String, dynamic> _analyzePersonalityFactors() {
    return {
      'extroversion': pet.emotionalMemory.personalityExtroversion,
      'neuroticism': pet.emotionalMemory.personalityNeuroticism,
      'openness': pet.emotionalMemory.personalityOpenness,
      'agreeableness': pet.emotionalMemory.personalityAgreeableness,
      'conscientiousness': pet.emotionalMemory.personalityConscientiousness,
    };
  }

  // Getters for current state
  String get currentBehaviorState => _currentBehaviorState;
  bool get isShowingMicroExpression => _isShowingMicroExpression;
  String get currentMicroExpression => _currentMicroExpression;
  Map<String, double> get userPreferenceScores => Map.unmodifiable(_userPreferenceScores);

  void dispose() {
    _behaviorTimer?.cancel();
    _microExpressionTimer?.cancel();
    _adaptiveLearningTimer?.cancel();
  }
}