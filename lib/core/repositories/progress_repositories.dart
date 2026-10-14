/// Günlük kayıt + görev tamamlama + pet vitals için soyut kontratlar.
/// Static `*Store` sınıflarının yerine geçer — testte fake'lenebilir.
abstract class JournalRepository {
  Future<({int moodIndex, String text, List<String> tags})> load(DateTime day);
  Future<void> save({
    required DateTime day,
    required int moodIndex,
    required String text,
    required List<String> tags,
  });
}

abstract class TaskCompletionRepository {
  Future<Set<String>> load(DateTime day);
  Future<void> save(DateTime day, Set<String> ids);
}

abstract class PetVitalsRepository {
  Future<({double hunger, double water, double happy, double energy})> load();
  Future<void> save(double hunger, double water, double happy, double energy);
}
