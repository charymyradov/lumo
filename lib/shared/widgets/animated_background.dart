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

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          imagePath,
          fit: BoxFit.cover,
          alignment: Alignment.center,
          errorBuilder: (_, __, ___) => Container(
            color: const Color(0xFFEDE7FF),
          ),
        ),
        // Blur kapalıysa filtre maliyetine girmemek için direkt geç.
        if (blurSigma > 0)
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
            child: const SizedBox.expand(),
          ),
        // Soluklaştırma perdesi (paleOpacity 0 ise yok).
        if (paleOpacity > 0)
          Container(
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
