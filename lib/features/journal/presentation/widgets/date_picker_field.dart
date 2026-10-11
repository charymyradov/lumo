import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lumo/core/constants/app_colors.dart';
import 'package:lumo/shared/widgets/glass_card.dart';

/// Tarih satırı — görseldeki "7 Ekim 2025 + takvim ikonu" kutusu.
class DatePickerField extends StatelessWidget {
  final String dateText;
  final VoidCallback? onTap;

  const DatePickerField({
    super.key,
    required this.dateText,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      radius: 18,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        children: [
          Expanded(
            child: Text(
              dateText,
              style: GoogleFonts.nunito(
                fontSize: 15.5,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: const Color(0xFF7B5EA7).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Icon(
              Icons.calendar_month_outlined,
              size: 18,
              color: Color(0xFF7B5EA7),
            ),
          ),
        ],
      ),
    );
  }
}
