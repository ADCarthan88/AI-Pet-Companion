import 'package:flutter/material.dart';
import 'dart:math';
import '../models/pet_habitat.dart';
import '../models/pet.dart';
import '../models/store_item.dart';
import '../models/weather_system.dart';
import 'pet_visualizations/pet_visualization_factory.dart';

class HabitatRenderer extends StatelessWidget {
  final PetHabitat habitat;
  final Pet pet;

  const HabitatRenderer({super.key, required this.habitat, required this.pet});

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

        // Pet Visualization
        Positioned(
          bottom: hasBed ? 70 : 60, // Position slightly higher when on bed
          left: hasBed ? 150 : null, // Position on bed if bed is active
          right: hasBed ? null : 120, // Position on right if no bed
          width: 120,
          height: 120,
          child: PetVisualizationFactory.getPetVisualization(
            pet: pet,
            isBlinking: false,
            mouthOpen: pet.currentActivity == PetActivity.eating,
            size: 120,
          ),
        ),

        // Background image (if available)
        if (habitat.background.isNotEmpty)
          Positioned.fill(
            child: Opacity(
              opacity: 0.7, // Slightly transparent to blend with the colors
              child: Image.asset(
                habitat.background,
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
                color: Colors.red.withOpacity(0.15),
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
                  Icon(
                    Icons.water_drop,
                    color: habitat.hasWater ? Colors.blue : Colors.grey,
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
                  Icon(
                    Icons.restaurant,
                    color: habitat.hasFood ? Colors.green : Colors.grey,
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
          child: Icon(Icons.water_drop, size: 30, color: Colors.blue[400]),
        ),
      );
    }
    if (habitat.hasFood) {
      itemWidgets.add(
        Positioned(
          bottom: 25,
          left: 60,
          child: Icon(Icons.rice_bowl, size: 32, color: Colors.orange[300]),
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
              bottom: 30,
              left: 120,
              width: 150,
              height: 70,
              child: Container(
                decoration: BoxDecoration(
                  color: _getItemColor(item),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(item.icon, size: 30, color: Colors.white),
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
                    color: Colors.amber[100]!.withOpacity(0.8),
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
                  color: Colors.blue[200]!.withOpacity(0.7),
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
                  color: Colors.white.withOpacity(0.8),
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
                color: Colors.white.withOpacity(0.7),
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
                color: Colors.blueGrey[700]!.withOpacity(0.8),
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
}
