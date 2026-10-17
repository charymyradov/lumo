import 'dart:ui';
import 'package:flutter/material.dart';

/// Bulanık, soluk çayır arka planı (rehber §5, §9).
///
/// Karakter düz vektör, arka plan ayrıntılı boyama:
/// arka plan hafif blur + beyaz perde ile soluklaştırılır,
/// pet öne çıkar.
class BlurredMeadowBackground extends StatelessWidget {
  const BlurredMeadowBackground({
    super.key,
    required this.imagePath,
    this.blurSigma = 0,
    this.paleOpacity = 0,
  });

  final String imagePath;
  final double blurSigma;
  final double paleOpacity;

  /// En pahalı blur bile tek karede takılmasın diye 12'ye sabitlenir.
  double get _clampedSigma => blurSigma > 12 ? 12 : blurSigma;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          imagePath,
          fit: BoxFit.cover,
          alignment: Alignment.center,
          filterQuality: FilterQuality.low,
          gaplessPlayback: true,
          cacheWidth: 1080,
          excludeFromSemantics: true,
          errorBuilder: (_, __, ___) => const ColoredBox(
            color: Color(0xFFEDE7FF),
          ),
        ),
        // Blur kapalıysa filtre maliyetine girmemek için direkt geç.
        if (_clampedSigma > 0)
          RepaintBoundary(
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: _clampedSigma,
                sigmaY: _clampedSigma,
              ),
              child: const SizedBox.expand(),
            ),
          ),
        // Soluklaştırma perdesi (paleOpacity 0 ise yok).
        if (paleOpacity > 0)
          ColoredBox(
            color: Colors.white.withValues(alpha: paleOpacity * 0.5),
          ),
      ],
    );
  }
}

/// Pet'in altına düşen oval yumuşak gölge zaten painter'da çiziliyor;
/// bu widget Lottie/overlay katmanında kullanılacak ek zemin ışımasıdır.
class SoftGroundGlow extends StatelessWidget {
  const SoftGroundGlow({super.key, this.width = 180});

  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: width * 0.24,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        boxShadow: const [
          BoxShadow(
            color: Color(0x331E1B4B),
            blurRadius: 24,
            spreadRadius: 2,
          ),
        ],
      ),
    );
  }
}
