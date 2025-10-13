import 'dart:math' as math;
import 'dart:async';
import '../models/pet.dart';
import '../models/emotional_memory.dart';

/// Advanced AI response engine that makes pets more realistic and responsive
class AIResponseEngine {
  final Pet pet;
  Timer? _contextualResponseTimer;
  Timer? _proactiveActionTimer;
  DateTime _lastUserInteraction = DateTime.now();
  String _currentContext = 'idle';
  
  // Response patterns based on personality and emotional state
  final Map<String, List<String>> _responsePatterns = {};
  final List<String> _recentResponses = [];
  
  AIResponseEngine({required this.pet}) {
    _initializeResponsePatterns();
    _startContextualMonitoring();
    _startProactiveActions();
  }

  void _initializeResponsePatterns() {
    // Initialize response patterns based on pet type and personality
    _responsePatterns['greeting'] = _getGreetingPatterns();
    _responsePatterns['attention_seeking'] = _getAttentionSeekingPatterns();
    _responsePatterns['comfort_seeking'] = _getComfortSeekingPatterns();
    _responsePatterns['playful'] = _getPlayfulPatterns();
    _responsePatterns['tired'] = _getTiredPatterns();
  }

  List<String> _getGreetingPatterns() {
    switch (pet.type) {
      case PetType.dog:
        return ['excited_tail_wag', 'happy_bark', 'jump_greeting', 'spin_circle'];
      case PetType.cat:
        return ['head_rub', 'purr_approach', 'slow_blink', 'figure_eight'];
      case PetType.bird:
        return ['wing_flutter', 'chirp_sequence', 'head_bob', 'perch_hop'];
      default:
        return ['approach_happy', 'gentle_nuzzle', 'excited_bounce'];
    }
  }

  List<String> _getAttentionSeekingPatterns() {
    final patterns = <String>[];
    
    // Base patterns for all pets
    patterns.addAll(['look_at_user', 'approach_slowly', 'gentle_nudge']);
    
    // Personality-influenced patterns
    if (pet.emotionalMemory.personalityExtroversion > 60) {
      patterns.addAll(['direct_approach', 'vocal_request', 'persistent_following']);
    } else {
      patterns.addAll(['subtle_positioning', 'quiet_waiting', 'gentle_presence']);
    }
    
    // Attachment-influenced patterns
    if (pet.emotionalMemory.attachment > 70) {
      patterns.addAll(['stay_close', 'frequent_checking', 'separation_anxiety']);
    }
    
    return patterns;
  }

  List<String> _getComfortSeekingPatterns() {
    final patterns = <String>[];
    
    if (pet.emotionalMemory.traumaLevel > 30) {
      patterns.addAll(['seek_hiding_spot', 'cautious_approach', 'need_reassurance']);
    }
    
    if (pet.emotionalMemory.sensitivity > 60) {
      patterns.addAll(['gentle_touch_seeking', 'quiet_companionship', 'soft_vocalizations']);
    }
    
    patterns.addAll(['curl_up_nearby', 'lean_against', 'request_petting']);
    return patterns;
  }

  List<String> _getPlayfulPatterns() {
    final patterns = <String>[];
    
    switch (pet.type) {
      case PetType.dog:
        patterns.addAll(['play_bow', 'fetch_invitation', 'zoomies', 'toy_bring']);
        break;
      case PetType.cat:
        patterns.addAll(['pounce_stance', 'chase_invitation', 'batting_play', 'hide_and_seek']);
        break;
      case PetType.bird:
        patterns.addAll(['acrobatic_flight', 'toy_manipulation', 'mimic_sounds', 'dance_display']);
        break;
      default:
        patterns.addAll(['playful_bounce', 'chase_game', 'toy_interaction']);
    }
    
    return patterns;
  }

  List<String> _getTiredPatterns() {
    return [
      'slow_movements', 'seek_resting_spot', 'yawn_sequence', 
      'gradual_settling', 'drowsy_blinks', 'comfort_positioning'
    ];
  }

  /// Start monitoring contextual responses
  void _startContextualMonitoring() {
    _contextualResponseTimer = Timer.periodic(
      const Duration(seconds: 2),
      (_) => _evaluateContextualResponse(),
    );
  }

  /// Start proactive actions based on AI decision making
  void _startProactiveActions() {
    _proactiveActionTimer = Timer.periodic(
      const Duration(seconds: 8),
      (_) => _evaluateProactiveAction(),
    );
  }

  /// Evaluate and trigger contextual responses
  void _evaluateContextualResponse() {
    final timeSinceInteraction = DateTime.now().difference(_lastUserInteraction);
    final currentEmotionalState = _analyzeEmotionalState();
    
    // Determine if pet should respond contextually
    if (_shouldRespondContextually(timeSinceInteraction, currentEmotionalState)) {
      final response = _selectContextualResponse(currentEmotionalState);
      _executeResponse(response);
    }
  }

  /// Evaluate and trigger proactive actions
  void _evaluateProactiveAction() {
    final emotionalState = _analyzeEmotionalState();
    final environmentalFactors = _analyzeEnvironment();
    
    if (_shouldTakeProactiveAction(emotionalState, environmentalFactors)) {
      final action = _selectProactiveAction(emotionalState, environmentalFactors);
      _executeProactiveAction(action);
    }
  }

  /// Analyze current emotional state for AI decision making
  Map<String, dynamic> _analyzeEmotionalState() {
    return {
      'mood': pet.mood,
      'energy': pet.energy,
      'happiness': pet.happiness,
      'trust_level': pet.emotionalMemory.trustLevel,
      'bond_strength': pet.emotionalMemory.bondStrength,
      'trauma_level': pet.emotionalMemory.traumaLevel,
      'attachment': pet.emotionalMemory.attachment,
      'playfulness': pet.emotionalMemory.playfulness,
      'curiosity': pet.emotionalMemory.curiosity,
      'sensitivity': pet.emotionalMemory.sensitivity,
      'confidence': pet.emotionalMemory.confidenceLevel,
      'time_since_interaction': DateTime.now().difference(_lastUserInteraction).inMinutes,
    };
  }

  /// Analyze environmental factors
  Map<String, dynamic> _analyzeEnvironment() {
    return {
      'habitat_condition': pet.habitat?.cleanliness ?? 50,
      'has_food': pet.habitat?.hasFood ?? false,
      'has_water': pet.habitat?.hasWater ?? false,
      'time_of_day': DateTime.now().hour,
      'current_activity': pet.currentActivity,
      'has_toys': pet.currentToy != null,
      'habitat_comfort': pet.habitat?.comfort ?? 50,
    };
  }

  /// Determine if pet should respond contextually
  bool _shouldRespondContextually(Duration timeSinceInteraction, Map<String, dynamic> state) {
    // Base probability influenced by personality and emotional state
    double baseProbability = 0.3;
    
    // Extroverted pets respond more frequently
    if (pet.emotionalMemory.personalityExtroversion > 60) {
      baseProbability += 0.2;
    }
    
    // High attachment increases response frequency
    if (state['attachment'] > 70) {
      baseProbability += 0.15;
    }
    
    // Low confidence decreases response frequency
    if (state['confidence'] < 40) {
      baseProbability -= 0.1;
    }
    
    // Time since interaction affects probability
    final minutesSinceInteraction = timeSinceInteraction.inMinutes;
    if (minutesSinceInteraction > 5) {
      baseProbability += 0.1;
    }
    if (minutesSinceInteraction > 15) {
      baseProbability += 0.2;
    }
    
    return math.Random().nextDouble() < baseProbability.clamp(0.1, 0.8);
  }

  /// Select appropriate contextual response
  String _selectContextualResponse(Map<String, dynamic> state) {
    final responses = <String>[];
    
    // Mood-based responses
    switch (state['mood'] as PetMood) {
      case PetMood.happy:
        responses.addAll(_responsePatterns['playful'] ?? []);
        break;
      case PetMood.sad:
        responses.addAll(_responsePatterns['comfort_seeking'] ?? []);
        break;
      case PetMood.excited:
        responses.addAll(_responsePatterns['attention_seeking'] ?? []);
        break;
      case PetMood.tired:
        responses.addAll(_responsePatterns['tired'] ?? []);
        break;
      case PetMood.loving:
        responses.addAll(_responsePatterns['greeting'] ?? []);
        break;
      default:
        responses.addAll(_responsePatterns['attention_seeking'] ?? []);
    }
    
    // Filter out recently used responses to avoid repetition
    final availableResponses = responses.where(
      (response) => !_recentResponses.contains(response)
    ).toList();
    
    if (availableResponses.isEmpty) {
      _recentResponses.clear(); // Reset if all responses used
      return responses.isNotEmpty ? responses.first : 'look_at_user';
    }
    
    return availableResponses[math.Random().nextInt(availableResponses.length)];
  }

  /// Determine if pet should take proactive action
  bool _shouldTakeProactiveAction(Map<String, dynamic> emotional, Map<String, dynamic> environmental) {
    double probability = 0.2;
    
    // High curiosity increases proactive behavior
    if (emotional['curiosity'] > 60) {
      probability += 0.15;
    }
    
    // High playfulness increases proactive behavior
    if (emotional['playfulness'] > 70) {
      probability += 0.2;
    }
    
    // Low energy decreases proactive behavior
    if (emotional['energy'] < 30) {
      probability -= 0.15;
    }
    
    // Environmental factors
    if (!environmental['has_food'] || !environmental['has_water']) {
      probability += 0.3; // More likely to seek resources
    }
    
    if (environmental['habitat_condition'] < 50) {
      probability += 0.1; // May seek cleaner area
    }
    
    return math.Random().nextDouble() < probability.clamp(0.05, 0.6);
  }

  /// Select proactive action based on state
  String _selectProactiveAction(Map<String, dynamic> emotional, Map<String, dynamic> environmental) {
    final actions = <String>[];
    
    // Need-based actions
    if (!environmental['has_food']) {
      actions.add('seek_food');
    }
    if (!environmental['has_water']) {
      actions.add('seek_water');
    }
    
    // Mood-based actions
    if (emotional['playfulness'] > 60 && emotional['energy'] > 40) {
      actions.addAll(['initiate_play', 'explore_environment', 'investigate_toys']);
    }
    
    if (emotional['curiosity'] > 70) {
      actions.addAll(['explore_new_area', 'investigate_objects', 'sniff_around']);
    }
    
    if (emotional['attachment'] > 60) {
      actions.addAll(['follow_user', 'stay_close', 'check_on_user']);
    }
    
    // Time-based actions
    final hour = environmental['time_of_day'] as int;
    if (hour >= 22 || hour <= 6) {
      actions.addAll(['seek_sleeping_spot', 'settle_down', 'yawn']);
    } else if (hour >= 6 && hour <= 10) {
      actions.addAll(['morning_stretch', 'seek_breakfast', 'energetic_greeting']);
    }
    
    return actions.isNotEmpty 
        ? actions[math.Random().nextInt(actions.length)]
        : 'idle_exploration';
  }

  /// Execute contextual response
  void _executeResponse(String response) {
    _recentResponses.add(response);
    if (_recentResponses.length > 5) {
      _recentResponses.removeAt(0);
    }
    
    print('🤖 AI Response: $response');
    
    // Trigger appropriate pet behavior based on response
    switch (response) {
      case 'excited_tail_wag':
      case 'happy_bark':
        pet.mood = PetMood.excited;
        pet.happiness = (pet.happiness + 5).clamp(0, 100);
        break;
      case 'approach_slowly':
      case 'gentle_nudge':
        pet.currentActivity = PetActivity.walking;
        break;
      case 'seek_hiding_spot':
        if (pet.emotionalMemory.traumaLevel > 50) {
          pet.mood = PetMood.sad;
        }
        break;
      case 'play_bow':
      case 'pounce_stance':
        pet.currentActivity = PetActivity.playing;
        pet.mood = PetMood.excited;
        break;
    }
    
    // Record emotional memory of AI-initiated interaction
    pet.emotionalMemory.recordInteraction(
      InteractionType.playing,
      EmotionalContext.positive,
      intensity: 0.3,
      notes: 'AI-initiated response: $response',
    );
  }

  /// Execute proactive action
  void _executeProactiveAction(String action) {
    print('🎯 Proactive Action: $action');
    
    switch (action) {
      case 'seek_food':
        pet.currentActivity = PetActivity.eating;
        pet.hunger = (pet.hunger + 10).clamp(0, 100);
        break;
      case 'seek_water':
        pet.addWaterToHabitat();
        break;
      case 'initiate_play':
        pet.play();
        break;
      case 'explore_environment':
        pet.currentActivity = PetActivity.walking;
        pet.curiosity = (pet.emotionalMemory.curiosity + 2).clamp(0, 100);
        break;
      case 'seek_sleeping_spot':
        pet.currentActivity = PetActivity.sleeping;
        break;
      case 'morning_stretch':
        pet.energy = (pet.energy + 5).clamp(0, 100);
        pet.mood = PetMood.happy;
        break;
    }
  }

  /// Update user interaction timestamp
  void recordUserInteraction(InteractionType type) {
    _lastUserInteraction = DateTime.now();
    _currentContext = type.name;
    
    // Adjust AI responsiveness based on interaction type
    if (type == InteractionType.playing || type == InteractionType.petting) {
      // Increase responsiveness after positive interactions
      _startContextualMonitoring();
    }
  }

  /// Get AI-suggested next action for the user
  String? suggestUserAction() {
    final state = _analyzeEmotionalState();
    final environment = _analyzeEnvironment();
    
    // Suggest actions based on pet's current needs and personality
    if (state['happiness'] < 40) {
      if (pet.emotionalMemory.personalityExtroversion > 60) {
        return 'Your pet seems down and would love some social interaction - try talking or playing!';
      } else {
        return 'Your pet needs gentle comfort - try some quiet petting or gentle touches.';
      }
    }
    
    if (state['energy'] < 30 && state['mood'] != PetMood.tired) {
      return 'Your pet is getting tired but fighting it - help them find a cozy spot to rest.';
    }
    
    if (state['playfulness'] > 70 && state['energy'] > 50) {
      return 'Your pet is feeling very playful - this would be a great time for games or toys!';
    }
    
    if (state['curiosity'] > 70) {
      return 'Your pet is very curious today - try introducing something new or rearranging their habitat!';
    }
    
    if (!environment['has_food'] || !environment['has_water']) {
      return 'Your pet noticed their food or water is running low - they might appreciate a refill.';
    }
    
    return null; // No specific suggestion
  }

  void dispose() {
    _contextualResponseTimer?.cancel();
    _proactiveActionTimer?.cancel();
  }
}