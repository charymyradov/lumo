import 'package:equatable/equatable.dart';

enum PetMood {
  joyful,
  playful,
  sleepy,
  hungry,
  thirsty,
  tired,
  calm,
  needy,
}

/// Vitals'tan mood çıkaran saf fonksiyon — test edilebilir.
PetMood resolvePetMood({
  required double hunger,
  required double hydration,
  required double happiness,
  required double energy,
}) {
  if (energy < 0.12) return PetMood.sleepy;
  if (hunger > 0.82) return PetMood.hungry;
  if (hydration < 0.25) return PetMood.thirsty;
  if (happiness < 0.28) return PetMood.needy;
  if (energy < 0.45) return PetMood.tired;
  if (happiness > 0.82 && energy > 0.5) return PetMood.playful;
  if (happiness > 0.6) return PetMood.joyful;
  return PetMood.calm;
}

class HomeState extends Equatable {
  final String userName;
  final String speciesId;
  final double hunger;
  final double hydration;
  final double happiness;
  final double energy;
  final int coins;
  final int level;
  final int xp;
  final bool loading;

  const HomeState({
    this.userName = '',
    this.speciesId = 'fox',
    this.hunger = 0.84,
    this.hydration = 0.78,
    this.happiness = 0.92,
    this.energy = 0.88,
    this.coins = 0,
    this.level = 5,
    this.xp = 0,
    this.loading = true,
  });

  PetMood get mood => resolvePetMood(
        hunger: hunger,
        hydration: hydration,
        happiness: happiness,
        energy: energy,
      );

  HomeState copyWith({
    String? userName,
    String? speciesId,
    double? hunger,
    double? hydration,
    double? happiness,
    double? energy,
    int? coins,
    int? level,
    int? xp,
    bool? loading,
  }) {
    return HomeState(
      userName: userName ?? this.userName,
      speciesId: speciesId ?? this.speciesId,
      hunger: hunger ?? this.hunger,
      hydration: hydration ?? this.hydration,
      happiness: happiness ?? this.happiness,
      energy: energy ?? this.energy,
      coins: coins ?? this.coins,
      level: level ?? this.level,
      xp: xp ?? this.xp,
      loading: loading ?? this.loading,
    );
  }

  @override
  List<Object?> get props => [
        userName,
        speciesId,
        hunger,
        hydration,
        happiness,
        energy,
        coins,
        level,
        xp,
        loading
      ];
}
