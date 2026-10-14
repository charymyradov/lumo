import 'package:equatable/equatable.dart';
import 'package:lumo/features/home/domain/entities/cosmetic_item.dart'
    show ShopCategory;

class ShopState extends Equatable {
  final int categoryIndex;
  final int coins;
  final Set<String> owned;
  final bool loading;
  final String? message;

  const ShopState({
    this.categoryIndex = 0,
    this.coins = 0,
    this.owned = const {},
    this.loading = true,
    this.message,
  });

  ShopCategory get category => ShopCategory.values[categoryIndex.clamp(0, 3)];

  ShopState copyWith({
    int? categoryIndex,
    int? coins,
    Set<String>? owned,
    bool? loading,
    String? message,
  }) {
    return ShopState(
      categoryIndex: categoryIndex ?? this.categoryIndex,
      coins: coins ?? this.coins,
      owned: owned ?? this.owned,
      loading: loading ?? this.loading,
      message: message,
    );
  }

  @override
  List<Object?> get props => [categoryIndex, coins, owned, loading, message];
}
