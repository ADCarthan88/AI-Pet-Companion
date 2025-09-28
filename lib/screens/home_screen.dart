import 'package:flutter/material.dart';
import '../models/pet.dart';
import '../widgets/toy_selection_widget.dart';
import 'pet_store_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

@visibleForTesting
class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  List<Pet> pets = [];
  late AnimationController _lickingController;
  late Animation<double> _lickingAnimation;
  int _selectedPetIndex = 0;

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

    // Show pet customization screen on startup if no pets
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (pets.isEmpty) {
        _showPetCustomizationScreen();
      }
    });

    // Set up periodic updates
    Future.delayed(const Duration(seconds: 1), _periodicUpdate);
  }

  void _periodicUpdate() {
    if (mounted) {
      setState(() {
        for (final pet in pets) {
          pet.updateState();
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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PetStoreScreen(
          onPetSelected: (Pet newPet) {
            setState(() {
              pets.add(newPet);
              _selectedPetIndex = pets.length - 1;
            });
          },
        ),
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
            icon: const Icon(Icons.pets),
            onPressed: _showPetCustomizationScreen,
            tooltip: 'Add new pet',
          ),
        ],
      ),
      body: Column(
        children: [
          ToySelectionWidget(
            pet: currentPet,
            onToySelected: (toy) {
              setState(() {
                if (currentPet.currentActivity == PetActivity.playingWithToy &&
                    currentPet.currentToy == toy) {
                  currentPet.stopPlayingWithToy();
                } else {
                  currentPet.playWithToy(toy);
                }
              });
            },
          ),
          // Pet selection
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

          // Pet status section
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

          // Pet display area
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
                      scale: currentPet.currentActivity == PetActivity.licking
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
                            style: Theme.of(context).textTheme.headlineSmall,
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

          // Action buttons
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
      floatingActionButton: FloatingActionButton(
        onPressed: _updatePet,
        child: const Icon(Icons.psychology),
        tooltip: 'Let AI decide next action',
      ),
    );
  }

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
