import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:lumo/features/breathing/presentation/pages/breathing_models.dart';

/// Faz / timer / ses tarafı nefes oturum durumu.
///
/// `_BreathingPageState` içindeki faz döngüsü, oturum sayacı ve ortam sesi
/// mantığının birebir taşınmış hali; tek fark `setState` yerine
/// [notifyListeners] kullanması. Animasyon tarafı aynı kalır: [breath]
/// 0.15 → 1.0 arası faz süresi boyunca `animateTo` ile akıcı sürülür.
class BreathingController extends ChangeNotifier {
  BreathingController({
    required TickerProvider vsync,
    required this.onSessionCompleted,
  }) {
    breath = AnimationController(
      vsync: vsync,
      lowerBound: 0.15,
      upperBound: 1.0,
      value: 0.15,
      duration: const Duration(seconds: 4),
    );
    _audio = AudioPlayer();
    _audio.setReleaseMode(ReleaseMode.loop).catchError((_) {});
    _playCurrentSound();
    startLoop();
    startSessionTimer();
  }

  /// Seçili süre dolduğunda view tarafından çalıştırılır (ödül + dialog).
  final VoidCallback onSessionCompleted;

  int patternIndex = 2; // görselde "Derin Nefes"
  int durationIndex = 0; // görselde "1 dk" vurgulu
  int soundIndex = 0;

  BreathPhase phase = BreathPhase.inhale;
  int secondsLeft = 4;

  /// 0.15 → 1.0 arası SÜREKLİ nefes değeri. Faz süresi boyunca
  /// animateTo ile akıcı sürülür; basamaklı setState yok.
  late final AnimationController breath;

  Timer? _sessionTimer;
  bool _sessionDone = false;

  Timer? _countdown;
  int _cycleToken = 0;
  bool _loopRunning = false;
  bool _disposed = false;

  late final AudioPlayer _audio;

  BreathingPattern get pattern => breathingPatterns[patternIndex];
  BreathSound get currentSound => breathingSounds[soundIndex];

  String get phaseText {
    switch (phase) {
      case BreathPhase.inhale:
        return 'Breathe in';
      case BreathPhase.hold:
      case BreathPhase.holdAfterExhale:
        return 'Hold';
      case BreathPhase.exhale:
        return 'Breathe out';
    }
  }

  void selectPattern(int i) {
    if (i == patternIndex) return;
    patternIndex = i;
    breath.stop();
    startLoop();
    notifyListeners();
  }

  void selectDuration(int i) {
    durationIndex = i;
    startSessionTimer();
    notifyListeners();
  }

  void cycleSound() {
    soundIndex = (soundIndex + 1) % breathingSounds.length;
    _playCurrentSound();
    notifyListeners();
  }

  void startSessionTimer() {
    _sessionTimer?.cancel();
    _sessionDone = false;
    _sessionTimer = Timer(breathingDurations[durationIndex], () {
      if (_disposed || _sessionDone) return;
      _sessionDone = true;
      onSessionCompleted();
    });
  }

  void startLoop() {
    _countdown?.cancel();
    _cycleToken++;
    final token = _cycleToken;

    phase = BreathPhase.inhale;
    secondsLeft = pattern.inhale;
    breath.value = 0.15;

    _countdown = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_disposed || token != _cycleToken) return;
      if (secondsLeft > 1) {
        secondsLeft--;
        notifyListeners();
      }
    });

    if (!_loopRunning) {
      _loopRunning = true;
      _runPhases(token).whenComplete(() => _loopRunning = false);
    }
  }

  void _setPhase(BreathPhase next, int seconds, int token) {
    if (_disposed || token != _cycleToken) return;
    phase = next;
    secondsLeft = seconds;
    notifyListeners();
  }

  /// Nefes döngüsü: şiş → tut → sön → (kutuysa) tut. Her şişme/sönme
  /// fazın tamamına yayılan tek bir easeInOut animasyondur.
  Future<void> _runPhases(int token) async {
    while (!_disposed && token == _cycleToken) {
      final p = pattern;
      _setPhase(BreathPhase.inhale, p.inhale, token);
      if (_disposed || token != _cycleToken) return;
      await breath
          .animateTo(
            1.0,
            duration: Duration(seconds: p.inhale),
            curve: Curves.easeInOut,
          )
          .catchError((_) {});
      if (_disposed || token != _cycleToken) return;

      if (p.hold > 0) {
        _setPhase(BreathPhase.hold, p.hold, token);
        await Future.delayed(Duration(seconds: p.hold));
        if (_disposed || token != _cycleToken) return;
      }
      _setPhase(BreathPhase.exhale, p.exhale, token);
      if (_disposed || token != _cycleToken) return;
      await breath
          .animateTo(
            0.15,
            duration: Duration(seconds: p.exhale),
            curve: Curves.easeInOut,
          )
          .catchError((_) {});
      if (_disposed || token != _cycleToken) return;

      if (p.holdAfter > 0) {
        _setPhase(BreathPhase.holdAfterExhale, p.holdAfter, token);
        await Future.delayed(Duration(seconds: p.holdAfter));
      }
    }
  }

  /// Seçili ortam sesini döngüyle çalar. "Kapalı" ise durdurur.
  Future<void> _playCurrentSound() async {
    try {
      final asset = breathingSounds[soundIndex].asset;
      if (asset == null) {
        await _audio.stop();
        return;
      }
      await _audio.stop();
      await _audio.setVolume(0.6);
      // audioplayers AssetSource yolu `assets/` önekini istemez.
      await _audio.play(AssetSource(asset.replaceFirst('assets/', '')));
    } catch (_) {
      // Ses çalamazsa sessizce geç — nefes döngüsü kırılmaz.
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _cycleToken++;
    _countdown?.cancel();
    _sessionTimer?.cancel();
    breath.dispose();
    _audio.dispose();
    super.dispose();
  }
}
