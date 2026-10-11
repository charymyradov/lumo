import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lumo/core/constants/app_colors.dart';
import 'package:lumo/shared/widgets/glass_card.dart';

class AchievementItem {
  final String label;
  final String emoji;
  final List<Color> colors;
  final bool locked;

  const AchievementItem({
    required this.label,
    required this.emoji,
    required this.colors,
    this.locked = false,
  });
}

const List<AchievementItem> profileAchievements = [
  AchievementItem(
      label: 'Yeni', emoji: '🏅', colors: [Color(0xFFFFD45E), Color(0xFFF0A828)]),
  AchievementItem(
      label: '7 Gün', emoji: '⭐', colors: [Color(0xFFFFE066), Color(0xFFFFB300)]),
  AchievementItem(
      label: '30 Gün',
      emoji: '🎖️',
      colors: [Color(0xFF8FA3BF), Color(0xFF5D6B8A)]),
  AchievementItem(
      label: '100 Gün',
      emoji: '🏆',
      colors: [Color(0xFFFF9A6B), Color(0xFFFF6B35)]),
];

/// "Başarımlar" cam kart + yatay madalya listesi.
class AchievementsGrid extends StatelessWidget {
  const AchievementsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      radius: 22,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Başarımlar',
                  style: GoogleFonts.nunito(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.textSecondary),
            ],
          ),
          const SizedBox(height: 14),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: List.generate(profileAchievements.length, (i) {
                final a = profileAchievements[i];
                return Padding(
                  padding: EdgeInsets.only(
                      right: i == profileAchievements.length - 1 ? 0 : 18),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: a.colors,
                          ),
                          border:
                              Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: a.colors.last.withValues(alpha: 0.35),
                              blurRadius: 12,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(a.emoji,
                              style: const TextStyle(fontSize: 26)),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        a.label,
                        style: GoogleFonts.nunito(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
