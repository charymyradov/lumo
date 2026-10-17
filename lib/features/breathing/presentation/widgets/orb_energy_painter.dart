import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Kürenin içindeki "yaşam çiçeği / plazma" deseni.
class OrbEnergyPainter extends CustomPainter {
  final double energy; // 0..1

  const OrbEnergyPainter({required this.energy});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final r = size.shortestSide / 2;
    final a = (0.34 + energy * 0.38).clamp(0.0, 0.85);

    // İç ışıma dolgusu
    final fill = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withValues(alpha: 0.10 + energy * 0.12),
          const Color(0xFFBFE0FF).withValues(alpha: 0.06),
          Colors.transparent,
        ],
        stops: const [0.0, 0.6, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: r * 0.9));
    canvas.drawCircle(center, r * 0.9, fill);

    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..color = const Color(0xFFE4F2FF).withValues(alpha: a);

    final strokeSoft = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9
      ..color = const Color(0xFFBFE0FF).withValues(alpha: a * 0.7);

    // Merkez + 6 yaprak (yaşam çiçeği)
    final petalR = r * 0.30;
    final orbitR = r * 0.30;
    canvas.drawCircle(center, petalR, stroke);
    for (var k = 0; k < 6; k++) {
      final ang = (k / 6) * math.pi * 2 - math.pi / 2;
      final c = Offset(
        center.dx + math.cos(ang) * orbitR,
        center.dy + math.sin(ang) * orbitR,
      );
      canvas.drawCircle(c, petalR, k.isEven ? stroke : strokeSoft);
    }
    // Dış taç yapraklar
    for (var k = 0; k < 12; k++) {
      final ang = (k / 12) * math.pi * 2 + math.pi / 12;
      final c = Offset(
        center.dx + math.cos(ang) * orbitR * 1.9,
        center.dy + math.sin(ang) * orbitR * 1.9,
      );
      canvas.drawCircle(c, petalR * 0.62, strokeSoft);
    }
    // Kıvrımlı plazma iplikleri
    final thread = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withValues(alpha: (a * 0.8).clamp(0.0, 0.8));
    for (var k = 0; k < 3; k++) {
      final ang = (k / 3) * math.pi * 2 + energy * 0.6;
      final p = Path()
        ..moveTo(
          center.dx + math.cos(ang) * r * 0.1,
          center.dy + math.sin(ang) * r * 0.1,
        )
        ..cubicTo(
          center.dx + math.cos(ang + 0.9) * r * 0.45,
          center.dy + math.sin(ang + 0.9) * r * 0.45,
          center.dx + math.cos(ang + 2.1) * r * 0.6,
          center.dy + math.sin(ang + 2.1) * r * 0.6,
          center.dx + math.cos(ang + 3.0) * r * 0.78,
          center.dy + math.sin(ang + 3.0) * r * 0.78,
        );
      canvas.drawPath(p, thread);
    }
    // Merkez çekirdek parıltısı
    final core = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withValues(alpha: 0.5 + energy * 0.3),
          Colors.white.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: r * 0.22));
    canvas.drawCircle(center, r * 0.22, core);
  }

  @override
  bool shouldRepaint(OrbEnergyPainter old) =>
      (old.energy - energy).abs() > 0.001;
}
