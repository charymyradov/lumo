import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lumo/core/constants/app_text.dart';
import 'package:lumo/core/constants/app_colors.dart';
import 'package:lumo/core/constants/asset_paths.dart';
import 'package:lumo/core/di/injection.dart';
import 'package:lumo/core/repositories/wallet_repository.dart';
import 'package:lumo/core/services/haptic_service.dart';
import 'package:lumo/features/tasks/domain/entities/quest.dart';
import 'package:lumo/features/tasks/presentation/bloc/quest_bloc.dart';
import 'package:lumo/features/tasks/presentation/bloc/quest_event.dart';
import 'package:lumo/features/tasks/presentation/bloc/quest_state.dart';
import 'package:lumo/features/tasks/presentation/widgets/quest_visuals.dart';
import 'package:lumo/features/tasks/presentation/widgets/streak_banner.dart';
import 'package:lumo/features/tasks/presentation/widgets/task_card.dart';
import 'package:lumo/shared/widgets/segmented_tabs.dart';

/// Görevler sayfası — liste Gemini AI'dan gelir.
/// Tüm etkileşim Bloc Event ile.
class TasksPage extends StatelessWidget {
  const TasksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<QuestBloc>()..add(const QuestLoadRequested()),
      child: const _TasksView(),
    );
  }
}

class _TasksView extends StatefulWidget {
  const _TasksView();

  @override
  State<_TasksView> createState() => _TasksViewState();
}

class _TasksViewState extends State<_TasksView> {
  static const List<String> _tabs = ['Daily', 'Weekly', 'Custom'];

  int _selectedTab = 0;
  int _streak = 7;

  bool get _isWeekly => _selectedTab == 1;

  @override
  void initState() {
    super.initState();
    _loadStreak();
  }

  Future<void> _loadStreak() async {
    // Streak rozeti cüzdan reposundan — görev tamamlama seti Bloc'ta.
    final wallet = await sl<WalletRepository>().load();
    if (!mounted) return;
    setState(() => _streak = wallet.streak);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background (softly blurred like the reference design)
        ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Image.asset(
              AssetPaths.splash2Jpg,
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),
        ),

        // Soft scrim so content stays readable
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.0, 0.18, 0.45, 1.0],
              colors: [
                Color(0x40FFFFFF),
                Color(0x66FFFFFF),
                Color(0xB3FFFFFF),
                Color(0xD9FFFFFF),
              ],
            ),
          ),
        ),

        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),

                // Günlük / Haftalık / Özel
                SegmentedTabs(
                  labels: _tabs,
                  selectedIndex: _selectedTab,
                  onChanged: (index) => setState(() => _selectedTab = index),
                ),

                const SizedBox(height: 22),

                _buildHeader(),

                const SizedBox(height: 12),

                Expanded(
                  child: _selectedTab == 2
                      ? _buildCustomEmptyState()
                      : _buildQuestList(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Başlık + kaynak rozeti + yenile butonu.
  Widget _buildHeader() {
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
                  if (state is! QuestLoaded) {
                    return const SizedBox.shrink();
                  }
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

  Widget _buildQuestList() {
    return BlocConsumer<QuestBloc, QuestState>(
      listenWhen: (p, c) {
        if (c is QuestError) return true;
        if (c is QuestLoaded) {
          // notice ilk yüklemede, reward her toggle'da gösterilir.
          final prevReward = p is QuestLoaded ? p.rewardMessage : null;
          return c.notice != null && p is! QuestLoaded ||
              (c.rewardMessage != null && c.rewardMessage != prevReward);
        }
        return false;
      },
      listener: (context, state) {
        final message = switch (state) {
          QuestLoaded(:final rewardMessage?) when rewardMessage.isNotEmpty =>
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
      },
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
          if (state is QuestError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.cloud_off_rounded, size: 44),
                  const SizedBox(height: 12),
                  Text(state.message),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => context
                        .read<QuestBloc>()
                        .add(const QuestLoadRequested()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final tasks = _isWeekly ? bundle.weekly : bundle.daily;
        final doneCount =
            tasks.where((q) => completedIds.contains(q.id)).length;
        final progress = tasks.isEmpty ? 0.0 : doneCount / tasks.length;

        return ListView(
          physics: const BouncingScrollPhysics(),
          children: [
            ...List.generate(tasks.length, (index) {
              final task = tasks[index];
              final visual = questVisuals(task.category);
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: TaskCard(
                  title: task.title,
                  subtitle: task.subtitle,
                  reward: task.reward,
                  duration: task.duration,
                  icon: visual.icon,
                  iconColor: visual.color,
                  completed: completedIds.contains(task.id),
                  onTap: () => _toggleTask(context, task),
                ),
              );
            }),
            StreakBanner(days: _streak, reward: 100, progress: progress),
            const SizedBox(height: 100),
          ],
        );
      },
    );
  }

  Widget _buildCustomEmptyState() {
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

  void _toggleTask(BuildContext context, Quest task) {
    // Ekonomi Bloc'ta — Widget sadece Event gönderir + haptic başlatır.
    HapticService.selection();
    context.read<QuestBloc>().add(QuestTaskToggled(task));
  }
}
