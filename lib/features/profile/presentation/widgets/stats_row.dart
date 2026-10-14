import 'package:flutter/material.dart';
import 'package:lumo/core/constants/app_text.dart';
import 'package:lumo/core/constants/app_colors.dart';
import 'package:lumo/shared/widgets/glass_card.dart';

/// Coin • Gün Serisi • Pet Bağı — tek cam kart içinde 3 sütun.
class StatsRow extends StatelessWidget {
  final int coins;
  final int streak;
  final int pets;

  const StatsRow({
    super.key,
    this.coins = 245,
    this.streak = 12,
    this.pets = 8,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      radius: 22,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
      child: Row(
        children: [
          _cell('🪙', '$coins', 'Coin'),
          _divider(),
          _cell('🔥', '$streak', 'Day Streak'),
          _divider(),
          _cell('💜', '$pets', 'Pet Bond'),
        ],
      ),
    );
  }

  Widget _cell(String emoji, String value, String label) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 5),
              Text(
                value,
                style: AppText.nunito(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: AppText.nunito(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(
      width: 1,
      height: 36,
      color: AppColors.textSecondary.withValues(alpha: 0.15),
    );
  }
}
