import 'package:flutter/material.dart';
import 'package:lumo/core/constants/app_text.dart';

/// Gradyanlı kaydet butonu.
class JournalSaveButton extends StatelessWidget {
  final bool saved;
  final VoidCallback onPressed;

  const JournalSaveButton({
    super.key,
    required this.saved,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4FA8F0), Color(0xFF3E8FE0)],
          ),
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF3E8FE0).withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(26),
            ),
          ),
          child: Text(
            saved ? 'Saved ✓' : 'Save',
            style: AppText.nunito(
              fontSize: 16.5,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
