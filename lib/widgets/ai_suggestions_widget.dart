import 'package:flutter/material.dart';
import 'dart:async';
import '../models/pet.dart';
import '../services/ai_response_engine.dart';
import '../services/realistic_behavior_engine.dart';

/// Widget that displays AI-generated suggestions and insights about the pet
class AISuggestionsWidget extends StatefulWidget {
  final Pet pet;
  final VoidCallback? onSuggestionTapped;

  const AISuggestionsWidget({
    super.key,
    required this.pet,
    this.onSuggestionTapped,
  });

  @override
  State<AISuggestionsWidget> createState() => _AISuggestionsWidgetState();
}

class _AISuggestionsWidgetState extends State<AISuggestionsWidget> {
  Timer? _updateTimer;
  String? _currentSuggestion;
  String _currentInsight = '';
  bool _isVisible = false;
  
  @override
  void initState() {
    super.initState();
    _startSuggestionUpdates();
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }

  void _startSuggestionUpdates() {
    _updateTimer = Timer.periodic(
      const Duration(seconds: 15),
      (_) => _updateSuggestions(),
    );
    
    // Initial update
    _updateSuggestions();
  }

  void _updateSuggestions() {
    if (!mounted) return;
    
    final aiEngine = widget.pet._aiResponseEngine;
    final behaviorEngine = widget.pet._behaviorEngine;
    
    setState(() {
      // Get AI suggestion
      _currentSuggestion = aiEngine?.suggestUserAction();
      
      // Get behavioral insight
      _currentInsight = _generateBehavioralInsight(behaviorEngine);
      
      // Show widget if we have content
      _isVisible = _currentSuggestion != null || _currentInsight.isNotEmpty;
    });
  }

  String _generateBehavioralInsight(RealisticBehaviorEngine? behaviorEngine) {
    if (behaviorEngine == null) return '';
    
    final currentBehavior = behaviorEngine.currentBehaviorState;
    final pet = widget.pet;
    
    switch (currentBehavior) {
      case 'seeking_attention':
        if (pet.emotionalMemory.attachment > 70) {
          return '${pet.name} is seeking attention because they\'re deeply attached to you!';
        } else if (pet.happiness < 50) {
          return '${pet.name} needs some cheering up - they\'re looking for comfort.';
        }
        return '${pet.name} wants to interact with you right now.';
        
      case 'investigating':
        if (pet.emotionalMemory.curiosity > 70) {
          return '${pet.name}\'s curious nature is showing - they love exploring!';
        }
        return '${pet.name} is investigating their environment.';
        
      case 'content':
        if (pet.emotionalMemory.trustLevel > 80) {
          return '${pet.name} feels completely safe and content with you.';
        }
        return '${pet.name} is feeling peaceful and satisfied.';
        
      case 'playful_energy':
        if (pet.emotionalMemory.playfulness > 80) {
          return '${pet.name} is bursting with playful energy - perfect time for games!';
        }
        return '${pet.name} is in a playful mood.';
        
      case 'resting':
        if (pet.energy < 30) {
          return '${pet.name} is tired and needs to recharge their energy.';
        }
        return '${pet.name} is taking a peaceful rest.';
        
      case 'alert':
        if (pet.emotionalMemory.personalityNeuroticism > 60) {
          return '${pet.name}\'s sensitive nature makes them very aware of their surroundings.';
        }
        return '${pet.name} is alert and paying attention to everything around them.';
        
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) return const SizedBox.shrink();
    
    return AnimatedOpacity(
      opacity: _isVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.blue.shade50,
              Colors.purple.shade50,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: Colors.blue.shade200,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  Icons.psychology,
                  color: Colors.blue.shade600,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'AI Insights',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () {
                    setState(() {
                      _isVisible = false;
                    });
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Current behavioral insight
            if (_currentInsight.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.visibility,
                      color: Colors.green.shade600,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _currentInsight,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
            
            // AI suggestion
            if (_currentSuggestion != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.amber.shade200,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.lightbulb,
                      color: Colors.amber.shade700,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _currentSuggestion!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade800,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
            
            // Pet emotional state summary
            _buildEmotionalStateSummary(),
            
            const SizedBox(height: 8),
            
            // Action button
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () {
                  widget.onSuggestionTapped?.call();
                  setState(() {
                    _isVisible = false;
                  });
                },
                icon: const Icon(Icons.favorite, size: 16),
                label: const Text('Got it!'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.blue.shade700,
                  textStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmotionalStateSummary() {
    final pet = widget.pet;
    final emotionalState = pet.emotionalMemory.getEmotionalStateDescription();
    
    // Extract the first sentence for brevity
    final briefState = emotionalState.split('.').first + '.';
    
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.pink.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.pink.shade200,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.favorite,
            color: Colors.pink.shade600,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              briefState,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade700,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Floating AI assistant button that shows suggestions when tapped
class AIAssistantButton extends StatefulWidget {
  final Pet pet;

  const AIAssistantButton({
    super.key,
    required this.pet,
  });

  @override
  State<AIAssistantButton> createState() => _AIAssistantButtonState();
}

class _AIAssistantButtonState extends State<AIAssistantButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Suggestions overlay
        if (_showSuggestions)
          Positioned(
            bottom: 80,
            right: 0,
            left: 0,
            child: AISuggestionsWidget(
              pet: widget.pet,
              onSuggestionTapped: () {
                setState(() {
                  _showSuggestions = false;
                });
              },
            ),
          ),
        
        // AI Assistant button
        Positioned(
          bottom: 16,
          right: 16,
          child: AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: FloatingActionButton(
                  onPressed: () {
                    setState(() {
                      _showSuggestions = !_showSuggestions;
                    });
                  },
                  backgroundColor: Colors.blue.shade600,
                  child: Icon(
                    _showSuggestions ? Icons.close : Icons.psychology,
                    color: Colors.white,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}