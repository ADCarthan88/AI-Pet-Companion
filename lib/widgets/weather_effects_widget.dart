import 'dart:math';
import 'package:flutter/material.dart';
import '../models/weather_system.dart';
import '../models/pet.dart';
import 'pet_visualizations/pet_visualization_factory.dart';

class WeatherEffectsWidget extends StatelessWidget {
  final WeatherType weatherType;
  final Pet pet;

  const WeatherEffectsWidget({
    Key? key,
    required this.weatherType,
    required this.pet,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background color based on weather
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: _getGradientColors(),
                stops: const [0.0, 0.7, 1.0],
              ),
            ),
          ),
        ),

        // Weather effects
        ..._buildWeatherEffects(),

        // Pet in the environment
        Positioned(
          bottom: 60,
          left: 0,
          right: 0,
          child: Center(
            child: SizedBox(
              width: 120,
              height: 120,
              child: PetVisualizationFactory.getPetVisualization(
                pet: pet,
                isBlinking: false,
                mouthOpen: false,
                size: 120,
              ),
            ),
          ),
        ),

        // Weather type indicator
        Positioned(
          top: 20,
          right: 20,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Text(_getWeatherEmoji(), style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 8),
                Text(
                  _getWeatherName(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<Color> _getGradientColors() {
    switch (weatherType) {
      case WeatherType.sunny:
        return [
          Colors.lightBlue[300]!,
          Colors.lightBlue[100]!,
          Colors.amber[100]!,
        ];
      case WeatherType.rainy:
        return [
          Colors.blueGrey[700]!,
          Colors.blueGrey[400]!,
          Colors.blueGrey[200]!,
        ];
      case WeatherType.snowy:
        return [Colors.lightBlue[100]!, Colors.grey[100]!, Colors.white];
      case WeatherType.cloudy:
        return [
          Colors.blueGrey[300]!,
          Colors.blueGrey[200]!,
          Colors.grey[100]!,
        ];
      case WeatherType.stormy:
        return [
          Colors.blueGrey[900]!,
          Colors.blueGrey[700]!,
          Colors.blueGrey[500]!,
        ];
    }
  }

  String _getWeatherEmoji() {
    switch (weatherType) {
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
    switch (weatherType) {
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

  List<Widget> _buildWeatherEffects() {
    final List<Widget> effects = [];
    final Random random = Random();

    switch (weatherType) {
      case WeatherType.sunny:
        // Sun rays
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
        for (int i = 0; i < 40; i++) {
          effects.add(
            Positioned(
              left: random.nextDouble() * 400,
              top: random.nextDouble() * 300,
              child: Container(
                width: 2,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.blue[200],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          );
        }
        break;

      case WeatherType.snowy:
        // Snowflakes
        for (int i = 0; i < 30; i++) {
          effects.add(
            Positioned(
              left: random.nextDouble() * 400,
              top: random.nextDouble() * 300,
              child: Text(
                '❄',
                style: TextStyle(
                  fontSize: random.nextInt(10) + 10.0,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ),
          );
        }
        break;

      case WeatherType.cloudy:
        // Clouds
        for (int i = 0; i < 5; i++) {
          effects.add(
            Positioned(
              left: (random.nextDouble() * 300) - 50,
              top: random.nextDouble() * 100,
              child: Icon(
                Icons.cloud,
                size: random.nextInt(50) + 50.0,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
          );
        }
        break;

      case WeatherType.stormy:
        // Storm clouds and lightning
        for (int i = 0; i < 5; i++) {
          effects.add(
            Positioned(
              left: (random.nextDouble() * 300) - 50,
              top: random.nextDouble() * 100,
              child: Icon(
                Icons.cloud,
                size: random.nextInt(50) + 50.0,
                color: Colors.blueGrey[700]!.withValues(alpha: 0.8),
              ),
            ),
          );
        }

        // Lightning
        if (random.nextBool()) {
          effects.add(
            Positioned(
              left: random.nextDouble() * 300,
              top: 50,
              child: Icon(Icons.flash_on, size: 60, color: Colors.yellow[200]),
            ),
          );
        }
        break;
    }

    return effects;
  }
}
