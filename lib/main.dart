import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lumo/core/constants/app_colors.dart';
import 'package:lumo/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:lumo/features/splash/presentation/pages/splash_page.dart';
import 'package:lumo/features/onboarding/presentation/pages/onboarding_flow_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
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
        ),
        home: SplashPage(
          onFinished: () {
            // Navigator is handled inside a Builder or using a GlobalKey, 
            // but for simplicity we will just use a minimal approach here.
          },
        ),
        // We will use a wrapper widget to handle navigation from splash
        builder: (context, child) {
          return Navigator(
            onGenerateRoute: (settings) {
              return MaterialPageRoute(
                builder: (context) => const AppRoot(),
              );
            },
          );
        },
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
  bool _showSplash = true;

  void _onSplashFinished() {
    setState(() {
      _showSplash = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 800),
      child: _showSplash
          ? SplashPage(onFinished: _onSplashFinished)
          : const OnboardingFlowPage(),
    );
  }
}
