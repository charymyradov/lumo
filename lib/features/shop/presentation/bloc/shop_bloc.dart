import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lumo/core/repositories/wallet_repository.dart';
import 'package:lumo/features/shop/presentation/bloc/shop_event.dart';
import 'package:lumo/features/shop/presentation/bloc/shop_state.dart';

/// Mağaza ekonomisi — tüm etkileşim Event ile.
class ShopBloc extends Bloc<ShopEvent, ShopState> {
  ShopBloc({required WalletRepository walletRepository})
      : _wallet = walletRepository,
        super(const ShopState()) {
    on<ShopLoadRequested>(_onLoad);
    on<ShopCategorySelected>(_onCategory);
    on<ShopBuyRequested>(_onBuy);
  }

  final WalletRepository _wallet;

  Future<void> _onLoad(ShopLoadRequested event, Emitter<ShopState> emit) async {
    emit(state.copyWith(loading: true));
    final coins = await _wallet.getCoins();
    final owned = await _wallet.ownedItems();
    emit(state.copyWith(coins: coins, owned: owned.toSet(), loading: false));
  }

  void _onCategory(ShopCategorySelected event, Emitter<ShopState> emit) =>
      emit(state.copyWith(categoryIndex: event.index));

  Future<void> _onBuy(ShopBuyRequested event, Emitter<ShopState> emit) async {
    if (state.owned.contains(event.id)) {
      emit(state.copyWith(
          message: '"${event.title}" already owned — equipped on Lumi! ✨'));
      return;
    }
    final ok = await _wallet.spendCoins(event.price);
    if (!ok) {
      emit(state.copyWith(
          message:
              'Not enough coins (${state.coins}) for "${event.title}". Complete quests to earn more! 🪙'));
      return;
    }
    await _wallet.markOwned(event.id);
    final coins = await _wallet.getCoins();
    final owned = await _wallet.ownedItems();
    emit(state.copyWith(
        coins: coins,
        owned: owned.toSet(),
        message: '"${event.title}" purchased! 🎉'));
  }
}
