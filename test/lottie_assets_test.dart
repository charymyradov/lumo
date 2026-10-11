import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lottie/lottie.dart';
import 'package:lumo/core/constants/asset_paths.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const assets = [
    AssetPaths.lumoIdle,
    AssetPaths.lumoHappy,
    AssetPaths.lumoBreathing,
    AssetPaths.lumoSleep,
    AssetPaths.lumoTapReaction,
  ];

  for (final asset in assets) {
    test('parses $asset without throwing', () async {
      final data = await rootBundle.load(asset);
      final composition = await LottieComposition.fromByteData(data);
      expect(composition.duration, greaterThan(Duration.zero));
      expect(composition.bounds, isNotNull);
    });
  }
}
