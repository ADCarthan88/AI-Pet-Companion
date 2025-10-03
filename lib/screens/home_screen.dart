import 'package:flutter/material.dart';
import 'dart:async';
import '../models/pet.dart';
import '../models/pet_habitat.dart';
import '../models/toy.dart';
import '../models/weather_system.dart';
import '../widgets/toy_selection_widget.dart';
import '../widgets/advanced_interactive_pet_widget.dart';
import '../widgets/habitat_renderer.dart';
import '../widgets/pet_bathing_widget.dart';
import '../widgets/petting_detector_widget.dart';
import '../models/pet_extensions.dart';
import 'pet_store_screen.dart';
import 'pet_supplies_store_screen.dart';
import 'trick_training_screen.dart';
import 'habitat_customization_screen.dart';
import '../services/sound_settings_service.dart';
import '../services/ambient_audio_service.dart' as ambient;
import '../services/pet_sound_service.dart';
import '../utils/debug_log.dart';

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
  final GlobalKey _petAreaKey = GlobalKey();

  // Animation controller for pet licking animation
  late AnimationController _lickingController;
  Timer? _initialUpdateTimer;
  Timer? _periodicUpdateTimer;
  ambient.AmbientAudioService? _ambientService;
  Timer? _ambientTimer;

  @override
  void initState() {
    super.initState();

    // Create a default pet if none exists
    pets = [
      Pet(
        name: 'Buddy',
        type: PetType.dog,
        gender: PetGender.male,
        happiness: 80,
        energy: 90,
        hunger: 20,
        cleanliness: 90,
        mood: PetMood.happy,
        currentActivity: PetActivity.idle,
        color: Colors.brown,
      ),
    ];

    _lickingController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    if (!PetSoundService.testingMode) {
      _ambientService = ambient.AmbientAudioService();
      _updateAmbient();
      _ambientTimer = Timer.periodic(
        const Duration(minutes: 2),
        (_) => _updateAmbient(),
      );
    }

    // Schedule initial update then start periodic updates
    _initialUpdateTimer = Timer(const Duration(seconds: 1), () {
      if (!mounted) return;
      _updatePetState();
      _startPeriodicUpdates();
    });
  }

  @override
  void dispose() {
    _initialUpdateTimer?.cancel();
    _periodicUpdateTimer?.cancel();
    _ambientTimer?.cancel();
    _ambientService?.dispose();
    for (final p in pets) {
      p.cancelTimers();
    }
    _lickingController.dispose();
    super.dispose();
  }

  void _updateAmbient() {
    final habitat = currentPet.habitat ?? PetHabitat(petType: currentPet.type);
    final hour = DateTime.now().hour;
    ambient.DayPeriod period;
    if (hour >= 5 && hour < 11) {
      period = ambient.DayPeriod.morning;
    } else if (hour >= 11 && hour < 17) {
      period = ambient.DayPeriod.afternoon;
    } else if (hour >= 17 && hour < 21) {
      period = ambient.DayPeriod.evening;
    } else {
      period = ambient.DayPeriod.night;
    }
    _ambientService?.setContext(theme: habitat.theme, period: period);
  }

  void _updatePetState() {
    if (!mounted) return;

    setState(() {
      for (final pet in pets) {
        pet.updateState();
      }
    });

    // (Periodic timer handles repeated scheduling)
  }

  void _startPeriodicUpdates() {
    _periodicUpdateTimer?.cancel();
    _periodicUpdateTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (!mounted) return;
      _updatePetState();
    });
  }

  Pet get currentPet => pets[_selectedPetIndex];

  void _feedPet() {
    setState(() {
      // Feed pet (hunger reduction) and mark habitat food present.
      currentPet.feed();
      currentPet.addFoodToHabitat();
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
          IconButton(
            icon: const Icon(Icons.volume_up),
            onPressed: () => _showSoundSettings(),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background based on pet habitat - using colors instead of images
          if (currentPet.habitat != null)
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    currentPet.habitat!.wallColor,
                    currentPet.habitat!.floorColor,
                  ],
                ),
              ),
            ),

          // DragTarget for dropping toys on the screen
          SizedBox.expand(
            child: DragTarget<Toy>(
              builder: (context, candidateData, rejectedData) {
                return const SizedBox.expand();
              },
              onAcceptWithDetails: (details) {
                setState(() {
                  final RenderBox box = context.findRenderObject() as RenderBox;
                  final Offset localPosition = box.globalToLocal(details.offset);
                  currentPet.playWithToy(details.data, throwPosition: localPosition);
                });
              },
            ),
          ),
          Column(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    if (currentPet.habitat != null)
                      Positioned.fill(
                        child: HabitatRenderer(
                          habitat: currentPet.habitat!,
                          pet: currentPet,
                        ),
                      ),
                    // Overlay pet interaction widget on top of habitat renderer
                    KeyedSubtree(
                      key: _petAreaKey,
                      child: Align(
                        alignment: Alignment.center,
                        child: PettingDetectorWidget(
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
                          child: AdvancedInteractivePetWidget(
                            pet: currentPet,
                            onTap: () {
                              if (!currentPet.isLicking) {
                                setState(() {
                                  currentPet.startLicking();
                                  _lickingController.forward(from: 0).then((_) {
                                    _lickingController.reverse().then((_) {
                                      setState(() => currentPet.stopLicking());
                                    });
                                  });
                                });
                              }
                            },
                            onLongPress: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text('${currentPet.name} is feeling...'),
                                  content: Text(_getMoodDescription(currentPet.mood)),
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
                    ),
                  ],
                ),
              ),

              // Bottom area for actions and toys
              Container(
                color: Colors.white.withValues(alpha: 0.8),
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildActionButton('Feed', () => _feedPet()),
                        _buildActionButton('Refill Food', () {
                          setState(() => currentPet.refillFoodBowl());
                        }),
                        _buildActionButton('Refill Water', () {
                          setState(() => currentPet.refillWaterBowl());
                        }),
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
                          debugLog('Toy selected: ${toy.name}');
                          setState(() {
                            if (currentPet.currentActivity ==
                                    PetActivity.playingWithToy &&
                                currentPet.currentToy == toy) {
                              debugLog('Stopping play with toy: ${toy.name}');
                              currentPet.stopPlayingWithToy();
                            } else {
                              debugLog('Playing with toy: ${toy.name}');
                              currentPet.playWithToy(toy);
                            }
                          });
                        },
                        onToyThrown: (toy, globalPos, velocity) {
                          // Convert global position to local pet area coordinates
                          final renderBox =
                              _petAreaKey.currentContext?.findRenderObject()
                                  as RenderBox?;
                          if (renderBox != null) {
                            final local = renderBox.globalToLocal(globalPos);
                            setState(() {
                              currentPet.playWithToy(toy, throwPosition: local);
                              // Scale velocity for in-app physics
                              final v = velocity.pixelsPerSecond;
                              // Normalize & damp
                              toy.velocity = Offset(v.dx, v.dy) * 0.02;
                              // Clamp extreme speeds
                              if (toy.velocity.distance > 40) {
                                final f = 40 / toy.velocity.distance;
                                toy.velocity = toy.velocity * f;
                              }
                            });
                          }
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
                    ? Colors.blue.withValues(alpha: 0.3)
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
        onPressed: _showPetCustomizationScreen,
        child: const Icon(Icons.add),
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

  // ignore: unused_element
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
    }
  }

  Widget _buildRainOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.blueGrey.withValues(alpha: 0.3),
            Colors.blueGrey.withValues(alpha: 0.1),
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
            Colors.white.withValues(alpha: 0.3),
            Colors.white.withValues(alpha: 0.1),
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
          colors: [Colors.grey.withValues(alpha: 0.3), Colors.grey.withValues(alpha: 0.1)],
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
            Colors.indigo.withValues(alpha: 0.3),
            Colors.indigo.withValues(alpha: 0.1),
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
        return Icons.catching_pokemon;
      case PetType.bird:
        return Icons.flutter_dash;
      case PetType.rabbit:
        return Icons.cruelty_free;
      case PetType.lion:
        return Icons.face;
      case PetType.giraffe:
        return Icons.height;
      case PetType.penguin:
        return Icons.ac_unit;
      case PetType.panda:
        return Icons.energy_savings_leaf;
    }
  }

  Widget _buildActionButton(String label, VoidCallback onPressed) {
    return ElevatedButton(onPressed: onPressed, child: Text(label));
  }

  void _showSoundSettings() {
    final service = SoundSettingsService();
    service.ensureLoaded();
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.volume_up),
                      const SizedBox(width: 8),
                      const Text(
                        'Sound Settings',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: Icon(
                          service.muted ? Icons.volume_off : Icons.volume_mute,
                        ),
                        onPressed: () async {
                          await service.setMuted(!service.muted);
                          setModalState(() {});
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Master Volume: ${(service.masterVolume * 100).round()}%',
                  ),
                  Slider(
                    value: service.masterVolume,
                    onChanged: (v) async {
                      await service.setVolume(v);
                      setModalState(() {});
                    },
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Checkbox(
                        value: service.muted,
                        onChanged: (v) async {
                          await service.setMuted(v ?? false);
                          setModalState(() {});
                        },
                      ),
                      const Text('Mute All'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
