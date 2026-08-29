/// アップデート情報（更新履歴）
///
/// 新しいバージョンをリリースするたびに、リストの先頭に [ChangelogEntry] を
/// 追加すること。[version] は `AppConstants.appVersion`（`pubspec.yaml` の
/// version とも一致させる）と合わせる。
class ChangelogEntry {
  final String version;
  final String date; // YYYY-MM-DD
  final List<String> notes;

  const ChangelogEntry({
    required this.version,
    required this.date,
    required this.notes,
  });
}

/// 更新履歴（新しい順）
const List<ChangelogEntry> kChangelog = [
  ChangelogEntry(
    version: '1.0.0',
    date: '2026-08-29',
    notes: [
      '「たくさん知りたくなる歴史図鑑」を公開しました。',
      '人物図鑑（300人）・世界同時パノラマ・自分年表・ここ歴史・テーマ別学習を追加しました。',
      '今日の偉人（ガチャ）・クイズ・パズル・診断・ログインストリークなどのミニ機能を追加しました。',
      '使い方ガイド、アップデート情報、ご意見・不具合報告フォームを追加しました。',
    ],
  ),
];
