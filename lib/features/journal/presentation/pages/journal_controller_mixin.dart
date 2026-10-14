import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lumo/core/services/haptic_service.dart';
import 'package:lumo/features/journal/presentation/bloc/journal_bloc.dart';
import 'package:lumo/features/journal/presentation/bloc/journal_event.dart';
import 'package:lumo/features/journal/presentation/bloc/journal_state.dart';

/// Controller yaşam döngüsü + tarih seçimi + kaydet + snackbar senkronu.
mixin JournalControllerMixin<T extends StatefulWidget> on State<T> {
  late final TextEditingController journalController;
  bool journalSynced = false;

  void initJournalController() {
    journalController = TextEditingController();
  }

  void disposeJournalController() {
    journalController.dispose();
  }

  String journalDateText(DateTime day) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${day.day} ${months[day.month - 1]} ${day.year}';
  }

  Future<void> pickJournalDate(BuildContext context, DateTime current) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked == null || !context.mounted) return;
    journalSynced = false;
    context.read<JournalBloc>().add(JournalDayPicked(picked));
  }

  void saveJournal(BuildContext context) {
    HapticService.success();
    context.read<JournalBloc>().add(const JournalSaveRequested());
  }

  bool journalListenWhen(JournalState p, JournalState c) =>
      p.text != c.text ||
      p.day != c.day ||
      p.loading != c.loading ||
      (c.message != null && c.message != p.message);

  void onJournalState(BuildContext context, JournalState state) {
    if (!state.loading && !journalSynced) {
      journalController.text = state.text;
      journalSynced = true;
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
  }
}
