import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lumo/core/constants/app_colors.dart';
import 'package:lumo/core/constants/app_text.dart';
import 'package:lumo/features/tasks/domain/entities/quest.dart';
import 'package:lumo/features/tasks/presentation/bloc/quest_bloc.dart';
import 'package:lumo/features/tasks/presentation/bloc/quest_event.dart';
import 'package:lumo/features/tasks/presentation/bloc/quest_state.dart';

/// Başlık + kaynak rozeti + yenile butonu.
class TasksHeader extends StatelessWidget {
  const TasksHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tasks',
                style: AppText.nunito(
                  fontSize: 23,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              BlocBuilder<QuestBloc, QuestState>(
                buildWhen: (p, c) => c is QuestLoaded,
                builder: (context, state) {
                  if (state is! QuestLoaded) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      switch (state.bundle.source) {
                        QuestSource.fresh => '✨ Generated with AI',
                        QuestSource.cache => 'Showing from cache',
                        QuestSource.fallback => 'Built-in list',
                      },
                      style: AppText.nunito(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary.withValues(alpha: 0.85),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        BlocBuilder<QuestBloc, QuestState>(
          builder: (context, state) {
            final busy = state is QuestLoading;
            return IconButton(
              onPressed: busy
                  ? null
                  : () => context
                      .read<QuestBloc>()
                      .add(const QuestRefreshRequested()),
              tooltip: 'Refresh quests',
              icon: busy
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2.4),
                    )
                  : const Icon(
                      Icons.refresh_rounded,
                      color: AppColors.primary,
                      size: 24,
                    ),
            );
          },
        ),
      ],
    );
  }
}
