import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lumo/core/services/haptic_service.dart';
import 'package:lumo/features/shop/presentation/bloc/shop_bloc.dart';
import 'package:lumo/features/shop/presentation/bloc/shop_event.dart';
import 'package:lumo/features/shop/presentation/bloc/shop_state.dart';
import 'package:lumo/features/shop/presentation/pages/shop_catalog.dart';

/// Satın alma + premium snackbar aksiyonları ve mesaj dinleyicisi.
mixin ShopActionsMixin<T extends StatelessWidget> on StatelessWidget {
  void buy(BuildContext context, ShopItem item) {
    HapticService.selection();
    context.read<ShopBloc>().add(ShopBuyRequested(
          id: item.id,
          title: item.title,
          price: item.price,
        ));
  }

  void goPremium(BuildContext context) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        const SnackBar(
          content: Text(
              'Premium is coming soon — shop items are free of ads forever. 💜'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  bool shopListenWhen(ShopState p, ShopState c) =>
      c.message != null && c.message != p.message;

  void onShopMessage(BuildContext context, ShopState state) {
    final msg = state.message;
    if (msg == null) return;
    if (msg.contains('purchased')) HapticService.success();
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(msg),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }
}
