import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lumo/features/home/domain/entities/pet_action_state.dart';
import 'package:lumo/features/home/presentation/pet/pet_stage/pet_paint_colors.dart';
import 'package:lumo/features/home/presentation/pet/pet_stage/pet_stage_context.dart';

/// Eyes + nose + mouth pass (former `_drawPetEyesAndMouth`).
abstract final class PetFacePainter {
  static void drawEyesAndMouth(
    PetStageContext ctx, {
    required double hcX,
    required double hcY,
    required bool isRunning,
    required double jumpSin,
  }) {
    final canvas = ctx.canvas;
    final sim = ctx.sim;

    // Bebek şeması: gözler geniş aralıklı, yüzün alt yarısında (rehber §4).
    final leftEyeCenter = Offset(hcX - 30, hcY + 8);
    final rightEyeCenter = Offset(hcX + 34, hcY + 8);
    final isHappy =
        ctx.isPetted || ctx.isDancing || sim.locomotionMode == PetActionState.jump;
    final isSad = sim.locomotionMode == PetActionState.groom;

    if (ctx.isSleeping) {
      ctx.arc(PetPaintColors.deepNose, leftEyeCenter.dx - 16,
          leftEyeCenter.dy - 8, 32, 20,
          startAngle: 15, sweepAngle: 150, useCenter: false, strokeWidth: 4.5);
      ctx.arc(PetPaintColors.deepNose, rightEyeCenter.dx - 16,
          rightEyeCenter.dy - 8, 32, 20,
          startAngle: 15, sweepAngle: 150, useCenter: false, strokeWidth: 4.5);
    } else if (isHappy) {
      // Mutlu: ^ ^ gözler (rehber §6.8).
      ctx.arc(PetPaintColors.deepNose, leftEyeCenter.dx - 16,
          leftEyeCenter.dy - 6, 32, 24,
          startAngle: 195, sweepAngle: 150, useCenter: false, strokeWidth: 5);
      ctx.arc(PetPaintColors.deepNose, rightEyeCenter.dx - 16,
          rightEyeCenter.dy - 6, 32, 24,
          startAngle: 195, sweepAngle: 150, useCenter: false, strokeWidth: 5);
    } else if (isSad) {
      // Üzgün: normal göz + damla yaş.
      final pupilShiftX = clampDouble(sim.lookOffsetX * 12, -5, 5);
      final pupilShiftY = clampDouble(sim.lookOffsetY * 12, -4, 4);
      drawSingleExpressiveEye(ctx, leftEyeCenter, pupilShiftX, pupilShiftY);
      drawSingleExpressiveEye(ctx, rightEyeCenter, pupilShiftX, pupilShiftY);
      ctx.oval(
        const Color(0xFF7DD3FC).withValues(alpha: 0.9),
        rightEyeCenter.dx + 12,
        rightEyeCenter.dy + 14,
        10,
        14,
      );
      canvas.drawCircle(
        Offset(rightEyeCenter.dx + 17, rightEyeCenter.dy + 17),
        2.5,
        ctx.fill(PetPaintColors.white.withValues(alpha: 0.9)),
      );
    } else if (sim.isBlinking ||
        (ctx.isEating && math.sin(sim.timeSec * 8) > 0.2)) {
      ctx.arc(PetPaintColors.deepNose, leftEyeCenter.dx - 16,
          leftEyeCenter.dy - 8, 32, 22,
          startAngle: 195, sweepAngle: 150, useCenter: false, strokeWidth: 5);
      ctx.arc(PetPaintColors.deepNose, rightEyeCenter.dx - 16,
          rightEyeCenter.dy - 8, 32, 22,
          startAngle: 195, sweepAngle: 150, useCenter: false, strokeWidth: 5);
    } else {
      final pupilShiftX = clampDouble(sim.lookOffsetX * 14, -6, 6);
      final pupilShiftY = clampDouble(sim.lookOffsetY * 14, -5, 5);
      drawSingleExpressiveEye(ctx, leftEyeCenter, pupilShiftX, pupilShiftY);
      drawSingleExpressiveEye(ctx, rightEyeCenter, pupilShiftX, pupilShiftY);
    }

    // Burun: küçük tek koyu nokta (rehber §4).
    final noseCenter = Offset(hcX + 2, hcY + 26);
    ctx.oval(PetPaintColors.deepNose, noseCenter.dx - 5, noseCenter.dy - 3.5,
        10, 7);
    canvas.drawCircle(
      Offset(noseCenter.dx - 1.5, noseCenter.dy - 1.5),
      2.0,
      ctx.fill(PetPaintColors.white.withValues(alpha: 0.85)),
    );

    // Ağız: kapalı "w" (rehber §4). Okunmayan minik diş/dil kaldırıldı.
    // Sadece yemek yerken ve mutluyken belirgin açık gülümseme.
    if (ctx.isEating) {
      final chew = math.sin(sim.timeSec * 11).abs();
      ctx.oval(PetPaintColors.deepNose, noseCenter.dx - 9, noseCenter.dy + 6,
          18, 8 + chew * 8);
      ctx.oval(const Color(0xFFFB7185), noseCenter.dx - 6, noseCenter.dy + 8,
          12, 5 + chew * 5);
    } else if (isHappy || isRunning || jumpSin > 0.2) {
      ctx.oval(const Color(0xFF6D28D9), noseCenter.dx - 10, noseCenter.dy + 6,
          20, 12);
      ctx.oval(const Color(0xFFFB7185), noseCenter.dx - 6, noseCenter.dy + 9,
          12, 6);
      ctx.oval(PetPaintColors.white.withValues(alpha: 0.7), noseCenter.dx - 4,
          noseCenter.dy + 8, 8, 3);
    } else if (isSad) {
      ctx.arc(PetPaintColors.deepNose, noseCenter.dx - 8, noseCenter.dy + 10,
          16, 10,
          startAngle: 200, sweepAngle: 140, useCenter: false, strokeWidth: 3);
    } else {
      ctx.arc(PetPaintColors.deepNose, noseCenter.dx - 12, noseCenter.dy + 5,
          11, 8,
          startAngle: 15, sweepAngle: 150, useCenter: false, strokeWidth: 3);
      ctx.arc(PetPaintColors.deepNose, noseCenter.dx + 1, noseCenter.dy + 5, 11,
          8,
          startAngle: 15, sweepAngle: 150, useCenter: false, strokeWidth: 3);
    }
  }

  static void drawSingleExpressiveEye(
      PetStageContext ctx, Offset eyePos, double pupilShiftX, double pupilShiftY) {
    final canvas = ctx.canvas;
    // Büyük dikey oval, iri pupil, 2 parlama (rehber §4). Sert eyeliner yumuşatıldı.
    ctx.oval(PetPaintColors.white, eyePos.dx - 20, eyePos.dy - 24, 40, 48);
    final irisCenter = Offset(eyePos.dx + pupilShiftX, eyePos.dy + pupilShiftY);
    final irisRect =
        Rect.fromLTWH(irisCenter.dx - 16, irisCenter.dy - 19, 32, 38);
    canvas.drawOval(
      irisRect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF4C1D95), Color(0xFF7C3AED), Color(0xFFA78BFA)],
          stops: [0.0, 0.55, 1.0],
        ).createShader(irisRect),
    );
    canvas.drawCircle(irisCenter, 10, ctx.fill(PetPaintColors.pupilInk));
    // Büyük + küçük parlama noktası.
    canvas.drawCircle(
      Offset(irisCenter.dx - 6, irisCenter.dy - 7),
      6.5,
      ctx.fill(PetPaintColors.white),
    );
    canvas.drawCircle(
      Offset(irisCenter.dx + 6, irisCenter.dy + 7),
      3.2,
      ctx.fill(PetPaintColors.white.withValues(alpha: 0.95)),
    );
    // Üst çizgi inceltildi: 6.5 -> 4.0 (rehber §4: koyu üst çizgi sertti).
    ctx.arc(PetPaintColors.eyeLid, eyePos.dx - 20, eyePos.dy - 25, 40, 30,
        startAngle: 190, sweepAngle: 160, useCenter: false, strokeWidth: 4.0);
  }
}
