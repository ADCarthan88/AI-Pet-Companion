import 'package:flutter/material.dart';
import '../models/pet.dart';

class PetInsightsScreen extends StatelessWidget {
  final Pet pet;

  const PetInsightsScreen({super.key, required this.pet});

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text('${pet.name}\'s Insights'),
        backgroundColor: Colors.purple.shade100,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Emotional State Card
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.psychology, color: Colors.purple, size: 28),
                        const SizedBox(width: 8),
                        Text(
                          'Emotional State',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Colors.purple,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      pet.getEmotionalState(),
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 12),
                    
                    // Trust & Bond Levels
                    _buildStatBar('Trust Level', pet.getTrustLevel(), Colors.blue),
                    const SizedBox(height: 8),
                    _buildStatBar('Bond Strength', pet.getBondStrength(), Colors.pink),
                    const SizedBox(height: 8),
                    _buildStatBar('Attachment', pet.emotionalMemory.attachment, Colors.purple),
                    const SizedBox(height: 8),
                    _buildStatBar('Confidence', pet.emotionalMemory.confidenceLevel, Colors.orange),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Personality Traits Card
            _buildPersonalityCard(context),

            const SizedBox(height: 16),

            // Emotional Traits Card
            _buildEmotionalTraitsCard(context),

            const SizedBox(height: 16),

            // Favorite Activities Card  
            _buildActivityPreferencesCard(context),

            const SizedBox(height: 16),

            // Habitat Condition Card
            _buildHabitatConditionCard(context),

            const SizedBox(height: 16),

            // Interactive Emotional Actions Card
            _buildEmotionalActionsCard(context),

            const SizedBox(height: 16),

            // Behavioral Recommendations Card
            _buildRecommendationsCard(context),

            const SizedBox(height: 16),

            // Favorite Memories Card
            _buildFavoriteMemoriesCard(context),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityPreferencesCard(BuildContext context) {
    final favoriteActivity = pet.getFavoriteActivity();
    final leastFavoriteActivity = pet.getLeastFavoriteActivity();
    
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.favorite, color: Colors.red, size: 28),
                const SizedBox(width: 8),
                Text(
                  'Activity Preferences',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            if (favoriteActivity != null)
              _buildActivityPreference('Favorite Activity', favoriteActivity.name, Colors.green, Icons.thumb_up)
            else
              Text('No clear favorite activity yet', style: TextStyle(color: Colors.grey)),
            
            const SizedBox(height: 8),
            
            if (leastFavoriteActivity != null)
              _buildActivityPreference('Least Favorite', leastFavoriteActivity.name, Colors.orange, Icons.thumb_down)
            else
              Text('No strong dislikes yet', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildHabitatConditionCard(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.home, color: Colors.brown, size: 28),
                const SizedBox(width: 8),
                Text(
                  'Habitat Condition',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.brown,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            Text(
              pet.getHabitatCondition(),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            
            const SizedBox(height: 12),
            
            // Maintenance status
            if (pet.habitatNeedsUrgentMaintenance())
              _buildMaintenanceAlert(
                'URGENT: Habitat needs immediate maintenance!', 
                Colors.red,
                Icons.warning,
              )
            else if (pet.habitatNeedsMaintenance())
              _buildMaintenanceAlert(
                'Habitat could use some maintenance', 
                Colors.orange,
                Icons.info,
              )
            else
              _buildMaintenanceAlert(
                'Habitat is in good condition', 
                Colors.green,
                Icons.check_circle,
              ),
            
            const SizedBox(height: 12),
            
            // Maintenance button
            if (pet.habitatNeedsMaintenance())
              ElevatedButton.icon(
                onPressed: pet.canAfford(pet.getHabitatMaintenanceCost()) 
                  ? () {
                      pet.performHabitatMaintenance();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Habitat maintenance completed! ${pet.name} is very happy!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  : null,
                icon: Icon(Icons.build),
                label: Text('Perform Maintenance (${pet.getHabitatMaintenanceCost().toStringAsFixed(1)} coins)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown,
                  foregroundColor: Colors.white,
                ),
              )
            else
              Container(), // Empty container when no maintenance needed
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationsCard(BuildContext context) {
    final recommendations = pet.getBehavioralRecommendations();
    
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.tips_and_updates, color: Colors.amber, size: 28),
                const SizedBox(width: 8),
                Text(
                  'Care Recommendations',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.amber.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            if (recommendations.isNotEmpty)
              ...recommendations.map((recommendation) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.lightbulb, color: Colors.amber, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        recommendation,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ))
            else
              Text(
                'Keep up the great care! No specific recommendations at this time.',
                style: TextStyle(color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalityCard(BuildContext context) {
    final memory = pet.emotionalMemory;
    
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person, color: Colors.indigo, size: 28),
                const SizedBox(width: 8),
                Text(
                  'Personality Traits',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.indigo,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            _buildStatBar('Extroversion', memory.personalityExtroversion, Colors.blue),
            const SizedBox(height: 6),
            _buildStatBar('Emotional Sensitivity', memory.personalityNeuroticism, Colors.red),
            const SizedBox(height: 6),
            _buildStatBar('Openness to New Things', memory.personalityOpenness, Colors.green),
            const SizedBox(height: 6),
            _buildStatBar('Cooperativeness', memory.personalityAgreeableness, Colors.purple),
            const SizedBox(height: 6),
            _buildStatBar('Loves Routine', memory.personalityConscientiousness, Colors.orange),
            
            const SizedBox(height: 8),
            Text(
              _getPersonalityDescription(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontStyle: FontStyle.italic,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmotionalTraitsCard(BuildContext context) {
    final memory = pet.emotionalMemory;
    
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.favorite_border, color: Colors.pink, size: 28),
                const SizedBox(width: 8),
                Text(
                  'Emotional Traits',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.pink,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            _buildStatBar('Playfulness', memory.playfulness, Colors.yellow),
            const SizedBox(height: 6),
            _buildStatBar('Curiosity', memory.curiosity, Colors.cyan),
            const SizedBox(height: 6),
            _buildStatBar('Social Needs', memory.socialability, Colors.blue),
            const SizedBox(height: 6),
            _buildStatBar('Independence', memory.independence, Colors.teal),
            const SizedBox(height: 6),
            _buildStatBar('Resilience', memory.resilience, Colors.green),
            
            if (memory.traumaLevel > 10) ...[
              const SizedBox(height: 6),
              _buildStatBar('Trauma Level', memory.traumaLevel, Colors.red),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmotionalActionsCard(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.touch_app, color: Colors.green, size: 28),
                const SizedBox(width: 8),
                Text(
                  'Emotional Interactions',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    pet.gentleTouch();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${pet.name} feels your gentle touch'),
                        backgroundColor: Colors.pink,
                      ),
                    );
                  },
                  icon: Icon(Icons.pan_tool, size: 18),
                  label: Text('Gentle Touch'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink.shade100,
                    foregroundColor: Colors.pink.shade700,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    pet.talkToPet('You\'re such a good pet!');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${pet.name} loves hearing your voice'),
                        backgroundColor: Colors.blue,
                      ),
                    );
                  },
                  icon: Icon(Icons.record_voice_over, size: 18),
                  label: Text('Talk'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade100,
                    foregroundColor: Colors.blue.shade700,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    pet.giveSurpriseGift('special treat');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${pet.name} is delighted with the surprise!'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  },
                  icon: Icon(Icons.card_giftcard, size: 18),
                  label: Text('Surprise Gift'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade100,
                    foregroundColor: Colors.orange.shade700,
                  ),
                ),
                if (pet.mood == PetMood.sad || pet.emotionalMemory.traumaLevel > 30)
                  ElevatedButton.icon(
                    onPressed: () {
                      pet.comfortPet();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${pet.name} feels comforted by your care'),
                          backgroundColor: Colors.purple,
                        ),
                      );
                    },
                    icon: Icon(Icons.favorite, size: 18),
                    label: Text('Comfort'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple.shade100,
                      foregroundColor: Colors.purple.shade700,
                    ),
                  ),
                ElevatedButton.icon(
                  onPressed: () {
                    pet.celebrateWithPet('your bond');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${pet.name} loves celebrating with you!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  icon: Icon(Icons.celebration, size: 18),
                  label: Text('Celebrate'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade100,
                    foregroundColor: Colors.green.shade700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoriteMemoriesCard(BuildContext context) {
    final favoriteMemories = pet.emotionalMemory.favoriteMemories;
    final fearTriggers = pet.emotionalMemory.fearTriggers;
    
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome, color: Colors.amber, size: 28),
                const SizedBox(width: 8),
                Text(
                  'Special Memories',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.amber.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            if (favoriteMemories.isNotEmpty) ...[
              Text(
                'Cherished Moments:',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade700,
                ),
              ),
              const SizedBox(height: 8),
              ...favoriteMemories.take(3).map((memory) => Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        memory.replaceAllMapped(
                          RegExp(r'([A-Z])'),
                          (match) => ' ${match.group(1)}',
                        ).trim(),
                        style: TextStyle(color: Colors.green.shade600),
                      ),
                    ),
                  ],
                ),
              )),
            ] else ...[
              Text(
                'No special memories yet - create some beautiful moments together!',
                style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
              ),
            ],
            
            if (fearTriggers.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Things to Approach Gently:',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade700,
                ),
              ),
              const SizedBox(height: 8),
              ...fearTriggers.take(3).map((trigger) => Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber, color: Colors.orange, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        trigger.replaceAllMapped(
                          RegExp(r'([A-Z])'),
                          (match) => ' ${match.group(1)}',
                        ).trim(),
                        style: TextStyle(color: Colors.orange.shade600),
                      ),
                    ),
                  ],
                ),
              )),
            ],
          ],
        ),
      ),
    );
  }

  String _getPersonalityDescription() {
    final memory = pet.emotionalMemory;
    final traits = <String>[];
    
    if (memory.personalityExtroversion > 70) {
      traits.add('socially outgoing');
    } else if (memory.personalityExtroversion < 30) {
      traits.add('quietly introverted');
    }
    
    if (memory.personalityNeuroticism > 70) {
      traits.add('emotionally sensitive');
    } else if (memory.personalityNeuroticism < 30) {
      traits.add('emotionally stable');
    }
    
    if (memory.personalityOpenness > 70) {
      traits.add('loves new experiences');
    } else if (memory.personalityOpenness < 30) {
      traits.add('prefers familiar routines');
    }
    
    if (memory.personalityAgreeableness > 70) {
      traits.add('naturally cooperative');
    } else if (memory.personalityAgreeableness < 30) {
      traits.add('independently minded');
    }
    
    if (traits.isEmpty) {
      return 'A well-balanced personality with moderate traits.';
    }
    
    return 'Your pet is ${traits.join(', ')}.';
  }

  Widget _buildStatBar(String label, double value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: LinearProgressIndicator(
                value: value / 100,
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 8,
              ),
            ),
            const SizedBox(width: 8),
            Text('${value.toStringAsFixed(1)}%', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }

  Widget _buildActivityPreference(String label, String activity, Color color, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text('$label: ', style: TextStyle(fontWeight: FontWeight.w500)),
        Text(
          activity.replaceAllMapped(
            RegExp(r'([A-Z])'),
            (match) => ' ${match.group(1)}',
          ).trim(),
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildMaintenanceAlert(String message, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: color, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}