import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lumo/core/constants/ai_config.dart';
import 'package:lumo/core/error/exceptions.dart';
import 'package:lumo/core/error/failures.dart';
import 'package:lumo/features/tasks/data/datasources/quest_defaults.dart';
import 'package:lumo/features/tasks/data/datasources/quest_remote_datasource.dart';
import 'package:lumo/features/tasks/data/models/quest_model.dart';
import 'package:lumo/features/tasks/domain/entities/quest.dart';
import 'package:lumo/features/tasks/domain/repositories/quest_repository.dart';

/// Politika:
/// * Bugünkü önbellek varsa ağa gitmeden onu döndür (hızlı açılış, kota dostu).
/// * Anahtar varsa ve (önbellek bayat / [forceRefresh]) ise AI'dan tazele.
/// * Ağ patlarsa bayat önbellek, o da yoksa yerleşik liste — ekran asla boş kalmaz.
class QuestRepositoryImpl implements QuestRepository {
  final QuestRemoteDataSource _remote;
  final SharedPreferences _prefs;

  QuestRepositoryImpl(
      {QuestRemoteDataSource? remote, required SharedPreferences prefs})
      : _remote = remote ?? QuestRemoteDataSource(),
        _prefs = prefs;

  static const _kJson = 'ai_quests_json_v1';
  static const _kDate = 'ai_quests_date_v1';

  @override
  Future<QuestBundle> getQuests(
      {bool forceRefresh = false,
      String promptContext = '',
      String profileKey = ''}) async {
    final cached = _readCache();
    final profileChanged = cached != null &&
        profileKey.isNotEmpty &&
        _cacheProfileKey() != profileKey;

    if (!forceRefresh &&
        !profileChanged &&
        cached != null &&
        _isToday(cached.fetchedAt)) {
      return cached;
    }

    // Anahtar yok: önbellek varsa onu, yoksa yerleşik listeyi göster.
    if (!AiConfig.hasGeminiKey) {
      return cached ?? fallbackQuestBundle();
    }

    try {
      final fresh = await _remote.fetchQuests(promptContext: promptContext);
      await _writeCache(fresh, profileKey);
      return fresh;
    } on MissingApiKeyException catch (e) {
      debugPrint('QuestRepository: ${failureFromException(e).message}');
      return cached ?? fallbackQuestBundle();
    } on ServerException catch (e) {
      final Failure failure = failureFromException(e);
      debugPrint('QuestRepository: ${failure.message}');
      if (cached != null) {
        return QuestBundle(
          daily: cached.daily,
          weekly: cached.weekly,
          source: QuestSource.cache,
          fetchedAt: cached.fetchedAt,
        );
      }
      final fb = fallbackQuestBundle();
      return QuestBundle(
        daily: fb.daily,
        weekly: fb.weekly,
        source: QuestSource.fallback,
        fetchedAt: fb.fetchedAt,
      );
    } on CacheException catch (e) {
      debugPrint('QuestRepository: ${failureFromException(e).message}');
      return cached ?? fallbackQuestBundle();
    }
  }

  bool _isToday(DateTime dt) {
    final now = DateTime.now();
    return dt.year == now.year && dt.month == now.month && dt.day == now.day;
  }

  QuestBundle? _readCache() {
    try {
      final raw = _prefs.getString(_kJson);
      if (raw == null || raw.isEmpty) return null;
      final map = jsonDecode(raw) as Map<String, dynamic>;
      List<Quest> list(dynamic v, String type) {
        if (v is! List) return [];
        return [
          for (var i = 0; i < v.length; i++)
            if (v[i] is Map<String, dynamic>)
              QuestModel.fromJson(
                  Map<String, dynamic>.from(v[i] as Map), '${type}_$i'),
        ];
      }

      return QuestBundle(
        daily: list(map['daily'], 'daily'),
        weekly: list(map['weekly'], 'weekly'),
        source: QuestSource.cache,
        fetchedAt: DateTime.tryParse(map['fetchedAt'] as String? ?? '') ??
            DateTime.now(),
      );
    } catch (_) {
      return null;
    }
  }

  String _cacheProfileKey() {
    try {
      final raw = _prefs.getString(_kJson);
      if (raw == null || raw.isEmpty) return '';
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return map['profileKey'] as String? ?? '';
    } catch (_) {
      return '';
    }
  }

  Future<void> _writeCache(QuestBundle bundle, String profileKey) async {
    try {
      await _prefs.setString(
        _kJson,
        jsonEncode({
          'daily': [
            for (final q in bundle.daily)
              QuestModel(
                id: q.id,
                title: q.title,
                subtitle: q.subtitle,
                reward: q.reward,
                duration: q.duration,
                category: q.category,
              ).toJson(),
          ],
          'weekly': [
            for (final q in bundle.weekly)
              QuestModel(
                id: q.id,
                title: q.title,
                subtitle: q.subtitle,
                reward: q.reward,
                duration: q.duration,
                category: q.category,
              ).toJson(),
          ],
          'fetchedAt': bundle.fetchedAt.toIso8601String(),
          'profileKey': profileKey,
        }),
      );
      await _prefs.setString(_kDate, DateTime.now().toIso8601String());
    } catch (_) {
      throw const CacheException('Could not write quest cache');
    }
  }
}
