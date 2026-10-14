import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumo/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:lumo/features/onboarding/presentation/bloc/onboarding_event.dart';
import 'package:lumo/features/onboarding/presentation/pages/onboarding_flow_page.dart';

void main() {
  testWidgets('keyboard dismisses outside the name field and on page change',
      (tester) async {
    await tester.pumpWidget(
      BlocProvider(
        create: (_) => OnboardingBloc(),
        child: const MaterialApp(home: OnboardingFlowPage()),
      ),
    );
    await tester.pump(const Duration(milliseconds: 200));

    final nameField = find.byType(TextField);
    await tester.tap(nameField);
    await tester.enterText(nameField, 'Lumi');
    await tester.pump();

    expect(
      tester.widget<EditableText>(find.byType(EditableText)).focusNode.hasFocus,
      isTrue,
    );

    await tester.tapAt(const Offset(12, 12));
    await tester.pump();

    expect(
      tester.widget<EditableText>(find.byType(EditableText)).focusNode.hasFocus,
      isFalse,
    );
    expect(tester.testTextInput.isVisible, isFalse);

    await tester.tap(nameField);
    await tester.pump();
    expect(
      tester.widget<EditableText>(find.byType(EditableText)).focusNode.hasFocus,
      isTrue,
    );

    tester
        .element(find.byType(OnboardingFlowPage))
        .read<OnboardingBloc>()
        .add(const OnboardingNextPage());
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsNothing);
    expect(tester.testTextInput.isVisible, isFalse);
    expect(find.text('What is your goal?'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
