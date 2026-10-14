import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:lumo/features/home/domain/entities/pet_action_state.dart';
import 'package:lumo/features/home/presentation/pet/micro_particle.dart';

/// All mutable state of the procedural pet rig.
///
/// Direct port of `PetRigSimulationState` from the Kotlin `LumoPetEngine.kt`.
/// Positions are normalized against the stage size (0..1) so the rig scales to
/// any screen, while limb/face offsets are expressed in the painter's local
/// "unit" space (see `PetStagePainter`).
class PetRigSimulationState {
  PetRigSimulationState() {
    particles = List<MicroParticle>.generate(26, (_) => MicroParticle());
  }

  // Locomotion -----------------------------------------------------------
  // Lumi alt-ortada durur (0.5, ~0.64); yatay merkez hiç kaymaz, dikey
  // konum sadece derinlik/koşu hissi için değişir.
  double petX = 0.50;
  double petY = 0.64;
  double targetX = 0.50;
  double targetY = 0.64;
  double facingDir = 1;
  double smoothFacing = 1;
  PetActionState locomotionMode = PetActionState.idle;

  // Timing ---------------------------------------------------------------
  double timeSec = 0;
  double gaitPhase = 0;
  double jumpPhase = 0;
  double actionTimer = 0;
  double idleWanderCooldown = 3.2;

  // Face -----------------------------------------------------------------
  double lookOffsetX = 0;
  double lookOffsetY = 0;
  bool isBlinking = false;
  double blinkTimer = 2.8;

  // Toy ball -------------------------------------------------------------
  double ballX = 0.76;
  double ballY = 0.71;
  double ballVx = 0;
  double ballVy = 0;
  bool showToyBall = false;

  // Tap ring -------------------------------------------------------------
  double tapRingX = 0.5;
  double tapRingY = 0.68;
  double tapRingAlpha = 0;

  // Speech bubble ----------------------------------------------------------
  // Widget katmanı yazıyı yazar; simülasyon görünürlüğü yaşlandırır.
  // speechAge < 0.4: belirme, > 2.8: kaybolma, aralarda tam görünür.
  String speechText = '';
  double speechAlpha = 0;
  double speechAge = 99;

  late final List<MicroParticle> particles;

  /// Grabs a free particle slot (or recycles the first one when the pool is
  /// exhausted) so no allocation happens during the animation loop.
  void spawnParticle({
    required double x,
    required double y,
    required double vx,
    required double vy,
    required Color color,
    required bool isHeart,
    bool isShard = false,
    double life = 1,
  }) {
    MicroParticle? free;
    for (final p in particles) {
      if (p.isDead) {
        free = p;
        break;
      }
    }
    final slot = free ?? particles.first;
    slot
      ..x = x
      ..y = y
      ..vx = vx
      ..vy = vy
      ..color = color
      ..isHeart = isHeart
      ..isShard = isShard
      ..life = life;
  }

  /// True when the rig is currently moving toward [targetX]/[targetY].
  bool get isTravelling {
    final dx = targetX - petX;
    final dy = targetY - petY;
    return math.sqrt(dx * dx + dy * dy) > 0.015;
  }

  /// True when the rig should use the fast "run" gait.
  bool get isRunning {
    final dx = targetX - petX;
    final dy = targetY - petY;
    final dist = math.sqrt(dx * dx + dy * dy);
    return dist > 0.22 ||
        locomotionMode == PetActionState.run ||
        locomotionMode == PetActionState.playBall;
  }

  void resetFaceLook() {
    lookOffsetX = 0;
    lookOffsetY = 0;
  }
}
