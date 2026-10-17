import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lumo/core/constants/app_text.dart';
import 'package:lumo/core/constants/app_colors.dart';
import 'package:lumo/core/constants/app_typography.dart';
import 'package:lumo/core/constants/asset_paths.dart';
import 'package:lumo/core/services/user_profile_store.dart';
import 'package:lumo/shared/widgets/glass_card.dart';

/// Davet kodu — kullanıcı adına göre üretilir, panoya kopyalanabilir.
class InviteCodePage extends StatefulWidget {
  const InviteCodePage({super.key});

  @override
  State<InviteCodePage> createState() => _InviteCodePageState();
}

class _InviteCodePageState extends State<InviteCodePage> {
  /// Yüklenene kadar null — ekranda yer tutucu kod görünür.
  String? _code;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final profile = await UserProfileStore.load();
    if (!mounted) return;
    final name =
        profile.name.trim().toUpperCase().replaceAll(RegExp(r'[^A-Z]'), '');
    final prefix =
        (name.isEmpty ? 'LUMO' : name.substring(0, name.length.clamp(1, 4)))
            .padRight(4, 'X');
    setState(() {
      _code = 'LUMO-$prefix-${profile.mascotIndex + 12}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          RepaintBoundary(
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Image.asset(
                  AssetPaths.splash2Jpg,
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.low,
                  gaplessPlayback: true,
                  cacheWidth: 1080,
                  excludeFromSemantics: true,
                ),
              ),
            ),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x66FFFFFF), Color(0xD9FFFFFF)],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(Icons.arrow_back_rounded),
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GlassCard(
                    radius: 24,
                    child: Column(
                      children: [
                        Text(
                          'Invite Code',
                          style: AppTypography.headingMedium.copyWith(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Invite your friends and earn coins together.',
                          textAlign: TextAlign.center,
                          style: AppText.nunito(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 22, vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white),
                          ),
                          child: Text(
                            _code ?? 'LUMO-···',
                            style: AppText.nunito(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        FilledButton.icon(
                          onPressed: _code == null
                              ? null
                              : () {
                                  Clipboard.setData(
                                      ClipboardData(text: _code!));
                                  ScaffoldMessenger.of(context)
                                    ..clearSnackBars()
                                    ..showSnackBar(
                                      const SnackBar(
                                        content: Text('Invite code copied! 📋'),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                },
                          icon: const Icon(Icons.copy_rounded, size: 18),
                          label: const Text('Copy code'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
