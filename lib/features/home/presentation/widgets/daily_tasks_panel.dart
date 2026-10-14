import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lumo/core/constants/app_text.dart';
import 'package:lumo/core/di/injection.dart';
import 'package:lumo/features/tasks/presentation/bloc/quest_bloc.dart';
import 'package:lumo/features/tasks/presentation/bloc/quest_event.dart';
import 'package:lumo/features/tasks/presentation/bloc/quest_state.dart';
import 'package:lumo/features/tasks/presentation/widgets/quest_visuals.dart';
import 'package:lumo/shared/widgets/glass_card.dart';

/// Home sekmesinde gösterilen kompakt günlük görev önizlemesi.
/// Kendi [QuestBloc]'unu kurar — Tasks sekmesindeki bloc'tan bağımsızdır
/// (önbellek sayesinde ekstra ağ isteği atılmaz).
class DailyTasksPanel extends StatelessWidget {
  const DailyTasksPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<QuestBloc>()..add(const QuestLoadRequested()),
      child: const _DailyTasksView(),
    );
  }
}

class _DailyTasksView extends StatefulWidget {
  const _DailyTasksView();

  @override
  State<_DailyTasksView> createState() => _DailyTasksViewState();
}

class _DailyTasksViewState extends State<_DailyTasksView> {
  @override
  Widget build(BuildContext context) {
    // Kısa ekranlarda kartın peti kapatmaması için önizleme sayısı azalır.
    final screenH = MediaQuery.of(context).size.height;
    final previewCount = screenH < 700 ? 2 : 3;
    return BlocBuilder<QuestBloc, QuestState>(
      builder: (context, state) {
        final bundle = switch (state) {
          QuestLoaded(:final bundle) => bundle,
          QuestLoading(:final current?) => current,
          QuestError(:final current?) => current,
          _ => null,
        };
        final completedIds = switch (state) {
          QuestLoaded(:final completedIds) => completedIds,
          _ => const <String>{},
        };

        // Yükleniyor + önbellek yoksa: ince iskelet göster.
        if (bundle == null) {
          return GlassCard(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            radius: 16,
            opacity: 0.86,
            blur: 18,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _headerRow(0, 0),
                const SizedBox(height: 6),
                for (var i = 0; i < previewCount; i++) ...[
                  _skeletonRow(),
                  if (i < previewCount - 1) const SizedBox(height: 5),
                ],
              ],
            ),
          );
        }

        final tasks = bundle.daily;
        final preview = tasks.take(previewCount).toList();
        final doneCount =
            tasks.where((q) => completedIds.contains(q.id)).length;

        return GlassCard(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          radius: 16,
          opacity: 0.86,
          blur: 18,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _headerRow(doneCount, tasks.length),
              const SizedBox(height: 6),
              if (preview.isEmpty)
                Text(
                  'No quests today — check Tasks tab.',
                  style: AppText.nunito(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF5D6470),
                  ),
                )
              else
                for (var i = 0; i < preview.length; i++) ...[
                  _questRow(
                    title: preview[i].title,
                    category: preview[i].category,
                    reward: preview[i].reward,
                    completed: completedIds.contains(preview[i].id),
                    onTap: () => context
                        .read<QuestBloc>()
                        .add(QuestTaskToggled(preview[i])),
                  ),
                  if (i < preview.length - 1) const SizedBox(height: 5),
                ],
              if (tasks.length > preview.length) ...[
                const SizedBox(height: 4),
                Text(
                  '+${tasks.length - preview.length} more in Tasks tab',
                  style: AppText.nunito(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF5D6470),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _headerRow(int done, int total) {
    return Row(
      children: [
        const Icon(Icons.checklist_rounded, size: 15, color: Color(0xFF5A449C)),
        const SizedBox(width: 6),
        Text(
          'Daily Quests',
          style: AppText.nunito(
            fontSize: 13.5,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1E2E3D),
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFF5A449C),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$done/$total',
            style: AppText.nunito(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _questRow({
    required String title,
    required String category,
    required int reward,
    required bool completed,
    required VoidCallback onTap,
  }) {
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

  Widget _skeletonRow() {
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
