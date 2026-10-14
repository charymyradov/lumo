import 'package:equatable/equatable.dart';

abstract class JournalEvent extends Equatable {
  const JournalEvent();
  @override
  List<Object?> get props => [];
}

class JournalLoadRequested extends JournalEvent {
  final DateTime? day;
  const JournalLoadRequested([this.day]);
}

class JournalMoodChanged extends JournalEvent {
  final int index;
  const JournalMoodChanged(this.index);
  @override
  List<Object?> get props => [index];
}

class JournalTextChanged extends JournalEvent {
  final String text;
  const JournalTextChanged(this.text);
  @override
  List<Object?> get props => [text];
}

class JournalTagToggled extends JournalEvent {
  final int index;
  const JournalTagToggled(this.index);
  @override
  List<Object?> get props => [index];
}

class JournalDayPicked extends JournalEvent {
  final DateTime day;
  const JournalDayPicked(this.day);
  @override
  List<Object?> get props => [day];
}

class JournalSaveRequested extends JournalEvent {
  const JournalSaveRequested();
}
