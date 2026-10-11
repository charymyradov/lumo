import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lumo/features/home/domain/entities/cosmetic_item.dart';
import 'package:lumo/features/home/domain/entities/pet_action_state.dart';

/// Single reusable slot of the zero-allocation particle pool.
class MicroParticle {
  MicroParticle({
    this.x = 0,
    this.y = 0,
    this.vx = 0,
    this.vy = 0,
    this.color = Colors.white,
    this.isHeart = true,
    this.life = 0,
  });

  double x;
  double y;
  double vx;
  double vy;
  Color color;
  bool isHeart;
  double life;

  bool get isDead => life <= 0;
}

/// All mutable state of the procedural pet rig.
///
/// Direct port of `PetRigSimulationState` from the Kotlin `LumoPetEngine.kt`.
/// Positions are normalized against the stage size (0..1) so the rig scales to
/// any screen, while limb/face offsets are expressed in the painter's local
/// "unit" space (see `PetStagePainter`).
class PetRigSimulationState {
  PetRigSimulationState() {
    particles = List<MicroParticle>.generate(18, (_) => MicroParticle());
  }

  // Locomotion -----------------------------------------------------------
  double petX = 0.50;
  double petY = 0.68;
  double targetX = 0.50;
  double targetY = 0.68;
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

/// Flattened "which cosmetics are active right now" flags so the painter does
/// not have to scan the whole inventory every frame.
class EquippedFlags {
  bool hasCloudBed = false;
  bool hasLantern = false;
  bool hasButterflyWings = false;
  bool hasCozyScarf = false;
  bool hasRibbonBow = false;
  bool hasCatHood = false;
  bool hasStarGlasses = false;
  bool hasCrown = false;
  bool hasMushroomHat = false;
  bool hasWizardHat = false;
  bool hasFlowerWreath = false;

  void updateFrom(List<CosmeticItem> items) {
    hasCloudBed = false;
    hasLantern = false;
    hasButterflyWings = false;
    hasCozyScarf = false;
    hasRibbonBow = false;
    hasCatHood = false;
    hasStarGlasses = false;
    hasCrown = false;
    hasMushroomHat = false;
    hasWizardHat = false;
    hasFlowerWreath = false;

    for (final item in items) {
      switch (item.id) {
        case 'item_cloud_bed':
          hasCloudBed = item.isPlacedOnStage;
        case 'item_lantern':
          hasLantern = item.isPlacedOnStage;
        case 'item_butterfly_wings':
          hasButterflyWings = item.isEquipped;
        case 'item_cozy_scarf':
          hasCozyScarf = item.isEquipped;
        case 'item_ribbon_bow':
          hasRibbonBow = item.isEquipped;
        case 'item_pink_cat_costume':
          hasCatHood = item.isEquipped;
        case 'item_star_glasses':
          hasStarGlasses = item.isEquipped;
        case 'item_crown':
          hasCrown = item.isEquipped;
        case 'item_mushroom_hat':
          hasMushroomHat = item.isEquipped;
        case 'item_wizard_hat':
          hasWizardHat = item.isEquipped;
        case 'item_flower_wreath':
          hasFlowerWreath = item.isEquipped;
      }
    }
  }
}

final math.Random _rng = math.Random();

/// Advances the whole pet simulation by [dt] seconds.
///
/// Direct port of `stepPetSimulation` from the Kotlin `LumoPetEngine.kt`.
void stepPetSimulation(
  PetRigSimulationState sim,
  double dt, {
  bool reduceMotion = false,
}) {
  final speedFactor = reduceMotion ? 0.35 : 1.0;
  sim.timeSec += dt * speedFactor;

  // Blinking -------------------------------------------------------------
  sim.blinkTimer -= dt;
  if (sim.blinkTimer <= 0) {
    sim.isBlinking = !sim.isBlinking;
    sim.blinkTimer =
        sim.isBlinking ? 0.14 : _rng.nextDouble() * 3.2 + 2.0;
  }

  // Tap ring -------------------------------------------------------------
  if (sim.tapRingAlpha > 0) {
    sim.tapRingAlpha = clampDouble(sim.tapRingAlpha - dt * 1.6, 0, 1);
  }

  // Particles ------------------------------------------------------------
  for (final p in sim.particles) {
    if (p.life > 0) {
      p.life -= dt * 0.95;
      p.x += p.vx * dt;
      p.y += p.vy * dt;
      p.vy -= 0.05 * dt;
    }
  }

  // Toy ball -------------------------------------------------------------
  if (sim.showToyBall) {
    sim.ballX = clampDouble(sim.ballX + sim.ballVx * dt, 0.14, 0.86);
    if (sim.ballX <= 0.15 || sim.ballX >= 0.85) {
      sim.ballVx = -sim.ballVx * 0.75;
    }
    sim.ballVy += 0.65 * dt;
    sim.ballY += sim.ballVy * dt;
    if (sim.ballY >= 0.73) {
      sim.ballY = 0.73;
      sim.ballVy = -sim.ballVy.abs() * 0.62;
      sim.ballVx *= 0.85;
    }
    if (sim.locomotionMode == PetActionState.playBall) {
      sim.targetX = sim.ballX;
      sim.targetY = 0.69;
      if ((sim.petX - sim.ballX).abs() < 0.07 && sim.ballVy.abs() < 0.18) {
        sim.ballVy = -0.36;
        sim.ballVx = (_rng.nextBool() ? 1.0 : -1.0) * 0.25;
        sim.jumpPhase = 0.01;
      }
    }
  }

  // Action timer ---------------------------------------------------------
  if (sim.actionTimer > 0) {
    sim.actionTimer -= dt;
    if (sim.actionTimer <= 0) {
      sim.showToyBall = false;
      if (sim.locomotionMode != PetActionState.sleep) {
        sim.locomotionMode = PetActionState.idle;
      }
    }
  }

  // Jump -----------------------------------------------------------------
  if (sim.jumpPhase > 0) {
    sim.jumpPhase += dt * 2.1;
    if (sim.jumpPhase >= 1) {
      sim.jumpPhase = 0;
      if (sim.locomotionMode == PetActionState.jump) {
        sim.locomotionMode = PetActionState.idle;
      }
    }
  }

  // Locomotion -----------------------------------------------------------
  final dx = sim.targetX - sim.petX;
  final dy = sim.targetY - sim.petY;
  final dist = math.sqrt(dx * dx + dy * dy);

  if (sim.locomotionMode != PetActionState.sleep) {
    if (dist > 0.015) {
      sim.facingDir = dx >= 0 ? 1.0 : -1.0;
      final isRunning = sim.isRunning;
      final moveSpeed = (isRunning ? 0.28 : 0.13) * speedFactor;
      final step = math.min(dist, moveSpeed * dt);
      sim.petX += (dx / dist) * step;
      sim.petY += (dy / dist) * step;
      sim.gaitPhase += dt * (isRunning ? 16.5 : 9.0) * speedFactor;

      if (isRunning && _rng.nextDouble() < 0.18) {
        sim.spawnParticle(
          x: sim.petX - sim.facingDir * 0.05,
          y: sim.petY + 0.06,
          vx: -sim.facingDir * 0.08,
          vy: -0.06,
          color: const Color(0xFFFDE047),
          isHeart: false,
          life: 0.60,
        );
      }
    } else {
      if (sim.locomotionMode == PetActionState.walk ||
          sim.locomotionMode == PetActionState.run) {
        sim.locomotionMode = PetActionState.idle;
      }
      if (sim.locomotionMode == PetActionState.idle && !reduceMotion) {
        sim.idleWanderCooldown -= dt;
        if (sim.idleWanderCooldown <= 0) {
          sim.idleWanderCooldown = _rng.nextDouble() * 4.5 + 3.5;
          if (_rng.nextDouble() < 0.72) {
            sim.targetX = _rng.nextDouble() * 0.56 + 0.22;
            sim.targetY = _rng.nextDouble() * 0.10 + 0.63;
            sim.locomotionMode =
                (sim.targetX - sim.petX).abs() > 0.28 ? PetActionState.run : PetActionState.walk;
          } else {
            sim.jumpPhase = 0.01;
          }
        }
      }
    }
  }

  sim.smoothFacing += (sim.facingDir - sim.smoothFacing) * math.min(dt * 10.0, 1.0);
}
