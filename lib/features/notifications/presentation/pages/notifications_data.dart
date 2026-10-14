import 'package:flutter/material.dart';

/// Bildirim satırı modeli (kategori: System / Social / Reward).
class NotifData {
  final String title;
  final String body;
  final String time;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String? emoji;
  final String category;

  const NotifData({
    required this.title,
    required this.body,
    required this.time,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    this.emoji,
    required this.category,
  });
}

const notificationItems = [
  NotifData(
    title: 'Quest reminder',
    body: 'You forgot to drink water',
    time: '2 min ago',
    icon: Icons.emoji_events_rounded,
    iconColor: Color(0xFFF59E0B),
    iconBg: Color(0xFFFFF3D6),
    emoji: '💧',
    category: 'System',
  ),
  NotifData(
    title: 'Motivation',
    body: 'You can do it!',
    time: '1 hour ago',
    icon: Icons.favorite_rounded,
    iconColor: Color(0xFFF0608A),
    iconBg: Color(0xFFFFE0E8),
    emoji: '💖',
    category: 'System',
  ),
  NotifData(
    title: 'Pet sound',
    body: 'Lumi misses you!',
    time: '5 hours ago',
    icon: Icons.pets_rounded,
    iconColor: Color(0xFFE05C7A),
    iconBg: Color(0xFFFFE4E4),
    emoji: '🐾',
    category: 'Social',
  ),
  NotifData(
    title: 'Reward',
    body: 'You claimed your daily reward!',
    time: '1 day ago',
    icon: Icons.card_giftcard_rounded,
    iconColor: Color(0xFFF59E0B),
    iconBg: Color(0xFFFFF0C8),
    emoji: '🎁',
    category: 'Reward',
  ),
  NotifData(
    title: 'Friend',
    body: 'Ayşe visited your play area.',
    time: '1 day ago',
    icon: Icons.person_rounded,
    iconColor: Color(0xFFE05C5C),
    iconBg: Color(0xFFFFE0DC),
    emoji: '🎈',
    category: 'Social',
  ),
];

const notificationFilterLabels = ['All', 'System', 'Social', 'Reward'];

/// Okunmamışları filtreler; 0 = Tümü (okunmamış).
List<({int index, NotifData data})> filterNotifications(
  int filter,
  Set<int> read,
) {
  final all = notificationItems.indexed
      .map((e) => (index: e.$1, data: e.$2))
      .toList();
  final unread = all.where((e) => !read.contains(e.index)).toList();
  if (filter == 0) return unread;
  return unread
      .where((e) => e.data.category == notificationFilterLabels[filter])
      .toList();
}
