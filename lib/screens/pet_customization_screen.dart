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
            Row(
              children: PetGender.values.map((gender) {
                return Expanded(
                  child: RadioListTile<PetGender>(
                    title: Text(gender.toString().split('.').last),
                    value: gender,
                    groupValue: _selectedGender,
                    onChanged: (value) {
                      setState(() {
                        _selectedGender = value!;
                      });
                    },
                  ),
                );
              }).toList(),
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
