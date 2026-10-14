import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lumo/core/services/haptic_service.dart';
import 'package:lumo/features/tasks/domain/entities/quest.dart';
import 'package:lumo/features/tasks/presentation/bloc/quest_bloc.dart';
import 'package:lumo/features/tasks/presentation/bloc/quest_event.dart';
import 'package:lumo/features/tasks/presentation/bloc/quest_state.dart';
import 'package:lumo/features/tasks/presentation/widgets/quest_visuals.dart';
import 'package:lumo/features/tasks/presentation/widgets/streak_banner.dart';
import 'package:lumo/features/tasks/presentation/widgets/task_card.dart';

/// Bloc dinleme (snackbar + haptic) + liste oluşturma tek widget'ta.
class TasksQuestList extends StatelessWidget {
  final bool isWeekly;
  final int streak;

  const TasksQuestList({
    super.key,
    required this.isWeekly,
    required this.streak,
  });

  void _toggle(BuildContext context, Quest task) {
    HapticService.selection();
    context.read<QuestBloc>().add(QuestTaskToggled(task));
  }

  bool _listenWhen(QuestState prev, QuestState curr) {
    if (curr is QuestError) return true;
    if (curr is QuestLoaded) {
      final prevReward = prev is QuestLoaded ? prev.rewardMessage : null;
      return curr.notice != null && prev is! QuestLoaded ||
          (curr.rewardMessage != null && curr.rewardMessage != prevReward);
    }
    return false;
  }

  void _listener(BuildContext context, QuestState state) {
    final message = switch (state) {
      QuestLoaded(:final rewardMessage?)
          when rewardMessage.isNotEmpty =>
        rewardMessage,
      QuestLoaded(:final notice?) => notice,
      QuestError(:final message) => message,
      _ => null,
    };
    if (message == null) return;
    if (state is QuestLoaded && state.rewardMessage != null) {
      HapticService.success();
    }
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<QuestBloc, QuestState>(
      listenWhen: _listenWhen,
      listener: _listener,
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
          if (state is QuestError) return _ErrorView(message: state.message);
          return const Center(child: CircularProgressIndicator());
        }

        final tasks = isWeekly ? bundle.weekly : bundle.daily;
        final doneCount =
            tasks.where((q) => completedIds.contains(q.id)).length;
        final progress = tasks.isEmpty ? 0.0 : doneCount / tasks.length;

        return ListView(
          physics: const BouncingScrollPhysics(),
          children: [
            for (final task in tasks)
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Builder(builder: (context) {
                  final visual = questVisuals(task.category);
                  return TaskCard(
                    title: task.title,
                    subtitle: task.subtitle,
                    reward: task.reward,
                    duration: task.duration,
                    icon: visual.icon,
                    iconColor: visual.color,
                    completed: completedIds.contains(task.id),
                    onTap: () => _toggle(context, task),
                  );
                }),
              ),
            StreakBanner(days: streak, reward: 100, progress: progress),
            const SizedBox(height: 100),
          ],
        );
      },
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off_rounded, size: 44),
          const SizedBox(height: 12),
          Text(message),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () =>
                context.read<QuestBloc>().add(const QuestLoadRequested()),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
