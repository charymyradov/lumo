import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:lumo/features/home/presentation/pet/pet_stage/pet_paint_colors.dart';
import 'package:lumo/features/home/presentation/pet/pet_stage/pet_stage_context.dart';

/// Stage + action props (former `_drawStage*` / `_draw*Prop` helpers).
abstract final class PetPropsPainter {
  static void cloudBed(
      PetStageContext ctx, double cx, double cy, double scale) {
    ctx.translateScale(cx, cy, scale, scale, () {
      ctx.oval(const Color(0x441E1B4B), -130, 22, 260, 54);
      ctx.roundRect(const Color(0xFF93C5FD), -115, -15, 230, 65, 32);
      ctx.canvas.drawCircle(
          const Offset(-62, -12), 48, ctx.fill(PetPaintColors.white));
      ctx.canvas.drawCircle(
          const Offset(0, -22), 58, ctx.fill(PetPaintColors.white));
      ctx.canvas.drawCircle(
          const Offset(62, -12), 48, ctx.fill(PetPaintColors.white));
      ctx.canvas.drawCircle(
          const Offset(-48, -18), 24, ctx.fill(const Color(0xFFFBBF24)));
    });
  }

  static void fairyLantern(
      PetStageContext ctx, double cx, double cy, double timeSec) {
    // Sakin nabız: hızlı büyüyüp küçülme hissini önlemek için
    // genlik %35 -> %8, hız 4.0 -> 1.4 rad/sn.
    final glow = 0.92 + 0.08 * math.sin(timeSec * 1.4);
    ctx.canvas.drawCircle(
      Offset(cx, cy),
      52 * glow,
      ctx.fill(const Color(0x55FEF08A)),
    );
    ctx.roundRect(const Color(0xFFFDE047), cx - 14, cy - 18, 28, 36, 8);
    ctx.canvas.drawLine(
      Offset(cx, cy - 42),
      Offset(cx, cy + 54),
      ctx.stroke(const Color(0xFF78350F), 5),
    );
  }

  static void foodBowl(
      PetStageContext ctx, double x, double y, double timeSec) {
    final canvas = ctx.canvas;
    ctx.oval(const Color(0xFFF472B6), x - 36, y - 12, 72, 28);
    canvas.drawCircle(
      Offset(x - 10, y - 10),
      11,
      ctx.fill(const Color(0xFFA855F7)),
    );
    canvas.drawCircle(
      Offset(x + 8, y - 12),
      12,
      ctx.fill(const Color(0xFFFB923C)),
    );
    canvas.drawCircle(Offset(x, y - 18), 9, ctx.fill(const Color(0xFFFDE047)));
    final bounce = math.sin(timeSec * 12).abs() * 18;
    canvas.drawCircle(
      Offset(x - 18, y - 24 - bounce),
      4.5,
      ctx.fill(const Color(0xFFFDE047)),
    );
    canvas.drawCircle(
      Offset(x + 18, y - 28 - bounce * 0.8),
      4,
      ctx.fill(const Color(0xFFF472B6)),
    );
  }

  static void waterBowl(
      PetStageContext ctx, double x, double y, double timeSec) {
    final canvas = ctx.canvas;
    ctx.oval(const Color(0xFF60A5FA), x - 36, y - 12, 72, 28);
    ctx.oval(const Color(0xFFBAE6FD), x - 28, y - 10, 56, 18);
    final splash = math.sin(timeSec * 10).abs() * 22;
    canvas.drawCircle(
      Offset(x - 14, y - 16 - splash),
      5,
      ctx.fill(const Color(0xFF93C5FD)),
    );
    canvas.drawCircle(
      Offset(x + 14, y - 20 - splash * 0.7),
      4.5,
      ctx.fill(const Color(0xFFBAE6FD)),
    );
  }

  static void groomingBubbles(
      PetStageContext ctx, double cx, double cy, double timeSec) {
    for (var i = 0; i <= 7; i++) {
      final angle = timeSec * 2.5 + i * 0.9;
      final bx = cx + math.cos(angle) * (48 + i * 8);
      final by = cy + math.sin(angle * 1.3) * 38 - (i * 6);
      final r = 10.0 + (i % 3) * 5;
      ctx.canvas.drawCircle(
        Offset(bx, by),
        r,
        ctx.fill(const Color(0x99E0F2FE)),
      );
      ctx.canvas.drawCircle(Offset(bx, by), r, ctx.stroke(PetPaintColors.white, 2));
      ctx.canvas.drawCircle(
        Offset(bx - r * 0.3, by - r * 0.3),
        r * 0.25,
        ctx.fill(PetPaintColors.white),
      );
    }
  }

  static void starToyBall(
      PetStageContext ctx, double x, double y, double rotationDeg) {
    ctx.rotate(rotationDeg, Offset(x, y), () {
      ctx.canvas.drawCircle(Offset(x, y), 24, ctx.fill(const Color(0xFFF59E0B)));
      ctx.canvas.drawCircle(
        Offset(x - 4, y - 4),
        16,
        ctx.fill(const Color(0xFFFEF08A)),
      );
      ctx.canvas.drawCircle(Offset(x, y), 7, ctx.fill(PetPaintColors.white));
    });
  }
}
