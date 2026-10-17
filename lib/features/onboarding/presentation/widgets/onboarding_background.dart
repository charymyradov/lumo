import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lumo/core/constants/asset_paths.dart';

/// Shared background for all onboarding screens.
/// splash.jpg fills the WHOLE screen (BoxFit.cover) and a soft light scrim
/// fades it into the lavender tones the page content sits on, so titles and
/// cards stay readable at the bottom.
class OnboardingBackground extends StatefulWidget {
  final Widget child;

  const OnboardingBackground({super.key, required this.child});

  @override
  State<OnboardingBackground> createState() => _OnboardingBackgroundState();
}

class _OnboardingBackgroundState extends State<OnboardingBackground> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Sayfa geçişinde decode jank'i olmasın: arka plan + sıradaki
    // offstage görsel önceden ısıtılır (hata yutulur).
    for (final path in const [AssetPaths.splashBg, AssetPaths.splash2Jpg]) {
      unawaited(
        precacheImage(
          ResizeImage(AssetImage(path), width: 1080),
          context,
        ).catchError((_) {}),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Full-screen background image
          Image.asset(
            AssetPaths.splashBg,
            fit: BoxFit.cover,
            alignment: Alignment.center,
            filterQuality: FilterQuality.low,
            gaplessPlayback: true,
            cacheWidth: 1080,
            excludeFromSemantics: true,
          ),

          // Soft scrim: transparent at top -> light lavender at the bottom
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.0, 0.32, 0.62, 1.0],
                colors: [
                  Colors.transparent,
                  Color(0x59F3EEFF),
                  Color(0xE6F3EEFF),
                  Color(0xF5F3EEFF),
                ],
              ),
            ),
          ),

          // Page content
          widget.child,
        ],
      ),
    );
  }
}
