import 'package:flutter/material.dart';
import 'package:lumo/core/constants/app_colors.dart';
import 'package:lumo/core/constants/app_text.dart';
import 'package:lumo/features/shop/presentation/pages/shop_catalog.dart';
import 'package:lumo/features/shop/presentation/widgets/shop_item_card.dart';

/// Kategori ürün grid'i + OWNED rozeti + boş durum.
class ShopGridSection extends StatelessWidget {
  final List<ShopItem> items;
  final Set<String> owned;
  final void Function(ShopItem) onBuy;

  const ShopGridSection({
    super.key,
    required this.items,
    required this.owned,
    required this.onBuy,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Padding(
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
      );
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.78,
      ),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final item = items[i];
        return Stack(
          children: [
            ShopItemCard(
              title: item.title,
              price: item.price,
              emoji: item.emoji,
              artColors: item.artColors,
              onTap: () => onBuy(item),
            ),
            if (owned.contains(item.id))
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 4,
                  ),
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
    );
  }
}
