import 'package:flutter/material.dart';
import '../models/pet.dart';
import '../widgets/toy_selection_widget.dart';
import '../widgets/advanced_interactive_pet_widget.dart';
import '../widgets/pet_visualizations/pet_visualization_factory.dart';
import 'pet_store_screen.dart';
import 'pet_supplies_store_screen.dart';
import 'trick_training_screen.dart';
import 'package:ai_pet_companion/screens/_emotion_backdrop.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  List<Pet> pets = [];
  int _selectedPetIndex = 0;
  late AnimationController _lickingController;
  bool _petStoreShown = false;

  Pet get currentPet => pets[_selectedPetIndex];

  @override
  void initState() {
    super.initState();
    _lickingController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (pets.isEmpty && !_petStoreShown) {
        _petStoreShown = true;
        _showPetCustomizationScreen();
      }
    });
    Future.delayed(const Duration(seconds: 1), _periodicUpdate);
  }

  void _periodicUpdate() {
    if (mounted) {
      setState(() {
        for (final pet in pets) {
          // Update pet state
          pet.updateState();
        }
      });
      Future.delayed(const Duration(seconds: 1), _periodicUpdate);
    }
  }

  void _showPetCustomizationScreen() {
    print('DEBUG: _showPetCustomizationScreen called');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          print('DEBUG: Navigating to PetStoreScreen');
          return PetStoreScreen(
            onPetSelected: (Pet newPet) {
              print(
                'DEBUG: onPetSelected fired with pet: \\${newPet.name}, type: \\${newPet.type}',
              );
              setState(() {
                pets.add(newPet);
                _selectedPetIndex = pets.length - 1;
                print('DEBUG: pets list now has \\${pets.length} pets.');
              });
            },
          );
        },
      ),
    );
  }

  void _updatePet() {
    setState(() {
      currentPet.decideNextAction();
    });
  }

  @override
  Widget build(BuildContext context) {
    print(
      'DEBUG: HomeScreen build called. pets.length = \\${pets.length}, _selectedPetIndex = \\${_selectedPetIndex}',
    );
    if (pets.isEmpty) {
      print('DEBUG: pets is empty, showing loading indicator.');
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    print(
      'DEBUG: Showing main menu for pet: \\${currentPet.name}, type: \\${currentPet.type}',
    );
    return Scaffold(
      appBar: AppBar(
        title: Text('AI Pet Companion - ${currentPet.name}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              print('DEBUG: PetSuppliesStore icon pressed.');
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PetSuppliesStoreScreen(
                    pet: currentPet,
                    onItemPurchased: (item) {
                      print('DEBUG: Item purchased: \\${item.name}');
                      setState(() {
                        currentPet.purchaseItem(item);
                      });
                    },
                  ),
                ),
              );
            },
            tooltip: 'Pet Supplies Store',
          ),
          IconButton(
            icon: const Icon(Icons.pets),
            onPressed: _showPetCustomizationScreen,
            tooltip: 'Add new pet',
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(child: EmotionBackdrop(mood: currentPet.mood)),
          Column(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildFeatureButton(
                      icon: Icons.school,
                      label: 'Train',
                      onPressed: () => _showTrickTraining(),
                    ),
                    _buildFeatureButton(
                      icon: Icons.wb_sunny,
                      label: 'Weather',
                      onPressed: () => _showWeatherControl(),
                    ),
                    _buildFeatureButton(
                      icon: Icons.home,
                      label: 'Habitat',
                      onPressed: () => _showHabitatCustomization(),
                    ),
                    _buildFeatureButton(
                      icon: Icons.games,
                      label: 'Games',
                      onPressed: () => _showMiniGames(),
                    ),
                    _buildFeatureButton(
                      icon: Icons.people,
                      label: 'Social',
                      onPressed: () => _showSocialFeatures(),
                    ),
                  ],
                ),
              ),
              ToySelectionWidget(
                pet: currentPet,
                onToySelected: (toy) {
                  print('DEBUG: Toy selected: \\${toy.name}');
                  setState(() {
                    if (currentPet.currentActivity ==
                            PetActivity.playingWithToy &&
                        currentPet.currentToy == toy) {
                      print('DEBUG: Stopping play with toy: \\${toy.name}');
                      currentPet.stopPlayingWithToy();
                    } else {
                      print('DEBUG: Playing with toy: \\${toy.name}');
                      currentPet.playWithToy(toy);
                    }
                  });
                },
              ),
              if (pets.length > 1)
                SizedBox(
                  height: 70,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: pets.length,
                    itemBuilder: (context, index) {
                      final pet = pets[index];
                      return GestureDetector(
                        onTap: () => setState(() => _selectedPetIndex = index),
                        child: Container(
                          width: 60,
                          margin: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: _selectedPetIndex == index
                                ? Colors.blue.withOpacity(0.3)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 40,
                                height: 40,
                                child:
                                    PetVisualizationFactory.getPetVisualization(
                                      pet: pet,
                                      isBlinking: false,
                                      mouthOpen: false,
                                      size: 40,
                                    ),
                              ),
                              Text(
                                pet.name,
                                style: const TextStyle(fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      child: _buildStatusIndicator(
                        'Happiness',
                        currentPet.happiness,
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: _buildStatusIndicator('Energy', currentPet.energy),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: _buildStatusIndicator('Hunger', currentPet.hunger),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: AdvancedInteractivePetWidget(
                  pet: currentPet,
                  onTap: () {
                    print('DEBUG: Pet tapped. mood = ${currentPet.mood}');
                    setState(() {
                      if (currentPet.mood == PetMood.happy ||
                          currentPet.mood == PetMood.loving) {
                        print('DEBUG: Starting licking animation.');
                        currentPet.startLicking();
                      }
                    });
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  alignment: WrapAlignment.center,
                  children: [
                    _buildActionButton('Feed', () {
                      print('DEBUG: Feed button pressed.');
                      setState(() => currentPet.feed());
                    }),
                    _buildActionButton('Snack', () {
                      print('DEBUG: Snack button pressed.');
                      setState(() => currentPet.feed(isSnack: true));
                    }),
                    _buildActionButton('Play', () {
                      print('DEBUG: Play button pressed.');
                      setState(() => currentPet.play());
                    }),
                    _buildActionButton('Clean', () {
                      print('DEBUG: Clean button pressed.');
                      setState(() => currentPet.clean());
                    }),
                    _buildActionButton('Brush', () {
                      print('DEBUG: Brush button pressed.');
                      setState(() => currentPet.brush());
                    }),
                    _buildActionButton('Rest', () {
                      print('DEBUG: Rest button pressed.');
                      setState(() => currentPet.rest());
                    }),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _updatePet,
        child: const Icon(Icons.psychology),
        tooltip: 'Let AI decide next action',
      ),
    );
  }

  Widget _buildFeatureButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
    );
  }

  void _showTrickTraining() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TrickTrainingScreen(pet: currentPet),
      ),
    );
  }

  void _showWeatherControl() {}
  void _showHabitatCustomization() {}
  void _showMiniGames() {}
  void _showSocialFeatures() {}

  @override
  void dispose() {
    _lickingController.dispose();
    super.dispose();
  }

  Widget _buildStatusIndicator(String label, int value) {
    return Column(
      children: [
        Text(label),
        const SizedBox(height: 8),
        LinearProgressIndicator(value: value / 100, minHeight: 10),
        Text('$value%'),
      ],
    );
  }

  Widget _buildActionButton(String label, VoidCallback onPressed) {
    return ElevatedButton(onPressed: onPressed, child: Text(label));
  }
}
