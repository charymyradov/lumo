import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lumo/core/constants/app_colors.dart';
import 'package:lumo/core/constants/asset_paths.dart';
import 'package:lumo/features/tasks/presentation/widgets/streak_banner.dart';
import 'package:lumo/features/tasks/presentation/widgets/task_card.dart';
import 'package:lumo/shared/widgets/segmented_tabs.dart';

/// Model describing one task row.
class _TaskItem {
  final String title;
  final String subtitle;
  final int reward;
  final String duration;
  final IconData icon;
  final Color color;

  const _TaskItem({
    required this.title,
    required this.subtitle,
    required this.reward,
    required this.duration,
    required this.icon,
    required this.color,
  });
}

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  static const List<String> _tabs = ['Günlük', 'Haftalık', 'Özel'];

  int _selectedTab = 0;

  static const List<_TaskItem> _dailyTasks = [
    _TaskItem(
      title: 'Su iç',
      subtitle: 'Sağlığın için su iç.',
      reward: 10,
      duration: '1 dk',
      icon: Icons.water_drop_rounded,
      color: Color(0xFF4FB3F0),
    ),
    _TaskItem(
      title: '10.000 adım at',
      subtitle: 'Hareket et, enerjini artır.',
      reward: 20,
      duration: '20 dk',
      icon: Icons.directions_run_rounded,
      color: Color(0xFF58C77A),
    ),
    _TaskItem(
      title: 'Nefes egzersizi yap',
      subtitle: 'Sakinleş ve odaklan.',
      reward: 15,
      duration: '5 dk',
      icon: Icons.air_rounded,
      color: Color(0xFF6FC8E8),
    ),
    _TaskItem(
      title: 'Günlük yaz',
      subtitle: 'Düşüncelerini paylaş.',
      reward: 25,
      duration: '10 dk',
      icon: Icons.edit_note_rounded,
      color: Color(0xFF9B6FE0),
    ),
  ];

  static const List<_TaskItem> _weeklyTasks = [
    _TaskItem(
      title: '5 gün arka arkaya spor yap',
      subtitle: 'Haftalık hedefine ulaş.',
      reward: 60,
      duration: '5 gün',
      icon: Icons.fitness_center_rounded,
      color: Color(0xFFE09B3D),
    ),
    _TaskItem(
      title: '3 kez nefes seansı tamamla',
      subtitle: 'Zihnini dinlendir.',
      reward: 40,
      duration: '3 seans',
      icon: Icons.self_improvement_rounded,
      color: Color(0xFF5CC8A0),
    ),
    _TaskItem(
      title: 'Haftalık hedef yaz',
      subtitle: 'Kendin için bir hedef belirle.',
      reward: 35,
      duration: '15 dk',
      icon: Icons.flag_rounded,
      color: Color(0xFFE05C7A),
    ),
  ];

  final Set<int> _completedDaily = {};
  final Set<int> _completedWeekly = {};

  bool get _isWeekly => _selectedTab == 1;

  List<_TaskItem> get _tasks => _isWeekly ? _weeklyTasks : _dailyTasks;

  Set<int> get _completed =>
      _isWeekly ? _completedWeekly : _completedDaily;

  double get _progress {
    if (_tasks.isEmpty) return 0;
    return _completed.length / _tasks.length;
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

                Text(
                  'Görevler',
                  style: GoogleFonts.nunito(
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),

                Expanded(
                  child: _selectedTab == 2
                      ? _buildCustomEmptyState()
                      : _buildTaskList(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTaskList() {
    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        ...List.generate(_tasks.length, (index) {
          final task = _tasks[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: TaskCard(
              title: task.title,
              subtitle: task.subtitle,
              reward: task.reward,
              duration: task.duration,
              icon: task.icon,
              iconColor: task.color,
              completed: _completed.contains(index),
              onTap: () => _toggleTask(index),
            ),
          );
        }),
        StreakBanner(days: 7, reward: 100, progress: _progress),
        const SizedBox(height: 100),
      ],
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
            style: GoogleFonts.nunito(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Kendine özel görevler oluşturabileceksin.',
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleTask(int index) {
    setState(() {
      if (!_completed.add(index)) {
        _completed.remove(index);
      }
    });
  }
}
