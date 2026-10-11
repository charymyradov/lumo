import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lumo/core/constants/app_colors.dart';
import 'package:lumo/core/router/main_shell.dart';
import 'package:lumo/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:lumo/features/onboarding/presentation/bloc/onboarding_event.dart';
import 'package:lumo/features/onboarding/presentation/widgets/onboarding_background.dart';
import 'package:lumo/features/onboarding/presentation/widgets/lumo_continue_button.dart';
import 'package:lumo/features/onboarding/presentation/widgets/permission_tile.dart';

class PermissionsPage extends StatefulWidget {
  const PermissionsPage({super.key});

  @override
  State<PermissionsPage> createState() => _PermissionsPageState();
}

class _PermissionsPageState extends State<PermissionsPage>
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
    return OnboardingBackground(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 20),

              const Spacer(flex: 2),

              // Content
              FadeTransition(
                opacity: _cardOpacity,
                child: SlideTransition(
                  position: _cardSlide,
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(32),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                          child: Container(
                            padding: const EdgeInsets.all(28),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(32),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.5),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      AppColors.primary.withValues(alpha: 0.1),
                                  blurRadius: 30,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Text(
                                  "İzinlere izin ver",
                                  style: GoogleFonts.nunito(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                const PermissionTile(
                                  icon: Icons.notifications_active_rounded,
                                  iconBgColor: AppColors.permissionBlue,
                                  title: 'Notifications',
                                  subtitle:
                                      'Important reminders and motivational messages',
                                ),
                                const PermissionTile(
                                  icon: Icons.favorite_rounded,
                                  iconBgColor: AppColors.permissionRed,
                                  title: 'Health Data\n(Optional)',
                                  subtitle: 'Activity tracking',
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  "We keep your data safe.",
                                  style: GoogleFonts.nunito(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textHint,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      LumoContinueButton(
                        label: 'Devam Et',
                        onTap: () {
                          // Complete onboarding logic
                          context
                              .read<OnboardingBloc>()
                              .add(const OnboardingCompleted());

                          // Enter the main app shell (bottom nav + tabs)
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (_) => const MainShell(),
                            ),
                          );
                        },
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
  }
}
