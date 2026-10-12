import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumo/features/splash/presentation/pages/splash_page.dart';

void main() {
  testWidgets('stops pending animation when disposed before logo starts',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: SplashPage(onFinished: () {})),
    );
    await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));

    await tester.pump(const Duration(milliseconds: 300));

    expect(tester.takeException(), isNull);
  });

  testWidgets('stops pending animation when disposed before text starts',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: SplashPage(onFinished: () {})),
    );
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));

    await tester.pump(const Duration(milliseconds: 700));

    expect(tester.takeException(), isNull);
  });
}
