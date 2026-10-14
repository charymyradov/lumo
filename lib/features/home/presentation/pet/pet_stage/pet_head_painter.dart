import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:lumo/features/home/domain/entities/mascot_species.dart';
import 'package:lumo/features/home/presentation/pet/pet_stage/pet_cosmetics_painter.dart';
import 'package:lumo/features/home/presentation/pet/pet_stage/pet_face_painter.dart';
import 'package:lumo/features/home/presentation/pet/pet_stage/pet_paint_colors.dart';
import 'package:lumo/features/home/presentation/pet/pet_stage/pet_stage_context.dart';

/// Head + ears + face coordinator (former `_drawPetHeadAndFace`).
abstract final class PetHeadPainter {
  static void draw(
    PetStageContext ctx, {
    required bool isRunning,
    required double jumpSin,
  }) {
    final canvas = ctx.canvas;
    final sim = ctx.sim;

    final breathWave = math.sin(sim.timeSec * (ctx.isSleeping ? 1.4 : 1.8));

    final double headPitch;
    if (ctx.isSleeping) {
      headPitch = 22;
    } else if (ctx.isEating) {
      headPitch = 26 + math.sin(sim.timeSec * 11).abs() * 7;
    } else if (ctx.isPetted) {
      headPitch = -8 + math.sin(sim.timeSec * 7) * 6;
    } else if (isRunning) {
      headPitch = -6 + math.cos(sim.gaitPhase) * 5;
    } else {
      headPitch = breathWave * 2.0 + sim.lookOffsetY * 22;
    }

    final earSpeed = ctx.isPetted || ctx.isEating || ctx.isDancing ? 9.0 : 2.4;
    final earAmp = ctx.isPetted || ctx.isDancing ? 12.0 : 6.0;
    final leftEarAngle =
        -16 + math.sin(sim.timeSec * earSpeed) * earAmp - (isRunning ? 10 : 0);
    final rightEarAngle = 16 -
        math.cos(sim.timeSec * earSpeed + 0.7) * earAmp +
        (isRunning ? 10 : 0);

    // Baş-gövde örtüşmesi artırıldı: ayrı sticker gibi durmasın (rehber §2).
    final headPivot = Offset(14, ctx.isSleeping ? 4.0 : -18.0);

    ctx.rotate(headPitch, headPivot, () {
      final hcX = headPivot.dx;
      final hcY = headPivot.dy - 42;
      // Kulaklar biraz küçültüldü, içi koyu mor (rehber §3).
      final earHeight =
          ctx.species == MascotSpecies.bunny ? 96.0 : 76.0;
      final earWidth = ctx.species == MascotSpecies.cat ? 50.0 : 56.0;

      ctx.rotate(leftEarAngle, Offset(hcX - 32, hcY - 34), () {
        drawSculptedEar(
          ctx,
          baseX: hcX - 32,
          baseY: hcY - 34,
          earWidth: earWidth,
          earHeight: earHeight,
          innerColor: PetPaintColors.earInner,
          outerColor: PetPaintColors.furWhite,
        );
      });
      ctx.rotate(rightEarAngle, Offset(hcX + 32, hcY - 34), () {
        drawSculptedEar(
          ctx,
          baseX: hcX + 32,
          baseY: hcY - 34,
          earWidth: earWidth,
          earHeight: earHeight,
          innerColor: PetPaintColors.earInner,
          outerColor: PetPaintColors.white,
        );
      });

      if (ctx.flags.hasCatHood) {
        canvas.drawCircle(
          Offset(hcX, hcY + 2),
          78,
          ctx.fill(const Color(0xFFF472B6)),
        );
      }

      // Yanak çıkıntıları: yumuşak, 2 tutam (rehber §3). Keskin 4 spike silindi.
      final cheekPath = Path()
        ..moveTo(hcX - 54, hcY - 8)
        ..quadraticBezierTo(hcX - 92, hcY + 12, hcX - 72, hcY + 34)
        ..quadraticBezierTo(hcX - 84, hcY + 44, hcX - 52, hcY + 50)
        ..close()
        ..moveTo(hcX + 54, hcY - 8)
        ..quadraticBezierTo(hcX + 92, hcY + 12, hcX + 72, hcY + 34)
        ..quadraticBezierTo(hcX + 84, hcY + 44, hcX + 52, hcY + 50)
        ..close();
      canvas.drawPath(cheekPath, ctx.fill(PetPaintColors.white));
      // 2 küçük yuvarlak yanak tüyü (sivri üçgen değil).
      for (final sx in [-76.0, 76.0]) {
        ctx.oval(PetPaintColors.white, hcX + sx - 10, hcY + 26, 20, 16);
      }
      for (final sx in [-62.0, 62.0]) {
        ctx.oval(PetPaintColors.white, hcX + sx - 8, hcY + 34, 16, 13);
      }

      // Mochi kafa: tam daire değil, yanaklar hafif geniş (rehber §2).
      final headPath = Path()
        ..moveTo(hcX - 68, hcY - 48)
        ..quadraticBezierTo(hcX - 78, hcY + 10, hcX - 58, hcY + 48)
        ..quadraticBezierTo(hcX - 30, hcY + 68, hcX, hcY + 68)
        ..quadraticBezierTo(hcX + 30, hcY + 68, hcX + 58, hcY + 48)
        ..quadraticBezierTo(hcX + 78, hcY + 10, hcX + 68, hcY - 48)
        ..quadraticBezierTo(hcX, hcY - 72, hcX - 68, hcY - 48)
        ..close();
      canvas.drawPath(headPath, ctx.fill(PetPaintColors.white));
      // Kontur kaldırıldı (rehber §1.4): tüm karakterde outline yok.
      // Çene altı hilal gölge: hacim için #EDE7FF.
      ctx.oval(
        PetPaintColors.softLavender.withValues(alpha: 0.9),
        hcX - 28,
        hcY + 52,
        56,
        12,
      );

      // Alın işareti: küçük mor elmas (markalaşma, rehber §3).
      final gemY = hcY - 38;
      final gemPath = Path()
        ..moveTo(hcX + 2, gemY - 9)
        ..lineTo(hcX + 9, gemY)
        ..lineTo(hcX + 2, gemY + 9)
        ..lineTo(hcX - 5, gemY)
        ..close();
      canvas.drawPath(gemPath, ctx.fill(const Color(0xFF8B5CF6)));
      canvas.drawCircle(
        Offset(hcX, gemY - 3),
        2.2,
        ctx.fill(PetPaintColors.white.withValues(alpha: 0.9)),
      );

      // Yanak allığı: yumuşak radial gradient (rehber §4).
      final blushAlpha = ctx.isPetted ? 0.55 : 0.42;
      ctx.softBlush(hcX - 46, hcY + 16, 34, blushAlpha);
      ctx.softBlush(hcX + 48, hcY + 16, 34, blushAlpha);

      PetFacePainter.drawEyesAndMouth(ctx,
          hcX: hcX, hcY: hcY, isRunning: isRunning, jumpSin: jumpSin);
      PetCosmeticsPainter.draw(ctx, hcX: hcX, hcY: hcY);
    });
  }

  static void drawSculptedEar(
    PetStageContext ctx, {
    required double baseX,
    required double baseY,
    required double earWidth,
    required double earHeight,
    required Color innerColor,
    required Color outerColor,
  }) {
    final canvas = ctx.canvas;
    // Temizlik: kulak çevresi ince mor anten çizgisi + dış spike'lar silindi (rehber §1.1).
    // Üçgen, hafif sivri, yuvarlak tabanlı kulak.
    final earOuterPath = Path()
      ..moveTo(baseX - earWidth * 0.5, baseY + 10)
      ..quadraticBezierTo(baseX - earWidth * 0.62, baseY - earHeight * 0.62,
          baseX, baseY - earHeight)
      ..quadraticBezierTo(baseX + earWidth * 0.62, baseY - earHeight * 0.62,
          baseX + earWidth * 0.5, baseY + 10)
      ..quadraticBezierTo(
          baseX, baseY + 18, baseX - earWidth * 0.5, baseY + 10)
      ..close();
    canvas.drawPath(earOuterPath, ctx.fill(outerColor));

    // İç kulak: koyu mor (rehber §3).
    final earInnerPath = Path()
      ..moveTo(baseX - earWidth * 0.30, baseY + 6)
      ..quadraticBezierTo(baseX - earWidth * 0.38, baseY - earHeight * 0.55,
          baseX, baseY - earHeight * 0.80)
      ..quadraticBezierTo(baseX + earWidth * 0.38, baseY - earHeight * 0.55,
          baseX + earWidth * 0.30, baseY + 6)
      ..quadraticBezierTo(baseX, baseY + 10, baseX - earWidth * 0.30, baseY + 6)
      ..close();
    canvas.drawPath(earInnerPath, ctx.fill(PetPaintColors.earDeep));
    final earInnerLight = Path()
      ..moveTo(baseX - earWidth * 0.20, baseY + 2)
      ..quadraticBezierTo(baseX - earWidth * 0.26, baseY - earHeight * 0.48,
          baseX, baseY - earHeight * 0.68)
      ..quadraticBezierTo(baseX + earWidth * 0.26, baseY - earHeight * 0.48,
          baseX + earWidth * 0.20, baseY + 2)
      ..close();
    canvas.drawPath(
        earInnerLight, ctx.fill(innerColor.withValues(alpha: 0.85)));
  }
}
