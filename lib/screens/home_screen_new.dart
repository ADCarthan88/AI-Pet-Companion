import 'package:flutter/material.dart';
import '../models/pet.dart';
import '../models/pet_habitat.dart';
import '../models/toy.dart';
import '../models/weather_system.dart';
import '../widgets/toy_selection_widget.dart';
import '../widgets/advanced_interactive_pet_widget.dart';
import '../widgets/pet_visualizations/pet_visualization_factory.dart';
import '../widgets/pet_owned_items_widget.dart';
import '../widgets/pet_environment_items_widget.dart';
import '../widgets/pet_bathing_widget.dart';
import '../widgets/petting_detector_widget.dart';
import '../models/pet_extensions.dart';
import 'pet_store_screen.dart';
import 'pet_supplies_store_screen.dart';
import 'trick_training_screen.dart';
import 'habitat_customization_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late List<Pet> pets;
  int _selectedPetIndex = 0;
  bool _showToySelection = false;
  bool _showEnvironmentItems = false;
  bool _showPetItems = false;

  // Animation controller for pet licking animation
  late AnimationController _lickingController;

  @override
  void initState() {
    super.initState();

    // Create a default pet if none exists
    pets = [
      Pet(
        name: 'Buddy',
        type: PetType.dog,
        happiness: 80,
        energy: 90,
        hunger: 20,
        cleanliness: 90,
        mood: PetMood.happy,
        currentActivity: PetActivity.idle,
        gender: PetGender.male,
        color: Colors.brown,
        coins: 100,
        inventory: [],
        ownedItems: [],
        tricks: [],
        habitat: PetHabitat(
          petType: PetType.dog,
          floorColor: Colors.brown.shade300,
          wallColor: Colors.blue.shade100,
          background: 'assets/images/habitats/basic_home.png',
          weather: WeatherType.sunny,
        ),
        preferredWeather: WeatherType.sunny,
        unlockedGames: [],
      ),
    ];

    _lickingController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // Set up a periodic timer to update pet state
    Future.delayed(const Duration(seconds: 1), _updatePetState);
  }

  @override
  void dispose() {
    _lickingController.dispose();
    super.dispose();
  }

  void _updatePetState() {
    if (!mounted) return;

    setState(() {
      for (final pet in pets) {
        pet.updateState();
      }
    });

    // Schedule the next update
    Future.delayed(const Duration(seconds: 30), _updatePetState);
  }

  Pet get currentPet => pets[_selectedPetIndex];

  void _feedPet() {
    setState(() {
      currentPet.feed();
    });
  }

  void _bathePet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: BoxDecoration(
            color: Colors.lightBlue.shade50,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Bath Time!',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: PetBathingWidget(
                  pet: currentPet,
                  onBathComplete: () {
                    // Close modal and update pet state
                    Navigator.pop(context);
                    setState(() {
                      currentPet.clean();
                    });
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showPetCustomizationScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return PetStoreScreen(
            onPetSelected: (Pet newPet) {
              setState(() {
                pets.add(newPet);
                _selectedPetIndex = pets.length - 1;
              });
            },
          );
        },
      ),
    );
  }

  void _showPetSuppliesStore() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PetSuppliesStoreScreen(
          pet: currentPet,
          onItemPurchased: (item) {
            setState(() {
              currentPet.coins -= item.price;
              currentPet.ownedItems.add(item);
            });
          },
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

  void _showHabitatCustomization() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HabitatCustomizationScreen(
          pet: currentPet,
          habitat: currentPet.habitat ?? PetHabitat(petType: currentPet.type),
        ),
      ),
    );
  }

  void _showSocialFeatures() {
    // Not implemented yet
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Social features coming soon!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pet Companion'),
        actions: [
          IconButton(
            icon: const Icon(Icons.currency_exchange),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Coins: ${currentPet.coins.toStringAsFixed(0)}',
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background based on pet habitat
          if (currentPet.habitat != null)
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(currentPet.habitat!.background),
                  fit: BoxFit.cover,
                ),
              ),
            ),

          // DragTarget for dropping toys on the screen
          SizedBox.expand(
            child: DragTarget<Toy>(
              builder: (context, candidateData, rejectedData) {
                return const SizedBox.expand();
              },
              onAccept: (Toy toy) {
                setState(() {
                  // Calculate the position relative to the screen size
                  final RenderBox box = context.findRenderObject() as RenderBox;
                  final Offset localPosition = box.globalToLocal(Offset.zero);

                  // This passes both the toy and where it was thrown
                  currentPet.playWithToy(toy, throwPosition: localPosition);

                  // Trigger the pet to move toward this position
                  if (currentPet.currentToy != null &&
                      currentPet.currentToy!.throwPosition != null) {
                    // This toy throw position will be used by the AdvancedInteractivePetWidget
                    print(
                      'Toy thrown to: ${currentPet.currentToy!.throwPosition}',
                    );
                  }
                });
              },
            ),
          ),
          Column(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    // Weather effects overlay if needed
                    if (currentPet.habitat?.currentWeather != null)
                      _buildWeatherOverlay(currentPet.habitat!.currentWeather),

                    // Petting detector wraps the pet visualization
                    PettingDetectorWidget(
                      pet: currentPet,
                      onPetting: (isPetting) {
                        if (isPetting) {
                          setState(() {
                            currentPet.happiness = (currentPet.happiness + 1)
                                .clamp(0, 100);
                            if (currentPet.happiness > 90) {
                              currentPet.mood = PetMood.loving;
                            } else if (currentPet.happiness > 70) {
                              currentPet.mood = PetMood.happy;
                            }
                          });
                        }
                      },
                      child: Center(
                        child: AdvancedInteractivePetWidget(
                          pet: currentPet,
                          onTap: () {
                            // Toggle licking animation when pet is tapped
                            if (!currentPet.isLicking) {
                              setState(() {
                                currentPet.startLicking();
                                _lickingController.forward(from: 0).then((_) {
                                  _lickingController.reverse().then((_) {
                                    setState(() {
                                      currentPet.stopLicking();
                                    });
                                  });
                                });
                              });
                            }
                          },
                          onLongPress: () {
                            // Show mood/emotion dialog
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text('${currentPet.name} is feeling...'),
                                content: Text(
                                  _getMoodDescription(currentPet.mood),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Close'),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Bottom area for actions and toys
              Container(
                color: Colors.white.withOpacity(0.8),
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildActionButton('Feed', () => _feedPet()),
                        _buildActionButton('Bathe', () => _bathePet()),
                        _buildActionButton(
                          'Habitat',
                          () => _showHabitatCustomization(),
                        ),
                        _buildActionButton(
                          'Toys',
                          () => setState(
                            () => _showToySelection = !_showToySelection,
                          ),
                        ),
                        _buildActionButton(
                          'Social',
                          () => _showSocialFeatures(),
                        ),
                      ],
                    ),
                    if (_showToySelection)
                      ToySelectionWidget(
                        pet: currentPet,
                        onToySelected: (toy) {
                          print('DEBUG: Toy selected: ${toy.name}');
                          setState(() {
                            if (currentPet.currentActivity ==
                                    PetActivity.playingWithToy &&
                                currentPet.currentToy == toy) {
                              print(
                                'DEBUG: Stopping play with toy: ${toy.name}',
                              );
                              currentPet.stopPlayingWithToy();
                            } else {
                              print('DEBUG: Playing with toy: ${toy.name}');
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
                              onTap: () =>
                                  setState(() => _selectedPetIndex = index),
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
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _getPetTypeIcon(pet.type),
                                      color: pet.color,
                                    ),
                                    Text(
                                      pet.name,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontWeight: _selectedPetIndex == index
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ],
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
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: _showPetCustomizationScreen,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Store'),
          BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Train'),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              // Already on home screen
              break;
            case 1:
              _showPetSuppliesStore();
              break;
            case 2:
              _showTrickTraining();
              break;
          }
        },
      ),
    );
  }

  Widget _buildWeatherOverlay(WeatherType weatherType) {
    switch (weatherType) {
      case WeatherType.sunny:
        return Container(); // No overlay for sunny
      case WeatherType.rainy:
        return _buildRainOverlay();
      case WeatherType.snowy:
        return _buildSnowOverlay();
      case WeatherType.cloudy:
        return _buildCloudOverlay();
      case WeatherType.stormy:
        return _buildStormyOverlay();
      default:
        return Container();
    }
  }

  Widget _buildRainOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.blueGrey.withOpacity(0.3),
            Colors.blueGrey.withOpacity(0.1),
          ],
        ),
      ),
    );
  }

  Widget _buildSnowOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withOpacity(0.3),
            Colors.white.withOpacity(0.1),
          ],
        ),
      ),
    );
  }

  Widget _buildCloudOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.grey.withOpacity(0.3), Colors.grey.withOpacity(0.1)],
        ),
      ),
    );
  }

  Widget _buildStormyOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.indigo.withOpacity(0.3),
            Colors.indigo.withOpacity(0.1),
          ],
        ),
      ),
    );
  }

  String _getMoodDescription(PetMood mood) {
    switch (mood) {
      case PetMood.happy:
        return 'Happy and content!';
      case PetMood.sad:
        return 'Feeling a bit down...';
      case PetMood.excited:
        return 'Excited and full of energy!';
      case PetMood.tired:
        return 'Tired and needs rest.';
      case PetMood.loving:
        return 'Feeling very affectionate!';
      case PetMood.neutral:
        return 'Feeling neutral.';
    }
  }

  IconData _getPetTypeIcon(PetType type) {
    switch (type) {
      case PetType.dog:
        return Icons.pets;
      case PetType.cat:
        return Icons.content_cut;
      case PetType.bird:
        return Icons.flutter_dash;
      case PetType.rabbit:
        return Icons.cruelty_free;
      case PetType.lion:
        return Icons.assured_workload;
      case PetType.giraffe:
        return Icons.height;
      case PetType.penguin:
        return Icons.ac_unit;
      case PetType.panda:
        return Icons.nature;
    }
  }

  Widget _buildActionButton(String label, VoidCallback onPressed) {
    return ElevatedButton(onPressed: onPressed, child: Text(label));
  }
}
