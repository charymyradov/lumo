import 'package:flutter/material.dart';
import 'package:lumo/core/constants/app_text.dart';
import 'package:lumo/shared/widgets/glass_card.dart';

/// Pet Care Panel — ince şerit, varsayılan kapalı.
/// Detayı buton grubunda: sayısal vital dökümü.
class HomeCarePanel extends StatelessWidget {
  final double hunger;
  final double hydration;
  final double happiness;
  final double energy;
  final bool expanded;
  final VoidCallback onToggle;

  const HomeCarePanel({
    super.key,
    required this.hunger,
    required this.hydration,
    required this.happiness,
    required this.energy,
    required this.expanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.fromLTRB(12, 8, 10, 8),
      radius: 16,
      opacity: 0.86,
      blur: 18,
      child: Column(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onToggle,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.pets,
                          color: Color(0xFF5A449C), size: 16),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          'Lumi Care',
                          style: AppText.nunito(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF1E2E3D),
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                VitalBar(
                  icon: Icons.restaurant_rounded,
                  value: hunger,
                  color: const Color(0xFFFB923C),
                  onTap: onToggle,
                ),
                const SizedBox(width: 6),
                VitalBar(
                  icon: Icons.water_drop_rounded,
                  value: hydration,
                  color: const Color(0xFF38BDF8),
                  onTap: onToggle,
                ),
                const SizedBox(width: 6),
                VitalBar(
                  icon: Icons.favorite_rounded,
                  value: happiness,
                  color: const Color(0xFFF472B6),
                  onTap: onToggle,
                ),
                const SizedBox(width: 6),
                VitalBar(
                  icon: Icons.bolt_rounded,
                  value: energy,
                  color: const Color(0xFFFBBF24),
                  onTap: onToggle,
                ),
                Icon(
                  expanded ? Icons.expand_less : Icons.expand_more,
                  size: 20,
                  color: Colors.black54,
                ),
              ],
            ),
          ),
          if (expanded) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: VitalStat(
                      label: 'Hunger',
                      value: hunger,
                      color: const Color(0xFFFB923C)),
                ),
                Expanded(
                  child: VitalStat(
                      label: 'Water',
                      value: hydration,
                      color: const Color(0xFF38BDF8)),
                ),
                Expanded(
                  child: VitalStat(
                      label: 'Happiness',
                      value: happiness,
                      color: const Color(0xFFF472B6)),
                ),
                Expanded(
                  child: VitalStat(
                      label: 'Energy',
                      value: energy,
                      color: const Color(0xFFFBBF24)),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Vital Bar — emoji hap yerine ikon + kalın bar; eşik altında kırmızı.
// ─────────────────────────────────────────────────────────────────────────────
class VitalBar extends StatelessWidget {
  final IconData icon;
  final double value;
  final Color color;
  final VoidCallback? onTap;

  const VitalBar({
    super.key,
    required this.icon,
    required this.value,
    required this.color,
    this.onTap,
  });

  /// Bu değerin altında vital "kritik" sayılır ve kırmızıya döner.
  static const double dangerBelow = 0.25;

  @override
  Widget build(BuildContext context) {
    final critical = value <= dangerBelow;
    final barColor = critical ? const Color(0xFFEF4444) : color;

    final bar = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: barColor),
        const SizedBox(width: 3),
        Container(
          width: 26,
          height: 7,
          decoration: BoxDecoration(
            color: const Color(0xFFE2E8F0),
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: value.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: barColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );

    if (onTap == null) return bar;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
        child: bar,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Vital Stat — şerit detayındaki sayısal döküm (Açlık %84 …)
// ─────────────────────────────────────────────────────────────────────────────
class VitalStat extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const VitalStat({
    super.key,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final critical = value <= 0.25;
    final pct = (value * 100).round();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: critical ? const Color(0xFFEF4444) : color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            '$label %$pct',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppText.nunito(
              fontSize: 10.5,
              fontWeight: critical ? FontWeight.w800 : FontWeight.w700,
              color:
                  critical ? const Color(0xFFDC2626) : const Color(0xFF5D6470),
            ),
          ),
        ),
      ],
    );
  }
}
