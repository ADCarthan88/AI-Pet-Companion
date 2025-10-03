import 'package:flutter/material.dart';
import '../models/pet.dart';

class PetCustomizationScreen extends StatefulWidget {
  final Function(Pet) onPetCreated;

  const PetCustomizationScreen({super.key, required this.onPetCreated});

  @override
  State<PetCustomizationScreen> createState() => _PetCustomizationScreenState();
}

class _PetCustomizationScreenState extends State<PetCustomizationScreen> {
  final _nameController = TextEditingController();
  PetType _selectedType = PetType.dog;
  PetGender _selectedGender = PetGender.male;
  Color _selectedColor = Colors.brown;

  final List<Color> _availableColors = [
    Colors.brown,
    Colors.grey,
    Colors.black,
    Colors.white70,
    Colors.orange,
    Colors.redAccent,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Customize Your Pet')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Pet Name',
                hintText: 'Enter a name for your pet',
              ),
            ),
            const SizedBox(height: 20),
            const Text('Select Pet Type:'),
            Wrap(
              spacing: 8.0,
              children: PetType.values.map((type) {
                return ChoiceChip(
                  label: Text(type.toString().split('.').last),
                  selected: _selectedType == type,
                  onSelected: (selected) {
                    setState(() {
                      _selectedType = type;
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            const Text('Select Gender:'),
            // Replaced deprecated RadioListTile groupValue/onChanged usage
            // with an explicit RadioGroup-like layout (manual Column + Radios)
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 480;
                final genderTiles = PetGender.values.map((gender) {
                  final label = gender.toString().split('.').last;
                  final selected = _selectedGender == gender;
                  return InkWell(
                    onTap: () => setState(() => _selectedGender = gender),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                      decoration: BoxDecoration(
                        color: selected ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.12) : null,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selected
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).dividerColor,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Radio<PetGender>(
                            value: gender,
                            groupValue: _selectedGender,
                            onChanged: (value) => setState(() => _selectedGender = value!),
                          ),
                          Text(label),
                        ],
                      ),
                    ),
                  );
                }).toList();
                if (isWide) {
                  return Row(
                    children: genderTiles
                        .map((w) => Expanded(child: w))
                        .toList(),
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: genderTiles,
                );
              },
            ),
            const SizedBox(height: 20),
            const Text('Select Color:'),
            Wrap(
              spacing: 8.0,
              children: _availableColors.map((color) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedColor = color;
                    });
                  },
                  child: Container(
                    width: 50,
                    height: 50,
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: color,
                      border: Border.all(
                        color: _selectedColor == color
                            ? Colors.blue
                            : Colors.transparent,
                        width: 3,
                      ),
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                if (_nameController.text.isNotEmpty) {
                  final pet = Pet(
                    name: _nameController.text,
                    type: _selectedType,
                    gender: _selectedGender,
                    color: _selectedColor,
                  );
                  widget.onPetCreated(pet);
                  Navigator.pop(context);
                }
              },
              child: const Text('Create Pet'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}
