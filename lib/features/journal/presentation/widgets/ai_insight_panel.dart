import 'package:flutter/material.dart';
import 'package:lumo/core/constants/app_text.dart';
import 'package:lumo/core/constants/app_colors.dart';
import 'package:lumo/shared/widgets/glass_card.dart';

/// "AI İçgörün" cam kartı — mor ikon + iki satır açıklama.
class AiInsightPanel extends StatelessWidget {
  final String message;
  final bool loading;

  const AiInsightPanel({
    super.key,
    required this.message,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      radius: 22,
      padding: const EdgeInsets.all(16),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFFFFE9F2).withValues(alpha: 0.72),
          const Color(0xFFF3E8FF).withValues(alpha: 0.62),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.person_outline_rounded,
                size: 20,
                color: AppColors.textPrimary,
              ),
              const SizedBox(width: 6),
              Text(
                'AI İçgörün',
                style: AppText.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFB79CED), Color(0xFF7B5EA7)],
                  ),
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: loading
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        ),
                      )
                    : Text(
                        message,
                        style: AppText.nunito(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w500,
                          height: 1.45,
                          color: AppColors.textPrimary.withValues(alpha: 0.9),
                        ),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Alt mini desen kartı — görselin en altındaki küçük şerit.
class AiPatternStrip extends StatelessWidget {
  const AiPatternStrip({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      radius: 18,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      gradient: LinearGradient(
        colors: [
          const Color(0xFFFFD9C7).withValues(alpha: 0.6),
          const Color(0xFFFFE9D6).withValues(alpha: 0.55),
        ],
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.bolt_rounded,
                      size: 12, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    '3 / 10',
                    style: AppText.nunito(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  const Icon(Icons.play_arrow_rounded,
                      size: 14, color: AppColors.primary),
                  Text(
                    'AI İçgörün Desenleri',
                    style: AppText.nunito(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Bugün kendine karşı çok naziksin! Bu dengeli ruh halin, yardım için de iyi bir temel oluşturuyor.',
              style: AppText.nunito(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                height: 1.4,
                color: AppColors.textPrimary.withValues(alpha: 0.85),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
