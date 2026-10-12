import 'package:flutter/material.dart';

/// AI'ın döndürdüğü `category` anahtarını ikon + renge çevirir.
/// Bilinmeyen anahtar sağlık ikonuna düşer (uygulama kırılmaz).
({IconData icon, Color color}) questVisuals(String category) {
  return switch (category) {
    'water' => (
        icon: Icons.water_drop_rounded,
        color: const Color(0xFF4FB3F0)
      ),
    'move' => (
        icon: Icons.directions_run_rounded,
        color: const Color(0xFF58C77A)
      ),
    'breath' => (
        icon: Icons.air_rounded,
        color: const Color(0xFF6FC8E8)
      ),
    'mind' => (
        icon: Icons.self_improvement_rounded,
        color: const Color(0xFF5CC8A0)
      ),
    'journal' => (
        icon: Icons.edit_note_rounded,
        color: const Color(0xFF9B6FE0)
      ),
    'sport' => (
        icon: Icons.fitness_center_rounded,
        color: const Color(0xFFE09B3D)
      ),
    'social' => (
        icon: Icons.people_rounded,
        color: const Color(0xFFE05C7A)
      ),
    'sleep' => (
        icon: Icons.bedtime_rounded,
        color: const Color(0xFF7B5EA7)
      ),
    _ => (
        icon: Icons.favorite_rounded,
        color: const Color(0xFFE05C7A)
      ),
  };
}
