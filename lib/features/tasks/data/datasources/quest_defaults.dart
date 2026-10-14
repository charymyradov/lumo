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
      q('fb_d0', 'Drink water', 'Drink water for your health.', 10, '1 min',
          'water'),
      q('fb_d1', 'Walk 10,000 steps', 'Move around and boost your energy.', 20,
          '20 min', 'move'),
      q('fb_d2', 'Do a breathing exercise', 'Calm down and focus.', 15, '5 min',
          'breath'),
      q('fb_d3', 'Write in your journal', 'Share your thoughts.', 25, '10 min',
          'journal'),
    ],
    weekly: [
      q('fb_w0', 'Exercise 5 days in a row', 'Reach your weekly goal.', 60,
          '5 days', 'sport'),
      q('fb_w1', 'Complete 3 breathing sessions', 'Rest your mind.', 40,
          '3 sessions', 'mind'),
      q('fb_w2', 'Write a weekly goal', 'Set a goal for yourself.', 35,
          '15 min', 'social'),
    ],
    source: QuestSource.fallback,
    fetchedAt: DateTime.now(),
  );
}
