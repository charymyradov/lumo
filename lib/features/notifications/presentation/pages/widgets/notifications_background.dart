import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:lumo/core/constants/asset_paths.dart';

/// splash2.jpg arka plan + scrim (diğer sayfalarla aynı dil).
class NotificationsBackground extends StatelessWidget {
  const NotificationsBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return const Stack(
      fit: StackFit.expand,
      children: [
        _BlurredImage(),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.0, 0.18, 0.45, 1.0],
              colors: [
                Color(0x40FFFFFF),
                Color(0x66FFFFFF),
                Color(0xB3FFFFFF),
                Color(0xD9FFFFFF),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _BlurredImage extends StatelessWidget {
  const _BlurredImage();

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Image.asset(
            AssetPaths.splash2Jpg,
            fit: BoxFit.cover,
            alignment: Alignment.center,
            filterQuality: FilterQuality.low,
            gaplessPlayback: true,
            cacheWidth: 1080,
            excludeFromSemantics: true,
          ),
        ),
      ),
    );
  }
}
