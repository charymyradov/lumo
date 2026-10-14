import 'package:flutter/material.dart';
import 'package:lumo/core/constants/app_typography.dart';

/// Logo ikonu (shimmer) + "lumo" wordmark.
class SplashLogo extends StatelessWidget {
  final Animation<double> logoOpacity;
  final Animation<double> logoScale;
  final AnimationController logoController;
  final AnimationController shimmerController;
  final Animation<double> textOpacity;
  final Animation<Offset> textSlide;

  const SplashLogo({
    super.key,
    required this.logoOpacity,
    required this.logoScale,
    required this.logoController,
    required this.shimmerController,
    required this.textOpacity,
    required this.textSlide,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: logoController,
      builder: (context, child) {
        return FadeTransition(
          opacity: logoOpacity,
          child: ScaleTransition(scale: logoScale, child: child),
        );
      },
      child: Column(
        children: [
          AnimatedBuilder(
            animation: shimmerController,
            builder: (context, child) {
              return ShaderMask(
                shaderCallback: (bounds) {
                  return LinearGradient(
                    begin:
                        Alignment(-1 + shimmerController.value * 3, 0),
                    end: Alignment(0 + shimmerController.value * 3, 0),
                    colors: const [
                      Color(0xFFFFF9C4),
                      Color(0xFFFFD700),
                      Color(0xFFFFF9C4),
                    ],
                  ).createShader(bounds);
                },
                child: const Icon(
                  Icons.auto_awesome,
                  size: 72,
                  color: Colors.white,
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          FadeTransition(
            opacity: textOpacity,
            child: SlideTransition(
              position: textSlide,
              child: Text(
                'lumo',
                style: AppTypography.displayLarge.copyWith(
                  fontSize: 56,
                  letterSpacing: 2,
                  shadows: [
                    const Shadow(
                      color: Color(0x66000000),
                      blurRadius: 20,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
