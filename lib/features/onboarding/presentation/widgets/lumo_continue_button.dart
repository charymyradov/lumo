import 'package:flutter/material.dart';
import 'package:lumo/core/constants/app_text.dart';
import 'package:lumo/core/constants/app_colors.dart';
import 'package:lumo/shared/widgets/lumo_tap.dart';

class LumoContinueButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const LumoContinueButton({super.key, this.label = 'Continue', this.onTap});

  @override
  Widget build(BuildContext context) {
    return LumoTap(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          gradient: AppColors.buttonGradient,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.35),
              blurRadius: 12,
              spreadRadius: 0,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: AppText.nunito(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.4,
            ),
          ),
        ),
      ),
    );
  }
}
