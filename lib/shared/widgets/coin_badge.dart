import 'package:flutter/material.dart';
import 'package:lumo/core/constants/app_text.dart';

/// Small golden coin with a check mark, used next to task rewards.
class CoinBadge extends StatelessWidget {
  final double size;

  const CoinBadge({super.key, this.size = 18});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFD45E), Color(0xFFF0A828)],
        ),
        border:
            Border.all(color: Colors.white.withValues(alpha: 0.8), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF0A828).withValues(alpha: 0.4),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(Icons.check_rounded, size: size * 0.7, color: Colors.white),
    );
  }
}

/// Coin display for the top bar – shows a golden circle with the amount.
class CoinReward extends StatelessWidget {
  final int amount;
  final double fontSize;

  const CoinReward({super.key, required this.amount, this.fontSize = 16});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        // Opak hap: parlak gökyüzünde de okunur, cam değil.
        color: Colors.black.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Gold coin icon
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFFFE066),
                  Color(0xFFFFC107),
                  Color(0xFFE6A100)
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFC107).withValues(alpha: 0.5),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                '🪙',
                style: TextStyle(fontSize: 12),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '$amount',
            style: AppText.nunito(
              fontSize: fontSize,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
