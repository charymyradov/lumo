import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:lumo/core/constants/ai_config.dart';
import 'package:lumo/core/error/exceptions.dart';
import 'package:lumo/features/tasks/data/models/quest_model.dart';
import 'package:lumo/features/tasks/domain/entities/quest.dart';

/// Gemini `generateContent` REST çağrısı.
/// Dönen metinden JSON gövdeyi ayıklar, [Quest] listelerine çevirir.
class QuestRemoteDataSource {
  final http.Client _client;

  QuestRemoteDataSource({http.Client? client})
      : _client = client ?? http.Client();

  static const _timeout = Duration(seconds: 25);

  static const _systemPrompt = '''
Sen Lumo adlı sevimli bir alışkanlık/pet oyununun görev üreticisisin.
Kullanıcı Türkçe konuşur; TÜM metinleri Türkçe yaz.
SADECE geçerli JSON döndür — açıklama, markdown, kod bloğu YOK.
Şema: {"daily": [Quest x4], "weekly": [Quest x3]}
Quest: {"title": "kısa vurucu başlık (en fazla 40 karakter)",
"subtitle": "tek cümle motive edici açıklama",
"reward": 10-60 arası coin,
"duration": "5 dk" / "20 dk" / "3 seans" gibi kısa süre,
"category": "water|move|breath|mind|journal|sport|social|health|sleep" içinden biri}
Kurallar: küçük adımlar, pozitif dil, tekrar yok, günlükler 1 günde bitecek işler.
''';

  /// [context]: kullanıcıyı kişiselleştirmek için serbest metin
  /// (örn. hedefler, seri günü). Boş olabilir.
  Future<QuestBundle> fetchQuests({String context = ''}) async {
    final apiKey = AiConfig.geminiApiKey;
    if (apiKey.isEmpty) throw const MissingApiKeyException();

    final today = DateTime.now();
    final userText = '''
Bugünün tarihi: ${today.day}.${today.month}.${today.year}.
${context.trim().isEmpty ? '' : 'Kullanıcı bağlamı: ${context.trim()}\n'}
4 günlük + 3 haftalık görev üret.
''';

    final uri = Uri.parse(
        '${AiConfig.geminiEndpoint}?key=${Uri.encodeQueryComponent(apiKey)}');

    late final http.Response res;
    try {
      res = await _client
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'system_instruction': {
                'parts': [
                  {'text': _systemPrompt}
                ]
              },
              'generationConfig': {
                'temperature': 0.9,
                'maxOutputTokens': 1400,
                'responseMimeType': 'application/json',
              },
              'contents': [
                {
                  'parts': [
                    {'text': userText}
                  ]
                }
              ],
            }),
          )
          .timeout(_timeout);
    } on TimeoutException {
      throw const ServerException('Yapay zekâ zaman aşımına uğradı');
    } catch (e) {
      throw ServerException('Ağ hatası: $e');
    }

    if (res.statusCode == 400) {
      throw const ServerException(
          'Gemini isteği reddetti (anahtar/model kontrol et)', 400);
    }
    if (res.statusCode == 403 || res.statusCode == 401) {
      throw ServerException(
          'API anahtarı geçersiz (kod ${res.statusCode})', res.statusCode);
    }
    if (res.statusCode == 429) {
      throw const ServerException('Limit doldu, biraz sonra dene', 429);
    }
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw ServerException('Sunucu hatası (${res.statusCode})',
          res.statusCode);
    }

    try {
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      final candidates = body['candidates'] as List?;
      if (candidates == null || candidates.isEmpty) {
        throw const FormatException('candidates boş');
      }
      final content =
          candidates.first['content'] as Map<String, dynamic>?;
      final parts = content?['parts'] as List?;
      if (parts == null || parts.isEmpty) {
        throw const FormatException('parts boş');
      }
      final text = parts
          .map((p) => (p as Map<String, dynamic>)['text'] as String? ?? '')
          .join();
      return _parseBundle(text);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('AI cevabı çözülemedi: $e');
    }
  }

  QuestBundle _parseBundle(String text) {
    // Model bazen ```json fences ekler — ilk { ile son } arasını al.
    final start = text.indexOf('{');
    final end = text.lastIndexOf('}');
    if (start < 0 || end <= start) {
      throw const FormatException('JSON gövde bulunamadı');
    }
    final decoded =
        jsonDecode(text.substring(start, end + 1)) as Map<String, dynamic>;

    List<Quest> parseList(dynamic raw, String type) {
      if (raw is! List) return [];
      final out = <Quest>[];
      for (var i = 0; i < raw.length; i++) {
        final item = raw[i];
        if (item is! Map<String, dynamic>) continue;
        try {
          out.add(QuestModel.fromJson(item, '${type}_$i'));
        } on FormatException {
          continue; // bozuk öğeyi atla, kalanı göster
        }
      }
      return out;
    }

    final daily = parseList(decoded['daily'], 'daily');
    final weekly = parseList(decoded['weekly'], 'weekly');
    if (daily.isEmpty && weekly.isEmpty) {
      throw const FormatException('Görev listesi boş');
    }
    return QuestBundle(
      daily: daily,
      weekly: weekly,
      source: QuestSource.fresh,
      fetchedAt: DateTime.now(),
    );
  }
}
