import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lumo/core/constants/app_colors.dart';
import 'package:lumo/core/constants/app_text.dart';
import 'package:lumo/core/di/injection.dart';
import 'package:lumo/features/journal/presentation/bloc/journal_bloc.dart';
import 'package:lumo/features/journal/presentation/bloc/journal_event.dart';
import 'package:lumo/features/journal/presentation/bloc/journal_state.dart';
import 'package:lumo/features/journal/presentation/pages/journal_controller_mixin.dart';
import 'package:lumo/features/journal/presentation/pages/widgets/journal_background.dart';
import 'package:lumo/features/journal/presentation/pages/widgets/journal_form_section.dart';

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

class _JournalViewState extends State<_JournalView>
    with JournalControllerMixin {
  @override
  void initState() {
    super.initState();
    initJournalController();
  }

  @override
  void dispose() {
    disposeJournalController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<JournalBloc, JournalState>(
      listenWhen: journalListenWhen,
      listener: onJournalState,
      builder: (context, state) {
        final bloc = context.read<JournalBloc>();
        return Stack(
          fit: StackFit.expand,
          children: [
            const JournalBackground(),
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
                    JournalFormSection(
                      state: state,
                      controller: journalController,
                      dateText: journalDateText(state.day),
                      onMoodChanged: (i) =>
                          bloc.add(JournalMoodChanged(i)),
                      onTextChanged: (t) =>
                          bloc.add(JournalTextChanged(t)),
                      onTagToggled: (i) => bloc.add(JournalTagToggled(i)),
                      onPickDate: () => pickJournalDate(context, state.day),
                      onSave: () => saveJournal(context),
                    ),
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
