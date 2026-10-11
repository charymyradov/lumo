import 'package:equatable/equatable.dart';

abstract class OnboardingEvent extends Equatable {
  const OnboardingEvent();
  @override
  List<Object?> get props => [];
}

class OnboardingNameChanged extends OnboardingEvent {
  final String name;
  const OnboardingNameChanged(this.name);
  @override
  List<Object?> get props => [name];
}

/// Bir hedefi seçili değilse seçer, seçili ise seçimden kaldırır.
class OnboardingGoalToggled extends OnboardingEvent {
  final String goal;
  const OnboardingGoalToggled(this.goal);
  @override
  List<Object?> get props => [goal];
}

class OnboardingMascotSelected extends OnboardingEvent {
  final int mascotIndex;
  const OnboardingMascotSelected(this.mascotIndex);
  @override
  List<Object?> get props => [mascotIndex];
}

class OnboardingNextPage extends OnboardingEvent {
  const OnboardingNextPage();
}

class OnboardingPrevPage extends OnboardingEvent {
  const OnboardingPrevPage();
}

class OnboardingCompleted extends OnboardingEvent {
  const OnboardingCompleted();
}
