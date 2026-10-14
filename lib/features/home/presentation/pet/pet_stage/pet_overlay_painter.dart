import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lumo/features/home/presentation/pet/pet_stage/pet_paint_colors.dart';
import 'package:lumo/features/home/presentation/pet/pet_stage/pet_stage_context.dart';

/// Screen-space overlay: speech bubble + particles.
abstract final class PetOverlayPainter {
  /// Lumi'nin kafasının üstünde beliren küçük konuşma balonu.
  /// Ekran uzayında çizilir (pet'in büyümesinden etkilenmez), pet ile
  /// birlikte hareket eder. [originY] çizim öncesi çevirmenin yapıldığı
  /// taban çizgisi, [scaleY] pet'in dikey ölçeğidir.
  static void speechBubble(
      PetStageContext ctx, double anchorX, double originY, double scaleY) {
    final canvas = ctx.canvas;
    final sim = ctx.sim;
    final alpha = clampDouble(sim.speechAlpha, 0, 1);
    if (alpha <= 0.01 || sim.speechText.isEmpty) return;

    const maxWidth = 190.0;
    final textPainter = TextPainter(
      text: TextSpan(
        text: sim.speechText,
        style: const TextStyle(
          fontFamily: 'Nunito',
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1E2E3D),
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 2,
      ellipsis: '…',
    )..layout(maxWidth: maxWidth);

    const padH = 12.0;
    const padV = 9.0;
    final bubbleW = textPainter.width + padH * 2;
    final bubbleH = textPainter.height + padV * 2;

    // Kulak uçları yerel ~-170 birimde biter; balon onun üstünde durur.
    final headTopY = originY - 195 * scaleY;
    var bubbleX = anchorX - bubbleW / 2;
    bubbleX = clampDouble(bubbleX, 12, ctx.w - bubbleW - 12);
    final bubbleY = (headTopY - bubbleH - 14).clamp(8.0, ctx.h - bubbleH - 8);

    final bubbleRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(bubbleX, bubbleY, bubbleW, bubbleH),
      const Radius.circular(15),
    );
    // Konuşma kuyruğu: kafaya bakan küçük üçgen.
    final tailTipX = (anchorX).clamp(bubbleX + 18, bubbleX + bubbleW - 18);
    final tailPath = Path()
      ..moveTo(tailTipX - 8, bubbleY + bubbleH - 1)
      ..lineTo(tailTipX + 8, bubbleY + bubbleH - 1)
      ..lineTo(tailTipX, bubbleY + bubbleH + 11)
      ..close();

    // Opak gövde (arka plan fotoğrafı okunmasın) + yumuşak gölge.
    final bubblePaint = Paint()..color = Colors.white.withValues(alpha: alpha);
    canvas.drawRRect(
      bubbleRect,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.18 * alpha)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    canvas.drawPath(tailPath, bubblePaint);
    canvas.drawRRect(bubbleRect, bubblePaint);
    canvas.drawRRect(
      bubbleRect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = const Color(0xFF7B5EA7).withValues(alpha: 0.45 * alpha),
    );

    textPainter.paint(
      canvas,
      Offset(bubbleX + padH, bubbleY + padV),
    );
  }

  static void particles(PetStageContext ctx) {
    final canvas = ctx.canvas;
    for (final p in ctx.sim.particles) {
      if (p.life <= 0) continue;
      final px = p.x * ctx.w;
      final py = p.y * ctx.h;
      final lifeAlpha = clampDouble(p.life, 0, 1);
      final color = p.color.withValues(alpha: lifeAlpha * 0.85);

      if (p.isShard) {
        // Temizlik: yarı saydam üçgen artefaktlar kaldırıldı (rehber §1.2).
        // Yerine yumuşak ışıltı noktası.
        canvas.drawCircle(Offset(px, py), 5.5 * lifeAlpha + 1.5, ctx.fill(color));
        canvas.drawCircle(
          Offset(px - 1.5, py - 1.5),
          1.6,
          ctx.fill(PetPaintColors.white.withValues(alpha: lifeAlpha * 0.9)),
        );
      } else if (p.isHeart) {
        final r = 13 * lifeAlpha;
        canvas.drawCircle(Offset(px - r * 0.35, py), r * 0.55, ctx.fill(color));
        canvas.drawCircle(Offset(px + r * 0.35, py), r * 0.55, ctx.fill(color));
        final heartPath = Path()
          ..moveTo(px - r * 0.85, py + r * 0.1)
          ..lineTo(px, py + r * 1.1)
          ..lineTo(px + r * 0.85, py + r * 0.1)
          ..close();
        canvas.drawPath(heartPath, ctx.fill(color));
      } else {
        canvas.drawCircle(Offset(px, py), 7 * lifeAlpha, ctx.fill(color));
      }
    }
  }
}
