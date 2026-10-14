import 'package:shared_preferences/shared_preferences.dart';
import 'package:lumo/core/repositories/progress_repositories.dart';
import 'package:lumo/core/services/progress_store.dart';

/// Repository cepheleri — kalıcılık mantığının tek sahibi `*Store`
/// sınıflarıdır (enjekte edilen [_prefs] Store'a aktarılır).
class JournalRepositoryImpl implements JournalRepository {
  final SharedPreferences _prefs;
  JournalRepositoryImpl({required SharedPreferences prefs}) : _prefs = prefs;

  @override
  Future<({int moodIndex, String text, List<String> tags})> load(DateTime day) {
    return JournalStore.load(day, _prefs);
  }

  @override
  Future<void> save({
    required DateTime day,
    required int moodIndex,
    required String text,
    required List<String> tags,
  }) {
    return JournalStore.save(
      day: day,
      moodIndex: moodIndex,
      text: text,
      tags: tags,
      prefs: _prefs,
    );
  }
}

class TaskCompletionRepositoryImpl implements TaskCompletionRepository {
  final SharedPreferences _prefs;
  TaskCompletionRepositoryImpl({required SharedPreferences prefs})
      : _prefs = prefs;

  @override
  Future<Set<String>> load(DateTime day) {
    return TaskCompletionStore.load(day, _prefs);
  }

  @override
  Future<void> save(DateTime day, Set<String> ids) {
    return TaskCompletionStore.save(day, ids, _prefs);
  }
}

class PetVitalsRepositoryImpl implements PetVitalsRepository {
  final SharedPreferences _prefs;
  PetVitalsRepositoryImpl({required SharedPreferences prefs}) : _prefs = prefs;

  @override
  Future<({double hunger, double water, double happy, double energy})>
      load() async {
    final v = await PetVitalsStore.load(_prefs);
    return (hunger: v.$1, water: v.$2, happy: v.$3, energy: v.$4);
  }

  @override
  Future<void> save(double hunger, double water, double happy, double energy) {
    return PetVitalsStore.save(hunger, water, happy, energy, _prefs);
  }
}
