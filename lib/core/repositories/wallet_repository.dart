/// Cüzdan için soyut kontrat (DIP).
/// UI/Bloc somut [WalletStore]'a değil bu interface'e bağımlı olmalı.
abstract class WalletRepository {
  Future<({int coins, int xp, int level, int streak})> load();
  Future<int> getCoins();
  Future<bool> spendCoins(int amount);
  Future<void> addCoins(int amount);
  Future<({int level, int xp})> addXp(int amount);
  Future<List<String>> ownedItems();
  Future<bool> isOwned(String id);
  Future<void> markOwned(String id);
}
