import 'package:flutter/material.dart';
import 'package:lumo/features/home/domain/entities/mascot_species.dart';
import 'package:lumo/features/home/presentation/pet/pet_simulation.dart';
import 'package:lumo/features/home/presentation/pet/pet_stage/pet_stage_renderer.dart';

/// Procedural, fully vector pet renderer.
///
/// Thin [CustomPainter] facade: the scene math and every `drawXxx` pass now
/// live in `pet_stage/` (`PetStageRenderer` + focused painters). Everything
/// is painted with primitives, so no sprite atlas is required and every
/// species / cosmetic combination keeps animating smoothly.
class PetStagePainter extends CustomPainter {
  PetStagePainter({
    required this.sim,
    required this.species,
    required this.flags,
    this.isNight = false,
    super.repaint,
  });

  final PetRigSimulationState sim;
  final MascotSpecies species;
  final EquippedFlags flags;
  final bool isNight;

  @override
  void paint(Canvas canvas, Size size) {
    PetStageRenderer.fromParts(
      canvas: canvas,
      size: size,
      sim: sim,
      species: species,
      flags: flags,
      isNight: isNight,
    ).render();
  }

  @override
  bool shouldRepaint(covariant PetStagePainter oldDelegate) {
    return oldDelegate.species != species ||
        oldDelegate.flags != flags ||
        oldDelegate.isNight != isNight;
  }
}
