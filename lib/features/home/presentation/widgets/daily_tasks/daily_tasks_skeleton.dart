import 'package:flutter/material.dart';
import 'package:lumo/features/home/presentation/widgets/daily_tasks/daily_tasks_header.dart';
import 'package:lumo/shared/widgets/glass_card.dart';

/// Yükleniyor iskeleti.
class DailyTasksSkeleton extends StatelessWidget {
  final int previewCount;

  const DailyTasksSkeleton({super.key, required this.previewCount});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      radius: 16,
      opacity: 0.86,
      blur: 18,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const DailyTasksHeader(done: 0, total: 0),
          const SizedBox(height: 6),
          for (var i = 0; i < previewCount; i++) ...[
            const _SkeletonRow(),
            if (i < previewCount - 1) const SizedBox(height: 5),
          ],
        ],
      ),
    );
  }
}

class _SkeletonRow extends StatelessWidget {
  const _SkeletonRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFE2E8F0),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            height: 12,
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
      ],
    );
  }
}
