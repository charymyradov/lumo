import 'package:flutter/material.dart';
import 'package:lumo/features/journal/presentation/bloc/journal_bloc.dart';
import 'package:lumo/features/journal/presentation/bloc/journal_state.dart';
import 'package:lumo/features/journal/presentation/pages/widgets/journal_save_button.dart';
import 'package:lumo/features/journal/presentation/widgets/ai_insight_panel.dart';
import 'package:lumo/features/journal/presentation/widgets/date_picker_field.dart';
import 'package:lumo/features/journal/presentation/widgets/journal_text_field.dart';
import 'package:lumo/features/journal/presentation/widgets/mood_selector.dart';
import 'package:lumo/features/journal/presentation/widgets/tag_chips.dart';

/// Mood + tarih + metin + etiket + kaydet + AI panelleri.
class JournalFormSection extends StatelessWidget {
  final JournalState state;
  final TextEditingController controller;
  final String dateText;
  final ValueChanged<int> onMoodChanged;
  final ValueChanged<String> onTextChanged;
  final ValueChanged<int> onTagToggled;
  final VoidCallback onPickDate;
  final VoidCallback onSave;

  const JournalFormSection({
    super.key,
    required this.state,
    required this.controller,
    required this.dateText,
    required this.onMoodChanged,
    required this.onTextChanged,
    required this.onTagToggled,
    required this.onPickDate,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MoodSelector(
          selectedIndex: state.moodIndex,
          onChanged: onMoodChanged,
        ),
        const SizedBox(height: 16),
        DatePickerField(dateText: dateText, onTap: onPickDate),
        const SizedBox(height: 12),
        JournalTextField(controller: controller, onChanged: onTextChanged),
        const SizedBox(height: 12),
        TagChips(
          tags: JournalBloc.tags,
          selected: state.selectedTags,
          onTap: onTagToggled,
        ),
        const SizedBox(height: 14),
        JournalSaveButton(saved: state.saved, onPressed: onSave),
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
          entryCount: controller.text.trim().isEmpty ? 2 : 3,
          message: state.selectedTags.isEmpty
              ? 'Add a tag to surface your weekly pattern.'
              : 'Top tag: ${JournalBloc.tags[state.selectedTags.first]} — keep it up.',
        ),
        const SizedBox(height: 110),
      ],
    );
  }
}
