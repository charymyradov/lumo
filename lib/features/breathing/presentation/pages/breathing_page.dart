import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lumo/core/constants/app_text.dart';
import 'package:lumo/core/constants/asset_paths.dart';
import 'package:lumo/core/di/injection.dart';
import 'package:lumo/core/services/haptic_service.dart';
import 'package:lumo/features/breathing/presentation/bloc/breathing_bloc.dart';
import 'package:lumo/features/breathing/presentation/bloc/breathing_event.dart';
import 'package:lumo/features/breathing/presentation/widgets/breathing_orb.dart';
import 'package:lumo/features/breathing/presentation/widgets/duration_selector.dart';
import 'package:lumo/features/breathing/presentation/widgets/pattern_selector.dart';
import 'package:lumo/features/breathing/presentation/widgets/sound_toggle.dart';

/// 7. Nefes Egzersizi — görseldeki gibi:
/// nefes.png • geri + başlık • cam küre (smooth nefes) •
/// "Nefes al / 4 saniye" • desen sırası • süre sırası • ses hapı.
/// Ödül ekonomisi [BreathingBloc]'te; animasyon/ses UI'da kalır.
class BreathingPage extends StatelessWidget {
  const BreathingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<BreathingBloc>(),
      child: const _BreathingView(),
    );
  }
}

class _BreathingView extends StatefulWidget {
  const _BreathingView();

  @override
  State<_BreathingView> createState() => _BreathingPageState();
}

enum _Phase { inhale, hold, exhale, holdAfterExhale }

class _BreathingPattern {
  final String title;
  final int inhale;
  final int hold;
  final int exhale;
  final int holdAfter;

  const _BreathingPattern({
    required this.title,
    required this.inhale,
    required this.hold,
    required this.exhale,
    this.holdAfter = 0,
  });
}

const _patterns = [
  _BreathingPattern(title: '4-7-8 Breathing', inhale: 4, hold: 7, exhale: 8),
  _BreathingPattern(
      title: 'Box Breathing', inhale: 4, hold: 4, exhale: 4, holdAfter: 4),
  _BreathingPattern(title: 'Deep Breathing', inhale: 4, hold: 2, exhale: 6),
];

/// Nefes ekranındaki ortam sesleri — `assets/sounds/` içindeki gerçek mp3'ler.
/// `asset` null ise ses kapalıdır. Yollar [AssetPaths] üzerinden gelir
/// (`assets/` önekli); çalarken `audioplayers` kuralı gereği önek soyulur.
class _BreathSound {
  final String title;
  final String? asset;

  const _BreathSound(this.title, this.asset);
}

const _sounds = [
  _BreathSound('Forest', AssetPaths.soundForest),
  _BreathSound('Ocean', AssetPaths.soundSea),
  _BreathSound('Rain', AssetPaths.soundRain),
  _BreathSound('Fire', AssetPaths.soundFire),
  _BreathSound('Off', null),
];

class _BreathingPageState extends State<_BreathingView>
    with SingleTickerProviderStateMixin {
  int _patternIndex = 2; // görselde "Derin Nefes"
  int _durationIndex = 0; // görselde "1 dk" vurgulu
  int _soundIndex = 0;

  _Phase _phase = _Phase.inhale;
  int _secondsLeft = 4;

  /// Seçili süre dolduğunda oturum biter + küçük ödül verilir.
  static const _durations = [
    Duration(minutes: 1),
    Duration(minutes: 3),
    Duration(minutes: 5),
    Duration(minutes: 10),
  ];
  Timer? _sessionTimer;
  bool _sessionDone = false;

  /// 0.15 → 1.0 arası SÜREKLİ nefes değeri. Faz süresi boyunca
  /// animateTo ile akıcı sürülür; basamaklı setState yok.
  late final AnimationController _breath;

  Timer? _countdown;
  int _cycleToken = 0;
  bool _loopRunning = false;

  late final AudioPlayer _audio;

  @override
  void initState() {
    super.initState();
    _breath = AnimationController(
      vsync: this,
      lowerBound: 0.15,
      upperBound: 1.0,
      value: 0.15,
      duration: const Duration(seconds: 4),
    );
    _audio = AudioPlayer();
    _audio.setReleaseMode(ReleaseMode.loop).catchError((_) {});
    _playCurrentSound();
    _startLoop();
    _startSessionTimer();
  }

  void _startSessionTimer() {
    _sessionTimer?.cancel();
    _sessionDone = false;
    _sessionTimer = Timer(_durations[_durationIndex], () {
      if (!mounted || _sessionDone) return;
      _sessionDone = true;
      _completeSession();
    });
  }

  void _completeSession() {
    HapticService.success();
    context.read<BreathingBloc>().add(const BreathingSessionCompleted());
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Session complete 🧘'),
        content: const Text(
            'Nice breathing! +15 coins, +8 XP earned. Lumi feels calmer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Continue'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context)
              ..pop()
              ..pop(),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _cycleToken++;
    _countdown?.cancel();
    _sessionTimer?.cancel();
    _breath.dispose();
    _audio.dispose();
    super.dispose();
  }

  _BreathingPattern get _pattern => _patterns[_patternIndex];

  void _startLoop() {
    _countdown?.cancel();
    _cycleToken++;
    final token = _cycleToken;

    setState(() {
      _phase = _Phase.inhale;
      _secondsLeft = _pattern.inhale;
    });
    _breath.value = 0.15;

    _countdown = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || token != _cycleToken) return;
      if (_secondsLeft > 1) setState(() => _secondsLeft--);
    });

    if (!_loopRunning) {
      _loopRunning = true;
      _runPhases(token).whenComplete(() => _loopRunning = false);
    }
  }

  Future<void> _setPhase(_Phase phase, int seconds, int token) async {
    if (!mounted || token != _cycleToken) return;
    setState(() {
      _phase = phase;
      _secondsLeft = seconds;
    });
  }

  /// Nefes döngüsü: şiş → tut → sön → (kutuysa) tut. Her şişme/sönme
  /// fazın tamamına yayılan tek bir easeInOut animasyondur.
  Future<void> _runPhases(int token) async {
    while (mounted && token == _cycleToken) {
      final p = _pattern;
      await _setPhase(_Phase.inhale, p.inhale, token);
      if (!mounted || token != _cycleToken) return;
      await _breath
          .animateTo(
            1.0,
            duration: Duration(seconds: p.inhale),
            curve: Curves.easeInOut,
          )
          .catchError((_) {});
      if (!mounted || token != _cycleToken) return;

      if (p.hold > 0) {
        await _setPhase(_Phase.hold, p.hold, token);
        await Future.delayed(Duration(seconds: p.hold));
        if (!mounted || token != _cycleToken) return;
      }
      await _setPhase(_Phase.exhale, p.exhale, token);
      if (!mounted || token != _cycleToken) return;
      await _breath
          .animateTo(
            0.15,
            duration: Duration(seconds: p.exhale),
            curve: Curves.easeInOut,
          )
          .catchError((_) {});
      if (!mounted || token != _cycleToken) return;

      if (p.holdAfter > 0) {
        await _setPhase(_Phase.holdAfterExhale, p.holdAfter, token);
        await Future.delayed(Duration(seconds: p.holdAfter));
      }
    }
  }

  String get _phaseText {
    switch (_phase) {
      case _Phase.inhale:
        return 'Breathe in';
      case _Phase.hold:
      case _Phase.holdAfterExhale:
        return 'Hold';
      case _Phase.exhale:
        return 'Breathe out';
    }
  }

  void _cycleSound() {
    setState(() => _soundIndex = (_soundIndex + 1) % _sounds.length);
    _playCurrentSound();
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sound: ${_sounds[_soundIndex].title}'),
        duration: const Duration(milliseconds: 900),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Seçili ortam sesini döngüyle çalar. "Kapalı" ise durdurur.
  Future<void> _playCurrentSound() async {
    try {
      final asset = _sounds[_soundIndex].asset;
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1033),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(AssetPaths.nefesBg, fit: BoxFit.cover),
          // Hafif karartma — yazılar okunsun, kedi ve yıldızlar görünsün
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.0, 0.45, 0.8, 1.0],
                colors: [
                  Color(0x4D000000),
                  Color(0x14000000),
                  Color(0x14000000),
                  Color(0x4D000000),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // ── Üst bar: görseldeki gibi sade geri oku + ortalı başlık
                Padding(
                  padding: const EdgeInsets.only(
                    left: 8,
                    right: 8,
                    top: 4,
                    bottom: 2,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          _pattern.title,
                          textAlign: TextAlign.center,
                          style: AppText.nunito(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // ── Küre ──
                BreathingOrb(animation: _breath),

                const SizedBox(height: 22),

                // ── Faz yazısı (görseldeki konum) ──
                Text(
                  _phaseText,
                  style: AppText.nunito(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    shadows: const [
                      Shadow(
                        color: Colors.black45,
                        blurRadius: 10,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: Text(
                    '$_secondsLeft sec',
                    key: ValueKey<int>(_secondsLeft),
                    style: AppText.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.92),
                    ),
                  ),
                ),

                const SizedBox(height: 26),

                // ── Desen sırası ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: PatternSelector(
                    selectedIndex: _patternIndex,
                    onChanged: (i) {
                      if (i == _patternIndex) return;
                      setState(() => _patternIndex = i);
                      _breath.stop();
                      _startLoop();
                    },
                  ),
                ),
                const SizedBox(height: 10),

                // ── Süre sırası ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: DurationSelector(
                    selectedIndex: _durationIndex,
                    onChanged: (i) {
                      setState(() => _durationIndex = i);
                      _startSessionTimer();
                    },
                  ),
                ),
                const SizedBox(height: 12),

                // ── Ses hapı ──
                SoundToggle(
                    sound: _sounds[_soundIndex].title, onTap: _cycleSound),

                // Kedi illüstrasyonu nefes.png'nin altında kalıyor
                const Spacer(),
                const SizedBox(height: 118),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
