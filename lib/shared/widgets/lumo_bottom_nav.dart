import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:lumo/core/constants/app_colors.dart';
import 'package:lumo/core/constants/app_text.dart';
import 'package:lumo/core/constants/asset_paths.dart';

/// A single destination of [LumoBottomNav].
class LumoNavItem {
  final String label;
  final String asset;

  const LumoNavItem({required this.label, required this.asset});
}

const List<LumoNavItem> lumoNavItems = [
  LumoNavItem(label: 'Home', asset: AssetPaths.navHome),
  LumoNavItem(label: 'Tasks', asset: AssetPaths.navTasks),
  LumoNavItem(label: 'Journal', asset: AssetPaths.navJournal),
  LumoNavItem(label: 'Shop', asset: AssetPaths.navShop),
  LumoNavItem(label: 'Profile', asset: AssetPaths.navProfile),
];

/// Sade floating cam alt bar.
///
/// Abartılı parlama/gölge yok: hafif blur'lu yarı saydam beyaz zemin,
/// seçili öğenin arkasında düz, yumuşak bir hap. İkonlar
/// `assets/navbar/` içindeki PNG'lerdir.
class LumoBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const LumoBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(
          16, 0, 16, (bottomInset > 0 ? bottomInset : 10) + 6),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: RepaintBoundary(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(26),
                color: Colors.white.withValues(alpha: 0.55),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.6),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: SizedBox(
                height: 66,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final itemWidth = constraints.maxWidth / lumoNavItems.length;

                    return Stack(
                      children: [
                        // ── Seçili hap (tek animasyon: 200ms easeOut) ──
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeOut,
                          left: currentIndex * itemWidth + 6,
                          width: itemWidth - 12,
                          top: 7,
                          bottom: 7,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(19),
                              color: AppColors.primary.withValues(alpha: 0.14),
                            ),
                          ),
                        ),

                        // ── Öğeler (statik ikon + yazı, renk değişimi) ──
                        Row(
                          children: List.generate(lumoNavItems.length, (index) {
                            return _NavItem(
                              item: lumoNavItems[index],
                              selected: index == currentIndex,
                              onTap: () => onTap(index),
                            );
                          }),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Alt barın tek öğesi: splash'siz, animasyonsuz, const-friendly.
class _NavItem extends StatelessWidget {
  final LumoNavItem item;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fgColor = selected
        ? AppColors.primary
        : const Color(0xFF5D6470).withValues(alpha: 0.8);

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Image.asset(
              item.asset,
              width: 22,
              height: 22,
              color: fgColor,
              colorBlendMode: BlendMode.srcIn,
              gaplessPlayback: true,
              filterQuality: FilterQuality.low,
              cacheWidth: 44,
              excludeFromSemantics: true,
              errorBuilder: (_, __, ___) => Icon(
                Icons.circle,
                size: 22,
                color: fgColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              item.label,
              style: AppText.nunito(
                fontSize: 11.5,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                color: fgColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
