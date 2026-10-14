import 'package:lumo/core/constants/asset_paths.dart';

/// Breath cycle phase of a breathing session.
enum BreathPhase { inhale, hold, exhale, holdAfterExhale }

/// A named inhale / hold / exhale / hold-after pattern.
class BreathingPattern {
  final String title;
  final int inhale;
  final int hold;
  final int exhale;
  final int holdAfter;

  const BreathingPattern({
    required this.title,
    required this.inhale,
    required this.hold,
    required this.exhale,
    this.holdAfter = 0,
  });
}

const breathingPatterns = [
  BreathingPattern(title: '4-7-8 Breathing', inhale: 4, hold: 7, exhale: 8),
  BreathingPattern(
      title: 'Box Breathing', inhale: 4, hold: 4, exhale: 4, holdAfter: 4),
  BreathingPattern(title: 'Deep Breathing', inhale: 4, hold: 2, exhale: 6),
];

/// Nefes ekranındaki ortam sesleri — `assets/sounds/` içindeki gerçek mp3'ler.
/// `asset` null ise ses kapalıdır. Yollar [AssetPaths] üzerinden gelir
/// (`assets/` önekli); çalarken `audioplayers` kuralı gereği önek soyulur.
class BreathSound {
  final String title;
  final String? asset;

  const BreathSound(this.title, this.asset);
}

const breathingSounds = [
  BreathSound('Forest', AssetPaths.soundForest),
  BreathSound('Ocean', AssetPaths.soundSea),
  BreathSound('Rain', AssetPaths.soundRain),
  BreathSound('Fire', AssetPaths.soundFire),
  BreathSound('Off', null),
];

/// Seçili süre dolduğunda oturum biter + küçük ödül verilir.
const breathingDurations = [
  Duration(minutes: 1),
  Duration(minutes: 3),
  Duration(minutes: 5),
  Duration(minutes: 10),
];
