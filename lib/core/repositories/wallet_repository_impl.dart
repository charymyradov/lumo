import 'package:shared_preferences/shared_preferences.dart';
import 'package:lumo/core/repositories/wallet_repository.dart';
import 'package:lumo/core/services/wallet_store.dart';

/// [WalletRepository]'nin SharedPreferences implementasyonu.
/// Kalıcılık mantığının tek sahibi [WalletStore]'dur — burası DI dostu
/// ince bir cephedir (enjekte edilen [_prefs] Store'a aktarılır).
class WalletRepositoryImpl implements WalletRepository {
  final SharedPreferences _prefs;
  WalletRepositoryImpl({required SharedPreferences prefs}) : _prefs = prefs;

  static const int defaultCoins = WalletStore.defaultCoins;
  static const int defaultXp = WalletStore.defaultXp;
  static const int defaultLevel = WalletStore.defaultLevel;
  static const int xpPerLevel = WalletStore.xpPerLevel;

  @override
  Future<({int coins, int xp, int level, int streak})> load() async {
    final r = await WalletStore.load(_prefs);
    return (coins: r.$1, xp: r.$2, level: r.$3, streak: r.$4);
  }

  @override
  Future<int> getCoins() => WalletStore.getCoins(_prefs);

  @override
  Future<bool> spendCoins(int amount) => WalletStore.spendCoins(amount, _prefs);

  @override
  Future<void> addCoins(int amount) => WalletStore.addCoins(amount, _prefs);

  @override
  Future<({int level, int xp})> addXp(int amount) async {
    final r = await WalletStore.addXp(amount, _prefs);
    return (level: r.$1, xp: r.$2);
  }

  @override
  Future<List<String>> ownedItems() => WalletStore.ownedItems(_prefs);

  @override
  Future<bool> isOwned(String id) => WalletStore.isOwned(id, _prefs);

  @override
  Future<void> markOwned(String id) => WalletStore.markOwned(id, _prefs);
}
