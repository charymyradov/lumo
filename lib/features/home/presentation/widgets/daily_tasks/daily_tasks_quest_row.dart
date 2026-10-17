import 'package:flutter/material.dart';
import 'package:lumo/core/constants/app_text.dart';
import 'package:lumo/features/tasks/presentation/widgets/quest_visuals.dart';
import 'package:lumo/shared/widgets/lumo_tap.dart';

/// Tek satırlık kompakt görev satırı.
///
/// Perf: [Opacity] katmanı yok — tamamlanan satırlar soldurulmuş
/// renklerle çizilir, böylece compositor'da ekstra offscreen layer
/// açılmaz. Satır hâlâ dokunulabilir (tamamlananı geri alma davranışı
/// korunur), bu yüzden [IgnorePointer] kullanılmaz.
class DailyTasksQuestRow extends StatelessWidget {
  final String title;
  final String category;
  final int reward;
  final bool completed;
  final VoidCallback onTap;

  const DailyTasksQuestRow({
    super.key,
    required this.title,
    required this.category,
    required this.reward,
    required this.completed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final visual = questVisuals(category);
    final titleColor = completed
        ? const Color(0xFF1E2E3D).withValues(alpha: 0.55)
        : const Color(0xFF1E2E3D);
    final rewardColor = completed
        ? const Color(0xFFB8860B).withValues(alpha: 0.55)
        : const Color(0xFFB8860B);
    return LumoTap(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: visual.color.withValues(alpha: completed ? 0.45 : 0.9),
            ),
            child: Icon(
              completed ? Icons.check_rounded : visual.icon,
              color: Colors.white.withValues(alpha: completed ? 0.85 : 1.0),
              size: 15,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppText.nunito(
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                color: titleColor,
                decoration: completed ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '+$reward',
            style: AppText.nunito(
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              color: rewardColor,
            ),
          ),
          const SizedBox(width: 4),
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: completed
                  ? const Color(0xFF58C77A).withValues(alpha: 0.85)
                  : Colors.transparent,
              border: Border.all(
                color: completed
                    ? const Color(0xFF58C77A)
                    : const Color(0xFFCBD5E1),
                width: 1.6,
              ),
            ),
            child: completed
                ? const Icon(
                    Icons.check_rounded,
                    size: 12,
                    color: Colors.white,
                  )
                : null,
          ),
        ],
      ),
    );
  }
}
