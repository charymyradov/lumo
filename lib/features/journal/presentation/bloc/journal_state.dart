import 'package:equatable/equatable.dart';

class JournalState extends Equatable {
  final int moodIndex;
  final String text;
  final Set<int> selectedTags;
  final bool saved;
  final bool loading;
  final DateTime day;
  final String? message;

  const JournalState({
    this.moodIndex = 0,
    this.text = '',
    this.selectedTags = const {},
    this.saved = false,
    this.loading = true,
    required this.day,
    this.message,
  });

  JournalState copyWith({
    int? moodIndex,
    String? text,
    Set<int>? selectedTags,
    bool? saved,
    bool? loading,
    DateTime? day,
    String? message,
  }) {
    return JournalState(
      moodIndex: moodIndex ?? this.moodIndex,
      text: text ?? this.text,
      selectedTags: selectedTags ?? this.selectedTags,
      saved: saved ?? this.saved,
      loading: loading ?? this.loading,
      day: day ?? this.day,
      message: message,
    );
  }

  @override
  List<Object?> get props =>
      [moodIndex, text, selectedTags, saved, loading, day, message];
}
