import 'package:flutter/material.dart';
import 'pet.dart';

enum WeatherType { sunny, rainy, snowy, cloudy, stormy }

class WeatherSystem {
  WeatherType currentWeather;
  final Function(WeatherType) onWeatherChanged;

  WeatherSystem({
    this.currentWeather = WeatherType.sunny,
    required this.onWeatherChanged,
  });

  void changeWeather(WeatherType newWeather) {
    currentWeather = newWeather;
    onWeatherChanged(currentWeather);
  }

  Color getWeatherColor() {
    switch (currentWeather) {
      case WeatherType.sunny:
        return Colors.yellow;
      case WeatherType.rainy:
        return Colors.blueGrey;
      case WeatherType.snowy:
        return Colors.white;
      case WeatherType.cloudy:
        return Colors.grey;
      case WeatherType.stormy:
        return Colors.indigo;
    }
  }

  String getWeatherEmoji() {
    switch (currentWeather) {
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

  static Map<WeatherType, List<String>> getPetWeatherReactions(PetType type) {
    switch (type) {
      case PetType.lion:
        return {
          WeatherType.sunny: ['Basks in the warm sun', 'Feels energetic'],
          WeatherType.rainy: ['Seeks shelter', 'Feels lazy'],
          WeatherType.snowy: ['Stays inside', 'Prefers to sleep'],
          WeatherType.cloudy: ['Patrols territory', 'Feels neutral'],
          WeatherType.stormy: ['Becomes alert', 'Seeks high ground'],
        };
      case PetType.penguin:
        return {
          WeatherType.sunny: ['Seeks shade', 'Feels tired'],
          WeatherType.rainy: ['Enjoys the cool weather', 'Feels playful'],
          WeatherType.snowy: ['Extremely happy', 'Very energetic'],
          WeatherType.cloudy: ['Comfortable', 'Moderately active'],
          WeatherType.stormy: ['Excited', 'Loves the cold wind'],
        };
      // Add other pet types...
      default:
        return {
          WeatherType.sunny: ['Enjoys the weather', 'Feels happy'],
          WeatherType.rainy: ['Stays dry', 'Feels calm'],
          WeatherType.snowy: ['Explores the snow', 'Feels curious'],
          WeatherType.cloudy: ['Regular activity', 'Feels normal'],
          WeatherType.stormy: ['Seeks shelter', 'Feels nervous'],
        };
    }
  }
}
