import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lumo/core/repositories/progress_repositories.dart';
import 'package:lumo/core/repositories/user_profile_repository.dart';
import 'package:lumo/core/repositories/wallet_repository.dart';
import 'package:lumo/features/home/presentation/bloc/home_event.dart';
import 'package:lumo/features/home/presentation/bloc/home_state.dart';

/// Home veri durumu — tüm etkileşim Event ile.
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc({
    required UserProfileRepository profileRepository,
    required PetVitalsRepository vitalsRepository,
    required WalletRepository walletRepository,
  })  : _profiles = profileRepository,
        _vitals = vitalsRepository,
        _wallet = walletRepository,
        super(const HomeState()) {
    on<HomeLoadRequested>(_onLoad);
    on<HomeWalletRefreshRequested>(_onWallet);
    on<HomeCareApplied>(_onCare);
    on<HomeVitalPulse>(_onPulse);
  }

  final UserProfileRepository _profiles;
  final PetVitalsRepository _vitals;
  final WalletRepository _wallet;

  Future<void> _onLoad(HomeLoadRequested event, Emitter<HomeState> emit) async {
    emit(state.copyWith(loading: true));
    final profile = await _profiles.load();
    final v = await _vitals.load();
    final w = await _wallet.load();
    emit(state.copyWith(
      userName: profile.name,
      speciesId: profile.speciesId,
      hunger: v.hunger,
      hydration: v.water,
      happiness: v.happy,
      energy: v.energy,
      coins: w.coins,
      xp: w.xp,
      level: w.level,
      loading: false,
    ));
  }

  Future<void> _onWallet(
      HomeWalletRefreshRequested event, Emitter<HomeState> emit) async {
    final w = await _wallet.load();
    emit(state.copyWith(coins: w.coins, xp: w.xp, level: w.level));
  }

  Future<void> _onCare(HomeCareApplied event, Emitter<HomeState> emit) async {
    emit(state.copyWith(
      hunger: (state.hunger + event.hunger).clamp(0.0, 1.0),
      hydration: (state.hydration + event.hydration).clamp(0.0, 1.0),
      happiness: (state.happiness + event.happiness).clamp(0.0, 1.0),
      energy: (state.energy + event.energy).clamp(0.0, 1.0),
    ));
    await _vitals.save(
        state.hunger, state.hydration, state.happiness, state.energy);
    final r = await _wallet.addXp(2);
    final w = await _wallet.load();
    emit(state.copyWith(level: r.level, xp: r.xp, coins: w.coins));
  }

  Future<void> _onPulse(HomeVitalPulse event, Emitter<HomeState> emit) async {
    if (event.sleeping) {
      emit(state.copyWith(
        energy: (state.energy + 0.15).clamp(0.0, 1.0),
        hunger: (state.hunger + 0.02).clamp(0.0, 1.0),
        hydration: (state.hydration - 0.015).clamp(0.0, 1.0),
        happiness: (state.happiness - 0.01).clamp(0.0, 1.0),
      ));
    } else {
      emit(state.copyWith(
        hunger: (state.hunger + 0.04).clamp(0.0, 1.0),
        hydration: (state.hydration - 0.03).clamp(0.0, 1.0),
        energy: (state.energy - 0.015).clamp(0.0, 1.0),
        happiness: (state.happiness - 0.02).clamp(0.0, 1.0),
      ));
    }
    await _vitals.save(
        state.hunger, state.hydration, state.happiness, state.energy);
  }
}
