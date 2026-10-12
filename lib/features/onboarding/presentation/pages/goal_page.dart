import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lumo/core/constants/app_text.dart';
import 'package:lumo/core/constants/asset_paths.dart';
import 'package:lumo/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:lumo/features/onboarding/presentation/bloc/onboarding_event.dart';
import 'package:lumo/features/onboarding/presentation/bloc/onboarding_state.dart';
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
      label: 'Stress reduction ',
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
    _GoalOption(
      id: 'meditation',
      label: 'Meditasyon',
      icon: Icons.self_improvement_rounded,
      iconBg: Color(0xFFE8E4FF),
      color: Color(0xFF8B5CF6),
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
        // Referans görsel: üstte pastel gökyüzü, ortada açık sis üstünde
        // seçim kartları, altta silik manzara. Koyu ada görseli yerine
        // aydınlık splash_1 kullanılır.
        return Scaffold(
          body: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                AssetPaths.splashBg,
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
              // Yumuşak perde: üst şeffaf -> orta açık sis -> alt hafif lavanta.
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0.0, 0.30, 0.55, 1.0],
                    colors: [
                      Colors.transparent,
                      Color(0x66FFF6FB),
                      Color(0xCCF6F1FF),
                      Color(0xE6F3EEFF),
                    ],
                  ),
                ),
              ),
              SafeArea(
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
                                'What is your goal?',
                                textAlign: TextAlign.center,
                                style: AppText.nunito(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFF40306B),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Hedef seçenekleri (referans: açık cam kart)
                              ...goals.map(
                                (goal) => _GoalGlassCard(
                                  goal: goal,
                                  isSelected: state.isGoalSelected(goal.id),
                                  onTap: () => context
                                      .read<OnboardingBloc>()
                                      .add(OnboardingGoalToggled(goal.id)),
                                ),
                              ),

                              const SizedBox(height: 6),

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
            ],
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
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    // Referans: neredeyse beyaz, seçiliyken hafif vurgu.
                    accent.withValues(alpha: isSelected ? 0.22 : 0.10),
                    Colors.white.withValues(alpha: isSelected ? 0.88 : 0.72),
                    const Color(0xFFFFF2F5)
                        .withValues(alpha: isSelected ? 0.80 : 0.62),
                  ],
                  stops: const [0.0, 0.45, 1.0],
                ),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isSelected
                      ? accent.withValues(alpha: 0.75)
                      : Colors.white.withValues(alpha: 0.90),
                  width: isSelected ? 1.8 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: accent.withValues(alpha: isSelected ? 0.20 : 0.08),
                    blurRadius: isSelected ? 18 : 10,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Sol mini sparkle detayı
                  Icon(
                    Icons.auto_awesome_rounded,
                    size: 13,
                    color: accent.withValues(alpha: isSelected ? 0.90 : 0.50),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: goal.iconBg,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(goal.icon, color: accent, size: 23),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      goal.label,
                      style: AppText.nunito(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF2E2A3B),
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
