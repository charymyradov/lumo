import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lumo/features/home/domain/entities/mascot_species.dart';
import 'package:lumo/features/home/domain/entities/pet_action_state.dart';
import 'package:lumo/features/home/presentation/pet/pet_simulation.dart';
import 'package:lumo/features/home/presentation/pet/pet_stage/pet_paint_colors.dart';

/// Per-frame render context shared by all split pet-stage painters.
///
/// Holds no allocation-sensitive state so it is safe to recreate on every
/// paint call. Replaces the private fields + canvas helpers of the former
/// monolithic `_PetStageRenderer`.
class PetStageContext {
  PetStageContext({
    required this.canvas,
    required this.size,
    required this.sim,
    required this.species,
    required this.flags,
    this.isNight = false,
  });

  final Canvas canvas;
  final Size size;
  final PetRigSimulationState sim;
  final MascotSpecies species;
  final EquippedFlags flags;
  final bool isNight;

  double get w => size.width;
  double get h => size.height;

  bool get isSleeping => sim.locomotionMode == PetActionState.sleep;
  bool get isPetted => sim.locomotionMode == PetActionState.petted;
  bool get isEating =>
      sim.locomotionMode == PetActionState.eat ||
      sim.locomotionMode == PetActionState.drink;
  bool get isDancing => sim.locomotionMode == PetActionState.dance;

  // ── Canvas helpers ─────────────────────────────────────────────────────

  Paint fill(Color color) => Paint()..color = color;

  Paint stroke(Color color, double width) => Paint()
    ..color = color
    ..style = PaintingStyle.stroke
    ..strokeWidth = width
    ..strokeCap = StrokeCap.round;

  void rotate(double degrees, Offset pivot, void Function() draw) {
    canvas.save();
    canvas.translate(pivot.dx, pivot.dy);
    canvas.rotate(degrees * math.pi / 180);
    canvas.translate(-pivot.dx, -pivot.dy);
    draw();
    canvas.restore();
  }

  void translateScale(
      double dx, double dy, double sx, double sy, void Function() draw) {
    canvas.save();
    canvas.translate(dx, dy);
    canvas.scale(sx, sy);
    draw();
    canvas.restore();
  }

  void oval(Color color, double left, double top, double width, double height) {
    canvas.drawOval(Rect.fromLTWH(left, top, width, height), fill(color));
  }

  void softShadowOval(
    double left,
    double top,
    double width,
    double height,
    Color color,
  ) {
    final rect = Rect.fromLTWH(left, top, width, height);
    canvas.drawOval(
      rect,
      Paint()
        ..color = color
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );
  }

  void softBlush(double cx, double cy, double size, double alpha) {
    final rect = Rect.fromCenter(
        center: Offset(cx, cy), width: size, height: size * 0.62);
    canvas.drawOval(
      rect,
      Paint()
        ..shader = RadialGradient(
          colors: [
            PetPaintColors.blushPink.withValues(alpha: alpha),
            PetPaintColors.blushPink.withValues(alpha: 0.0),
          ],
          stops: const [0.15, 1.0],
        ).createShader(rect),
    );
  }

  void strokeOval(Color color, double left, double top, double width,
      double height, double strokeWidth) {
    canvas.drawOval(
        Rect.fromLTWH(left, top, width, height), stroke(color, strokeWidth));
  }

  void roundRect(Color color, double left, double top, double width,
      double height, double radius) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(left, top, width, height),
        Radius.circular(radius),
      ),
      fill(color),
    );
  }

  void arc(
    Color color,
    double left,
    double top,
    double width,
    double height, {
    required double startAngle,
    required double sweepAngle,
    required bool useCenter,
    double strokeWidth = 0,
  }) {
    final paint = strokeWidth > 0 ? stroke(color, strokeWidth) : fill(color);
    canvas.drawArc(
      Rect.fromLTWH(left, top, width, height),
      startAngle * math.pi / 180,
      sweepAngle * math.pi / 180,
      useCenter,
      paint,
    );
  }

  /// Port of the monolith's `isRunningLocomotion` helper.
  bool isRunningLocomotion(double dist) {
    return dist > 0.22 ||
        sim.locomotionMode == PetActionState.run ||
        sim.locomotionMode == PetActionState.playBall;
  }

  double clamp01(double v) => clampDouble(v, 0, 1);
}
