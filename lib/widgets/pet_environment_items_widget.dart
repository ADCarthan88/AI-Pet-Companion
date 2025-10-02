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
    final itemName = weather.name.toLowerCase();

    // Sun Umbrella
    if (itemName.contains('umbrella')) {
      return Positioned(
        top: size * 0.1,
        right: size * 0.2,
        width: size * 0.3,
        height: size * 0.4,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            // Umbrella top
            Container(
              width: size * 0.28,
              height: size * 0.15,
              decoration: BoxDecoration(
                color: weatherColor,
                borderRadius: BorderRadius.circular(size * 0.15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),

            // Umbrella pole
            Positioned(
              top: size * 0.14,
              child: Container(
                width: size * 0.025,
                height: size * 0.25,
                decoration: BoxDecoration(
                  color: Colors.grey[700],
                  borderRadius: BorderRadius.circular(size * 0.01),
                ),
              ),
            ),

            // Base
            Positioned(
              bottom: 0,
              child: Container(
                width: size * 0.1,
                height: size * 0.02,
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(size * 0.01),
                ),
              ),
            ),
          ],
        ),
      );
    }
    // Rain Coat
    else if (itemName.contains('coat')) {
      return Positioned(
        bottom: size * 0.3,
        right: size * 0.15,
        width: size * 0.2,
        height: size * 0.25,
        child: Stack(
          children: [
            // Coat body
            Container(
              width: size * 0.2,
              height: size * 0.2,
              decoration: BoxDecoration(
                color: weatherColor,
                borderRadius: BorderRadius.circular(size * 0.05),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 2,
                  ),
                ],
              ),
            ),

            // Coat hood
            Positioned(
              top: 0,
              right: size * 0.02,
              child: Container(
                width: size * 0.08,
                height: size * 0.08,
                decoration: BoxDecoration(
                  color: weatherColor,
                  borderRadius: BorderRadius.circular(size * 0.04),
                ),
              ),
            ),

            // Buttons
            Positioned(
              top: size * 0.08,
              left: size * 0.1,
              child: Column(
                children: [
                  Container(
                    width: size * 0.02,
                    height: size * 0.02,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(height: size * 0.02),
                  Container(
                    width: size * 0.02,
                    height: size * 0.02,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
    // Winter Boots
    else if (itemName.contains('boots')) {
      return Positioned(
        bottom: size * 0.05,
        left: size * 0.7,
        child: Row(
          children: [
            _buildBoot(weatherColor),
            SizedBox(width: size * 0.02),
            _buildBoot(weatherColor),
          ],
        ),
      );
    }
    // Storm Shelter
    else if (itemName.contains('shelter')) {
      return Positioned(
        bottom: size * 0.05,
        right: size * 0.1,
        width: size * 0.3,
        height: size * 0.25,
        child: Stack(
          children: [
            // Shelter base
            Container(
              width: size * 0.3,
              height: size * 0.2,
              decoration: BoxDecoration(
                color: weatherColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(size * 0.1),
                  topRight: Radius.circular(size * 0.1),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
            // Door
            Positioned(
              bottom: 0,
              left: size * 0.1,
              child: Container(
                width: size * 0.1,
                height: size * 0.15,
                decoration: BoxDecoration(
                  color: _getDarkerColor(weatherColor),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(size * 0.05),
                    topRight: Radius.circular(size * 0.05),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
    // Heated Igloo
    else if (itemName.contains('igloo')) {
      return Positioned(
        bottom: size * 0.05,
        left: size * 0.1,
        width: size * 0.35,
        height: size * 0.25,
        child: Stack(
          children: [
            // Igloo dome
            Container(
              width: size * 0.35,
              height: size * 0.25,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(size * 0.18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
            // Entrance
            Positioned(
              bottom: 0,
              left: size * 0.12,
              child: Container(
                width: size * 0.12,
                height: size * 0.12,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(size * 0.06),
                    topRight: Radius.circular(size * 0.06),
                  ),
                ),
              ),
            ),
            // Heating indicator
            Positioned(
              top: size * 0.05,
              right: size * 0.05,
              child: Container(
                width: size * 0.05,
                height: size * 0.05,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.8),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      );
    }
    // Mist Generator
    else if (itemName.contains('mist')) {
      return Positioned(
        bottom: size * 0.05,
        right: size * 0.1,
        width: size * 0.2,
        height: size * 0.15,
        child: Stack(
          children: [
            // Base
            Container(
              width: size * 0.2,
              height: size * 0.1,
              decoration: BoxDecoration(
                color: weatherColor,
                borderRadius: BorderRadius.circular(size * 0.05),
              ),
            ),
            // Mist clouds
            Positioned(
              top: -size * 0.05,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  3,
                  (index) => Container(
                    width: size * 0.06,
                    height: size * 0.06,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
    // Default for other weather items
    else {
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
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
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

  // Helper method to build a boot for winter boots item
  Widget _buildBoot(Color color) {
    return Container(
      width: size * 0.06,
      height: size * 0.1,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(size * 0.02),
          topRight: Radius.circular(size * 0.02),
          bottomLeft: Radius.circular(size * 0.01),
          bottomRight: Radius.circular(size * 0.01),
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 2),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            height: size * 0.02,
            decoration: BoxDecoration(
              color: _getDarkerColor(color),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(size * 0.01),
                bottomRight: Radius.circular(size * 0.01),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
