import 'package:flutter/material.dart';
import '../models/pet.dart';
import '../models/store_item.dart';

class PetOwnedItemsWidget extends StatelessWidget {
  final Pet pet;
  final Function(StoreItem) onItemSelected;
  final StoreItem? activeItem;

  const PetOwnedItemsWidget({
    Key? key,
    required this.pet,
    required this.onItemSelected,
    this.activeItem,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get all owned items for this pet
    final ownedItems = pet.ownedItems
        .where(
          (item) =>
              item.suitableFor.contains(pet.type) || item.suitableFor.isEmpty,
        )
        .toList();

    if (ownedItems.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(8.0),
        child: Text(
          "No items yet! Visit the store to buy toys, food, and more for your pet.",
          textAlign: TextAlign.center,
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            'My Items',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: ownedItems.length,
            itemBuilder: (context, index) {
              final item = ownedItems[index];
              final isActive = activeItem != null && activeItem?.id == item.id;

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () => onItemSelected(item),
                  child: Column(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: item.selectedColor ?? Colors.grey.shade200,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isActive
                                ? Colors.blue.shade700
                                : Colors.grey,
                            width: isActive ? 3 : 1,
                          ),
                          boxShadow: isActive
                              ? [
                                  BoxShadow(
                                    color: Colors.blue.withOpacity(0.8),
                                    blurRadius: 10,
                                    spreadRadius: 3,
                                  ),
                                ]
                              : null,
                        ),
                        child: Icon(
                          item.icon,
                          color: _getIconColor(item.category),
                          size: 30,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.name,
                        style: TextStyle(
                          fontWeight: isActive
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isActive ? Colors.blue : Colors.black,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Color _getIconColor(ItemCategory category) {
    switch (category) {
      case ItemCategory.food:
        return Colors.orange;
      case ItemCategory.toys:
        return Colors.purple;
      case ItemCategory.furniture:
        return Colors.brown;
      case ItemCategory.accessories:
        return Colors.pink;
      case ItemCategory.grooming:
        return Colors.blue;
      case ItemCategory.beds:
        return Colors.indigo;
      case ItemCategory.treats:
        return Colors.amber;
      case ItemCategory.healthCare:
        return Colors.green;
      case ItemCategory.weatherItems:
        return Colors.lightBlue;
      default:
        return Colors.grey;
    }
  }
}
