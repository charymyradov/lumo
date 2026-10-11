import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:lumo/features/home/domain/entities/cosmetic_item.dart';
import 'package:lumo/features/home/domain/entities/mascot_species.dart';
import 'package:lumo/features/home/domain/entities/pet_action_state.dart';
import 'package:lumo/features/home/presentation/pet/pet_simulation.dart';
import 'package:lumo/features/home/presentation/pet/pet_stage_painter.dart';

/// Full screen, gesture driven pet stage.
///
/// Direct port of `LumoInteractivePetStage` from the Kotlin `LumoPetEngine.kt`.
///
/// * Tapping the pet "pets" it (hearts burst out of the pool).
/// * Tapping the ground makes the pet walk / run toward that spot.
/// * Double tapping the ground makes it run & jump excitedly.
/// * Dragging the pet makes it follow the finger and react.
///
/// The whole simulation is stepped from a single [Ticker], so nothing rebuilds
/// every frame: only the [CustomPaint] layer repaints.
class LumoInteractivePetStage extends StatefulWidget {
  const LumoInteractivePetStage({
    super.key,
    required this.species,
    required this.actionState,
    required this.equippedItems,
    required this.reduceMotion,
    required this.onPetTappedOrStroked,
    required this.onGroundTapped,
  });

  final MascotSpecies species;

  /// Latest care action requested from the outside world (bowl, ball, sleep…).
  final PetActionState actionState;

  /// Wardrobe + furniture used to decide which accessories are drawn.
  final List<CosmeticItem> equippedItems;

  /// When true the whole rig runs at 35% speed and stops self-wandering.
  final bool reduceMotion;

  /// Called when the pet itself (body/head) was tapped or stroked.
  final VoidCallback onPetTappedOrStroked;

  /// Called when a spot on the ground was tapped, with the resulting
  /// locomotion mode and a user facing status message.
  final void Function(PetActionState moveMode, String message) onGroundTapped;

  @override
  State<LumoInteractivePetStage> createState() => _LumoInteractivePetStageState();
}

class _LumoInteractivePetStageState extends State<LumoInteractivePetStage>
    with TickerProviderStateMixin {
  static const String debugTag = 'lumo_interactive_pet_stage';

  late final PetRigSimulationState _sim;
  late final EquippedFlags _flags;
  late final Ticker _ticker;

  /// Bumped once per tick so only the painter repaints (the widget tree stays
  /// untouched, mirroring the Kotlin `frameTickState` trick).
  final ValueNotifier<int> _repaint = ValueNotifier<int>(0);

  Duration _lastElapsed = Duration.zero;
  bool _hasLastElapsed = false;

  @override
  void initState() {
    super.initState();
    _sim = PetRigSimulationState();
    _flags = EquippedFlags()..updateFrom(widget.equippedItems);
    _applyExternalAction(widget.actionState);
    _ticker = createTicker(_onTick)..start();
  }

  @override
  void didUpdateWidget(covariant LumoInteractivePetStage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.actionState != widget.actionState) {
      _applyExternalAction(widget.actionState);
    }
    if (!identical(oldWidget.equippedItems, widget.equippedItems)) {
      _flags.updateFrom(widget.equippedItems);
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    _repaint.dispose();
    super.dispose();
  }

  // ── Simulation bootstrap ────────────────────────────────────────────────

  /// Port of the Kotlin `LaunchedEffect(actionState)` block.
  void _applyExternalAction(PetActionState actionState) {
    final sim = _sim;
    sim.locomotionMode = actionState;

    switch (actionState) {
      case PetActionState.eat || PetActionState.drink:
        sim.actionTimer = 4.2;
      case PetActionState.petted || PetActionState.groom:
        sim.actionTimer = 3.6;
      case PetActionState.jump || PetActionState.dance:
        sim.actionTimer = 2.4;
      case PetActionState.playBall:
        sim.showToyBall = true;
        sim.ballX = sim.petX < 0.5 ? 0.80 : 0.20;
        sim.ballY = 0.66;
        sim.ballVx = sim.petX < 0.5 ? -0.18 : 0.18;
        sim.ballVy = -0.25;
        sim.targetX = sim.ballX;
        sim.targetY = 0.69;
        sim.actionTimer = 5.5;
      case PetActionState.run:
        sim.targetX = sim.petX < 0.5 ? 0.82 : 0.18;
        sim.targetY = 0.66;
        sim.actionTimer = 3.5;
      case PetActionState.walk:
        sim.targetX = sim.petX < 0.5 ? 0.74 : 0.26;
        sim.targetY = 0.68;
        sim.actionTimer = 4.0;
      case PetActionState.idle || PetActionState.sleep:
        sim.actionTimer = 0;
    }

    if (actionState == PetActionState.jump) {
      sim.jumpPhase = 0.01;
    }
    if (actionState == PetActionState.eat || actionState == PetActionState.drink) {
      sim.targetX = clampDouble(sim.petX + 0.08 * sim.facingDir, 0.28, 0.72);
      sim.targetY = 0.70;
    }
  }

  void _onTick(Duration elapsed) {
    final double dt;
    if (!_hasLastElapsed) {
      dt = 0.016;
      _hasLastElapsed = true;
    } else {
      dt = clampDouble(
        (elapsed - _lastElapsed).inMicroseconds / 1000000,
        0.001,
        0.05,
      );
    }
    _lastElapsed = elapsed;

    stepPetSimulation(_sim, dt, reduceMotion: widget.reduceMotion);
    _repaint.value++;
  }

  // ── Gestures ────────────────────────────────────────────────────────────

  Size get _stageSize {
    final box = context.findRenderObject();
    return box is RenderBox && box.hasSize ? box.size : Size.zero;
  }

  void _handleDoubleTap(Offset position) {
    final size = _stageSize;
    if (size.isEmpty) return;

    final nx = clampDouble(position.dx / size.width, 0.15, 0.85);
    final ny = clampDouble(position.dy / size.height, 0.55, 0.76);
    _sim.targetX = nx;
    _sim.targetY = ny;
    _sim.tapRingX = nx;
    _sim.tapRingY = ny;
    _sim.tapRingAlpha = 1;
    _sim.locomotionMode = PetActionState.run;
    _sim.jumpPhase = 0.01;

    widget.onGroundTapped(
      PetActionState.run,
      'Çift dokundun! Lumi neşeyle koşup zıplıyor! 🏃‍♂️✨',
    );
  }

  void _handleTap(Offset position) {
    final size = _stageSize;
    if (size.isEmpty) return;

    final nx = position.dx / size.width;
    final ny = position.dy / size.height;
    final distToPet =
        (Offset(nx, ny) - Offset(_sim.petX, _sim.petY - 0.08)).distance;

    if (distToPet < 0.16) {
      _petThePet();
      return;
    }

    if (ny >= 0.44 && ny <= 0.82) {
      final clampedX = clampDouble(nx, 0.18, 0.82);
      final clampedY = clampDouble(ny, 0.58, 0.74);
      final runNeeded = (clampedX - _sim.petX).abs() > 0.25;
      _sim.targetX = clampedX;
      _sim.targetY = clampedY;
      _sim.tapRingX = clampedX;
      _sim.tapRingY = clampedY;
      _sim.tapRingAlpha = 1;
      _sim.lookOffsetX = clampDouble(clampedX - _sim.petX, -0.3, 0.3);
      _sim.locomotionMode = runNeeded ? PetActionState.run : PetActionState.walk;

      widget.onGroundTapped(
        _sim.locomotionMode,
        runNeeded
            ? 'Lumi işaretlediğin yere doğru koşuyor! 🐾💨'
            : 'Lumi yanına doğru yürüyor! 🌸',
      );
    }
  }

  /// Port of the Kotlin tap-on-pet branch (5 hearts + happy reaction).
  void _petThePet() {
    _sim.locomotionMode = PetActionState.petted;
    _sim.actionTimer = 3.2;
    _sim.jumpPhase = 0.01;
    for (var i = 0; i < 5; i++) {
      _sim.spawnParticle(
        x: _sim.petX + (_rng.nextDouble() - 0.5) * 0.14,
        y: _sim.petY - 0.12,
        vx: (_rng.nextDouble() - 0.5) * 0.12,
        vy: -0.14 - _rng.nextDouble() * 0.08,
        color: i.isEven ? const Color(0xFFF472B6) : const Color(0xFFA78BFA),
        isHeart: true,
      );
    }
    widget.onPetTappedOrStroked();
  }

  /// Port of the Kotlin `detectDragGestures` block: eyes follow the finger and
  /// stroking the pet makes it purr (hearts).
  void _handleDrag(Offset position) {
    final size = _stageSize;
    if (size.isEmpty) return;

    final nx = clampDouble(position.dx / size.width, 0.1, 0.9);
    final ny = clampDouble(position.dy / size.height, 0.2, 0.9);
    _sim.lookOffsetX = clampDouble(nx - _sim.petX, -0.35, 0.35);
    _sim.lookOffsetY = clampDouble(ny - (_sim.petY - 0.1), -0.35, 0.35);

    final distToPet =
        (Offset(nx, ny) - Offset(_sim.petX, _sim.petY - 0.08)).distance;
    if (distToPet < 0.18) {
      _sim.locomotionMode = PetActionState.petted;
      _sim.actionTimer = 2.5;
      if (_rng.nextDouble() < 0.25) {
        _sim.spawnParticle(
          x: nx,
          y: ny - 0.03,
          vx: (_rng.nextDouble() - 0.5) * 0.08,
          vy: -0.15,
          color: const Color(0xFFF472B6),
          isHeart: true,
        );
      }
    }
  }

  // ── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: const ValueKey<String>(debugTag),
      behavior: HitTestBehavior.opaque,
      onTapUp: (details) => _handleTap(details.localPosition),
      onDoubleTapDown: (details) => _handleDoubleTap(details.localPosition),
      onPanUpdate: (details) => _handleDrag(details.localPosition),
      child: CustomPaint(
        painter: PetStagePainter(
          sim: _sim,
          species: widget.species,
          flags: _flags,
          repaint: _repaint,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

final math.Random _rng = math.Random();
