import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary brand palette
  static const Color primary = Color(0xFF7B5EA7);
  static const Color primaryLight = Color(0xFF9B7EC8);
  static const Color primaryDark = Color(0xFF5B3E87);

  // Accent / CTA
  static const Color accent = Color(0xFFA78BE0);
  static const Color accentButton = Color(0xFF8A5CF5);

  // Backgrounds
  static const Color bgDark = Color(0xFF1A0F2E);
  static const Color bgCard = Color(0xFFEEE8FF);

  // Text
  static const Color textPrimary = Color(0xFF2D1B69);
  static const Color textSecondary = Color(0xFF6B5B95);
  static const Color textOnDark = Color(0xFFFFFFFF);
  static const Color textHint = Color(0xFFAA99CC);

  // Gradients
  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF4B2D8F), Color(0xFF8B5CC8), Color(0xFFD4A0E8)],
  );

  static const LinearGradient buttonGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF7C4DCC), Color(0xFFA879E6)],
  );

  // Glass
  static const Color glassWhite = Color(0xCCFFFFFF);
  static const Color glassBorder = Color(0x80FFFFFF);

  // Goal icon colors
  static const Color goalRed = Color(0xFFE05C7A);
  static const Color goalPurple = Color(0xFF9B6FE0);
  static const Color goalGreen = Color(0xFF5CC8A0);
  static const Color goalOrange = Color(0xFFE09B3D);

  // Permission colors
  static const Color permissionBlue = Color(0xFF5B8DEF);
  static const Color permissionRed = Color(0xFFE05C7A);
}
