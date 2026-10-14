import 'dart:math' as math;

import 'package:flutter/material.dart';

class SplashParticles extends StatelessWidget {
  final AnimationController controller;

  const SplashParticles({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return CustomPaint(
          painter: ParticlePainter(controller.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class ParticlePainter extends CustomPainter {
  final double progress;

  ParticlePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    const particles = [
      Particle(0.15, 0.2, 3.0, 0.0),
      Particle(0.75, 0.15, 2.0, 0.2),
      Particle(0.3, 0.35, 2.5, 0.4),
      Particle(0.85, 0.4, 3.5, 0.1),
      Particle(0.5, 0.1, 2.0, 0.6),
      Particle(0.1, 0.6, 1.5, 0.3),
      Particle(0.9, 0.7, 2.5, 0.7),
      Particle(0.4, 0.8, 1.8, 0.5),
      Particle(0.65, 0.25, 3.0, 0.8),
      Particle(0.2, 0.45, 2.2, 0.15),
    ];

    for (final p in particles) {
      final phase = (progress + p.phase) % 1.0;
      final opacity = (math.sin(phase * 2 * math.pi) * 0.5 + 0.5) * 0.6;
      final yOffset = math.sin(phase * 2 * math.pi) * 10;

      paint.color = Colors.white.withValues(alpha: opacity);
      canvas.drawCircle(
        Offset(p.xFrac * size.width, p.yFrac * size.height + yOffset),
        p.radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(ParticlePainter old) => old.progress != progress;
}

class Particle {
  final double xFrac;
  final double yFrac;
  final double radius;
  final double phase;
  const Particle(this.xFrac, this.yFrac, this.radius, this.phase);
}
