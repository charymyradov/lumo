import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lumo/core/constants/app_text.dart';
import 'package:lumo/core/constants/app_colors.dart';
import 'package:lumo/core/constants/asset_paths.dart';
import 'package:lumo/core/di/injection.dart';
import 'package:lumo/core/services/haptic_service.dart';
import 'package:lumo/features/journal/presentation/bloc/journal_bloc.dart';
import 'package:lumo/features/journal/presentation/bloc/journal_event.dart';
import 'package:lumo/features/journal/presentation/bloc/journal_state.dart';
import 'package:lumo/features/journal/presentation/widgets/ai_insight_panel.dart';
import 'package:lumo/features/journal/presentation/widgets/date_picker_field.dart';
import 'package:lumo/features/journal/presentation/widgets/journal_text_field.dart';
import 'package:lumo/features/journal/presentation/widgets/mood_selector.dart';
import 'package:lumo/features/journal/presentation/widgets/tag_chips.dart';

/// 4. Günlük (Journal) — tüm etkileşim Bloc Event ile.
class JournalPage extends StatelessWidget {
  const JournalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<JournalBloc>()..add(const JournalLoadRequested()),
      child: const _JournalView(),
    );
  }
}

class _JournalView extends StatefulWidget {
  const _JournalView();

  @override
  State<_JournalView> createState() => _JournalViewState();
}

class _JournalViewState extends State<_JournalView> {
  late final TextEditingController _controller;
  bool _synced = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  String _dateText(DateTime day) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return '${day.day} ${months[day.month - 1]} ${day.year}';
  }

  Future<void> _pickDate(BuildContext context, DateTime current) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked == null || !context.mounted) return;
    _synced = false;
    context.read<JournalBloc>().add(JournalDayPicked(picked));
  }

  void _save(BuildContext context) {
    HapticService.success();
    context.read<JournalBloc>().add(const JournalSaveRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<JournalBloc, JournalState>(
      listenWhen: (p, c) =>
          p.text != c.text ||
          p.day != c.day ||
          p.loading != c.loading ||
          (c.message != null && c.message != p.message),
      listener: (context, state) {
        // Bloc'tan gelen metni controller'a tek yönlü senkronla.
        if (!state.loading && !_synced) {
          _controller.text = state.text;
          _synced = true;
        }
        final msg = state.message;
        if (msg != null && state.saved) {
          ScaffoldMessenger.of(context)
            ..clearSnackBars()
            ..showSnackBar(
              SnackBar(
                content: Text(msg),
                duration: const Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
              ),
            );
        }
      },
      builder: (context, state) {
        final bloc = context.read<JournalBloc>();
        return Stack(
          fit: StackFit.expand,
          children: [
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
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    Text(
                      'How are you today?',
                      style: AppText.nunito(
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    MoodSelector(
                      selectedIndex: state.moodIndex,
                      onChanged: (i) => bloc.add(JournalMoodChanged(i)),
                    ),
                    const SizedBox(height: 16),
                    DatePickerField(
                      dateText: _dateText(state.day),
                      onTap: () => _pickDate(context, state.day),
                    ),
                    const SizedBox(height: 12),
                    JournalTextField(
                      controller: _controller,
                      onChanged: (t) => bloc.add(JournalTextChanged(t)),
                    ),
                    const SizedBox(height: 12),
                    TagChips(
                      tags: JournalBloc.tags,
                      selected: state.selectedTags,
                      onTap: (i) => bloc.add(JournalTagToggled(i)),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF4FA8F0), Color(0xFF3E8FE0)],
                          ),
                          borderRadius: BorderRadius.circular(26),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF3E8FE0)
                                  .withValues(alpha: 0.35),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () => _save(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(26),
                            ),
                          ),
                          child: Text(
                            state.saved ? 'Saved ✓' : 'Save',
                            style: AppText.nunito(
                              fontSize: 16.5,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    if (state.loading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2.5),
                          ),
                        ),
                      )
                    else
                      AiInsightPanel(message: JournalBloc.insightFor(state)),
                    const SizedBox(height: 10),
                    AiPatternStrip(
                      entryCount: _controller.text.trim().isEmpty ? 2 : 3,
                      message: state.selectedTags.isEmpty
                          ? 'Add a tag to surface your weekly pattern.'
                          : 'Top tag: ${JournalBloc.tags[state.selectedTags.first]} — keep it up.',
                    ),
                    const SizedBox(height: 110),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
