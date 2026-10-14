import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumo/features/home/domain/entities/cosmetic_item.dart';
import 'package:lumo/features/home/domain/entities/mascot_species.dart';
import 'package:lumo/features/home/domain/entities/pet_action_state.dart';
import 'package:lumo/features/home/presentation/pet/lumo_interactive_pet_stage.dart';
import 'package:lumo/features/home/presentation/pet/pet_simulation.dart';
import 'package:lumo/features/home/presentation/pet/pet_stage_painter.dart';

void main() {
  PetActionState? lastGroundMode;
  String? lastGroundMessage;
  var pettedCount = 0;

  Widget stageWidget({bool tickerEnabled = true}) {
    lastGroundMode = null;
    lastGroundMessage = null;
    pettedCount = 0;

    return MaterialApp(
      home: TickerMode(
        enabled: tickerEnabled,
        child: Scaffold(
          body: SizedBox(
            width: 400,
            height: 600,
            child: LumoInteractivePetStage(
              species: MascotSpecies.fox,
              actionState: PetActionState.idle,
              equippedItems: defaultCosmeticItems,
              reduceMotion: false,
              onPetTappedOrStroked: () => pettedCount++,
              onGroundTapped: (mode, message) {
                lastGroundMode = mode;
                lastGroundMessage = message;
              },
            ),
          ),
        ),
      ),
    );
  }

  Future<void> pumpStage(WidgetTester tester) async {
    await tester.pumpWidget(stageWidget());
    await tester.pump(const Duration(milliseconds: 500));
  }

  PetRigSimulationState simulation(WidgetTester tester) {
    final customPaint = tester
        .widgetList<CustomPaint>(find.byType(CustomPaint))
        .firstWhere((paint) => paint.painter is PetStagePainter);
    return (customPaint.painter! as PetStagePainter).sim;
  }

  Future<void> pumpFrames(WidgetTester tester, int frames) async {
    for (var i = 0; i < frames; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  testWidgets('stage renders and runs its animation loop',
      (WidgetTester tester) async {
    await pumpStage(tester);

    expect(find.byKey(const ValueKey<String>('lumo_interactive_pet_stage')),
        findsOneWidget);

    // The rig breathes/blinks, so stepping time must not throw.
    await tester.pump(const Duration(milliseconds: 500));
    expect(tester.takeException(), isNull);
  });

  testWidgets('animation updates are capped near 45 frames per second',
      (tester) async {
    await tester.pumpWidget(stageWidget());
    await tester.pump(Duration.zero);
    final initialTime = simulation(tester).timeSec;

    await tester.pump(const Duration(milliseconds: 16));
    expect(simulation(tester).timeSec, initialTime);

    await tester.pump(const Duration(milliseconds: 8));
    expect(simulation(tester).timeSec, greaterThan(initialTime));
  });

  testWidgets('TickerMode pauses the stage until it becomes visible',
      (tester) async {
    await tester.pumpWidget(stageWidget(tickerEnabled: false));
    await tester.pump(const Duration(seconds: 1));
    expect(simulation(tester).timeSec, 0);

    await tester.pumpWidget(stageWidget());
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump(const Duration(milliseconds: 50));
    expect(simulation(tester).timeSec, greaterThan(0));
  });

  testWidgets('tapping the pet triggers the pet callback', (tester) async {
    await pumpStage(tester);

    // Pet starts at (0.5, 0.68); its head sits ~8% above the anchor.
    await tester.tapAt(const Offset(200, 360));
    await tester.pump(const Duration(milliseconds: 500));

    expect(pettedCount, 1);
  });

  testWidgets('tapping the ground makes the pet travel there', (tester) async {
    await pumpStage(tester);

    // Far right of the walkable band → must resolve into a locomotion mode.
    await tester.tapAt(const Offset(350, 430));
    await tester.pump(const Duration(milliseconds: 500));

    expect(lastGroundMode, isNotNull);
    expect(lastGroundMessage, isNotEmpty);
  });

  testWidgets('ground tap returns to the starting spot without playing ball',
      (tester) async {
    await pumpStage(tester);

    await tester.tapAt(const Offset(350, 430));
    await pumpFrames(tester, 30);

    expect(simulation(tester).petX, greaterThan(0.75));
    expect(simulation(tester).locomotionMode, isNot(PetActionState.playBall));

    await pumpFrames(tester, 90);
    expect(simulation(tester).targetX, closeTo(0.5, 0.001));
    expect(simulation(tester).locomotionMode, isNot(PetActionState.playBall));

    await pumpFrames(tester, 30);
    expect(simulation(tester).petX, closeTo(0.5, 0.02));
    expect(simulation(tester).locomotionMode, PetActionState.idle);
  });

  testWidgets('double tapping the ground makes the pet run & jump',
      (tester) async {
    await pumpStage(tester);

    await tester.tapAt(const Offset(350, 430));
    await tester.pump(const Duration(milliseconds: 30));
    await tester.tapAt(const Offset(350, 430));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));

    expect(lastGroundMode, PetActionState.run);
  });
}
