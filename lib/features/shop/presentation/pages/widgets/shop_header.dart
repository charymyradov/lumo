import 'package:flutter/material.dart';
import 'package:lumo/core/constants/app_colors.dart';
import 'package:lumo/core/constants/app_text.dart';

/// Başlık + coin rozeti.
class ShopHeader extends StatelessWidget {
  final int coins;

  const ShopHeader({super.key, required this.coins});

  @override
  Widget build(BuildContext context) {
    return Row(
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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
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
                '$coins',
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
    );
  }
}
