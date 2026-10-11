import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

  static const _items = [
    _NotifData(
      title: 'Görev hatırlatıcı',
      body: 'Su içmeyi unuttun',
      time: '2 dk önce',
      icon: Icons.emoji_events_rounded,
      iconColor: Color(0xFFF59E0B),
      iconBg: Color(0xFFFFF3D6),
      emoji: '💧',
      category: 'Sistem',
    ),
    _NotifData(
      title: 'Motivasyon',
      body: 'Sen başarabilirsin!',
      time: '1 saat önce',
      icon: Icons.favorite_rounded,
      iconColor: Color(0xFFF0608A),
      iconBg: Color(0xFFFFE0E8),
      emoji: '💖',
      category: 'Sistem',
    ),
    _NotifData(
      title: 'Pet sesi',
      body: 'Lumi seni özledi!',
      time: '5 saat önce',
      icon: Icons.pets_rounded,
      iconColor: Color(0xFFE05C7A),
      iconBg: Color(0xFFFFE4E4),
      emoji: '🐾',
      category: 'Sosyal',
    ),
    _NotifData(
      title: 'Ödül',
      body: 'Günlük ödülünü aldın!',
      time: '1 gün önce',
      icon: Icons.card_giftcard_rounded,
      iconColor: Color(0xFFF59E0B),
      iconBg: Color(0xFFFFF0C8),
      emoji: '🎁',
      category: 'Ödül',
    ),
    _NotifData(
      title: 'Arkadaş',
      body: 'Ayşe senin oyun alanını ziyaret etti.',
      time: '1 gün önce',
      icon: Icons.person_rounded,
      iconColor: Color(0xFFE05C5C),
      iconBg: Color(0xFFFFE0DC),
      emoji: '🎈',
      category: 'Sosyal',
    ),
  ];

  List<_NotifData> get _filtered {
    if (_filter == 0) return _items;
    final cat = ['Tümü', 'Sistem', 'Sosyal', 'Ödül'][_filter];
    return _items.where((e) => e.category == cat).toList();
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
                        'Bildirimler',
                        style: GoogleFonts.nunito(
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
                  child: ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      final n = _filtered[i];
                      return NotificationTile(
                        title: n.title,
                        body: n.body,
                        timeAgo: n.time,
                        icon: n.icon,
                        iconColor: n.iconColor,
                        iconBg: n.iconBg,
                        emoji: n.emoji,
                      );
                    },
                  ),
                ),

                // Tümünü oku
                Center(
                  child: TextButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).clearSnackBars();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Tüm bildirimler okundu.'),
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
                      "Tümünü oku",
                      style: GoogleFonts.nunito(
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
