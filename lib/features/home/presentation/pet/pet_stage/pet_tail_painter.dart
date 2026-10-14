import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:lumo/features/home/presentation/pet/pet_stage/pet_paint_colors.dart';
import 'package:lumo/features/home/presentation/pet/pet_stage/pet_stage_context.dart';

/// Tail pass (the former `_drawPetTailAndWings`).
///
/// Kept under its historical name even though only the tail is drawn today;
/// the butterfly-wings flag is not rendered by the painter.
abstract final class PetTailPainter {
  static void draw(
    PetStageContext ctx, {
    required bool isMoving,
    required bool isRunning,
    required double jumpSin,
  }) {
    final canvas = ctx.canvas;
    final sim = ctx.sim;

    final tailSpeed = ctx.isPetted || ctx.isEating || ctx.isDancing
        ? 9.0
        : isRunning
            ? 8.0
            : isMoving
                ? 5.0
                : ctx.isSleeping
                    ? 1.2
                    : 2.0;

    // Follow-through: gövdeden gecikmeli kuyruk (rehber §6.5).
    // Uç segment bazdan ~0.35 sn geriden gelir.
    final baseSwing = math.sin(sim.timeSec * tailSpeed) *
        (ctx.isPetted || ctx.isDancing
            ? 22.0
            : ctx.isSleeping
                ? 5.0
                : 14.0);
    final tipLag = math.sin(sim.timeSec * tailSpeed - 0.7) *
        (ctx.isPetted || ctx.isDancing ? 14.0 : 9.0);
    final gaitSway = isMoving ? math.sin(sim.gaitPhase) * 5.0 : 0.0;
    final jumpKick = jumpSin * 18.0;
    final tailSwing = baseSwing + gaitSway + jumpKick;
    // Kuyruk gövdeye içten bağlanır: pivot gövde sol kenarının içinde,
    // tabana bindirme dairesi çizilir, kopukluk kalmaz.
    final tailPivot = Offset(-44, ctx.isSleeping ? 36.0 : 20.0);

    ctx.rotate(ctx.isSleeping ? -32 + tailSwing : 14 + tailSwing, tailPivot,
        () {
      canvas.drawCircle(tailPivot, 26, ctx.fill(PetPaintColors.tailDeep));
      // Kalın kıvrımlı kuyruk: gradient gövde + dalgalı beyaz uç (rehber §3, §5).
      // Hedef-tahtası halka daireler kaldırıldı.
      final tailPath = Path()
        ..moveTo(tailPivot.dx, tailPivot.dy)
        ..cubicTo(
          tailPivot.dx - 80,
          tailPivot.dy - 92,
          tailPivot.dx - 160,
          tailPivot.dy - 42 + tipLag * 0.5,
          tailPivot.dx - 132,
          tailPivot.dy + 44,
        )
        ..cubicTo(
          tailPivot.dx - 100,
          tailPivot.dy + 84,
          tailPivot.dx - 36,
          tailPivot.dy + 54,
          tailPivot.dx,
          tailPivot.dy + 16,
        )
        ..close();
      final tailRect = Rect.fromCircle(
        center: Offset(tailPivot.dx - 80, tailPivot.dy),
        radius: 110,
      );
      canvas.drawPath(
        tailPath,
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              PetPaintColors.tailPurple,
              PetPaintColors.tailDeep,
              PetPaintColors.earDeep
            ],
            stops: [0.0, 0.6, 1.0],
          ).createShader(tailRect),
      );
      // Üst ışık: yumuşak hacim.
      ctx.oval(
        PetPaintColors.white.withValues(alpha: 0.22),
        tailPivot.dx - 118,
        tailPivot.dy - 48 + tipLag * 0.3,
        52,
        18,
      );
      // Dalgalı beyaz tüy kenarı (imza uç).
      final tipCenter = Offset(
        tailPivot.dx - 132,
        tailPivot.dy - 2 + tipLag * 0.4,
      );
      final tipPath = Path();
      const waves = 5;
      for (var i = 0; i <= waves; i++) {
        final t = i / waves;
        final ang = math.pi * (0.65 + t * 1.1);
        final r = 30 + (i.isEven ? 7.0 : -3.0);
        final px = tipCenter.dx + math.cos(ang) * r;
        final py = tipCenter.dy + math.sin(ang) * r * 0.85;
        if (i == 0) {
          tipPath.moveTo(px, py);
        } else {
          tipPath.lineTo(px, py);
        }
      }
      tipPath.close();
      canvas.drawPath(tipPath, ctx.fill(PetPaintColors.furWhite));
      canvas.drawCircle(tipCenter, 18, ctx.fill(PetPaintColors.white));
    });
  }
}
