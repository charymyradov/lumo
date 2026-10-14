import 'package:flutter/material.dart';
import 'package:lumo/core/constants/app_text.dart';
import 'package:lumo/core/constants/app_colors.dart';
import 'package:lumo/shared/widgets/glass_card.dart';

/// Arkadaşlar • Davet Kodu • Ayarlar — cam menü listesi.
class ProfileMenuList extends StatelessWidget {
  final VoidCallback? onFriends;
  final VoidCallback? onInviteCode;
  final VoidCallback? onSettings;

  const ProfileMenuList({
    super.key,
    this.onFriends,
    this.onInviteCode,
    this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      radius: 22,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _tile(Icons.group_outlined, 'Friends', onFriends),
          _divider(),
          _tile(Icons.card_giftcard_outlined, 'Invite Code', onInviteCode),
          _divider(),
          _tile(Icons.settings_outlined, 'Settings', onSettings),
        ],
      ),
    );
  }

  Widget _tile(IconData icon, String title, VoidCallback? onTap) {
    return ListTile(
      onTap: onTap,
      dense: true,
      leading: Icon(icon, color: AppColors.textSecondary, size: 24),
      title: Text(
        title,
        style: AppText.nunito(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
      trailing: const Icon(Icons.chevron_right_rounded,
          color: AppColors.textSecondary),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    );
  }

  Widget _divider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(
        height: 1,
        thickness: 1,
        color: AppColors.textSecondary.withValues(alpha: 0.12),
      ),
    );
  }
}
