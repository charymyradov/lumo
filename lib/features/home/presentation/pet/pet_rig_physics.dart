import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lumo/features/home/domain/entities/pet_action_state.dart';
import 'package:lumo/features/home/presentation/pet/pet_rig_state.dart';

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

  _stepBlinking(sim, dt);
  _stepFaceLook(sim, dt, reduceMotion: reduceMotion);
  _stepTapRing(sim, dt);
  _stepSpeech(sim, dt);
  _stepParticles(sim, dt);
  _stepTailSparkle(sim, reduceMotion: reduceMotion);
  _stepToyBall(sim, dt);
  _stepActionTimer(sim, dt);
  _stepJump(sim, dt);
  _stepLocomotion(sim, dt, reduceMotion: reduceMotion, speedFactor: speedFactor);

  sim.smoothFacing +=
      (sim.facingDir - sim.smoothFacing) * math.min(dt * 10.0, 1.0);
}

/// Blinking: rastgele 2-5 sn aralık (rehber §6.3).
void _stepBlinking(PetRigSimulationState sim, double dt) {
  sim.blinkTimer -= dt;
  if (sim.blinkTimer <= 0) {
    sim.isBlinking = !sim.isBlinking;
    sim.blinkTimer = sim.isBlinking ? 0.13 : _rng.nextDouble() * 3.0 + 2.0;
  }
}

/// Idle çeşitliliği: etrafa bakma / kulak seğirmesi hissi (rehber §6.9).
/// lookOffset yavaşça merkeze döner, idle'da rastgele yeni bakış seçilir.
void _stepFaceLook(
  PetRigSimulationState sim,
  double dt, {
  required bool reduceMotion,
}) {
  sim.lookOffsetX += (0 - sim.lookOffsetX) * math.min(dt * 0.6, 1.0);
  sim.lookOffsetY += (0 - sim.lookOffsetY) * math.min(dt * 0.6, 1.0);
  if (sim.locomotionMode == PetActionState.idle && !reduceMotion) {
    if (_rng.nextDouble() < dt * 0.35) {
      sim.lookOffsetX = _rng.nextDouble() * 0.4 - 0.2;
      sim.lookOffsetY = _rng.nextDouble() * 0.24 - 0.12;
    }
  }
}

void _stepTapRing(PetRigSimulationState sim, double dt) {
  if (sim.tapRingAlpha > 0) {
    sim.tapRingAlpha = clampDouble(sim.tapRingAlpha - dt * 1.6, 0, 1);
  }
}

/// Speech bubble: belir (0.4sn) → tut → kaybol (2.8sn sonrası 0.5sn).
void _stepSpeech(PetRigSimulationState sim, double dt) {
  if (sim.speechText.isNotEmpty) {
    sim.speechAge += dt;
    const fadeIn = 0.4, holdUntil = 2.8, fadeOut = 0.5;
    if (sim.speechAge < fadeIn) {
      sim.speechAlpha = clampDouble(sim.speechAge / fadeIn, 0, 1);
    } else if (sim.speechAge <= holdUntil) {
      sim.speechAlpha = 1;
    } else if (sim.speechAge <= holdUntil + fadeOut) {
      sim.speechAlpha =
          clampDouble(1 - (sim.speechAge - holdUntil) / fadeOut, 0, 1);
    } else {
      sim.speechAlpha = 0;
      sim.speechText = '';
    }
  } else {
    sim.speechAlpha = 0;
  }
}

void _stepParticles(PetRigSimulationState sim, double dt) {
  for (final p in sim.particles) {
    if (p.life > 0) {
      p.life -= dt * (p.isShard ? 0.45 : 0.95);
      p.x += p.vx * dt;
      p.y += p.vy * dt;
      if (!p.isShard) p.vy -= 0.05 * dt;
    }
  }
}

/// Kuyruk ışıltısı: üçgen artefaktlar temizlendi, seyrek yumuşak nokta
/// (rehber §1.2). Eskiden her kare %6 olasılıkla üçgen çıkıyordu.
void _stepTailSparkle(
  PetRigSimulationState sim, {
  required bool reduceMotion,
}) {
  if (sim.locomotionMode != PetActionState.sleep &&
      !reduceMotion &&
      _rng.nextDouble() < 0.015) {
    final behind = sim.facingDir >= 0 ? -1.0 : 1.0;
    sim.spawnParticle(
      x: sim.petX + behind * (0.10 + _rng.nextDouble() * 0.08),
      y: sim.petY - 0.04 - _rng.nextDouble() * 0.08,
      vx: behind * 0.02,
      vy: -0.03 - _rng.nextDouble() * 0.02,
      color:
          _rng.nextBool() ? const Color(0xFF8B5CF6) : const Color(0xFFC4B5FD),
      isHeart: false,
      isShard: true,
      life: 1.0,
    );
  }
}

void _stepToyBall(PetRigSimulationState sim, double dt) {
  if (!sim.showToyBall) return;
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

void _stepActionTimer(PetRigSimulationState sim, double dt) {
  if (sim.actionTimer > 0) {
    sim.actionTimer -= dt;
    if (sim.actionTimer <= 0) {
      sim.showToyBall = false;
      if (sim.locomotionMode != PetActionState.sleep) {
        sim.locomotionMode = PetActionState.idle;
      }
    }
  }
}

void _stepJump(PetRigSimulationState sim, double dt) {
  if (sim.jumpPhase > 0) {
    sim.jumpPhase += dt * 2.1;
    if (sim.jumpPhase >= 1) {
      sim.jumpPhase = 0;
      if (sim.locomotionMode == PetActionState.jump) {
        sim.locomotionMode = PetActionState.idle;
      }
    }
  }
}

void _stepLocomotion(
  PetRigSimulationState sim,
  double dt, {
  required bool reduceMotion,
  required double speedFactor,
}) {
  final dx = sim.targetX - sim.petX;
  final dy = sim.targetY - sim.petY;
  final dist = math.sqrt(dx * dx + dy * dy);

  if (sim.locomotionMode == PetActionState.sleep) return;

  if (dist > 0.015) {
    sim.facingDir = dx >= 0 ? 1.0 : -1.0;
    final isRunning = sim.isRunning;
    final moveSpeed = (isRunning ? 0.28 : 0.13) * speedFactor;
    final step = math.min(dist, moveSpeed * dt);
    sim.petX += (dx / dist) * step;
    sim.petY += (dy / dist) * step;
    sim.gaitPhase += dt * (isRunning ? 16.5 : 9.0) * speedFactor;

    // 5) Toz partikülü artırıldı: koşmada daha sık + yürümede hafif.
    if (isRunning && _rng.nextDouble() < 0.28) {
      sim.spawnParticle(
        x: sim.petX - sim.facingDir * 0.05,
        y: sim.petY + 0.06,
        vx: -sim.facingDir * 0.08,
        vy: -0.06,
        color: const Color(0xFFFDE047),
        isHeart: false,
        life: 0.60,
      );
    } else if (!isRunning && _rng.nextDouble() < 0.08) {
      sim.spawnParticle(
        x: sim.petX - sim.facingDir * 0.04,
        y: sim.petY + 0.06,
        vx: -sim.facingDir * 0.05,
        vy: -0.04,
        color: const Color(0xFFE9E2FF),
        isHeart: false,
        life: 0.45,
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
          // Dar dikey bant: Lumi alt-ortadan çok fazla uzaklaşmaz.
          sim.targetX = _rng.nextDouble() * 0.56 + 0.22;
          sim.targetY = _rng.nextDouble() * 0.07 + 0.60;
          sim.locomotionMode = (sim.targetX - sim.petX).abs() > 0.28
              ? PetActionState.run
              : PetActionState.walk;
        } else {
          sim.jumpPhase = 0.01;
        }
      }
    }
  }
}
