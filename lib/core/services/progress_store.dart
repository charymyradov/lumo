import 'package:shared_preferences/shared_preferences.dart';

/// Günlük kayıtları + görev tamamlama kalıcılığı.
///
/// Repository implementasyonları kalıcılığı buraya delege eder; DI yokken
/// (test/önizleme) doğrudan da kullanılır. [prefs] verilirse enjekte edilen
/// instance kullanılır, yoksa global singleton'a düşülür.
class JournalStore {
  JournalStore._();

  static String _keyFor(DateTime day) =>
      'journal_${day.year}_${day.month}_${day.day}_v1';

  static Future<SharedPreferences> _prefsOrGlobal(
      SharedPreferences? prefs) async {
    return prefs ?? await SharedPreferences.getInstance();
  }

  static Future<void> save({
    required DateTime day,
    required int moodIndex,
    required String text,
    required List<String> tags,
    SharedPreferences? prefs,
  }) async {
    final p = await _prefsOrGlobal(prefs);
    await p.setInt('${_keyFor(day)}_mood', moodIndex);
    await p.setString('${_keyFor(day)}_text', text);
    await p.setStringList('${_keyFor(day)}_tags', tags);
  }

  static Future<({int moodIndex, String text, List<String> tags})> load(
      DateTime day,
      [SharedPreferences? prefs]) async {
    final p = await _prefsOrGlobal(prefs);
    return (
      moodIndex: p.getInt('${_keyFor(day)}_mood') ?? 0,
      text: p.getString('${_keyFor(day)}_text') ?? '',
      tags: p.getStringList('${_keyFor(day)}_tags') ?? const [],
    );
  }
}

/// Görev tamamlama: gün bazlı saklanır, coin/XP ödülü WalletStore üzerinden.
class TaskCompletionStore {
  TaskCompletionStore._();

  static String _keyFor(DateTime day) =>
      'tasks_done_${day.year}_${day.month}_${day.day}_v1';

  static Future<Set<String>> load(DateTime day,
      [SharedPreferences? prefs]) async {
    final p = prefs ?? await SharedPreferences.getInstance();
    return (p.getStringList(_keyFor(day)) ?? const []).toSet();
  }

  static Future<void> save(DateTime day, Set<String> ids,
      [SharedPreferences? prefs]) async {
    final p = prefs ?? await SharedPreferences.getInstance();
    await p.setStringList(_keyFor(day), ids.toList());
  }
}

/// Pet vitals kalıcılığı (açlık/su/mutluluk/enerji 0..1).
class PetVitalsStore {
  PetVitalsStore._();

  static const _kHunger = 'pet_hunger_v1';
  static const _kWater = 'pet_water_v1';
  static const _kHappy = 'pet_happy_v1';
  static const _kEnergy = 'pet_energy_v1';

  static const double defaultHunger = 0.84;
  static const double defaultWater = 0.78;
  static const double defaultHappy = 0.92;
  static const double defaultEnergy = 0.88;

  static Future<(double, double, double, double)> load(
      [SharedPreferences? prefs]) async {
    final p = prefs ?? await SharedPreferences.getInstance();
    return (
      p.getDouble(_kHunger) ?? defaultHunger,
      p.getDouble(_kWater) ?? defaultWater,
      p.getDouble(_kHappy) ?? defaultHappy,
      p.getDouble(_kEnergy) ?? defaultEnergy,
    );
  }

  static Future<void> save(
      double hunger, double water, double happy, double energy,
      [SharedPreferences? prefs]) async {
    final p = prefs ?? await SharedPreferences.getInstance();
    await p.setDouble(_kHunger, hunger);
    await p.setDouble(_kWater, water);
    await p.setDouble(_kHappy, happy);
    await p.setDouble(_kEnergy, energy);
  }
}
