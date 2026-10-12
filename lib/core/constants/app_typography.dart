import 'package:flutter/material.dart';
import 'package:lumo/core/constants/app_colors.dart';
import 'package:lumo/core/constants/app_text.dart';

class AppTypography {
  AppTypography._();

  static TextStyle get displayLarge => AppText.nunito(
        fontSize: 40,
        fontWeight: FontWeight.w900,
        color: AppColors.textOnDark,
        letterSpacing: -0.5,
      );

  static TextStyle get headingLarge => AppText.nunito(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
        letterSpacing: -0.3,
      );

  static TextStyle get headingMedium => AppText.nunito(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodyLarge => AppText.nunito(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
      );

  static TextStyle get bodyMedium => AppText.nunito(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
      );

  static TextStyle get bodySmall => AppText.nunito(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
      );

  static TextStyle get labelButton => AppText.nunito(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: Colors.white,
        letterSpacing: 0.3,
      );

  static TextStyle get hintText => AppText.nunito(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: AppColors.textHint,
      );

  static TextStyle get taglineText => AppText.nunito(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Colors.white70,
        fontStyle: FontStyle.italic,
      );
}
