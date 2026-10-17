import 'package:flutter/material.dart';
import 'package:lumo/core/constants/app_typography.dart';
import 'package:lumo/core/constants/asset_paths.dart';

/// Arka plan görseli + okunabilirlik gradyanı.
class SplashBackground extends StatelessWidget {
  const SplashBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          AssetPaths.splash1,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.low,
          gaplessPlayback: true,
          cacheWidth: 1080,
          excludeFromSemantics: true,
        ),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Color(0x66000000)],
              stops: [0.5, 1.0],
            ),
          ),
        ),
      ],
    );
  }
}

/// Tagline + alt bar.
class SplashTagline extends StatelessWidget {
  final Animation<double> opacity;
  final Animation<Offset> slide;

  const SplashTagline({
    super.key,
    required this.opacity,
    required this.slide,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FadeTransition(
          opacity: opacity,
          child: SlideTransition(
            position: slide,
            child: Text(
              'Small steps, big happiness.',
              style: AppTypography.taglineText.copyWith(letterSpacing: 0.5),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        const SizedBox(height: 8),
        FadeTransition(
          opacity: opacity,
          child: Container(
            width: 60,
            height: 4,
            margin: const EdgeInsets.only(bottom: 32, top: 16),
            decoration: BoxDecoration(
              color: Colors.white54,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ],
    );
  }
}
