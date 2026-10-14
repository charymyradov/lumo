import 'package:flutter_test/flutter_test.dart';
import 'package:lumo/core/repositories/progress_repositories.dart';
import 'package:lumo/core/repositories/user_profile_repository.dart';
import 'package:lumo/core/repositories/wallet_repository.dart';
import 'package:lumo/core/services/user_profile_store.dart';
import 'package:lumo/features/home/presentation/bloc/home_bloc.dart';
import 'package:lumo/features/home/presentation/bloc/home_event.dart';
import 'package:lumo/features/home/presentation/bloc/home_state.dart';
import 'package:lumo/features/journal/presentation/bloc/journal_bloc.dart';
import 'package:lumo/features/journal/presentation/bloc/journal_event.dart';
import 'package:lumo/features/journal/presentation/bloc/journal_state.dart';
import 'package:lumo/features/shop/presentation/bloc/shop_bloc.dart';
import 'package:lumo/features/shop/presentation/bloc/shop_event.dart';
import 'package:lumo/features/shop/presentation/bloc/shop_state.dart';

class _FakeWallet implements WalletRepository {
  int coins = 100;
  int xp = 0;
  int level = 5;
  final Set<String> _owned = {};
  @override
  Future<void> addCoins(int amount) async => coins += amount;
  @override
  Future<({int level, int xp})> addXp(int amount) async {
    xp += amount;
    return (level: level, xp: xp);
  }

  @override
  Future<int> getCoins() async => coins;
  @override
  Future<bool> isOwned(String id) async => _owned.contains(id);
  @override
  Future<void> markOwned(String id) async => _owned.add(id);
  @override
  Future<List<String>> ownedItems() async => _owned.toList();
  @override
  Future<({int coins, int xp, int level, int streak})> load() async =>
      (coins: coins, xp: xp, level: level, streak: 7);
  @override
  Future<bool> spendCoins(int amount) async {
    if (coins < amount) return false;
    coins -= amount;
    return true;
  }
}

class _FakeJournal implements JournalRepository {
  String text = '';
  @override
  Future<({int moodIndex, String text, List<String> tags})> load(
      DateTime day) async {
    return (moodIndex: 0, text: text, tags: const <String>[]);
  }

  @override
  Future<void> save(
      {required DateTime day,
      required int moodIndex,
      required String text,
      required List<String> tags}) async {
    this.text = text;
  }
}

class _FakeVitals implements PetVitalsRepository {
  @override
  Future<({double hunger, double water, double happy, double energy})>
      load() async => (hunger: 0.5, water: 0.5, happy: 0.5, energy: 0.5);
  @override
  Future<void> save(
      double hunger, double water, double happy, double energy) async {}
}

class _FakeProfile implements UserProfileRepository {
  @override
  Future<UserProfile> load() async => const UserProfile(name: 'Ada');
  @override
  Future<void> save(
      {required String name,
      required List<String> goals,
      required int mascotIndex}) async {}
}

Future<T> _waitFor<T>(Stream<T> stream, bool Function(T) test) {
  return stream.firstWhere(test);
}

void main() {
  group('resolvePetMood (saf fonksiyon)', () {
    test('sleepy when energy critical', () {
      expect(
          resolvePetMood(
              hunger: 0.5, hydration: 0.5, happiness: 0.5, energy: 0.05),
          PetMood.sleepy);
    });
    test('hungry when hunger high', () {
      expect(
          resolvePetMood(
              hunger: 0.9, hydration: 0.8, happiness: 0.8, energy: 0.8),
          PetMood.hungry);
    });
    test('playful when happy + energetic', () {
      expect(
          resolvePetMood(
              hunger: 0.3, hydration: 0.8, happiness: 0.9, energy: 0.8),
          PetMood.playful);
    });
  });

  group('ShopBloc (Event/State)', () {
    test('buy deducts and marks owned', () async {
      final w = _FakeWallet();
      final bloc = ShopBloc(walletRepository: w);
      bloc.add(const ShopLoadRequested());
      await _waitFor<ShopState>(bloc.stream, (s) => !s.loading);
      bloc.add(const ShopBuyRequested(id: 'a', title: 'A', price: 30));
      final done =
          await _waitFor<ShopState>(bloc.stream, (s) => s.message != null);
      expect(done.message!.contains('purchased'), true);
      expect(w.coins, 70);
      expect(bloc.state.owned.contains('a'), true);
      await bloc.close();
    });

    test('buy fails on insufficient coins', () async {
      final w = _FakeWallet()..coins = 5;
      final bloc = ShopBloc(walletRepository: w);
      bloc.add(const ShopLoadRequested());
      await _waitFor<ShopState>(bloc.stream, (s) => !s.loading);
      bloc.add(const ShopBuyRequested(id: 'b', title: 'B', price: 50));
      final done =
          await _waitFor<ShopState>(bloc.stream, (s) => s.message != null);
      expect(done.message!.contains('Not enough'), true);
      await bloc.close();
    });
  });

  group('JournalBloc (Event/State)', () {
    test('save rewards first time only', () async {
      final w = _FakeWallet();
      final bloc =
          JournalBloc(journalRepository: _FakeJournal(), walletRepository: w);
      bloc.add(JournalLoadRequested(DateTime(2026, 1, 1)));
      await _waitFor<JournalState>(bloc.stream, (s) => !s.loading);
      bloc.add(const JournalTextChanged('today I felt good and calm'));
      await _waitFor<JournalState>(bloc.stream, (s) => s.text.isNotEmpty);
      bloc.add(const JournalSaveRequested());
      final saved = await _waitFor<JournalState>(bloc.stream, (s) => s.saved);
      expect(saved.message!.contains('+10'), true);
      expect(w.coins, 110);
      await bloc.close();
    });
  });

  group('HomeBloc (Event/State)', () {
    test('load fills profile + vitals + wallet', () async {
      final bloc = HomeBloc(
        profileRepository: _FakeProfile(),
        vitalsRepository: _FakeVitals(),
        walletRepository: _FakeWallet(),
      );
      bloc.add(const HomeLoadRequested());
      final done = await _waitFor(bloc.stream, (s) => !s.loading);
      expect(done.userName, 'Ada');
      await bloc.close();
    });
  });
}
