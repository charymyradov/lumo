import 'package:flutter/material.dart';
import 'package:lumo/core/constants/app_text.dart';
import 'package:lumo/core/constants/asset_paths.dart';
import 'package:lumo/shared/widgets/coin_badge.dart';

/// Üst bar: avatar + selamlama/XP hapı + coin rozeti.
class HomeTopBar extends StatelessWidget {
  final double topPadding;
  final String userName;
  final int level;
  final int xp;
  final int xpMax;
  final int coins;

  const HomeTopBar({
    super.key,
    required this.topPadding,
    required this.userName,
    required this.level,
    required this.xp,
    required this.xpMax,
    required this.coins,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: topPadding + 8,
        left: 16,
        right: 16,
        bottom: 10,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.20),
            Colors.transparent,
          ],
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Avatar circle
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 10,
                ),
              ],
              image: const DecorationImage(
                image: AssetImage(AssetPaths.splashBg),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Selamlama + XP bar — parlak gökyüzünde okunurluk için
          // yarı saydam koyu hap (gölge tek başına yetmiyor).
          Expanded(
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 7, 13, 8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.34),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.18),
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userName.isEmpty
                        ? 'Hello! · Lv. $level'
                        : 'Hello, $userName! · Lv. $level',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.nunito(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: SizedBox(
                            height: 7,
                            child: Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color:
                                        Colors.white.withValues(alpha: 0.24),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                FractionallySizedBox(
                                  alignment: Alignment.centerLeft,
                                  widthFactor: (xp / xpMax).clamp(0.0, 1.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFFA78BE0),
                                          Color(0xFFFEF08A),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          '$xp/$xpMax',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.nunito(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 8),

          CoinReward(amount: coins),
        ],
      ),
    );
  }
}
