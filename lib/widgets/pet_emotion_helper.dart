import 'dart:math';
import 'package:flutter/material.dart';
import '../models/pet.dart';

class PetEmotionHelper {
  // Map pet moods to visual cues
  static Map<PetMood, IconData> moodIcons = {
    PetMood.happy: Icons.sentiment_very_satisfied,
    PetMood.neutral: Icons.sentiment_neutral,
    PetMood.sad: Icons.sentiment_dissatisfied,
    PetMood.excited: Icons.sentiment_very_satisfied,
    PetMood.tired: Icons.bedtime,
    PetMood.loving: Icons.favorite,
  };

  // Map pet moods to colors
  static Map<PetMood, Color> moodColors = {
    PetMood.happy: Colors.amber,
    PetMood.neutral: Colors.blue,
    PetMood.sad: Colors.blueGrey,
    PetMood.excited: Colors.orange,
    PetMood.tired: Colors.indigo,
    PetMood.loving: Colors.pink,
  };

  // Map pet moods to emoji
  static Map<PetMood, String> moodEmojis = {
    PetMood.happy: '😊',
    PetMood.neutral: '😐',
    PetMood.sad: '😢',
    PetMood.excited: '😃',
    PetMood.tired: '😴',
    PetMood.loving: '❤️',
  };

  // Get random emotion bubble text based on pet state
  static String getRandomEmotionText(Pet pet) {
    // Generate a random emotion based on pet's state
    final random = Random();

    // Different sets of emotions based on pet's needs
    if (pet.hunger > 70) {
      final options = ['🍗', '🍖', '🥩', '🍕', '🍔'];
      return options[random.nextInt(options.length)];
    } else if (pet.cleanliness < 30) {
      final options = ['💦', '🛁', '🧼'];
      return options[random.nextInt(options.length)];
    } else if (pet.energy < 30) {
      final options = ['💤', '😴', '🛏️'];
      return options[random.nextInt(options.length)];
    } else if (pet.happiness > 80) {
      final options = ['❤️', '😊', '🎾', '🎮', '🎯'];
      return options[random.nextInt(options.length)];
    }

    // Pet type specific emotions
    // Pet type specific emotions
    if (pet.type == PetType.dog) {
      final options = ['🦴', '🐾', '🦮', '🐕'];
      return options[random.nextInt(options.length)];
    } else if (pet.type == PetType.cat) {
      final options = ['🐟', '🧶', '🐱', '🐈'];
      return options[random.nextInt(options.length)];
    } else if (pet.type == PetType.bird) {
      final options = ['🌱', '🪶', '🐦', '✈️'];
      return options[random.nextInt(options.length)];
    } else if (pet.type == PetType.rabbit) {
      final options = ['🥕', '🍃', '🐰'];
      return options[random.nextInt(options.length)];
    } else if (pet.type == PetType.lion) {
      final options = ['👑', '🦁', '🏞️'];
      return options[random.nextInt(options.length)];
    } else if (pet.type == PetType.giraffe) {
      final options = ['🌳', '🦒', '🌿'];
      return options[random.nextInt(options.length)];
    } else if (pet.type == PetType.penguin) {
      final options = ['❄️', '🧊', '🐧'];
      return options[random.nextInt(options.length)];
    } else {
      // PetType.panda and any future types
      final options = ['🎍', '🎋', '🐼'];
      return options[random.nextInt(options.length)];
    }
  }

  // Get thought bubble text based on pet activity
  static String getActivityEmoji(PetActivity activity) {
    if (activity == PetActivity.playing ||
        activity == PetActivity.playingWithToy) {
      return '🎮';
    } else if (activity == PetActivity.sleeping) {
      return '💤';
    } else if (activity == PetActivity.eating) {
      return '🍽️';
    } else if (activity == PetActivity.idle) {
      return '🤔';
    } else if (activity == PetActivity.licking) {
      return '❤️';
    } else if (activity == PetActivity.beingCleaned) {
      return '🛁';
    } else if (activity == PetActivity.beingBrushed) {
      return '🧹';
    } else {
      return '❓';
    }
  }

  // Get color based on pet activity
  static Color getActivityColor(PetActivity activity) {
    if (activity == PetActivity.playing ||
        activity == PetActivity.playingWithToy) {
      return Colors.green;
    } else if (activity == PetActivity.sleeping) {
      return Colors.indigo;
    } else if (activity == PetActivity.eating) {
      return Colors.orange;
    } else if (activity == PetActivity.idle) {
      return Colors.blue;
    } else if (activity == PetActivity.licking) {
      return Colors.pink;
    } else if (activity == PetActivity.beingCleaned) {
      return Colors.lightBlue;
    } else if (activity == PetActivity.beingBrushed) {
      return Colors.amber;
    } else {
      return Colors.grey;
    }
  }
}
