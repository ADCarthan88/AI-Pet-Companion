import 'package:flutter/material.dart';
import '../models/pet.dart';
import '../models/toy.dart';

class ToySelectionWidget extends StatelessWidget {
  final Pet pet;
  final Function(Toy) onToySelected;

  const ToySelectionWidget({
    super.key,
    required this.pet,
    required this.onToySelected,
  });

  @override
  Widget build(BuildContext context) {
    final availableToys = Toy.getToysForPetType(pet.type);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Toys for ${pet.name}',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: availableToys.length,
            itemBuilder: (context, index) {
              final toy = availableToys[index];
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () => onToySelected(toy),
                  child: Column(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: toy.color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: toy.isInUse ? Colors.green : Colors.grey,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          _getToyIcon(toy.type),
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(toy.name),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  IconData _getToyIcon(ToyType type) {
    switch (type) {
      case ToyType.ball:
        return Icons.sports_baseball;
      case ToyType.laserPointer:
        return Icons.radio_button_checked;
      case ToyType.bell:
        return Icons.notifications;
      case ToyType.carrot:
        return Icons.eco;
    }
  }
}