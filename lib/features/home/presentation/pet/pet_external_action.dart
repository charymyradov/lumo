import 'package:flutter/foundation.dart';
import 'package:lumo/features/home/domain/entities/pet_action_state.dart';
import 'package:lumo/features/home/presentation/pet/pet_rig_state.dart';

/// Port of the Kotlin `LaunchedEffect(actionState)` block from
/// `LumoInteractivePetStage`: translates an externally requested care action
/// (bowl, ball, sleep…) into rig targets and timers.
void applyExternalPetAction(
  PetRigSimulationState sim,
  PetActionState actionState,
) {
  sim.locomotionMode = actionState;

  switch (actionState) {
    case PetActionState.eat || PetActionState.drink:
      sim.actionTimer = 4.2;
    case PetActionState.petted || PetActionState.groom:
      sim.actionTimer = 3.6;
    case PetActionState.jump || PetActionState.dance:
      sim.actionTimer = 2.4;
    case PetActionState.playBall:
      sim.showToyBall = true;
      sim.ballX = sim.petX < 0.5 ? 0.80 : 0.20;
      sim.ballY = 0.66;
      sim.ballVx = sim.petX < 0.5 ? -0.18 : 0.18;
      sim.ballVy = -0.25;
      sim.targetX = sim.ballX;
      sim.targetY = 0.69;
      sim.actionTimer = 5.5;
    case PetActionState.run:
      sim.targetX = sim.petX < 0.5 ? 0.82 : 0.18;
      sim.targetY = 0.66;
      sim.actionTimer = 3.5;
    case PetActionState.walk:
      sim.targetX = sim.petX < 0.5 ? 0.74 : 0.26;
      sim.targetY = 0.68;
      sim.actionTimer = 4.0;
    case PetActionState.idle || PetActionState.sleep:
      sim.actionTimer = 0;
  }

  if (actionState == PetActionState.jump) {
    sim.jumpPhase = 0.01;
  }
  if (actionState == PetActionState.eat ||
      actionState == PetActionState.drink) {
    sim.targetX = clampDouble(sim.petX + 0.08 * sim.facingDir, 0.28, 0.72);
    sim.targetY = 0.70;
  }
}
