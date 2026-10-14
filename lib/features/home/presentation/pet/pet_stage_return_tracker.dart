import 'package:flutter/material.dart';
import 'package:lumo/features/home/domain/entities/pet_action_state.dart';
import 'package:lumo/features/home/presentation/pet/pet_rig_state.dart';

/// Tracks the "walk back home" leg after a ground tap.
///
/// Port of the `_returningFromGroundTap` / `_groundTapWait` /
/// `_groundTapReturnStarted` fields plus `_updateGroundTapReturn` from
/// `LumoInteractivePetStage`. Calling [update] every tick drives the rig back
/// to the spot it stood on when the user tapped the ground.
class GroundTapReturnTracker {
  bool returning = false;
  bool returnStarted = false;
  double wait = 0;
  double originX = 0.5;
  double originY = 0.64;

  /// Remembers where the pet stood and arms the delayed return.
  void startReturn(double petX, double petY) {
    originX = petX;
    originY = petY;
    wait = 0;
    returnStarted = false;
    returning = true;
  }

  void cancel() {
    returning = false;
    returnStarted = false;
    wait = 0;
  }

  /// Advances the return state machine by [dt] seconds.
  void update(PetRigSimulationState sim, double dt) {
    if (!returning) return;

    if (!returnStarted) {
      if (sim.isTravelling) return;

      wait += dt;
      if (wait < 4.5) return;

      returnStarted = true;
      sim.targetX = originX;
      sim.targetY = originY;
      final distance = Offset(
        sim.petX - originX,
        sim.petY - originY,
      ).distance;
      sim.locomotionMode =
          distance > 0.25 ? PetActionState.run : PetActionState.walk;
      sim.actionTimer = 0;
      return;
    }

    if (!sim.isTravelling) {
      sim.locomotionMode = PetActionState.idle;
      sim.idleWanderCooldown = 3.5;
      returning = false;
      returnStarted = false;
      wait = 0;
    }
  }
}
