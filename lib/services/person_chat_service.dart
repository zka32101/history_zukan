import 'package:cloud_functions/cloud_functions.dart';
import 'package:history_zukan/models/index.dart';

/// PersonChatService handles Claude Haiku AI interactions via Firebase Cloud Function.
/// Phase 2: D1 Feature
class PersonChatService {
  static const int _maxTokensPerResponse = 300;
  static const int _maxMessageLength = 500;
  static const int _maxContextMessages = 6; // last 3 exchanges
  static const int _maxServerMessages = 20; // mirrors functions/index.js cap

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

    final messages = _convertToApiFormat(conversationHistory, userMessage);
    if (messages.length > _maxServerMessages) {
      throw Exception('会話が長すぎます。');
    }

    try {
      // NOTE: only personId is sent — the Cloud Function looks up the
      // person and builds the system prompt server-side. Never send a
      // client-constructed system prompt: a client could otherwise turn
      // this callable into an arbitrary, unmoderated Claude proxy.
      final result = await _callable.call({
        'personId': person.id,
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
    } catch (_) {
      // Network failures, malformed responses, etc. — never leak the raw
      // exception (which may contain internal details) to the UI.
      throw Exception('通信エラーが発生しました。しばらくしてからもう一度お試しください。');
    }
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
