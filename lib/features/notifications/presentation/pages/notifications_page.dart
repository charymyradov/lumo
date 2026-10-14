import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:lumo/core/constants/app_text.dart';
import 'package:lumo/core/constants/app_colors.dart';
import 'package:lumo/core/constants/asset_paths.dart';
import 'package:lumo/features/notifications/presentation/widgets/notification_filter_tabs.dart';
import 'package:lumo/features/notifications/presentation/widgets/notification_tile.dart';
import 'package:lumo/shared/widgets/lumo_bottom_nav.dart';

class _NotifData {
  final String title;
  final String body;
  final String time;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String? emoji;
  final String category; // Sistem / Sosyal / Ödül

  const _NotifData({
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

/// 8. Bildirimler — görseldeki gibi:
/// splash2.jpg arka plan • başlık • Tümü/Sistem/Sosyal/Ödül •
/// 5 bildirim kartı • "Tümünü oku" • alt nav.
class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  int _filter = 0;
  final Set<int> _read = {};

  static const _items = [
    _NotifData(
      title: 'Quest reminder',
      body: 'You forgot to drink water',
      time: '2 min ago',
      icon: Icons.emoji_events_rounded,
      iconColor: Color(0xFFF59E0B),
      iconBg: Color(0xFFFFF3D6),
      emoji: '💧',
      category: 'System',
    ),
    _NotifData(
      title: 'Motivation',
      body: 'You can do it!',
      time: '1 hour ago',
      icon: Icons.favorite_rounded,
      iconColor: Color(0xFFF0608A),
      iconBg: Color(0xFFFFE0E8),
      emoji: '💖',
      category: 'System',
    ),
    _NotifData(
      title: 'Pet sound',
      body: 'Lumi misses you!',
      time: '5 hours ago',
      icon: Icons.pets_rounded,
      iconColor: Color(0xFFE05C7A),
      iconBg: Color(0xFFFFE4E4),
      emoji: '🐾',
      category: 'Social',
    ),
    _NotifData(
      title: 'Reward',
      body: 'You claimed your daily reward!',
      time: '1 day ago',
      icon: Icons.card_giftcard_rounded,
      iconColor: Color(0xFFF59E0B),
      iconBg: Color(0xFFFFF0C8),
      emoji: '🎁',
      category: 'Reward',
    ),
    _NotifData(
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

  List<({int index, _NotifData data})> get _filtered {
    final all = _items.indexed.map((e) => (index: e.$1, data: e.$2)).toList();
    final unread = all.where((e) => !_read.contains(e.index)).toList();
    if (_filter == 0) return unread;
    final cat = ['All', 'System', 'Social', 'Reward'][_filter];
    return unread.where((e) => e.data.category == cat).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── splash2.jpg arka plan (diğer sayfalarla aynı dil) ──
          ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Image.asset(
                AssetPaths.splash2Jpg,
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
            ),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.0, 0.18, 0.45, 1.0],
                colors: [
                  Color(0x40FFFFFF),
                  Color(0x66FFFFFF),
                  Color(0xB3FFFFFF),
                  Color(0xD9FFFFFF),
                ],
              ),
            ),
          ),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Üst bar: geri + başlık
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 20, 0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          width: 38,
                          height: 38,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.7),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 17,
                            color: Color(0xFF2D1B69),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Notifications',
                        style: AppText.nunito(
                          fontSize: 21,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Filtre hapları
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: NotificationFilterTabs(
                    selectedIndex: _filter,
                    onChanged: (i) => setState(() => _filter = i),
                  ),
                ),
                const SizedBox(height: 16),

                // Liste
                Expanded(
                  child: _filtered.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('🎉', style: TextStyle(fontSize: 44)),
                              const SizedBox(height: 10),
                              Text(
                                'All caught up!',
                                style: AppText.nunito(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                'No unread notifications.',
                                style: AppText.nunito(
                                  fontSize: 13.5,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: _filtered.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, i) {
                            final entry = _filtered[i];
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
                                child: const Icon(Icons.check_rounded,
                                    color: Colors.white),
                              ),
                              onDismissed: (_) =>
                                  setState(() => _read.add(entry.index)),
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
                        ),
                ),

                // Tümünü oku
                Center(
                  child: TextButton.icon(
                    onPressed: _filtered.isEmpty
                        ? null
                        : () {
                            setState(() =>
                                _read.addAll(_filtered.map((e) => e.index)));
                            ScaffoldMessenger.of(context).clearSnackBars();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text('All notifications marked as read.'),
                                duration: Duration(milliseconds: 900),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                    icon: const Icon(
                      Icons.mark_email_read_outlined,
                      size: 17,
                      color: Color(0xFF7B5EA7),
                    ),
                    label: Text(
                      "Mark all read",
                      style: AppText.nunito(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF7B5EA7),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 90), // alt nav payı
              ],
            ),
          ),
        ],
      ),
      // Görseldeki alt barla birebir
      bottomNavigationBar: LumoBottomNav(
        currentIndex: 0,
        onTap: (_) => Navigator.of(context).pop(),
      ),
    );
  }
}
