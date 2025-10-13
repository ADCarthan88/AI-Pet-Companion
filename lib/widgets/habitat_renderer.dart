import 'package:flutter/material.dart';
import 'dart:math';
import '../models/pet_habitat.dart';
import '../models/pet.dart';
import '../models/store_item.dart';
import '../models/weather_system.dart';
import '../services/badge_service.dart';

class HabitatRenderer extends StatelessWidget {
  final PetHabitat habitat;
  final Pet pet;
  final Widget? child; // Pet widget to render inside habitat

  const HabitatRenderer({
    super.key, 
    required this.habitat, 
    required this.pet,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    // Check if pet has a bed as an active item
    final bool hasBed =
        pet.activeItem != null && pet.activeItem!.category == ItemCategory.beds;

    return Stack(
      children: [
        // Background
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [habitat.wallColor, habitat.floorColor],
              stops: const [0.6, 1.0], // Wall to floor transition
            ),
          ),
        ),

        // Weather effects
        ...renderWeatherEffects(),

        // Pet widget positioned within the habitat
        Positioned(
          bottom: pet.currentActivity == PetActivity.sleeping && hasBed ? 80 : 100,
          left: pet.currentActivity == PetActivity.sleeping && hasBed ? 160 : null,
          right: pet.currentActivity == PetActivity.sleeping && hasBed ? null : 150,
          width: 120,
          height: 120,
          child: child ?? const SizedBox.shrink(),
        ),

        // Pet interaction area for bed sleeping (invisible tap zone)
        if (hasBed)
          Positioned(
            bottom: 70,
            left: 150,
            width: 120,
            height: 120,
            child: GestureDetector(
              onTap: () {
                // Toggle sleeping when tapping bed area
                if (pet.currentActivity != PetActivity.sleeping) {
                  pet.currentActivity = PetActivity.sleeping;
                  pet.energy = (pet.energy + 10).clamp(0, 100);
                  BadgeService.instance.increment(
                    'sleep_sessions',
                    threshold: 3,
                    badgeId: 'Catnapper',
                  );
                } else {
                  pet.currentActivity = PetActivity.idle;
                }
              },
              child: Container(
                // Invisible interaction area
                color: Colors.transparent,
              ),
            ),
          ),

        // Background image (if available)
        if (habitat.background != null && habitat.background!.isNotEmpty)
          Positioned.fill(
            child: Opacity(
              opacity: 0.7, // Slightly transparent to blend with the colors
              child: Image.asset(
                habitat.background!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback if image doesn't exist yet
                  return const SizedBox();
                },
              ),
            ),
          ),

        // Habitat items (will render in position based on item type)
        ...renderHabitatItems(),
        if (habitat.items.isNotEmpty && renderHabitatItems().isEmpty)
          Positioned(
            top: 50,
            left: 10,
            right: 10,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.15),
                border: Border.all(color: Colors.redAccent),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'Debug: Habitat has items but none rendered (check positioning logic).',
                style: TextStyle(fontSize: 12, color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
          ),

        // Environmental elements
        if (habitat.hasWaste)
          Positioned(
            bottom: 10,
            right: 10,
            child: Icon(Icons.delete, color: Colors.brown.shade800, size: 30),
          ),

        // Insects if present
        ...renderInsects(),

        // Interactive elements
        ...renderInteractiveElements(),

        // Status indicators
        Positioned(
          top: 10,
          right: 10,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Weather indicator
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _getWeatherEmoji(),
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(width: 4),
                  Text(_getWeatherName()),
                ],
              ),
              const SizedBox(height: 4),

              // Water indicator
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildWaterBowlIcon(
                    color: habitat.hasWater ? Colors.blue : Colors.grey,
                    size: 24,
                  ),
                  const SizedBox(width: 4),
                  const Text('Water'),
                ],
              ),
              const SizedBox(height: 4),

              // Food indicator
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildFoodBowlIcon(
                    color: habitat.hasFood ? Colors.orange : Colors.grey,
                    size: 24,
                  ),
                  const SizedBox(width: 4),
                  const Text('Food'),
                ],
              ),
              const SizedBox(height: 4),

              // Cleanliness indicator
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    habitat.cleanliness > 70
                        ? Icons.clean_hands
                        : (habitat.cleanliness > 30
                              ? Icons.cleaning_services
                              : Icons.cleaning_services_outlined),
                    color: _getCleanlinessColor(),
                  ),
                  const SizedBox(width: 4),
                  Text('${habitat.cleanliness.toInt()}%'),
                ],
              ),
            ],
          ),
        ),

        // Happiness and comfort indicators
        Positioned(
          top: 10,
          left: 10,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Happiness indicator
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_getHappinessIcon(), color: _getHappinessColor()),
                  const SizedBox(width: 4),
                  Text('${habitat.happiness.toInt()}%'),
                ],
              ),
              const SizedBox(height: 4),

              // Comfort indicator
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.hotel, color: _getComfortColor()),
                  const SizedBox(width: 4),
                  Text('${habitat.comfort.toInt()}%'),
                ],
              ),
            ],
          ),
        ),

        // Cleaning action button
        Positioned(
          bottom: 20,
          right: 20,
          child: FloatingActionButton(
            heroTag: 'clean_habitat',
            mini: true,
            backgroundColor: Colors.blue.shade100,
            onPressed: () {
              _cleanHabitat(context);
            },
            child: const Icon(Icons.cleaning_services),
          ),
        ),
      ],
    );
  }

  List<Widget> renderHabitatItems() {
    List<Widget> itemWidgets = [];

    // Always show bowls if habitat has food/water even without explicit item
    if (habitat.hasWater) {
      itemWidgets.add(
        Positioned(
          bottom: 25,
          left: 20,
          child: GestureDetector(
            onTap: () {
              // Drinking behavior
              pet.energy = (pet.energy + 5).clamp(0, 100);
              pet.cleanliness = (pet.cleanliness + 2).clamp(0, 100);
              pet.happiness = (pet.happiness + 2).clamp(0, 100);
              BadgeService.instance.increment(
                'care_actions',
                threshold: 10,
                badgeId: 'Caretaker I',
              );
            },
            child: _buildWaterBowlIcon(color: Colors.blue, size: 30),
          ),
        ),
      );
    }
    if (habitat.hasFood) {
      itemWidgets.add(
        Positioned(
          bottom: 25,
          left: 60,
          child: GestureDetector(
            onTap: () {
              // Eating behavior
              pet.hunger = (pet.hunger - 15).clamp(0, 100);
              pet.happiness = (pet.happiness + 5).clamp(0, 100);
              pet.currentActivity = PetActivity.eating;
              BadgeService.instance.increment(
                'feeding_actions',
                threshold: 5,
                badgeId: 'Feeder',
              );
              Future.delayed(const Duration(seconds: 2), () {
                // Return to idle if still eating
                if (pet.currentActivity == PetActivity.eating) {
                  pet.currentActivity = PetActivity.idle;
                }
              });
            },
            child: _buildFoodBowlIcon(color: Colors.orange, size: 32),
          ),
        ),
      );
    }

    // Position items based on their type
    for (var item in habitat.items) {
      Widget itemWidget = Icon(item.icon, size: 40, color: _getItemColor(item));

      // Position differently based on item name/type
      switch (item.name) {
        // Items that go on ground
        case 'Savannah Rock':
        case 'Ice Block':
        case 'Rabbit Warren':
          itemWidgets.add(
            Positioned(
              bottom: 20,
              left: 40 + (habitat.items.indexOf(item) * 20),
              child: itemWidget,
            ),
          );
          break;

        // Items that go higher up
        case 'Pride Tree':
        case 'Tall Tree':
        case 'Bamboo Grove':
        case 'Climbing Tree':
        case 'Bird Perch':
        case 'Nest':
          itemWidgets.add(
            Positioned(
              bottom: 100,
              left: 60 + (habitat.items.indexOf(item) * 30),
              child: SizedBox(height: 100, child: itemWidget),
            ),
          );
          break;

        // Water-related items
        case 'Watering Hole':
        case 'Stream':
        case 'Fishing Spot':
        case 'Birdbath':
          itemWidgets.add(
            Positioned(
              bottom: 30,
              right: 60 + (habitat.items.indexOf(item) * 20),
              child: itemWidget,
            ),
          );
          break;

        // Indoor items
        case 'Dog Bed':
        case 'Cat Tower':
        case 'Toy Basket':
        case 'Scratching Post':
          itemWidgets.add(
            Positioned(
              bottom: 40,
              left: 80 + (habitat.items.indexOf(item) * 40),
              child: itemWidget,
            ),
          );
          break;

        // Bed items
        case 'Basic Dog Bed':
        case 'Basic Cat Cushion':
        case 'Simple Perch':
        case 'Hay Mat':
        case 'Savannah Rest Pad':
        case 'Giraffe Sleep Mat':
        case 'Simple Ice Nest':
        case 'Bamboo Mat':
        case 'Premium Dog Bed':
        case 'Premium Cat Bed':
        case 'Deluxe Perch':
        case 'Deluxe Rabbit Hutch':
        case 'Luxury Lion Bed':
        case 'Luxury Giraffe Pad':
        case 'Deluxe Penguin Nest':
        case 'Luxury Panda Bed':
          itemWidgets.add(
            Positioned(
              bottom: 40,
              left: 120,
              width: 150,
              height: 80,
              child: CustomPaint(
                size: const Size(150, 80),
                painter: PetBedPainter(
                  color: _getItemColor(item),
                  bedType: _getBedType(item.name),
                ),
              ),
            ),
          );
          break;

        // Window/door items
        case 'Doggy Door':
        case 'Window Perch':
          itemWidgets.add(Positioned(bottom: 80, right: 40, child: itemWidget));
          break;

        // Food-related items
        case 'Feeding Station':
        case 'Veggie Patch':
          itemWidgets.add(
            Positioned(bottom: 50, right: 100, child: itemWidget),
          );
          break;

        // Default positioning
        default:
          itemWidgets.add(
            Positioned(
              bottom: 30 + (habitat.items.indexOf(item) * 15),
              left: 50 + (habitat.items.indexOf(item) * 25),
              child: itemWidget,
            ),
          );
      }
    }

    return itemWidgets;
  }

  List<Widget> renderWeatherEffects() {
    List<Widget> effects = [];
    final Random random = Random();

    switch (habitat.currentWeather) {
      case WeatherType.sunny:
        // Sun rays in top corner
        effects.add(
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.amber[300],
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber[100]!.withValues(alpha: 0.8),
                    blurRadius: 30,
                    spreadRadius: 20,
                  ),
                ],
              ),
            ),
          ),
        );
        break;

      case WeatherType.rainy:
        // Raindrops
        for (int i = 0; i < 30; i++) {
          effects.add(
            Positioned(
              left: random.nextDouble() * 400,
              top: random.nextDouble() * 300,
              child: Container(
                width: 2,
                height: random.nextDouble() * 15 + 10, // Vary raindrop length
                decoration: BoxDecoration(
                  color: Colors.blue[200]!.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          );
        }
        break;

      case WeatherType.snowy:
        // Snowflakes
        for (int i = 0; i < 20; i++) {
          effects.add(
            Positioned(
              left: random.nextDouble() * 400,
              top: random.nextDouble() * 300,
              child: Text(
                '❄',
                style: TextStyle(
                  fontSize: random.nextDouble() * 10 + 10,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ),
          );
        }
        break;

      case WeatherType.cloudy:
        // Clouds
        for (int i = 0; i < 4; i++) {
          effects.add(
            Positioned(
              left: random.nextDouble() * 300,
              top: random.nextDouble() * 100,
              child: Icon(
                Icons.cloud,
                size: random.nextDouble() * 40 + 30,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
          );
        }
        break;

      case WeatherType.stormy:
        // Clouds and lightning
        for (int i = 0; i < 4; i++) {
          effects.add(
            Positioned(
              left: random.nextDouble() * 300,
              top: random.nextDouble() * 100,
              child: Icon(
                Icons.cloud,
                size: random.nextDouble() * 40 + 30,
                color: Colors.blueGrey[700]!.withValues(alpha: 0.8),
              ),
            ),
          );
        }

        // Lightning bolt
        if (random.nextBool()) {
          effects.add(
            Positioned(
              left: random.nextDouble() * 300,
              top: 20,
              child: Icon(Icons.flash_on, size: 50, color: Colors.yellow[300]),
            ),
          );
        }
        break;
    }

    return effects;
  }

  List<Widget> renderInsects() {
    List<Widget> insects = [];

    // Add insects based on insect count
    for (int i = 0; i < habitat.insectCount; i++) {
      // Randomize positions a bit
      double leftPosition = 50.0 + (i * 40);
      double bottomPosition = 30.0 + ((i % 3) * 15);

      insects.add(
        Positioned(
          left: leftPosition,
          bottom: bottomPosition,
          child: const Icon(Icons.bug_report, color: Colors.black54, size: 15),
        ),
      );
    }

    return insects;
  }

  List<Widget> renderInteractiveElements() {
    List<Widget> elements = [];

    // Add interactive elements
    for (int i = 0; i < habitat.interactiveElements.length; i++) {
      String element = habitat.interactiveElements[i];

      // Position and icon depend on element type
      IconData icon = Icons.toys;
      Color color = Colors.blue;

      if (element.contains('ball')) {
        icon = Icons.sports_baseball;
        color = Colors.red;
      } else if (element.contains('toy')) {
        icon = Icons.toys;
        color = Colors.purple;
      } else if (element.contains('puzzle')) {
        icon = Icons.extension;
        color = Colors.orange;
      }

      elements.add(
        Positioned(
          left: 80.0 + (i * 50),
          bottom: 60.0,
          child: InkWell(
            onTap: () {
              // Handle interaction
            },
            child: Icon(icon, color: color, size: 25),
          ),
        ),
      );
    }

    return elements;
  }

  Color _getItemColor(HabitatItem item) {
    // Color items based on their theme
    switch (item.theme) {
      case HabitatTheme.savannah:
        return Colors.amber.shade700;
      case HabitatTheme.arctic:
        return Colors.lightBlue.shade300;
      case HabitatTheme.bambooGrove:
        return Colors.green.shade800;
      case HabitatTheme.forest:
        return Colors.green.shade600;
      case HabitatTheme.house:
        return Colors.brown.shade300;
      case HabitatTheme.garden:
        return Colors.green.shade500;
      default:
        return Colors.black;
    }
  }

  BedType _getBedType(String bedName) {
    if (bedName.toLowerCase().contains('premium') || bedName.toLowerCase().contains('luxury')) {
      return BedType.luxury;
    } else if (bedName.toLowerCase().contains('deluxe')) {
      return BedType.deluxe;
    } else {
      return BedType.basic;
    }
  }

  Color _getCleanlinessColor() {
    if (habitat.cleanliness > 70) {
      return Colors.green;
    } else if (habitat.cleanliness > 40) {
      return Colors.amber;
    } else {
      return Colors.red;
    }
  }

  IconData _getHappinessIcon() {
    if (habitat.happiness > 70) {
      return Icons.sentiment_very_satisfied;
    } else if (habitat.happiness > 40) {
      return Icons.sentiment_satisfied;
    } else {
      return Icons.sentiment_dissatisfied;
    }
  }

  Color _getHappinessColor() {
    if (habitat.happiness > 70) {
      return Colors.green;
    } else if (habitat.happiness > 40) {
      return Colors.amber;
    } else {
      return Colors.red;
    }
  }

  Color _getComfortColor() {
    if (habitat.comfort > 70) {
      return Colors.green;
    } else if (habitat.comfort > 40) {
      return Colors.amber;
    } else {
      return Colors.red;
    }
  }

  String _getWeatherEmoji() {
    switch (habitat.currentWeather) {
      case WeatherType.sunny:
        return '☀️';
      case WeatherType.rainy:
        return '🌧️';
      case WeatherType.snowy:
        return '❄️';
      case WeatherType.cloudy:
        return '☁️';
      case WeatherType.stormy:
        return '⛈️';
    }
  }

  String _getWeatherName() {
    switch (habitat.currentWeather) {
      case WeatherType.sunny:
        return 'Sunny';
      case WeatherType.rainy:
        return 'Rainy';
      case WeatherType.snowy:
        return 'Snowy';
      case WeatherType.cloudy:
        return 'Cloudy';
      case WeatherType.stormy:
        return 'Stormy';
    }
  }

  void _cleanHabitat(BuildContext context) {
    // Clean the habitat
    habitat.clean();

    // Show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Habitat cleaned!'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  // Custom water bowl icon widget
  Widget _buildWaterBowlIcon({required Color color, required double size}) {
    return CustomPaint(
      size: Size(size, size * 0.6),
      painter: WaterBowlPainter(color: color),
    );
  }

  // Custom food bowl icon widget
  Widget _buildFoodBowlIcon({required Color color, required double size}) {
    return CustomPaint(
      size: Size(size, size * 0.6),
      painter: FoodBowlPainter(color: color),
    );
  }
}

// Enhanced 3D water bowl painter
class WaterBowlPainter extends CustomPainter {
  final Color color;

  WaterBowlPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height * 0.7;
    final bowlRadius = size.width * 0.45;
    
    // Create gradient for 3D bowl effect
    final bowlGradient = RadialGradient(
      center: const Alignment(-0.3, -0.5),
      radius: 1.2,
      colors: [
        color.withValues(alpha: 0.3),
        color,
        color.withValues(alpha: 0.7),
      ],
      stops: const [0.0, 0.7, 1.0],
    );

    // Bowl shadow (behind)
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centerX + 2, centerY + 4),
        width: bowlRadius * 2.2,
        height: bowlRadius * 0.8,
      ),
      shadowPaint,
    );

    // Main bowl with gradient
    final bowlPaint = Paint()
      ..shader = bowlGradient.createShader(
        Rect.fromCenter(
          center: Offset(centerX, centerY),
          width: bowlRadius * 2,
          height: bowlRadius * 0.7,
        ),
      );

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centerX, centerY),
        width: bowlRadius * 2,
        height: bowlRadius * 0.7,
      ),
      bowlPaint,
    );

    // Bowl rim highlight
    final rimPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centerX, centerY),
        width: bowlRadius * 2,
        height: bowlRadius * 0.7,
      ),
      rimPaint,
    );

    // Water with realistic reflection
    final waterGradient = RadialGradient(
      center: const Alignment(-0.4, -0.6),
      radius: 1.0,
      colors: [
        Colors.lightBlue[100]!,
        Colors.blue[300]!,
        Colors.blue[600]!,
      ],
      stops: const [0.0, 0.5, 1.0],
    );

    final waterPaint = Paint()
      ..shader = waterGradient.createShader(
        Rect.fromCenter(
          center: Offset(centerX, centerY - 2),
          width: bowlRadius * 1.6,
          height: bowlRadius * 0.4,
        ),
      );

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centerX, centerY - 2),
        width: bowlRadius * 1.6,
        height: bowlRadius * 0.4,
      ),
      waterPaint,
    );

    // Water highlight (reflection)
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.4);

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centerX - bowlRadius * 0.3, centerY - 6),
        width: bowlRadius * 0.4,
        height: bowlRadius * 0.1,
      ),
      highlightPaint,
    );
  }

  @override
  bool shouldRepaint(covariant WaterBowlPainter oldDelegate) => 
      oldDelegate.color != color;
}

// Enhanced 3D food bowl painter
class FoodBowlPainter extends CustomPainter {
  final Color color;

  FoodBowlPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height * 0.7;
    final bowlRadius = size.width * 0.45;
    
    // Create gradient for 3D bowl effect
    final bowlGradient = RadialGradient(
      center: const Alignment(-0.3, -0.5),
      radius: 1.2,
      colors: [
        color.withValues(alpha: 0.3),
        color,
        color.withValues(alpha: 0.7),
      ],
      stops: const [0.0, 0.7, 1.0],
    );

    // Bowl shadow (behind)
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centerX + 2, centerY + 4),
        width: bowlRadius * 2.2,
        height: bowlRadius * 0.8,
      ),
      shadowPaint,
    );

    // Main bowl with gradient
    final bowlPaint = Paint()
      ..shader = bowlGradient.createShader(
        Rect.fromCenter(
          center: Offset(centerX, centerY),
          width: bowlRadius * 2,
          height: bowlRadius * 0.7,
        ),
      );

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centerX, centerY),
        width: bowlRadius * 2,
        height: bowlRadius * 0.7,
      ),
      bowlPaint,
    );

    // Bowl rim highlight
    final rimPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centerX, centerY),
        width: bowlRadius * 2,
        height: bowlRadius * 0.7,
      ),
      rimPaint,
    );

    // Enhanced 3D kibbles with shadows and highlights
    final kibblePositions = [
      Offset(centerX - bowlRadius * 0.4, centerY - 4),
      Offset(centerX + bowlRadius * 0.2, centerY - 6),
      Offset(centerX - bowlRadius * 0.1, centerY - 2),
      Offset(centerX + bowlRadius * 0.4, centerY - 1),
      Offset(centerX - bowlRadius * 0.3, centerY + 2),
      Offset(centerX + bowlRadius * 0.1, centerY + 3),
      Offset(centerX + bowlRadius * 0.3, centerY + 1),
      Offset(centerX - bowlRadius * 0.2, centerY - 1),
    ];

    for (final pos in kibblePositions) {
      // Kibble shadow
      final shadowKibblePaint = Paint()
        ..color = Colors.black.withValues(alpha: 0.3);
      canvas.drawCircle(Offset(pos.dx + 1, pos.dy + 2), 3, shadowKibblePaint);

      // Main kibble with gradient
      final kibbleGradient = RadialGradient(
        colors: [
          Colors.brown[300]!,
          Colors.brown[600]!,
          Colors.brown[800]!,
        ],
        stops: const [0.2, 0.7, 1.0],
      );

      final kibblePaint = Paint()
        ..shader = kibbleGradient.createShader(
          Rect.fromCenter(center: pos, width: 6, height: 6),
        );
      
      canvas.drawCircle(pos, 3, kibblePaint);

      // Kibble highlight
      final highlightPaint = Paint()
        ..color = Colors.brown[200]!.withValues(alpha: 0.8);
      canvas.drawCircle(Offset(pos.dx - 1, pos.dy - 1), 1, highlightPaint);
    }
  }

  @override
  bool shouldRepaint(covariant FoodBowlPainter oldDelegate) => 
      oldDelegate.color != color;
}

// Bed types for different appearances
enum BedType { basic, deluxe, luxury }

// Enhanced 3D pet bed painter
class PetBedPainter extends CustomPainter {
  final Color color;
  final BedType bedType;

  PetBedPainter({required this.color, required this.bedType});

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height * 0.8;
    final bedWidth = size.width * 0.9;
    final bedHeight = size.height * 0.4;

    // Bed shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(centerX + 3, centerY + 5),
          width: bedWidth + 6,
          height: bedHeight + 3,
        ),
        const Radius.circular(15),
      ),
      shadowPaint,
    );

    // Main bed base with gradient
    final bedGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        color.withValues(alpha: 0.4),
        color,
        color.withValues(alpha: 0.8),
      ],
      stops: const [0.0, 0.5, 1.0],
    );

    final bedPaint = Paint()
      ..shader = bedGradient.createShader(
        Rect.fromCenter(
          center: Offset(centerX, centerY),
          width: bedWidth,
          height: bedHeight,
        ),
      );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(centerX, centerY),
          width: bedWidth,
          height: bedHeight,
        ),
        const Radius.circular(12),
      ),
      bedPaint,
    );

    // Bed cushion/pillow (different styles based on type)
    _drawCushion(canvas, size, centerX, centerY, bedWidth, bedHeight);

    // Bed rim/border highlight
    final rimPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(centerX, centerY),
          width: bedWidth,
          height: bedHeight,
        ),
        const Radius.circular(12),
      ),
      rimPaint,
    );
  }

  void _drawCushion(Canvas canvas, Size size, double centerX, double centerY, 
                   double bedWidth, double bedHeight) {
    final cushionWidth = bedWidth * 0.8;
    final cushionHeight = bedHeight * 0.6;

    Color cushionColor;
    double cushionRadius;
    
    switch (bedType) {
      case BedType.basic:
        cushionColor = Colors.grey[300]!;
        cushionRadius = 8;
        break;
      case BedType.deluxe:
        cushionColor = Colors.blue[200]!;
        cushionRadius = 10;
        break;
      case BedType.luxury:
        cushionColor = Colors.purple[200]!;
        cushionRadius = 12;
        break;
    }

    // Cushion gradient
    final cushionGradient = RadialGradient(
      center: const Alignment(-0.3, -0.4),
      radius: 1.2,
      colors: [
        cushionColor.withValues(alpha: 0.6),
        cushionColor,
        cushionColor.withValues(alpha: 0.8),
      ],
      stops: const [0.0, 0.6, 1.0],
    );

    final cushionPaint = Paint()
      ..shader = cushionGradient.createShader(
        Rect.fromCenter(
          center: Offset(centerX, centerY - 3),
          width: cushionWidth,
          height: cushionHeight,
        ),
      );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(centerX, centerY - 3),
          width: cushionWidth,
          height: cushionHeight,
        ),
        Radius.circular(cushionRadius),
      ),
      cushionPaint,
    );

    // Cushion stitching lines for luxury beds
    if (bedType == BedType.luxury) {
      final stitchPaint = Paint()
        ..color = Colors.purple[400]!.withValues(alpha: 0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;

      // Cross-hatch pattern
      for (int i = 1; i < 4; i++) {
        final x = centerX - cushionWidth * 0.3 + (i * cushionWidth * 0.2);
        canvas.drawLine(
          Offset(x, centerY - cushionHeight * 0.2),
          Offset(x, centerY + cushionHeight * 0.1),
          stitchPaint,
        );
      }
    }

    // Highlight on cushion
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.4);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(centerX - cushionWidth * 0.2, centerY - 8),
          width: cushionWidth * 0.4,
          height: cushionHeight * 0.3,
        ),
        Radius.circular(cushionRadius * 0.7),
      ),
      highlightPaint,
    );
  }

  @override
  bool shouldRepaint(covariant PetBedPainter oldDelegate) => 
      oldDelegate.color != color || oldDelegate.bedType != bedType;
}
