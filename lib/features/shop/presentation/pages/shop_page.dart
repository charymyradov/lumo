import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lumo/core/di/injection.dart';
import 'package:lumo/features/shop/presentation/bloc/shop_bloc.dart';
import 'package:lumo/features/shop/presentation/bloc/shop_event.dart';
import 'package:lumo/features/shop/presentation/bloc/shop_state.dart';
import 'package:lumo/features/shop/presentation/pages/shop_actions_mixin.dart';
import 'package:lumo/features/shop/presentation/pages/shop_catalog.dart';
import 'package:lumo/features/shop/presentation/pages/widgets/shop_background.dart';
import 'package:lumo/features/shop/presentation/pages/widgets/shop_grid_section.dart';
import 'package:lumo/features/shop/presentation/pages/widgets/shop_header.dart';
import 'package:lumo/features/shop/presentation/widgets/category_selector.dart';
import 'package:lumo/features/shop/presentation/widgets/daily_deal_banner.dart';
import 'package:lumo/features/shop/presentation/widgets/premium_banner.dart';

/// 5. Mağaza — başlık • kategoriler • günlük indirim • ürünler • premium.
/// Ekonomi ([ShopBloc]) UI'dan ayrık; Widget sadece Event gönderir,
/// sonuç snackbar ile dinlenir.
class ShopPage extends StatelessWidget {
  const ShopPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ShopBloc>()..add(const ShopLoadRequested()),
      child: const _ShopView(),
    );
  }
}

class _ShopView extends StatelessWidget with ShopActionsMixin {
  const _ShopView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ShopBloc, ShopState>(
      listenWhen: shopListenWhen,
      listener: onShopMessage,
      builder: (context, state) {
        final items =
            shopCatalog.where((e) => e.category == state.category).toList();
        return Stack(
          fit: StackFit.expand,
          children: [
            const ShopBackground(),
            SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    ShopHeader(coins: state.coins),
                    const SizedBox(height: 16),
                    CategorySelector(
                      selectedIndex: state.categoryIndex,
                      onChanged: (i) =>
                          context.read<ShopBloc>().add(ShopCategorySelected(i)),
                    ),
                    const SizedBox(height: 16),
                    const DailyDealBanner(),
                    const SizedBox(height: 14),
                    ShopGridSection(
                      items: items,
                      owned: state.owned,
                      onBuy: (item) => buy(context, item),
                    ),
                    const SizedBox(height: 14),
                    PremiumBanner(onTap: () => goPremium(context)),
                    const SizedBox(height: 110),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
