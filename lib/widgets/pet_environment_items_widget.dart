import 'package:flutter/material.dart';
import '../models/pet.dart';
import '../models/store_item.dart';

class PetEnvironmentItemsWidget extends StatelessWidget {
  final Pet pet;
  final double size;

  const PetEnvironmentItemsWidget({
    Key? key,
    required this.pet,
    required this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // If no active item, don't display anything
    if (pet.activeItem == null) {
      return const SizedBox.shrink();
    }

    // Render the active item based on category
    return _buildItemVisualization(pet.activeItem!);
  }

  Widget _buildItemVisualization(StoreItem item) {
    switch (item.category) {
      case ItemCategory.beds:
        return _buildBed(item);
      case ItemCategory.food:
        return _buildFood(item);
      case ItemCategory.toys:
        return _buildToy(item);
      case ItemCategory.furniture:
        return _buildFurniture(item);
      case ItemCategory.accessories:
        return _buildAccessory(item);
      case ItemCategory.weatherItems:
        return _buildWeatherItem(item);
      default:
        // For other categories, use a simple icon representation
        return Positioned(
          bottom: size * 0.05,
          right: size * 0.05,
          child: Container(
            padding: EdgeInsets.all(size * 0.03),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              shape: BoxShape.circle,
            ),
            child: Icon(
              item.icon,
              color: item.selectedColor ?? Colors.blue,
              size: size * 0.1,
            ),
          ),
        );
    }
  }

  Widget _buildBed(StoreItem bed) {
    final bedColor = bed.selectedColor ?? Colors.brown;

    return Positioned(
      bottom: size * 0.05,
      left: size * 0.15,
      width: size * 0.7,
      height: size * 0.25,
      child: Stack(
        children: [
          // Base of bed
          Container(
            margin: EdgeInsets.only(top: size * 0.05),
            decoration: BoxDecoration(
              color: bedColor,
              borderRadius: BorderRadius.circular(size * 0.05),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),

          // Pillow
          Positioned(
            top: size * 0.02,
            left: size * 0.05,
            width: size * 0.2,
            height: size * 0.1,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(size * 0.03),
                border: Border.all(color: Colors.grey.shade300, width: 2),
              ),
            ),
          ),

          // Blanket
          Positioned(
            top: size * 0.1,
            right: size * 0.05,
            width: size * 0.5,
            height: size * 0.1,
            child: Container(
              decoration: BoxDecoration(
                color: _getLighterColor(bedColor),
                borderRadius: BorderRadius.circular(size * 0.03),
                border: Border.all(color: _getDarkerColor(bedColor), width: 1),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFood(StoreItem food) {
    final foodColor = food.selectedColor ?? Colors.orange;

    return Positioned(
      bottom: size * 0.05,
      right: size * 0.1,
      width: size * 0.25,
      height: size * 0.1,
      child: Stack(
        children: [
          // Bowl
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade400, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 2,
                ),
              ],
            ),
          ),

          // Food inside bowl
          Positioned(
            top: size * 0.025,
            left: size * 0.025,
            right: size * 0.025,
            bottom: size * 0.025,
            child: Container(
              decoration: BoxDecoration(
                color: foodColor,
                shape: BoxShape.circle,
              ),
            ),
          ),

          // Food texture
          Positioned(
            top: size * 0.035,
            left: size * 0.06,
            child: Container(
              width: size * 0.03,
              height: size * 0.03,
              decoration: BoxDecoration(
                color: _getLighterColor(foodColor),
                shape: BoxShape.circle,
              ),
            ),
          ),

          Positioned(
            top: size * 0.05,
            right: size * 0.07,
            child: Container(
              width: size * 0.04,
              height: size * 0.02,
              decoration: BoxDecoration(
                color: _getLighterColor(foodColor),
                borderRadius: BorderRadius.circular(size * 0.01),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToy(StoreItem toy) {
    final toyColor = toy.selectedColor ?? Colors.red;

    return Positioned(
      bottom: size * 0.15,
      right: size * 0.15,
      width: size * 0.2,
      height: size * 0.2,
      child: Container(
        decoration: BoxDecoration(
          color: toyColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 3,
            ),
          ],
        ),
        child: Center(
          child: Icon(
            toy.icon,
            color: _getContrastColor(toyColor),
            size: size * 0.1,
          ),
        ),
      ),
    );
  }

  Widget _buildFurniture(StoreItem furniture) {
    final furnitureColor = furniture.selectedColor ?? Colors.brown;

    // Basic furniture shape - a small table or stand
    return Positioned(
      bottom: size * 0.05,
      left: size * 0.05,
      width: size * 0.3,
      height: size * 0.25,
      child: Stack(
        children: [
          // Table top
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: size * 0.05,
            child: Container(
              decoration: BoxDecoration(
                color: furnitureColor,
                borderRadius: BorderRadius.circular(size * 0.01),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
            ),
          ),

          // Left leg
          Positioned(
            top: size * 0.05,
            left: size * 0.05,
            width: size * 0.03,
            bottom: 0,
            child: Container(color: furnitureColor),
          ),

          // Right leg
          Positioned(
            top: size * 0.05,
            right: size * 0.05,
            width: size * 0.03,
            bottom: 0,
            child: Container(color: furnitureColor),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherItem(StoreItem weather) {
    final weatherColor = weather.selectedColor ?? Colors.lightBlue;

    // Position based on item name
    if (weather.name.toLowerCase().contains('umbrella')) {
      return Positioned(
        top: size * 0.1,
        right: size * 0.2,
        width: size * 0.3,
        height: size * 0.3,
        child: Column(
          children: [
            Container(
              width: size * 0.25,
              height: size * 0.15,
              decoration: BoxDecoration(
                color: weatherColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(size * 0.15),
                  topRight: Radius.circular(size * 0.15),
                  bottomLeft: Radius.circular(size * 0.15),
                  bottomRight: Radius.circular(size * 0.15),
                ),
              ),
            ),
            Container(
              width: size * 0.02,
              height: size * 0.15,
              color: Colors.grey[600],
            ),
          ],
        ),
      );
    } else if (weather.name.toLowerCase().contains('coat') ||
        weather.name.toLowerCase().contains('boots')) {
      // Wearable weather items
      return Positioned(
        bottom: size * 0.25,
        right: size * 0.15,
        width: size * 0.15,
        height: size * 0.15,
        child: Container(
          decoration: BoxDecoration(
            color: weatherColor.withOpacity(0.8),
            borderRadius: BorderRadius.circular(size * 0.03),
          ),
          child: Center(
            child: Icon(weather.icon, color: Colors.white, size: size * 0.08),
          ),
        ),
      );
    } else {
      // Default for other weather items
      return Positioned(
        bottom: size * 0.05,
        left: size * 0.05,
        width: size * 0.25,
        height: size * 0.25,
        child: Container(
          decoration: BoxDecoration(
            color: weatherColor.withOpacity(0.7),
            borderRadius: BorderRadius.circular(size * 0.05),
            border: Border.all(color: _getDarkerColor(weatherColor), width: 2),
          ),
          child: Center(
            child: Icon(weather.icon, color: Colors.white, size: size * 0.15),
          ),
        ),
      );
    }
  }

  Widget _buildAccessory(StoreItem accessory) {
    final accessoryColor = accessory.selectedColor ?? Colors.pink;

    // A simple accessory - like a collar or hat
    if (accessory.name.toLowerCase().contains('collar')) {
      return Positioned(
        bottom: size * 0.35,
        left: size * 0.3,
        right: size * 0.3,
        height: size * 0.05,
        child: Container(
          decoration: BoxDecoration(
            color: accessoryColor,
            borderRadius: BorderRadius.circular(size * 0.025),
            border: Border.all(
              color: _getDarkerColor(accessoryColor),
              width: 1,
            ),
          ),
          child: Center(
            child: Container(
              width: size * 0.04,
              height: size * 0.04,
              decoration: BoxDecoration(
                color: Colors.yellow,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.orange, width: 1),
              ),
            ),
          ),
        ),
      );
    } else {
      // Other accessories as a generic item
      return Positioned(
        top: size * 0.1,
        right: size * 0.2,
        width: size * 0.15,
        height: size * 0.15,
        child: Container(
          decoration: BoxDecoration(
            color: accessoryColor.withOpacity(0.8),
            borderRadius: BorderRadius.circular(size * 0.03),
          ),
          child: Center(
            child: Icon(
              accessory.icon,
              color: _getContrastColor(accessoryColor),
              size: size * 0.08,
            ),
          ),
        ),
      );
    }
  }

  // Helper methods for colors
  Color _getLighterColor(Color color) {
    return HSLColor.fromColor(color)
        .withLightness(
          (HSLColor.fromColor(color).lightness + 0.2).clamp(0.0, 1.0),
        )
        .toColor();
  }

  Color _getDarkerColor(Color color) {
    return HSLColor.fromColor(color)
        .withLightness(
          (HSLColor.fromColor(color).lightness - 0.2).clamp(0.0, 1.0),
        )
        .toColor();
  }

  Color _getContrastColor(Color color) {
    return color.computeLuminance() > 0.5 ? Colors.black : Colors.white;
  }
}
