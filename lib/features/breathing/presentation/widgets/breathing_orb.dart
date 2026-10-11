import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Görseldeki cam enerji küresi.
/// [animation] 0.15 (sönmüş) → 1.0 (şişmiş) arası SÜREKLİ sürülür;
/// parent bir [AnimationController]'ı faz süresince animateTo ile
/// yumuşakça ilerletir — saniye başı "tık tık" basamak YOK.
class BreathingOrb extends StatelessWidget {
  final Animation<double> animation;

  const BreathingOrb({super.key, required this.animation});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      height: 300,
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, _) {
          final t = animation.value.clamp(0.15, 1.0);
          final norm = ((t - 0.15) / 0.85).clamp(0.0, 1.0);
          final eased = norm; // parent zaten easeInOut ile sürüyor
          final sphereD = 172 + eased * 52; // 172 → 224
          final ringD = sphereD + 26;
          final haloD = sphereD + 84;
          final glow = 0.35 + eased * 0.5;

          return Stack(
            alignment: Alignment.center,
            children: [
              // ── 1. Geniş hale ──
              Container(
                width: haloD,
                height: haloD,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF9FC4FF).withValues(alpha: 0.28 * glow),
                      const Color(0xFFB79CFF).withValues(alpha: 0.16 * glow),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.55, 1.0],
                  ),
                ),
              ),
              // ── 2. İnce dış halka (görseldeki çember) ──
              Container(
                width: ringD,
                height: ringD,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.35 + eased * 0.3),
                    width: 1.3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(
                        0xFF9FC4FF,
                      ).withValues(alpha: 0.25 + eased * 0.3),
                      blurRadius: 24,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
              // ── 3. Ana cam küre ──
              Container(
                width: sphereD,
                height: sphereD,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    center: const Alignment(-0.3, -0.35),
                    radius: 1.05,
                    colors: [
                      Colors.white.withValues(alpha: 0.34 + eased * 0.14),
                      const Color(0xFFC9DCF7).withValues(alpha: 0.22),
                      const Color(0xFF8FA9D6).withValues(alpha: 0.16),
                      const Color(0xFF5B6FA8).withValues(alpha: 0.30),
                      const Color(0xFFDCE9FF).withValues(alpha: 0.55),
                    ],
                    stops: const [0.0, 0.38, 0.62, 0.82, 1.0],
                  ),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.55 + eased * 0.2),
                    width: 1.6,
                  ),
                ),
                child: CustomPaint(
                  painter: _OrbEnergyPainter(energy: eased),
                ),
              ),
              // ── 4. Üst-sol cam parlaması ──
              Positioned(
                left: 150 - sphereD / 2 + sphereD * 0.14,
                top: 150 - sphereD / 2 + sphereD * 0.10,
                child: Container(
                  width: sphereD * 0.22,
                  height: sphereD * 0.22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.85),
                        Colors.white.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 150 - sphereD / 2 + sphereD * 0.20,
                top: 150 - sphereD / 2 + sphereD * 0.16,
                child: Container(
                  width: 13,
                  height: 13,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.95),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.7),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                ),
              ),
              // ── 5. Alta süzülen ışık ──
              Positioned(
                bottom: 150 - sphereD / 2 - 26,
                child: Container(
                  width: sphereD * 0.55,
                  height: 18,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: RadialGradient(
                      colors: [
                        const Color(
                          0xFFBFD4FF,
                        ).withValues(alpha: 0.35 + eased * 0.3),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Kürenin içindeki "yaşam çiçeği / plazma" deseni.
class _OrbEnergyPainter extends CustomPainter {
  final double energy; // 0..1

  _OrbEnergyPainter({required this.energy});

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
  bool shouldRepaint(_OrbEnergyPainter old) => old.energy != energy;
}
