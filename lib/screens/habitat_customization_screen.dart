import 'package:flutter/material.dart';
import '../models/pet_habitat.dart';
import '../models/pet.dart';

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

  void _removeItem(HabitatItem item) {
    setState(() {
      _habitat.removeItem(item);
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
                // TODO: Implement currency system and check if user can afford item
                setState(() {
                  item.isOwned = true;
                  _habitat.addItem(item);
                });
                Navigator.of(context).pop();
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
        title: const Text('Customize Habitat'),
        actions: [
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
          // Stats Display
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatIndicator('Happiness', _habitat.happiness),
                _buildStatIndicator('Comfort', _habitat.comfort),
              ],
            ),
          ),
          // Habitat Preview
          Expanded(
            flex: 2,
            child: Container(
              margin: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: _getThemeColor(_habitat.theme),
                borderRadius: BorderRadius.circular(16.0),
                border: Border.all(color: Colors.grey),
              ),
              child: Stack(
                children: [
                  // Habitat Items
                  ..._habitat.items
                      .map(
                        (item) => Positioned(
                          // TODO: Add proper positioning for items
                          child: Icon(item.icon, size: 48, color: Colors.brown),
                        ),
                      )
                      .toList(),
                ],
              ),
            ),
          ),
          // Available Items
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Available Items',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16.0,
                          mainAxisSpacing: 16.0,
                          childAspectRatio: 1.5,
                        ),
                    itemCount: _availableItems.length,
                    itemBuilder: (context, index) {
                      final item = _availableItems[index];
                      final bool isOwned = item.isOwned;
                      final bool isInHabitat = _habitat.items.contains(item);

                      return Card(
                        child: InkWell(
                          onTap: () {
                            if (isInHabitat) {
                              _removeItem(item);
                            } else {
                              _addItem(item);
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  item.icon,
                                  size: 32,
                                  color: isInHabitat ? Colors.blue : null,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  item.name,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: isInHabitat
                                        ? FontWeight.bold
                                        : null,
                                  ),
                                ),
                                if (!isOwned)
                                  Text(
                                    '${item.cost} coins',
                                    style: const TextStyle(color: Colors.green),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatIndicator(String label, double value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Container(
          width: 100,
          height: 10,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(5),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: LinearProgressIndicator(
              value: value / 100,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                value > 70
                    ? Colors.green
                    : value > 30
                    ? Colors.orange
                    : Colors.red,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color _getThemeColor(HabitatTheme theme) {
    switch (theme) {
      case HabitatTheme.jungle:
        return Colors.green[100]!;
      case HabitatTheme.savannah:
        return Colors.orange[100]!;
      case HabitatTheme.arctic:
        return Colors.blue[50]!;
      case HabitatTheme.forest:
        return Colors.green[50]!;
      case HabitatTheme.bambooGrove:
        return Colors.lightGreen[50]!;
      case HabitatTheme.mountain:
        return Colors.grey[100]!;
      case HabitatTheme.desert:
        return Colors.orange[50]!;
      case HabitatTheme.ocean:
        return Colors.blue[100]!;
    }
  }
}
