import 'package:flutter/material.dart';
import 'package:lumo/core/constants/app_colors.dart';
import 'package:lumo/core/constants/app_text.dart';

/// Üst bar: geri + başlık.
class NotificationsHeader extends StatelessWidget {
  const NotificationsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
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
    );
  }
}

/// Boş liste görünümü.
class NotificationsEmptyView extends StatelessWidget {
  const NotificationsEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
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
    );
  }
}

/// "Tümünü oku" butonu.
class MarkAllReadButton extends StatelessWidget {
  final bool enabled;
  final VoidCallback onPressed;

  const MarkAllReadButton({
    super.key,
    required this.enabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton.icon(
        onPressed: enabled ? onPressed : null,
        icon: const Icon(
          Icons.mark_email_read_outlined,
          size: 17,
          color: Color(0xFF7B5EA7),
        ),
        label: Text(
          'Mark all read',
          style: AppText.nunito(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF7B5EA7),
          ),
        ),
      ),
    );
  }
}
