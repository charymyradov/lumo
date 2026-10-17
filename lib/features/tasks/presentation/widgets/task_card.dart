import 'package:flutter/material.dart';
import 'package:lumo/core/constants/app_text.dart';
import 'package:lumo/core/constants/app_colors.dart';
import 'package:lumo/shared/widgets/coin_badge.dart';
import 'package:lumo/shared/widgets/glass_card.dart';

/// A single task row shown on the Tasks page:
/// colored icon bubble • title + subtitle • reward + duration.
class TaskCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final int reward;
  final String duration;
  final IconData icon;
  final Color iconColor;
  final bool completed;
  final VoidCallback? onTap;

  const TaskCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.reward,
    required this.duration,
    required this.icon,
    required this.iconColor,
    this.completed = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: GlassCard(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        radius: 26,
        opacity: completed ? 0.28 : 0.45,
        child: Row(
          children: [
            // Icon bubble
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    iconColor.withValues(alpha: completed ? 0.55 : 0.95),
                    iconColor.withValues(alpha: completed ? 0.4 : 0.75),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: iconColor.withValues(alpha: 0.35),
                    blurRadius: 12,
                    spreadRadius: 0,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                completed ? Icons.check_rounded : icon,
                color: Colors.white,
                size: 27,
              ),
            ),
            const SizedBox(width: 13),

            // Title + subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppText.nunito(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      decoration: completed ? TextDecoration.lineThrough : null,
                      decorationColor: AppColors.textPrimary.withValues(
                        alpha: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppText.nunito(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary.withValues(alpha: 0.9),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Reward + duration
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                CoinReward(amount: reward),
                const SizedBox(height: 6),
                Text(
                  duration,
                  style: AppText.nunito(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
