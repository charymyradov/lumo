import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumo/features/home/domain/entities/cosmetic_item.dart';
import 'package:lumo/features/home/domain/entities/mascot_species.dart';
import 'package:lumo/features/home/domain/entities/pet_action_state.dart';
import 'package:lumo/features/home/presentation/pet/lumo_interactive_pet_stage.dart';

void main() {
  PetActionState? lastGroundMode;
  String? lastGroundMessage;
  var pettedCount = 0;

  Future<void> pumpStage(WidgetTester tester) async {
    lastGroundMode = null;
    lastGroundMessage = null;
    pettedCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
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
    await tester.pump(const Duration(milliseconds: 500));
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
