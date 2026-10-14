import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lumo/core/repositories/progress_repositories.dart';
import 'package:lumo/core/repositories/progress_repositories_impl.dart';
import 'package:lumo/core/repositories/user_profile_repository.dart';
import 'package:lumo/core/repositories/user_profile_repository_impl.dart';
import 'package:lumo/core/repositories/wallet_repository.dart';
import 'package:lumo/core/repositories/wallet_repository_impl.dart';
import 'package:lumo/features/breathing/presentation/bloc/breathing_bloc.dart';
import 'package:lumo/features/home/presentation/bloc/home_bloc.dart';
import 'package:lumo/features/journal/presentation/bloc/journal_bloc.dart';
import 'package:lumo/features/shop/presentation/bloc/shop_bloc.dart';
import 'package:lumo/features/tasks/data/datasources/quest_remote_datasource.dart';
import 'package:lumo/features/tasks/data/repositories/quest_repository_impl.dart';
import 'package:lumo/features/tasks/domain/repositories/quest_repository.dart';
import 'package:lumo/features/tasks/domain/usecases/get_ai_quests.dart';
import 'package:lumo/features/tasks/presentation/bloc/quest_bloc.dart';

/// Service locator — tüm state yönetimi Bloc (Event/State) ile.
final sl = GetIt.instance;

Future<void> configureDependencies() async {
  final prefs = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(prefs);

  // Core repositories (eski static *Store'ların yerine).
  sl.registerLazySingleton<WalletRepository>(
    () => WalletRepositoryImpl(prefs: sl<SharedPreferences>()),
  );
  sl.registerLazySingleton<JournalRepository>(
    () => JournalRepositoryImpl(prefs: sl<SharedPreferences>()),
  );
  sl.registerLazySingleton<TaskCompletionRepository>(
    () => TaskCompletionRepositoryImpl(prefs: sl<SharedPreferences>()),
  );
  sl.registerLazySingleton<PetVitalsRepository>(
    () => PetVitalsRepositoryImpl(prefs: sl<SharedPreferences>()),
  );
  sl.registerLazySingleton<UserProfileRepository>(
    () => UserProfileRepositoryImpl(prefs: sl<SharedPreferences>()),
  );

  sl.registerLazySingleton<QuestRemoteDataSource>(
    () => QuestRemoteDataSource(),
  );
  sl.registerLazySingleton<QuestRepository>(
    () => QuestRepositoryImpl(
      remote: sl<QuestRemoteDataSource>(),
      prefs: sl<SharedPreferences>(),
    ),
  );
  sl.registerLazySingleton<GetAiQuests>(
    () => GetAiQuests(sl<QuestRepository>()),
  );
  sl.registerFactory<QuestBloc>(
    () => QuestBloc(
      getAiQuests: sl<GetAiQuests>(),
      profileRepository: sl<UserProfileRepository>(),
      completionRepository: sl<TaskCompletionRepository>(),
      walletRepository: sl<WalletRepository>(),
    ),
  );
  sl.registerFactory<JournalBloc>(
    () => JournalBloc(
      journalRepository: sl<JournalRepository>(),
      walletRepository: sl<WalletRepository>(),
    ),
  );
  sl.registerFactory<ShopBloc>(
    () => ShopBloc(walletRepository: sl<WalletRepository>()),
  );
  sl.registerFactory<HomeBloc>(
    () => HomeBloc(
      profileRepository: sl<UserProfileRepository>(),
      vitalsRepository: sl<PetVitalsRepository>(),
      walletRepository: sl<WalletRepository>(),
    ),
  );
  sl.registerFactory<BreathingBloc>(
    () => BreathingBloc(walletRepository: sl<WalletRepository>()),
  );
}
