import 'dart:math' as math;
import 'dart:async';
import 'package:flutter/material.dart';
import '../models/pet.dart';
import '../models/emotional_memory.dart';

/// Service for handling interactive responses that make the pet feel more alive
class InteractiveResponseService {
  final Pet pet;
  Timer? _responseTimer;
  Timer? _anticipationTimer;
  
  // Response state tracking
  bool _isAnticipatingInteraction = false;
  String _anticipatedInteraction = '';
  DateTime _lastInteractionTime = DateTime.now();
  
  // Response patterns and timing
  final Map<InteractionType, List<String>> _responsePatterns = {};
  final Map<String, Duration> _responseDurations = {};
  
  // Contextual awareness
  String _currentUserContext = 'idle';
  double _userEngagementLevel = 0.5;
  final List<String> _recentUserActions = [];

  InteractiveResponseService({required this.pet}) {
    _initializeResponsePatterns();
    _startResponseMonitoring();
  }

  void _initializeResponsePatterns() {
    // Initialize response patterns for different interaction types
    _responsePatterns[InteractionType.feeding] = [
      'eager_approach', 'happy_anticipation', 'grateful_nuzzle', 'satisfied_settling'
    ];
    
    _responsePatterns[InteractionType.petting] = [
      'lean_into_touch', 'purr_response', 'content_sigh', 'request_more'
    ];
    
    _responsePatterns[InteractionType.playing] = [
      'excited_bounce', 'playful_pounce', 'chase_invitation', 'toy_bring'
    ];
    
    _responsePatterns[InteractionType.cleaning] = [
      'initial_resistance', 'gradual_acceptance', 'grateful_calm', 'refreshed_energy'
    ];
    
    _responsePatterns[InteractionType.brushing] = [
      'cautious_approach', 'relaxed_enjoyment', 'sleepy_contentment', 'bonding_moment'
    ];
    
    _responsePatterns[InteractionType.talking] = [
      'attentive_listening', 'head_tilt_response', 'vocal_reply', 'engaged_focus'
    ];
    
    // Initialize response durations
    _responseDurations['immediate'] = Duration(milliseconds: 200);
    _responseDurations['quick'] = Duration(milliseconds: 800);
    _responseDurations['normal'] = Duration(seconds: 2);
    _responseDurations['extended'] = Duration(seconds: 5);
  }

  void _startResponseMonitoring() {
    _responseTimer = Timer.periodic(
      const Duration(milliseconds: 500),
      (_) => _updateResponseState(),
    );
  }

  /// Main response update loop
  void _updateResponseState() {
    _updateUserEngagement();
    _checkForAnticipatedInteractions();
    _updateContextualAwareness();
  }

  /// Process an interaction and generate appropriate response
  Future<void> processInteraction(InteractionType type, {Map<String, dynamic>? context}) async {
    _lastInteractionTime = DateTime.now();
    _addToRecentActions(type.name);
    
    // Generate immediate response
    final immediateResponse = _generateImmediateResponse(type, context);
    await _executeResponse(immediateResponse, 'immediate');
    
    // Generate follow-up responses based on pet's personality and emotional state
    final followUpResponses = _generateFollowUpResponses(type, context);
    
    for (int i = 0; i < followUpResponses.length; i++) {
      final delay = Duration(milliseconds: 500 + (i * 1000));
      Timer(delay, () async {
        if (followUpResponses[i].isNotEmpty) {
          await _executeResponse(followUpResponses[i], 'normal');
        }
      });
    }
    
    // Update emotional memory with interaction context
    _recordInteractionResponse(type, context);
  }

  /// Generate immediate response to interaction
  String _generateImmediateResponse(InteractionType type, Map<String, dynamic>? context) {
    final responses = _responsePatterns[type] ?? ['generic_acknowledgment'];
    final emotionalState = _analyzeEmotionalState();
    
    // Filter responses based on current emotional state
    final appropriateResponses = _filterResponsesByEmotion(responses, emotionalState);
    
    // Consider personality factors
    final personalityFiltered = _filterResponsesByPersonality(appropriateResponses);
    
    // Avoid repetitive responses
    final variedResponses = _filterForVariety(personalityFiltered);
    
    return variedResponses.isNotEmpty 
        ? variedResponses[math.Random().nextInt(variedResponses.length)]
        : responses.first;
  }

  /// Generate follow-up responses that create a conversation-like flow
  List<String> _generateFollowUpResponses(InteractionType type, Map<String, dynamic>? context) {
    final followUps = <String>[];
    final emotionalState = _analyzeEmotionalState();
    
    switch (type) {
      case InteractionType.feeding:
        if (pet.hunger > 70) {
          followUps.add('very_grateful_response');
        }
        if (emotionalState['trust'] > 60) {
          followUps.add('trusting_approach');
        }
        followUps.add('post_meal_contentment');
        break;
        
      case InteractionType.petting:
        if (pet.emotionalMemory.attachment > 50) {
          followUps.add('bonding_deepening');
        }
        if (pet.emotionalMemory.sensitivity > 60) {
          followUps.add('sensitive_appreciation');
        }
        if (math.Random().nextDouble() < 0.3) {
          followUps.add('request_continue');
        }
        break;
        
      case InteractionType.playing:
        if (pet.energy > 60) {
          followUps.add('continued_playfulness');
        }
        if (pet.emotionalMemory.playfulness > 70) {
          followUps.add('play_escalation');
        }
        followUps.add('play_satisfaction');
        break;
        
      case InteractionType.cleaning:
        if (pet.cleanliness < 30) {
          followUps.add('relief_response');
        }
        followUps.add('post_clean_energy');
        if (emotionalState['trust'] > 70) {
          followUps.add('trusting_gratitude');
        }
        break;
        
      case InteractionType.talking:
        if (pet.emotionalMemory.socialability > 60) {
          followUps.add('social_engagement');
        }
        if (pet.emotionalMemory.personalityExtroversion > 60) {
          followUps.add('vocal_response');
        }
        followUps.add('attentive_listening');
        break;
    }
    
    return followUps;
  }

  /// Execute a response with appropriate timing and effects
  Future<void> _executeResponse(String response, String timing) async {
    if (response.isEmpty) return;
    
    print('🎭 Interactive Response: $response (timing: $timing)');
    
    // Apply response effects to pet
    _applyResponseEffects(response);
    
    // Wait for response duration
    final duration = _responseDurations[timing] ?? Duration(seconds: 1);
    await Future.delayed(duration);
  }

  /// Apply effects of response to pet state
  void _applyResponseEffects(String response) {
    switch (response) {
      case 'eager_approach':
      case 'excited_bounce':
        pet.mood = PetMood.excited;
        pet.energy = (pet.energy - 2).clamp(0, 100);
        break;
        
      case 'grateful_nuzzle':
      case 'bonding_deepening':
        pet.mood = PetMood.loving;
        pet.happiness = (pet.happiness + 3).clamp(0, 100);
        break;
        
      case 'content_sigh':
      case 'satisfied_settling':
        pet.mood = PetMood.happy;
        break;
        
      case 'playful_pounce':
      case 'chase_invitation':
        pet.currentActivity = PetActivity.playing;
        pet.mood = PetMood.excited;
        break;
        
      case 'relaxed_enjoyment':
      case 'sleepy_contentment':
        pet.energy = (pet.energy + 2).clamp(0, 100);
        break;
        
      case 'attentive_listening':
      case 'engaged_focus':
        pet.happiness = (pet.happiness + 1).clamp(0, 100);
        break;
        
      case 'initial_resistance':
        pet.energy = (pet.energy - 1).clamp(0, 100);
        break;
        
      case 'very_grateful_response':
        pet.happiness = (pet.happiness + 5).clamp(0, 100);
        pet.mood = PetMood.loving;
        break;
    }
  }

  /// Filter responses based on emotional state
  List<String> _filterResponsesByEmotion(List<String> responses, Map<String, dynamic> emotional) {
    final filtered = <String>[];
    
    for (final response in responses) {
      bool shouldInclude = true;
      
      // Filter based on mood
      switch (emotional['mood'] as PetMood) {
        case PetMood.sad:
          if (response.contains('excited') || response.contains('bounce')) {
            shouldInclude = false;
          }
          break;
        case PetMood.tired:
          if (response.contains('excited') || response.contains('playful')) {
            shouldInclude = false;
          }
          break;
        case PetMood.excited:
          if (response.contains('sleepy') || response.contains('calm')) {
            shouldInclude = false;
          }
          break;
        default:
          break;
      }
      
      // Filter based on trust level
      if (emotional['trust'] < 30) {
        if (response.contains('eager') || response.contains('approach')) {
          shouldInclude = false;
        }
      }
      
      // Filter based on energy
      if (emotional['energy'] < 20) {
        if (response.contains('bounce') || response.contains('excited')) {
          shouldInclude = false;
        }
      }
      
      if (shouldInclude) {
        filtered.add(response);
      }
    }
    
    return filtered.isNotEmpty ? filtered : responses;
  }

  /// Filter responses based on personality traits
  List<String> _filterResponsesByPersonality(List<String> responses) {
    final filtered = <String>[];
    
    for (final response in responses) {
      bool shouldInclude = true;
      
      // Introverted pets are less likely to have excited responses
      if (pet.emotionalMemory.personalityExtroversion < 40) {
        if (response.contains('excited') || response.contains('vocal')) {
          shouldInclude = math.Random().nextDouble() < 0.3;
        }
      }
      
      // Highly sensitive pets have more nuanced responses
      if (pet.emotionalMemory.sensitivity > 70) {
        if (response.contains('resistance') || response.contains('cautious')) {
          shouldInclude = true; // More likely to show these responses
        }
      }
      
      // Open pets are more likely to engage
      if (pet.emotionalMemory.personalityOpenness > 60) {
        if (response.contains('approach') || response.contains('engagement')) {
          shouldInclude = true;
        }
      }
      
      if (shouldInclude) {
        filtered.add(response);
      }
    }
    
    return filtered.isNotEmpty ? filtered : responses;
  }

  /// Filter responses to avoid repetition
  List<String> _filterForVariety(List<String> responses) {
    final filtered = responses.where(
      (response) => !_recentUserActions.contains(response)
    ).toList();
    
    return filtered.isNotEmpty ? filtered : responses;
  }

  /// Check for anticipated interactions based on context
  void _checkForAnticipatedInteractions() {
    if (_isAnticipatingInteraction) return;
    
    final timeSinceLastInteraction = DateTime.now().difference(_lastInteractionTime);
    
    // Anticipate feeding if hungry
    if (pet.hunger > 70 && timeSinceLastInteraction.inMinutes > 5) {
      _startAnticipation('feeding', 'hunger_anticipation');
    }
    
    // Anticipate play if energetic and bored
    if (pet.energy > 70 && pet.happiness < 60 && timeSinceLastInteraction.inMinutes > 10) {
      _startAnticipation('playing', 'play_anticipation');
    }
    
    // Anticipate attention if attachment is high
    if (pet.emotionalMemory.attachment > 80 && timeSinceLastInteraction.inMinutes > 3) {
      _startAnticipation('petting', 'attention_anticipation');
    }
  }

  /// Start anticipating a specific interaction
  void _startAnticipation(String interactionType, String anticipationBehavior) {
    _isAnticipatingInteraction = true;
    _anticipatedInteraction = interactionType;
    
    print('🔮 Anticipating: $interactionType');
    
    // Show anticipation behavior
    _showAnticipationBehavior(anticipationBehavior);
    
    // Stop anticipation after a timeout
    _anticipationTimer = Timer(Duration(minutes: 2), () {
      _stopAnticipation();
    });
  }

  void _showAnticipationBehavior(String behavior) {
    switch (behavior) {
      case 'hunger_anticipation':
        pet.currentActivity = PetActivity.idle;
        // Pet might look toward food area or show hungry behaviors
        break;
      case 'play_anticipation':
        pet.mood = PetMood.excited;
        pet.currentActivity = PetActivity.playing;
        break;
      case 'attention_anticipation':
        pet.currentActivity = PetActivity.idle;
        // Pet might approach user or show attention-seeking behaviors
        break;
    }
  }

  void _stopAnticipation() {
    _isAnticipatingInteraction = false;
    _anticipatedInteraction = '';
    _anticipationTimer?.cancel();
  }

  /// Update user engagement level based on interaction patterns
  void _updateUserEngagement() {
    final timeSinceLastInteraction = DateTime.now().difference(_lastInteractionTime);
    
    if (timeSinceLastInteraction.inMinutes < 2) {
      _userEngagementLevel = (_userEngagementLevel + 0.1).clamp(0.0, 1.0);
    } else if (timeSinceLastInteraction.inMinutes > 10) {
      _userEngagementLevel = (_userEngagementLevel - 0.05).clamp(0.0, 1.0);
    }
  }

  /// Update contextual awareness of user behavior
  void _updateContextualAwareness() {
    // Analyze recent user actions to understand context
    if (_recentUserActions.isNotEmpty) {
      final recentAction = _recentUserActions.last;
      
      if (recentAction.contains('feeding') || recentAction.contains('food')) {
        _currentUserContext = 'caring';
      } else if (recentAction.contains('playing') || recentAction.contains('toy')) {
        _currentUserContext = 'playful';
      } else if (recentAction.contains('petting') || recentAction.contains('brushing')) {
        _currentUserContext = 'affectionate';
      } else {
        _currentUserContext = 'neutral';
      }
    }
  }

  /// Add action to recent actions list
  void _addToRecentActions(String action) {
    _recentUserActions.add(action);
    if (_recentUserActions.length > 5) {
      _recentUserActions.removeAt(0);
    }
  }

  /// Record interaction response in emotional memory
  void _recordInteractionResponse(InteractionType type, Map<String, dynamic>? context) {
    final emotionalContext = _determineEmotionalContext(type, context);
    final intensity = _calculateResponseIntensity(type);
    
    pet.emotionalMemory.recordInteraction(
      type,
      emotionalContext,
      intensity: intensity,
      notes: 'Interactive response with context: $_currentUserContext',
    );
  }

  EmotionalContext _determineEmotionalContext(InteractionType type, Map<String, dynamic>? context) {
    // Determine emotional context based on pet's current state and interaction
    if (pet.emotionalMemory.trustLevel > 70) {
      return EmotionalContext.bonding;
    } else if (pet.happiness > 80) {
      return EmotionalContext.joyful;
    } else if (pet.mood == PetMood.excited) {
      return EmotionalContext.playful;
    } else if (pet.emotionalMemory.traumaLevel > 30) {
      return EmotionalContext.cautious;
    } else {
      return EmotionalContext.positive;
    }
  }

  double _calculateResponseIntensity(InteractionType type) {
    double baseIntensity = 0.5;
    
    // Adjust based on pet's emotional state
    if (pet.emotionalMemory.sensitivity > 60) {
      baseIntensity += 0.2;
    }
    
    if (pet.emotionalMemory.attachment > 70) {
      baseIntensity += 0.15;
    }
    
    // Adjust based on interaction type
    switch (type) {
      case InteractionType.feeding:
        if (pet.hunger > 70) baseIntensity += 0.3;
        break;
      case InteractionType.playing:
        if (pet.energy > 60) baseIntensity += 0.2;
        break;
      case InteractionType.petting:
        if (pet.emotionalMemory.attachment > 50) baseIntensity += 0.25;
        break;
      default:
        break;
    }
    
    return baseIntensity.clamp(0.1, 1.0);
  }

  Map<String, dynamic> _analyzeEmotionalState() {
    return {
      'mood': pet.mood,
      'energy': pet.energy,
      'happiness': pet.happiness,
      'trust': pet.emotionalMemory.trustLevel,
      'attachment': pet.emotionalMemory.attachment,
      'sensitivity': pet.emotionalMemory.sensitivity,
    };
  }

  // Getters for current state
  bool get isAnticipatingInteraction => _isAnticipatingInteraction;
  String get anticipatedInteraction => _anticipatedInteraction;
  double get userEngagementLevel => _userEngagementLevel;
  String get currentUserContext => _currentUserContext;

  void dispose() {
    _responseTimer?.cancel();
    _anticipationTimer?.cancel();
  }
}