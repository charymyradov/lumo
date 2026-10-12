import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lumo/features/home/presentation/pet/lumo_interactive_pet_stage.dart';
import 'package:lumo/features/home/domain/entities/cosmetic_item.dart';
import 'package:lumo/features/home/domain/entities/mascot_species.dart';
import 'package:lumo/features/home/domain/entities/pet_action_state.dart';
import 'package:rive/rive.dart';

/// Rive geçiş kabuğu (rive 0.14 / ViewModel API).
///
/// `assets/rive/lumo.riv` tasarımcıdan gelene kadar otomatik olarak mevcut
/// vektör sahneye ([LumoInteractivePetStage]) düşer, uygulama kırılmaz.
/// Dosya eklendiğinde `useRive: true` yapman yeterli.
///
/// Beklenen Rive sözleşmesi (Rive editöründe):
/// * Artboard: `Lumo`, StateMachine: `PetMachine`
/// * Trigger'lar: `pet`, `eat`, `drink`, `jump`, `dance`, `sleep`, `wake`,
///   `walk`, `run`, `idle`
/// * Number: `lookX` (-35..35), `lookY` (-35..35) — göz takibi (rehber §6.4)
/// * Number: `breath` — nefes scale sürücüsü (opsiyonel)
class RivePetStage extends StatefulWidget {
  const RivePetStage({
    super.key,
    required this.species,
    required this.actionState,
    required this.equippedItems,
    required this.reduceMotion,
    required this.isNight,
    required this.onPetTappedOrStroked,
    required this.onGroundTapped,
    this.lookX = 0,
    this.lookY = 0,
  });

  static const String assetPath = 'assets/rive/lumo.riv';
  static const String artboardName = 'Lumo';
  static const String stateMachineName = 'PetMachine';

  final MascotSpecies species;
  final PetActionState actionState;
  final List<CosmeticItem> equippedItems;
  final bool reduceMotion;
  final bool isNight;
  final VoidCallback onPetTappedOrStroked;
  final void Function(PetActionState moveMode, String message) onGroundTapped;

  /// Göz takibi girdileri (rehber §6.4): -1..1 aralığında sürükleme konumu.
  final double lookX;
  final double lookY;

  @override
  State<RivePetStage> createState() => _RivePetStageState();
}

class _RivePetStageState extends State<RivePetStage> {
  bool _assetExists = false;
  bool _checked = false;
  RiveWidgetController? _riveController;
  PetActionState? _lastFired;

  @override
  void initState() {
    super.initState();
    _checkAsset();
  }

  Future<void> _checkAsset() async {
    try {
      await rootBundle.load(RivePetStage.assetPath);
      if (mounted) setState(() => _assetExists = true);
    } catch (_) {
      // .riv henüz yok — fallback sahne kullanılacak.
    } finally {
      if (mounted) setState(() => _checked = true);
    }
  }

  static String _triggerFor(PetActionState action) {
    return switch (action) {
      PetActionState.petted => 'pet',
      PetActionState.eat => 'eat',
      PetActionState.drink => 'drink',
      PetActionState.jump => 'jump',
      PetActionState.dance => 'dance',
      PetActionState.sleep => 'sleep',
      PetActionState.walk => 'walk',
      PetActionState.run || PetActionState.playBall => 'run',
      PetActionState.groom => 'pet',
      PetActionState.idle => 'idle',
    };
  }

  void _fireFor(PetActionState action) {
    final sm = _riveController?.stateMachine;
    if (sm == null) return;
    try {
      // ignore: deprecated_member_use
      sm.trigger(_triggerFor(action))?.fire();
    } catch (_) {}
    _lastFired = action;
    _applyLook();
  }

  void _applyLook() {
    final sm = _riveController?.stateMachine;
    if (sm == null) return;
    try {
      // ignore: deprecated_member_use
      final lx = sm.number('lookX');
      if (lx != null) lx.value = (widget.lookX * 35).clamp(-35, 35);
      // ignore: deprecated_member_use
      final ly = sm.number('lookY');
      if (ly != null) ly.value = (widget.lookY * 35).clamp(-35, 35);
    } catch (_) {}
  }

  RiveWidgetController _buildController(File file) {
    final controller = RiveWidgetController(
      file,
      artboardSelector: const ArtboardNamed(RivePetStage.artboardName),
      stateMachineSelector:
          const StateMachineNamed(RivePetStage.stateMachineName),
    );
    _riveController = controller;
    // İlk karede mevcut aksiyonu ateşle.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _fireFor(widget.actionState);
    });
    return controller;
  }

  @override
  void didUpdateWidget(covariant RivePetStage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.actionState != widget.actionState) {
      _fireFor(widget.actionState);
    }
    if (oldWidget.lookX != widget.lookX || oldWidget.lookY != widget.lookY) {
      _applyLook();
    }
  }

  @override
  void dispose() {
    _riveController?.dispose();
    _riveController = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_checked) return const SizedBox.expand();
    if (!_assetExists) return _fallback();

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onPetTappedOrStroked,
      onDoubleTap: () => widget.onGroundTapped(
        PetActionState.run,
        'Çift dokundun! Lumi neşeyle koşup zıplıyor! 🏃‍♂️✨',
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          RepaintBoundary(
            child: RiveWidgetBuilder(
              fileLoader: FileLoader.fromAsset(
                RivePetStage.assetPath,
                riveFactory: Factory.rive,
              ),
              artboardSelector:
                  const ArtboardNamed(RivePetStage.artboardName),
              stateMachineSelector:
                  const StateMachineNamed(RivePetStage.stateMachineName),
              controller: _buildController,
              builder: (context, state) => switch (state) {
                RiveLoading() => const SizedBox.expand(),
                RiveFailed() => _fallback(),
                RiveLoaded(:final controller) => RiveWidget(
                    controller: controller,
                    fit: Fit.contain,
                  ),
              },
            ),
          ),
          if (widget.isNight)
            Container(color: const Color(0xFF312E81).withValues(alpha: 0.08)),
        ],
      ),
    );
  }

  Widget _fallback() {
    // Rive yüklenirken/sonrasında aksiyon değişirse fallback da güncel kalır.
    if (_lastFired != widget.actionState) {
      _lastFired = widget.actionState;
    }
    return LumoInteractivePetStage(
      species: widget.species,
      actionState: widget.actionState,
      equippedItems: widget.equippedItems,
      reduceMotion: widget.reduceMotion,
      isNight: widget.isNight,
      onPetTappedOrStroked: widget.onPetTappedOrStroked,
      onGroundTapped: widget.onGroundTapped,
    );
  }
}
