import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:lumo/features/home/presentation/extensions/home_entities_ui.dart';
import 'package:lumo/features/home/presentation/pet/pet_stage/pet_paint_colors.dart';
import 'package:lumo/features/home/presentation/pet/pet_stage/pet_stage_context.dart';

/// Torso + articulated-limb pass (former `_drawPetLimbsAndTorso`).
abstract final class PetBodyPainter {
  static void draw(
    PetStageContext ctx, {
    required bool isMoving,
    required bool isRunning,
    required double jumpSin,
  }) {
    final canvas = ctx.canvas;
    final sim = ctx.sim;

    // Nefes döngüsü 3.5 sn (rehber §6.2): 2π/3.5 ≈ 1.8 rad/sn.
    final breathWave = math.sin(sim.timeSec * (ctx.isSleeping ? 1.4 : 1.8));

    final strideAmp = isRunning
        ? 32.0
        : isMoving
            ? 22.0
            : ctx.isDancing
                ? 20.0
                : jumpSin > 0.1
                    ? 26.0
                    : 0.0;

    final gaitPhase = sim.gaitPhase;
    final flPhase = ctx.isDancing ? sim.timeSec * 10 : gaitPhase;
    final brPhase = isRunning ? gaitPhase + math.pi * 0.85 : gaitPhase + 0.4;
    final frPhase = isRunning ? gaitPhase + 0.35 : gaitPhase + math.pi;
    final blPhase =
        isRunning ? gaitPhase + math.pi * 1.15 : gaitPhase + math.pi + 0.4;

    final activeStride = isMoving || ctx.isDancing || jumpSin > 0.1;
    final frontLeftHip = activeStride ? math.sin(flPhase) * strideAmp : 0.0;
    final frontLeftKnee = activeStride
        ? math.max(0.0, math.cos(flPhase)) * (strideAmp * 0.75)
        : 0.0;
    final frontRightHip = activeStride ? math.sin(frPhase) * strideAmp : 0.0;
    final frontRightKnee = activeStride
        ? math.max(0.0, math.cos(frPhase)) * (strideAmp * 0.75)
        : 0.0;
    final backLeftHip = activeStride ? math.sin(blPhase) * strideAmp : 0.0;
    final backLeftKnee = activeStride
        ? math.max(0.0, -math.cos(blPhase)) * (strideAmp * 0.7)
        : 0.0;
    final backRightHip = activeStride ? math.sin(brPhase) * strideAmp : 0.0;
    final backRightKnee = activeStride
        ? math.max(0.0, -math.cos(brPhase)) * (strideAmp * 0.7)
        : 0.0;

    if (!ctx.isSleeping) {
      drawArticulatedLimb(
        ctx,
        hipX: -34,
        hipY: 38,
        hipAngleDeg: backRightHip,
        kneeAngleDeg: backRightKnee,
        upperColor: ctx.species.secondaryFurColor,
        lowerColor: const Color(0xFFDDD6FE),
        pawColor: const Color(0xFFF5F3FF),
        showPinkPad: true,
      );
      drawArticulatedLimb(
        ctx,
        hipX: 32,
        hipY: 36,
        hipAngleDeg: frontRightHip,
        kneeAngleDeg: frontRightKnee,
        upperColor: ctx.species.secondaryFurColor,
        lowerColor: const Color(0xFFDDD6FE),
        pawColor: const Color(0xFFF5F3FF),
        showPinkPad: true,
      );
    }

    final double torsoPitch;
    if (ctx.isSleeping) {
      torsoPitch = 14;
    } else if (ctx.isEating) {
      torsoPitch = 18;
    } else if (isRunning) {
      torsoPitch = math.sin(gaitPhase) * 11 - 6;
    } else if (jumpSin > 0.1) {
      torsoPitch = -14;
    } else if (ctx.isDancing) {
      torsoPitch = math.sin(sim.timeSec * 10) * 9;
    } else {
      torsoPitch = breathWave * 1.8;
    }

    ctx.rotate(torsoPitch, const Offset(0, 25), () {
      // Nefes: %2.5 scale, ~3.5 sn döngü (rehber §6.2). Eskiden %6.5 ve hızlıydı.
      final breathScale = 1 + breathWave * 0.025;
      // Armut gövde: altı geniş, üstü dar, kısa tombul (rehber §2).
      // Üç ton: ana beyaz, gölge #EDE7FF, vurgu mor (rehber §5).
      final bodyPath = Path()
        ..moveTo(-44 * breathScale, -16)
        ..quadraticBezierTo(-62 * breathScale, 8, -58 * breathScale, 38)
        ..quadraticBezierTo(-54 * breathScale, 62, 0, 62)
        ..quadraticBezierTo(54 * breathScale, 62, 58 * breathScale, 38)
        ..quadraticBezierTo(62 * breathScale, 8, 44 * breathScale, -16)
        ..quadraticBezierTo(0, -28, -44 * breathScale, -16)
        ..close();
      canvas.drawPath(bodyPath, ctx.fill(PetPaintColors.furWhite));
      // Alt gölge: beyaz üstüne beyaz öldürmesin diye #EDE7FF hilal.
      final bellyShadow = Path()
        ..moveTo(-48 * breathScale, 30)
        ..quadraticBezierTo(0, 58, 48 * breathScale, 30)
        ..quadraticBezierTo(0, 48, -48 * breathScale, 30)
        ..close();
      canvas.drawPath(bellyShadow, ctx.fill(PetPaintColors.softLavender));
      ctx.oval(PetPaintColors.white, -42, -10, 88 * breathScale,
          60 * breathScale);
      ctx.oval(
        PetPaintColors.white.withValues(alpha: ctx.isNight ? 0.35 : 0.55),
        -32,
        -14,
        58 * breathScale,
        20,
      );

      // Göğüs kabartısı: iki yumuşak katman, sivri uç yok (rehber §1.3, §2).
      final ruffBack = Path()
        ..moveTo(4, -14)
        ..quadraticBezierTo(60, -12, 70, 14)
        ..quadraticBezierTo(52, 30, 40, 46)
        ..quadraticBezierTo(12, 42, -2, 20)
        ..close();
      canvas.drawPath(ruffBack, ctx.fill(PetPaintColors.softLavender));
      final ruffMid = Path()
        ..moveTo(10, -10)
        ..quadraticBezierTo(58, -6, 64, 16)
        ..quadraticBezierTo(48, 28, 38, 40)
        ..quadraticBezierTo(14, 36, 2, 18)
        ..close();
      canvas.drawPath(ruffMid, ctx.fill(PetPaintColors.furWhite));
      // Adım 1: göğüs 2. katman — ön kabartı (daha açık, daha öne).
      final ruffFront = Path()
        ..moveTo(16, -6)
        ..quadraticBezierTo(52, -2, 56, 16)
        ..quadraticBezierTo(44, 26, 36, 34)
        ..quadraticBezierTo(20, 30, 10, 16)
        ..close();
      canvas.drawPath(ruffFront, ctx.fill(PetPaintColors.white));
      ctx.oval(
        PetPaintColors.white.withValues(alpha: ctx.isNight ? 0.25 : 0.45),
        22,
        -4,
        28,
        12,
      );
      // Pati yanındaki beyaz üçgen artefaktlar temizlendi: sivri spike döngüsü silindi.

      if (ctx.flags.hasCozyScarf) {
        ctx.roundRect(const Color(0xFFA78BFA), -8, -12, 66, 22, 11);
        ctx.roundRect(const Color(0xFF8B5CF6), 28, 4, 20, 36, 8);
      }
      if (ctx.flags.hasRibbonBow) {
        canvas.drawCircle(
            const Offset(22, 2), 14, ctx.fill(const Color(0xFFF43F5E)));
        canvas.drawCircle(
            const Offset(44, 2), 14, ctx.fill(const Color(0xFFFB7185)));
        canvas.drawCircle(
            const Offset(33, 2), 8, ctx.fill(const Color(0xFFFDA4AF)));
      }
    });

    if (!ctx.isSleeping) {
      drawArticulatedLimb(
        ctx,
        hipX: -42,
        hipY: 42,
        hipAngleDeg: backLeftHip,
        kneeAngleDeg: backLeftKnee,
        upperColor: PetPaintColors.white,
        lowerColor: ctx.species.secondaryFurColor,
        pawColor: PetPaintColors.white,
        showPinkPad: true,
      );
      drawArticulatedLimb(
        ctx,
        hipX: 24,
        hipY: 40,
        hipAngleDeg: frontLeftHip,
        kneeAngleDeg: frontLeftKnee,
        upperColor: PetPaintColors.white,
        lowerColor: ctx.species.secondaryFurColor,
        pawColor: PetPaintColors.white,
        showPinkPad: true,
      );
    } else {
      ctx.oval(PetPaintColors.white, 14, 44, 36, 22);
      ctx.oval(PetPaintColors.white, -22, 46, 36, 22);
    }
  }

  static void drawArticulatedLimb(
    PetStageContext ctx, {
    required double hipX,
    required double hipY,
    required double hipAngleDeg,
    required double kneeAngleDeg,
    required Color upperColor,
    required Color lowerColor,
    required Color pawColor,
    bool showPinkPad = false,
  }) {
    const upperLen = 22.0;
    const lowerLen = 20.0;

    ctx.rotate(hipAngleDeg, Offset(hipX, hipY), () {
      ctx.roundRect(upperColor, hipX - 16, hipY - 6, 32, upperLen + 10, 15);
      // Fur shading on the thigh.
      ctx.oval(
        PetPaintColors.white.withValues(alpha: 0.35),
        hipX - 12,
        hipY - 2,
        24,
        14,
      );
      final kneeX = hipX;
      final kneeY = hipY + upperLen;
      ctx.rotate(kneeAngleDeg, Offset(kneeX, kneeY), () {
        ctx.roundRect(lowerColor, kneeX - 14, kneeY - 4, 28, lowerLen + 8, 13);
        final pawY = kneeY + lowerLen;
        // Tilki çorabı: koyu mor pati ucu (rehber §5). Renk dengesini sağlar.
        ctx.oval(PetPaintColors.pawSock, kneeX - 19, pawY - 7, 38, 22);
        ctx.oval(pawColor, kneeX - 16, pawY - 7, 32, 15);
        // Tombul pati çizgisi: tek, ince, yumuşak.
        ctx.canvas.drawLine(
          Offset(kneeX - 1, pawY + 3),
          Offset(kneeX - 1, pawY + 10),
          ctx.stroke(PetPaintColors.furShadow, 2.0),
        );
        // Pati yastığı: pençenin alt-ortasında tek temiz oval.
        if (showPinkPad) {
          ctx.oval(
            PetPaintColors.blushDeep.withValues(alpha: 0.45),
            kneeX - 6,
            pawY + 2,
            12,
            8,
          );
        }
      });
    });
  }
}
