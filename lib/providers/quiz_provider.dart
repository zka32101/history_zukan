import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:history_zukan/models/index.dart';

// =========================================
// Quiz Providers
// =========================================

/// Hive quiz_records ボックスプロバイダー
final quizRecordBoxProvider =
    Provider<Box<QuizNotificationRecord>>((ref) {
  return Hive.box<QuizNotificationRecord>('quiz_records');
});

/// 本日のクイズイベント一覧プロバイダー
final todayQuizEventsProvider = FutureProvider<List<QuizQuestion>>((ref) async {
  // TODO: FirestoreService.getEventsByMonthDay() を呼び出して
  // 今日の月日に合致するイベントを取得し、quizQuestion フィールドをチェック

  // 暫定版: ダミーデータを返す
  final now = DateTime.now();
  return [
    QuizQuestion(
      eventId: 'event_honoji',
      eventTitle: '本能寺の変',
      eventYear: 1582,
      quizQuestion: '1582年6月2日に京都で起きた本能寺の変。この事件を引き起こした主要人物は誰でしょう？',
      options: [
        QuizOption(
          text: '織田信長',
          correct: false,
          explanation: '織田信長はこの事件の被害者です。',
        ),
        QuizOption(
          text: '明智光秀',
          correct: true,
          explanation: '正解です！明智光秀が信長に反旗を翻しました。',
        ),
        QuizOption(
          text: '豊臣秀吉',
          correct: false,
          explanation: '秀吉は信長の傘下にいましたが、直接の実行者ではありません。',
        ),
        QuizOption(
          text: '徳川家康',
          correct: false,
          explanation: '家康は信長の同盟者でした。',
        ),
      ],
      quizContext: '戦国時代の転機となった事件です。',
    ),
  ];
});

/// 本日のクイズ回答状態プロバイダー
final todayQuizAnswersProvider =
    StateProvider<Map<String, QuizAnswer>>((ref) {
  final box = ref.watch(quizRecordBoxProvider);
  final today = DateTime.now().toString().split(' ')[0];

  final todayRecords = box.values
      .where((r) => r.date == today)
      .cast<QuizNotificationRecord>();

  return {
    for (final record in todayRecords)
      record.eventId: QuizAnswer(
        selectedAnswer: record.selectedAnswer ?? '',
        isCorrect: record.isCorrect,
        answeredAt: record.answeredAt,
      ),
  };
});

/// 本日のクイズサマリープロバイダー
final todayQuizSummaryProvider =
    FutureProvider<TodayQuizSummary>((ref) async {
  final questions = await ref.watch(todayQuizEventsProvider.future);
  final answers = ref.watch(todayQuizAnswersProvider);

  return TodayQuizSummary(
    todayQuestions: questions,
    answers: answers,
    answeredCount: answers.length,
  );
});

/// クイズ回答送信プロバイダー
final submitQuizAnswerProvider =
    FutureProvider.family<bool, (String, String)>((ref, params) async {
  final (eventId, selectedAnswerText) = params;

  // イベントのクイズ選択肢から正解を判定
  final questions = await ref.watch(todayQuizEventsProvider.future);
  final question = questions.firstWhere(
    (q) => q.eventId == eventId,
    orElse: () => questions.first,
  );
  final selectedOption = question.findOptionByText(selectedAnswerText);
  final isCorrect = selectedOption?.correct ?? false;

  // Hive に記録
  final box = ref.read(quizRecordBoxProvider);
  final today = DateTime.now().toString().split(' ')[0];

  final record = QuizNotificationRecord(
    eventId: eventId,
    date: today,
    answered: true,
    selectedAnswer: selectedAnswerText,
    isCorrect: isCorrect,
    answeredAt: DateTime.now(),
  );

  await box.add(record);

  // 回答状態を更新
  ref.invalidate(todayQuizAnswersProvider);
  ref.invalidate(todayQuizSummaryProvider);

  return isCorrect;
});

/// クイズ統計プロバイダー
final quizStatisticsProvider = FutureProvider<QuizStatistics>((ref) async {
  final box = ref.watch(quizRecordBoxProvider);

  final records = box.values.cast<QuizNotificationRecord>();
  final totalAttempted = records.length;
  final totalCorrect = records.where((r) => r.isCorrect).length;
  final totalIncorrect = totalAttempted - totalCorrect;

  // 連続日数を計算
  int consecutiveDays = 0;
  int longestStreak = 0;
  int currentStreak = 0;

  final now = DateTime.now();
  for (int i = 0; i < 365; i++) {
    final checkDate = now.subtract(Duration(days: i));
    final checkDateStr =
        '${checkDate.year}-${checkDate.month.toString().padLeft(2, '0')}-${checkDate.day.toString().padLeft(2, '0')}';

    final hasQuizToday =
        records.any((r) => r.date == checkDateStr && r.answered);

    if (hasQuizToday) {
      if (i == 0) {
        consecutiveDays = 1;
      }
      currentStreak++;
      longestStreak = currentStreak > longestStreak ? currentStreak : longestStreak;
    } else {
      if (i == 0) {
        consecutiveDays = 0;
      }
      currentStreak = 0;
    }
  }

  return QuizStatistics(
    totalAttempted: totalAttempted,
    totalCorrect: totalCorrect,
    totalIncorrect: totalIncorrect,
    consecutiveDays: consecutiveDays,
    longestStreak: longestStreak,
  );
});

/// クイズ回答ダイアログ用: 選択肢から QuizOption を検索
QuizOption? findCorrectOption(List<QuizOption> options) {
  try {
    return options.firstWhere((o) => o.correct);
  } catch (e) {
    return null;
  }
}
