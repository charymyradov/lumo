import 'package:shared_preferences/shared_preferences.dart';

/// Coin / XP / Level / Streak merkezi.
/// Tüm sayfalar buradan okur-yazar; yeniden başlatmada yaşar.
///
/// Repository katmanı ([WalletRepositoryImpl]) kalıcılığı buraya delege eder;
/// DI yokken (test/önizleme) doğrudan da kullanılır. [prefs] verilirse
/// enjekte edilen instance kullanılır, yoksa global singleton'a düşülür.
class WalletStore {
  WalletStore._();

  static const _kCoins = 'wallet_coins_v1';
  static const _kXp = 'wallet_xp_v1';
  static const _kLevel = 'wallet_level_v1';
  static const _kStreak = 'wallet_streak_v1';
  static const _kLastStreakDate = 'wallet_last_streak_date_v1';
  static const _kOwnedItems = 'wallet_owned_items_v1';

  static const int defaultCoins = 246;
  static const int defaultXp = 230;
  static const int defaultLevel = 5;
  static const int xpPerLevel = 300;

  static Future<SharedPreferences> _prefsOrGlobal(
      SharedPreferences? prefs) async {
    return prefs ?? await SharedPreferences.getInstance();
  }

  static Future<(int coins, int xp, int level, int streak)> load(
      [SharedPreferences? prefs]) async {
    final p = await _prefsOrGlobal(prefs);
    final coins = p.getInt(_kCoins) ?? defaultCoins;
    final xp = p.getInt(_kXp) ?? defaultXp;
    final level = p.getInt(_kLevel) ?? defaultLevel;
    var streak = p.getInt(_kStreak) ?? 7;
    // Günlük streak tazele: son açılış bugünden farklıysa +1 (max 99).
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final last = p.getString(_kLastStreakDate);
    if (last != today) {
      if (last != null) {
        streak = (streak + 1).clamp(1, 99);
      }
      await p.setInt(_kStreak, streak);
      await p.setString(_kLastStreakDate, today);
    }
    return (coins, xp, level, streak);
  }

  static Future<int> getCoins([SharedPreferences? prefs]) async {
    final p = await _prefsOrGlobal(prefs);
    return p.getInt(_kCoins) ?? defaultCoins;
  }

  static Future<bool> spendCoins(int amount, [SharedPreferences? prefs]) async {
    final p = await _prefsOrGlobal(prefs);
    final current = p.getInt(_kCoins) ?? defaultCoins;
    if (current < amount) return false;
    await p.setInt(_kCoins, current - amount);
    return true;
  }

  static Future<void> addCoins(int amount, [SharedPreferences? prefs]) async {
    final p = await _prefsOrGlobal(prefs);
    final current = p.getInt(_kCoins) ?? defaultCoins;
    await p.setInt(_kCoins, current + amount);
  }

  /// XP ekler, level atlama varsa coins bonusu verir. Yeni (level, xp) döner.
  static Future<(int level, int xp)> addXp(int amount,
      [SharedPreferences? prefs]) async {
    final p = await _prefsOrGlobal(prefs);
    var xp = (p.getInt(_kXp) ?? defaultXp) + amount;
    var level = p.getInt(_kLevel) ?? defaultLevel;
    while (xp >= xpPerLevel) {
      xp -= xpPerLevel;
      level += 1;
      final coins = p.getInt(_kCoins) ?? defaultCoins;
      await p.setInt(_kCoins, coins + 50);
    }
    await p.setInt(_kXp, xp);
    await p.setInt(_kLevel, level);
    return (level, xp);
  }

  static Future<List<String>> ownedItems([SharedPreferences? prefs]) async {
    final p = await _prefsOrGlobal(prefs);
    return p.getStringList(_kOwnedItems) ?? const [];
  }

  static Future<bool> isOwned(String id, [SharedPreferences? prefs]) async {
    final owned = await ownedItems(prefs);
    return owned.contains(id);
  }

  static Future<void> markOwned(String id, [SharedPreferences? prefs]) async {
    final p = await _prefsOrGlobal(prefs);
    final owned = p.getStringList(_kOwnedItems) ?? <String>[];
    if (!owned.contains(id)) {
      owned.add(id);
      await p.setStringList(_kOwnedItems, owned);
    }
  }

  static Future<void> resetForTests() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kCoins);
    await prefs.remove(_kXp);
    await prefs.remove(_kLevel);
    await prefs.remove(_kOwnedItems);
  }
}
