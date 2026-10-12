import 'package:lumo/features/tasks/domain/entities/quest.dart';

/// Gemini'den dönen ham JSON'u [Quest]'e çevirir.
/// Eksik/bozuk alanlarda mantıklı varsayılanlar kullanılır — AI çıktısı
/// uygulamayı asla çökertmemeli.
class QuestModel extends Quest {
  const QuestModel({
    required super.id,
    required super.title,
    required super.subtitle,
    required super.reward,
    required super.duration,
    required super.category,
  });

  factory QuestModel.fromJson(Map<String, dynamic> json, String fallbackId) {
    final title = (json['title'] as String? ?? '').trim();
    if (title.isEmpty) {
      throw const FormatException('Quest başlığı boş');
    }
    final rawReward = json['reward'];
    final reward = switch (rawReward) {
      int v => v,
      double v => v.round(),
      String v => int.tryParse(v) ?? 15,
      _ => 15,
    };
    return QuestModel(
      id: (json['id'] as String?)?.trim().isNotEmpty == true
          ? (json['id'] as String).trim()
          : fallbackId,
      title: title.length > 48 ? '${title.substring(0, 47)}…' : title,
      subtitle: ((json['subtitle'] as String?) ?? '').trim(),
      reward: reward.clamp(5, 100),
      duration: ((json['duration'] as String?) ?? '10 dk').trim(),
      category: _normalizeCategory(json['category'] as String?),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'subtitle': subtitle,
        'reward': reward,
        'duration': duration,
        'category': category,
      };

  static String _normalizeCategory(String? raw) {
    const allowed = {
      'water',
      'move',
      'breath',
      'mind',
      'journal',
      'sport',
      'social',
      'health',
      'sleep',
    };
    final v = (raw ?? '').trim().toLowerCase();
    return allowed.contains(v) ? v : 'health';
  }
}
