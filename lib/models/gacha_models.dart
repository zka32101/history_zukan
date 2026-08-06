import 'package:hive_flutter/hive_flutter.dart';

part 'gacha_models.g.dart';

// =========================================
// Gacha Models
// =========================================

/// ガチャマスタ人物データ (Firestore: gacha_persons)
class GachaPerson {
  final String personId;
  final String name;
  final String country;
  final int rarity;    // 1:N, 2:R, 3:SR, 4:SSR
  final int weight;    // ガチャ抽選確率

  GachaPerson({
    required this.personId,
    required this.name,
    required this.country,
    required this.rarity,
    required this.weight,
  });

  factory GachaPerson.fromJson(Map<String, dynamic> json) => GachaPerson(
        personId: json['personId'] as String,
        name: json['name'] as String,
        country: json['country'] as String,
        rarity: json['rarity'] as int,
        weight: json['weight'] as int,
      );

  Map<String, dynamic> toJson() => {
        'personId': personId,
        'name': name,
        'country': country,
        'rarity': rarity,
        'weight': weight,
      };

  String get rarityLabel {
    switch (rarity) {
      case 4:
        return 'SSR';
      case 3:
        return 'SR';
      case 2:
        return 'R';
      case 1:
        return 'N';
      default:
        return 'N';
    }
  }

  String get rarityColor {
    switch (rarity) {
      case 4:
        return '#FFD700'; // Gold
      case 3:
        return '#C0C0C0'; // Silver
      case 2:
        return '#CD7F32'; // Bronze
      case 1:
        return '#A9A9A9'; // Gray
      default:
        return '#A9A9A9';
    }
  }
}

/// ガチャ引いた履歴 (Hive: gacha_records)
@HiveType(typeId: 20)
class GachaRecord {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String personId;

  @HiveField(2)
  final int rarity;

  @HiveField(3)
  final DateTime obtainedDate;

  @HiveField(4)
  final bool isDuplicate;

  GachaRecord({
    required this.id,
    required this.personId,
    required this.rarity,
    required this.obtainedDate,
    required this.isDuplicate,
  });

  factory GachaRecord.fromJson(Map<String, dynamic> json) => GachaRecord(
        id: json['id'] as String,
        personId: json['personId'] as String,
        rarity: json['rarity'] as int,
        obtainedDate: DateTime.parse(json['obtainedDate'] as String),
        isDuplicate: json['isDuplicate'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'personId': personId,
        'rarity': rarity,
        'obtainedDate': obtainedDate.toIso8601String(),
        'isDuplicate': isDuplicate,
      };
}

/// ガチャコレクション図鑑用のカード
class CollectionCard {
  final String personId;
  final String name;
  final String country;
  final int rarity;
  final bool isObtained;
  final DateTime? obtainedDate;

  CollectionCard({
    required this.personId,
    required this.name,
    required this.country,
    required this.rarity,
    required this.isObtained,
    this.obtainedDate,
  });
}

/// ガチャ実行結果
class GachaResult {
  final GachaPerson person;
  final bool isDuplicate;
  final String rarityLabel;

  GachaResult({
    required this.person,
    required this.isDuplicate,
    required this.rarityLabel,
  });
}

/// 今日のガチャ利用可能状態
class GachaAvailability {
  final bool canGacha;
  final int remainingTime; // ミリ秒（次のガチャまで）

  GachaAvailability({
    required this.canGacha,
    required this.remainingTime,
  });
}

/// ガチャコレクション統計
class GachaStatistics {
  final int totalObtained;
  final int totalDuplicates;
  final Map<int, int> rarityCount; // rarity -> count

  GachaStatistics({
    required this.totalObtained,
    required this.totalDuplicates,
    required this.rarityCount,
  });

  int get completionPercent {
    return ((totalObtained - totalDuplicates) * 100 ~/ 300).clamp(0, 100);
  }

  int get ssrCount => rarityCount[4] ?? 0;
  int get srCount => rarityCount[3] ?? 0;
  int get rCount => rarityCount[2] ?? 0;
  int get nCount => rarityCount[1] ?? 0;
}
