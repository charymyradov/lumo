import 'package:flutter/material.dart';
import 'package:lumo/features/home/presentation/widgets/falling_leaves.dart';
import 'package:lumo/shared/widgets/animated_background.dart';

/// Home sahnesinin tam ekran arka plan katmanları:
/// çayır görseli, vinyet, gökyüzü detayları, yapraklar ve alt gradyan.
class HomeBackground extends StatelessWidget {
  final String imagePath;
  final bool isNight;

  const HomeBackground({
    super.key,
    required this.imagePath,
    required this.isNight,
  });

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Stack(
      fit: StackFit.expand,
      children: [
        // ── 1. Full-screen Background (net: blur kapalı) ──
        // Rehber §5 + §9: arka plan ayrıntılı boyama, karakter düz vektör.
        BlurredMeadowBackground(
          imagePath: imagePath,
          blurSigma: 0,
          paleOpacity: 0,
        ),

        // ── 1b. Vignette: kenarları koyulaştıran yumuşak gradyan ──
        // Parlak gökyüzünde kalan bütün yazılar (üst bar, yan kısayollar,
        // alt bakım şeridi) tek hamlede okunur hale gelir.
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -0.18),
                radius: 0.98,
                colors: [
                  Colors.transparent,
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.10),
                  Colors.black.withValues(alpha: 0.38),
                ],
                stops: const [0.0, 0.42, 0.72, 1.0],
              ),
            ),
          ),
        ),

        // ── 2. Sky ambience and environment props ────────────────
        Positioned(
          left: 30,
          top: 110,
          child: Opacity(
            opacity: isNight ? 0.18 : 0.30,
            child: Container(
              width: 140,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(50),
              ),
            ),
          ),
        ),
        Positioned(
          left: 210,
          top: 140,
          child: Opacity(
            opacity: isNight ? 0.12 : 0.24,
            child: Container(
              width: 180,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(50),
              ),
            ),
          ),
        ),
        // ── Süzülen yapraklar + ışık zerrecikleri ────────────────
        // Kendi CustomPaint katmanında akar; sayfayı rebuild etmez.
        Positioned.fill(
          child: IgnorePointer(
            child: FallingLeaves(isNight: isNight),
          ),
        ),

        // ── 3. Subtle bottom gradient for readability ─────────────
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: height * 0.52,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.10),
                  Colors.black.withValues(alpha: 0.26),
                ],
                stops: const [0.0, 0.6, 1.0],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
