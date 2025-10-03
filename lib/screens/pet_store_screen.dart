import 'package:flutter/material.dart';
import '../utils/debug_log.dart';
import '../models/pet.dart';
import '../models/toy.dart';
import '../widgets/toy_selection_widget.dart';
import '../widgets/pet_visualizations/pet_visualization_factory.dart';

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
  debugLog('PetStoreScreen build');
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
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            // Make pet happy when tapped
                            _previewPet!.happiness =
                                (_previewPet!.happiness + 10).clamp(0, 100);
                            _previewPet!.mood = PetMood.happy;
                          });
                        },
                        child: _buildPetVisualization(),
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
                    Column(
                      children: [
                        const Text(
                          'Choose a color:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: availableColors[_previewPet!.type]!
                              .map(
                                (color) => AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  margin: const EdgeInsets.all(2),
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedColors[_previewPet!.type] =
                                            color;
                                        _previewPet!.color = color;

                                        // Make the pet react to the color change
                                        if (_previewPet!.mood !=
                                            PetMood.excited) {
                                          _previewPet!.mood = PetMood.excited;

                                          // Reset mood after a short delay
                                          Future.delayed(
                                            const Duration(seconds: 1),
                                            () {
                                              if (mounted) {
                                                setState(() {
                                                  _previewPet!.mood =
                                                      PetMood.neutral;
                                                });
                                              }
                                            },
                                          );
                                        }
                                      });
                                    },
                                    child: Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: color,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: _previewPet!.color == color
                                              ? Theme.of(context).primaryColor
                                              : Colors.grey,
                                          width: 2,
                                        ),
                                        boxShadow: _previewPet!.color == color
                                            ? [
                                                BoxShadow(
                                                  color: color.withValues(alpha: 0.5),
                                                  blurRadius: 8,
                                                  spreadRadius: 2,
                                                ),
                                              ]
                                            : null,
                                      ),
                                      child: _previewPet!.color == color
                                          ? const Icon(
                                              Icons.check,
                                              color: Colors.white,
                                            )
                                          : null,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ],
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
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.sports_baseball),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        elevation: 4,
                      ),
                      onPressed: _nameController.text.isEmpty
                          ? null
                          : () {
                              // Get a random toy suitable for this pet type
                              final toys = Toy.getToysForPetType(
                                _previewPet!.type,
                              );
                              if (toys.isNotEmpty) {
                                final randomToy = toys.first;

                                setState(() {
                                  _previewPet!.playWithToy(randomToy);

                                  // Show animation effects
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '${_previewPet!.name} is playing with a ${randomToy.name}!',
                                      ),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                });

                                // Reset after play
                                Future.delayed(const Duration(seconds: 3), () {
                                  if (mounted) {
                                    setState(() {
                                      _previewPet!.currentActivity =
                                          PetActivity.idle;
                                    });
                                  }
                                });
                              }
                            },
                      label: const Text('Try Playing'),
                    ),
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.pets),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () {
                      final name = _nameController.text.trim();
                      if (name.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please give your pet a name'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        _nameFocusNode.requestFocus();
                        return;
                      }

                      // Create a happy animation effect before selecting
                      setState(() {
                        _previewPet!.mood = PetMood.excited;
                      });

                      // Add a small delay for the animation effect
                      Future.delayed(const Duration(milliseconds: 500), () {
                        if (!mounted) return; // Guard against async gap context use
                        final chosenPet = Pet(
                          name: name,
                          type: _previewPet!.type,
                          gender: _previewPet!.gender,
                          color: _previewPet!.color,
                          happiness: 80,
                          mood: PetMood.happy,
                        );
                        widget.onPetSelected(chosenPet);
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        }
                      });
                    },
                    label: const Text(
                      'Choose This Pet',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // _getPetIcon removed (unused) to satisfy analyzer.

  // Method to build pet visualization using the factory
  Widget _buildPetVisualization() {
    if (_previewPet == null) {
      return const SizedBox.shrink();
    }

    // We'll use a slightly animated version with random blinking for the store display
    final now = DateTime.now().millisecondsSinceEpoch;
    final isBlinking = (now % 3000) < 200; // Blink briefly every 3 seconds
    final mouthOpen =
        _previewPet!.mood == PetMood.happy; // Open mouth when happy

    return Stack(
      children: [
        // Use the PetVisualizationFactory for consistent appearance
        Positioned.fill(
          child: Center(
            child: SizedBox(
              width: 180,
              height: 180,
              child: PetVisualizationFactory.getPetVisualization(
                pet: _previewPet!,
                isBlinking: isBlinking,
                mouthOpen: mouthOpen,
                size: 180,
              ),
            ),
          ),
        ),

        // Show mood indicator
        if (_previewPet!.mood == PetMood.happy)
          Positioned(
            top: 10,
            right: 10,
            child: Icon(
              Icons.favorite,
              color: Colors.red.withValues(alpha: 0.7),
              size: 24,
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }
}
