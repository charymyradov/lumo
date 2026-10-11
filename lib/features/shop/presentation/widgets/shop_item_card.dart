import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lumo/core/constants/app_colors.dart';
import 'package:lumo/shared/widgets/glass_card.dart';

/// Mağaza ürün kartı — görsel + isim + coin fiyat.
class ShopItemCard extends StatelessWidget {
  final String title;
  final int price;
  final String emoji;
  final List<Color> artColors;
  final VoidCallback? onTap;

  const ShopItemCard({
    super.key,
    required this.title,
    required this.price,
    required this.emoji,
    required this.artColors,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      radius: 24,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 112,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: artColors,
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.7),
                width: 1,
              ),
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 56)),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.nunito(
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFFFFD45E), Color(0xFFF0A828)],
                  ),
                ),
                child: const Icon(Icons.check_rounded,
                    size: 13, color: Colors.white),
              ),
              const SizedBox(width: 6),
              Text(
                '$price',
                style: GoogleFonts.nunito(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
