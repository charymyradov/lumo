class AiConfig {
  AiConfig._();

  static const String _embeddedKey =
      'AQ.Ab8RN6I9mGrK05cZTiiHxbo77Qd6G3vqcWDcnvVcJfSqO98Cig';

  /// Önce `--dart-define=GEMINI_API_KEY`, yoksa gömülü sabit kullanılır.
  static String get geminiApiKey {
    const env = String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');
    if (env.isNotEmpty) return env;
    if (_embeddedKey.startsWith('BURAYA_')) return '';
    return _embeddedKey;
  }

  static bool get hasGeminiKey => geminiApiKey.isNotEmpty;

  /// Hızlı + ucuz JSON üretimi için Flash modeli.
  static const String geminiModel = 'gemini-2.5-flash';

  static String get geminiEndpoint =>
      'https://generativelanguage.googleapis.com/v1beta/models/$geminiModel:generateContent';
}
