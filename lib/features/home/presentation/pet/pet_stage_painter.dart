import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lumo/features/home/domain/entities/mascot_species.dart';
import 'package:lumo/features/home/domain/entities/pet_action_state.dart';
import 'package:lumo/features/home/presentation/pet/pet_simulation.dart';

/// Procedural, fully vector pet renderer.
///
/// Direct port of the `DrawScope` render pass of the Kotlin `LumoPetEngine.kt`
/// (`renderPetStageScene` + every `drawXxx` helper). Everything is painted with
/// primitives, so no sprite atlas is required and every species / cosmetic
/// combination keeps animating smoothly.
class PetStagePainter extends CustomPainter {
  PetStagePainter({
    required this.sim,
    required this.species,
    required this.flags,
    super.repaint,
  });

  final PetRigSimulationState sim;
  final MascotSpecies species;
  final EquippedFlags flags;

  @override
  void paint(Canvas canvas, Size size) {
    _PetStageRenderer(canvas: canvas, size: size, sim: sim, species: species, flags: flags)
        .render();
  }

  @override
  bool shouldRepaint(covariant PetStagePainter oldDelegate) {
    return oldDelegate.species != species || oldDelegate.flags != flags;
  }
}

/// Stateless-per-frame renderer helper. Holds no allocation-sensitive state so
/// it is safe to recreate on every paint call.
class _PetStageRenderer {
  _PetStageRenderer({
    required this.canvas,
    required this.size,
    required this.sim,
    required this.species,
    required this.flags,
  });

  final Canvas canvas;
  final Size size;
  final PetRigSimulationState sim;
  final MascotSpecies species;
  final EquippedFlags flags;

  static const Color _white = Colors.white;
  static const Color _blushPink = Color(0xFFF472B6);
  static const Color _deepNose = Color(0xFF4C1D95);
  static const Color _pupilInk = Color(0xFF1E1B4B);
  static const Color _eyeLid = Color(0xFF2E1065);

  double get _w => size.width;
  double get _h => size.height;

  bool get _isSleeping => sim.locomotionMode == PetActionState.sleep;
  bool get _isPetted => sim.locomotionMode == PetActionState.petted;
  bool get _isEating => sim.locomotionMode == PetActionState.eat ||
      sim.locomotionMode == PetActionState.drink;
  bool get _isDancing => sim.locomotionMode == PetActionState.dance;

  // ── Canvas helpers ───────────────────────────────────────────────────────

  Paint _fill(Color color) => Paint()..color = color;

  Paint _stroke(Color color, double width) => Paint()
    ..color = color
    ..style = PaintingStyle.stroke
    ..strokeWidth = width
    ..strokeCap = StrokeCap.round;

  void _rotate(double degrees, Offset pivot, void Function() draw) {
    canvas.save();
    canvas.translate(pivot.dx, pivot.dy);
    canvas.rotate(degrees * math.pi / 180);
    canvas.translate(-pivot.dx, -pivot.dy);
    draw();
    canvas.restore();
  }

  void _translateScale(double dx, double dy, double sx, double sy, void Function() draw) {
    canvas.save();
    canvas.translate(dx, dy);
    canvas.scale(sx, sy);
    draw();
    canvas.restore();
  }

  void _oval(Color color, double left, double top, double width, double height) {
    canvas.drawOval(Rect.fromLTWH(left, top, width, height), _fill(color));
  }

  void _strokeOval(
      Color color, double left, double top, double width, double height, double strokeWidth) {
    canvas.drawOval(Rect.fromLTWH(left, top, width, height), _stroke(color, strokeWidth));
  }

  void _roundRect(Color color, double left, double top, double width, double height, double radius) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(left, top, width, height),
        Radius.circular(radius),
      ),
      _fill(color),
    );
  }

  void _arc(
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
    final paint = strokeWidth > 0
        ? _stroke(color, strokeWidth)
        : _fill(color);
    canvas.drawArc(
      Rect.fromLTWH(left, top, width, height),
      startAngle * math.pi / 180,
      sweepAngle * math.pi / 180,
      useCenter,
      paint,
    );
  }

  // ── Scene ────────────────────────────────────────────────────────────────

  void render() {
    if (flags.hasCloudBed) {
      _drawStageCloudBed(_w * 0.26, _h * 0.71, _w * 0.00095);
    }
    if (flags.hasLantern) {
      _drawStageFairyLantern(_w * 0.82, _h * 0.63, sim.timeSec);
    }

    if (sim.tapRingAlpha > 0) {
      final rx = sim.tapRingX * _w;
      final ry = sim.tapRingY * _h;
      final ringRadius = (1 - sim.tapRingAlpha) * 48 + 16;
      _strokeOval(
        _white.withValues(alpha: sim.tapRingAlpha * 0.75),
        rx - ringRadius,
        ry - ringRadius * 0.42,
        ringRadius * 2,
        ringRadius * 0.84,
        3.5,
      );
    }

    final dist = (Offset(sim.targetX, sim.targetY) - Offset(sim.petX, sim.petY)).distance;
    final isMoving = dist > 0.016 && sim.locomotionMode != PetActionState.sleep;
    final isRunning =
        isRunningLocomotion(dist);

    final depthScale = clampDouble(0.85 + (sim.petY - 0.58) * 1.1, 0.82, 1.12);
    final jumpSin =
        sim.jumpPhase > 0 ? math.sin(sim.jumpPhase * math.pi) : 0.0;
    final jumpHeightPx = jumpSin * (_h * 0.11);

    final double squashX;
    if (sim.jumpPhase >= 0.01 && sim.jumpPhase <= 0.18) {
      squashX = 1.14;
    } else if (jumpSin > 0.4) {
      squashX = 0.92;
    } else if (sim.locomotionMode == PetActionState.petted) {
      squashX = 1.05 + math.sin(sim.timeSec * 8) * 0.03;
    } else {
      squashX = 1;
    }
    final stretchY = 2 - squashX;

    final anchorX = sim.petX * _w;
    final anchorY = sim.petY * _h;

    // Ground shadow (shrinks while the pet is airborne).
    final shadowRadiusX = 76 * depthScale * (1 - jumpSin * 0.35);
    final shadowRadiusY = 22 * depthScale * (1 - jumpSin * 0.35);
    _oval(
      const Color(0x481E1B4B),
      anchorX - shadowRadiusX,
      anchorY + 46 * depthScale - shadowRadiusY,
      shadowRadiusX * 2,
      shadowRadiusY * 2,
    );

    final baseScale = (_w / 1080) * 1.05 * depthScale;
    final facing = sim.smoothFacing >= 0 ? 1.0 : -1.0;
    final isDancing = sim.locomotionMode == PetActionState.dance;
    final strideBob = isMoving
        ? math.sin(sim.gaitPhase).abs() * (isRunning ? -16.0 : -9.0)
        : 0.0;
    final danceBob =
        isDancing ? math.sin(sim.timeSec * 10).abs() * -18.0 : 0.0;

    canvas.save();
    canvas.translate(anchorX, anchorY - jumpHeightPx + strideBob + danceBob);
    canvas.scale(baseScale * squashX * facing, baseScale * stretchY);

    _drawPetTailAndWings(isMoving: isMoving, isRunning: isRunning);
    _drawPetLimbsAndTorso(isMoving: isMoving, isRunning: isRunning, jumpSin: jumpSin);
    _drawPetHeadAndFace(isRunning: isRunning, jumpSin: jumpSin);

    canvas.restore();

    // Props -----------------------------------------------------------------
    if (sim.locomotionMode == PetActionState.eat) {
      _drawFoodBowlProp(
        anchorX + facing * 76 * depthScale,
        anchorY + 42 * depthScale,
        sim.timeSec,
      );
    } else if (sim.locomotionMode == PetActionState.drink) {
      _drawWaterBowlProp(
        anchorX + facing * 76 * depthScale,
        anchorY + 42 * depthScale,
        sim.timeSec,
      );
    } else if (sim.locomotionMode == PetActionState.groom) {
      _drawGroomingBubbles(anchorX, anchorY - 35 * depthScale, sim.timeSec);
    }

    if (sim.showToyBall) {
      _drawStarToyBall(sim.ballX * _w, sim.ballY * _h, sim.timeSec * 260);
    }

    _drawParticles();
  }

  bool isRunningLocomotion(double dist) {
    return dist > 0.22 ||
        sim.locomotionMode == PetActionState.run ||
        sim.locomotionMode == PetActionState.playBall;
  }

  void _drawParticles() {
    for (final p in sim.particles) {
      if (p.life <= 0) continue;
      final px = p.x * _w;
      final py = p.y * _h;
      final lifeAlpha = clampDouble(p.life, 0, 1);
      final color = p.color.withValues(alpha: lifeAlpha);

      if (p.isHeart) {
        final r = 13 * lifeAlpha;
        canvas.drawCircle(Offset(px - r * 0.35, py), r * 0.55, _fill(color));
        canvas.drawCircle(Offset(px + r * 0.35, py), r * 0.55, _fill(color));
        final heartPath = Path()
          ..moveTo(px - r * 0.85, py + r * 0.1)
          ..lineTo(px, py + r * 1.1)
          ..lineTo(px + r * 0.85, py + r * 0.1)
          ..close();
        canvas.drawPath(heartPath, _fill(color));
      } else {
        canvas.drawCircle(Offset(px, py), 7 * lifeAlpha, _fill(color));
      }
    }
  }

  // ── Tail & wings ─────────────────────────────────────────────────────────

  void _drawPetTailAndWings({required bool isMoving, required bool isRunning}) {
    final tailSpeed = _isPetted || _isEating || _isDancing
        ? 14.0
        : isRunning
            ? 12.0
            : isMoving
                ? 7.5
                : _isSleeping
                    ? 1.5
                    : 3.6;

    final tailSwing = math.sin(sim.timeSec * tailSpeed) *
        (_isPetted || _isDancing ? 26.0 : _isSleeping ? 5.0 : 16.0);
    final tailPivot = Offset(-52, _isSleeping ? 38.0 : 18.0);

    _rotate(_isSleeping ? -35 + tailSwing : 15 + tailSwing, tailPivot, () {
      final tailPath = Path()
        ..moveTo(tailPivot.dx, tailPivot.dy)
        ..cubicTo(
          tailPivot.dx - 75,
          tailPivot.dy - 85,
          tailPivot.dx - 145,
          tailPivot.dy - 35 + tailSwing * 0.9,
          tailPivot.dx - 118,
          tailPivot.dy + 42,
        )
        ..cubicTo(
          tailPivot.dx - 85,
          tailPivot.dy + 78,
          tailPivot.dx - 32,
          tailPivot.dy + 48,
          tailPivot.dx,
          tailPivot.dy + 16,
        )
        ..close();
      canvas.drawPath(tailPath, _fill(species.primaryEarColor));
      canvas.drawCircle(
        Offset(tailPivot.dx - 86, tailPivot.dy + 2 + tailSwing * 0.25),
        36,
        _fill(species.secondaryFurColor),
      );
      canvas.drawCircle(
        Offset(tailPivot.dx - 104, tailPivot.dy - 4 + tailSwing * 0.35),
        28,
        _fill(_white),
      );
    });

    if (flags.hasButterflyWings) {
      final flap =
          0.72 + 0.28 * math.sin(sim.timeSec * (isMoving ? 14 : 6));
      _translateScale(-18, -10, flap, 1, () {
        _oval(const Color(0xCC38BDF8), -78, -68, 78, 92);
        _oval(const Color(0xCCBAE6FD), -64, -48, 48, 56);
        _oval(const Color(0xCC818CF8), -64, 4, 58, 62);
      });
    }
  }

  // ── Limbs & torso ────────────────────────────────────────────────────────

  void _drawPetLimbsAndTorso({
    required bool isMoving,
    required bool isRunning,
    required double jumpSin,
  }) {
    final breathWave =
        math.sin(sim.timeSec * (_isSleeping ? 2.2 : 3.8));

    final strideAmp = isRunning
        ? 42.0
        : isMoving
            ? 28.0
            : _isDancing
                ? 24.0
                : jumpSin > 0.1
                    ? 30.0
                    : 0.0;

    final gaitPhase = sim.gaitPhase;
    final flPhase = _isDancing ? sim.timeSec * 10 : gaitPhase;
    final brPhase = isRunning ? gaitPhase + math.pi * 0.85 : gaitPhase + 0.4;
    final frPhase = isRunning ? gaitPhase + 0.35 : gaitPhase + math.pi;
    final blPhase = isRunning ? gaitPhase + math.pi * 1.15 : gaitPhase + math.pi + 0.4;

    final activeStride = isMoving || _isDancing || jumpSin > 0.1;
    final frontLeftHip = activeStride ? math.sin(flPhase) * strideAmp : 0.0;
    final frontLeftKnee =
        activeStride ? math.max(0.0, math.cos(flPhase)) * (strideAmp * 0.75) : 0.0;
    final frontRightHip = activeStride ? math.sin(frPhase) * strideAmp : 0.0;
    final frontRightKnee =
        activeStride ? math.max(0.0, math.cos(frPhase)) * (strideAmp * 0.75) : 0.0;
    final backLeftHip = activeStride ? math.sin(blPhase) * strideAmp : 0.0;
    final backLeftKnee =
        activeStride ? math.max(0.0, -math.cos(blPhase)) * (strideAmp * 0.7) : 0.0;
    final backRightHip = activeStride ? math.sin(brPhase) * strideAmp : 0.0;
    final backRightKnee =
        activeStride ? math.max(0.0, -math.cos(brPhase)) * (strideAmp * 0.7) : 0.0;

    if (!_isSleeping) {
      _drawArticulatedLimb(
        hipX: -34,
        hipY: 38,
        hipAngleDeg: backRightHip,
        kneeAngleDeg: backRightKnee,
        upperColor: species.secondaryFurColor,
        lowerColor: const Color(0xFFDDD6FE),
        pawColor: const Color(0xFFF5F3FF),
      );
      _drawArticulatedLimb(
        hipX: 32,
        hipY: 36,
        hipAngleDeg: frontRightHip,
        kneeAngleDeg: frontRightKnee,
        upperColor: species.secondaryFurColor,
        lowerColor: const Color(0xFFDDD6FE),
        pawColor: const Color(0xFFF5F3FF),
      );
    }

    final double torsoPitch;
    if (_isSleeping) {
      torsoPitch = 14;
    } else if (_isEating) {
      torsoPitch = 18;
    } else if (isRunning) {
      torsoPitch = math.sin(gaitPhase) * 11 - 6;
    } else if (jumpSin > 0.1) {
      torsoPitch = -14;
    } else if (_isDancing) {
      torsoPitch = math.sin(sim.timeSec * 10) * 9;
    } else {
      torsoPitch = breathWave * 1.8;
    }

    _rotate(torsoPitch, const Offset(0, 25), () {
      final breathScale = 1 + breathWave * 0.035;
      _oval(species.secondaryFurColor, -58, -14, 116 * breathScale, 78 * breathScale);
      _oval(_white, -46, -10, 98 * breathScale, 66 * breathScale);

      final ruffPath = Path()
        ..moveTo(12, -10)
        ..quadraticBezierTo(58, -6, 64, 16)
        ..quadraticBezierTo(48, 28, 38, 40)
        ..quadraticBezierTo(14, 36, 2, 18)
        ..close();
      canvas.drawPath(ruffPath, _fill(_white));

      if (flags.hasCozyScarf) {
        _roundRect(const Color(0xFFA78BFA), -8, -12, 66, 22, 11);
        _roundRect(const Color(0xFF8B5CF6), 28, 4, 20, 36, 8);
      }
      if (flags.hasRibbonBow) {
        canvas.drawCircle(const Offset(22, 2), 14, _fill(const Color(0xFFF43F5E)));
        canvas.drawCircle(const Offset(44, 2), 14, _fill(const Color(0xFFFB7185)));
        canvas.drawCircle(const Offset(33, 2), 8, _fill(const Color(0xFFFDA4AF)));
      }
    });

    if (!_isSleeping) {
      _drawArticulatedLimb(
        hipX: -42,
        hipY: 42,
        hipAngleDeg: backLeftHip,
        kneeAngleDeg: backLeftKnee,
        upperColor: _white,
        lowerColor: species.secondaryFurColor,
        pawColor: _white,
        showPinkPad: true,
      );
      _drawArticulatedLimb(
        hipX: 24,
        hipY: 40,
        hipAngleDeg: frontLeftHip,
        kneeAngleDeg: frontLeftKnee,
        upperColor: _white,
        lowerColor: species.secondaryFurColor,
        pawColor: _white,
        showPinkPad: true,
      );
    } else {
      _oval(_white, 14, 44, 36, 22);
      _oval(_white, -22, 46, 36, 22);
    }
  }

  void _drawArticulatedLimb({
    required double hipX,
    required double hipY,
    required double hipAngleDeg,
    required double kneeAngleDeg,
    required Color upperColor,
    required Color lowerColor,
    required Color pawColor,
    bool showPinkPad = false,
  }) {
    const upperLen = 24.0;
    const lowerLen = 22.0;

    _rotate(hipAngleDeg, Offset(hipX, hipY), () {
      _roundRect(upperColor, hipX - 13, hipY - 6, 26, upperLen + 10, 13);
      final kneeX = hipX;
      final kneeY = hipY + upperLen;
      _rotate(kneeAngleDeg, Offset(kneeX, kneeY), () {
        _roundRect(lowerColor, kneeX - 11, kneeY - 4, 22, lowerLen + 8, 11);
        final pawY = kneeY + lowerLen;
        _oval(pawColor, kneeX - 14, pawY - 6, 30, 18);
        if (showPinkPad) {
          canvas.drawCircle(
            Offset(kneeX + 4, pawY + 3),
            4.5,
            _fill(_blushPink.withValues(alpha: 0.65)),
          );
        }
      });
    });
  }

  // ── Head & face ──────────────────────────────────────────────────────────

  void _drawPetHeadAndFace({required bool isRunning, required double jumpSin}) {
    final breathWave = math.sin(sim.timeSec * (_isSleeping ? 2.2 : 3.8));

    final double headPitch;
    if (_isSleeping) {
      headPitch = 22;
    } else if (_isEating) {
      headPitch = 26 + math.sin(sim.timeSec * 11).abs() * 7;
    } else if (_isPetted) {
      headPitch = -8 + math.sin(sim.timeSec * 7) * 6;
    } else if (isRunning) {
      headPitch = -6 + math.cos(sim.gaitPhase) * 5;
    } else {
      headPitch = breathWave * 2.5 + sim.lookOffsetY * 22;
    }

    final earSpeed = _isPetted || _isEating || _isDancing ? 11.0 : 3.2;
    final earAmp = _isPetted || _isDancing ? 14.0 : 6.0;
    final leftEarAngle =
        -18 + math.sin(sim.timeSec * earSpeed) * earAmp - (isRunning ? 12 : 0);
    final rightEarAngle =
        18 - math.cos(sim.timeSec * earSpeed + 0.7) * earAmp + (isRunning ? 12 : 0);

    final headPivot = Offset(18, _isSleeping ? 2.0 : -24.0);

    _rotate(headPitch, headPivot, () {
      final hcX = headPivot.dx;
      final hcY = headPivot.dy - 42;
      final earHeight = species == MascotSpecies.bunny ? 115.0 : 82.0;
      final earWidth = species == MascotSpecies.cat ? 54.0 : 62.0;

      _rotate(leftEarAngle, Offset(hcX - 34, hcY - 38), () {
        _drawSculptedEar(
          baseX: hcX - 34,
          baseY: hcY - 38,
          earWidth: earWidth,
          earHeight: earHeight,
          innerColor: species.primaryEarColor,
          outerColor: species.secondaryFurColor,
        );
      });
      _rotate(rightEarAngle, Offset(hcX + 34, hcY - 38), () {
        _drawSculptedEar(
          baseX: hcX + 34,
          baseY: hcY - 38,
          earWidth: earWidth,
          earHeight: earHeight,
          innerColor: species.primaryEarColor,
          outerColor: _white,
        );
      });

      if (flags.hasCatHood) {
        canvas.drawCircle(
          Offset(hcX, hcY + 2),
          78,
          _fill(const Color(0xFFF472B6)),
        );
      }

      // Cheek flares
      final cheekPath = Path()
        ..moveTo(hcX - 52, hcY - 8)
        ..quadraticBezierTo(hcX - 96, hcY + 14, hcX - 74, hcY + 34)
        ..quadraticBezierTo(hcX - 88, hcY + 46, hcX - 52, hcY + 48)
        ..close()
        ..moveTo(hcX + 52, hcY - 8)
        ..quadraticBezierTo(hcX + 96, hcY + 14, hcX + 74, hcY + 34)
        ..quadraticBezierTo(hcX + 88, hcY + 46, hcX + 52, hcY + 48)
        ..close();
      canvas.drawPath(cheekPath, _fill(_white));

      // Main head sphere
      _oval(species.secondaryFurColor, hcX - 68, hcY - 58, 136, 118);
      _oval(_white, hcX - 62, hcY - 54, 124, 108);
      _oval(
        species.primaryEarColor.withValues(alpha: 0.35),
        hcX - 36,
        hcY - 54,
        72,
        36,
      );

      // Forehead tuft
      final tuftPath = Path()
        ..moveTo(hcX - 12, hcY - 54)
        ..quadraticBezierTo(hcX, hcY - 82, hcX + 16, hcY - 62)
        ..quadraticBezierTo(hcX + 24, hcY - 74, hcX + 22, hcY - 50)
        ..close();
      canvas.drawPath(tuftPath, _fill(_white));

      // Rosy blush
      final blushAlpha = _isPetted ? 0.58 : 0.36;
      _oval(_blushPink.withValues(alpha: blushAlpha), hcX - 56, hcY + 14, 28, 16);
      _oval(_blushPink.withValues(alpha: blushAlpha), hcX + 32, hcY + 14, 28, 16);

      _drawPetEyesAndMouth(hcX: hcX, hcY: hcY, isRunning: isRunning, jumpSin: jumpSin);
      _drawPetHeadCosmetics(hcX: hcX, hcY: hcY);
    });
  }

  void _drawPetEyesAndMouth({
    required double hcX,
    required double hcY,
    required bool isRunning,
    required double jumpSin,
  }) {
    final leftEyeCenter = Offset(hcX - 26, hcY + 2);
    final rightEyeCenter = Offset(hcX + 30, hcY + 2);

    if (_isSleeping) {
      _arc(_deepNose, leftEyeCenter.dx - 16, leftEyeCenter.dy - 8, 32, 20,
          startAngle: 15, sweepAngle: 150, useCenter: false, strokeWidth: 4.5);
      _arc(_deepNose, rightEyeCenter.dx - 16, rightEyeCenter.dy - 8, 32, 20,
          startAngle: 15, sweepAngle: 150, useCenter: false, strokeWidth: 4.5);
    } else if (_isPetted ||
        sim.isBlinking ||
        (_isEating && math.sin(sim.timeSec * 8) > 0.2)) {
      _arc(_deepNose, leftEyeCenter.dx - 16, leftEyeCenter.dy - 10, 32, 22,
          startAngle: 195, sweepAngle: 150, useCenter: false, strokeWidth: 5);
      _arc(_deepNose, rightEyeCenter.dx - 16, rightEyeCenter.dy - 10, 32, 22,
          startAngle: 195, sweepAngle: 150, useCenter: false, strokeWidth: 5);
    } else {
      final pupilShiftX = clampDouble(sim.lookOffsetX * 14, -6, 6);
      final pupilShiftY = clampDouble(sim.lookOffsetY * 14, -5, 5);
      _drawSingleExpressiveEye(leftEyeCenter, pupilShiftX, pupilShiftY);
      _drawSingleExpressiveEye(rightEyeCenter, pupilShiftX, pupilShiftY);
    }

    // Nose
    final noseCenter = Offset(hcX + 3, hcY + 18);
    _oval(_deepNose, noseCenter.dx - 7, noseCenter.dy - 4.5, 14, 9);
    canvas.drawCircle(
      Offset(noseCenter.dx - 2, noseCenter.dy - 2),
      2.2,
      _fill(_white.withValues(alpha: 0.7)),
    );

    // Jaw
    final double jawOpen;
    if (_isEating) {
      jawOpen = math.sin(sim.timeSec * 13).abs() * 14 + 4;
    } else if (isRunning || jumpSin > 0.2 || _isDancing) {
      jawOpen = 10;
    } else {
      jawOpen = 0;
    }

    if (jawOpen > 2) {
      _roundRect(const Color(0xFF881337), noseCenter.dx - 10, noseCenter.dy + 6, 20, jawOpen, 9);
      _oval(const Color(0xFFFB7185), noseCenter.dx - 7, noseCenter.dy + 8, 14, jawOpen * 0.85);
    } else {
      _arc(_deepNose, noseCenter.dx - 12, noseCenter.dy + 3, 12, 9,
          startAngle: 10, sweepAngle: 160, useCenter: false, strokeWidth: 3.2);
      _arc(_deepNose, noseCenter.dx, noseCenter.dy + 3, 12, 9,
          startAngle: 10, sweepAngle: 160, useCenter: false, strokeWidth: 3.2);
    }
  }

  void _drawSingleExpressiveEye(Offset eyePos, double pupilShiftX, double pupilShiftY) {
    _oval(_white, eyePos.dx - 18, eyePos.dy - 20, 36, 40);
    final irisCenter = Offset(eyePos.dx + pupilShiftX, eyePos.dy + pupilShiftY);
    _oval(const Color(0xFF5B21B6), irisCenter.dx - 15, irisCenter.dy - 17, 30, 34);
    _oval(const Color(0xFFA78BFA), irisCenter.dx - 11, irisCenter.dy, 22, 15);
    canvas.drawCircle(irisCenter, 9.5, _fill(_pupilInk));
    canvas.drawCircle(
      Offset(irisCenter.dx - 5.5, irisCenter.dy - 6.5),
      6.2,
      _fill(_white),
    );
    canvas.drawCircle(
      Offset(irisCenter.dx + 5.5, irisCenter.dy + 6.5),
      3.2,
      _fill(_white.withValues(alpha: 0.85)),
    );
    _arc(_eyeLid, eyePos.dx - 18, eyePos.dy - 21, 36, 26,
        startAngle: 190, sweepAngle: 160, useCenter: false, strokeWidth: 4.2);
  }

  void _drawSculptedEar({
    required double baseX,
    required double baseY,
    required double earWidth,
    required double earHeight,
    required Color innerColor,
    required Color outerColor,
  }) {
    final earOuterPath = Path()
      ..moveTo(baseX - earWidth * 0.5, baseY + 10)
      ..quadraticBezierTo(baseX - earWidth * 0.65, baseY - earHeight * 0.65, baseX, baseY - earHeight)
      ..quadraticBezierTo(baseX + earWidth * 0.65, baseY - earHeight * 0.65, baseX + earWidth * 0.5, baseY + 10)
      ..close();
    canvas.drawPath(earOuterPath, _fill(outerColor));

    final earInnerPath = Path()
      ..moveTo(baseX - earWidth * 0.34, baseY + 6)
      ..quadraticBezierTo(
          baseX - earWidth * 0.44, baseY - earHeight * 0.58, baseX, baseY - earHeight * 0.84)
      ..quadraticBezierTo(
          baseX + earWidth * 0.44, baseY - earHeight * 0.58, baseX + earWidth * 0.34, baseY + 6)
      ..close();
    canvas.drawPath(earInnerPath, _fill(innerColor.withValues(alpha: 0.78)));

    _oval(_white, baseX - earWidth * 0.28, baseY - 10, earWidth * 0.56, 20);
  }

  void _drawPetHeadCosmetics({required double hcX, required double hcY}) {
    if (flags.hasStarGlasses) {
      final leftEyeCenter = Offset(hcX - 26, hcY + 2);
      final rightEyeCenter = Offset(hcX + 30, hcY + 2);
      canvas.drawCircle(leftEyeCenter, 22, _stroke(const Color(0xFFA855F7), 4.5));
      canvas.drawCircle(rightEyeCenter, 22, _stroke(const Color(0xFFA855F7), 4.5));
      canvas.drawLine(
        Offset(leftEyeCenter.dx + 20, leftEyeCenter.dy),
        Offset(rightEyeCenter.dx - 20, rightEyeCenter.dy),
        _stroke(const Color(0xFFFBBF24), 4.5),
      );
    }

    if (flags.hasCrown) {
      final crownPath = Path()
        ..moveTo(hcX - 28, hcY - 54)
        ..lineTo(hcX - 32, hcY - 86)
        ..lineTo(hcX - 12, hcY - 68)
        ..lineTo(hcX, hcY - 96)
        ..lineTo(hcX + 12, hcY - 68)
        ..lineTo(hcX + 32, hcY - 86)
        ..lineTo(hcX + 28, hcY - 54)
        ..close();
      canvas.drawPath(crownPath, _fill(const Color(0xFFFBBF24)));
      canvas.drawCircle(
        Offset(hcX, hcY - 66),
        5.5,
        _fill(const Color(0xFFEC4899)),
      );
    }

    if (flags.hasMushroomHat) {
      _arc(const Color(0xFFEF4444), hcX - 58, hcY - 102, 116, 84,
          startAngle: 180, sweepAngle: 180, useCenter: true);
      canvas.drawCircle(Offset(hcX - 24, hcY - 78), 10, _fill(_white));
      canvas.drawCircle(Offset(hcX + 18, hcY - 82), 12, _fill(_white));
      canvas.drawCircle(Offset(hcX, hcY - 68), 8, _fill(_white));
    }

    if (flags.hasWizardHat) {
      final hatPath = Path()
        ..moveTo(hcX, hcY - 126)
        ..lineTo(hcX - 42, hcY - 52)
        ..lineTo(hcX + 42, hcY - 52)
        ..close();
      canvas.drawPath(hatPath, _fill(const Color(0xFF2563EB)));
      _oval(const Color(0xFF1D4ED8), hcX - 58, hcY - 60, 116, 20);
      canvas.drawCircle(
        Offset(hcX, hcY - 84),
        7,
        _fill(const Color(0xFFFDE047)),
      );
    }

    if (flags.hasFlowerWreath) {
      for (var i = -2; i <= 2; i++) {
        final fx = hcX + i * 18.0;
        final fy = hcY - 54 + i.abs().toDouble() * 3;
        canvas.drawCircle(
          Offset(fx, fy),
          9.5,
          _fill(i.isEven ? const Color(0xFFF472B6) : const Color(0xFFFDE047)),
        );
        canvas.drawCircle(Offset(fx, fy), 3.5, _fill(_white));
      }
    }

    if (sim.locomotionMode == PetActionState.sleep) {
      final zProgress = (sim.timeSec * 0.6) % 1;
      for (var z = 0; z <= 2; z++) {
        final zp = (zProgress + z * 0.33) % 1;
        final zx = hcX + 48 + zp * 38;
        final zy = hcY - 45 - zp * 75;
        final alpha = clampDouble(1 - zp, 0, 1);
        canvas.drawCircle(
          Offset(zx, zy),
          8 + zp * 8,
          _fill(const Color(0xFFC4B5FD).withValues(alpha: alpha * 0.7)),
        );
      }
    }
  }

  // ── Stage props ──────────────────────────────────────────────────────────

  void _drawStageCloudBed(double cx, double cy, double scale) {
    _translateScale(cx, cy, scale, scale, () {
      _oval(const Color(0x441E1B4B), -130, 22, 260, 54);
      _roundRect(const Color(0xFF93C5FD), -115, -15, 230, 65, 32);
      canvas.drawCircle(const Offset(-62, -12), 48, _fill(_white));
      canvas.drawCircle(const Offset(0, -22), 58, _fill(_white));
      canvas.drawCircle(const Offset(62, -12), 48, _fill(_white));
      canvas.drawCircle(const Offset(-48, -18), 24, _fill(const Color(0xFFFBBF24)));
    });
  }

  void _drawStageFairyLantern(double cx, double cy, double timeSec) {
    final glow = 0.65 + 0.35 * math.sin(timeSec * 4);
    canvas.drawCircle(
      Offset(cx, cy),
      52 * glow,
      _fill(const Color(0x55FEF08A)),
    );
    _roundRect(const Color(0xFFFDE047), cx - 14, cy - 18, 28, 36, 8);
    canvas.drawLine(
      Offset(cx, cy - 42),
      Offset(cx, cy + 54),
      _stroke(const Color(0xFF78350F), 5),
    );
  }

  void _drawFoodBowlProp(double x, double y, double timeSec) {
    _oval(const Color(0xFFF472B6), x - 36, y - 12, 72, 28);
    canvas.drawCircle(
      Offset(x - 10, y - 10),
      11,
      _fill(const Color(0xFFA855F7)),
    );
    canvas.drawCircle(
      Offset(x + 8, y - 12),
      12,
      _fill(const Color(0xFFFB923C)),
    );
    canvas.drawCircle(Offset(x, y - 18), 9, _fill(const Color(0xFFFDE047)));
    final bounce = math.sin(timeSec * 12).abs() * 18;
    canvas.drawCircle(
      Offset(x - 18, y - 24 - bounce),
      4.5,
      _fill(const Color(0xFFFDE047)),
    );
    canvas.drawCircle(
      Offset(x + 18, y - 28 - bounce * 0.8),
      4,
      _fill(const Color(0xFFF472B6)),
    );
  }

  void _drawWaterBowlProp(double x, double y, double timeSec) {
    _oval(const Color(0xFF60A5FA), x - 36, y - 12, 72, 28);
    _oval(const Color(0xFFBAE6FD), x - 28, y - 10, 56, 18);
    final splash = math.sin(timeSec * 10).abs() * 22;
    canvas.drawCircle(
      Offset(x - 14, y - 16 - splash),
      5,
      _fill(const Color(0xFF93C5FD)),
    );
    canvas.drawCircle(
      Offset(x + 14, y - 20 - splash * 0.7),
      4.5,
      _fill(const Color(0xFFBAE6FD)),
    );
  }

  void _drawGroomingBubbles(double cx, double cy, double timeSec) {
    for (var i = 0; i <= 7; i++) {
      final angle = timeSec * 2.5 + i * 0.9;
      final bx = cx + math.cos(angle) * (48 + i * 8);
      final by = cy + math.sin(angle * 1.3) * 38 - (i * 6);
      final r = 10.0 + (i % 3) * 5;
      canvas.drawCircle(
        Offset(bx, by),
        r,
        _fill(const Color(0x99E0F2FE)),
      );
      canvas.drawCircle(Offset(bx, by), r, _stroke(_white, 2));
      canvas.drawCircle(
        Offset(bx - r * 0.3, by - r * 0.3),
        r * 0.25,
        _fill(_white),
      );
    }
  }

  void _drawStarToyBall(double x, double y, double rotationDeg) {
    _rotate(rotationDeg, Offset(x, y), () {
      canvas.drawCircle(Offset(x, y), 24, _fill(const Color(0xFFF59E0B)));
      canvas.drawCircle(
        Offset(x - 4, y - 4),
        16,
        _fill(const Color(0xFFFEF08A)),
      );
      canvas.drawCircle(Offset(x, y), 7, _fill(_white));
    });
  }
}
