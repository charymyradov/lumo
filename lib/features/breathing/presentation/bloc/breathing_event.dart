import 'package:equatable/equatable.dart';

abstract class BreathingEvent extends Equatable {
  const BreathingEvent();
  @override
  List<Object?> get props => [];
}

class BreathingSessionCompleted extends BreathingEvent {
  const BreathingSessionCompleted();
}

class BreathingReset extends BreathingEvent {
  const BreathingReset();
}
