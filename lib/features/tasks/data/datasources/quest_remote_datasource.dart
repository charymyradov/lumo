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
You are the quest generator for Lumo, a cute habit/pet game.
The user speaks English; write ALL text in English.
Return valid JSON ONLY — no explanations, no markdown, no code blocks.
Schema: {"daily": [Quest x4], "weekly": [Quest x3]}
Quest: {"title": "short punchy title (max 40 characters)",
"subtitle": "one motivational sentence",
"reward": 10-60 coins,
"duration": short duration like "5 min" / "20 min" / "3 sessions",
"category": one of "water|move|breath|mind|journal|sport|social|health|sleep"}
Rules: small steps, positive language, no repetition, daily quests are tasks completable in 1 day.
''';

  /// [promptContext]: kullanıcıyı kişiselleştirmek için serbest metin
  /// (örn. hedefler, seri günü). Boş olabilir.
  Future<QuestBundle> fetchQuests({String promptContext = ''}) async {
    final apiKey = AiConfig.geminiApiKey;
    if (apiKey.isEmpty) throw const MissingApiKeyException();

    final today = DateTime.now();
    final userText = '''
Today's date: ${today.day}.${today.month}.${today.year}.
${promptContext.trim().isEmpty ? '' : 'User context: ${promptContext.trim()}\n'}
Generate 4 daily + 3 weekly quests.
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
      throw const ServerException('AI request timed out');
    } catch (e) {
      throw ServerException('Network error: $e');
    }

    if (res.statusCode == 400) {
      throw const ServerException(
          'Gemini request rejected (check API key/model)', 400);
    }
    if (res.statusCode == 403 || res.statusCode == 401) {
      throw ServerException(
          'Invalid API key (code ${res.statusCode})', res.statusCode);
    }
    if (res.statusCode == 429) {
      throw const ServerException('Rate limit reached, try again later', 429);
    }
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw ServerException('Server error (${res.statusCode})', res.statusCode);
    }

    try {
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      final candidates = body['candidates'] as List?;
      if (candidates == null || candidates.isEmpty) {
        throw const FormatException('candidates empty');
      }
      final content = candidates.first['content'] as Map<String, dynamic>?;
      final parts = content?['parts'] as List?;
      if (parts == null || parts.isEmpty) {
        throw const FormatException('parts empty');
      }
      final text = parts
          .map((p) => (p as Map<String, dynamic>)['text'] as String? ?? '')
          .join();
      return _parseBundle(text);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Could not parse AI response: $e');
    }
  }

  QuestBundle _parseBundle(String text) {
    // Model bazen ```json fences ekler — ilk { ile son } arasını al.
    final start = text.indexOf('{');
    final end = text.lastIndexOf('}');
    if (start < 0 || end <= start) {
      throw const FormatException('JSON body not found');
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
      throw const FormatException('Quest list is empty');
    }
    return QuestBundle(
      daily: daily,
      weekly: weekly,
      source: QuestSource.fresh,
      fetchedAt: DateTime.now(),
    );
  }
}
