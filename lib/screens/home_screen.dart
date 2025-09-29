import 'package:flutter/material.dart';
import '../models/pet.dart';
import '../widgets/toy_selection_widget.dart';
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
  late Animation<double> _lickingAnimation;
  bool _petStoreShown = false;

  Pet get currentPet => pets[_selectedPetIndex];

  @override
  void initState() {
    super.initState();
    _lickingController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _lickingAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _lickingController, curve: Curves.easeInOut),
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
          // You may want to implement updateState in your Pet model
          // pet.updateState();
          if (pet.currentActivity == PetActivity.licking) {
            _lickingController.repeat(reverse: true);
          } else {
            _lickingController.stop();
          }
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
              print('DEBUG: onPetSelected fired with pet: \\${newPet.name}, type: \\${newPet.type}');
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
    if (pets.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('AI Pet Companion - ${currentPet.name}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PetSuppliesStoreScreen(
                    pet: currentPet,
                    onItemPurchased: (item) {
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
                  setState(() {
                    if (currentPet.currentActivity ==
                            PetActivity.playingWithToy &&
                        currentPet.currentToy == toy) {
                      currentPet.stopPlayingWithToy();
                    } else {
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
                              Icon(_getPetIcon(pet.type), color: pet.color),
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
                    _buildStatusIndicator('Happiness', currentPet.happiness),
                    _buildStatusIndicator('Energy', currentPet.energy),
                    _buildStatusIndicator('Hunger', currentPet.hunger),
                  ],
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTapDown: (_) => setState(() {
                    if (currentPet.mood == PetMood.happy ||
                        currentPet.mood == PetMood.loving) {
                      currentPet.startLicking();
                    }
                  }),
                  child: Center(
                    child: AnimatedBuilder(
                      animation: _lickingAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale:
                              currentPet.currentActivity == PetActivity.licking
                              ? _lickingAnimation.value
                              : 1.0,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _getPetIcon(currentPet.type),
                                size: 120,
                                color: currentPet.color,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Mood: ${currentPet.mood.toString().split('.').last}',
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineSmall,
                              ),
                              Text(
                                'Activity: ${currentPet.currentActivity.toString().split('.').last}',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Text(
                                'Cleanliness: ${currentPet.cleanliness}%',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
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
                      setState(() => currentPet.feed());
                    }),
                    _buildActionButton('Snack', () {
                      setState(() => currentPet.feed(isSnack: true));
                    }),
                    _buildActionButton('Play', () {
                      setState(() => currentPet.play());
                    }),
                    _buildActionButton('Clean', () {
                      setState(() => currentPet.clean());
                    }),
                    _buildActionButton('Brush', () {
                      setState(() => currentPet.brush());
                    }),
                    _buildActionButton('Rest', () {
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

  IconData _getPetIcon(PetType type) {
    switch (type) {
      case PetType.dog:
        return Icons.pets;
      case PetType.cat:
        return Icons.catching_pokemon;
      case PetType.bird:
        return Icons.flutter_dash;
      case PetType.rabbit:
        return Icons.cruelty_free;
      default:
        return Icons.pets;
    }
  }
}
