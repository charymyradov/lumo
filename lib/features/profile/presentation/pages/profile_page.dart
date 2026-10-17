import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lumo/core/constants/asset_paths.dart';
import 'package:lumo/core/router/app_routes.dart';
import 'package:lumo/core/di/injection.dart';
import 'package:lumo/core/repositories/user_profile_repository.dart';
import 'package:lumo/core/repositories/wallet_repository.dart';
import 'package:lumo/core/repositories/wallet_repository_impl.dart';
import 'package:lumo/features/profile/presentation/widgets/achievements_grid.dart';
import 'package:lumo/features/profile/presentation/widgets/profile_header.dart';
import 'package:lumo/features/profile/presentation/widgets/profile_menu_list.dart';
import 'package:lumo/features/profile/presentation/widgets/stats_row.dart';
import 'package:lumo/features/profile/presentation/pages/invite_code_page.dart';
import 'package:lumo/features/settings/presentation/pages/settings_page.dart';
import 'package:lumo/shared/widgets/placeholder_page.dart';

/// 6. Profil — çayır arka plan • avatar • seviye bar • stats • başarımlar • menü.
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _name = 'Friend';
  int _level = WalletRepositoryImpl.defaultLevel;
  int _xp = WalletRepositoryImpl.defaultXp;
  int _coins = WalletRepositoryImpl.defaultCoins;
  int _streak = 7;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Tab'a her dönüşte cüzdanı tazele (görev/market ödülleri görünsün).
    _reload();
  }

  Future<void> _reload() async {
    final profile = await sl<UserProfileRepository>().load();
    final wallet = await sl<WalletRepository>().load();
    if (!mounted) return;
    setState(() {
      _name = profile.name.isEmpty ? 'Friend' : profile.name;
      _coins = wallet.coins;
      _xp = wallet.xp;
      _level = wallet.level;
      _streak = wallet.streak;
      _loaded = true;
    });
  }

  void _openInvite() {
    pushAppPage(context, const InviteCodePage());
  }

  void _openSettings() async {
    await pushAppPage(context, const SettingsPage());
    _reload();
  }

  void _openFriendsSoon() {
    pushAppPage(context, const PlaceholderPage(title: 'Friends'));
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_xp / WalletRepositoryImpl.xpPerLevel).clamp(0.0, 1.0);
    return Stack(
      fit: StackFit.expand,
      children: [
        // Üstte çayır fotoğrafı net görünür, alta doğru beyaza açılır.
        Image.asset(
          AssetPaths.dayMeadow,
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
          filterQuality: FilterQuality.low,
          gaplessPlayback: true,
          cacheWidth: 1080,
          excludeFromSemantics: true,
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
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(const ClipboardData(
                            text: 'Lumo — Small steps, big happiness.'));
                        ScaffoldMessenger.of(context)
                          ..clearSnackBars()
                          ..showSnackBar(
                            const SnackBar(
                              content: Text('Lumo link copied! 📋'),
                              behavior: SnackBarBehavior.floating,
                              duration: Duration(seconds: 2),
                            ),
                          );
                      },
                      child: Container(
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
                    ),
                  ],
                ),
                if (!_loaded)
                  const Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  )
                else ...[
                  ProfileHeader(
                    name: _name,
                    level: _level,
                    progress: progress,
                    progressText: '$_xp / ${WalletRepositoryImpl.xpPerLevel}',
                  ),
                  const SizedBox(height: 16),
                  StatsRow(coins: _coins, streak: _streak, pets: 1),
                  const SizedBox(height: 12),
                  const AchievementsGrid(),
                  const SizedBox(height: 12),
                  ProfileMenuList(
                    onFriends: _openFriendsSoon,
                    onInviteCode: _openInvite,
                    onSettings: _openSettings,
                  ),
                ],
                const SizedBox(height: 110),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
