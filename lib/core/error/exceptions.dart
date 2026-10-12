/// Uygulama genelinde yakalanan düşük seviye hatalar.
/// Katmanlar bunları fırlatır, cubit/bloc kullanıcı dostu mesaja çevirir.
class ServerException implements Exception {
  final String message;
  final int? statusCode;

  const ServerException(this.message, [this.statusCode]);

  @override
  String toString() => 'ServerException($statusCode): $message';
}

class CacheException implements Exception {
  final String message;

  const CacheException([this.message = 'Önbellek okunamadı']);

  @override
  String toString() => 'CacheException: $message';
}

class MissingApiKeyException implements Exception {
  const MissingApiKeyException();

  @override
  String toString() =>
      'MissingApiKeyException: Gemini API anahtarı tanımlı değil';
}
