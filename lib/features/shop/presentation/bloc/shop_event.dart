import 'package:equatable/equatable.dart';

abstract class ShopEvent extends Equatable {
  const ShopEvent();
  @override
  List<Object?> get props => [];
}

class ShopLoadRequested extends ShopEvent {
  const ShopLoadRequested();
}

class ShopCategorySelected extends ShopEvent {
  final int index;
  const ShopCategorySelected(this.index);
  @override
  List<Object?> get props => [index];
}

class ShopBuyRequested extends ShopEvent {
  final String id;
  final String title;
  final int price;
  const ShopBuyRequested(
      {required this.id, required this.title, required this.price});
  @override
  List<Object?> get props => [id, title, price];
}
