import 'package:flutter/material.dart';
import 'package:lumo/core/constants/app_colors.dart';
import 'package:lumo/core/constants/app_text.dart';

/// Custom sekmesi boş durumu.
class TasksEmptyState extends StatelessWidget {
  const TasksEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppColors.accent.withValues(alpha: 0.35),
                  AppColors.primary.withValues(alpha: 0.25),
                ],
              ),
              border: Border.all(color: Colors.white, width: 1.5),
            ),
            child: const Icon(
              Icons.add_rounded,
              size: 44,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'No custom quests yet',
            style: AppText.nunito(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Daily and Weekly quests cover your goals for now.',
            textAlign: TextAlign.center,
            style: AppText.nunito(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }
}
