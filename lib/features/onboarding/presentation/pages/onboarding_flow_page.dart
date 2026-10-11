import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lumo/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:lumo/features/onboarding/presentation/bloc/onboarding_state.dart';
import 'package:lumo/features/onboarding/presentation/pages/welcome_page.dart';
import 'package:lumo/features/onboarding/presentation/pages/goal_page.dart';
import 'package:lumo/features/onboarding/presentation/pages/mascot_select_page.dart';
import 'package:lumo/features/onboarding/presentation/pages/permissions_page.dart';

class OnboardingFlowPage extends StatefulWidget {
  const OnboardingFlowPage({super.key});

  @override
  State<OnboardingFlowPage> createState() => _OnboardingFlowPageState();
}

class _OnboardingFlowPageState extends State<OnboardingFlowPage> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OnboardingBloc, OnboardingState>(
      listenWhen: (previous, current) => previous.currentPage != current.currentPage,
      listener: (context, state) {
        _pageController.animateToPage(
          state.currentPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOutCubic,
        );
      },
      builder: (context, state) {
        return Scaffold(
          body: PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(), // Prevent manual swipe
            children: const [
              WelcomePage(),
              GoalPage(),
              MascotSelectPage(),
              PermissionsPage(),
            ],
          ),
        );
      },
    );
  }
}
