import 'package:flutter/material.dart';
import 'package:lumo/features/home/domain/entities/pet_action_state.dart';
import 'package:lumo/features/home/presentation/pet/pet_stage/pet_paint_colors.dart';
import 'package:lumo/features/home/presentation/pet/pet_stage/pet_stage_context.dart';

/// Head-worn cosmetics + sleep "z" bubbles (former `_drawPetHeadCosmetics`).
abstract final class PetCosmeticsPainter {
  static void draw(
    PetStageContext ctx, {
    required double hcX,
    required double hcY,
  }) {
    final canvas = ctx.canvas;
    final sim = ctx.sim;

    if (ctx.flags.hasStarGlasses) {
      final leftEyeCenter = Offset(hcX - 26, hcY + 2);
      final rightEyeCenter = Offset(hcX + 30, hcY + 2);
      canvas.drawCircle(
          leftEyeCenter, 22, ctx.stroke(const Color(0xFFA855F7), 4.5));
      canvas.drawCircle(
          rightEyeCenter, 22, ctx.stroke(const Color(0xFFA855F7), 4.5));
      canvas.drawLine(
        Offset(leftEyeCenter.dx + 20, leftEyeCenter.dy),
        Offset(rightEyeCenter.dx - 20, rightEyeCenter.dy),
        ctx.stroke(const Color(0xFFFBBF24), 4.5),
      );
    }

    if (ctx.flags.hasCrown) {
      // Mini gold crown with rounded teeth + pink gem (reference look).
      final crownBaseY = hcY - 58;
      final crownPath = Path()
        ..moveTo(hcX - 30, crownBaseY)
        ..lineTo(hcX - 34, crownBaseY - 30)
        ..quadraticBezierTo(
            hcX - 32, crownBaseY - 36, hcX - 26, crownBaseY - 30)
        ..lineTo(hcX - 12, crownBaseY - 16)
        ..lineTo(hcX - 4, crownBaseY - 42)
        ..quadraticBezierTo(hcX, crownBaseY - 50, hcX + 4, crownBaseY - 42)
        ..lineTo(hcX + 12, crownBaseY - 16)
        ..lineTo(hcX + 26, crownBaseY - 30)
        ..quadraticBezierTo(
            hcX + 32, crownBaseY - 36, hcX + 34, crownBaseY - 30)
        ..lineTo(hcX + 30, crownBaseY)
        ..close();
      final crownRect = Rect.fromLTWH(hcX - 34, crownBaseY - 50, 68, 50);
      canvas.drawPath(
        crownPath,
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFEF08A), Color(0xFFFBBF24), Color(0xFFB45309)],
            stops: [0.0, 0.55, 1.0],
          ).createShader(crownRect),
      );
      // Crown outline for definition.
      canvas.drawPath(crownPath, ctx.stroke(PetPaintColors.goldDark, 2.5));
      // Base band.
      ctx.roundRect(PetPaintColors.goldDark, hcX - 30, crownBaseY - 6, 60, 8, 4);
      // Pink gem.
      final gemCenter = Offset(hcX, crownBaseY - 20);
      final gemPath = Path()
        ..moveTo(gemCenter.dx, gemCenter.dy - 9)
        ..lineTo(gemCenter.dx + 7, gemCenter.dy)
        ..lineTo(gemCenter.dx, gemCenter.dy + 9)
        ..lineTo(gemCenter.dx - 7, gemCenter.dy)
        ..close();
      canvas.drawPath(gemPath, ctx.fill(const Color(0xFFEC4899)));
      canvas.drawCircle(
        Offset(gemCenter.dx - 2, gemCenter.dy - 3),
        2.5,
        ctx.fill(PetPaintColors.white.withValues(alpha: 0.9)),
      );
      // Gold shine dots on teeth.
      canvas.drawCircle(
          Offset(hcX - 30, crownBaseY - 28), 2.5, ctx.fill(PetPaintColors.goldLight));
      canvas.drawCircle(
          Offset(hcX, crownBaseY - 40), 3, ctx.fill(PetPaintColors.goldLight));
      canvas.drawCircle(
          Offset(hcX + 30, crownBaseY - 28), 2.5, ctx.fill(PetPaintColors.goldLight));
    }

    if (ctx.flags.hasMushroomHat) {
      ctx.arc(const Color(0xFFEF4444), hcX - 58, hcY - 102, 116, 84,
          startAngle: 180, sweepAngle: 180, useCenter: true);
      canvas.drawCircle(
          Offset(hcX - 24, hcY - 78), 10, ctx.fill(PetPaintColors.white));
      canvas.drawCircle(
          Offset(hcX + 18, hcY - 82), 12, ctx.fill(PetPaintColors.white));
      canvas.drawCircle(
          Offset(hcX, hcY - 68), 8, ctx.fill(PetPaintColors.white));
    }

    if (ctx.flags.hasWizardHat) {
      final hatPath = Path()
        ..moveTo(hcX, hcY - 126)
        ..lineTo(hcX - 42, hcY - 52)
        ..lineTo(hcX + 42, hcY - 52)
        ..close();
      canvas.drawPath(hatPath, ctx.fill(const Color(0xFF2563EB)));
      ctx.oval(const Color(0xFF1D4ED8), hcX - 58, hcY - 60, 116, 20);
      canvas.drawCircle(
        Offset(hcX, hcY - 84),
        7,
        ctx.fill(const Color(0xFFFDE047)),
      );
    }

    if (ctx.flags.hasFlowerWreath) {
      for (var i = -2; i <= 2; i++) {
        final fx = hcX + i * 18.0;
        final fy = hcY - 54 + i.abs().toDouble() * 3;
        canvas.drawCircle(
          Offset(fx, fy),
          9.5,
          ctx.fill(i.isEven ? const Color(0xFFF472B6) : const Color(0xFFFDE047)),
        );
        canvas.drawCircle(Offset(fx, fy), 3.5, ctx.fill(PetPaintColors.white));
      }
    }

    if (sim.locomotionMode == PetActionState.sleep) {
      final zProgress = (sim.timeSec * 0.6) % 1;
      for (var z = 0; z <= 2; z++) {
        final zp = (zProgress + z * 0.33) % 1;
        final zx = hcX + 48 + zp * 38;
        final zy = hcY - 45 - zp * 75;
        final alpha = (1 - zp).clamp(0.0, 1.0);
        canvas.drawCircle(
          Offset(zx, zy),
          8 + zp * 8,
          ctx.fill(const Color(0xFFC4B5FD).withValues(alpha: alpha * 0.7)),
        );
      }
    }
  }
}
