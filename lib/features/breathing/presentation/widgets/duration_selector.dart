import 'package:flutter/material.dart';
import 'package:lumo/core/constants/app_text.dart';

/// Görseldeki süre sırası: [1 dk] [3 dk] [5 dk] [10 dk]
class DurationSelector extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const DurationSelector({
    super.key,
    required this.selectedIndex,
    required this.onChanged,
  });

  static const labels = ['1 min', '3 min', '5 min', '10 min'];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(labels.length, (i) {
        final selected = i == selectedIndex;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i == labels.length - 1 ? 0 : 10),
            child: GestureDetector(
              onTap: () => onChanged(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected
                      ? Colors.white.withValues(alpha: 0.30)
                      : Colors.white.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.white.withValues(
                      alpha: selected ? 0.6 : 0.26,
                    ),
                    width: 1,
                  ),
                ),
                child: Text(
                  labels[i],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.nunito(
                    fontSize: 13,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
