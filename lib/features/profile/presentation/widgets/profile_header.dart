import 'package:flutter/material.dart';
import 'package:lumo/core/constants/app_text.dart';

/// Üst avatar + isim + seviye + XP bar — görseldeki Profil başlığı.
class ProfileHeader extends StatelessWidget {
  final String name;
  final int level;
  final double progress; // 0..1
  final String progressText;

  const ProfileHeader({
    super.key,
    this.name = 'Elif',
    this.level = 12,
    this.progress = 800 / 1200,
    this.progressText = '800 / 1 200',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 108,
              height: 108,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFE3B3), Color(0xFFFFB38A)],
                ),
              ),
              child: const Center(
                child: Text('👧', style: TextStyle(fontSize: 60)),
              ),
            ),
            Positioned(
              top: 6,
              right: 6,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1),
                ),
                child: const Icon(
                  Icons.camera_alt_outlined,
                  size: 15,
                  color: Color(0xFF5D6470),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          name,
          style: AppText.nunito(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            shadows: [
              Shadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 8,
              ),
            ],
          ),
        ),
        Text(
          'Seviye $level',
          style: AppText.nunito(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Colors.white.withValues(alpha: 0.95),
          ),
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            height: 12,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white, width: 1),
            ),
            child: Stack(
              children: [
                FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: progress.clamp(0.0, 1.0),
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF9B6FE0), Color(0xFF5B3E87)],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Text('💧', style: TextStyle(fontSize: 13)),
            const SizedBox(width: 4),
            Text(
              progressText,
              style: AppText.nunito(
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
