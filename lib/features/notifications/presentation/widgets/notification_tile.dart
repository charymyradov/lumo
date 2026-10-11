import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Görseldeki beyaz bildirim kartı:
/// renkli yuvarlak ikon • kalın başlık • açıklama • "2 dk önce".
class NotificationTile extends StatelessWidget {
  final String title;
  final String body;
  final String timeAgo;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String? emoji;

  const NotificationTile({
    super.key,
    required this.title,
    required this.body,
    required this.timeAgo,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    this.emoji,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: iconBg,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF2D1B45),
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  emoji == null ? body : '$body  $emoji',
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF5D6470),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  timeAgo,
                  style: GoogleFonts.nunito(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF9AA0AC),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
