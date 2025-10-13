

/// Represents different types of interactions with the pet
enum InteractionType {
  feeding,
  cleaning,
  brushing,
  playing,
  petting,
  training,
  scolding,
  ignoring,
  medicating,
  bathing,
  cuddling,
  exercising,
  talking,
  singing,
  dancing,
  surpriseGift,
  roughPlay,
  gentleTouch,
  massaging,
  storytelling,
  musicPlaying,
  photoTaking,
  trickReward,
  comforting,
  celebrating,
}

/// Represents the emotional context of an interaction
enum EmotionalContext {
  positive,     // Pet was happy, interaction went well
  neutral,      // Normal interaction, no strong emotion
  negative,     // Pet was stressed, sick, or resistant
  bonding,      // Special bonding moment
  stressful,    // Necessary but unpleasant (medicine, bath when dirty)
  joyful,       // Overwhelming happiness and excitement
  melancholy,   // Sad but not traumatic
  anxious,      // Worried or nervous
  playful,      // Fun and energetic
  curious,      // Interested and exploring
  protective,   // Pet feels safe and secure
  lonely,       // Pet feels isolated or abandoned
  grateful,     // Pet appreciates special care
  mischievous,  // Pet is being playfully naughty
  nostalgic,    // Reminiscing about past good times
}

/// Individual memory of an interaction
class InteractionMemory {
  final InteractionType type;
  final EmotionalContext context;
  final DateTime timestamp;
  final double intensityLevel; // 0.0 to 1.0 - how memorable was this?
  final String? notes; // Optional context notes

  InteractionMemory({
    required this.type,
    required this.context,
    required this.timestamp,
    this.intensityLevel = 0.5,
    this.notes,
  });

  /// How fresh is this memory? Newer memories have more weight
  double get recencyWeight {
    final daysSince = DateTime.now().difference(timestamp).inDays;
    if (daysSince == 0) return 1.0;
    if (daysSince <= 3) return 0.8;
    if (daysSince <= 7) return 0.6;
    if (daysSince <= 14) return 0.4;
    if (daysSince <= 30) return 0.2;
    return 0.1; // Very old memories fade but don't disappear completely
  }

  /// Overall emotional weight of this memory
  double get emotionalWeight {
    final contextMultiplier = switch (context) {
      EmotionalContext.bonding => 1.5,
      EmotionalContext.joyful => 1.8,
      EmotionalContext.grateful => 1.4,
      EmotionalContext.positive => 1.0,
      EmotionalContext.playful => 1.1,
      EmotionalContext.curious => 0.9,
      EmotionalContext.protective => 1.2,
      EmotionalContext.nostalgic => 1.0,
      EmotionalContext.mischievous => 0.8,
      EmotionalContext.neutral => 0.5,
      EmotionalContext.melancholy => -0.3,
      EmotionalContext.anxious => -0.8,
      EmotionalContext.lonely => -0.9,
      EmotionalContext.negative => -1.0,
      EmotionalContext.stressful => -0.7,
    };
    
    return intensityLevel * contextMultiplier * recencyWeight;
  }

  Map<String, dynamic> toJson() => {
    'type': type.name,
    'context': context.name,
    'timestamp': timestamp.toIso8601String(),
    'intensityLevel': intensityLevel,
    'notes': notes,
  };

  factory InteractionMemory.fromJson(Map<String, dynamic> json) => InteractionMemory(
    type: InteractionType.values.byName(json['type']),
    context: EmotionalContext.values.byName(json['context']),
    timestamp: DateTime.parse(json['timestamp']),
    intensityLevel: json['intensityLevel']?.toDouble() ?? 0.5,
    notes: json['notes'],
  );
}

/// Tracks behavioral patterns and preferences
class BehavioralPattern {
  final InteractionType preferredInteraction;
  final double preferenceStrength; // 0.0 to 1.0
  final List<String> associatedBehaviors;
  final DateTime lastObserved;

  BehavioralPattern({
    required this.preferredInteraction,
    required this.preferenceStrength,
    required this.associatedBehaviors,
    required this.lastObserved,
  });

  Map<String, dynamic> toJson() => {
    'preferredInteraction': preferredInteraction.name,
    'preferenceStrength': preferenceStrength,
    'associatedBehaviors': associatedBehaviors,
    'lastObserved': lastObserved.toIso8601String(),
  };

  factory BehavioralPattern.fromJson(Map<String, dynamic> json) => BehavioralPattern(
    preferredInteraction: InteractionType.values.byName(json['preferredInteraction']),
    preferenceStrength: json['preferenceStrength']?.toDouble() ?? 0.5,
    associatedBehaviors: List<String>.from(json['associatedBehaviors'] ?? []),
    lastObserved: DateTime.parse(json['lastObserved']),
  );
}

/// Comprehensive emotional memory system for the pet
class EmotionalMemory {
  final List<InteractionMemory> _memories = [];
  final Map<InteractionType, double> _interactionPreferences = {};
  final List<BehavioralPattern> _behavioralPatterns = [];
  
  // Trust and bond metrics
  double _trustLevel = 50.0; // 0-100, starts neutral
  double _bondStrength = 0.0; // 0-100, grows over time
  double _traumaLevel = 0.0; // 0-100, negative experiences
  
  // Advanced emotional states
  double _confidenceLevel = 50.0; // How secure the pet feels
  double _playfulness = 50.0; // How much the pet enjoys fun activities
  double _curiosity = 50.0; // How interested the pet is in new things
  double _attachment = 0.0; // How attached to owner (can cause separation anxiety)
  double _independence = 50.0; // How self-reliant the pet is
  double _socialability = 50.0; // How much the pet enjoys social interaction
  double _sensitivity = 50.0; // How emotionally sensitive the pet is
  double _resilience = 50.0; // How quickly the pet recovers from negative experiences
  
  // Behavioral adaptation
  bool _isAdaptingToRoutine = false;
  DateTime? _lastTraumaticEvent;
  Map<String, double> _timePreferences = {}; // Hour of day preferences
  
  // Personality traits that affect emotional responses
  late final double _personalityExtroversion; // 0-100, affects social needs
  late final double _personalityNeuroticism; // 0-100, affects stress sensitivity
  late final double _personalityOpenness; // 0-100, affects curiosity and adaptability
  late final double _personalityAgreeableness; // 0-100, affects cooperation
  late final double _personalityConscientiousness; // 0-100, affects routine preferences
  
  // Current emotional state modifiers
  String _currentMoodDescription = 'content';
  
  // Special emotional bonds
  final List<String> _favoriteMemories = []; // Descriptions of special bonding moments
  final List<String> _fearTriggers = []; // Things that make the pet anxious
  
  // Constructors
  EmotionalMemory() {
    // Initialize random personality traits (0-100 scale)
    _personalityExtroversion = 30 + (DateTime.now().millisecondsSinceEpoch % 40).toDouble(); // 30-70 range
    _personalityNeuroticism = 20 + (DateTime.now().microsecondsSinceEpoch % 60).toDouble(); // 20-80 range
    _personalityOpenness = 25 + (DateTime.now().second % 50).toDouble(); // 25-75 range
    _personalityAgreeableness = 30 + (DateTime.now().minute % 40).toDouble(); // 30-70 range
    _personalityConscientiousness = 35 + (DateTime.now().hour % 30).toDouble(); // 35-65 range
    
    // Set initial emotional states based on personality
    _confidenceLevel = _personalityExtroversion;
    _playfulness = (_personalityExtroversion + _personalityOpenness) / 2;
    _curiosity = _personalityOpenness;
    _sensitivity = _personalityNeuroticism;
    _resilience = 100 - _personalityNeuroticism;
    _socialability = _personalityExtroversion;
    
    print('🧬 PET PERSONALITY: Extroversion: ${_personalityExtroversion.toStringAsFixed(1)}, Neuroticism: ${_personalityNeuroticism.toStringAsFixed(1)}, Openness: ${_personalityOpenness.toStringAsFixed(1)}');
  }

  // Getters
  List<InteractionMemory> get memories => List.unmodifiable(_memories);
  double get trustLevel => _trustLevel;
  double get bondStrength => _bondStrength;
  double get traumaLevel => _traumaLevel;
  bool get isAdaptingToRoutine => _isAdaptingToRoutine;
  Map<InteractionType, double> get interactionPreferences => Map.unmodifiable(_interactionPreferences);
  List<BehavioralPattern> get behavioralPatterns => List.unmodifiable(_behavioralPatterns);
  
  // Advanced emotional state getters
  double get confidenceLevel => _confidenceLevel;
  double get playfulness => _playfulness;
  double get curiosity => _curiosity;
  double get attachment => _attachment;
  double get independence => _independence;
  double get socialability => _socialability;
  double get sensitivity => _sensitivity;
  double get resilience => _resilience;
  String get currentMoodDescription => _currentMoodDescription;
  List<String> get favoriteMemories => List.unmodifiable(_favoriteMemories);
  List<String> get fearTriggers => List.unmodifiable(_fearTriggers);
  
  // Personality getters
  double get personalityExtroversion => _personalityExtroversion;
  double get personalityNeuroticism => _personalityNeuroticism;
  double get personalityOpenness => _personalityOpenness;
  double get personalityAgreeableness => _personalityAgreeableness;
  double get personalityConscientiousness => _personalityConscientiousness;

  /// Add a new interaction memory
  void recordInteraction(InteractionType type, EmotionalContext context, {double intensity = 0.5, String? notes}) {
    final memory = InteractionMemory(
      type: type,
      context: context,
      timestamp: DateTime.now(),
      intensityLevel: intensity,
      notes: notes,
    );
    
    _memories.add(memory);
    _updateEmotionalState(memory);
    _updatePreferences(type, context, intensity);
    _pruneOldMemories();
    
    print('🧠 Recorded ${type.name} interaction with ${context.name} context (intensity: ${intensity.toStringAsFixed(1)})');
  }

  /// Update overall emotional state based on new memory
  void _updateEmotionalState(InteractionMemory memory) {
    final baseImpact = memory.emotionalWeight * 2; // Scale impact
    
    // Apply personality modifiers to emotional impact
    final sensitivityMultiplier = 1.0 + (_personalityNeuroticism / 100.0); // More sensitive = stronger reactions
    final resilienceMultiplier = 1.0 + ((100 - _personalityNeuroticism) / 200.0); // More resilient = faster recovery
    final emotionalImpact = baseImpact * sensitivityMultiplier;
    
    // Update trust level with personality influence
    if (memory.context == EmotionalContext.positive || memory.context == EmotionalContext.bonding || memory.context == EmotionalContext.joyful) {
      final trustGain = emotionalImpact * (1.0 + _personalityAgreeableness / 200.0);
      _trustLevel = (_trustLevel + trustGain).clamp(0.0, 100.0);
      _confidenceLevel = (_confidenceLevel + trustGain * 0.5).clamp(0.0, 100.0);
    } else if (memory.context == EmotionalContext.negative || memory.context == EmotionalContext.stressful || memory.context == EmotionalContext.anxious) {
      final trustLoss = -emotionalImpact.abs();
      _trustLevel = (_trustLevel + trustLoss * resilienceMultiplier).clamp(0.0, 100.0);
      _traumaLevel = (_traumaLevel - trustLoss * 0.5).clamp(0.0, 100.0);
      _confidenceLevel = (_confidenceLevel + trustLoss * 0.3).clamp(0.0, 100.0);
      _lastTraumaticEvent = memory.timestamp;
      
      // Add to fear triggers if it's a strongly negative experience
      if (memory.intensityLevel > 0.7 && !_fearTriggers.contains(memory.type.name)) {
        _fearTriggers.add(memory.type.name);
      }
    }
    
    // Update bond strength and attachment with personality influence
    if (memory.context == EmotionalContext.bonding || memory.context == EmotionalContext.joyful || memory.context == EmotionalContext.grateful) {
      final bondGain = emotionalImpact * 1.5 * (1.0 + _personalityExtroversion / 200.0);
      _bondStrength = (_bondStrength + bondGain).clamp(0.0, 100.0);
      _attachment = (_attachment + bondGain * 0.8).clamp(0.0, 100.0);
      
      // Create favorite memories for special bonding moments
      if (memory.intensityLevel > 0.7) {
        final memoryDescription = '${memory.type.name} moment - ${_getEmotionalDescription(memory.context)}';
        if (!_favoriteMemories.contains(memoryDescription)) {
          _favoriteMemories.add(memoryDescription);
          if (_favoriteMemories.length > 10) _favoriteMemories.removeAt(0); // Keep only recent favorites
        }
      }
    } else if (memory.context == EmotionalContext.positive || memory.context == EmotionalContext.playful) {
      final bondGain = emotionalImpact * 0.5;
      _bondStrength = (_bondStrength + bondGain).clamp(0.0, 100.0);
      _attachment = (_attachment + bondGain * 0.3).clamp(0.0, 100.0);
    }
    
    // Update specific emotional traits based on interaction type
    _updateSpecificTraits(memory);
    
    // Trauma naturally heals over time (influenced by resilience)
    if (_lastTraumaticEvent != null) {
      final daysSinceTrauma = DateTime.now().difference(_lastTraumaticEvent!).inDays;
      if (daysSinceTrauma > 0) {
        final healingRate = 0.02 + (_resilience / 5000.0); // Higher resilience = faster healing
        _traumaLevel = (_traumaLevel * (1.0 - (daysSinceTrauma * healingRate))).clamp(0.0, 100.0);
      }
    }
    
    // Update mood description
    _updateCurrentMood();
  }
  
  /// Update specific emotional traits based on interaction type
  void _updateSpecificTraits(InteractionMemory memory) {
    final impact = memory.emotionalWeight * 0.5; // Smaller impact for traits
    
    switch (memory.type) {
      case InteractionType.playing:
      case InteractionType.dancing:
      case InteractionType.roughPlay:
        _playfulness = (_playfulness + impact).clamp(0.0, 100.0);
        break;
      case InteractionType.talking:
      case InteractionType.storytelling:
      case InteractionType.singing:
        _socialability = (_socialability + impact).clamp(0.0, 100.0);
        break;
      case InteractionType.surpriseGift:
      case InteractionType.celebrating:
        _curiosity = (_curiosity + impact).clamp(0.0, 100.0);
        _playfulness = (_playfulness + impact * 0.5).clamp(0.0, 100.0);
        break;
      case InteractionType.gentleTouch:
      case InteractionType.massaging:
      case InteractionType.cuddling:
        _sensitivity = (_sensitivity + impact * 0.3).clamp(0.0, 100.0);
        _attachment = (_attachment + impact * 0.8).clamp(0.0, 100.0);
        break;
      case InteractionType.training:
      case InteractionType.trickReward:
        _confidenceLevel = (_confidenceLevel + impact).clamp(0.0, 100.0);
        break;
      case InteractionType.comforting:
        _resilience = (_resilience + impact * 0.3).clamp(0.0, 100.0);
        break;
      case InteractionType.ignoring:
        _independence = (_independence + impact).clamp(0.0, 100.0);
        _attachment = (_attachment - impact * 0.5).clamp(0.0, 100.0);
        break;
      default:
        break;
    }
  }

  /// Update current mood description based on emotional state
  void _updateCurrentMood() {
    final overallHappiness = (_trustLevel + _bondStrength + _confidenceLevel) / 3;
    final stress = (_traumaLevel + _sensitivity) / 2;
    
    if (overallHappiness > 80 && stress < 20) {
      _currentMoodDescription = _bondStrength > 70 ? 'blissfully devoted' : 'radiantly happy';
    } else if (overallHappiness > 70) {
      _currentMoodDescription = _playfulness > 60 ? 'cheerfully playful' : 'contentedly peaceful';
    } else if (overallHappiness > 60) {
      _currentMoodDescription = _socialability > 60 ? 'sociably content' : 'quietly satisfied';
    } else if (overallHappiness > 40) {
      _currentMoodDescription = stress > 50 ? 'cautiously hopeful' : 'moderately content';
    } else if (overallHappiness > 30) {
      _currentMoodDescription = _traumaLevel > 40 ? 'hesitantly wary' : 'somewhat melancholy';
    } else if (stress > 60) {
      _currentMoodDescription = _traumaLevel > 70 ? 'deeply troubled' : 'anxiously distressed';
    } else {
      _currentMoodDescription = _independence > 60 ? 'distantly aloof' : 'sadly withdrawn';
    }
    
    // Update emotional volatility based on recent mood changes
        // Emotional state affects mood description
    // Higher stress levels from trauma and low trust affect overall emotional state
  }
  
  /// Get emotional description for context
  String _getEmotionalDescription(EmotionalContext context) {
    return switch (context) {
      EmotionalContext.joyful => 'pure joy',
      EmotionalContext.bonding => 'deep connection',
      EmotionalContext.grateful => 'heartfelt gratitude',
      EmotionalContext.playful => 'carefree fun',
      EmotionalContext.curious => 'fascinated wonder',
      EmotionalContext.protective => 'safe security',
      EmotionalContext.nostalgic => 'warm memories',
      EmotionalContext.mischievous => 'playful naughtiness',
      EmotionalContext.positive => 'simple happiness',
      EmotionalContext.neutral => 'calm acceptance',
      EmotionalContext.melancholy => 'gentle sadness',
      EmotionalContext.anxious => 'worried uncertainty',
      EmotionalContext.lonely => 'aching loneliness',
      EmotionalContext.negative => 'uncomfortable distress',
      EmotionalContext.stressful => 'overwhelming stress',
    };
  }
  
  /// Update interaction preferences based on experience
  void _updatePreferences(InteractionType type, EmotionalContext context, double intensity) {
    final currentPreference = _interactionPreferences[type] ?? 0.0;
    final preferenceChange = switch (context) {
      EmotionalContext.bonding => intensity * 3.0,
      EmotionalContext.joyful => intensity * 3.5,
      EmotionalContext.grateful => intensity * 2.5,
      EmotionalContext.positive => intensity * 1.5,
      EmotionalContext.playful => intensity * 1.8,
      EmotionalContext.curious => intensity * 1.2,
      EmotionalContext.protective => intensity * 1.5,
      EmotionalContext.nostalgic => intensity * 1.0,
      EmotionalContext.mischievous => intensity * 0.5,
      EmotionalContext.neutral => 0.0,
      EmotionalContext.melancholy => -intensity * 0.5,
      EmotionalContext.anxious => -intensity * 1.5,
      EmotionalContext.lonely => -intensity * 2.0,
      EmotionalContext.negative => -intensity * 2.0,
      EmotionalContext.stressful => -intensity * 1.0,
    };
    
    _interactionPreferences[type] = (currentPreference + preferenceChange).clamp(-50.0, 50.0);
    
    // Update time preferences
    final hour = DateTime.now().hour.toString();
    final currentTimePreference = _timePreferences[hour] ?? 0.0;
    _timePreferences[hour] = (currentTimePreference + preferenceChange * 0.1).clamp(-10.0, 10.0);
  }

  /// Remove very old memories to prevent infinite growth
  void _pruneOldMemories() {
    const maxMemories = 500;
    const maxDays = 90;
    
    if (_memories.length > maxMemories) {
      _memories.removeRange(0, _memories.length - maxMemories);
    }
    
    final cutoffDate = DateTime.now().subtract(Duration(days: maxDays));
    _memories.removeWhere((memory) => memory.timestamp.isBefore(cutoffDate));
  }

  /// Get the pet's current emotional state description
  String getEmotionalStateDescription() {
    final List<String> traits = [];
    
    // Current mood (most prominent)
    traits.add(_currentMoodDescription);
    
    // Personality-influenced descriptions
    if (_personalityExtroversion > 70) {
      traits.add(_socialability > 60 ? 'socially vibrant' : 'outwardly friendly');
    } else if (_personalityExtroversion < 30) {
      traits.add(_independence > 60 ? 'contentedly independent' : 'quietly reserved');
    }
    
    // Trust level descriptions with personality flavor
    if (_trustLevel > 80) {
      traits.add(_personalityAgreeableness > 60 ? 'wholehearted in trust' : 'selectively trusting');
    } else if (_trustLevel > 60) {
      traits.add('growing in trust');
    } else if (_trustLevel > 40) {
      traits.add(_personalityNeuroticism > 60 ? 'cautiously hopeful' : 'moderately trusting');
    } else if (_trustLevel > 20) {
      traits.add(_personalityNeuroticism > 60 ? 'nervously guarded' : 'hesitantly wary');
    } else {
      traits.add(_traumaLevel > 50 ? 'emotionally wounded' : 'deeply distrustful');
    }
    
    // Bond strength descriptions with attachment considerations
    if (_bondStrength > 80) {
      if (_attachment > 80) {
        traits.add('intensely devoted');
      } else {
        traits.add('deeply bonded yet balanced');
      }
    } else if (_bondStrength > 60) {
      traits.add(_attachment > 60 ? 'closely attached' : 'warmly connected');
    } else if (_bondStrength > 40) {
      traits.add(_curiosity > 60 ? 'curiously drawn to you' : 'steadily growing closer');
    } else if (_bondStrength > 20) {
      traits.add(_playfulness > 60 ? 'playfully warming up' : 'slowly opening up');
    } else {
      traits.add(_personalityOpenness > 60 ? 'curiously observing you' : 'still assessing the relationship');
    }
    
    // Special emotional states
    if (_attachment > 80) {
      traits.add('may experience separation anxiety');
    }
    if (_playfulness > 80) {
      traits.add('bubbling with playful energy');
    }
    if (_curiosity > 80) {
      traits.add('fascinated by everything around');
    }
    if (_confidenceLevel > 80) {
      traits.add('radiating self-assurance');
    } else if (_confidenceLevel < 20) {
      traits.add('struggling with self-doubt');
    }
    
    // Trauma level descriptions
    if (_traumaLevel > 60) {
      traits.add('carrying emotional wounds');
    } else if (_traumaLevel > 30) {
      traits.add('has some trust issues');
    } else if (_traumaLevel > 10) {
      traits.add('mostly recovered from past stress');
    }
    
    return 'Your pet is ${traits.join(', ')}.';
  }

  /// Get favorite interaction type
  InteractionType? getFavoriteInteraction() {
    if (_interactionPreferences.isEmpty) return null;
    
    final sortedPreferences = _interactionPreferences.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sortedPreferences.first.value > 5.0 ? sortedPreferences.first.key : null;
  }

  /// Get least favorite interaction type
  InteractionType? getLeastFavoriteInteraction() {
    if (_interactionPreferences.isEmpty) return null;
    
    final sortedPreferences = _interactionPreferences.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));
    
    return sortedPreferences.first.value < -5.0 ? sortedPreferences.first.key : null;
  }

  /// Check if pet is likely to be receptive to interaction right now
  bool isReceptiveToInteraction(InteractionType type) {
    final preference = _interactionPreferences[type] ?? 0.0;
    final timePreference = _timePreferences[DateTime.now().hour.toString()] ?? 0.0;
    final traumaFactor = _traumaLevel / 100.0;
    
    // High trauma makes pet less receptive
    final receptiveness = (preference + timePreference - (traumaFactor * 20)) / 50.0;
    
    return receptiveness > 0.1; // Positive receptiveness threshold
  }

  /// Get behavioral recommendations based on memory and personality
  List<String> getBehavioralRecommendations() {
    final recommendations = <String>[];
    
    // Personality-based recommendations
    if (_personalityExtroversion > 70 && _socialability < 50) {
      recommendations.add('Your naturally social pet needs more interaction - try talking, singing, or playing together');
    } else if (_personalityExtroversion < 30 && _attachment > 70) {
      recommendations.add('Your introverted pet is deeply attached - respect their need for quiet bonding time');
    }
    
    if (_personalityNeuroticism > 70) {
      recommendations.add('Your sensitive pet needs extra gentle care and predictable routines');
      if (_fearTriggers.isNotEmpty) {
        recommendations.add('Be mindful of fear triggers: ${_fearTriggers.join(", ")}');
      }
    }
    
    if (_personalityOpenness > 70 && _curiosity < 50) {
      recommendations.add('Your naturally curious pet seems understimulated - try new activities, toys, or surprise gifts');
    }
    
    // Trust-based recommendations with personality context
    if (_trustLevel < 30) {
      if (_personalityNeuroticism > 60) {
        recommendations.add('Build trust very slowly with your anxious pet - consistency is key');
      } else {
        recommendations.add('Take time to build trust with gentle, consistent interactions');
      }
      recommendations.add('Avoid sudden movements or loud sounds');
    } else if (_trustLevel > 80) {
      if (_personalityOpenness > 60) {
        recommendations.add('Your trusting and open pet is ready for new adventures and challenges');
      } else {
        recommendations.add('Your pet trusts you completely - continue your caring routine');
      }
    }
    
    // Bond and attachment-based recommendations
    if (_bondStrength < 20) {
      if (_personalityExtroversion > 60) {
        recommendations.add('Your social pet needs more interactive bonding - try cuddling, talking, or playing together');
      } else {
        recommendations.add('Build your bond slowly through gentle, consistent care');
      }
    } else if (_attachment > 80) {
      recommendations.add('Your pet is very attached - consider gradual separation training to reduce anxiety');
      recommendations.add('Leave comfort items when you\'re away');
    } else if (_bondStrength > 70) {
      recommendations.add('Your strong bond brings mutual joy - your pet treasures your time together');
    }
    
    // Confidence-based recommendations
    if (_confidenceLevel < 30) {
      recommendations.add('Build your pet\'s confidence with positive reinforcement and successful training sessions');
      if (_personalityConscientiousness > 60) {
        recommendations.add('Your pet responds well to structured, routine-based confidence building');
      }
    } else if (_confidenceLevel > 80 && _playfulness > 70) {
      recommendations.add('Your confident, playful pet is ready for more challenging and exciting activities');
    }
    
    // Trauma and emotional healing recommendations
    if (_traumaLevel > 40) {
      if (_resilience > 60) {
        recommendations.add('Your resilient pet is healing well - continue consistent, positive care');
      } else {
        recommendations.add('Be extra patient - your sensitive pet needs more time to heal from past stress');
      }
      recommendations.add('Focus on positive, low-stress interactions');
      if (_favoriteMemories.isNotEmpty) {
        recommendations.add('Recreate positive experiences that brought joy: ${_favoriteMemories.last}');
      }
    }
    
    // Special trait-based recommendations
    if (_playfulness > 80) {
      recommendations.add('Your highly playful pet needs lots of fun activities and games to stay happy');
    } else if (_playfulness < 20) {
      recommendations.add('Your pet seems less playful lately - gentle games might help rekindle their joy');
    }
    
    if (_curiosity > 80) {
      recommendations.add('Your curious pet thrives on variety - try new toys, environments, or experiences');
    }
    
    if (_socialability > 80 && _bondStrength < 50) {
      recommendations.add('Your social pet craves more interaction - spend more time talking and engaging with them');
    }
    
    // Preference-based recommendations
    final favorite = getFavoriteInteraction();
    final leastFavorite = getLeastFavoriteInteraction();
    
    if (favorite != null) {
      final activityName = favorite.name.replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(1)}').trim();
      recommendations.add('Your pet especially enjoys $activityName - try doing this more often');
    }
    
    if (leastFavorite != null) {
      final activityName = leastFavorite.name.replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(1)}').trim();
      if (_personalityNeuroticism > 60) {
        recommendations.add('Your sensitive pet finds $activityName stressful - approach very gently or avoid when possible');
      } else {
        recommendations.add('Your pet dislikes $activityName - try making it more positive with rewards and patience');
      }
    }
    
    // Favorite memory recommendations
    if (_favoriteMemories.isNotEmpty && _bondStrength > 50) {
      recommendations.add('Recreate cherished moments - your pet fondly remembers: ${_favoriteMemories.last}');
    }
    
    return recommendations;
  }

  /// Calculate emotional influence on pet stats with personality factors
  Map<String, double> getEmotionalStatModifiers() {
    final modifiers = <String, double>{};
    
    // Base happiness from positive emotions
    final positiveEmotions = (_trustLevel + _bondStrength + _confidenceLevel) / 300.0;
    var happinessBonus = positiveEmotions * 25; // Up to 25 point bonus
    
    // Personality influences on happiness
    if (_personalityExtroversion > 70 && _socialability > 60) {
      happinessBonus += 5; // Extroverted pets get bonus happiness from social satisfaction
    }
    if (_personalityOpenness > 70 && _curiosity > 60) {
      happinessBonus += 3; // Open pets get bonus happiness from satisfied curiosity
    }
    
    // Playfulness boost
    if (_playfulness > 70) {
      happinessBonus += (_playfulness - 50) / 10; // Up to 5 additional points
    }
    
    modifiers['happiness'] = happinessBonus;
    
    // Trauma and stress effects (personality-influenced)
    final traumaFactor = _traumaLevel / 100.0;
    final sensitivityMultiplier = 1.0 + (_personalityNeuroticism / 200.0);
    final traumaImpact = traumaFactor * 15 * sensitivityMultiplier;
    
    modifiers['happiness'] = (modifiers['happiness'] ?? 0.0) - traumaImpact;
    modifiers['stress'] = traumaFactor * 25 * sensitivityMultiplier; // Up to 25+ point stress increase
    
    // Attachment effects
    if (_attachment > 80) {
      modifiers['loneliness'] = -35; // Strong attachment greatly reduces loneliness
      modifiers['separation_anxiety'] = _attachment - 50; // But may cause separation anxiety
    } else {
      modifiers['loneliness'] = -(_bondStrength / 100.0 * 30); // Up to 30 point reduction
    }
    
    // Confidence effects on energy and activity
    if (_confidenceLevel > 70) {
      modifiers['energy_efficiency'] = (_confidenceLevel - 50) / 10; // Up to 5 point efficiency bonus
    } else if (_confidenceLevel < 30) {
      modifiers['energy_drain'] = (50 - _confidenceLevel) / 10; // Up to 5 point additional drain
    }
    
    return modifiers;
  }

  Map<String, dynamic> toJson() => {
    'memories': _memories.map((m) => m.toJson()).toList(),
    'interactionPreferences': _interactionPreferences.map((k, v) => MapEntry(k.name, v)),
    'behavioralPatterns': _behavioralPatterns.map((p) => p.toJson()).toList(),
    'trustLevel': _trustLevel,
    'bondStrength': _bondStrength,
    'traumaLevel': _traumaLevel,
    'isAdaptingToRoutine': _isAdaptingToRoutine,
    'lastTraumaticEvent': _lastTraumaticEvent?.toIso8601String(),
    'timePreferences': _timePreferences,
  };

  factory EmotionalMemory.fromJson(Map<String, dynamic> json) {
    final memory = EmotionalMemory();
    
    // Load memories
    if (json['memories'] != null) {
      for (final memoryJson in json['memories']) {
        memory._memories.add(InteractionMemory.fromJson(memoryJson));
      }
    }
    
    // Load preferences
    if (json['interactionPreferences'] != null) {
      for (final entry in (json['interactionPreferences'] as Map).entries) {
        memory._interactionPreferences[InteractionType.values.byName(entry.key)] = entry.value.toDouble();
      }
    }
    
    // Load behavioral patterns
    if (json['behavioralPatterns'] != null) {
      for (final patternJson in json['behavioralPatterns']) {
        memory._behavioralPatterns.add(BehavioralPattern.fromJson(patternJson));
      }
    }
    
    memory._trustLevel = json['trustLevel']?.toDouble() ?? 50.0;
    memory._bondStrength = json['bondStrength']?.toDouble() ?? 0.0;
    memory._traumaLevel = json['traumaLevel']?.toDouble() ?? 0.0;
    memory._isAdaptingToRoutine = json['isAdaptingToRoutine'] ?? false;
    memory._lastTraumaticEvent = json['lastTraumaticEvent'] != null 
        ? DateTime.parse(json['lastTraumaticEvent']) 
        : null;
    memory._timePreferences = Map<String, double>.from(json['timePreferences'] ?? {});
    
    return memory;
  }
}