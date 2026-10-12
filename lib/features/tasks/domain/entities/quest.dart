import 'package:equatable/equatable.dart';

/// AI (veya yedek liste) tarafından üretilmiş tek görev.
/// [category]: water | move | breath | mind | journal | sport | social |
/// health | sleep — ikon/renk eşlemesi `quest_visuals.dart` içinde.
class Quest extends Equatable {
  final String id;
  final String title;
  final String subtitle;
  final int reward;
  final String duration;
  final String category;

  const Quest({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.reward,
    required this.duration,
    required this.category,
  });

  @override
  List<Object?> get props => [id, title, subtitle, reward, duration, category];
}

/// Günlük + haftalık görev demeti ve nereden geldiği.
enum QuestSource { fresh, cache, fallback }

class QuestBundle extends Equatable {
  final List<Quest> daily;
  final List<Quest> weekly;
  final QuestSource source;
  final DateTime fetchedAt;

  const QuestBundle({
    required this.daily,
    required this.weekly,
    required this.source,
    required this.fetchedAt,
  });

  @override
  List<Object?> get props => [daily, weekly, source, fetchedAt];
}
