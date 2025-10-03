import 'package:flutter/material.dart';
import '../models/pet_habitat.dart';
import '../models/pet.dart';
import '../widgets/habitat_renderer.dart';

class HabitatCustomizationScreen extends StatefulWidget {
  final Pet pet;
  final PetHabitat habitat;

  const HabitatCustomizationScreen({
    Key? key,
    required this.pet,
    required this.habitat,
  }) : super(key: key);

  @override
  State<HabitatCustomizationScreen> createState() =>
      _HabitatCustomizationScreenState();
}

class _HabitatCustomizationScreenState
    extends State<HabitatCustomizationScreen> {
  late PetHabitat _habitat;
  late List<HabitatItem> _availableItems;
  bool _showingStore = false;

  @override
  void initState() {
    super.initState();
    _habitat = widget.habitat;
    _availableItems = HabitatItem.getItemsForPetType(widget.pet.type);
  }

  void _addItem(HabitatItem item) {
    if (!item.isOwned) {
      // Show purchase confirmation dialog
      _showPurchaseDialog(item);
    } else {
      setState(() {
        _habitat.addItem(item);
      });
    }
  }

  void _addInteractiveElement(String element) {
    setState(() {
      _habitat.addInteractiveElement(element);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added $element to the habitat!'),
          duration: const Duration(seconds: 1),
        ),
      );
    });
  }

  Future<void> _showPurchaseDialog(HabitatItem item) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Purchase ${item.name}?'),
          content: Text('Cost: ${item.cost} coins\n${item.description}'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Purchase'),
              onPressed: () {
                // Check if user can afford item
                if (widget.pet.coins >= item.cost) {
                  setState(() {
                    widget.pet.coins -= item.cost.toInt();
                    item.isOwned = true;
                    _habitat.addItem(item);
                  });
                  Navigator.of(context).pop();
                } else {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Not enough coins to purchase this item!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.pet.name}\'s Habitat'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              setState(() {
                _showingStore = !_showingStore;
              });
            },
            tooltip: 'Habitat Store',
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              Navigator.pop(context, _habitat);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Habitat Visualization
          Expanded(
            flex: 2,
            child: HabitatRenderer(habitat: _habitat, pet: widget.pet),
          ),

          // Either store or controls
          Expanded(
            flex: 1,
            child: _showingStore ? _buildStoreView() : _buildControlsView(),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Habitat Items for ${widget.pet.name}',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _availableItems.length,
            itemBuilder: (context, index) {
              final item = _availableItems[index];
              final bool isOwned = _habitat.items.any(
                (habitatItem) => habitatItem.name == item.name,
              );

              return ListTile(
                leading: Icon(item.icon),
                title: Text(item.name),
                subtitle: Text(item.description),
                trailing: isOwned
                    ? const Icon(Icons.check, color: Colors.green)
                    : Text('\$${item.cost.toInt()}'),
                enabled: !isOwned && widget.pet.coins >= item.cost,
                onTap: isOwned ? null : () => _addItem(item),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildControlsView() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Habitat Controls',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildControlButton(
                icon: Icons.water_drop,
                label: 'Add Water',
                onPressed: () {
                  setState(() {
                    _habitat.addWater();
                  });
                },
              ),
              _buildControlButton(
                icon: Icons.restaurant,
                label: 'Add Food',
                onPressed: () {
                  setState(() {
                    _habitat.addFood();
                  });
                },
              ),
              _buildControlButton(
                icon: Icons.cleaning_services,
                label: 'Clean Habitat',
                onPressed: () {
                  setState(() {
                    _habitat.clean();
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildControlButton(
                icon: Icons.toys,
                label: 'Add Toy',
                onPressed: () => _addInteractiveElement('toy'),
              ),
              _buildControlButton(
                icon: Icons.sports_baseball,
                label: 'Add Ball',
                onPressed: () => _addInteractiveElement('ball'),
              ),
              _buildControlButton(
                icon: Icons.extension,
                label: 'Add Puzzle',
                onPressed: () => _addInteractiveElement('puzzle'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }
}
