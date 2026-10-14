import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lumo/core/repositories/progress_repositories.dart';
import 'package:lumo/core/repositories/wallet_repository.dart';
import 'package:lumo/features/journal/presentation/bloc/journal_event.dart';
import 'package:lumo/features/journal/presentation/bloc/journal_state.dart';

/// Journal iş mantığı — tüm etkileşim Event ile.
class JournalBloc extends Bloc<JournalEvent, JournalState> {
  JournalBloc({
    required JournalRepository journalRepository,
    required WalletRepository walletRepository,
  })  : _journal = journalRepository,
        _wallet = walletRepository,
        super(JournalState(day: DateTime.now())) {
    on<JournalLoadRequested>(_onLoad);
    on<JournalMoodChanged>(_onMood);
    on<JournalTextChanged>(_onText);
    on<JournalTagToggled>(_onTag);
    on<JournalDayPicked>(_onDay);
    on<JournalSaveRequested>(_onSave);
  }

  final JournalRepository _journal;
  final WalletRepository _wallet;

  static const tagIds = [
    'gratitude',
    'health',
    'family',
    'sleep',
    'focus',
    'calm'
  ];
  static const tags = [
    '#gratitude',
    '#health',
    '#family',
    '#sleep',
    '#focus',
    '#calm'
  ];

  Future<void> _onLoad(
      JournalLoadRequested event, Emitter<JournalState> emit) async {
    final d = event.day ?? state.day;
    emit(state.copyWith(day: d, loading: true, saved: false));
    final data = await _journal.load(d);
    emit(state.copyWith(
      moodIndex: data.moodIndex.clamp(0, 4),
      text: data.text,
      selectedTags: data.tags.map(tagIds.indexOf).where((i) => i >= 0).toSet(),
      saved: data.text.isNotEmpty,
      loading: false,
    ));
  }

  void _onMood(JournalMoodChanged event, Emitter<JournalState> emit) =>
      emit(state.copyWith(moodIndex: event.index, saved: false));

  void _onText(JournalTextChanged event, Emitter<JournalState> emit) =>
      emit(state.copyWith(text: event.text, saved: false));

  void _onTag(JournalTagToggled event, Emitter<JournalState> emit) {
    final s = Set<int>.of(state.selectedTags);
    if (!s.add(event.index)) s.remove(event.index);
    emit(state.copyWith(selectedTags: s, saved: false));
  }

  Future<void> _onDay(
      JournalDayPicked event, Emitter<JournalState> emit) async {
    add(JournalLoadRequested(event.day));
  }

  Future<void> _onSave(
      JournalSaveRequested event, Emitter<JournalState> emit) async {
    final tagList = state.selectedTags.map((i) => tagIds[i]).toList();
    await _journal.save(
      day: state.day,
      moodIndex: state.moodIndex,
      text: state.text.trim(),
      tags: tagList,
    );
    final wasSaved = state.saved;
    if (!wasSaved) {
      await _wallet.addCoins(10);
      await _wallet.addXp(5);
    }
    emit(state.copyWith(
        saved: true,
        message: wasSaved ? 'Journal updated ✓' : 'Saved ✓  +10 coins'));
  }

  /// Saf içgörü metni — state'ten türetilir, event değildir.
  static String insightFor(JournalState s) {
    final text = s.text.trim();
    const moods = ['tired', 'okay', 'good', 'great', 'radiant'];
    final mood = moods[s.moodIndex.clamp(0, moods.length - 1)];
    if (text.isEmpty) {
      return 'You marked today as "$mood". Write a sentence or two above — even a small note helps tomorrow\'s insight get sharper.';
    }
    if (text.length < 30) {
      return 'Thanks for checking in as "$mood". A little more detail (what helped / what drained you) would unlock a deeper pattern next time.';
    }
    final tagText = s.selectedTags.isEmpty
        ? ''
        : ' Your tags (${s.selectedTags.map((i) => tags[i]).join(', ')}) show what mattered most.';
    return 'You\'re being kind to yourself today with a "$mood" mood.$tagText Keep this rhythm — small notes compound into real self-knowledge.';
  }
}
