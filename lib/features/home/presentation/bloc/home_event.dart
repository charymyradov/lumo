import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();
  @override
  List<Object?> get props => [];
}

class HomeLoadRequested extends HomeEvent {
  const HomeLoadRequested();
}

class HomeWalletRefreshRequested extends HomeEvent {
  const HomeWalletRefreshRequested();
}

class HomeCareApplied extends HomeEvent {
  final double hunger;
  final double hydration;
  final double happiness;
  final double energy;
  const HomeCareApplied({
    this.hunger = 0,
    this.hydration = 0,
    this.happiness = 0,
    this.energy = 0,
  });
  @override
  List<Object?> get props => [hunger, hydration, happiness, energy];
}

class HomeVitalPulse extends HomeEvent {
  final bool sleeping;
  const HomeVitalPulse({required this.sleeping});
  @override
  List<Object?> get props => [sleeping];
}
