import 'package:flutter/material.dart';
import 'package:lumo/core/constants/asset_paths.dart';
import 'package:lumo/features/breathing/presentation/pages/breathing_controller.dart';
import 'package:lumo/features/breathing/presentation/widgets/breathing_header.dart';
import 'package:lumo/features/breathing/presentation/widgets/breathing_orb.dart';
import 'package:lumo/features/breathing/presentation/widgets/breathing_phase_display.dart';
import 'package:lumo/features/breathing/presentation/widgets/duration_selector.dart';
import 'package:lumo/features/breathing/presentation/widgets/pattern_selector.dart';
import 'package:lumo/features/breathing/presentation/widgets/sound_toggle.dart';

/// Nefes oturumunun görsel gövdesi: arka plan + küre + faz + seçiciler.
///
/// [BreathingController]'ı dinler; faz/sayaç değişimlerinde yalnızca bu
/// gövde yeniden kurulur.
class BreathingSessionView extends StatelessWidget {
  const BreathingSessionView({super.key, required this.controller});

  final BreathingController controller;

  void _onSoundTap(BuildContext context) {
    controller.cycleSound();
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sound: ${controller.currentSound.title}'),
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
            child: ListenableBuilder(
              listenable: controller,
              builder: (context, _) => Column(
                children: [
                  BreathingHeader(
                    title: controller.pattern.title,
                    onBack: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(height: 30),

                  // ── Küre ──
                  BreathingOrb(animation: controller.breath),

                  const SizedBox(height: 22),

                  // ── Faz yazısı (görseldeki konum) ──
                  BreathingPhaseDisplay(
                    phaseText: controller.phaseText,
                    secondsLeft: controller.secondsLeft,
                  ),

                  const SizedBox(height: 26),

                  // ── Desen sırası ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: PatternSelector(
                      selectedIndex: controller.patternIndex,
                      onChanged: controller.selectPattern,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // ── Süre sırası ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: DurationSelector(
                      selectedIndex: controller.durationIndex,
                      onChanged: controller.selectDuration,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ── Ses hapı ──
                  SoundToggle(
                    sound: controller.currentSound.title,
                    onTap: () => _onSoundTap(context),
                  ),

                  // Kedi illüstrasyonu nefes.png'nin altında kalıyor
                  const Spacer(),
                  const SizedBox(height: 118),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
