import 'package:flutter/material.dart';
import 'package:lumo/core/constants/asset_paths.dart';

/// Shared background for all onboarding screens.
/// splash.jpg fills the WHOLE screen (BoxFit.cover) and a soft light scrim
/// fades it into the lavender tones the page content sits on, so titles and
/// cards stay readable at the bottom.
class OnboardingBackground extends StatelessWidget {
  final Widget child;

  const OnboardingBackground({super.key, required this.child});

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
          child,
        ],
      ),
    );
  }
}
