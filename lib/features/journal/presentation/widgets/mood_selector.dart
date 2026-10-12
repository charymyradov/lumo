import 'package:flutter/material.dart';
import 'package:lumo/core/constants/app_text.dart';
import 'package:lumo/core/constants/app_colors.dart';

class MoodOption {
  final String label;
  final String emoji;
  final Color color;

  const MoodOption({
    required this.label,
    required this.emoji,
    required this.color,
  });
}

const List<MoodOption> journalMoods = [
  MoodOption(label: 'Mükemmel', emoji: '😊', color: Color(0xFF8A5CF5)),
  MoodOption(label: 'İyi', emoji: '🙂', color: Color(0xFFFFC93C)),
  MoodOption(label: 'Normal', emoji: '😐', color: Color(0xFFF5B97F)),
  MoodOption(label: 'Kötü', emoji: '🙁', color: Color(0xFFF2607A)),
  MoodOption(label: 'Çok Kötü', emoji: '😢', color: Color(0xFF93A5C4)),
];

/// Yatay 5'li ruh hali seçici — görseldeki gibi dairesel emoji balonları.
class MoodSelector extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const MoodSelector({
    super.key,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(journalMoods.length, (index) {
        final mood = journalMoods[index];
        final selected = index == selectedIndex;
        return Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onChanged(index),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  width: selected ? 58 : 52,
                  height: selected ? 58 : 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        mood.color.withValues(alpha: 0.95),
                        mood.color.withValues(alpha: 0.7),
                      ],
                    ),
                    border: Border.all(
                      color: selected ? Colors.white : Colors.white.withValues(alpha: 0.7),
                      width: selected ? 2.5 : 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: mood.color.withValues(alpha: selected ? 0.45 : 0.25),
                        blurRadius: selected ? 16 : 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(mood.emoji, style: const TextStyle(fontSize: 28)),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  mood.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.nunito(
                    fontSize: 12,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                    color: selected
                        ? AppColors.textPrimary
                        : AppColors.textPrimary.withValues(alpha: 0.75),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
