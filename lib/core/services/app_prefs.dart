import 'package:shared_preferences/shared_preferences.dart';

/// Uygulama geneli kalıcı küçük bayraklar.
class AppPrefs {
  AppPrefs._();

  static const String onboardingCompletedKey = 'onboarding_completed_v1';

  static Future<bool> isOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(onboardingCompletedKey) ?? false;
  }

  static Future<void> setOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(onboardingCompletedKey, true);
  }
}
