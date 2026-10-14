import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lumo/core/constants/app_colors.dart';
import 'package:lumo/core/router/main_shell.dart';
import 'package:lumo/core/services/app_prefs.dart';
import 'package:lumo/core/di/injection.dart';
import 'package:lumo/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:lumo/features/splash/presentation/pages/splash_page.dart';
import 'package:lumo/features/onboarding/presentation/pages/onboarding_flow_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  await configureDependencies();
  runApp(const LumoApp());
}

class LumoApp extends StatelessWidget {
  const LumoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => OnboardingBloc()),
      ],
      child: MaterialApp(
        title: 'Lumo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
          useMaterial3: true,
          scaffoldBackgroundColor: AppColors.bgDark,
          fontFamily: 'Nunito',
        ),
        home: const AppRoot(),
      ),
    );
  }
}

class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  /// null = henüz diskten okunmadı.
  bool? _onboardingCompleted;
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    _loadOnboardingFlag();
  }

  Future<void> _loadOnboardingFlag() async {
    final completed = await AppPrefs.isOnboardingCompleted();
    if (!mounted) return;
    setState(() {
      _onboardingCompleted = completed;
      // Daha önce tamamlanmışsa splash/onboarding atlanır, direkt home.
      if (completed) _showSplash = false;
    });
  }

  void _onSplashFinished() {
    setState(() {
      _showSplash = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Disk okunurken kısa splash göster (boş ekran çakmasını önler).
    // Bu dal yalnızca ilk açılışta görülür; onFinished boş bırakılmaz,
    // bayrak yüklenince zaten gerçek dallara geçilir.
    if (_onboardingCompleted == null) {
      return SplashPage(onFinished: _onSplashFinished);
    }
    if (_onboardingCompleted == true) {
      return const MainShell();
    }
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 800),
      child: _showSplash
          ? SplashPage(onFinished: _onSplashFinished)
          : const OnboardingFlowPage(),
    );
  }
}
