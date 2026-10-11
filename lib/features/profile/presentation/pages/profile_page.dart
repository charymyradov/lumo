import 'package:flutter/material.dart';
import 'package:lumo/core/constants/asset_paths.dart';
import 'package:lumo/features/profile/presentation/widgets/achievements_grid.dart';
import 'package:lumo/features/profile/presentation/widgets/profile_header.dart';
import 'package:lumo/features/profile/presentation/widgets/profile_menu_list.dart';
import 'package:lumo/features/profile/presentation/widgets/stats_row.dart';

/// 6. Profil — görseldeki gibi:
/// çayır arka plan • avatar • seviye bar • stats • başarımlar • menü.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Üstte çayır fotoğrafı net görünür, alta doğru beyaza açılır.
        Image.asset(
          AssetPaths.dayMeadow,
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
        ),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.0, 0.32, 0.55, 1.0],
              colors: [
                Color(0x00000000),
                Color(0x33FFFFFF),
                Color(0xB3FFFFFF),
                Color(0xE6FFFFFF),
              ],
            ),
          ),
        ),
        SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 8),
                // Sağ üst küçük ikon (görseldeki gibi)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                      child: const Icon(
                        Icons.camera_alt_outlined,
                        size: 19,
                        color: Color(0xFF5D6470),
                      ),
                    ),
                  ],
                ),
                const ProfileHeader(),
                const SizedBox(height: 16),
                const StatsRow(),
                const SizedBox(height: 12),
                const AchievementsGrid(),
                const SizedBox(height: 12),
                ProfileMenuList(
                  onFriends: () {},
                  onInviteCode: () {},
                  onSettings: () {},
                ),
                const SizedBox(height: 110),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
