import 'package:flutter/material.dart';
import '../models/pet.dart';
import '../animations/dog_animation.dart';
import '../animations/cat_animation.dart';
import '../animations/bird_animation.dart';
import '../animations/rabbit_animation.dart';
import '../animations/lion_animation.dart';
import '../animations/giraffe_animation.dart';
import '../animations/penguin_animation.dart';
import '../animations/panda_animation.dart';

class PetAnimationFactory {
  static Widget createPetAnimation(Pet pet, {required Function(PetActivity) onActivityChanged}) {
    switch (pet.type) {
      case PetType.dog:
        return DogAnimation(pet: pet, onActivityChanged: onActivityChanged);
      case PetType.cat:
        return CatAnimation(pet: pet, onActivityChanged: onActivityChanged);
      case PetType.bird:
        return BirdAnimation(pet: pet, onActivityChanged: onActivityChanged);
      case PetType.rabbit:
        return RabbitAnimation(pet: pet, onActivityChanged: onActivityChanged);
      case PetType.lion:
        return LionAnimation(pet: pet, onActivityChanged: onActivityChanged);
      case PetType.giraffe:
        return GiraffeAnimation(pet: pet, onActivityChanged: onActivityChanged);
      case PetType.penguin:
        return PenguinAnimation(pet: pet, onActivityChanged: onActivityChanged);
      case PetType.panda:
        return PandaAnimation(pet: pet, onActivityChanged: onActivityChanged);
    }
  }
}