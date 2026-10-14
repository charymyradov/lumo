import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lumo/core/repositories/wallet_repository.dart';
import 'package:lumo/features/breathing/presentation/bloc/breathing_event.dart';
import 'package:lumo/features/breathing/presentation/bloc/breathing_state.dart';

/// Nefes oturum ödülü — Event ile tetiklenir.
class BreathingBloc extends Bloc<BreathingEvent, BreathingState> {
  BreathingBloc({required WalletRepository walletRepository})
      : _wallet = walletRepository,
        super(const BreathingState()) {
    on<BreathingSessionCompleted>(_onComplete);
    on<BreathingReset>((event, emit) => emit(const BreathingState()));
  }

  final WalletRepository _wallet;

  Future<void> _onComplete(
      BreathingSessionCompleted event, Emitter<BreathingState> emit) async {
    await _wallet.addCoins(15);
    await _wallet.addXp(8);
    emit(const BreathingState(sessionDone: true));
  }
}
