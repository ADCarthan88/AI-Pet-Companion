import 'package:flutter/material.dart';
import '../models/pet.dart';
import '../models/store_item.dart';

class PetSuppliesStoreScreen extends StatefulWidget {
  const PetSuppliesStoreScreen({
    super.key,
    required this.pet,
    required this.onItemPurchased,
  });

  final Pet pet;
  final Function(StoreItem) onItemPurchased;

  @override
  State<PetSuppliesStoreScreen> createState() => _PetSuppliesStoreScreenState();
}

class _PetSuppliesStoreScreenState extends State<PetSuppliesStoreScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Color? _selectedColor;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: ItemCategory.values.length,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showItemDetails(StoreItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(item.name),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.description),
              const SizedBox(height: 16),
              Text('Price: ${item.price} coins'),
              if (item.happinessBoost != 0)
                Text('Happiness: +${item.happinessBoost}'),
              if (item.energyBoost != 0)
                Text(
                  'Energy: ${item.energyBoost > 0 ? "+" : ""}${item.energyBoost}',
                ),
              if (item.healthBoost != 0) Text('Health: +${item.healthBoost}'),
              if (item.cleanlinessBoost != 0)
                Text('Cleanliness: +${item.cleanlinessBoost}'),
              const SizedBox(height: 16),
              if (item.availableColors.isNotEmpty) ...[
                const Text('Available Colors:'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: item.availableColors.map((color) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedColor = color;
                        });
                      },
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _selectedColor == color
                                ? Colors.blue
                                : Colors.grey,
                            width: _selectedColor == color ? 2 : 1,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          if (!item.isOwned)
            ElevatedButton(
              onPressed: () {
                if (widget.pet.canAfford(item.price)) {
                  setState(() {
                    if (_selectedColor != null) {
                      item.selectedColor = _selectedColor;
                    }
                  });

                  // Purchase the item and add it to the pet's owned items
                  bool purchased = widget.pet.purchaseItem(item);

                  if (purchased) {
                    widget.onItemPurchased(item);
                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Purchased ${item.name}! You can now use it from your inventory.',
                        ),
                        backgroundColor: Colors.green,
                        action: SnackBarAction(
                          label: 'Use Now',
                          onPressed: () {
                            widget.pet.setActiveItem(item);
                          },
                        ),
                      ),
                    );
                  }
                } else {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Not enough coins to purchase ${item.name}!',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: Text('Purchase (${item.price.toInt()} coins)'),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pet Supplies Store'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: ItemCategory.values.map((category) {
            return Tab(
              text: category.toString().split('.').last,
              icon: Icon(_getCategoryIcon(category)),
            );
          }).toList(),
          onTap: null,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: ItemCategory.values.map((category) {
          final items = StoreItem.getItemsByCategory(category, widget.pet.type);
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Card(
                child: InkWell(
                  onTap: () => _showItemDetails(item),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          item.icon,
                          size: 48,
                          color:
                              item.selectedColor ??
                              Theme.of(context).primaryColor,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item.name,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${item.price} coins',
                          style: TextStyle(
                            color: item.isOwned ? Colors.green : Colors.blue,
                          ),
                        ),
                        if (item.isOwned)
                          const Chip(
                            label: Text('Owned'),
                            backgroundColor: Colors.green,
                            labelStyle: TextStyle(color: Colors.white),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }

  IconData _getCategoryIcon(ItemCategory category) {
    switch (category) {
      case ItemCategory.food:
        return Icons.restaurant;
      case ItemCategory.toys:
        return Icons.toys;
      case ItemCategory.furniture:
        return Icons.chair;
      case ItemCategory.accessories:
        return Icons.style;
      case ItemCategory.grooming:
        return Icons.brush;
      case ItemCategory.beds:
        return Icons.bed;
      case ItemCategory.treats:
        return Icons.cake;
      case ItemCategory.healthCare:
        return Icons.healing;
      case ItemCategory.weatherItems:
        return Icons.wb_cloudy;
    }
  }
}
