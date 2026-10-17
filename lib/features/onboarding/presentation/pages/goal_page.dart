import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lumo/core/constants/app_text.dart';
import 'package:lumo/core/constants/asset_paths.dart';
import 'package:lumo/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:lumo/features/onboarding/presentation/bloc/onboarding_event.dart';
import 'package:lumo/features/onboarding/presentation/bloc/onboarding_state.dart';
import 'package:lumo/features/onboarding/presentation/widgets/goal_option_tile.dart';
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
      label: 'Stress reduction',
      icon: Icons.spa_rounded,
      color: Color(0xFFFF7A45),
    ),
    _GoalOption(
      id: 'sleep',
      label: 'Better Sleep',
      icon: Icons.nights_stay_rounded,
      color: Color(0xFF7B61FF),
    ),
    _GoalOption(
      id: 'focus',
      label: 'Focus',
      icon: Icons.forum_rounded,
      color: Color(0xFF1FBF75),
    ),
    _GoalOption(
      id: 'motivation',
      label: 'Motivation',
      icon: Icons.emoji_events_rounded,
      color: Color(0xFFFFA81A),
    ),
    _GoalOption(
      id: 'meditation',
      label: 'Meditation',
      icon: Icons.self_improvement_rounded,
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
                filterQuality: FilterQuality.low,
                gaplessPlayback: true,
                cacheWidth: 1080,
                excludeFromSemantics: true,
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

                              // Hedef seçenekleri
                              ...goals.map(
                                (goal) => GoalOptionTile(
                                  label: goal.label,
                                  icon: goal.icon,
                                  iconColor: goal.color,
                                  isSelected: state.isGoalSelected(goal.id),
                                  onTap: () => context
                                      .read<OnboardingBloc>()
                                      .add(OnboardingGoalToggled(goal.id)),
                                ),
                              ),

                              const SizedBox(height: 6),

                              LumoContinueButton(
                                label: 'Continue',
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
    required this.color,
  });

  final String id;
  final String label;
  final IconData icon;

  /// Kartın tonunu belirleyen ana renk (ikon + kenarlık + gölge).
  final Color color;
}
