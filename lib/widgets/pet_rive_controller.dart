import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import '../models/pet.dart';

class PetRiveController {
  final Pet pet;
  Artboard? artboard;
  StateMachineController? controller;

  // State machine inputs
  SMITrigger? idleTrigger;
  SMITrigger? walkTrigger;
  SMITrigger? runTrigger;
  SMITrigger? eatTrigger;
  SMITrigger? sleepTrigger;
  SMITrigger? lickTrigger;
  SMITrigger? cleanTrigger;
  SMITrigger? playTrigger;

  // Mood and state boolean inputs
  SMIBool? isHappy;
  SMIBool? isSad;
  SMIBool? isExcited;
  SMIBool? isTired;
  SMIBool? isLoving;

  // Direction for facing left/right
  SMINumber? directionInput;

  PetRiveController({required this.pet});

  Future<void> init(String assetPath) async {
    try {
      final riveFile = await RiveFile.asset(assetPath);
      artboard = riveFile.mainArtboard;

      // Get the state machine controller
      controller = StateMachineController.fromArtboard(
        artboard!,
        'PetStateMachine', // This should match the state machine name in your Rive file
      );

      if (controller != null) {
        artboard!.addController(controller!);

        // Get triggers
        idleTrigger = controller!.findSMI('idle');
        walkTrigger = controller!.findSMI('walk');
        runTrigger = controller!.findSMI('run');
        eatTrigger = controller!.findSMI('eat');
        sleepTrigger = controller!.findSMI('sleep');
        lickTrigger = controller!.findSMI('lick');
        cleanTrigger = controller!.findSMI('clean');
        playTrigger = controller!.findSMI('play');

        // Get mood inputs
        isHappy = controller!.findSMI('isHappy');
        isSad = controller!.findSMI('isSad');
        isExcited = controller!.findSMI('isExcited');
        isTired = controller!.findSMI('isTired');
        isLoving = controller!.findSMI('isLoving');

        // Direction input
        directionInput = controller!.findSMI('direction');

        // Set initial mood
        _updateMood();
      }
    } catch (e) {
      debugPrint('Error loading Rive asset: $e');
      return;
    }
  }

  void updateAnimation(PetActivity activity) {
    // Set the mood first
    _updateMood();

    // Then trigger appropriate animation
    switch (activity) {
      case PetActivity.idle:
        idleTrigger?.fire();
        break;
      case PetActivity.playing:
      case PetActivity.playingWithToy:
        playTrigger?.fire();
        break;
      case PetActivity.sleeping:
        sleepTrigger?.fire();
        break;
      case PetActivity.eating:
        eatTrigger?.fire();
        break;
      case PetActivity.licking:
        lickTrigger?.fire();
        break;
      case PetActivity.beingCleaned:
      case PetActivity.beingBrushed:
        cleanTrigger?.fire();
        break;
      case PetActivity.walking:
        playTrigger?.fire(); // Use play animation for walking
        break;
    }
  }

  void updateDirection(double direction) {
    // Set direction value (-1 for left, 1 for right)
    directionInput?.value = direction;
  }

  void _updateMood() {
    // Reset all mood inputs
    isHappy?.value = false;
    isSad?.value = false;
    isExcited?.value = false;
    isTired?.value = false;
    isLoving?.value = false;

    // Set current mood
    switch (pet.mood) {
      case PetMood.happy:
        isHappy?.value = true;
        break;
      case PetMood.sad:
        isSad?.value = true;
        break;
      case PetMood.excited:
        isExcited?.value = true;
        break;
      case PetMood.tired:
        isTired?.value = true;
        break;
      case PetMood.loving:
        isLoving?.value = true;
        break;
      case PetMood.neutral:
        // No specific mood set
        break;
    }
  }

  void dispose() {
    controller?.dispose();
  }
}
