import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lumo/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const LumoApp());

    expect(find.byType(LumoApp), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(LumoApp), findsOneWidget);
  });

  testWidgets('app tickers pause in background and resume in foreground',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const MaterialApp(home: AppRoot()));
    await tester.pump();

    expect(tester.widget<TickerMode>(find.byType(TickerMode).last).enabled,
        isTrue);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();
    expect(tester.widget<TickerMode>(find.byType(TickerMode).last).enabled,
        isFalse);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(tester.widget<TickerMode>(find.byType(TickerMode).last).enabled,
        isTrue);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 4));
  });
}
