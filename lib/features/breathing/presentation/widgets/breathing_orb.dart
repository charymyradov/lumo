import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:lumo/features/breathing/presentation/widgets/orb_energy_painter.dart';

/// Görseldeki cam enerji küresi.
/// [animation] 0.15 (sönmüş) → 1.0 (şişmiş) arası SÜREKLİ sürülür;
/// parent bir [AnimationController]'ı faz süresince animateTo ile
/// yumuşakça ilerletir — saniye başı "tık tık" basamak YOK.
///
/// İç plazma deseni [OrbEnergyPainter]'dadır.
///
/// Performans notları (60fps):
/// * Alpha hesabı [lerpDouble] ile yapılır; aradeğer renk listeleri
///   build dışında `static const` tutulur.
/// * Hale/halka/küre katmanları ayrı [RepaintBoundary] içindedir.
/// * Tamamen statik 13px parlama noktası [AnimatedBuilder.child]'a taşınır.
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
        child: _staticDot,
        builder: (context, child) {
          final t = animation.value.clamp(0.15, 1.0);
          final eased = ((t - 0.15) / 0.85).clamp(0.0, 1.0);
          final sphereD = 172 + eased * 52; // 172 → 224
          final ringD = sphereD + 26;
          final haloD = sphereD + 84;

          // lerpDouble ile ucuz alpha hesabı (orijinal formüllerle birebir):
          // halo: 0.28/0.16 * (0.35 + e * 0.5)
          final haloA1 = lerpDouble(0.098, 0.238, eased)!;
          final haloA2 = lerpDouble(0.056, 0.136, eased)!;
          final ringBorderA = lerpDouble(0.35, 0.65, eased)!;
          final ringGlowA = lerpDouble(0.25, 0.55, eased)!;
          final topA = lerpDouble(0.34, 0.48, eased)!;
          final sphereBorderA = lerpDouble(0.55, 0.75, eased)!;
          final floorA = lerpDouble(0.35, 0.65, eased)!;

          return Stack(
            alignment: Alignment.center,
            children: [
              // ── 1. Geniş hale ──
              RepaintBoundary(
                child: _HaloLayer(diameter: haloD, a1: haloA1, a2: haloA2),
              ),
              // ── 2. İnce dış halka (görseldeki çember) ──
              RepaintBoundary(
                child: _RingLayer(
                  diameter: ringD,
                  borderAlpha: ringBorderA,
                  glowAlpha: ringGlowA,
                ),
              ),
              // ── 3. Ana cam küre ──
              RepaintBoundary(
                child: _SphereLayer(
                  diameter: sphereD,
                  energy: eased,
                  highlightAlpha: topA,
                  borderAlpha: sphereBorderA,
                ),
              ),
              // ── 4. Üst-sol cam parlaması (dekorasyon const, boy animasyonlu) ──
              Positioned(
                left: 150 - sphereD / 2 + sphereD * 0.14,
                top: 150 - sphereD / 2 + sphereD * 0.10,
                child: Container(
                  width: sphereD * 0.22,
                  height: sphereD * 0.22,
                  decoration: _glintDecoration,
                ),
              ),
              // ── 4b. Statik parlama noktası (AnimatedBuilder child) ──
              Positioned(
                left: 150 - sphereD / 2 + sphereD * 0.20,
                top: 150 - sphereD / 2 + sphereD * 0.16,
                child: child!,
              ),
              // ── 5. Alta süzülen ışık ──
              Positioned(
                bottom: 150 - sphereD / 2 - 26,
                child: _FloorGlow(width: sphereD * 0.55, alpha: floorA),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ── Build dışı sabitler: her tick'te yeniden oluşmaz ──

const _haloStops = <double>[0.0, 0.55, 1.0];
const _sphereStops = <double>[0.0, 0.38, 0.62, 0.82, 1.0];
const _sphereCenter = Alignment(-0.3, -0.35);

// Alpha'sı sabit küre renkleri (bir kez hesaplandı, her kare reuse edilir).
const _sphereMid1 = Color(0x38C9DCF7); // #C9DCF7 @ .22
const _sphereMid2 = Color(0x298FA9D6); // #8FA9D6 @ .16
const _sphereMid3 = Color(0x4D5B6FA8); // #5B6FA8 @ .30
const _sphereEdge = Color(0x8CDCE9FF); // #DCE9FF @ .55

// Statik parlamalar: const dekorasyonlar.
const _glintDecoration = BoxDecoration(
  shape: BoxShape.circle,
  gradient: RadialGradient(
    colors: [Color(0xD9FFFFFF), Color(0x00FFFFFF)],
  ),
);
const _dotDecoration = BoxDecoration(
  shape: BoxShape.circle,
  color: Color(0xF2FFFFFF),
  boxShadow: [BoxShadow(color: Color(0xB3FFFFFF), blurRadius: 10)],
);
const _staticDot = SizedBox(
  width: 13,
  height: 13,
  child: DecoratedBox(decoration: _dotDecoration),
);

class _HaloLayer extends StatelessWidget {
  const _HaloLayer({required this.diameter, required this.a1, required this.a2});

  final double diameter;
  final double a1;
  final double a2;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            const Color(0xFF9FC4FF).withValues(alpha: a1),
            const Color(0xFFB79CFF).withValues(alpha: a2),
            Colors.transparent,
          ],
          stops: _haloStops,
        ),
      ),
    );
  }
}

class _RingLayer extends StatelessWidget {
  const _RingLayer({
    required this.diameter,
    required this.borderAlpha,
    required this.glowAlpha,
  });

  final double diameter;
  final double borderAlpha;
  final double glowAlpha;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: borderAlpha),
          width: 1.3,
        ),
        // Ucuz gölge: blur 24→16, spread 2→0.
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9FC4FF).withValues(alpha: glowAlpha),
            blurRadius: 16,
          ),
        ],
      ),
    );
  }
}

class _SphereLayer extends StatelessWidget {
  const _SphereLayer({
    required this.diameter,
    required this.energy,
    required this.highlightAlpha,
    required this.borderAlpha,
  });

  final double diameter;
  final double energy;
  final double highlightAlpha;
  final double borderAlpha;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: _sphereCenter,
          radius: 1.05,
          colors: [
            Colors.white.withValues(alpha: highlightAlpha),
            _sphereMid1,
            _sphereMid2,
            _sphereMid3,
            _sphereEdge,
          ],
          stops: _sphereStops,
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: borderAlpha),
          width: 1.6,
        ),
      ),
      child: CustomPaint(
        painter: OrbEnergyPainter(energy: energy),
        isComplex: true,
        willChange: true,
      ),
    );
  }
}

class _FloorGlow extends StatelessWidget {
  const _FloorGlow({required this.width, required this.alpha});

  final double width;
  final double alpha;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 18,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: RadialGradient(
          colors: [
            const Color(0xFFBFD4FF).withValues(alpha: alpha),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}
