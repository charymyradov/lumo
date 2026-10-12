import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lumo/core/constants/app_text.dart';
import 'package:lumo/core/constants/app_colors.dart';
import 'package:lumo/core/constants/asset_paths.dart';
import 'package:lumo/features/tasks/domain/entities/quest.dart';
import 'package:lumo/features/tasks/presentation/cubit/quest_cubit.dart';
import 'package:lumo/features/tasks/presentation/cubit/quest_state.dart';
import 'package:lumo/features/tasks/presentation/widgets/quest_visuals.dart';
import 'package:lumo/features/tasks/presentation/widgets/streak_banner.dart';
import 'package:lumo/features/tasks/presentation/widgets/task_card.dart';
import 'package:lumo/shared/widgets/segmented_tabs.dart';

/// Görevler sayfası — liste Gemini AI'dan gelir.
/// Anahtar yoksa / çevrimdışıyken önbellek + yerleşik liste gösterilir;
/// kart tasarımı ve sekmeler eskisiyle aynı.
class TasksPage extends StatelessWidget {
  const TasksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => QuestCubit()..load(),
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
  static const List<String> _tabs = ['Günlük', 'Haftalık', 'Özel'];

  int _selectedTab = 0;
  final Set<String> _completedIds = {};

  bool get _isWeekly => _selectedTab == 1;

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
                'Görevler',
                style: AppText.nunito(
                  fontSize: 23,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              BlocBuilder<QuestCubit, QuestState>(
                buildWhen: (p, c) => c is QuestLoaded,
                builder: (context, state) {
                  if (state is! QuestLoaded) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      switch (state.bundle.source) {
                        QuestSource.fresh => '✨ Yapay zekâ ile hazırlandı',
                        QuestSource.cache => 'Önbellekten gösteriliyor',
                        QuestSource.fallback => 'Hazır liste',
                      },
                      style: AppText.nunito(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary
                            .withValues(alpha: 0.85),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        BlocBuilder<QuestCubit, QuestState>(
          builder: (context, state) {
            final busy = state is QuestLoading;
            return IconButton(
              onPressed: busy
                  ? null
                  : () => context.read<QuestCubit>().refresh(),
              tooltip: 'Görevleri yenile',
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
    return BlocConsumer<QuestCubit, QuestState>(
      listenWhen: (p, c) => c is QuestLoaded && c.notice != null,
      listener: (context, state) {
        final notice = (state as QuestLoaded).notice;
        if (notice == null) return;
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(
            SnackBar(
              content: Text(notice),
              duration: const Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
            ),
          );
      },
      builder: (context, state) {
        final bundle = switch (state) {
          QuestLoaded(:final bundle) => bundle,
          QuestLoading(:final current?) => current,
          _ => null,
        };
        if (bundle == null) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final tasks = _isWeekly ? bundle.weekly : bundle.daily;
        final doneCount =
            tasks.where((q) => _completedIds.contains(q.id)).length;
        final progress =
            tasks.isEmpty ? 0.0 : doneCount / tasks.length;

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
                  completed: _completedIds.contains(task.id),
                  onTap: () => _toggleTask(task.id),
                ),
              );
            }),
            StreakBanner(days: 7, reward: 100, progress: progress),
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
            'Henüz özel görev yok',
            style: AppText.nunito(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Kendine özel görevler oluşturabileceksin.',
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

  void _toggleTask(String id) {
    setState(() {
      if (!_completedIds.add(id)) {
        _completedIds.remove(id);
      }
    });
  }
}
