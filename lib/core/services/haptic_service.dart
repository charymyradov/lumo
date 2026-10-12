import 'package:flutter/services.dart';

/// Tek noktadan dokunma titreşimi (rehber §8).
///
/// `HapticFeedback.lightImpact()` her dokunuşta çağrılmalı:
/// animasyon + ses + titreşim üçlüsü sevimlilik hissini taşır.
class HapticService {
  HapticService._();

  /// Pet'e dokununca: hafif, sevimli tepki.
  static Future<void> petTap() async {
    try {
      await HapticFeedback.lightImpact();
    } catch (_) {
      // Test / desteklenmeyen platformda sessiz geç.
    }
  }

  /// Görev tamamlama / seviye atlama: biraz daha belirgin.
  static Future<void> success() async {
    try {
      await HapticFeedback.mediumImpact();
    } catch (_) {}
  }

  /// Buton / seçim: en hafif.
  static Future<void> selection() async {
    try {
      await HapticFeedback.selectionClick();
    } catch (_) {}
  }
}
