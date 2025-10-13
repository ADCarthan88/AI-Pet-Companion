import 'package:flutter/material.dart';
import 'dart:async';
import '../models/pet.dart';
import '../models/pet_habitat.dart';
import '../models/toy.dart';
import '../models/store_item.dart';

import '../widgets/toy_selection_widget.dart';
import '../widgets/advanced_interactive_pet_widget.dart';
import '../widgets/realistic_pet_widget.dart';
import '../widgets/habitat_renderer.dart';
import '../widgets/pet_bathing_widget.dart';
import '../widgets/petting_detector_widget.dart';
import '../models/pet_extensions.dart';
import '../widgets/ai_suggestions_widget.dart';

import 'habitat_customization_screen.dart';
import '../services/sound_settings_service.dart';
import '../services/ambient_audio_service.dart' as ambient;
import '../services/new_audio_service.dart';
import '../utils/debug_log.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

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
  final GlobalKey<AdvancedInteractivePetWidgetState> _petWidgetKey = GlobalKey<AdvancedInteractivePetWidgetState>();

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

    if (!NewAudioService.testingMode) {
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

  void _toggleSleep() {
    setState(() {
      if (currentPet.currentActivity == PetActivity.sleeping) {
        // Wake up the pet
        currentPet.currentActivity = PetActivity.idle;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${currentPet.name} woke up refreshed!'),
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        // Put pet to sleep and replenish energy
        currentPet.currentActivity = PetActivity.sleeping;
        currentPet.energy = (currentPet.energy + 20).clamp(0, 100);
        
        // Check if pet has a bed - if so, they'll walk to it
        final hasBed = currentPet.activeItem != null && 
                      currentPet.activeItem!.category == ItemCategory.beds;
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(hasBed 
              ? '${currentPet.name} is walking to bed to sleep...'
              : '${currentPet.name} is taking a nap and gaining energy!'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    });
  }

  void _callPet() {
    // This will trigger the pet widget to reset position if off-screen
    _petWidgetKey.currentState?.resetPetPosition();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Calling ${currentPet.name} back to the habitat!'),
        duration: const Duration(seconds: 2),
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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Social features coming soon!')),
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
                        onPressed: () {
                          service.setMuted(!service.muted);
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
                        onChanged: (v) {
                          service.setMuted(v ?? false);
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
          // Background based on pet habitat
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

          // DragTarget for dropping toys
          SizedBox.expand(
            child: DragTarget<Toy>(
              builder: (context, candidateData, rejectedData) {
                return const SizedBox.expand();
              },
              onAcceptWithDetails: (details) {
                setState(() {
                  final RenderBox box = context.findRenderObject() as RenderBox;
                  final Offset localPosition = box.globalToLocal(
                    details.offset,
                  );
                  currentPet.playWithToy(
                    details.data,
                    throwPosition: localPosition,
                  );
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
                          child: KeyedSubtree(
                            key: _petAreaKey,
                            child: PettingDetectorWidget(
                              pet: currentPet,
                              onPetting: (isPetting) {
                                if (isPetting) {
                                  setState(() {
                                    currentPet.happiness =
                                        (currentPet.happiness + 1).clamp(0, 100);
                                    if (currentPet.happiness > 90) {
                                      currentPet.mood = PetMood.loving;
                                    } else if (currentPet.happiness > 70) {
                                      currentPet.mood = PetMood.happy;
                                    }
                                  });
                                }
                              },
                              child: RealisticPetWidget(
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
                                      title: Text(
                                        '${currentPet.name} is feeling...',
                                      ),
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
                        ),
                      ),
                    // Fallback pet widget if no habitat
                    if (currentPet.habitat == null)
                      KeyedSubtree(
                        key: _petAreaKey,
                        child: Align(
                          alignment: Alignment.center,
                          child: PettingDetectorWidget(
                            pet: currentPet,
                            onPetting: (isPetting) {
                              if (isPetting) {
                                setState(() {
                                  currentPet.happiness =
                                      (currentPet.happiness + 1).clamp(0, 100);
                                  if (currentPet.happiness > 90) {
                                    currentPet.mood = PetMood.loving;
                                  } else if (currentPet.happiness > 70) {
                                    currentPet.mood = PetMood.happy;
                                  }
                                });
                              }
                            },
                            child: RealisticPetWidget(
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
                                    title: Text(
                                      '${currentPet.name} is feeling...',
                                    ),
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
                        _buildActionButton('Sleep', () => _toggleSleep()),
                        _buildActionButton('Call Pet', () => _callPet()),
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
                          final renderBox =
                              _petAreaKey.currentContext?.findRenderObject()
                                  as RenderBox?;
                          if (renderBox != null) {
                            final local = renderBox.globalToLocal(globalPos);
                            setState(() {
                              currentPet.playWithToy(toy, throwPosition: local);
                              final v = velocity.pixelsPerSecond;
                              toy.velocity = Offset(v.dx, v.dy) * 0.02;
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
          
          // AI Assistant overlay
          AIAssistantButton(pet: currentPet),
        ],
      ),
      floatingActionButton: null, // Removed debug button to make room for AI assistant
      /*floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        onPressed: () async {
          print('=== COMPREHENSIVE AUDIO DEBUG TEST ===');

          // Test 1: Check if assets are bundled
          try {
            print('TEST 1: Checking if cat happy file exists...');
            final data = await rootBundle.load('assets/sounds/cat/happy_1.mp3');
            print(
              'TEST 1: SUCCESS - File found, size: ${data.lengthInBytes} bytes',
            );
          } catch (e) {
            print('TEST 1: FAILED - File not found: $e');
          }

          // Test 2: Test AudioPlayer directly (bypass our service)
          try {
            print('TEST 2: Testing AudioPlayer directly...');
            final testPlayer = AudioPlayer();
            await testPlayer.setVolume(1.0);
            await testPlayer.play(AssetSource('sounds/cat/happy_1.mp3'));
            print('TEST 2: SUCCESS - Direct AudioPlayer call completed');
          } catch (e) {
            print('TEST 2: FAILED - Direct AudioPlayer failed: $e');
          }

          // Test 3: Test our sound service
          try {
            print('TEST 3: Testing NewAudioService...');
            final soundService = NewAudioService(pet: currentPet);
            await soundService.playSound('happy');
            print('TEST 3: SUCCESS - NewAudioService call completed');
          } catch (e) {
            print('TEST 3: FAILED - NewAudioService failed: $e');
          }

          // Test 4: Check volume settings
          try {
            print('TEST 4: Checking volume settings...');
            final soundSettings = SoundSettingsService();
            print(
              'TEST 4: Muted: ${soundSettings.isMuted}, Volume: ${soundSettings.volume}',
            );
          } catch (e) {
            print('TEST 4: FAILED - Volume check failed: $e');
          }

          print('=== DEBUG TEST COMPLETE ===');

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Audio debug test complete - check console!'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: const Icon(Icons.bug_report, color: Colors.white),
      ),*/
    );
  }
}
