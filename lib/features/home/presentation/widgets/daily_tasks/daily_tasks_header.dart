import 'package:flutter/material.dart';
import 'package:lumo/core/constants/app_text.dart';

/// "Daily Quests" başlığı + sayaç rozeti.
class DailyTasksHeader extends StatelessWidget {
  final int done;
  final int total;

  const DailyTasksHeader({
    super.key,
    required this.done,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.checklist_rounded, size: 15, color: Color(0xFF5A449C)),
        const SizedBox(width: 6),
        Text(
          'Daily Quests',
          style: AppText.nunito(
            fontSize: 13.5,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1E2E3D),
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFF5A449C),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$done/$total',
            style: AppText.nunito(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
