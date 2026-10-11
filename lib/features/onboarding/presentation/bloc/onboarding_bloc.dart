import 'package:flutter_bloc/flutter_bloc.dart';
import 'onboarding_event.dart';
import 'onboarding_state.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  static const int totalPages = 4; // welcome, goal, mascot, permissions

  OnboardingBloc() : super(const OnboardingState()) {
    on<OnboardingNameChanged>(_onNameChanged);
    on<OnboardingGoalToggled>(_onGoalToggled);
    on<OnboardingMascotSelected>(_onMascotSelected);
    on<OnboardingNextPage>(_onNextPage);
    on<OnboardingPrevPage>(_onPrevPage);
    on<OnboardingCompleted>(_onCompleted);
  }

  void _onNameChanged(
      OnboardingNameChanged event, Emitter<OnboardingState> emit) {
    emit(state.copyWith(name: event.name));
  }

  void _onGoalToggled(
      OnboardingGoalToggled event, Emitter<OnboardingState> emit) {
    final goals = List<String>.from(state.selectedGoals);
    if (goals.contains(event.goal)) {
      goals.remove(event.goal);
    } else {
      goals.add(event.goal);
    }
    emit(state.copyWith(selectedGoals: goals));
  }

  void _onMascotSelected(
      OnboardingMascotSelected event, Emitter<OnboardingState> emit) {
    emit(state.copyWith(selectedMascotIndex: event.mascotIndex));
  }

  void _onNextPage(OnboardingNextPage event, Emitter<OnboardingState> emit) {
    if (state.currentPage < totalPages - 1) {
      emit(state.copyWith(currentPage: state.currentPage + 1));
    }
  }

  void _onPrevPage(OnboardingPrevPage event, Emitter<OnboardingState> emit) {
    if (state.currentPage > 0) {
      emit(state.copyWith(currentPage: state.currentPage - 1));
    }
  }

  void _onCompleted(OnboardingCompleted event, Emitter<OnboardingState> emit) {
    emit(state.copyWith(isCompleted: true));
  }
}
