import 'package:equatable/equatable.dart';

class OnboardingState extends Equatable {
  final int currentPage;
  final String name;
  final List<String> selectedGoals;
  final int selectedMascotIndex;
  final bool isCompleted;

  const OnboardingState({
    this.currentPage = 0,
    this.name = '',
    this.selectedGoals = const [],
    this.selectedMascotIndex = 0,
    this.isCompleted = false,
  });

  bool get hasSelectedGoals => selectedGoals.isNotEmpty;

  bool isGoalSelected(String goalId) => selectedGoals.contains(goalId);

  OnboardingState copyWith({
    int? currentPage,
    String? name,
    List<String>? selectedGoals,
    int? selectedMascotIndex,
    bool? isCompleted,
  }) {
    return OnboardingState(
      currentPage: currentPage ?? this.currentPage,
      name: name ?? this.name,
      selectedGoals: selectedGoals ?? this.selectedGoals,
      selectedMascotIndex: selectedMascotIndex ?? this.selectedMascotIndex,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  List<Object?> get props => [
        currentPage,
        name,
        selectedGoals,
        selectedMascotIndex,
        isCompleted,
      ];
}
