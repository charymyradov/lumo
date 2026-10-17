import 'package:flutter/material.dart';

/// Uygulama geneli sayfa geçişi: 220ms easeOutCubic fade + slide.
///
/// Tüm `MaterialPageRoute` kullanımları yerine bunu kullanın ki
/// geçiş maliyeti sabit ve öngörülebilir kalsın.
class AppPageRoute<T> extends PageRouteBuilder<T> {
  static const Duration transitionDurationConst = Duration(milliseconds: 220);
  static const Duration reverseTransitionDurationConst =
      Duration(milliseconds: 220);
  static const Curve transitionCurve = Curves.easeOutCubic;

  AppPageRoute({required Widget page, super.settings})
      : super(
          transitionDuration: transitionDurationConst,
          reverseTransitionDuration: reverseTransitionDurationConst,
          maintainState: true,
          opaque: true,
          barrierDismissible: false,
          pageBuilder: (_, __, ___) => page,
          transitionsBuilder: (_, animation, __, child) {
            final curved = CurvedAnimation(
              parent: animation,
              curve: transitionCurve,
            );
            return FadeTransition(
              opacity: curved,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.06),
                  end: Offset.zero,
                ).animate(curved),
                child: child,
              ),
            );
          },
        );
}

/// Standart push — [AppPageRoute] ile.
Future<T?> pushAppPage<T>(BuildContext context, Widget page) {
  return Navigator.of(context).push<T>(
    AppPageRoute<T>(page: page),
  );
}

/// Standart pushReplacement — [AppPageRoute] ile.
Future<T?> pushReplacementAppPage<T>(BuildContext context, Widget page) {
  return Navigator.of(context).pushReplacement<T, Object?>(
    AppPageRoute<T>(page: page),
  );
}
