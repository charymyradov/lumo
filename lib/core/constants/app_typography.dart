import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lumo/core/constants/app_colors.dart';

class AppTypography {
  AppTypography._();

  static TextStyle get displayLarge => GoogleFonts.nunito(
        fontSize: 40,
        fontWeight: FontWeight.w900,
        color: AppColors.textOnDark,
        letterSpacing: -0.5,
      );

  static TextStyle get headingLarge => GoogleFonts.nunito(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
        letterSpacing: -0.3,
      );

  static TextStyle get headingMedium => GoogleFonts.nunito(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodyLarge => GoogleFonts.nunito(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
      );

  static TextStyle get bodyMedium => GoogleFonts.nunito(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
      );

  static TextStyle get bodySmall => GoogleFonts.nunito(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
      );

  static TextStyle get labelButton => GoogleFonts.nunito(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: Colors.white,
        letterSpacing: 0.3,
      );

  static TextStyle get hintText => GoogleFonts.nunito(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: AppColors.textHint,
      );

  static TextStyle get taglineText => GoogleFonts.nunito(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Colors.white70,
        fontStyle: FontStyle.italic,
      );
}
