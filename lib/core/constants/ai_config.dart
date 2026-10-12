/// Yapay zekâ (Gemini) yapılandırması.
///
/// ## API anahtarı nasıl eklenir?
///
/// **Önerilen:** anahtarı koda gömmek yerine derleme anında ver —
/// koda yazılan anahtar git'e düşer ve çalınabilir:
/// ```
/// flutter run --dart-define=GEMINI_API_KEY=AIza...senin_anahtarin
/// ```
///
/// **Pratik yol:** aşağıdaki [_embeddedKey] sabitine anahtarını yapıştır.
/// Anahtar yoksa uygulama çökmez; görevler yerleşik listeden + önbellekten gelir.
class AiConfig {
  AiConfig._();

  static const String _embeddedKey = 'BURAYA_GEMINI_API_KEY_YAZ';

  /// Önce `--dart-define=GEMINI_API_KEY`, yoksa gömülü sabit kullanılır.
  static String get geminiApiKey {
    const env = String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');
    if (env.isNotEmpty) return env;
    if (_embeddedKey.startsWith('BURAYA_')) return '';
    return _embeddedKey;
  }

  static bool get hasGeminiKey => geminiApiKey.isNotEmpty;

  /// Hızlı + ucuz JSON üretimi için Flash modeli.
  static const String geminiModel = 'gemini-2.0-flash';

  static String get geminiEndpoint =>
      'https://generativelanguage.googleapis.com/v1beta/models/$geminiModel:generateContent';
}
