import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lumo/core/constants/ai_config.dart';
import 'package:lumo/core/services/user_profile_store.dart';
import 'package:lumo/features/tasks/data/repositories/quest_repository_impl.dart';
import 'package:lumo/features/tasks/domain/entities/quest.dart';
import 'package:lumo/features/tasks/domain/usecases/get_ai_quests.dart';
import 'package:lumo/features/tasks/presentation/cubit/quest_state.dart';

/// AI görev listesini yönetir. Bağımlılıkları tembel kurar —
/// sayfa `QuestCubit()..load()` ile tek satırda kullanır.
class QuestCubit extends Cubit<QuestState> {
  QuestCubit() : super(const QuestInitial());

  GetAiQuests? _useCase;
  bool _loading = false;

  Future<void> _ensureUseCase() async {
    if (_useCase != null) return;
    final prefs = await SharedPreferences.getInstance();
    _useCase = GetAiQuests(QuestRepositoryImpl(prefs: prefs));
  }

  /// İlk açılış: önbellek varsa anında göster, arka planda tazele.
  /// Kişiselleştirme (isim + hedefler + maskot) profilden alınır.
  Future<void> load() async {
    if (_loading) return;
    _loading = true;
    try {
      await _ensureUseCase();
      emit(const QuestLoading());
      final profile = await UserProfileStore.load();
      final bundle = await _useCase!.call(
        context: profile.questContext(),
        profileKey: profile.profileKey,
      );
      emit(QuestLoaded(bundle, notice: _noticeFor(bundle)));
    } catch (_) {
      // Repository zaten yedek listeye düşer; burası son güvenlik ağı.
      if (!isClosed) emit(const QuestLoading());
    } finally {
      _loading = false;
    }
  }

  /// Yenile butonu: zorunlu ağ isteği. Mevcut liste ekranda kalır.
  Future<void> refresh() async {
    if (_loading) return;
    final current =
        state is QuestLoaded ? (state as QuestLoaded).bundle : null;
    _loading = true;
    try {
      await _ensureUseCase();
      if (current != null) emit(QuestLoading(current));
      final profile = await UserProfileStore.load();
      final bundle = await _useCase!.call(
        forceRefresh: true,
        context: profile.questContext(),
        profileKey: profile.profileKey,
      );
      emit(QuestLoaded(bundle, notice: _noticeFor(bundle)));
    } catch (_) {
      if (current != null && !isClosed) {
        emit(QuestLoaded(current, notice: 'Bağlantı kurulamadı'));
      }
    } finally {
      _loading = false;
    }
  }

  String? _noticeFor(QuestBundle bundle) {
    if (!AiConfig.hasGeminiKey && bundle.source == QuestSource.fallback) {
      return 'API anahtarı eklenince görevler AI ile gelecek';
    }
    if (bundle.source == QuestSource.cache) {
      return 'Çevrimdışı liste gösteriliyor';
    }
    return null;
  }
}
