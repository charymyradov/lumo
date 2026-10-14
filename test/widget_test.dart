import 'package:flutter_test/flutter_test.dart';

import 'package:lumo/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const LumoApp());

    expect(find.byType(LumoApp), findsOneWidget);

    // Splash animasyonundaki gecikmeli adımların tamamlanmasına izin ver
    // ki test sonunda sarkan Timer kalmasın.
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(LumoApp), findsOneWidget);
  });
}
