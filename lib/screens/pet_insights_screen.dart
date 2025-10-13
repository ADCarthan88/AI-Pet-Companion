import 'package:flutter/material.dart';
import '../models/pet.dart';

class PetInsightsScreen extends StatelessWidget {
  final Pet pet;

  const PetInsightsScreen({super.key, required this.pet});

  @override
  Widget build(BuildContext context) {
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
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Favorite Activities Card
            Card(
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
                    
                    Builder(
                      builder: (context) {
                        final favoriteActivity = pet.getFavoriteActivity();
                        if (favoriteActivity != null) {
                          return _buildActivityPreference('Favorite Activity', favoriteActivity.name, Colors.green, Icons.thumb_up);
                        } else {
                          return Text('No clear favorite activity yet', style: TextStyle(color: Colors.grey));
                        }
                      },
                    ),
                    
                    const SizedBox(height: 8),
                    
                    Builder(
                      builder: (context) {
                        final leastFavoriteActivity = pet.getLeastFavoriteActivity();
                        if (leastFavoriteActivity != null) {
                          return _buildActivityPreference('Least Favorite', leastFavoriteActivity.name, Colors.orange, Icons.thumb_down);
                        } else {
                          return Text('No strong dislikes yet', style: TextStyle(color: Colors.grey));
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Habitat Condition Card
            Card(
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
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Behavioral Recommendations Card
            Card(
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
                    
                    // Behavioral recommendations
                    if (pet.getBehavioralRecommendations().isNotEmpty)
                      ...pet.getBehavioralRecommendations().map((recommendation) => Padding(
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
            ),
          ],
        ),
      ),
    );
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
              style: TextStyle(color: color.withOpacity(0.8), fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}