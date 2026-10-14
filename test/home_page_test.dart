import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumo/features/home/presentation/pages/home_page.dart';
import 'package:lumo/shared/widgets/glass_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Ana sahne (P0/P1) yüklemesi: Lumi'nin altında 4 net bakım butonu,
/// ince bakım şeridi, görev başlığı rozeti ve etiketli sağ kısayollar.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpHome(
    WidgetTester tester, {
    Map<String, Object> preferences = const {},
    bool tickerEnabled = true,
  }) async {
    SharedPreferences.setMockInitialValues(preferences);
    await tester.pumpWidget(
      MaterialApp(
        home: TickerMode(
          enabled: tickerEnabled,
          child: const HomePage(),
        ),
      ),
    );
    // Profil yüklemesi + ilk kare.
    await tester.pump(const Duration(milliseconds: 100));
  }

  /// Ağaç tamamen sökülsün ki timer'lar iptal edilsin.
  Future<void> disposeHome(WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
    await tester.pump(const Duration(seconds: 5));
  }

  testWidgets('sabit 4 bakım butonu ve ince bakım şeridi görünür',
      (tester) async {
    await pumpHome(tester);

    for (final label in ['Feed', 'Water', 'Play', 'Sleep']) {
      expect(find.text(label), findsOneWidget, reason: '$label butonu');
    }

    // İnce şerit: varsayılan kapalı, detay satırı gizli.
    expect(find.text('Lumi Care'), findsOneWidget);
    expect(find.textContaining('Hunger %'), findsNothing);

    // Eski 7'li emoji buton grubu ve sabit görev satırları kaldırıldı.
    expect(find.text('Top Oyna'), findsNothing);
    expect(find.text('Koştur'), findsNothing);
    expect(find.text('Walk 10,000 steps'), findsNothing);

    expect(tester.takeException(), isNull);
    await disposeHome(tester);
  });

  testWidgets('pet yalnızca Feed butonuna basılınca yemek yer', (tester) async {
    await pumpHome(tester, preferences: {
      'pet_hunger_v1': 0.95,
      'pet_water_v1': 0.78,
      'pet_happy_v1': 0.50,
      'pet_energy_v1': 0.88,
    });

    await tester.pump(const Duration(seconds: 5));
    expect(find.text(' %95'), findsOneWidget);

    await tester.tap(find.text('Feed'));
    await tester.pump();
    expect(find.text(' %77'), findsOneWidget);

    expect(tester.takeException(), isNull);
    await disposeHome(tester);
  });

  testWidgets('Home timers pause while its tab is hidden', (tester) async {
    await pumpHome(
      tester,
      tickerEnabled: false,
      preferences: {
        'pet_hunger_v1': 0.50,
        'pet_water_v1': 0.78,
        'pet_happy_v1': 0.50,
        'pet_energy_v1': 0.88,
      },
    );

    await tester.tap(find.text('Lumi Care'));
    await tester.pump(const Duration(seconds: 11));
    expect(find.text('Hunger %50'), findsOneWidget);

    await tester.pumpWidget(
      const MaterialApp(
        home: TickerMode(
          enabled: true,
          child: HomePage(),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(seconds: 11));
    expect(find.text('Hunger %54'), findsOneWidget);

    expect(tester.takeException(), isNull);
    await disposeHome(tester);
  });

  testWidgets('başlıkta görev rozeti yok, cam yalnızca bakım şeridinde',
      (tester) async {
    await pumpHome(tester);

    // Daily Quest paneli home'dan kaldırıldı.
    expect(find.text('Daily Quests'), findsNothing);
    expect(find.text('3/5'), findsNothing);

    // Cam kart: navigasyon (kendi widget'ı) + tek bakım şeridi.
    expect(find.byType(GlassCard), findsOneWidget);

    expect(tester.takeException(), isNull);
    await disposeHome(tester);
  });

  testWidgets('sağ kısayolları etiketli ve tekrarsız', (tester) async {
    await pumpHome(tester);

    expect(find.text('Calm'), findsOneWidget);
    expect(find.text('Notifications'), findsOneWidget);

    // Profil kopyası ve boş yenile butonu silindi, kutu+yıldız birleşti.
    expect(find.byIcon(Icons.person_outline_rounded), findsNothing);
    expect(find.byIcon(Icons.refresh_rounded), findsNothing);
    expect(find.byIcon(Icons.star_rounded), findsNothing);

    // Üst barda sabit "Level 5, 230 xp" yazısı yerine XP barı + rozet.
    expect(find.text('(Level 5, 230 xp)'), findsNothing);
    expect(find.text('230/300'), findsOneWidget);
    expect(find.textContaining('Lv. 5'), findsOneWidget);

    // Üstte tam genişlik sabit balon kaldırıldı (artık kafanın üstünde).
    expect(find.byIcon(Icons.pets), findsOneWidget); // yalnızca şeritte

    expect(tester.takeException(), isNull);
    await disposeHome(tester);
  });

  testWidgets('vital şeridine dokununca sayısal detay açılır', (tester) async {
    await pumpHome(tester);

    expect(find.textContaining('Hunger %'), findsNothing);
    await tester.tap(find.text('Lumi Care'));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.textContaining('Hunger %'), findsOneWidget);
    expect(find.textContaining('Energy %'), findsOneWidget);

    expect(tester.takeException(), isNull);
    await disposeHome(tester);
  });

  testWidgets('dar ekranda (360x640) taşma yok', (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await pumpHome(tester);

    for (final label in [
      'Feed',
      'Water',
      'Play',
      'Sleep',
      'Calm',
      'Notifications',
    ]) {
      expect(find.text(label), findsOneWidget, reason: '$label butonu');
    }
    expect(find.text('Lumi Care'), findsOneWidget);
    expect(find.text('Daily Quests'), findsNothing);
    expect(find.text('3/5'), findsNothing);

    expect(tester.takeException(), isNull);
    await disposeHome(tester);
  });
}
