import 'package:flutter/material.dart';
import 'package:lumo/core/constants/app_text.dart';

/// Sağ kenardaki dikey kısayol sütunu (Notifications / Calm / Quests).
class HomeSideActions extends StatelessWidget {
  final VoidCallback onNotifications;
  final VoidCallback onCalm;
  final VoidCallback onQuests;

  const HomeSideActions({
    super.key,
    required this.onNotifications,
    required this.onCalm,
    required this.onQuests,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SideActionButton(
          icon: Icons.notifications_rounded,
          color: const Color(0xFFFF8A65),
          label: 'Notifications',
          onTap: onNotifications,
        ),
        const SizedBox(height: 14),
        SideActionButton(
          icon: Icons.spa_rounded,
          color: const Color(0xFF4FB3F0),
          label: 'Calm',
          onTap: onCalm,
        ),
        const SizedBox(height: 14),
        SideActionButton(
          icon: Icons.checklist_rounded,
          color: const Color(0xFF58C77A),
          label: 'Quests',
          onTap: onQuests,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Side Action Button
// ─────────────────────────────────────────────────────────────────────────────
class SideActionButton extends StatefulWidget {
  final IconData icon;
  final Color color;

  /// İkonun altındaki küçük etiket (10.5px).
  final String? label;
  final VoidCallback onTap;

  const SideActionButton({
    super.key,
    required this.icon,
    required this.color,
    this.label,
    required this.onTap,
  });

  @override
  State<SideActionButton> createState() => SideActionButtonState();
}

class SideActionButtonState extends State<SideActionButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scaleController;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.9,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final button = GestureDetector(
      onTapDown: (_) => _scaleController.reverse(),
      onTapUp: (_) {
        _scaleController.forward();
        widget.onTap();
      },
      onTapCancel: () => _scaleController.forward(),
      child: ScaleTransition(
        scale: _scaleController,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.55),
                Colors.white.withValues(alpha: 0.28),
              ],
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.65),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(widget.icon, color: Colors.white, size: 20),
        ),
      ),
    );

    if (widget.label == null) return button;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        button,
        const SizedBox(height: 2),
        Text(
          widget.label!,
          style: AppText.nunito(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            shadows: const [
              Shadow(
                  color: Colors.black54, blurRadius: 5, offset: Offset(0, 1)),
            ],
          ),
        ),
      ],
    );
  }
}
