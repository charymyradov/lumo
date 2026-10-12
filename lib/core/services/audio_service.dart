import 'package:flutter/services.dart';

/// Yumuşak pet sesleri (rehber §8): mırıltı, "pop", kıkırdama.
///
/// Gerçek ses dosyaları eklendiğinde (`assets/sounds/pop.mp3` vb.)
/// `audioplayers` ile çalınacak. Şu an ek bağımlılık olmadan
/// sistem sesi kullanılıyor, sessizce geçiyor — uygulama kırılmaz.
///
/// Beklenen dosyalar (eklenince otomatik kullanılır):
/// * `assets/sounds/pop.mp3` — dokunma
/// * `assets/sounds/purr.mp3` — sevme
/// * `assets/sounds/giggle.mp3` — oyun / dans
/// * `assets/sounds/sleep.mp3` — uyku
class PetSoundService {
  PetSoundService._();

  static Future<void> playPop() async {
    try {
      await SystemSound.play(SystemSoundType.click);
    } catch (_) {}
  }

  static Future<void> playPurr() async {
    try {
      await SystemSound.play(SystemSoundType.click);
    } catch (_) {}
  }

  static Future<void> playGiggle() async {
    try {
      await SystemSound.play(SystemSoundType.alert);
    } catch (_) {}
  }

  static Future<void> playSleep() async {
    try {
      await SystemSound.play(SystemSoundType.click);
    } catch (_) {}
  }
}
