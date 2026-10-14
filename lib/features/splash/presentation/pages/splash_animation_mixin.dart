import 'package:flutter/material.dart';

/// Dört animasyon controller'ının kurulum + yaşam döngüsü.
mixin SplashAnimationMixin<T extends StatefulWidget> on State<T>,
    TickerProviderStateMixin<T> {
  late AnimationController logoController;
  late AnimationController textController;
  late AnimationController shimmerController;
  late AnimationController particleController;

  late Animation<double> logoScale;
  late Animation<double> logoOpacity;
  late Animation<double> textOpacity;
  late Animation<Offset> textSlide;
  late Animation<double> taglineOpacity;
  late Animation<Offset> taglineSlide;

  bool splashDisposed = false;

  void initSplashAnimations() {
    logoController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    textController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );
    shimmerController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    particleController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();

    logoScale = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: logoController, curve: Curves.elasticOut),
    );
    logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: logoController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );
    textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: textController, curve: Curves.easeIn),
    );
    textSlide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: textController, curve: Curves.easeOutCubic),
    );
    taglineOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: textController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeIn),
      ),
    );
    taglineSlide = Tween<Offset>(
      begin: const Offset(0, 0.8),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: textController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOutCubic),
      ),
    );
  }

  Future<void> runSplashSequence(VoidCallback onFinished) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted || splashDisposed) return;
    logoController.forward();

    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted || splashDisposed) return;
    textController.forward();

    await Future.delayed(const Duration(milliseconds: 2200));
    if (!mounted || splashDisposed) return;
    onFinished();
  }

  void disposeSplashAnimations() {
    splashDisposed = true;
    logoController.dispose();
    textController.dispose();
    shimmerController.dispose();
    particleController.dispose();
  }
}
