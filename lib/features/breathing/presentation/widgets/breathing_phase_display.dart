import 'package:flutter/material.dart';
import 'package:lumo/core/constants/app_text.dart';

/// Faz yazısı (görseldeki konum) + geri sayım.
class BreathingPhaseDisplay extends StatelessWidget {
  const BreathingPhaseDisplay({
    super.key,
    required this.phaseText,
    required this.secondsLeft,
  });

  final String phaseText;
  final int secondsLeft;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          phaseText,
          style: AppText.nunito(
            fontSize: 21,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            shadows: const [
              Shadow(
                color: Colors.black45,
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeOut,
          // Sadece opaklık geçişi: scale/clip yok, layout sabit Stack.
          transitionBuilder: (child, animation) =>
              FadeTransition(opacity: animation, child: child),
          layoutBuilder: (currentChild, previousChildren) => Stack(
            alignment: Alignment.center,
            children: [
              ...previousChildren,
              if (currentChild != null) currentChild,
            ],
          ),
          child: Text(
            '$secondsLeft sec',
            key: ValueKey<int>(secondsLeft),
            style: AppText.nunito(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.92),
            ),
          ),
        ),
      ],
    );
  }
}
