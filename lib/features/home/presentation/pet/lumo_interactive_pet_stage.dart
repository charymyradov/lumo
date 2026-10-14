import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:lumo/features/home/domain/entities/cosmetic_item.dart';
import 'package:lumo/features/home/domain/entities/mascot_species.dart';
import 'package:lumo/features/home/domain/entities/pet_action_state.dart';
import 'package:lumo/features/home/presentation/pet/pet_stage_controller.dart';
import 'package:lumo/features/home/presentation/pet/pet_stage_view.dart';

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
/// every frame: only the [CustomPaint] layer repaints. Tick, gesture and
/// action logic lives in [PetStageController]; this widget only owns the
/// ticker and forwards widget updates.
class LumoInteractivePetStage extends StatefulWidget {
  const LumoInteractivePetStage({
    super.key,
    required this.species,
    required this.actionState,
    required this.equippedItems,
    required this.reduceMotion,
    this.isNight = false,
    this.speechText = '',
    this.speechVisible = false,
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

  /// Night mode tint for the pet (4 - ışık tepkisi).
  final bool isNight;

  /// Konuşma balonu metni. Değişince sayaç sıfırlanır, balon ~3 sn görünür.
  final String speechText;

  /// Balonun görünmesine izin var mı (sahne her zaman çizer, sim karar verir).
  final bool speechVisible;

  /// Called when the pet itself (body/head) was tapped or stroked.
  final VoidCallback onPetTappedOrStroked;

  /// Called when a spot on the ground was tapped, with the resulting
  /// locomotion mode and a user facing status message.
  final void Function(PetActionState moveMode, String message) onGroundTapped;

  @override
  State<LumoInteractivePetStage> createState() =>
      _LumoInteractivePetStageState();
}

class _LumoInteractivePetStageState extends State<LumoInteractivePetStage>
    with TickerProviderStateMixin {
  late final PetStageController _controller;
  late final Ticker _ticker;

  Size get _stageSize {
    final box = context.findRenderObject();
    return box is RenderBox && box.hasSize ? box.size : Size.zero;
  }

  @override
  void initState() {
    super.initState();
    _controller = PetStageController(
      onPetTappedOrStroked: widget.onPetTappedOrStroked,
      onGroundTapped: widget.onGroundTapped,
    );
    _controller.syncEquipped(widget.equippedItems);
    _controller.applyExternalAction(widget.actionState);
    _ticker = createTicker(_onTick)..start();
  }

  @override
  void didUpdateWidget(covariant LumoInteractivePetStage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Yeniden kurulan parent callback'leri her zaman güncel tut.
    _controller.onPetTappedOrStroked = widget.onPetTappedOrStroked;
    _controller.onGroundTapped = widget.onGroundTapped;
    if (oldWidget.actionState != widget.actionState) {
      _controller.applyExternalAction(widget.actionState);
    }
    if (!identical(oldWidget.equippedItems, widget.equippedItems)) {
      _controller.syncEquipped(widget.equippedItems);
    }
    if (oldWidget.speechText != widget.speechText ||
        oldWidget.speechVisible != widget.speechVisible) {
      _controller.setSpeech(widget.speechText, widget.speechVisible);
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    _controller.handleTick(elapsed, reduceMotion: widget.reduceMotion);
  }

  @override
  Widget build(BuildContext context) {
    return PetStageView(
      sim: _controller.sim,
      species: widget.species,
      flags: _controller.flags,
      repaint: _controller.repaint,
      isNight: widget.isNight,
      onTapUp: (position) => _controller.handleTap(_stageSize, position),
      onDoubleTapDown: (position) =>
          _controller.handleDoubleTap(_stageSize, position),
      onPanUpdate: (position) => _controller.handleDrag(_stageSize, position),
    );
  }
}
