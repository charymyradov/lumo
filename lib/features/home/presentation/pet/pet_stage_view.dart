import 'package:flutter/material.dart';
import 'package:lumo/features/home/domain/entities/mascot_species.dart';
import 'package:lumo/features/home/presentation/pet/equipped_flags.dart';
import 'package:lumo/features/home/presentation/pet/pet_rig_state.dart';
import 'package:lumo/features/home/presentation/pet/pet_stage_painter.dart';

/// Gesture + paint surface of the interactive pet stage.
///
/// Purely visual: pointer events are forwarded to callbacks owned by
/// [LumoInteractivePetStage]'s state (via its [PetStageController]), and the
/// rig is painted from [sim] without rebuilding the widget tree.
class PetStageView extends StatelessWidget {
  const PetStageView({
    super.key,
    required this.sim,
    required this.species,
    required this.flags,
    required this.repaint,
    required this.isNight,
    required this.onTapUp,
    required this.onDoubleTapDown,
    required this.onPanUpdate,
  });

  final PetRigSimulationState sim;
  final MascotSpecies species;
  final EquippedFlags flags;
  final Listenable repaint;
  final bool isNight;

  final ValueChanged<Offset> onTapUp;
  final ValueChanged<Offset> onDoubleTapDown;
  final ValueChanged<Offset> onPanUpdate;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: const ValueKey<String>('lumo_interactive_pet_stage'),
      behavior: HitTestBehavior.opaque,
      onTapUp: (details) => onTapUp(details.localPosition),
      onDoubleTapDown: (details) => onDoubleTapDown(details.localPosition),
      onPanUpdate: (details) => onPanUpdate(details.localPosition),
      child: RepaintBoundary(
        child: CustomPaint(
          painter: PetStagePainter(
            sim: sim,
            species: species,
            flags: flags,
            isNight: isNight,
            repaint: repaint,
          ),
          // Katman önbelleğe alınır ve her kare değişeceği bilinir.
          isComplex: true,
          willChange: true,
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}
