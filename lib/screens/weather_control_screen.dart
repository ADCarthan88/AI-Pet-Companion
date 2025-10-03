import 'package:flutter/material.dart';
import '../models/pet.dart';
import '../models/weather_system.dart';
import '../widgets/weather_effects_widget.dart';

class WeatherControlScreen extends StatefulWidget {
  const WeatherControlScreen({super.key, required this.pet});

  final Pet pet;

  @override
  State<WeatherControlScreen> createState() => _WeatherControlScreenState();
}

class _WeatherControlScreenState extends State<WeatherControlScreen> {
  late WeatherType _selectedWeather;
  late List<String> _weatherReactions;

  @override
  void initState() {
    super.initState();
    // Initialize with current weather or pet's preferred weather
    _selectedWeather =
        widget.pet.habitat?.currentWeather ?? widget.pet.preferredWeather;
    _updateReactions();
  }

  // Update the pet's reactions based on selected weather
  void _updateReactions() {
    final reactions = WeatherSystem.getPetWeatherReactions(widget.pet.type);
    _weatherReactions = reactions[_selectedWeather] ?? ['Normal reaction'];
  }

  // Apply the selected weather to the pet's habitat
  void _applyWeather() {
    if (widget.pet.habitat != null) {
      setState(() {
        widget.pet.habitat!.changeWeather(_selectedWeather);

        // Apply effects based on weather and pet preferences
        if (_selectedWeather == widget.pet.preferredWeather) {
          widget.pet.happiness = (widget.pet.happiness + 10).clamp(0, 100);
          widget.pet.energy = (widget.pet.energy + 5).clamp(0, 100);
        } else if (_isAdverseWeather()) {
          widget.pet.happiness = (widget.pet.happiness - 5).clamp(0, 100);
          widget.pet.energy = (widget.pet.energy - 5).clamp(0, 100);
        }

        // Update UI
        _updateReactions();
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Weather changed to ${_weatherTypeToString(_selectedWeather)}',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  // Check if the selected weather is adverse for this pet type
  bool _isAdverseWeather() {
    switch (widget.pet.type) {
      case PetType.lion:
      case PetType.giraffe:
        return _selectedWeather == WeatherType.rainy ||
            _selectedWeather == WeatherType.snowy ||
            _selectedWeather == WeatherType.stormy;
      case PetType.penguin:
        return _selectedWeather == WeatherType.sunny;
      case PetType.panda:
        return _selectedWeather == WeatherType.sunny ||
            _selectedWeather == WeatherType.stormy;
      default:
        return _selectedWeather == WeatherType.stormy;
    }
  }

  // Convert weather type to display string
  String _weatherTypeToString(WeatherType type) {
    switch (type) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Weather Control - ${widget.pet.name}')),
      body: Column(
        children: [
          // Weather visualization
          Expanded(
            flex: 2,
            child: WeatherEffectsWidget(
              weatherType: _selectedWeather,
              pet: widget.pet,
            ),
          ),

          // Pet reaction
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'How ${widget.pet.name} feels: ',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          _isAdverseWeather()
                              ? Icons.sentiment_dissatisfied
                              : _selectedWeather == widget.pet.preferredWeather
                              ? Icons.sentiment_very_satisfied
                              : Icons.sentiment_satisfied,
                          color: _isAdverseWeather()
                              ? Colors.red
                              : _selectedWeather == widget.pet.preferredWeather
                              ? Colors.green
                              : Colors.amber,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ..._weatherReactions.map(
                      (reaction) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          children: [
                            const Icon(Icons.pets, size: 16),
                            const SizedBox(width: 8),
                            Text(reaction),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Weather selection
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Select Weather:',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildWeatherButton(WeatherType.sunny, '☀️', 'Sunny'),
                      _buildWeatherButton(WeatherType.cloudy, '☁️', 'Cloudy'),
                      _buildWeatherButton(WeatherType.rainy, '🌧️', 'Rainy'),
                      _buildWeatherButton(WeatherType.snowy, '❄️', 'Snowy'),
                      _buildWeatherButton(WeatherType.stormy, '⛈️', 'Stormy'),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _applyWeather,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Apply Weather'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherButton(
    WeatherType weatherType,
    String emoji,
    String label,
  ) {
    final isSelected = _selectedWeather == weatherType;
    final isPreferred = widget.pet.preferredWeather == weatherType;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _selectedWeather = weatherType;
                _updateReactions();
              });
            },
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
        color: isSelected
          ? Colors.blue.withValues(alpha: 0.3)
          : Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: isSelected ? Colors.blue : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 30)),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(label),
          if (isPreferred)
            const Padding(
              padding: EdgeInsets.only(top: 4.0),
              child: Text(
                '(Preferred)',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
