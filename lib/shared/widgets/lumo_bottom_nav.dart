import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:lumo/core/constants/app_colors.dart';
import 'package:lumo/core/constants/app_text.dart';

/// A single destination of [LumoBottomNav].
class LumoNavItem {
  final String label;
  final String asset;

  const LumoNavItem({required this.label, required this.asset});
}

const List<LumoNavItem> lumoNavItems = [
  LumoNavItem(label: 'Yaşam', asset: 'assets/navbar/home.png'),
  LumoNavItem(label: 'Görevler', asset: 'assets/navbar/checklist.png'),
  LumoNavItem(label: 'Günlük', asset: 'assets/navbar/journal.png'),
  LumoNavItem(label: 'Mağaza', asset: 'assets/navbar/shopping-cart.png'),
  LumoNavItem(label: 'Profil', asset: 'assets/navbar/user.png'),
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
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
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
                  final itemWidth =
                      constraints.maxWidth / lumoNavItems.length;

                  return Stack(
                    children: [
                      // ── Seçili hap (sade, düz renk) ──
                      AnimatedPositioned(
                        duration:
                            const Duration(milliseconds: 350),
                        curve: Curves.easeInOutCubic,
                        left: currentIndex * itemWidth + 6,
                        width: itemWidth - 12,
                        top: 7,
                        bottom: 7,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(19),
                            color: AppColors.primary
                                .withValues(alpha: 0.14),
                          ),
                        ),
                      ),

                      // ── Öğeler ──
                      Row(
                        children: List.generate(
                            lumoNavItems.length, (index) {
                          final item = lumoNavItems[index];
                          final selected =
                              index == currentIndex;
                          final fgColor = selected
                              ? AppColors.primary
                              : const Color(0xFF5D6470)
                                  .withValues(alpha: 0.8);

                          return Expanded(
                            child: InkWell(
                              onTap: () => onTap(index),
                              splashFactory:
                                  NoSplash.splashFactory,
                              highlightColor:
                                  Colors.transparent,
                              borderRadius:
                                  BorderRadius.circular(19),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                mainAxisSize:
                                    MainAxisSize.max,
                                children: [
                                  AnimatedScale(
                                    scale:
                                        selected ? 1.1 : 1.0,
                                    duration: const Duration(
                                        milliseconds: 300),
                                    curve: Curves.easeInOutCubic,
                                    child: Image.asset(
                                      item.asset,
                                      width: 22,
                                      height: 22,
                                      color: fgColor,
                                      colorBlendMode:
                                          BlendMode.srcIn,
                                      errorBuilder: (_,
                                              __, ___) =>
                                          Icon(
                                        Icons.circle,
                                        size: 22,
                                        color: fgColor,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  AnimatedDefaultTextStyle(
                                    duration: const Duration(
                                        milliseconds: 300),
                                    curve: Curves.easeInOut,
                                    style: AppText.nunito(
                                      fontSize: 11.5,
                                      fontWeight: selected
                                          ? FontWeight.w800
                                          : FontWeight.w600,
                                      color: fgColor,
                                    ),
                                    child: Text(item.label),
                                  ),
                                ],
                              ),
                            ),
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
    );
  }
}
