import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lumo/core/constants/asset_paths.dart';
import 'package:lumo/features/breathing/presentation/widgets/breathing_orb.dart';
import 'package:lumo/features/breathing/presentation/widgets/duration_selector.dart';
import 'package:lumo/features/breathing/presentation/widgets/pattern_selector.dart';
import 'package:lumo/features/breathing/presentation/widgets/sound_toggle.dart';

/// 7. Nefes Egzersizi — görseldeki gibi:
/// nefes.png • geri + başlık • cam küre (smooth nefes) •
/// "Nefes al / 4 saniye" • desen sırası • süre sırası • ses hapı.
class BreathingPage extends StatefulWidget {
  const BreathingPage({super.key});

  @override
  State<BreathingPage> createState() => _BreathingPageState();
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
  _BreathingPattern(title: '4-7-8 Nefes', inhale: 4, hold: 7, exhale: 8),
  _BreathingPattern(title: 'Kutu Nefes', inhale: 4, hold: 4, exhale: 4, holdAfter: 4),
  _BreathingPattern(title: 'Derin Nefes', inhale: 4, hold: 2, exhale: 6),
];

const _sounds = ['Orman', 'Deniz', 'Yağmur', 'Kapalı'];

class _BreathingPageState extends State<BreathingPage>
    with SingleTickerProviderStateMixin {
  int _patternIndex = 2; // görselde "Derin Nefes"
  int _durationIndex = 0; // görselde "1 dk" vurgulu
  int _soundIndex = 0;

  _Phase _phase = _Phase.inhale;
  int _secondsLeft = 4;

  /// 0.15 → 1.0 arası SÜREKLİ nefes değeri. Faz süresi boyunca
  /// animateTo ile akıcı sürülür; basamaklı setState yok.
  late final AnimationController _breath;

  Timer? _countdown;
  int _cycleToken = 0;
  bool _loopRunning = false;

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
    _startLoop();
  }

  @override
  void dispose() {
    _cycleToken++;
    _countdown?.cancel();
    _breath.dispose();
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
        return 'Nefes al';
      case _Phase.hold:
      case _Phase.holdAfterExhale:
        return 'Tut';
      case _Phase.exhale:
        return 'Nefes ver';
    }
  }

  void _cycleSound() {
    setState(() => _soundIndex = (_soundIndex + 1) % _sounds.length);
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ses: ${_sounds[_soundIndex]}'),
        duration: const Duration(milliseconds: 900),
        behavior: SnackBarBehavior.floating,
      ),
    );
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
                          style: GoogleFonts.nunito(
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
                  style: GoogleFonts.nunito(
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
                    '$_secondsLeft saniye',
                    key: ValueKey<int>(_secondsLeft),
                    style: GoogleFonts.nunito(
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
                    onChanged: (i) => setState(() => _durationIndex = i),
                  ),
                ),
                const SizedBox(height: 12),

                // ── Ses hapı ──
                SoundToggle(sound: _sounds[_soundIndex], onTap: _cycleSound),

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
