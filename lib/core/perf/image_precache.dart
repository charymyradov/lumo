import 'package:flutter/widgets.dart';
import 'package:lumo/core/constants/asset_paths.dart';

/// Uygulama görsellerini ilk ihtiyaçtan önce ısıtır.
///
/// Full-screen JPG/PNG'ler decode maliyetini düşürmek için 1080px'e,
/// pet PNG'leri 512px'e, nav ikonları 44px'e küçültülmüş çözünürlükte
/// önbelleğe alınır. `Image.asset(cacheWidth:)` ile aynı [ResizeImage]
/// parametreleri kullanıldığı için sayfalardaki görseller önbellekten gelir.
///
/// Tekrar çağrılması güvenlidir (ikinci çağrı önbellek isabetidir);
/// tek bir asset bozulsa bile açılışı düşürmez.
Future<void> precacheAppImages(BuildContext context) async {
  const big = <String>[
    AssetPaths.dayMeadow,
    AssetPaths.nightMeadow,
    AssetPaths.splash1,
    AssetPaths.splashBg,
    AssetPaths.splash2Jpg,
    AssetPaths.nefesBg,
  ];
  const pets = <String>[
    AssetPaths.petFox,
    AssetPaths.petCat,
    AssetPaths.petDog,
    AssetPaths.petPanda,
    AssetPaths.petFossa,
  ];
  const navIcons = <String>[
    AssetPaths.navHome,
    AssetPaths.navTasks,
    AssetPaths.navJournal,
    AssetPaths.navShop,
    AssetPaths.navProfile,
  ];
  final futures = <Future<void>>[
    for (final p in big)
      _safePrecache(context, ResizeImage(AssetImage(p), width: 1080)),
    for (final p in pets)
      _safePrecache(context, ResizeImage(AssetImage(p), width: 512)),
    for (final p in navIcons)
      _safePrecache(context, ResizeImage(AssetImage(p), width: 44)),
  ];
  await Future.wait(futures);
}

/// Carousel'de görünen + komşu 2 pet görselini ısıtır (jank'sız kaydırma).
Future<void> precachePetNeighbors(
  BuildContext context,
  int selectedIndex,
) async {
  const pets = <String>[
    AssetPaths.petFox,
    AssetPaths.petCat,
    AssetPaths.petDog,
    AssetPaths.petPanda,
    AssetPaths.petFossa,
  ];
  final futures = <Future<void>>[];
  for (var i = selectedIndex - 2; i <= selectedIndex + 2; i++) {
    if (i < 0 || i >= pets.length) continue;
    futures.add(
      _safePrecache(
        context,
        ResizeImage(AssetImage(pets[i]), width: 512),
      ),
    );
  }
  await Future.wait(futures);
}

Future<void> _safePrecache(BuildContext context, ImageProvider provider) async {
  try {
    await precacheImage(provider, context);
  } catch (_) {
    // Tek eksik/bozuk asset açılışı engellemesin.
  }
}
