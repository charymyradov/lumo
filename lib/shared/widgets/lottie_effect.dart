import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:lumo/core/constants/asset_paths.dart';
import 'package:lumo/features/home/domain/entities/pet_action_state.dart';

/// Duygu efekt katmanı (rehber §7).
///
/// Stack sırası: arka plan → Rive/vektör pet → [PetEmotionOverlay].
/// Hafif JSON'lar `RepaintBoundary` içinde oynatılır, pet animasyonunu bölmez.
///
/// Mevcut hafif dosyalar:
/// * mutlu → [AssetPaths.lumoHappy] (kalp/ışıltı yerine geçer)
/// * uyku → [AssetPaths.lumoSleep] ("Zzz")
/// * dokunma → [AssetPaths.lumoTapReaction] (pop tepkisi)
/// * nefes/idle → [AssetPaths.lumoBreathing]
///
/// Tasarımcıdan beklenecek ek dosyalar (gelince [effectFor] genişletilir):
/// * `assets/animations/fx_hearts.json`, `fx_confetti.json`,
///   `fx_rain.json`, `fx_zzz.json`, `fx_crumbs.json`, `fx_butterfly.json`
class PetEmotionOverlay extends StatelessWidget {
  const PetEmotionOverlay({
    super.key,
    required this.action,
    this.size = 220,
  });

  final PetActionState action;
  final double size;

  /// Bu aksiyon için gösterilecek Lottie dosyası (yoksa null → efekt gizlenir).
  static String? effectFor(PetActionState action) {
    switch (action) {
      case PetActionState.petted:
      case PetActionState.dance:
      case PetActionState.jump:
      case PetActionState.playBall:
        return AssetPaths.lumoHappy;
      case PetActionState.sleep:
        return AssetPaths.lumoSleep;
      case PetActionState.eat:
      case PetActionState.drink:
      case PetActionState.groom:
        return AssetPaths.lumoTapReaction;
      case PetActionState.idle:
      case PetActionState.walk:
      case PetActionState.run:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final asset = effectFor(action);
    if (asset == null) return const SizedBox.shrink();
    return IgnorePointer(
      child: RepaintBoundary(
        child: Lottie.asset(
          asset,
          key: ValueKey('fx-${action.name}'),
          width: size,
          height: size,
          fit: BoxFit.contain,
          repeat: action == PetActionState.sleep,
          // Dosya bozuksa/eksikse sahne kırılmasın.
          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
        ),
      ),
    );
  }
}

/// Genel hafif Lottie sarmalayıcı: hata toleranslı, boundary'li.
class LottieEffect extends StatelessWidget {
  const LottieEffect({
    super.key,
    required this.asset,
    this.width = 160,
    this.height = 160,
    this.repeat = true,
  });

  final String asset;
  final double width;
  final double height;
  final bool repeat;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Lottie.asset(
        asset,
        width: width,
        height: height,
        fit: BoxFit.contain,
        repeat: repeat,
        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
      ),
    );
  }
}
