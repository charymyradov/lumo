import 'package:flutter/material.dart';
import 'package:lumo/core/constants/app_text.dart';
import 'package:lumo/features/tasks/presentation/widgets/quest_visuals.dart';

/// Tek satırlık kompakt görev satırı.
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
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Opacity(
        opacity: completed ? 0.55 : 1.0,
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
                color: Colors.white,
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
                  color: const Color(0xFF1E2E3D),
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
                color: const Color(0xFFB8860B),
              ),
            ),
            const SizedBox(width: 4),
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: completed ? const Color(0xFF58C77A) : Colors.transparent,
                border: Border.all(
                  color: completed
                      ? const Color(0xFF58C77A)
                      : const Color(0xFFCBD5E1),
                  width: 1.6,
                ),
              ),
              child: completed
                  ? const Icon(Icons.check_rounded,
                      size: 12, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
