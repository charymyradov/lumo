import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Görseldeki ortalanmış ses hapı: [ Ses  Orman  ▾ ]
class SoundToggle extends StatelessWidget {
  final String sound;
  final VoidCallback onTap;

  const SoundToggle({super.key, required this.sound, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.32),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.volume_up_outlined,
              color: Colors.white,
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              'Ses  $sound',
              style: GoogleFonts.nunito(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 10),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Colors.white70,
              size: 17,
            ),
          ],
        ),
      ),
    );
  }
}
