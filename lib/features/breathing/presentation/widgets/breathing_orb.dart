import 'package:flutter/material.dart';
import 'package:lumo/features/breathing/presentation/widgets/orb_energy_painter.dart';

/// Görseldeki cam enerji küresi.
/// [animation] 0.15 (sönmüş) → 1.0 (şişmiş) arası SÜREKLİ sürülür;
/// parent bir [AnimationController]'ı faz süresince animateTo ile
/// yumuşakça ilerletir — saniye başı "tık tık" basamak YOK.
///
/// İç plazma deseni [OrbEnergyPainter]'dadır.
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
                  painter: OrbEnergyPainter(energy: eased),
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
