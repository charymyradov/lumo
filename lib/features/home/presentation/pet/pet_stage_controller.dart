import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lumo/core/services/audio_service.dart';
import 'package:lumo/core/services/haptic_service.dart';
import 'package:lumo/features/home/domain/entities/cosmetic_item.dart';
import 'package:lumo/features/home/domain/entities/pet_action_state.dart';
import 'package:lumo/features/home/presentation/pet/equipped_flags.dart';
import 'package:lumo/features/home/presentation/pet/pet_external_action.dart';
import 'package:lumo/features/home/presentation/pet/pet_rig_physics.dart';
import 'package:lumo/features/home/presentation/pet/pet_rig_state.dart';
import 'package:lumo/features/home/presentation/pet/pet_stage_return_tracker.dart';

final math.Random _rng = math.Random();

/// Owns the tick loop state and gesture reactions of
/// [LumoInteractivePetStage].
///
/// The widget keeps ticker ownership (so `TickerMode` keeps pausing the
/// stage) and forwards elapsed frames plus pointer positions here; painting
/// still reads [sim] directly, so only the [CustomPaint] layer repaints via
/// [repaint].
class PetStageController {
  PetStageController({
    required this.onPetTappedOrStroked,
    required this.onGroundTapped,
  });

  /// ~45 fps cap, mirroring the Kotlin frame throttle.
  static const Duration frameInterval = Duration(microseconds: 22222);

  final PetRigSimulationState sim = PetRigSimulationState();
  final EquippedFlags flags = EquippedFlags();
  final GroundTapReturnTracker returnTracker = GroundTapReturnTracker();

  /// Bumped once per tick so only the painter repaints (the widget tree stays
  /// untouched, mirroring the Kotlin `frameTickState` trick).
  final ValueNotifier<int> repaint = ValueNotifier<int>(0);

  VoidCallback onPetTappedOrStroked;
  void Function(PetActionState moveMode, String message) onGroundTapped;

  Duration _lastElapsed = Duration.zero;
  bool _hasLastElapsed = false;
  Duration _frameThrottleElapsed = Duration.zero;
  Duration _elapsedSinceLastFrame = Duration.zero;

  void applyExternalAction(PetActionState actionState) {
    applyExternalPetAction(sim, actionState);
  }

  void syncEquipped(List<CosmeticItem> items) => flags.updateFrom(items);

  void setSpeech(String text, bool visible) {
    sim.speechText = visible ? text : '';
    sim.speechAge = 0;
    sim.speechAlpha = 0;
  }

  /// Steps the simulation; called from the widget's [Ticker].
  void handleTick(Duration elapsed, {required bool reduceMotion}) {
    if (!_hasLastElapsed) {
      _lastElapsed = elapsed;
      _hasLastElapsed = true;
      return;
    }

    final frameDelta = elapsed - _lastElapsed;
    _lastElapsed = elapsed;
    _frameThrottleElapsed += frameDelta;
    _elapsedSinceLastFrame += frameDelta;
    if (_frameThrottleElapsed < frameInterval) return;

    _frameThrottleElapsed = Duration(
      microseconds:
          _frameThrottleElapsed.inMicroseconds % frameInterval.inMicroseconds,
    );
    final dt = clampDouble(
      _elapsedSinceLastFrame.inMicroseconds / 1000000,
      0.001,
      0.05,
    );
    _elapsedSinceLastFrame = Duration.zero;

    stepPetSimulation(sim, dt, reduceMotion: reduceMotion);
    returnTracker.update(sim, dt);
    repaint.value++;
  }

  // ── Gestures ────────────────────────────────────────────────────────────

  void handleDoubleTap(Size stageSize, Offset position) {
    if (stageSize.isEmpty) return;

    final nx = clampDouble(position.dx / stageSize.width, 0.15, 0.85);
    final ny = clampDouble(position.dy / stageSize.height, 0.58, 0.70);
    _startGroundTapReturn();
    sim.targetX = nx;
    sim.targetY = ny;
    sim.tapRingX = nx;
    sim.tapRingY = ny;
    sim.tapRingAlpha = 1;
    sim.locomotionMode = PetActionState.run;
    sim.jumpPhase = 0.01;

    onGroundTapped(
      PetActionState.run,
      'Double tap! Lumi is joyfully running and jumping! 🏃‍♂️✨',
    );
  }

  void handleTap(Size stageSize, Offset position) {
    if (stageSize.isEmpty) return;

    final nx = position.dx / stageSize.width;
    final ny = position.dy / stageSize.height;
    final distToPet =
        (Offset(nx, ny) - Offset(sim.petX, sim.petY - 0.08)).distance;

    if (distToPet < 0.16) {
      petThePet();
      return;
    }

    if (ny >= 0.44 && ny <= 0.82) {
      final clampedX = clampDouble(nx, 0.18, 0.82);
      final clampedY = clampDouble(ny, 0.58, 0.70);
      final runNeeded = (clampedX - sim.petX).abs() > 0.25;
      _startGroundTapReturn();
      sim.targetX = clampedX;
      sim.targetY = clampedY;
      sim.tapRingX = clampedX;
      sim.tapRingY = clampedY;
      sim.tapRingAlpha = 1;
      sim.lookOffsetX = clampDouble(clampedX - sim.petX, -0.3, 0.3);
      sim.locomotionMode =
          runNeeded ? PetActionState.run : PetActionState.walk;

      onGroundTapped(
        sim.locomotionMode,
        runNeeded
            ? 'Lumi is running toward the spot you tapped! 🐾💨'
            : 'Lumi is walking over to you! 🌸',
      );
    }
  }

  /// Port of the Kotlin tap-on-pet branch (5 hearts + happy reaction).
  void petThePet() {
    // His: her dokunuşta animasyon + ses + titreşim (rehber §8).
    HapticService.petTap();
    PetSoundService.playPurr();
    sim.locomotionMode = PetActionState.petted;
    sim.actionTimer = 3.2;
    sim.jumpPhase = 0.01;
    for (var i = 0; i < 5; i++) {
      sim.spawnParticle(
        x: sim.petX + (_rng.nextDouble() - 0.5) * 0.14,
        y: sim.petY - 0.12,
        vx: (_rng.nextDouble() - 0.5) * 0.12,
        vy: -0.14 - _rng.nextDouble() * 0.08,
        color: i.isEven ? const Color(0xFFF472B6) : const Color(0xFFA78BFA),
        isHeart: true,
      );
    }
    onPetTappedOrStroked();
  }

  /// Port of the Kotlin `detectDragGestures` block: eyes follow the finger and
  /// stroking the pet makes it purr (hearts).
  void handleDrag(Size stageSize, Offset position) {
    if (stageSize.isEmpty) return;

    final nx = clampDouble(position.dx / stageSize.width, 0.1, 0.9);
    final ny = clampDouble(position.dy / stageSize.height, 0.2, 0.9);
    sim.lookOffsetX = clampDouble(nx - sim.petX, -0.35, 0.35);
    sim.lookOffsetY = clampDouble(ny - (sim.petY - 0.1), -0.35, 0.35);

    final distToPet =
        (Offset(nx, ny) - Offset(sim.petX, sim.petY - 0.08)).distance;
    if (distToPet < 0.18) {
      sim.locomotionMode = PetActionState.petted;
      sim.actionTimer = 2.5;
      if (_rng.nextDouble() < 0.25) {
        sim.spawnParticle(
          x: nx,
          y: ny - 0.03,
          vx: (_rng.nextDouble() - 0.5) * 0.08,
          vy: -0.15,
          color: const Color(0xFFF472B6),
          isHeart: true,
        );
      }
    }
  }

  void _startGroundTapReturn() {
    returnTracker.startReturn(sim.petX, sim.petY);
    sim.idleWanderCooldown = 30;
  }

  void dispose() => repaint.dispose();
}
