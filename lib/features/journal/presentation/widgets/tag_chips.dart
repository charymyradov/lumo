import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:lumo/core/constants/app_text.dart';
import 'package:lumo/core/constants/app_colors.dart';
import 'package:lumo/shared/widgets/lumo_tap.dart';

/// Küçük hashtag çipleri — #minnet #sağlık #Aile ...
class TagChips extends StatelessWidget {
  final List<String> tags;
  final Set<int> selected;
  final ValueChanged<int> onTap;
  final bool blurEnabled;

  const TagChips({
    super.key,
    required this.tags,
    required this.selected,
    required this.onTap,
    this.blurEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(tags.length, (index) {
        final isSelected = selected.contains(index);
        final chip = AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.85)
                : Colors.white.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? Colors.white.withValues(alpha: 0.6)
                  : Colors.white.withValues(alpha: 0.7),
              width: 1,
            ),
          ),
          child: Text(
            tags[index],
            style: AppText.nunito(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isSelected
                  ? Colors.white
                  : AppColors.textPrimary.withValues(alpha: 0.8),
            ),
          ),
        );
        return LumoTap(
          onTap: () => onTap(index),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: blurEnabled
                ? RepaintBoundary(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: chip,
                    ),
                  )
                : chip,
          ),
        );
      }),
    );
  }
}
