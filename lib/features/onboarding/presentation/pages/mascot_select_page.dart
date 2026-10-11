import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lumo/core/constants/app_colors.dart';
import 'package:lumo/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:lumo/features/onboarding/presentation/bloc/onboarding_event.dart';
import 'package:lumo/features/onboarding/presentation/bloc/onboarding_state.dart';
import 'package:lumo/features/onboarding/presentation/widgets/onboarding_background.dart';
import 'package:lumo/features/onboarding/presentation/widgets/lumo_continue_button.dart';
import 'package:lumo/features/onboarding/presentation/widgets/mascot_carousel.dart';

class MascotSelectPage extends StatefulWidget {
  const MascotSelectPage({super.key});

  @override
  State<MascotSelectPage> createState() => _MascotSelectPageState();
}

class _MascotSelectPageState extends State<MascotSelectPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _cardOpacity;
  late Animation<Offset> _cardSlide;

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
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic));

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
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  
                  // Less spacing on top for mascot page to fit everything
                  const Spacer(flex: 2),

                  // Content
                  FadeTransition(
                    opacity: _cardOpacity,
                    child: SlideTransition(
                      position: _cardSlide,
                      child: Column(
                        children: [
                          Text(
                            "Choose your mascot",
                            style: GoogleFonts.nunito(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "They will be your guide on your journey.",
                            style: GoogleFonts.nunito(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),

                          MascotCarousel(
                            selectedIndex: state.selectedMascotIndex,
                            onMascotTap: (index) {
                              context
                                  .read<OnboardingBloc>()
                                  .add(OnboardingMascotSelected(index));
                            },
                          ),

                          const SizedBox(height: 32),

                          LumoContinueButton(
                            label: 'Select',
                            onTap: () => context
                                .read<OnboardingBloc>()
                                .add(const OnboardingNextPage()),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(flex: 1),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
