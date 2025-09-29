import 'package:flutter/material.dart';
import '../models/pet.dart';
import '../widgets/toy_selection_widget.dart';

class PetStoreScreen extends StatefulWidget {
  final Function(Pet) onPetSelected;

  const PetStoreScreen({super.key, required this.onPetSelected});

  @override
  State<PetStoreScreen> createState() => _PetStoreScreenState();
}

class _PetStoreScreenState extends State<PetStoreScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  Pet? _previewPet;
  final _nameController = TextEditingController();
  final _nameFocusNode = FocusNode();
  final Map<PetType, Color> _selectedColors = {};

  final Map<PetType, String> petTypeDescriptions = {
    PetType.dog: 'Loyal and playful companion, great for active families.',
    PetType.cat: 'Independent and graceful, perfect for cozy homes.',
    PetType.bird: 'Cheerful and musical friend that brings life to any room.',
    PetType.rabbit: 'Gentle and quiet pet, ideal for calm environments.',
    PetType.lion:
        'Majestic and powerful, requires lots of space and attention.',
    PetType.giraffe: 'Gentle giant with a unique perspective on life.',
    PetType.penguin: 'Charming waddler that loves to swim and slide.',
    PetType.panda: 'Peaceful bamboo enthusiast, brings zen to your home.',
  };

  final Map<PetType, List<Color>> availableColors = {
    PetType.dog: [Colors.brown, Colors.black, Colors.white, Colors.amber[100]!],
    PetType.cat: [Colors.black, Colors.white, Colors.grey, Colors.orange],
    PetType.bird: [Colors.blue, Colors.red, Colors.yellow, Colors.green],
    PetType.rabbit: [Colors.white, Colors.brown, Colors.grey, Colors.black],
    PetType.lion: [Colors.amber[200]!, Colors.brown[300]!],
    PetType.giraffe: [Colors.orange[300]!, Colors.brown[200]!],
    PetType.penguin: [Colors.black, Colors.grey[850]!],
    PetType.panda: [Colors.black],
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: PetType.values.length, vsync: this);
    for (var type in PetType.values) {
      _selectedColors[type] = availableColors[type]!.first;
    }
    _createPreviewPet(PetType.values.first);
    // Auto-focus name field after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _nameFocusNode.requestFocus();
    });
  }

  void _createPreviewPet(PetType type) {
    setState(() {
      final color = _selectedColors[type] ?? availableColors[type]!.first;
      _previewPet = Pet(
        name: _nameController.text.trim().isEmpty
            ? 'Preview Pet'
            : _nameController.text.trim(),
        type: type,
        gender: PetGender.male,
        color: color,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    print('DEBUG: PetStoreScreen build called');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pet Store'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: PetType.values
              .map(
                (type) =>
                    Tab(text: type.toString().split('.').last.toUpperCase()),
              )
              .toList(),
          onTap: (index) => _createPreviewPet(PetType.values[index]),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              petTypeDescriptions[_previewPet?.type ?? PetType.dog]!,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ),
          if (_previewPet != null) ...[
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        color: _previewPet!.color,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getPetIcon(_previewPet!.type),
                        size: 100,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: TextField(
                        controller: _nameController,
                        focusNode: _nameFocusNode,
                        decoration: const InputDecoration(
                          labelText: 'Give your pet a name',
                          border: OutlineInputBorder(),
                        ),
                        textInputAction: TextInputAction.done,
                        onChanged: (value) =>
                            _createPreviewPet(_previewPet!.type),
                        onSubmitted: (_) =>
                            _createPreviewPet(_previewPet!.type),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      children: availableColors[_previewPet!.type]!
                          .map(
                            (color) => GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedColors[_previewPet!.type] = color;
                                  _previewPet!.color = color;
                                });
                              },
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: _previewPet!.color == color
                                        ? Theme.of(context).primaryColor
                                        : Colors.grey,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                    ToySelectionWidget(
                      pet: _previewPet!,
                      onToySelected: (toy) {
                        setState(() {
                          _previewPet!.playWithToy(toy);
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Tooltip(
                    message: _nameController.text.isEmpty
                        ? 'Please enter a name for your pet first.'
                        : '',
                    child: ElevatedButton(
                      onPressed: _nameController.text.isEmpty
                          ? null
                          : () {
                              _previewPet!.play();
                              setState(() {});
                            },
                      child: const Text('Try Playing'),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      final name = _nameController.text.trim();
                      if (name.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please give your pet a name'),
                          ),
                        );
                        _nameFocusNode.requestFocus();
                        return;
                      }
                      // Pass a new Pet instance to avoid reference issues
                      final chosenPet = Pet(
                        name: name,
                        type: _previewPet!.type,
                        gender: _previewPet!.gender,
                        color: _previewPet!.color,
                      );
                      widget.onPetSelected(chosenPet);
                      Navigator.pop(context);
                    },
                    child: const Text('Choose This Pet'),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  IconData _getPetIcon(PetType type) {
    switch (type) {
      case PetType.dog:
        return Icons.pets;
      case PetType.cat:
        return Icons.copyright;
      case PetType.bird:
        return Icons.flutter_dash;
      case PetType.rabbit:
        return Icons.cruelty_free;
      case PetType.lion:
        return Icons.face;
      case PetType.giraffe:
        return Icons.height;
      case PetType.penguin:
        return Icons.water;
      case PetType.panda:
        return Icons.mood;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }
}
