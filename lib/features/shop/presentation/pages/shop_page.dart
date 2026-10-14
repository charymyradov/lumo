import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lumo/core/constants/app_text.dart';
import 'package:lumo/core/constants/app_colors.dart';
import 'package:lumo/core/constants/asset_paths.dart';
import 'package:lumo/core/di/injection.dart';
import 'package:lumo/core/services/haptic_service.dart';
import 'package:lumo/features/home/domain/entities/cosmetic_item.dart'
    show ShopCategory;
import 'package:lumo/features/shop/presentation/bloc/shop_bloc.dart';
import 'package:lumo/features/shop/presentation/bloc/shop_event.dart';
import 'package:lumo/features/shop/presentation/bloc/shop_state.dart';
import 'package:lumo/features/shop/presentation/widgets/category_selector.dart';
import 'package:lumo/features/shop/presentation/widgets/daily_deal_banner.dart';
import 'package:lumo/features/shop/presentation/widgets/premium_banner.dart';
import 'package:lumo/features/shop/presentation/widgets/shop_item_card.dart';

class _ShopItem {
  final String id;
  final String title;
  final int price;
  final String emoji;
  final List<Color> artColors;

  /// Domain enum kullanılır — int index değil. Sıra:
  /// ShopCategory.values[tabIndex] ile birebir eşleşir
  /// (outfit, accessory, furniture, background).
  final ShopCategory category;

  const _ShopItem({
    required this.id,
    required this.title,
    required this.price,
    required this.emoji,
    required this.artColors,
    required this.category,
  });
}

const _catalog = [
  _ShopItem(
    id: 'pink_cat',
    title: 'Pink Cat Costume',
    price: 180,
    emoji: '🐱',
    artColors: [Color(0xFFFFE3EE), Color(0xFFFFC9DE)],
    category: ShopCategory.outfit,
  ),
  _ShopItem(
    id: 'cloud_bed',
    title: 'Cloud Bed',
    price: 150,
    emoji: '☁️',
    artColors: [Color(0xFFE3F0FF), Color(0xFFC9E2FF)],
    category: ShopCategory.furniture,
  ),
  _ShopItem(
    id: 'star_crown',
    title: 'Star Crown',
    price: 220,
    emoji: '👑',
    artColors: [Color(0xFFFFF3C4), Color(0xFFFFD97A)],
    category: ShopCategory.accessory,
  ),
  _ShopItem(
    id: 'leaf_cape',
    title: 'Leaf Cape',
    price: 120,
    emoji: '🍃',
    artColors: [Color(0xFFDDF7E3), Color(0xFFA8E6B0)],
    category: ShopCategory.outfit,
  ),
];

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

class _ShopView extends StatelessWidget {
  const _ShopView();

  void _buy(BuildContext context, _ShopItem item) {
    HapticService.selection();
    context.read<ShopBloc>().add(ShopBuyRequested(
          id: item.id,
          title: item.title,
          price: item.price,
        ));
  }

  void _goPremium(BuildContext context) {
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

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ShopBloc, ShopState>(
      listenWhen: (p, c) => c.message != null && c.message != p.message,
      listener: (context, state) {
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
      },
      builder: (context, state) {
        final items =
            _catalog.where((e) => e.category == state.category).toList();
        return Stack(
          fit: StackFit.expand,
          children: [
            ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Image.asset(
                  AssetPaths.splash2Jpg,
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                ),
              ),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.0, 0.18, 0.45, 1.0],
                  colors: [
                    Color(0x40FFFFFF),
                    Color(0x66FFFFFF),
                    Color(0xB3FFFFFF),
                    Color(0xD9FFFFFF),
                  ],
                ),
              ),
            ),
            SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Shop',
                            style: AppText.nunito(
                              fontSize: 23,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 7),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('🪙', style: TextStyle(fontSize: 15)),
                              const SizedBox(width: 5),
                              Text(
                                '${state.coins}',
                                style: AppText.nunito(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    CategorySelector(
                      selectedIndex: state.categoryIndex,
                      onChanged: (i) =>
                          context.read<ShopBloc>().add(ShopCategorySelected(i)),
                    ),
                    const SizedBox(height: 16),
                    const DailyDealBanner(),
                    const SizedBox(height: 14),
                    if (items.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Center(
                          child: Text(
                            'Nothing in this category yet.',
                            style: AppText.nunito(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      )
                    else
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.78,
                        ),
                        itemCount: items.length,
                        itemBuilder: (context, i) {
                          final item = items[i];
                          final owned = state.owned.contains(item.id);
                          return Stack(
                            children: [
                              ShopItemCard(
                                title: item.title,
                                price: item.price,
                                emoji: item.emoji,
                                artColors: item.artColors,
                                onTap: () => _buy(context, item),
                              ),
                              if (owned)
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 9, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF22C55E),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      'OWNED',
                                      style: AppText.nunito(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    const SizedBox(height: 14),
                    PremiumBanner(onTap: () => _goPremium(context)),
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
