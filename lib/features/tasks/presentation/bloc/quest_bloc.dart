import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lumo/core/constants/ai_config.dart';
import 'package:lumo/core/error/failures.dart';
import 'package:lumo/core/repositories/progress_repositories.dart';
import 'package:lumo/core/repositories/user_profile_repository.dart';
import 'package:lumo/core/repositories/wallet_repository.dart';
import 'package:lumo/core/services/progress_store.dart';
import 'package:lumo/core/services/user_profile_store.dart';
import 'package:lumo/core/services/wallet_store.dart';
import 'package:lumo/features/tasks/data/repositories/quest_repository_impl.dart';
import 'package:lumo/features/tasks/domain/entities/quest.dart';
import 'package:lumo/features/tasks/domain/usecases/get_ai_quests.dart';
import 'package:lumo/features/tasks/presentation/bloc/quest_event.dart';
import 'package:lumo/features/tasks/presentation/bloc/quest_state.dart';

/// AI görev listesi + tamamlama ekonomisi.
/// Tüm etkileşim Event ile — eski `load()/refresh()/toggleTask()`
/// metodları yerine `QuestLoadRequested/QuestRefreshRequested/QuestTaskToggled`.
class QuestBloc extends Bloc<QuestEvent, QuestState> {
  QuestBloc({
    GetAiQuests? getAiQuests,
    UserProfileRepository? profileRepository,
    TaskCompletionRepository? completionRepository,
    WalletRepository? walletRepository,
  }) : super(const QuestInitial()) {
    _useCase = getAiQuests;
    _profileRepo = profileRepository;
    _completionRepo = completionRepository;
    _walletRepo = walletRepository;
    on<QuestLoadRequested>(_onLoad);
    on<QuestRefreshRequested>(_onRefresh);
    on<QuestTaskToggled>(_onToggle);
  }

  GetAiQuests? _useCase;
  UserProfileRepository? _profileRepo;
  TaskCompletionRepository? _completionRepo;
  WalletRepository? _walletRepo;

  Set<String> _completedIds = {};

  Future<void> _ensureDeps() async {
    if (_useCase != null &&
        _profileRepo != null &&
        _completionRepo != null &&
        _walletRepo != null) {
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    _useCase ??= GetAiQuests(QuestRepositoryImpl(prefs: prefs));
    _profileRepo ??= _StaticProfileRepo();
    _completionRepo ??= _StaticCompletionRepo();
    _walletRepo ??= _StaticWalletRepo();
  }

  Future<void> _onLoad(
      QuestLoadRequested event, Emitter<QuestState> emit) async {
    emit(const QuestLoading());
    try {
      await _ensureDeps();
      _completedIds = await _completionRepo!.load(DateTime.now());
      final profile = await _profileRepo!.load();
      final bundle = await _useCase!.call(
        promptContext: profile.questContext(),
        profileKey: profile.profileKey,
      );
      emit(QuestLoaded(bundle,
          notice: _noticeFor(bundle), completedIds: Set.of(_completedIds)));
    } catch (e) {
      final current =
          state is QuestLoaded ? (state as QuestLoaded).bundle : null;
      final stale =
          state is QuestLoading ? (state as QuestLoading).current : current;
      emit(QuestError(failureFromException(e).message, stale));
    }
  }

  Future<void> _onRefresh(
      QuestRefreshRequested event, Emitter<QuestState> emit) async {
    final current = state is QuestLoaded ? (state as QuestLoaded).bundle : null;
    final stale = state is QuestError ? (state as QuestError).current : current;
    try {
      await _ensureDeps();
      if (stale != null) emit(QuestLoading(stale));
      final profile = await _profileRepo!.load();
      final bundle = await _useCase!.call(
        forceRefresh: true,
        promptContext: profile.questContext(),
        profileKey: profile.profileKey,
      );
      _completedIds = await _completionRepo!.load(DateTime.now());
      emit(QuestLoaded(bundle,
          notice: _noticeFor(bundle), completedIds: Set.of(_completedIds)));
    } catch (e) {
      emit(QuestError(failureFromException(e).message, stale));
    }
  }

  Future<void> _onToggle(
      QuestTaskToggled event, Emitter<QuestState> emit) async {
    await _ensureDeps();
    final task = event.task;
    final alreadyDone = _completedIds.contains(task.id);
    if (alreadyDone) {
      _completedIds = Set.of(_completedIds)..remove(task.id);
    } else {
      _completedIds = Set.of(_completedIds)..add(task.id);
    }
    await _completionRepo!.save(DateTime.now(), _completedIds);

    String? rewardMsg;
    if (!alreadyDone) {
      await _walletRepo!.addCoins(task.reward);
      await _walletRepo!.addXp(10);
      rewardMsg = '+${task.reward} coins · +10 XP — "${task.title}" done! 🎉';
    }

    final s = state;
    if (s is QuestLoaded) {
      emit(QuestLoaded(s.bundle,
          notice: s.notice,
          completedIds: Set.of(_completedIds),
          rewardMessage: rewardMsg));
    }
  }

  String? _noticeFor(QuestBundle bundle) {
    if (!AiConfig.hasGeminiKey && bundle.source == QuestSource.fallback) {
      return 'Quests will come from AI once an API key is added';
    }
    if (bundle.source == QuestSource.cache) {
      return 'Showing offline list';
    }
    return null;
  }
}

// --- Geriye uyumluluk shims ---
// DI kurulmamış bağlamlarda (test/önizleme) static Store'lara delege eder;
// anahtar/değer mantığının tek sahibi Store'lardır.
class _StaticProfileRepo implements UserProfileRepository {
  @override
  Future<UserProfile> load() => UserProfileStore.load();
  @override
  Future<void> save(
          {required String name,
          required List<String> goals,
          required int mascotIndex}) =>
      UserProfileStore.save(name: name, goals: goals, mascotIndex: mascotIndex);
}

class _StaticCompletionRepo implements TaskCompletionRepository {
  @override
  Future<Set<String>> load(DateTime day) => TaskCompletionStore.load(day);

  @override
  Future<void> save(DateTime day, Set<String> ids) =>
      TaskCompletionStore.save(day, ids);
}

class _StaticWalletRepo implements WalletRepository {
  @override
  Future<({int coins, int xp, int level, int streak})> load() async {
    final r = await WalletStore.load();
    return (coins: r.$1, xp: r.$2, level: r.$3, streak: r.$4);
  }

  @override
  Future<void> addCoins(int amount) => WalletStore.addCoins(amount);

  @override
  Future<({int level, int xp})> addXp(int amount) async {
    final r = await WalletStore.addXp(amount);
    return (level: r.$1, xp: r.$2);
  }

  @override
  Future<int> getCoins() => WalletStore.getCoins();

  @override
  Future<bool> isOwned(String id) => WalletStore.isOwned(id);

  @override
  Future<void> markOwned(String id) => WalletStore.markOwned(id);

  @override
  Future<List<String>> ownedItems() => WalletStore.ownedItems();

  @override
  Future<bool> spendCoins(int amount) => WalletStore.spendCoins(amount);
}
