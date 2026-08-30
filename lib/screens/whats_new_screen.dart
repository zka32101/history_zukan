import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:history_zukan/constants/changelog.dart';
import 'package:history_zukan/widgets/gradient_app_bar.dart';

/// アプリのバージョン既読管理（起動時に「アップデート情報」を自動表示するかどうかの判定に使う）
///
/// `chat_histories_json` などと同じく Hive の `Box<String>` を使う
/// （型付きモデルの Hive アダプタを新設しなくて済むため、この環境のように
/// build_runner が使えない場合でも安全に追加できる）。
class AppMetaStorage {
  static const String boxName = 'app_meta';
  static const String _lastSeenVersionKey = 'lastSeenVersion';

  static Box<String> get _box => Hive.box<String>(boxName);

  /// 前回起動時に表示した最新バージョンを取得（未記録なら null）
  static String? get lastSeenVersion => _box.get(_lastSeenVersionKey);

  static Future<void> markVersionSeen(String version) async {
    await _box.put(_lastSeenVersionKey, version);
  }
}

/// アップデート情報（更新履歴）画面
class WhatsNewScreen extends StatelessWidget {
  const WhatsNewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GradientAppBar(title: 'アップデート情報'),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: kChangelog.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final entry = kChangelog[index];
          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6A1B9A).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'v${entry.version}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF6A1B9A),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        entry.date,
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...entry.notes.map(
                    (note) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
                          Expanded(child: Text(note, style: const TextStyle(height: 1.4))),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
