import 'package:flutter/material.dart';
import '../models/pet.dart';
import '../models/pet_trick.dart';

class TrickTrainingScreen extends StatefulWidget {
  final Pet pet;

  const TrickTrainingScreen({super.key, required this.pet});

  @override
  State<TrickTrainingScreen> createState() => _TrickTrainingScreenState();
}

class _TrickTrainingScreenState extends State<TrickTrainingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _practiceController;
  late Animation<double> _practiceAnimation;
  PetTrick? selectedTrick;

  @override
  void initState() {
    super.initState();
    _practiceController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _practiceAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _practiceController, curve: Curves.easeInOut),
    );
  }

  void _practiceTrick(PetTrick trick) {
    setState(() {
      selectedTrick = trick;
      widget.pet.practiceTrick(trick);
    });
    _practiceController.forward().then((_) => _practiceController.reverse());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Training ${widget.pet.name}')),
      body: Column(
        children: [
          // Pet status section
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Icon(Icons.favorite),
                    Text('Energy: ${widget.pet.energy}'),
                  ],
                ),
                Column(
                  children: [
                    const Icon(Icons.mood),
                    Text('Happiness: ${widget.pet.happiness}'),
                  ],
                ),
                Column(
                  children: [
                    const Icon(Icons.stars),
                    Text(
                      'Tricks Mastered: ${widget.pet.tricks.where((t) => t.isMastered).length}',
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Currently practicing trick
          if (selectedTrick != null) ...[
            const SizedBox(height: 20),
            ScaleTransition(
              scale: _practiceAnimation,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text(
                      'Practicing: ${selectedTrick!.name}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: selectedTrick!.masteryPercentage,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        selectedTrick!.isMastered
                            ? Colors.green
                            : Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      selectedTrick!.isMastered
                          ? 'Mastered!'
                          : 'Keep practicing!',
                      style: TextStyle(
                        color: selectedTrick!.isMastered ? Colors.green : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          // Available tricks list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: widget.pet.tricks.length,
              itemBuilder: (context, index) {
                final trick = widget.pet.tricks[index];
                return Card(
                  child: ListTile(
                    leading: Icon(
                      trick.isMastered ? Icons.star : Icons.star_border,
                      color: trick.isMastered ? Colors.amber : null,
                    ),
                    title: Text(trick.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(trick.description),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: trick.masteryPercentage,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            trick.isMastered
                                ? Colors.green
                                : Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                    trailing: ElevatedButton(
                      onPressed: widget.pet.energy >= 10
                          ? () => _practiceTrick(trick)
                          : null,
                      child: Text(trick.isMastered ? 'Practice' : 'Learn'),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _practiceController.dispose();
    super.dispose();
  }
}
