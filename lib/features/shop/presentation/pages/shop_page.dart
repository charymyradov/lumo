import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lumo/core/constants/app_colors.dart';
import 'package:lumo/core/constants/asset_paths.dart';
import 'package:lumo/features/shop/presentation/widgets/category_selector.dart';
import 'package:lumo/features/shop/presentation/widgets/daily_deal_banner.dart';
import 'package:lumo/features/shop/presentation/widgets/premium_banner.dart';
import 'package:lumo/features/shop/presentation/widgets/shop_item_card.dart';

/// 5. Mağaza — görseldeki gibi:
/// başlık • kategoriler • günlük indirim • 2 ürün • premium.
class ShopPage extends StatefulWidget {
  const ShopPage({super.key});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  int _category = 0;

  @override
  Widget build(BuildContext context) {
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
                Text(
                  'Mağaza',
                  style: GoogleFonts.nunito(
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                CategorySelector(
                  selectedIndex: _category,
                  onChanged: (i) => setState(() => _category = i),
                ),
                const SizedBox(height: 16),
                const DailyDealBanner(),
                const SizedBox(height: 14),
                const Row(
                  children: [
                    Expanded(
                      child: ShopItemCard(
                        title: 'Pembe Kedi Kostümü',
                        price: 180,
                        emoji: '🐱',
                        artColors: [
                          Color(0xFFFFE3EE),
                          Color(0xFFFFC9DE),
                        ],
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: ShopItemCard(
                        title: 'Bulut Yatağı',
                        price: 150,
                        emoji: '☁️',
                        artColors: [
                          Color(0xFFE3F0FF),
                          Color(0xFFC9E2FF),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const PremiumBanner(),
                const SizedBox(height: 110),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
