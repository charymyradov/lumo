import 'package:flutter/material.dart';
import 'package:lumo/features/notifications/presentation/pages/notifications_controller.dart';
import 'package:lumo/features/notifications/presentation/pages/notifications_data.dart';
import 'package:lumo/features/notifications/presentation/pages/widgets/notifications_background.dart';
import 'package:lumo/features/notifications/presentation/pages/widgets/notifications_header.dart';
import 'package:lumo/features/notifications/presentation/pages/widgets/notifications_list.dart';
import 'package:lumo/features/notifications/presentation/widgets/notification_filter_tabs.dart';
import 'package:lumo/shared/widgets/lumo_bottom_nav.dart';

/// 8. Bildirimler — görseldeki gibi:
/// splash2.jpg arka plan • başlık • Tümü/Sistem/Sosyal/Ödül •
/// 5 bildirim kartı • "Tümünü oku" • alt nav.
class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage>
    with NotificationsControllerMixin {
  @override
  Widget build(BuildContext context) {
    final filtered = filterNotifications(filter, read);

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const NotificationsBackground(),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const NotificationsHeader(),
                const SizedBox(height: 14),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: NotificationFilterTabs(
                    selectedIndex: filter,
                    onChanged: setFilter,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: filtered.isEmpty
                      ? const NotificationsEmptyView()
                      : NotificationsList(
                          entries: filtered,
                          onDismissed: markRead,
                        ),
                ),
                MarkAllReadButton(
                  enabled: filtered.isNotEmpty,
                  onPressed: () {
                    markAllRead(filtered.map((e) => e.index));
                    showMarkedAllReadMessage();
                  },
                ),
                const SizedBox(height: 90),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: LumoBottomNav(
        currentIndex: 0,
        onTap: (_) => Navigator.of(context).pop(),
      ),
    );
  }
}
