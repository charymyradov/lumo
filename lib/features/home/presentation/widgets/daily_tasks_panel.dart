import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lumo/core/constants/app_text.dart';
import 'package:lumo/core/di/injection.dart';
import 'package:lumo/features/home/presentation/widgets/daily_tasks/daily_tasks_header.dart';
import 'package:lumo/features/home/presentation/widgets/daily_tasks/daily_tasks_quest_row.dart';
import 'package:lumo/features/home/presentation/widgets/daily_tasks/daily_tasks_skeleton.dart';
import 'package:lumo/features/tasks/presentation/bloc/quest_bloc.dart';
import 'package:lumo/features/tasks/presentation/bloc/quest_event.dart';
import 'package:lumo/features/tasks/presentation/bloc/quest_state.dart';
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

class _DailyTasksView extends StatelessWidget {
  const _DailyTasksView();

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

        if (bundle == null) {
          return DailyTasksSkeleton(previewCount: previewCount);
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
              DailyTasksHeader(done: doneCount, total: tasks.length),
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
                  DailyTasksQuestRow(
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
}
