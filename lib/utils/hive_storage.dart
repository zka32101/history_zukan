import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/index.dart';

/// Hive storage for chat histories using JSON strings.
/// Uses Box<String> to avoid Hive adapter dependency on nested ChatMessage.
class ChatHistoryStorage {
  static const String boxName = 'chat_histories_json';

  static Box<String> get _box => Hive.box<String>(boxName);

  static ChatHistory? load(String personId) {
    final raw = _box.get(personId);
    if (raw == null) return null;
    try {
      return ChatHistory.fromJson(
          Map<String, dynamic>.from(jsonDecode(raw) as Map));
    } catch (_) {
      return null;
    }
  }

  static Future<void> save(ChatHistory history) async {
    await _box.put(history.personId, jsonEncode(history.toJson()));
  }

  static Future<void> delete(String personId) async {
    await _box.delete(personId);
  }
}
