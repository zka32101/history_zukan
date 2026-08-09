import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:history_zukan/models/index.dart';

// =========================================
// Puzzle Providers
// =========================================

/// Hive puzzle_records ボックスプロバイダー
final puzzleRecordBoxProvider =
    Provider<Box<PersonRelationPuzzleRecord>>((ref) {
  return Hive.box<PersonRelationPuzzleRecord>('puzzle_records');
});

/// 本日のパズルプロバイダー
final todayPuzzleProvider = FutureProvider<PersonRelationPuzzle>((ref) async {
  // TODO: Firestore から今日の日付に合致するパズルを取得
  // person_relation_puzzles/{today} のドキュメントを取得

  // 暫定版: ダミーパズルを返す
  final today = DateTime.now();
  return PersonRelationPuzzle(
    id: 'puzzle_001',
    puzzleDate: today,
    theme: '戦国時代の人間関係',
    category: PuzzleCategory.sameEra,
    clueText: 'これら3人の共通点は？',
    personIds: ['person_j050', 'person_j060', 'person_j070'],
    commonTrait: '皆、戦国時代に活躍した戦国大名',
    explanation:
        '織田信長、豊臣秀吉、徳川家康は日本の戦国時代を代表する3人の大名です。',
    difficulty: 2,
    hints: [
      '時代を考えてみましょう',
      '戦国時代の有名な人物です',
    ],
  );
});

/// パズル関連人物情報プロバイダー
final puzzlePersonsProvider = FutureProvider<List<HistoryPerson>>((ref) async {
  final puzzle = await ref.watch(todayPuzzleProvider.future);

  // TODO: FirestoreService から personIds に対応する HistoryPerson を取得
  // 暫定版: ダミー人物を返す

  return [];
});

/// パズルプログレス操作用 StateNotifier
class PuzzleProgressNotifier extends StateNotifier<PuzzleProgress> {
  PuzzleProgressNotifier() : super(PuzzleProgress(
    answer: '',
    usedHint: false,
    submitted: false,
  ));

  void setAnswer(String answer) {
    state = PuzzleProgress(
      answer: answer,
      usedHint: state.usedHint,
      submitted: state.submitted,
    );
  }

  void toggleHint() {
    state = PuzzleProgress(
      answer: state.answer,
      usedHint: !state.usedHint,
      submitted: state.submitted,
    );
  }

  void submit() {
    state = PuzzleProgress(
      answer: state.answer,
      usedHint: state.usedHint,
      submitted: true,
    );
  }

  void reset() {
    state = PuzzleProgress(
      answer: '',
      usedHint: false,
      submitted: false,
    );
  }
}

final puzzleProgressNotifierProvider =
    StateNotifierProvider<PuzzleProgressNotifier, PuzzleProgress>((ref) {
  return PuzzleProgressNotifier();
});

/// パズルヒント表示プロバイダー
final puzzleHintProvider = StateProvider<String?>((ref) {
  final puzzle = ref.watch(todayPuzzleProvider).valueOrNull;
  final progress = ref.watch(puzzleProgressNotifierProvider);

  if (!progress.usedHint || puzzle == null || puzzle.hints.isEmpty) {
    return null;
  }

  return puzzle.hints[0]; // 最初のヒントを表示
});

/// パズル解答判定プロバイダー
final submitPuzzleAnswerProvider =
    FutureProvider.family<PuzzleSolutionResult, String>((ref, answer) async {
  final puzzle = await ref.watch(todayPuzzleProvider.future);
  final progress = ref.watch(puzzleProgressNotifierProvider);

  // 部分一致または完全一致で判定
  // NOTE: `answer` must be trimmed and non-empty first — `String.contains('')`
  // is always true in Dart, so an empty/whitespace-only answer used to be
  // graded "correct" automatically. Also normalize spaces instead of
  // splitting on the first word: Japanese sentences have no spaces, so
  // `commonTrait.split(' ')[0]` degenerated to the whole sentence.
  final trimmedAnswer = answer.trim();
  final normalizedTrait = puzzle.commonTrait.replaceAll(' ', '');
  final isCorrect = trimmedAnswer.length >= 2 &&
      (normalizedTrait.contains(trimmedAnswer) ||
          trimmedAnswer.contains(normalizedTrait));

  // Hive に記録
  final box = ref.read(puzzleRecordBoxProvider);
  final today = DateTime.now().toString().split(' ')[0];

  final record = PersonRelationPuzzleRecord(
    puzzleId: puzzle.id,
    date: today,
    solved: isCorrect,
    attemptCount: 1, // TODO: 実装時に実際の試行回数を記録
    usedHint: progress.usedHint,
    solvedAt: isCorrect ? DateTime.now() : null,
  );

  // 同じ日付のレコードがあるかチェック
  final existingRecord = box.values
      .cast<PersonRelationPuzzleRecord?>()
      .firstWhere(
        (r) => r?.date == today && r?.puzzleId == puzzle.id,
        orElse: () => null,
      );

  if (existingRecord == null) {
    await box.add(record);
  }

  return PuzzleSolutionResult(
    isCorrect: isCorrect,
    feedback: isCorrect ? '✨ 正解です！' : '💭 もう一度考えてみましょう',
    explanation: puzzle.explanation,
    nextSteps: [
      '人物の詳細を見る',
      '関連する時代を学ぶ',
    ],
  );
});

/// パズル統計プロバイダー
final puzzleStatisticsProvider = FutureProvider<PuzzleStatistics>((ref) async {
  final box = ref.watch(puzzleRecordBoxProvider);

  final records = box.values.cast<PersonRelationPuzzleRecord>();
  final totalAttempted = records.length;
  final totalSolved = records.where((r) => r.solved).length;

  final solveRate = totalAttempted > 0
      ? (totalSolved / totalAttempted * 100).toInt()
      : 0;

  // 連続正解数を計算
  int bestStreak = 0;
  int currentStreak = 0;

  final now = DateTime.now();
  for (int i = 0; i < 365; i++) {
    final checkDate = now.subtract(Duration(days: i));
    final checkDateStr =
        '${checkDate.year}-${checkDate.month.toString().padLeft(2, '0')}-${checkDate.day.toString().padLeft(2, '0')}';

    final solvedToday = records.any((r) => r.date == checkDateStr && r.solved);

    if (solvedToday) {
      currentStreak++;
      bestStreak = currentStreak > bestStreak ? currentStreak : bestStreak;
    } else {
      currentStreak = 0;
    }
  }

  return PuzzleStatistics(
    totalAttempted: totalAttempted,
    totalSolved: totalSolved,
    solveRate: solveRate,
    solveTimeByDifficulty: [30, 120, 300], // プレースホルダー（秒）
    bestStreak: bestStreak,
  );
});

/// パズル履歴プロバイダー
final puzzleHistoryProvider = FutureProvider<List<PuzzleHistoryItem>>((ref) async {
  final box = ref.watch(puzzleRecordBoxProvider);

  final history = <PuzzleHistoryItem>[];
  final now = DateTime.now();

  for (int i = 0; i < 30; i++) {
    final date = now.subtract(Duration(days: i));
    final dateStr =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

    final record = box.values
        .cast<PersonRelationPuzzleRecord?>()
        .firstWhere(
          (r) => r?.date == dateStr,
          orElse: () => null,
        );

    if (record == null) {
      history.add(PuzzleHistoryItem(date: dateStr, status: PuzzleStatus.notAttempted));
    } else if (record.solved) {
      history.add(PuzzleHistoryItem(date: dateStr, status: PuzzleStatus.solved));
    } else {
      history.add(PuzzleHistoryItem(date: dateStr, status: PuzzleStatus.attempted));
    }
  }

  return history;
});
