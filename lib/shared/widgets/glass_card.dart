import 'dart:ui';

import 'package:flutter/material.dart';

/// Frosted-glass card used across Lumo screens.
/// Blurs whatever is behind it and lays a translucent white veil on top,
/// so the background photo still reads through the card.
///
/// Perf notes: sigma is clamped to <= 10 (cheaper than the old 18-24),
/// the [BackdropFilter] sits inside a [RepaintBoundary] so the blur
/// repaints in isolation, and [blurEnabled] skips the filter entirely
/// (plain translucent fill) on low-end devices.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double radius;
  final double blur;
  final double opacity;
  final Gradient? gradient;
  final List<BoxShadow>? boxShadow;
  final VoidCallback? onTap;
  final bool blurEnabled;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.radius = 24,
    this.blur = 10,
    this.opacity = 0.45,
    this.gradient,
    this.boxShadow,
    this.onTap,
    this.blurEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final sigma = blurEnabled ? blur.clamp(0.0, 10.0) : 0.0;
    final veil = Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: gradient ??
            LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: opacity + 0.15),
                Colors.white.withValues(alpha: opacity),
              ],
            ),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.55),
          width: 1.2,
        ),
      ),
      child: child,
    );

    final card = ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: blurEnabled && sigma > 0
          ? RepaintBoundary(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
                child: veil,
              ),
            )
          : veil,
    );

    final decorated = RepaintBoundary(
      child: Container(
        margin: margin,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          boxShadow: boxShadow ??
              const [
                BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 12,
                  spreadRadius: 0,
                  offset: Offset(0, 8),
                ),
              ],
        ),
        child: card,
      ),
    );

    if (onTap == null) return decorated;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: decorated,
    );
  }
}
