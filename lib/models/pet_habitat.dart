import 'package:flutter/material.dart';
import 'pet.dart';

enum HabitatTheme {
  jungle,
  savannah,
  arctic,
  forest,
  bambooGrove,
  mountain,
  desert,
  ocean,
}

class HabitatItem {
  final String name;
  final String description;
  final double cost;
  final IconData icon;
  final List<PetType> suitableFor;
  final HabitatTheme theme;
  bool isOwned;

  HabitatItem({
    required this.name,
    required this.description,
    required this.cost,
    required this.icon,
    required this.suitableFor,
    required this.theme,
    this.isOwned = false,
  });

  static List<HabitatItem> getItemsForPetType(PetType type) {
    return allItems.where((item) => item.suitableFor.contains(type)).toList();
  }

  static final List<HabitatItem> allItems = [
    // Lion habitat items
    HabitatItem(
      name: 'Savannah Rock',
      description: 'A perfect lounging spot for lions',
      cost: 100,
      icon: Icons.landscape,
      suitableFor: [PetType.lion],
      theme: HabitatTheme.savannah,
    ),
    // Giraffe habitat items
    HabitatItem(
      name: 'Tall Tree',
      description: 'Acacia tree with delicious leaves',
      cost: 150,
      icon: Icons.park,
      suitableFor: [PetType.giraffe],
      theme: HabitatTheme.savannah,
    ),
    // Penguin habitat items
    HabitatItem(
      name: 'Ice Block',
      description: 'Cool ice block for sliding',
      cost: 75,
      icon: Icons.ac_unit,
      suitableFor: [PetType.penguin],
      theme: HabitatTheme.arctic,
    ),
    // Panda habitat items
    HabitatItem(
      name: 'Bamboo Grove',
      description: 'Dense bamboo forest section',
      cost: 200,
      icon: Icons.forest,
      suitableFor: [PetType.panda],
      theme: HabitatTheme.bambooGrove,
    ),
  ];
}

class PetHabitat {
  final PetType petType;
  HabitatTheme theme;
  List<HabitatItem> items;
  double happiness;
  double comfort;

  PetHabitat({
    required this.petType,
    required this.theme,
    List<HabitatItem>? items,
  }) : items = items ?? [],
       happiness = 50.0,
       comfort = 50.0;

  void addItem(HabitatItem item) {
    if (item.suitableFor.contains(petType)) {
      items.add(item);
      _updateStats();
    }
  }

  void removeItem(HabitatItem item) {
    items.remove(item);
    _updateStats();
  }

  void _updateStats() {
    // Calculate happiness and comfort based on items
    happiness = 50.0 + (items.length * 5.0);
    comfort = 50.0 + (items.where((item) => item.theme == theme).length * 10.0);

    // Cap at 100
    happiness = happiness.clamp(0.0, 100.0);
    comfort = comfort.clamp(0.0, 100.0);
  }

  static HabitatTheme getDefaultTheme(PetType type) {
    switch (type) {
      case PetType.lion:
        return HabitatTheme.savannah;
      case PetType.giraffe:
        return HabitatTheme.savannah;
      case PetType.penguin:
        return HabitatTheme.arctic;
      case PetType.panda:
        return HabitatTheme.bambooGrove;
      case PetType.dog:
        return HabitatTheme.forest;
      case PetType.cat:
        return HabitatTheme.forest;
      case PetType.bird:
        return HabitatTheme.forest;
      case PetType.rabbit:
        return HabitatTheme.forest;
    }
  }
}
