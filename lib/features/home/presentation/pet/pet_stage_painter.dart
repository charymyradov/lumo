import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lumo/features/home/domain/entities/mascot_species.dart';
import 'package:lumo/features/home/domain/entities/pet_action_state.dart';
import 'package:lumo/features/home/presentation/extensions/home_entities_ui.dart';
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
    this.isNight = false,
    super.repaint,
  });

  final PetRigSimulationState sim;
  final MascotSpecies species;
  final EquippedFlags flags;
  final bool isNight;

  @override
  void paint(Canvas canvas, Size size) {
    _PetStageRenderer(
            canvas: canvas,
            size: size,
            sim: sim,
            species: species,
            flags: flags,
            isNight: isNight)
        .render();
  }

  @override
  bool shouldRepaint(covariant PetStagePainter oldDelegate) {
    return oldDelegate.species != species ||
        oldDelegate.flags != flags ||
        oldDelegate.isNight != isNight;
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
    this.isNight = false,
  });

  final Canvas canvas;
  final Size size;
  final PetRigSimulationState sim;
  final MascotSpecies species;
  final EquippedFlags flags;
  final bool isNight;

  static const Color _white = Colors.white;
  static const Color _furWhite = Color(0xFFFDFBFF);
  static const Color _softLavender = Color(0xFFEDE7FF);
  static const Color _furShadow = Color(0xFFDDD6FE);
  static const Color _tailPurple = Color(0xFF8B5CF6);
  static const Color _tailDeep = Color(0xFF7C3AED);
  static const Color _earInner = Color(0xFF8B5CF6);
  static const Color _earDeep = Color(0xFF5B21B6);
  static const Color _blushPink = Color(0xFFF9A8D4);
  static const Color _blushDeep = Color(0xFFF472B6);
  static const Color _deepNose = Color(0xFF4C1D95);
  static const Color _pupilInk = Color(0xFF1E1B4B);
  static const Color _eyeLid = Color(0xFF4C1D95);
  static const Color _goldDark = Color(0xFFB45309);
  static const Color _goldLight = Color(0xFFFEF08A);
  static const Color _pawSock = Color(0xFF6D28D9);

  double get _w => size.width;
  double get _h => size.height;

  bool get _isSleeping => sim.locomotionMode == PetActionState.sleep;
  bool get _isPetted => sim.locomotionMode == PetActionState.petted;
  bool get _isEating =>
      sim.locomotionMode == PetActionState.eat ||
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

  void _translateScale(
      double dx, double dy, double sx, double sy, void Function() draw) {
    canvas.save();
    canvas.translate(dx, dy);
    canvas.scale(sx, sy);
    draw();
    canvas.restore();
  }

  void _oval(
      Color color, double left, double top, double width, double height) {
    canvas.drawOval(Rect.fromLTWH(left, top, width, height), _fill(color));
  }

  void _softShadowOval(
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

  void _softBlush(double cx, double cy, double size, double alpha) {
    final rect = Rect.fromCenter(
        center: Offset(cx, cy), width: size, height: size * 0.62);
    canvas.drawOval(
      rect,
      Paint()
        ..shader = RadialGradient(
          colors: [
            _blushPink.withValues(alpha: alpha),
            _blushPink.withValues(alpha: 0.0),
          ],
          stops: const [0.15, 1.0],
        ).createShader(rect),
    );
  }

  void _strokeOval(Color color, double left, double top, double width,
      double height, double strokeWidth) {
    canvas.drawOval(
        Rect.fromLTWH(left, top, width, height), _stroke(color, strokeWidth));
  }

  void _roundRect(Color color, double left, double top, double width,
      double height, double radius) {
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
    final paint = strokeWidth > 0 ? _stroke(color, strokeWidth) : _fill(color);
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

    final dist = (Offset(sim.targetX, sim.targetY) - Offset(sim.petX, sim.petY))
        .distance;
    final isMoving = dist > 0.016 && sim.locomotionMode != PetActionState.sleep;
    final isRunning = isRunningLocomotion(dist);

    final jumpSin = sim.jumpPhase > 0 ? math.sin(sim.jumpPhase * math.pi) : 0.0;
    final jumpHeightPx = jumpSin * (_h * 0.11);

    final double squashX;
    if (sim.jumpPhase >= 0.01 && sim.jumpPhase <= 0.18) {
      squashX = 1.10;
    } else if (jumpSin > 0.4) {
      squashX = 0.92;
    } else if (sim.locomotionMode == PetActionState.petted) {
      // Squash & stretch: dokunulunca hafif yassılıp toparlan (rehber §6.6).
      squashX = 1.05 + math.sin(sim.timeSec * 7) * 0.025;
    } else {
      squashX = 1;
    }
    final stretchY = 2 - squashX;

    final anchorX = sim.petX * _w;
    // Derinlik ölçeği pet'in dikey konumundan gelir; önce onu çöz.
    final depthScale = clampDouble(0.92 + (sim.petY - 0.58) * 1.35, 0.9, 1.35);
    final baseScale = (_w / 1080) * 1.8 * depthScale;

    // Lumi alt-ortada durur; alt bakım buton şeridi asla üstüne binmesin.
    // 250 px: butonlar (~124) + alt nav payı (~92-118) + emniyet payı.
    final uiStackTop = _h - 250;
    final feetOffset = math.max(92 * baseScale, 74 * depthScale);
    final anchorY = math.min(sim.petY * _h, uiStackTop - feetOffset);

    // Oval yumuşak zemin gölgesi: arka plandan ayrıştırır (rehber §5).
    // Karakteri sahneye oturtmak için koyu ve geniş tutulur.
    final shadowRadiusX = 92 * depthScale * (1 - jumpSin * 0.4);
    final shadowRadiusY = 24 * depthScale * (1 - jumpSin * 0.4);
    _softShadowOval(
      anchorX - shadowRadiusX,
      anchorY + 48 * depthScale - shadowRadiusY,
      shadowRadiusX * 2,
      shadowRadiusY * 2,
      const Color(0x661E1B4B),
    );

    final facing = sim.smoothFacing >= 0 ? 1.0 : -1.0;
    final isDancing = sim.locomotionMode == PetActionState.dance;
    final strideBob = isMoving
        ? math.sin(sim.gaitPhase).abs() * (isRunning ? -16.0 : -9.0)
        : 0.0;
    final danceBob = isDancing ? math.sin(sim.timeSec * 10).abs() * -18.0 : 0.0;

    canvas.save();
    canvas.translate(anchorX, anchorY - jumpHeightPx + strideBob + danceBob);
    canvas.scale(baseScale * squashX * facing, baseScale * stretchY);

    _drawPetTailAndWings(
        isMoving: isMoving, isRunning: isRunning, jumpSin: jumpSin);
    _drawPetLimbsAndTorso(
        isMoving: isMoving, isRunning: isRunning, jumpSin: jumpSin);
    _drawPetHeadAndFace(isRunning: isRunning, jumpSin: jumpSin);

    canvas.restore();

    // 4) Işık tepkisi: gece sahnede pete soğuk mor tint.
    if (isNight) {
      final tintRect = Rect.fromCenter(
        center: Offset(anchorX, anchorY - 60 * depthScale),
        width: 340 * depthScale,
        height: 340 * depthScale,
      );
      canvas.drawOval(
        tintRect,
        Paint()..color = const Color(0xFF312E81).withValues(alpha: 0.10),
      );
    }

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

    // Kafa üstü balon: sahne uzayında, pet'in ölçeğine göre konumlanır.
    _drawSpeechBubble(anchorX, anchorY - jumpHeightPx + strideBob + danceBob,
        baseScale * stretchY);

    _drawParticles();
  }

  bool isRunningLocomotion(double dist) {
    return dist > 0.22 ||
        sim.locomotionMode == PetActionState.run ||
        sim.locomotionMode == PetActionState.playBall;
  }

  /// Lumi'nin kafasının üstünde beliren küçük konuşma balonu.
  /// Ekran uzayında çizilir (pet'in büyümesinden etkilenmez), pet ile
  /// birlikte hareket eder. [originY] çizim öncesi çevirmenin yapıldığı
  /// taban çizgisi, [scaleY] pet'in dikey ölçeğidir.
  void _drawSpeechBubble(double anchorX, double originY, double scaleY) {
    final alpha = clampDouble(sim.speechAlpha, 0, 1);
    if (alpha <= 0.01 || sim.speechText.isEmpty) return;

    const maxWidth = 190.0;
    final textPainter = TextPainter(
      text: TextSpan(
        text: sim.speechText,
        style: const TextStyle(
          fontFamily: 'Nunito',
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1E2E3D),
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 2,
      ellipsis: '…',
    )..layout(maxWidth: maxWidth);

    const padH = 12.0;
    const padV = 9.0;
    final bubbleW = textPainter.width + padH * 2;
    final bubbleH = textPainter.height + padV * 2;

    // Kulak uçları yerel ~-170 birimde biter; balon onun üstünde durur.
    final headTopY = originY - 195 * scaleY;
    var bubbleX = anchorX - bubbleW / 2;
    bubbleX = clampDouble(bubbleX, 12, _w - bubbleW - 12);
    final bubbleY = (headTopY - bubbleH - 14).clamp(8.0, _h - bubbleH - 8);

    final bubbleRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(bubbleX, bubbleY, bubbleW, bubbleH),
      const Radius.circular(15),
    );
    // Konuşma kuyruğu: kafaya bakan küçük üçgen.
    final tailTipX = (anchorX).clamp(bubbleX + 18, bubbleX + bubbleW - 18);
    final tailPath = Path()
      ..moveTo(tailTipX - 8, bubbleY + bubbleH - 1)
      ..lineTo(tailTipX + 8, bubbleY + bubbleH - 1)
      ..lineTo(tailTipX, bubbleY + bubbleH + 11)
      ..close();

    // Opak gövde (arka plan fotoğrafı okunmasın) + yumuşak gölge.
    final bubblePaint = Paint()..color = Colors.white.withValues(alpha: alpha);
    canvas.drawRRect(
      bubbleRect,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.18 * alpha)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    canvas.drawPath(tailPath, bubblePaint);
    canvas.drawRRect(bubbleRect, bubblePaint);
    canvas.drawRRect(
      bubbleRect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = const Color(0xFF7B5EA7).withValues(alpha: 0.45 * alpha),
    );

    textPainter.paint(
      canvas,
      Offset(bubbleX + padH, bubbleY + padV),
    );
  }

  void _drawParticles() {
    for (final p in sim.particles) {
      if (p.life <= 0) continue;
      final px = p.x * _w;
      final py = p.y * _h;
      final lifeAlpha = clampDouble(p.life, 0, 1);
      final color = p.color.withValues(alpha: lifeAlpha * 0.85);

      if (p.isShard) {
        // Temizlik: yarı saydam üçgen artefaktlar kaldırıldı (rehber §1.2).
        // Yerine yumuşak ışıltı noktası.
        canvas.drawCircle(Offset(px, py), 5.5 * lifeAlpha + 1.5, _fill(color));
        canvas.drawCircle(
          Offset(px - 1.5, py - 1.5),
          1.6,
          _fill(_white.withValues(alpha: lifeAlpha * 0.9)),
        );
      } else if (p.isHeart) {
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

  void _drawPetTailAndWings(
      {required bool isMoving,
      required bool isRunning,
      required double jumpSin}) {
    final tailSpeed = _isPetted || _isEating || _isDancing
        ? 9.0
        : isRunning
            ? 8.0
            : isMoving
                ? 5.0
                : _isSleeping
                    ? 1.2
                    : 2.0;

    // Follow-through: gövdeden gecikmeli kuyruk (rehber §6.5).
    // Uç segment bazdan ~0.35 sn geriden gelir.
    final baseSwing = math.sin(sim.timeSec * tailSpeed) *
        (_isPetted || _isDancing
            ? 22.0
            : _isSleeping
                ? 5.0
                : 14.0);
    final tipLag = math.sin(sim.timeSec * tailSpeed - 0.7) *
        (_isPetted || _isDancing ? 14.0 : 9.0);
    final gaitSway = isMoving ? math.sin(sim.gaitPhase) * 5.0 : 0.0;
    final jumpKick = jumpSin * 18.0;
    final tailSwing = baseSwing + gaitSway + jumpKick;
    // Kuyruk gövdeye içten bağlanır: pivot gövde sol kenarının içinde,
    // tabana bindirme dairesi çizilir, kopukluk kalmaz.
    final tailPivot = Offset(-44, _isSleeping ? 36.0 : 20.0);

    _rotate(_isSleeping ? -32 + tailSwing : 14 + tailSwing, tailPivot, () {
      canvas.drawCircle(tailPivot, 26, _fill(_tailDeep));
      // Kalın kıvrımlı kuyruk: gradient gövde + dalgalı beyaz uç (rehber §3, §5).
      // Hedef-tahtası halka daireler kaldırıldı.
      final tailPath = Path()
        ..moveTo(tailPivot.dx, tailPivot.dy)
        ..cubicTo(
          tailPivot.dx - 80,
          tailPivot.dy - 92,
          tailPivot.dx - 160,
          tailPivot.dy - 42 + tipLag * 0.5,
          tailPivot.dx - 132,
          tailPivot.dy + 44,
        )
        ..cubicTo(
          tailPivot.dx - 100,
          tailPivot.dy + 84,
          tailPivot.dx - 36,
          tailPivot.dy + 54,
          tailPivot.dx,
          tailPivot.dy + 16,
        )
        ..close();
      final tailRect = Rect.fromCircle(
        center: Offset(tailPivot.dx - 80, tailPivot.dy),
        radius: 110,
      );
      canvas.drawPath(
        tailPath,
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_tailPurple, _tailDeep, _earDeep],
            stops: [0.0, 0.6, 1.0],
          ).createShader(tailRect),
      );
      // Üst ışık: yumuşak hacim.
      _oval(
        _white.withValues(alpha: 0.22),
        tailPivot.dx - 118,
        tailPivot.dy - 48 + tipLag * 0.3,
        52,
        18,
      );
      // Dalgalı beyaz tüy kenarı (imza uç).
      final tipCenter = Offset(
        tailPivot.dx - 132,
        tailPivot.dy - 2 + tipLag * 0.4,
      );
      final tipPath = Path();
      const waves = 5;
      for (var i = 0; i <= waves; i++) {
        final t = i / waves;
        final ang = math.pi * (0.65 + t * 1.1);
        final r = 30 + (i.isEven ? 7.0 : -3.0);
        final px = tipCenter.dx + math.cos(ang) * r;
        final py = tipCenter.dy + math.sin(ang) * r * 0.85;
        if (i == 0) {
          tipPath.moveTo(px, py);
        } else {
          tipPath.lineTo(px, py);
        }
      }
      tipPath.close();
      canvas.drawPath(tipPath, _fill(_furWhite));
      canvas.drawCircle(tipCenter, 18, _fill(_white));
    });
  }

  // ── Limbs & torso ────────────────────────────────────────────────────────

  void _drawPetLimbsAndTorso({
    required bool isMoving,
    required bool isRunning,
    required double jumpSin,
  }) {
    // Nefes döngüsü 3.5 sn (rehber §6.2): 2π/3.5 ≈ 1.8 rad/sn.
    final breathWave = math.sin(sim.timeSec * (_isSleeping ? 1.4 : 1.8));

    final strideAmp = isRunning
        ? 32.0
        : isMoving
            ? 22.0
            : _isDancing
                ? 20.0
                : jumpSin > 0.1
                    ? 26.0
                    : 0.0;

    final gaitPhase = sim.gaitPhase;
    final flPhase = _isDancing ? sim.timeSec * 10 : gaitPhase;
    final brPhase = isRunning ? gaitPhase + math.pi * 0.85 : gaitPhase + 0.4;
    final frPhase = isRunning ? gaitPhase + 0.35 : gaitPhase + math.pi;
    final blPhase =
        isRunning ? gaitPhase + math.pi * 1.15 : gaitPhase + math.pi + 0.4;

    final activeStride = isMoving || _isDancing || jumpSin > 0.1;
    final frontLeftHip = activeStride ? math.sin(flPhase) * strideAmp : 0.0;
    final frontLeftKnee = activeStride
        ? math.max(0.0, math.cos(flPhase)) * (strideAmp * 0.75)
        : 0.0;
    final frontRightHip = activeStride ? math.sin(frPhase) * strideAmp : 0.0;
    final frontRightKnee = activeStride
        ? math.max(0.0, math.cos(frPhase)) * (strideAmp * 0.75)
        : 0.0;
    final backLeftHip = activeStride ? math.sin(blPhase) * strideAmp : 0.0;
    final backLeftKnee = activeStride
        ? math.max(0.0, -math.cos(blPhase)) * (strideAmp * 0.7)
        : 0.0;
    final backRightHip = activeStride ? math.sin(brPhase) * strideAmp : 0.0;
    final backRightKnee = activeStride
        ? math.max(0.0, -math.cos(brPhase)) * (strideAmp * 0.7)
        : 0.0;

    if (!_isSleeping) {
      _drawArticulatedLimb(
        hipX: -34,
        hipY: 38,
        hipAngleDeg: backRightHip,
        kneeAngleDeg: backRightKnee,
        upperColor: species.secondaryFurColor,
        lowerColor: const Color(0xFFDDD6FE),
        pawColor: const Color(0xFFF5F3FF),
        showPinkPad: true,
      );
      _drawArticulatedLimb(
        hipX: 32,
        hipY: 36,
        hipAngleDeg: frontRightHip,
        kneeAngleDeg: frontRightKnee,
        upperColor: species.secondaryFurColor,
        lowerColor: const Color(0xFFDDD6FE),
        pawColor: const Color(0xFFF5F3FF),
        showPinkPad: true,
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
      // Nefes: %2.5 scale, ~3.5 sn döngü (rehber §6.2). Eskiden %6.5 ve hızlıydı.
      final breathScale = 1 + breathWave * 0.025;
      // Armut gövde: altı geniş, üstü dar, kısa tombul (rehber §2).
      // Üç ton: ana beyaz, gölge #EDE7FF, vurgu mor (rehber §5).
      final bodyPath = Path()
        ..moveTo(-44 * breathScale, -16)
        ..quadraticBezierTo(-62 * breathScale, 8, -58 * breathScale, 38)
        ..quadraticBezierTo(-54 * breathScale, 62, 0, 62)
        ..quadraticBezierTo(54 * breathScale, 62, 58 * breathScale, 38)
        ..quadraticBezierTo(62 * breathScale, 8, 44 * breathScale, -16)
        ..quadraticBezierTo(0, -28, -44 * breathScale, -16)
        ..close();
      canvas.drawPath(bodyPath, _fill(_furWhite));
      // Alt gölge: beyaz üstüne beyaz öldürmesin diye #EDE7FF hilal.
      final bellyShadow = Path()
        ..moveTo(-48 * breathScale, 30)
        ..quadraticBezierTo(0, 58, 48 * breathScale, 30)
        ..quadraticBezierTo(0, 48, -48 * breathScale, 30)
        ..close();
      canvas.drawPath(bellyShadow, _fill(_softLavender));
      _oval(_white, -42, -10, 88 * breathScale, 60 * breathScale);
      _oval(
        _white.withValues(alpha: isNight ? 0.35 : 0.55),
        -32,
        -14,
        58 * breathScale,
        20,
      );

      // Göğüs kabartısı: iki yumuşak katman, sivri uç yok (rehber §1.3, §2).
      final ruffBack = Path()
        ..moveTo(4, -14)
        ..quadraticBezierTo(60, -12, 70, 14)
        ..quadraticBezierTo(52, 30, 40, 46)
        ..quadraticBezierTo(12, 42, -2, 20)
        ..close();
      canvas.drawPath(ruffBack, _fill(_softLavender));
      final ruffMid = Path()
        ..moveTo(10, -10)
        ..quadraticBezierTo(58, -6, 64, 16)
        ..quadraticBezierTo(48, 28, 38, 40)
        ..quadraticBezierTo(14, 36, 2, 18)
        ..close();
      canvas.drawPath(ruffMid, _fill(_furWhite));
      // Adım 1: göğüs 2. katman — ön kabartı (daha açık, daha öne).
      final ruffFront = Path()
        ..moveTo(16, -6)
        ..quadraticBezierTo(52, -2, 56, 16)
        ..quadraticBezierTo(44, 26, 36, 34)
        ..quadraticBezierTo(20, 30, 10, 16)
        ..close();
      canvas.drawPath(ruffFront, _fill(_white));
      _oval(
        _white.withValues(alpha: isNight ? 0.25 : 0.45),
        22,
        -4,
        28,
        12,
      );
      // Pati yanındaki beyaz üçgen artefaktlar temizlendi: sivri spike döngüsü silindi.

      if (flags.hasCozyScarf) {
        _roundRect(const Color(0xFFA78BFA), -8, -12, 66, 22, 11);
        _roundRect(const Color(0xFF8B5CF6), 28, 4, 20, 36, 8);
      }
      if (flags.hasRibbonBow) {
        canvas.drawCircle(
            const Offset(22, 2), 14, _fill(const Color(0xFFF43F5E)));
        canvas.drawCircle(
            const Offset(44, 2), 14, _fill(const Color(0xFFFB7185)));
        canvas.drawCircle(
            const Offset(33, 2), 8, _fill(const Color(0xFFFDA4AF)));
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
    const upperLen = 22.0;
    const lowerLen = 20.0;

    _rotate(hipAngleDeg, Offset(hipX, hipY), () {
      _roundRect(upperColor, hipX - 16, hipY - 6, 32, upperLen + 10, 15);
      // Fur shading on the thigh.
      _oval(
        _white.withValues(alpha: 0.35),
        hipX - 12,
        hipY - 2,
        24,
        14,
      );
      final kneeX = hipX;
      final kneeY = hipY + upperLen;
      _rotate(kneeAngleDeg, Offset(kneeX, kneeY), () {
        _roundRect(lowerColor, kneeX - 14, kneeY - 4, 28, lowerLen + 8, 13);
        final pawY = kneeY + lowerLen;
        // Tilki çorabı: koyu mor pati ucu (rehber §5). Renk dengesini sağlar.
        _oval(_pawSock, kneeX - 19, pawY - 7, 38, 22);
        _oval(pawColor, kneeX - 16, pawY - 7, 32, 15);
        // Tombul pati çizgisi: tek, ince, yumuşak.
        canvas.drawLine(
          Offset(kneeX - 1, pawY + 3),
          Offset(kneeX - 1, pawY + 10),
          _stroke(_furShadow, 2.0),
        );
        // Pati yastığı: pençenin alt-ortasında tek temiz oval.
        if (showPinkPad) {
          _oval(
            _blushDeep.withValues(alpha: 0.45),
            kneeX - 6,
            pawY + 2,
            12,
            8,
          );
        }
      });
    });
  }

  // ── Head & face ──────────────────────────────────────────────────────────

  void _drawPetHeadAndFace({required bool isRunning, required double jumpSin}) {
    final breathWave = math.sin(sim.timeSec * (_isSleeping ? 1.4 : 1.8));

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
      headPitch = breathWave * 2.0 + sim.lookOffsetY * 22;
    }

    final earSpeed = _isPetted || _isEating || _isDancing ? 9.0 : 2.4;
    final earAmp = _isPetted || _isDancing ? 12.0 : 6.0;
    final leftEarAngle =
        -16 + math.sin(sim.timeSec * earSpeed) * earAmp - (isRunning ? 10 : 0);
    final rightEarAngle = 16 -
        math.cos(sim.timeSec * earSpeed + 0.7) * earAmp +
        (isRunning ? 10 : 0);

    // Baş-gövde örtüşmesi artırıldı: ayrı sticker gibi durmasın (rehber §2).
    final headPivot = Offset(14, _isSleeping ? 4.0 : -18.0);

    _rotate(headPitch, headPivot, () {
      final hcX = headPivot.dx;
      final hcY = headPivot.dy - 42;
      // Kulaklar biraz küçültüldü, içi koyu mor (rehber §3).
      final earHeight = species == MascotSpecies.bunny ? 96.0 : 76.0;
      final earWidth = species == MascotSpecies.cat ? 50.0 : 56.0;

      _rotate(leftEarAngle, Offset(hcX - 32, hcY - 34), () {
        _drawSculptedEar(
          baseX: hcX - 32,
          baseY: hcY - 34,
          earWidth: earWidth,
          earHeight: earHeight,
          innerColor: _earInner,
          outerColor: _furWhite,
        );
      });
      _rotate(rightEarAngle, Offset(hcX + 32, hcY - 34), () {
        _drawSculptedEar(
          baseX: hcX + 32,
          baseY: hcY - 34,
          earWidth: earWidth,
          earHeight: earHeight,
          innerColor: _earInner,
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

      // Yanak çıkıntıları: yumuşak, 2 tutam (rehber §3). Keskin 4 spike silindi.
      final cheekPath = Path()
        ..moveTo(hcX - 54, hcY - 8)
        ..quadraticBezierTo(hcX - 92, hcY + 12, hcX - 72, hcY + 34)
        ..quadraticBezierTo(hcX - 84, hcY + 44, hcX - 52, hcY + 50)
        ..close()
        ..moveTo(hcX + 54, hcY - 8)
        ..quadraticBezierTo(hcX + 92, hcY + 12, hcX + 72, hcY + 34)
        ..quadraticBezierTo(hcX + 84, hcY + 44, hcX + 52, hcY + 50)
        ..close();
      canvas.drawPath(cheekPath, _fill(_white));
      // 2 küçük yuvarlak yanak tüyü (sivri üçgen değil).
      for (final sx in [-76.0, 76.0]) {
        _oval(_white, hcX + sx - 10, hcY + 26, 20, 16);
      }
      for (final sx in [-62.0, 62.0]) {
        _oval(_white, hcX + sx - 8, hcY + 34, 16, 13);
      }

      // Mochi kafa: tam daire değil, yanaklar hafif geniş (rehber §2).
      final headPath = Path()
        ..moveTo(hcX - 68, hcY - 48)
        ..quadraticBezierTo(hcX - 78, hcY + 10, hcX - 58, hcY + 48)
        ..quadraticBezierTo(hcX - 30, hcY + 68, hcX, hcY + 68)
        ..quadraticBezierTo(hcX + 30, hcY + 68, hcX + 58, hcY + 48)
        ..quadraticBezierTo(hcX + 78, hcY + 10, hcX + 68, hcY - 48)
        ..quadraticBezierTo(hcX, hcY - 72, hcX - 68, hcY - 48)
        ..close();
      canvas.drawPath(headPath, _fill(_white));
      // Kontur kaldırıldı (rehber §1.4): tüm karakterde outline yok.
      // Çene altı hilal gölge: hacim için #EDE7FF.
      _oval(
        _softLavender.withValues(alpha: 0.9),
        hcX - 28,
        hcY + 52,
        56,
        12,
      );

      // Alın işareti: küçük mor elmas (markalaşma, rehber §3).
      final gemY = hcY - 38;
      final gemPath = Path()
        ..moveTo(hcX + 2, gemY - 9)
        ..lineTo(hcX + 9, gemY)
        ..lineTo(hcX + 2, gemY + 9)
        ..lineTo(hcX - 5, gemY)
        ..close();
      canvas.drawPath(gemPath, _fill(const Color(0xFF8B5CF6)));
      canvas.drawCircle(
        Offset(hcX, gemY - 3),
        2.2,
        _fill(_white.withValues(alpha: 0.9)),
      );

      // Yanak allığı: yumuşak radial gradient (rehber §4).
      final blushAlpha = _isPetted ? 0.55 : 0.42;
      _softBlush(hcX - 46, hcY + 16, 34, blushAlpha);
      _softBlush(hcX + 48, hcY + 16, 34, blushAlpha);

      _drawPetEyesAndMouth(
          hcX: hcX, hcY: hcY, isRunning: isRunning, jumpSin: jumpSin);
      _drawPetHeadCosmetics(hcX: hcX, hcY: hcY);
    });
  }

  void _drawPetEyesAndMouth({
    required double hcX,
    required double hcY,
    required bool isRunning,
    required double jumpSin,
  }) {
    // Bebek şeması: gözler geniş aralıklı, yüzün alt yarısında (rehber §4).
    final leftEyeCenter = Offset(hcX - 30, hcY + 8);
    final rightEyeCenter = Offset(hcX + 34, hcY + 8);
    final isHappy =
        _isPetted || _isDancing || sim.locomotionMode == PetActionState.jump;
    final isSad = sim.locomotionMode == PetActionState.groom;

    if (_isSleeping) {
      _arc(_deepNose, leftEyeCenter.dx - 16, leftEyeCenter.dy - 8, 32, 20,
          startAngle: 15, sweepAngle: 150, useCenter: false, strokeWidth: 4.5);
      _arc(_deepNose, rightEyeCenter.dx - 16, rightEyeCenter.dy - 8, 32, 20,
          startAngle: 15, sweepAngle: 150, useCenter: false, strokeWidth: 4.5);
    } else if (isHappy) {
      // Mutlu: ^ ^ gözler (rehber §6.8).
      _arc(_deepNose, leftEyeCenter.dx - 16, leftEyeCenter.dy - 6, 32, 24,
          startAngle: 195, sweepAngle: 150, useCenter: false, strokeWidth: 5);
      _arc(_deepNose, rightEyeCenter.dx - 16, rightEyeCenter.dy - 6, 32, 24,
          startAngle: 195, sweepAngle: 150, useCenter: false, strokeWidth: 5);
    } else if (isSad) {
      // Üzgün: normal göz + damla yaş.
      final pupilShiftX = clampDouble(sim.lookOffsetX * 12, -5, 5);
      final pupilShiftY = clampDouble(sim.lookOffsetY * 12, -4, 4);
      _drawSingleExpressiveEye(leftEyeCenter, pupilShiftX, pupilShiftY);
      _drawSingleExpressiveEye(rightEyeCenter, pupilShiftX, pupilShiftY);
      _oval(
        const Color(0xFF7DD3FC).withValues(alpha: 0.9),
        rightEyeCenter.dx + 12,
        rightEyeCenter.dy + 14,
        10,
        14,
      );
      canvas.drawCircle(
        Offset(rightEyeCenter.dx + 17, rightEyeCenter.dy + 17),
        2.5,
        _fill(_white.withValues(alpha: 0.9)),
      );
    } else if (sim.isBlinking ||
        (_isEating && math.sin(sim.timeSec * 8) > 0.2)) {
      _arc(_deepNose, leftEyeCenter.dx - 16, leftEyeCenter.dy - 8, 32, 22,
          startAngle: 195, sweepAngle: 150, useCenter: false, strokeWidth: 5);
      _arc(_deepNose, rightEyeCenter.dx - 16, rightEyeCenter.dy - 8, 32, 22,
          startAngle: 195, sweepAngle: 150, useCenter: false, strokeWidth: 5);
    } else {
      final pupilShiftX = clampDouble(sim.lookOffsetX * 14, -6, 6);
      final pupilShiftY = clampDouble(sim.lookOffsetY * 14, -5, 5);
      _drawSingleExpressiveEye(leftEyeCenter, pupilShiftX, pupilShiftY);
      _drawSingleExpressiveEye(rightEyeCenter, pupilShiftX, pupilShiftY);
    }

    // Burun: küçük tek koyu nokta (rehber §4).
    final noseCenter = Offset(hcX + 2, hcY + 26);
    _oval(_deepNose, noseCenter.dx - 5, noseCenter.dy - 3.5, 10, 7);
    canvas.drawCircle(
      Offset(noseCenter.dx - 1.5, noseCenter.dy - 1.5),
      2.0,
      _fill(_white.withValues(alpha: 0.85)),
    );

    // Ağız: kapalı "w" (rehber §4). Okunmayan minik diş/dil kaldırıldı.
    // Sadece yemek yerken ve mutluyken belirgin açık gülümseme.
    if (_isEating) {
      final chew = math.sin(sim.timeSec * 11).abs();
      _oval(_deepNose, noseCenter.dx - 9, noseCenter.dy + 6, 18, 8 + chew * 8);
      _oval(const Color(0xFFFB7185), noseCenter.dx - 6, noseCenter.dy + 8, 12,
          5 + chew * 5);
    } else if (isHappy || isRunning || jumpSin > 0.2) {
      _oval(const Color(0xFF6D28D9), noseCenter.dx - 10, noseCenter.dy + 6, 20,
          12);
      _oval(
          const Color(0xFFFB7185), noseCenter.dx - 6, noseCenter.dy + 9, 12, 6);
      _oval(_white.withValues(alpha: 0.7), noseCenter.dx - 4, noseCenter.dy + 8,
          8, 3);
    } else if (isSad) {
      _arc(_deepNose, noseCenter.dx - 8, noseCenter.dy + 10, 16, 10,
          startAngle: 200, sweepAngle: 140, useCenter: false, strokeWidth: 3);
    } else {
      _arc(_deepNose, noseCenter.dx - 12, noseCenter.dy + 5, 11, 8,
          startAngle: 15, sweepAngle: 150, useCenter: false, strokeWidth: 3);
      _arc(_deepNose, noseCenter.dx + 1, noseCenter.dy + 5, 11, 8,
          startAngle: 15, sweepAngle: 150, useCenter: false, strokeWidth: 3);
    }
  }

  void _drawSingleExpressiveEye(
      Offset eyePos, double pupilShiftX, double pupilShiftY) {
    // Büyük dikey oval, iri pupil, 2 parlama (rehber §4). Sert eyeliner yumuşatıldı.
    _oval(_white, eyePos.dx - 20, eyePos.dy - 24, 40, 48);
    final irisCenter = Offset(eyePos.dx + pupilShiftX, eyePos.dy + pupilShiftY);
    final irisRect =
        Rect.fromLTWH(irisCenter.dx - 16, irisCenter.dy - 19, 32, 38);
    canvas.drawOval(
      irisRect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF4C1D95), Color(0xFF7C3AED), Color(0xFFA78BFA)],
          stops: [0.0, 0.55, 1.0],
        ).createShader(irisRect),
    );
    canvas.drawCircle(irisCenter, 10, _fill(_pupilInk));
    // Büyük + küçük parlama noktası.
    canvas.drawCircle(
      Offset(irisCenter.dx - 6, irisCenter.dy - 7),
      6.5,
      _fill(_white),
    );
    canvas.drawCircle(
      Offset(irisCenter.dx + 6, irisCenter.dy + 7),
      3.2,
      _fill(_white.withValues(alpha: 0.95)),
    );
    // Üst çizgi inceltildi: 6.5 -> 4.0 (rehber §4: koyu üst çizgi sertti).
    _arc(_eyeLid, eyePos.dx - 20, eyePos.dy - 25, 40, 30,
        startAngle: 190, sweepAngle: 160, useCenter: false, strokeWidth: 4.0);
  }

  void _drawSculptedEar({
    required double baseX,
    required double baseY,
    required double earWidth,
    required double earHeight,
    required Color innerColor,
    required Color outerColor,
  }) {
    // Temizlik: kulak çevresi ince mor anten çizgisi + dış spike'lar silindi (rehber §1.1).
    // Üçgen, hafif sivri, yuvarlak tabanlı kulak.
    final earOuterPath = Path()
      ..moveTo(baseX - earWidth * 0.5, baseY + 10)
      ..quadraticBezierTo(baseX - earWidth * 0.62, baseY - earHeight * 0.62,
          baseX, baseY - earHeight)
      ..quadraticBezierTo(baseX + earWidth * 0.62, baseY - earHeight * 0.62,
          baseX + earWidth * 0.5, baseY + 10)
      ..quadraticBezierTo(baseX, baseY + 18, baseX - earWidth * 0.5, baseY + 10)
      ..close();
    canvas.drawPath(earOuterPath, _fill(outerColor));

    // İç kulak: koyu mor (rehber §3).
    final earInnerPath = Path()
      ..moveTo(baseX - earWidth * 0.30, baseY + 6)
      ..quadraticBezierTo(baseX - earWidth * 0.38, baseY - earHeight * 0.55,
          baseX, baseY - earHeight * 0.80)
      ..quadraticBezierTo(baseX + earWidth * 0.38, baseY - earHeight * 0.55,
          baseX + earWidth * 0.30, baseY + 6)
      ..quadraticBezierTo(baseX, baseY + 10, baseX - earWidth * 0.30, baseY + 6)
      ..close();
    canvas.drawPath(earInnerPath, _fill(_earDeep));
    final earInnerLight = Path()
      ..moveTo(baseX - earWidth * 0.20, baseY + 2)
      ..quadraticBezierTo(baseX - earWidth * 0.26, baseY - earHeight * 0.48,
          baseX, baseY - earHeight * 0.68)
      ..quadraticBezierTo(baseX + earWidth * 0.26, baseY - earHeight * 0.48,
          baseX + earWidth * 0.20, baseY + 2)
      ..close();
    canvas.drawPath(earInnerLight, _fill(innerColor.withValues(alpha: 0.85)));
  }

  void _drawPetHeadCosmetics({required double hcX, required double hcY}) {
    if (flags.hasStarGlasses) {
      final leftEyeCenter = Offset(hcX - 26, hcY + 2);
      final rightEyeCenter = Offset(hcX + 30, hcY + 2);
      canvas.drawCircle(
          leftEyeCenter, 22, _stroke(const Color(0xFFA855F7), 4.5));
      canvas.drawCircle(
          rightEyeCenter, 22, _stroke(const Color(0xFFA855F7), 4.5));
      canvas.drawLine(
        Offset(leftEyeCenter.dx + 20, leftEyeCenter.dy),
        Offset(rightEyeCenter.dx - 20, rightEyeCenter.dy),
        _stroke(const Color(0xFFFBBF24), 4.5),
      );
    }

    if (flags.hasCrown) {
      // Mini gold crown with rounded teeth + pink gem (reference look).
      final crownBaseY = hcY - 58;
      final crownPath = Path()
        ..moveTo(hcX - 30, crownBaseY)
        ..lineTo(hcX - 34, crownBaseY - 30)
        ..quadraticBezierTo(
            hcX - 32, crownBaseY - 36, hcX - 26, crownBaseY - 30)
        ..lineTo(hcX - 12, crownBaseY - 16)
        ..lineTo(hcX - 4, crownBaseY - 42)
        ..quadraticBezierTo(hcX, crownBaseY - 50, hcX + 4, crownBaseY - 42)
        ..lineTo(hcX + 12, crownBaseY - 16)
        ..lineTo(hcX + 26, crownBaseY - 30)
        ..quadraticBezierTo(
            hcX + 32, crownBaseY - 36, hcX + 34, crownBaseY - 30)
        ..lineTo(hcX + 30, crownBaseY)
        ..close();
      final crownRect = Rect.fromLTWH(hcX - 34, crownBaseY - 50, 68, 50);
      canvas.drawPath(
        crownPath,
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFEF08A), Color(0xFFFBBF24), Color(0xFFB45309)],
            stops: [0.0, 0.55, 1.0],
          ).createShader(crownRect),
      );
      // Crown outline for definition.
      canvas.drawPath(crownPath, _stroke(_goldDark, 2.5));
      // Base band.
      _roundRect(_goldDark, hcX - 30, crownBaseY - 6, 60, 8, 4);
      // Pink gem.
      final gemCenter = Offset(hcX, crownBaseY - 20);
      final gemPath = Path()
        ..moveTo(gemCenter.dx, gemCenter.dy - 9)
        ..lineTo(gemCenter.dx + 7, gemCenter.dy)
        ..lineTo(gemCenter.dx, gemCenter.dy + 9)
        ..lineTo(gemCenter.dx - 7, gemCenter.dy)
        ..close();
      canvas.drawPath(gemPath, _fill(const Color(0xFFEC4899)));
      canvas.drawCircle(
        Offset(gemCenter.dx - 2, gemCenter.dy - 3),
        2.5,
        _fill(_white.withValues(alpha: 0.9)),
      );
      // Gold shine dots on teeth.
      canvas.drawCircle(
          Offset(hcX - 30, crownBaseY - 28), 2.5, _fill(_goldLight));
      canvas.drawCircle(Offset(hcX, crownBaseY - 40), 3, _fill(_goldLight));
      canvas.drawCircle(
          Offset(hcX + 30, crownBaseY - 28), 2.5, _fill(_goldLight));
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
      canvas.drawCircle(
          const Offset(-48, -18), 24, _fill(const Color(0xFFFBBF24)));
    });
  }

  void _drawStageFairyLantern(double cx, double cy, double timeSec) {
    // Sakin nabız: hızlı büyüyüp küçülme hissini önlemek için
    // genlik %35 -> %8, hız 4.0 -> 1.4 rad/sn.
    final glow = 0.92 + 0.08 * math.sin(timeSec * 1.4);
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
