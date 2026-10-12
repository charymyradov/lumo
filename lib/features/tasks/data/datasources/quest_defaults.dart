import 'package:lumo/features/tasks/domain/entities/quest.dart';

/// API anahtarı yokken / çevrimdışıyken gösterilen yerleşik liste.
/// Uygulama bu liste sayesinde AI olmadan da tam çalışır.
QuestBundle fallbackQuestBundle() {
  Quest q(
    String id,
    String title,
    String subtitle,
    int reward,
    String duration,
    String category,
  ) =>
      Quest(
        id: id,
        title: title,
        subtitle: subtitle,
        reward: reward,
        duration: duration,
        category: category,
      );

  return QuestBundle(
    daily: [
      q('fb_d0', 'Su iç', 'Sağlığın için su iç.', 10, '1 dk', 'water'),
      q('fb_d1', '10.000 adım at', 'Hareket et, enerjini artır.', 20,
          '20 dk', 'move'),
      q('fb_d2', 'Nefes egzersizi yap', 'Sakinleş ve odaklan.', 15, '5 dk',
          'breath'),
      q('fb_d3', 'Günlük yaz', 'Düşüncelerini paylaş.', 25, '10 dk',
          'journal'),
    ],
    weekly: [
      q('fb_w0', '5 gün arka arkaya spor yap', 'Haftalık hedefine ulaş.', 60,
          '5 gün', 'sport'),
      q('fb_w1', '3 kez nefes seansı tamamla', 'Zihnini dinlendir.', 40,
          '3 seans', 'mind'),
      q('fb_w2', 'Haftalık hedef yaz',
          'Kendin için bir hedef belirle.', 35, '15 dk', 'social'),
    ],
    source: QuestSource.fallback,
    fetchedAt: DateTime.now(),
  );
}
