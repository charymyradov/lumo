import 'package:flutter/material.dart';

/// Shared palette for the procedural pet-stage painters.
///
/// Extracted verbatim from `_PetStageRenderer`'s private color constants so
/// every split painter file references a single source of truth.
abstract final class PetPaintColors {
  static const Color white = Colors.white;
  static const Color furWhite = Color(0xFFFDFBFF);
  static const Color softLavender = Color(0xFFEDE7FF);
  static const Color furShadow = Color(0xFFDDD6FE);
  static const Color tailPurple = Color(0xFF8B5CF6);
  static const Color tailDeep = Color(0xFF7C3AED);
  static const Color earInner = Color(0xFF8B5CF6);
  static const Color earDeep = Color(0xFF5B21B6);
  static const Color blushPink = Color(0xFFF9A8D4);
  static const Color blushDeep = Color(0xFFF472B6);
  static const Color deepNose = Color(0xFF4C1D95);
  static const Color pupilInk = Color(0xFF1E1B4B);
  static const Color eyeLid = Color(0xFF4C1D95);
  static const Color goldDark = Color(0xFFB45309);
  static const Color goldLight = Color(0xFFFEF08A);
  static const Color pawSock = Color(0xFF6D28D9);
}
