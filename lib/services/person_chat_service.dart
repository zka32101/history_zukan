import 'package:cloud_functions/cloud_functions.dart';
import 'package:history_zukan/models/index.dart';

/// PersonChatService handles Claude Haiku AI interactions via Firebase Cloud Function.
/// Phase 2: D1 Feature
class PersonChatService {
  static const int _maxTokensPerResponse = 300;
  static const int _maxMessageLength = 500;
  static const int _maxContextMessages = 6; // last 3 exchanges

  final _callable =
      FirebaseFunctions.instanceFor(region: 'asia-northeast1')
          .httpsCallable('personChat');

  /// Send a message to Claude Haiku as a historical person.
  Future<String> sendMessage({
    required HistoryPerson person,
    required String userMessage,
    required List<ChatMessage> conversationHistory,
  }) async {
    if (userMessage.length > _maxMessageLength) {
      throw Exception('メッセージが長すぎます（最大${_maxMessageLength}文字）。');
    }

    final systemPrompt = _buildSystemPrompt(person);
    final messages = _convertToApiFormat(conversationHistory, userMessage);

    try {
      final result = await _callable.call({
        'personName': person.name,
        'systemPrompt': systemPrompt,
        'messages': messages,
        'maxTokens': _maxTokensPerResponse,
      });

      final data = result.data as Map<Object?, Object?>;
      final message = data['message'] as String?;
      if (message == null || message.isEmpty) {
        throw Exception('応答が空でした。');
      }
      return message;
    } on FirebaseFunctionsException catch (e) {
      switch (e.code) {
        case 'unauthenticated':
          throw Exception('ログインが必要です。');
        case 'resource-exhausted':
          throw Exception('APIの利用制限に達しました。しばらくお待ちください。');
        case 'invalid-argument':
          throw Exception('無効なリクエストです。');
        default:
          throw Exception('通信エラー: ${e.message}');
      }
    }
  }

  String _buildSystemPrompt(HistoryPerson person) {
    final quotes = person.famousQuotes?.join('\n') ?? '';
    final timeline = person.lifeTimeline?.entries
            .map((e) => '${e.key}: ${e.value}')
            .join('\n') ??
        '';

    return '''あなたは${person.name}（${person.birthYear}〜${person.deathYear}年）になりきって会話します。

背景: ${person.description}
性格: ${person.personality ?? '不詳'}

${quotes.isNotEmpty ? '名言:\n$quotes\n' : ''}${timeline.isNotEmpty ? '主要事件:\n$timeline\n' : ''}
会話ルール:
1. 一人称を「我」「わし」など歴史人物らしく使う
2. 5〜8文で簡潔に答える
3. 日本語のみで回答する
4. 歴史的に正確な情報を提供する
5. 子ども（小学生）にもわかりやすく話す''';
  }

  List<Map<String, String>> _convertToApiFormat(
    List<ChatMessage> history,
    String newUserMessage,
  ) {
    final recent = history.length > _maxContextMessages
        ? history.sublist(history.length - _maxContextMessages)
        : history;

    return [
      ...recent.map((m) => {'role': m.role, 'content': m.content}),
      {'role': 'user', 'content': newUserMessage},
    ];
  }

  int estimateTokens(String text) {
    // Japanese: roughly 1.5 chars per token
    return (text.length / 1.5).ceil();
  }
}
