import 'package:equatable/equatable.dart';
import 'package:lumo/core/error/exceptions.dart';

/// Domain katmanının UI'ya ilettiği tip güvenli hata modeli.
/// Exception'lar data'da fırlatılır, burada Failure'a çevrilir,
/// Bloc kullanıcı dostu mesaja dönüştürür.
abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  final int? statusCode;
  const ServerFailure(super.message, [this.statusCode]);

  @override
  List<Object?> get props => [message, statusCode];
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Could not read cache']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection']);
}

class MissingApiKeyFailure extends Failure {
  const MissingApiKeyFailure(
      [super.message = 'Gemini API key is not configured']);
}

/// Data katmanı exception'larını UI dostu [Failure] modeline çevirir.
/// Repository ve Bloc'lar ham `toString()` yerine bunu kullanır.
Failure failureFromException(Object e) {
  if (e is MissingApiKeyException) {
    return const MissingApiKeyFailure();
  }
  if (e is CacheException) {
    return CacheFailure(e.message);
  }
  if (e is ServerException) {
    if (e.statusCode == 401 || e.statusCode == 403) {
      return NetworkFailure('Invalid API key (code ${e.statusCode})');
    }
    if (e.statusCode == 429) {
      return ServerFailure(e.message, e.statusCode);
    }
    if (e.message.contains('timed out') ||
        e.message.contains('Network error')) {
      return const NetworkFailure();
    }
    return ServerFailure(e.message, e.statusCode);
  }
  if (e is Failure) return e;
  return ServerFailure(e.toString());
}
