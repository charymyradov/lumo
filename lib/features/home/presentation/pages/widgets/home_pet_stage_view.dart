import 'package:flutter/material.dart';
import 'package:lumo/features/home/domain/entities/cosmetic_item.dart';
import 'package:lumo/features/home/domain/entities/mascot_species.dart';
import 'package:lumo/features/home/domain/entities/pet_action_state.dart';
import 'package:lumo/features/home/presentation/pet/lumo_interactive_pet_stage.dart';
import 'package:lumo/features/home/presentation/pet/rive_pet_stage.dart';

/// Evcil hayvan sahnesi: Rive öncelikli, yoksa vektör sahneye düşer.
class HomePetStageView extends StatelessWidget {
  final bool useRive;
  final MascotSpecies species;
  final PetActionState actionState;
  final List<CosmeticItem> equippedItems;
  final bool isNight;
  final String speechText;
  final bool speechVisible;
  final VoidCallback onPetTapped;
  final void Function(PetActionState moveMode, String message) onGroundTapped;

  const HomePetStageView({
    super.key,
    required this.useRive,
    required this.species,
    required this.actionState,
    required this.equippedItems,
    required this.isNight,
    required this.speechText,
    required this.speechVisible,
    required this.onPetTapped,
    required this.onGroundTapped,
  });

  @override
  Widget build(BuildContext context) {
    if (useRive) {
      return RivePetStage(
        species: species,
        actionState: actionState,
        equippedItems: equippedItems,
        reduceMotion: false,
        isNight: isNight,
        speechText: speechText,
        speechVisible: speechVisible,
        onPetTappedOrStroked: onPetTapped,
        onGroundTapped: onGroundTapped,
      );
    }
    return LumoInteractivePetStage(
      species: species,
      actionState: actionState,
      equippedItems: equippedItems,
      reduceMotion: false,
      isNight: isNight,
      speechText: speechText,
      speechVisible: speechVisible,
      onPetTappedOrStroked: onPetTapped,
      onGroundTapped: onGroundTapped,
    );
  }
}
