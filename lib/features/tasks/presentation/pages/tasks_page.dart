import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lumo/core/di/injection.dart';
import 'package:lumo/features/tasks/presentation/bloc/quest_bloc.dart';
import 'package:lumo/features/tasks/presentation/bloc/quest_event.dart';
import 'package:lumo/features/tasks/presentation/pages/tasks_streak_mixin.dart';
import 'package:lumo/features/tasks/presentation/pages/widgets/tasks_background.dart';
import 'package:lumo/features/tasks/presentation/pages/widgets/tasks_empty_state.dart';
import 'package:lumo/features/tasks/presentation/pages/widgets/tasks_header.dart';
import 'package:lumo/features/tasks/presentation/pages/widgets/tasks_quest_list.dart';
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

class _TasksViewState extends State<_TasksView> with TasksStreakMixin {
  static const List<String> _tabs = ['Daily', 'Weekly', 'Custom'];

  int _selectedTab = 0;
  bool get _isWeekly => _selectedTab == 1;

  @override
  void initState() {
    super.initState();
    loadStreak();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const TasksBackground(),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                SegmentedTabs(
                  labels: _tabs,
                  selectedIndex: _selectedTab,
                  onChanged: (index) => setState(() => _selectedTab = index),
                ),
                const SizedBox(height: 22),
                const TasksHeader(),
                const SizedBox(height: 12),
                Expanded(
                  child: _selectedTab == 2
                      ? const TasksEmptyState()
                      : TasksQuestList(
                          isWeekly: _isWeekly,
                          streak: streak,
                        ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
