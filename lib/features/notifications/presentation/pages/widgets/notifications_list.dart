import 'package:flutter/material.dart';
import 'package:lumo/features/notifications/presentation/pages/notifications_data.dart';
import 'package:lumo/features/notifications/presentation/widgets/notification_tile.dart';

/// Kaydırarak okundu işaretlenebilen bildirim listesi.
class NotificationsList extends StatelessWidget {
  final List<({int index, NotifData data})> entries;
  final ValueChanged<int> onDismissed;

  const NotificationsList({
    super.key,
    required this.entries,
    required this.onDismissed,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: entries.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final entry = entries[i];
        final n = entry.data;
        return Dismissible(
          key: ValueKey('notif_${entry.index}'),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: const Color(0xFF22C55E),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.check_rounded, color: Colors.white),
          ),
          onDismissed: (_) => onDismissed(entry.index),
          child: NotificationTile(
            title: n.title,
            body: n.body,
            timeAgo: n.time,
            icon: n.icon,
            iconColor: n.iconColor,
            iconBg: n.iconBg,
            emoji: n.emoji,
          ),
        );
      },
    );
  }
}
