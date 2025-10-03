import 'pet.dart';

// This file contains additions needed for the Pet class that were missing

extension PetExtensions on Pet {
  void stopLicking() {
    isLicking = false;
    currentActivity = PetActivity.idle;
    updateState();
  }
}
