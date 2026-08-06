import 'package:history_zukan/models/history_person.dart';

/// 人物の国・生年から、6種類のAI生成プレースホルダー画像のうち
/// どれを表示すべきかを判定する。Firestoreの imageUrl が読み込めない場合の
/// フォールバック表示に使う（assets/images/person_placeholders/）。
///
/// 判定ロジック:
/// - 日本 かつ 1868年（明治維新）より前 -> jp_ancient（古代〜江戸）
/// - 日本 かつ 1868〜1945年生まれ -> jp_modern（明治〜昭和）
/// - 日本 かつ 1945年以降生まれ -> jp_contemporary（現代）
/// - 西洋圏 かつ 1400年より前 -> world_ancient（古代〜中世）
/// - 西洋圏 かつ 1400年以降 -> world_renaissance（ルネサンス〜現代）
/// - それ以外（アフリカ・中東・日本以外のアジア等） -> world_other
String personPlaceholderKey(HistoryPerson person) {
  final year = int.tryParse(
    (person.birthYear ?? '').replaceAll(RegExp(r'[^0-9-]'), ''),
  );

  if (person.country.contains('日本')) {
    if (year == null || year < 1868) return 'jp_ancient';
    if (year < 1945) return 'jp_modern';
    return 'jp_contemporary';
  }

  const westernCountries = [
    'イタリア', 'フランス', 'イギリス', 'ドイツ', 'ギリシャ', 'ギリシア', 'ローマ',
    'アメリカ', 'スペイン', 'オランダ', 'ポーランド', 'ロシア', 'ポルトガル',
    'オーストリア', 'スイス', 'ノルウェー', 'スウェーデン', 'デンマーク',
  ];
  final isWestern = westernCountries.any((c) => person.country.contains(c));

  if (isWestern) {
    if (year == null || year < 1400) return 'world_ancient';
    return 'world_renaissance';
  }

  return 'world_other';
}
