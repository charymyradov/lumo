import 'package:flutter/material.dart';
import 'package:lumo/features/splash/presentation/pages/splash_animation_mixin.dart';
import 'package:lumo/features/splash/presentation/pages/widgets/splash_background.dart';
import 'package:lumo/features/splash/presentation/pages/widgets/splash_logo.dart';
import 'package:lumo/features/splash/presentation/pages/widgets/splash_particles.dart';

class SplashPage extends StatefulWidget {
  final VoidCallback onFinished;

  const SplashPage({super.key, required this.onFinished});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with TickerProviderStateMixin, SplashAnimationMixin {
  @override
  void initState() {
    super.initState();
    initSplashAnimations();
    runSplashSequence(widget.onFinished);
  }

  @override
  void dispose() {
    disposeSplashAnimations();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const SplashBackground(),
          SplashParticles(controller: particleController),
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 2),
                SplashLogo(
                  logoOpacity: logoOpacity,
                  logoScale: logoScale,
                  logoController: logoController,
                  shimmerController: shimmerController,
                  textOpacity: textOpacity,
                  textSlide: textSlide,
                ),
                const Spacer(flex: 2),
                SplashTagline(
                  opacity: taglineOpacity,
                  slide: taglineSlide,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
