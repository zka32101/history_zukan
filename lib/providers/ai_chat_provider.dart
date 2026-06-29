import 'package:history_zukan/models/index.dart';
import 'package:history_zukan/services/person_chat_service.dart';
import 'package:history_zukan/utils/hive_storage.dart';
import 'package:riverpod/riverpod.dart';
import 'package:uuid/uuid.dart';

final personChatServiceProvider = Provider((ref) => PersonChatService());

class ChatHistoryNotifier extends StateNotifier<ChatHistory> {
  final PersonChatService _chatService;
  final String _personId;

  ChatHistoryNotifier(
    this._chatService,
    this._personId,
    ChatHistory initialState,
  ) : super(initialState);

  Future<void> sendMessage(String userMessage, HistoryPerson person) async {
    if (!state.hasQuota) {
      throw Exception(
          '会話上限（${state.maxConversations}回）に達しました。アドオン購入でリセットできます。');
    }

    final userMsg = ChatMessage(
      id: const Uuid().v4(),
      role: 'user',
      content: userMessage,
      timestamp: DateTime.now(),
      tokenCount: _chatService.estimateTokens(userMessage),
    );

    state = state.copyWith(
      messages: [...state.messages, userMsg],
      lastUpdated: DateTime.now(),
    );

    try {
      final response = await _chatService.sendMessage(
        person: person,
        userMessage: userMessage,
        conversationHistory: state.messages,
      );

      final assistantMsg = ChatMessage(
        id: const Uuid().v4(),
        role: 'assistant',
        content: response,
        timestamp: DateTime.now(),
        tokenCount: _chatService.estimateTokens(response),
      );

      state = state.copyWith(
        messages: [...state.messages, assistantMsg],
        totalConversations: state.totalConversations + 1,
        lastUpdated: DateTime.now(),
      );

      await ChatHistoryStorage.save(state);
    } catch (e) {
      // ユーザーメッセージをロールバック
      state = state.copyWith(
        messages: state.messages.where((m) => m.id != userMsg.id).toList(),
      );
      rethrow;
    }
  }

  Future<void> clearHistory() async {
    state = state.copyWith(messages: [], lastUpdated: DateTime.now());
    await ChatHistoryStorage.save(state);
  }

  Future<void> resetQuota() async {
    state = state.copyWith(totalConversations: 0, lastUpdated: DateTime.now());
    await ChatHistoryStorage.save(state);
  }
}

/// Hive から読み込んで初期化（人物ごとに1インスタンス）
final chatHistoryProvider =
    StateNotifierProvider.family<ChatHistoryNotifier, ChatHistory, String>(
  (ref, personId) {
    final loaded = ChatHistoryStorage.load(personId);
    return ChatHistoryNotifier(
      ref.watch(personChatServiceProvider),
      personId,
      loaded ?? ChatHistory.initial(personId, 'Unknown Person'),
    );
  },
);

final remainingQuotaProvider = Provider.family<int, String>((ref, personId) {
  return ref.watch(chatHistoryProvider(personId)).remainingQuota;
});

final hasQuotaProvider = Provider.family<bool, String>((ref, personId) {
  return ref.watch(chatHistoryProvider(personId)).hasQuota;
});

final sendMessageProvider = FutureProvider.family
    .autoDispose<void, (String, String, HistoryPerson)>((ref, params) async {
  final (personId, message, person) = params;
  await ref
      .read(chatHistoryProvider(personId).notifier)
      .sendMessage(message, person);
});
