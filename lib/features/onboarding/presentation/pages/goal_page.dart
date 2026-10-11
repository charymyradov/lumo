import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lumo/core/constants/app_colors.dart';
import 'package:lumo/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:lumo/features/onboarding/presentation/bloc/onboarding_event.dart';
import 'package:lumo/features/onboarding/presentation/bloc/onboarding_state.dart';
import 'package:lumo/features/onboarding/presentation/widgets/onboarding_background.dart';
import 'package:lumo/features/onboarding/presentation/widgets/lumo_continue_button.dart';

class GoalPage extends StatefulWidget {
  const GoalPage({super.key});

  @override
  State<GoalPage> createState() => _GoalPageState();
}

class _GoalPageState extends State<GoalPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _cardOpacity;
  late Animation<Offset> _cardSlide;

  final List<_GoalOption> goals = const [
    _GoalOption(
      id: 'stress',
      label: 'Stress Reduction',
      icon: Icons.spa_rounded,
      iconBg: Color(0xFFFFE8E0),
      color: Color(0xFFFF7A45),
    ),
    _GoalOption(
      id: 'sleep',
      label: 'Better Sleep',
      icon: Icons.nights_stay_rounded,
      iconBg: Color(0xFFEDE9FF),
      color: Color(0xFF7B61FF),
    ),
    _GoalOption(
      id: 'focus',
      label: 'Focus',
      icon: Icons.forum_rounded,
      iconBg: Color(0xFFE2F7EE),
      color: Color(0xFF1FBF75),
    ),
    _GoalOption(
      id: 'motivation',
      label: 'Motivation',
      icon: Icons.emoji_events_rounded,
      iconBg: Color(0xFFFFF1D6),
      color: Color(0xFFFFA81A),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _cardOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _cardSlide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic));

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _animController.forward();
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnboardingBloc, OnboardingState>(
      builder: (context, state) {
        return OnboardingBackground(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Üstteki gökyüzü illüstrasyonu için boşluk
                  const Spacer(flex: 3),

                  FadeTransition(
                    opacity: _cardOpacity,
                    child: SlideTransition(
                      position: _cardSlide,
                      child: Column(
                        children: [
                          Text(
                            'What is your goal??',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.nunito(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 14),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            transitionBuilder: (child, animation) =>
                                FadeTransition(
                              opacity: animation,
                              child: ScaleTransition(
                                scale: animation,
                                child: child,
                              ),
                            ),
                            child: state.selectedGoals.isEmpty
                                ? const SizedBox.shrink()
                                : Container(
                                    key: ValueKey(state.selectedGoals.length),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary
                                          .withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      '${state.selectedGoals.length} selected',
                                      style: GoogleFonts.nunito(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                          ),
                          const SizedBox(height: 14),

                          // Hedef seçenekleri (cam efektli, ikon rengine göre tonlu)
                          ...goals.map(
                            (goal) => _GoalGlassCard(
                              goal: goal,
                              isSelected: state.isGoalSelected(goal.id),
                              onTap: () => context
                                  .read<OnboardingBloc>()
                                  .add(OnboardingGoalToggled(goal.id)),
                            ),
                          ),

                          const SizedBox(height: 14),

                          LumoContinueButton(
                            label: 'Devam Et',
                            onTap: state.hasSelectedGoals
                                ? () => context
                                    .read<OnboardingBloc>()
                                    .add(const OnboardingNextPage())
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Bir hedef seçeneği: kimlik, etiket ve ikon rengi.
class _GoalOption {
  const _GoalOption({
    required this.id,
    required this.label,
    required this.icon,
    required this.iconBg,
    required this.color,
  });

  final String id;
  final String label;
  final IconData icon;

  /// İkonun arkasındaki yumuşak pastel daire.
  final Color iconBg;

  /// Kartın tonunu belirleyen ana renk (ikon + kenarlık + gölge).
  final Color color;
}

/// Cam (glass) efektli hedef kartı.
///
/// Arkasındaki arka planı bulanıklaştırır ve kartı ikonun rengine göre
/// soldan sağa açılan yumuşak bir gradyanla tonlar.
class _GoalGlassCard extends StatelessWidget {
  const _GoalGlassCard({
    required this.goal,
    required this.isSelected,
    required this.onTap,
  });

  final _GoalOption goal;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color accent = goal.color;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    accent.withValues(alpha: isSelected ? 0.32 : 0.20),
                    Colors.white.withValues(alpha: isSelected ? 0.80 : 0.58),
                    Colors.white.withValues(alpha: isSelected ? 0.66 : 0.42),
                  ],
                  stops: const [0.0, 0.55, 1.0],
                ),
                borderRadius: BorderRadius.circular(26),
                border: Border.all(
                  color: isSelected
                      ? accent.withValues(alpha: 0.80)
                      : Colors.white.withValues(alpha: 0.85),
                  width: isSelected ? 1.8 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: accent.withValues(alpha: isSelected ? 0.28 : 0.12),
                    blurRadius: isSelected ? 22 : 14,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Sol sparkle detayı, ikon rengiyle tonlanmış
                  Icon(
                    Icons.auto_awesome_rounded,
                    size: 15,
                    color: accent.withValues(alpha: isSelected ? 0.95 : 0.60),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: goal.iconBg,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: accent.withValues(alpha: 0.25),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(goal.icon, color: accent, size: 23),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      goal.label,
                      style: GoogleFonts.nunito(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: isSelected ? 1 : 0,
                    child: Icon(
                      Icons.check_circle_rounded,
                      color: accent,
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
