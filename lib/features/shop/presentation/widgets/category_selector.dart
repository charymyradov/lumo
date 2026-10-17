import 'package:flutter/material.dart';
import 'package:lumo/core/constants/app_text.dart';
import 'package:lumo/core/constants/app_colors.dart';
import 'package:lumo/shared/widgets/lumo_tap.dart';

/// Presentation tab modeli — domain'deki `ShopCategory` enum'unu gölgelememesi
/// için `ShopCategoryTab` adını kullanır (önceki `ShopCategory` ismi
/// `features/home/domain/entities/cosmetic_item.dart` ile çakışıyordu).
class ShopCategoryTab {
  final String label;
  final IconData icon;

  const ShopCategoryTab({required this.label, required this.icon});
}

const List<ShopCategoryTab> shopCategories = [
  ShopCategoryTab(label: 'Outfits', icon: Icons.checkroom_rounded),
  ShopCategoryTab(label: 'Accessories', icon: Icons.watch_outlined),
  ShopCategoryTab(label: 'Furniture', icon: Icons.chair_alt_rounded),
  ShopCategoryTab(label: 'Background', icon: Icons.landscape_rounded),
];

/// Üstteki 4'lü kategori seçici — seçili olan mor dolgulu.
class CategorySelector extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const CategorySelector({
    super.key,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(shopCategories.length, (index) {
        final cat = shopCategories[index];
        final selected = index == selectedIndex;
        return Expanded(
          child: LumoTap(
            onTap: () => onChanged(index),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  width: 62,
                  height: 62,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: selected
                        ? const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF9B6FE0), Color(0xFF7B5EA7)],
                          )
                        : LinearGradient(
                            colors: [
                              Colors.white.withValues(alpha: 0.75),
                              Colors.white.withValues(alpha: 0.5),
                            ],
                          ),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.8),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: selected
                            ? const Color(0xFF7B5EA7).withValues(alpha: 0.35)
                            : Colors.black.withValues(alpha: 0.06),
                        blurRadius: selected ? 12 : 10,
                        spreadRadius: 0,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Icon(
                    cat.icon,
                    size: 28,
                    color: selected ? Colors.white : const Color(0xFF7B5EA7),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  cat.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.nunito(
                    fontSize: 12.5,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                    color: selected
                        ? AppColors.textPrimary
                        : AppColors.textPrimary.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
