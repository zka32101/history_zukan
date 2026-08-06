import 'package:hive_flutter/hive_flutter.dart';

part 'login_models.g.dart';

// =========================================
// Login Streak Models
// =========================================

/// ログイン連続日数状態 (Hive: login_streaks)
@HiveType(typeId: 21)
class LoginStreak {
  @HiveField(0)
  final int consecutiveDays;

  @HiveField(1)
  final DateTime lastLoginDate;

  @HiveField(2)
  final int totalLoginDays; // 累計（リセット対象外）

  @HiveField(3)
  final String currentEra;

  LoginStreak({
    required this.consecutiveDays,
    required this.lastLoginDate,
    required this.totalLoginDays,
    required this.currentEra,
  });

  factory LoginStreak.fromJson(Map<String, dynamic> json) => LoginStreak(
        consecutiveDays: json['consecutiveDays'] as int,
        lastLoginDate: DateTime.parse(json['lastLoginDate'] as String),
        totalLoginDays: json['totalLoginDays'] as int,
        currentEra: json['currentEra'] as String,
      );

  Map<String, dynamic> toJson() => {
        'consecutiveDays': consecutiveDays,
        'lastLoginDate': lastLoginDate.toIso8601String(),
        'totalLoginDays': totalLoginDays,
        'currentEra': currentEra,
      };
}

/// 時代マスタ (const)
class EraJourney {
  final String id;
  final String name;
  final String japaneseName;
  final int daysToReach;
  final int position;
  final String description; // 時代説明

  const EraJourney({
    required this.id,
    required this.name,
    required this.japaneseName,
    required this.daysToReach,
    required this.position,
    required this.description,
  });
}

/// 時代進捗状態
class EraProgress {
  final EraJourney era;
  final bool reached;
  final DateTime? reachedDate;

  EraProgress({
    required this.era,
    required this.reached,
    this.reachedDate,
  });
}

/// ログイン状態チェック結果
class LoginCheckResult {
  final bool isNewDay;
  final int consecutiveDays;
  final int totalLoginDays;
  final bool eraChanged; // 新しい時代に到達したか
  final EraJourney? newEra;

  LoginCheckResult({
    required this.isNewDay,
    required this.consecutiveDays,
    required this.totalLoginDays,
    required this.eraChanged,
    this.newEra,
  });
}

/// 時代マスタデータ
const List<EraJourney> ERAS_JOURNEY = [
  EraJourney(
    id: 'jomon',
    name: 'Jomon',
    japaneseName: '縄文時代',
    daysToReach: 7,
    position: 0,
    description: '日本最古の文明。狩猟採集から農業へ。',
  ),
  EraJourney(
    id: 'yayoi',
    name: 'Yayoi',
    japaneseName: '弥生時代',
    daysToReach: 14,
    position: 1,
    description: '稲作農業の伝来。社会階級の形成。',
  ),
  EraJourney(
    id: 'kofun',
    name: 'Kofun',
    japaneseName: '古墳時代',
    daysToReach: 21,
    position: 2,
    description: '大型古墳の造営。ヤマト王権の発展。',
  ),
  EraJourney(
    id: 'asuka',
    name: 'Asuka',
    japaneseName: '飛鳥時代',
    daysToReach: 30,
    position: 3,
    description: '仏教伝来。聖徳太子の時代。',
  ),
  EraJourney(
    id: 'nara',
    name: 'Nara',
    japaneseName: '奈良時代',
    daysToReach: 45,
    position: 4,
    description: '奈良に都を置く。律令制度の確立。',
  ),
  EraJourney(
    id: 'heian',
    name: 'Heian',
    japaneseName: '平安時代',
    daysToReach: 60,
    position: 5,
    description: '京都に都を移す。貴族文化の最盛期。',
  ),
  EraJourney(
    id: 'kamakura',
    name: 'Kamakura',
    japaneseName: '鎌倉時代',
    daysToReach: 80,
    position: 6,
    description: '武士の政権。源頼朝の幕府。',
  ),
  EraJourney(
    id: 'muromachi',
    name: 'Muromachi',
    japaneseName: '室町時代',
    daysToReach: 100,
    position: 7,
    description: '南北朝の争い。応仁の乱。',
  ),
  EraJourney(
    id: 'azuchi',
    name: 'Azuchi-Momoyama',
    japaneseName: '安土桃山時代',
    daysToReach: 120,
    position: 8,
    description: '織田信長・豊臣秀吉による統一。',
  ),
  EraJourney(
    id: 'edo',
    name: 'Edo',
    japaneseName: '江戸時代',
    daysToReach: 150,
    position: 9,
    description: '徳川幕府による安定。約260年続く。',
  ),
  EraJourney(
    id: 'meiji',
    name: 'Meiji',
    japaneseName: '明治時代',
    daysToReach: 180,
    position: 10,
    description: '明治維新。近代日本の誕生。',
  ),
  EraJourney(
    id: 'taisho',
    name: 'Taisho',
    japaneseName: '大正時代',
    daysToReach: 200,
    position: 11,
    description: '大正デモクラシー。文化の中心地。',
  ),
  EraJourney(
    id: 'showa',
    name: 'Showa',
    japaneseName: '昭和時代',
    daysToReach: 250,
    position: 12,
    description: '昭和の時代。日本の急速な成長。',
  ),
  EraJourney(
    id: 'heisei',
    name: 'Heisei',
    japaneseName: '平成時代',
    daysToReach: 300,
    position: 13,
    description: '平成時代。バブル期から安定成長へ。',
  ),
  EraJourney(
    id: 'reiwa',
    name: 'Reiwa',
    japaneseName: '令和時代',
    daysToReach: 365,
    position: 14,
    description: '令和時代。新しい時代の始まり。',
  ),
];

/// 時代を日数から取得
EraJourney getEraByDays(int days) {
  for (var i = ERAS_JOURNEY.length - 1; i >= 0; i--) {
    if (days >= ERAS_JOURNEY[i].daysToReach) {
      return ERAS_JOURNEY[i];
    }
  }
  return ERAS_JOURNEY[0];
}

/// 次の時代への残り日数
int daysUntilNextEra(int currentDays) {
  final currentEra = getEraByDays(currentDays);
  final currentIndex = ERAS_JOURNEY.indexOf(currentEra);

  if (currentIndex >= ERAS_JOURNEY.length - 1) {
    return 0; // 最後の時代
  }

  final nextEra = ERAS_JOURNEY[currentIndex + 1];
  return (nextEra.daysToReach - currentDays).clamp(0, 365);
}
