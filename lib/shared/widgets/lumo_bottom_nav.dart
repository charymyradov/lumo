import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lumo/core/constants/app_colors.dart';

/// A single destination of [LumoBottomNav].
class LumoNavItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;

  const LumoNavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });
}

const List<LumoNavItem> lumoNavItems = [
  LumoNavItem(
    label: 'Yaşam',
    icon: Icons.home_outlined,
    activeIcon: Icons.home_rounded,
  ),
  LumoNavItem(
    label: 'Görevler',
    icon: Icons.assignment_outlined,
    activeIcon: Icons.assignment_rounded,
  ),
  LumoNavItem(
    label: 'Günlük',
    icon: Icons.menu_book_outlined,
    activeIcon: Icons.menu_book_rounded,
  ),
  LumoNavItem(
    label: 'Mağaza',
    icon: Icons.storefront_outlined,
    activeIcon: Icons.storefront_rounded,
  ),
  LumoNavItem(
    label: 'Profil',
    icon: Icons.person_outline_rounded,
    activeIcon: Icons.person_rounded,
  ),
];

/// Frosted glass bottom navigation bar.
/// The bar itself is translucent so the page background bleeds through it.
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

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: Container(
          padding: EdgeInsets.only(
            top: 10,
            bottom: bottomInset > 0 ? bottomInset : 12,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.42),
            border: const Border(
              top: BorderSide(color: Colors.white, width: 1.2),
            ),
          ),
          child: Row(
            children: List.generate(lumoNavItems.length, (index) {
              final item = lumoNavItems[index];
              final selected = index == currentIndex;
              final color = selected
                  ? AppColors.primary
                  : const Color(0xFF5D6470).withValues(alpha: 0.85);

              return Expanded(
                child: InkWell(
                  onTap: () => onTap(index),
                  splashFactory: NoSplash.splashFactory,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        transitionBuilder: (child, animation) =>
                            ScaleTransition(scale: animation, child: child),
                        child: Icon(
                          selected ? item.activeIcon : item.icon,
                          key: ValueKey<bool>(selected),
                          size: 25,
                          color: color,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.label,
                        style: GoogleFonts.nunito(
                          fontSize: 11.5,
                          fontWeight:
                              selected ? FontWeight.w800 : FontWeight.w600,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
