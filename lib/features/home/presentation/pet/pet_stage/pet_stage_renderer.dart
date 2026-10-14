import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lumo/features/home/domain/entities/mascot_species.dart';
import 'package:lumo/features/home/domain/entities/pet_action_state.dart';
import 'package:lumo/features/home/presentation/pet/pet_simulation.dart';
import 'package:lumo/features/home/presentation/pet/pet_stage/pet_body_painter.dart';
import 'package:lumo/features/home/presentation/pet/pet_stage/pet_head_painter.dart';
import 'package:lumo/features/home/presentation/pet/pet_stage/pet_overlay_painter.dart';
import 'package:lumo/features/home/presentation/pet/pet_stage/pet_paint_colors.dart';
import 'package:lumo/features/home/presentation/pet/pet_stage/pet_props_painter.dart';
import 'package:lumo/features/home/presentation/pet/pet_stage/pet_stage_context.dart';
import 'package:lumo/features/home/presentation/pet/pet_stage/pet_tail_painter.dart';

/// Stateless-per-frame scene coordinator.
///
/// Owns the scene-space math (anchor, depth scale, squash & stretch,
/// ground shadow, night tint) and delegates each visual pass to the
/// focused painter in `pet_stage/`. Safe to recreate on every paint call.
class PetStageRenderer {
  PetStageRenderer({
    required this.ctx,
  });

  final PetStageContext ctx;

  factory PetStageRenderer.fromParts({
    required Canvas canvas,
    required Size size,
    required PetRigSimulationState sim,
    required MascotSpecies species,
    required EquippedFlags flags,
    bool isNight = false,
  }) {
    return PetStageRenderer(
      ctx: PetStageContext(
        canvas: canvas,
        size: size,
        sim: sim,
        species: species,
        flags: flags,
        isNight: isNight,
      ),
    );
  }

  void render() {
    final canvas = ctx.canvas;
    final sim = ctx.sim;
    final flags = ctx.flags;
    final w = ctx.w;
    final h = ctx.h;

    if (flags.hasCloudBed) {
      PetPropsPainter.cloudBed(ctx, w * 0.26, h * 0.71, w * 0.00095);
    }
    if (flags.hasLantern) {
      PetPropsPainter.fairyLantern(ctx, w * 0.82, h * 0.63, sim.timeSec);
    }

    if (sim.tapRingAlpha > 0) {
      final rx = sim.tapRingX * w;
      final ry = sim.tapRingY * h;
      final ringRadius = (1 - sim.tapRingAlpha) * 48 + 16;
      ctx.strokeOval(
        PetPaintColors.white.withValues(alpha: sim.tapRingAlpha * 0.75),
        rx - ringRadius,
        ry - ringRadius * 0.42,
        ringRadius * 2,
        ringRadius * 0.84,
        3.5,
      );
    }

    final dist =
        (Offset(sim.targetX, sim.targetY) - Offset(sim.petX, sim.petY)).distance;
    final isMoving =
        dist > 0.016 && sim.locomotionMode != PetActionState.sleep;
    final isRunning = ctx.isRunningLocomotion(dist);

    final jumpSin = sim.jumpPhase > 0 ? math.sin(sim.jumpPhase * math.pi) : 0.0;
    final jumpHeightPx = jumpSin * (h * 0.11);

    final double squashX;
    if (sim.jumpPhase >= 0.01 && sim.jumpPhase <= 0.18) {
      squashX = 1.10;
    } else if (jumpSin > 0.4) {
      squashX = 0.92;
    } else if (sim.locomotionMode == PetActionState.petted) {
      // Squash & stretch: dokunulunca hafif yassılıp toparlan (rehber §6.6).
      squashX = 1.05 + math.sin(sim.timeSec * 7) * 0.025;
    } else {
      squashX = 1;
    }
    final stretchY = 2 - squashX;

    final anchorX = sim.petX * w;
    // Derinlik ölçeği pet'in dikey konumundan gelir; önce onu çöz.
    final depthScale = clampDouble(0.92 + (sim.petY - 0.58) * 1.35, 0.9, 1.35);
    final baseScale = (w / 1080) * 1.8 * depthScale;

    // Lumi alt-ortada durur; alt bakım buton şeridi asla üstüne binmesin.
    // 250 px: butonlar (~124) + alt nav payı (~92-118) + emniyet payı.
    final uiStackTop = h - 250;
    final feetOffset = math.max(92 * baseScale, 74 * depthScale);
    final anchorY = math.min(sim.petY * h, uiStackTop - feetOffset);

    // Oval yumuşak zemin gölgesi: arka plandan ayrıştırır (rehber §5).
    // Karakteri sahneye oturtmak için koyu ve geniş tutulur.
    final shadowRadiusX = 92 * depthScale * (1 - jumpSin * 0.4);
    final shadowRadiusY = 24 * depthScale * (1 - jumpSin * 0.4);
    ctx.softShadowOval(
      anchorX - shadowRadiusX,
      anchorY + 48 * depthScale - shadowRadiusY,
      shadowRadiusX * 2,
      shadowRadiusY * 2,
      const Color(0x661E1B4B),
    );

    final facing = sim.smoothFacing >= 0 ? 1.0 : -1.0;
    final isDancing = sim.locomotionMode == PetActionState.dance;
    final strideBob = isMoving
        ? math.sin(sim.gaitPhase).abs() * (isRunning ? -16.0 : -9.0)
        : 0.0;
    final danceBob = isDancing ? math.sin(sim.timeSec * 10).abs() * -18.0 : 0.0;

    canvas.save();
    canvas.translate(anchorX, anchorY - jumpHeightPx + strideBob + danceBob);
    canvas.scale(baseScale * squashX * facing, baseScale * stretchY);

    PetTailPainter.draw(ctx,
        isMoving: isMoving, isRunning: isRunning, jumpSin: jumpSin);
    PetBodyPainter.draw(ctx,
        isMoving: isMoving, isRunning: isRunning, jumpSin: jumpSin);
    PetHeadPainter.draw(ctx, isRunning: isRunning, jumpSin: jumpSin);

    canvas.restore();

    // 4) Işık tepkisi: gece sahnede pete soğuk mor tint.
    if (ctx.isNight) {
      final tintRect = Rect.fromCenter(
        center: Offset(anchorX, anchorY - 60 * depthScale),
        width: 340 * depthScale,
        height: 340 * depthScale,
      );
      canvas.drawOval(
        tintRect,
        Paint()..color = const Color(0xFF312E81).withValues(alpha: 0.10),
      );
    }

    // Props -----------------------------------------------------------------
    if (sim.locomotionMode == PetActionState.eat) {
      PetPropsPainter.foodBowl(
        ctx,
        anchorX + facing * 76 * depthScale,
        anchorY + 42 * depthScale,
        sim.timeSec,
      );
    } else if (sim.locomotionMode == PetActionState.drink) {
      PetPropsPainter.waterBowl(
        ctx,
        anchorX + facing * 76 * depthScale,
        anchorY + 42 * depthScale,
        sim.timeSec,
      );
    } else if (sim.locomotionMode == PetActionState.groom) {
      PetPropsPainter.groomingBubbles(
          ctx, anchorX, anchorY - 35 * depthScale, sim.timeSec);
    }

    if (sim.showToyBall) {
      PetPropsPainter.starToyBall(
          ctx, sim.ballX * w, sim.ballY * h, sim.timeSec * 260);
    }

    // Kafa üstü balon: sahne uzayında, pet'in ölçeğine göre konumlanır.
    PetOverlayPainter.speechBubble(
        ctx, anchorX, anchorY - jumpHeightPx + strideBob + danceBob,
        baseScale * stretchY);

    PetOverlayPainter.particles(ctx);
  }
}
