import 'package:flutter/material.dart';
import 'package:lumo/core/constants/app_text.dart';

/// Lumi'nin altındaki sabit 4 bakım butonu (Feed / Water / Play / Sleep).
/// Dördü de aynı stildedir (acil nabız/kırmızı nokta yok).
class HomeCareButtons extends StatelessWidget {
  final double hunger;
  final double hydration;
  final double happiness;
  final double energy;
  final bool isSleeping;
  final VoidCallback onFeed;
  final VoidCallback onDrink;
  final VoidCallback onPlay;
  final VoidCallback onSleepToggle;

  const HomeCareButtons({
    super.key,
    required this.hunger,
    required this.hydration,
    required this.happiness,
    required this.energy,
    required this.isSleeping,
    required this.onFeed,
    required this.onDrink,
    required this.onPlay,
    required this.onSleepToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CareActionButton(
            id: 'feed',
            label: 'Feed',
            icon: Icons.restaurant_rounded,
            color: const Color(0xFFFB923C),
            value: hunger,
            onTap: onFeed,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: CareActionButton(
            id: 'water',
            label: 'Water',
            icon: Icons.water_drop_rounded,
            color: const Color(0xFF38BDF8),
            value: hydration,
            onTap: onDrink,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: CareActionButton(
            id: 'play',
            label: 'Play',
            icon: Icons.sports_soccer_rounded,
            color: const Color(0xFFFBBF24),
            value: happiness,
            onTap: onPlay,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: CareActionButton(
            id: 'sleep',
            label: isSleeping ? 'Wake Up' : 'Sleep',
            icon: isSleeping
                ? Icons.wb_sunny_rounded
                : Icons.nightlight_round,
            color: const Color(0xFF818CF8),
            value: energy,
            onTap: onSleepToggle,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Care Action Button — Lumi'nin altındaki 4 net butondan biri
// ─────────────────────────────────────────────────────────────────────────────
class CareActionButton extends StatelessWidget {
  final String id;
  final String label;
  final IconData icon;
  final Color color;

  /// Butonun bağlı olduğu vital değer (0.0–1.0). Lumi Care şeridindeki
  /// değerle aynı kaynaktan gelir, etiketin yanında % olarak gösterilir.
  final double value;

  final VoidCallback onTap;

  const CareActionButton({
    super.key,
    required this.id,
    required this.label,
    required this.icon,
    required this.color,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Opak zemin (cam değil): gökyüzünde net okunur. Dört buton da
    // birebir aynı stildedir — büyüme/küçülme ve renk farkı yok.
    // Tek satır etiket ("Feed %84") taşmayı önler.
    final pct = (value.clamp(0.0, 1.0) * 100).round();
    return Semantics(
      button: true,
      identifier: id,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: color.withValues(alpha: 0.35),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(height: 2),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      maxLines: 1,
                      style: AppText.nunito(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1E2E3D),
                      ),
                    ),
                    Text(
                      ' %$pct',
                      maxLines: 1,
                      style: AppText.nunito(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF5D6470),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
