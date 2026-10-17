import 'package:flutter/material.dart';

/// Lightweight press-scale tap wrapper used across Lumo buttons/tiles.
///
/// Replaces repeated `GestureDetector(onTap) + AnimatedContainer` patterns:
/// opaque hit-testing (no translucent miss cost), a cheap 120ms
/// [AnimatedScale] press effect and a [RepaintBoundary] so the scale
/// animation repaints in isolation instead of dirtying the parent list.
class LumoTap extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double pressedScale;
  final Duration duration;
  final bool enabled;

  const LumoTap({
    super.key,
    required this.child,
    this.onTap,
    this.pressedScale = 0.96,
    this.duration = const Duration(milliseconds: 120),
    this.enabled = true,
  });

  @override
  State<LumoTap> createState() => _LumoTapState();
}

class _LumoTapState extends State<LumoTap> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final active = widget.enabled && widget.onTap != null;
    return RepaintBoundary(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: active ? (_) => _setPressed(true) : null,
        onTapUp: active ? (_) => _setPressed(false) : null,
        onTapCancel: active ? () => _setPressed(false) : null,
        onTap: active ? widget.onTap : null,
        child: AnimatedScale(
          scale: _pressed && active ? widget.pressedScale : 1.0,
          duration: widget.duration,
          curve: Curves.easeOut,
          child: widget.child,
        ),
      ),
    );
  }
}
