import 'package:hive_flutter/hive_flutter.dart';

part 'puzzle_models.g.dart';

// =========================================
// Person Relation Puzzle Models
// =========================================

/// 人物相関パズル問題 (Firestore: person_relation_puzzles)
class PersonRelationPuzzle {
  final String id;
  final DateTime puzzleDate;
  final String theme; // 「政治家の関係」「文化人の絆」など
  final PuzzleCategory category;
  final String clueText; // 「これら3人の共通点は？」
  final List<String> personIds; // 2-5人の人物ID
  final String commonTrait; // 「皆、安土桃山時代に活躍」
  final String explanation; // 詳細解説
  final int difficulty; // 1-5
  final List<String> hints; // オプション（複数段階）

  PersonRelationPuzzle({
    required this.id,
    required this.puzzleDate,
    required this.theme,
    required this.category,
    required this.clueText,
    required this.personIds,
    required this.commonTrait,
    required this.explanation,
    required this.difficulty,
    required this.hints,
  });

  factory PersonRelationPuzzle.fromJson(Map<String, dynamic> json) =>
      PersonRelationPuzzle(
        id: json['id'] as String,
        puzzleDate: DateTime.parse(json['puzzleDate'] as String),
        theme: json['theme'] as String,
        category: _parsePuzzleCategory(json['category'] as String),
        clueText: json['clueText'] as String,
        personIds: List<String>.from(json['personIds'] as List<dynamic>),
        commonTrait: json['commonTrait'] as String,
        explanation: json['explanation'] as String,
        difficulty: json['difficulty'] as int,
        hints: List<String>.from(json['hints'] as List<dynamic>? ?? []),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'puzzleDate': puzzleDate.toIso8601String(),
        'theme': theme,
        'category': category.name,
        'clueText': clueText,
        'personIds': personIds,
        'commonTrait': commonTrait,
        'explanation': explanation,
        'difficulty': difficulty,
        'hints': hints,
      };
}

/// パズルカテゴリ
enum PuzzleCategory {
  sameEra, // 「同じ時代に活躍」
  sameField, // 「同じ分野」
  teacherStudent, // 「師弟関係」
  conflict, // 「対立・競争」
  cooperation, // 「協力・同盟」
}

PuzzleCategory _parsePuzzleCategory(String value) {
  switch (value) {
    case 'sameEra':
      return PuzzleCategory.sameEra;
    case 'sameField':
      return PuzzleCategory.sameField;
    case 'teacherStudent':
      return PuzzleCategory.teacherStudent;
    case 'conflict':
      return PuzzleCategory.conflict;
    case 'cooperation':
      return PuzzleCategory.cooperation;
    default:
      return PuzzleCategory.sameEra;
  }
}

/// パズル回答記録 (Hive: puzzle_records)
@HiveType(typeId: 24)
class PersonRelationPuzzleRecord {
  @HiveField(0)
  final String puzzleId;

  @HiveField(1)
  final String date; // YYYY-MM-DD

  @HiveField(2)
  final bool solved; // 正解フラグ

  @HiveField(3)
  final int attemptCount; // 何回目で正解したか

  @HiveField(4)
  final bool usedHint; // ヒント使用フラグ

  @HiveField(5)
  final DateTime? solvedAt;

  PersonRelationPuzzleRecord({
    required this.puzzleId,
    required this.date,
    required this.solved,
    required this.attemptCount,
    required this.usedHint,
    this.solvedAt,
  });

  factory PersonRelationPuzzleRecord.fromJson(Map<String, dynamic> json) =>
      PersonRelationPuzzleRecord(
        puzzleId: json['puzzleId'] as String,
        date: json['date'] as String,
        solved: json['solved'] as bool,
        attemptCount: json['attemptCount'] as int,
        usedHint: json['usedHint'] as bool,
        solvedAt: json['solvedAt'] != null
            ? DateTime.parse(json['solvedAt'] as String)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'puzzleId': puzzleId,
        'date': date,
        'solved': solved,
        'attemptCount': attemptCount,
        'usedHint': usedHint,
        'solvedAt': solvedAt?.toIso8601String(),
      };
}

/// パズル進行状態（UI用）
class PuzzleProgress {
  final String answer; // ユーザー入力
  final bool usedHint; // ヒント使用フラグ
  final bool submitted; // 送信済みフラグ

  PuzzleProgress({
    required this.answer,
    required this.usedHint,
    required this.submitted,
  });
}

/// パズル履歴アイテム（カレンダー表示用）
class PuzzleHistoryItem {
  final String date; // YYYY-MM-DD
  final PuzzleStatus status; // 未実施/スキップ/不正解/正解

  PuzzleHistoryItem({
    required this.date,
    required this.status,
  });
}

/// パズルステータス
enum PuzzleStatus {
  notAttempted, // ■
  solved, // ✓
  attempted, // ◇ (不正解)
  skipped, // ◇ (スキップ)
}

/// パズル解答判定結果
class PuzzleSolutionResult {
  final bool isCorrect;
  final String feedback; // 「正解です！」or 「惜しい...」
  final String explanation; // 詳細解説
  final List<String> nextSteps; // 関連ページ案内

  PuzzleSolutionResult({
    required this.isCorrect,
    required this.feedback,
    required this.explanation,
    required this.nextSteps,
  });
}

/// パズルスコアボード（週間統計）
class PuzzleStatistics {
  final int totalAttempted;
  final int totalSolved;
  final int solveRate; // %
  final List<int> solveTimeByDifficulty; // [1, 3, 5] で平均秒数
  final int bestStreak; // 連続正解数

  PuzzleStatistics({
    required this.totalAttempted,
    required this.totalSolved,
    required this.solveRate,
    required this.solveTimeByDifficulty,
    required this.bestStreak,
  });

  String get displayString =>
      '正解率: $solveRate% ($totalSolved/$totalAttempted) 連続: $bestStreak日';
}

/// パズル難易度ラベル
String getPuzzleDifficultyLabel(int difficulty) {
  switch (difficulty) {
    case 1:
      return '⭐ 簡単';
    case 2:
      return '⭐⭐ 普通';
    case 3:
      return '⭐⭐⭐ 難しい';
    case 4:
      return '⭐⭐⭐⭐ 非常に難しい';
    case 5:
      return '⭐⭐⭐⭐⭐ 超難関';
    default:
      return '⭐ 不明';
  }
}
