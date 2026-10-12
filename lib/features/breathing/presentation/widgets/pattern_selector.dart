import 'package:flutter/material.dart';
import 'package:lumo/core/constants/app_text.dart';

/// Görseldeki desen sırası: [4-7-8] [Kutu Nefes] [Derin Nefes]
/// Tam genişliğe yayılır, seçili olan daha opak mor.
class PatternSelector extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const PatternSelector({
    super.key,
    required this.selectedIndex,
    required this.onChanged,
  });

  static const labels = ['4-7-8', 'Kutu Nefes', 'Derin Nefes'];

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
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected
                      ? const Color(0xFF9B7ED9).withValues(alpha: 0.62)
                      : Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.white.withValues(
                      alpha: selected ? 0.55 : 0.28,
                    ),
                    width: 1,
                  ),
                ),
                child: Text(
                  labels[i],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.nunito(
                    fontSize: 13.5,
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
