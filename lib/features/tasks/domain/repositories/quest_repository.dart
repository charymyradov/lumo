import 'package:lumo/features/tasks/domain/entities/quest.dart';

/// Günlük + haftalık AI görevleri.
/// [forceRefresh] true ise önbelleğe bakılmadan ağa gidilir.
/// [profileKey] değişmişse (isim/hedef/maskot güncellendiyse) günlük
/// önbellek geçersiz sayılır ve taze liste çekilir.
abstract class QuestRepository {
  Future<QuestBundle> getQuests(
      {bool forceRefresh = false, String context = '', String profileKey = ''});
}
