import 'package:hive_flutter/hive_flutter.dart';

part 'quiz_models.g.dart';

// =========================================
// Quiz Models (Extend existing HistoryEvent)
// =========================================

/// クイズ選択肢（HistoryEvent.quizOptions の要素）
class QuizOption {
  final String text;
  final bool correct; // 正解フラグ
  final String explanation; // 正解/不正解時の解説

  QuizOption({
    required this.text,
    required this.correct,
    required this.explanation,
  });

  factory QuizOption.fromJson(Map<String, dynamic> json) => QuizOption(
        text: json['text'] as String,
        correct: json['correct'] as bool,
        explanation: json['explanation'] as String,
      );

  Map<String, dynamic> toJson() => {
        'text': text,
        'correct': correct,
        'explanation': explanation,
      };
}

/// クイズ回答記録 (Hive: quiz_records)
@HiveType(typeId: 23)
class QuizNotificationRecord {
  @HiveField(0)
  final String eventId;

  @HiveField(1)
  final String date; // YYYY-MM-DD

  @HiveField(2)
  final bool answered; // 回答済みフラグ

  @HiveField(3)
  final String? selectedAnswer; // ユーザーの選択肢テキスト

  @HiveField(4)
  final bool isCorrect; // 正解判定

  @HiveField(5)
  final DateTime? answeredAt;

  QuizNotificationRecord({
    required this.eventId,
    required this.date,
    required this.answered,
    this.selectedAnswer,
    required this.isCorrect,
    this.answeredAt,
  });

  factory QuizNotificationRecord.fromJson(Map<String, dynamic> json) =>
      QuizNotificationRecord(
        eventId: json['eventId'] as String,
        date: json['date'] as String,
        answered: json['answered'] as bool,
        selectedAnswer: json['selectedAnswer'] as String?,
        isCorrect: json['isCorrect'] as bool,
        answeredAt: json['answeredAt'] != null
            ? DateTime.parse(json['answeredAt'] as String)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'eventId': eventId,
        'date': date,
        'answered': answered,
        'selectedAnswer': selectedAnswer,
        'isCorrect': isCorrect,
        'answeredAt': answeredAt?.toIso8601String(),
      };
}

/// クイズ回答結果UI用
class QuizAnswer {
  final String selectedAnswer;
  final bool isCorrect;
  final DateTime? answeredAt;

  QuizAnswer({
    required this.selectedAnswer,
    required this.isCorrect,
    this.answeredAt,
  });
}

/// 本日のクイズサマリー（ホーム画面表示用）
class TodayQuizSummary {
  final List<QuizQuestion> todayQuestions;
  final Map<String, QuizAnswer> answers; // eventId -> answer
  final int answeredCount;

  TodayQuizSummary({
    required this.todayQuestions,
    required this.answers,
    required this.answeredCount,
  });

  int get totalCount => todayQuestions.length;
  int get correctCount =>
      answers.values.where((a) => a.isCorrect).length;
  int get remainingCount => totalCount - answeredCount;
  double get correctRate =>
      answeredCount > 0 ? (correctCount / answeredCount * 100) : 0;
}

/// クイズ出題（HistoryEvent から抽出）
class QuizQuestion {
  final String eventId;
  final String eventTitle;
  final int eventYear;
  final String quizQuestion;
  final List<QuizOption> options;
  final String? quizContext; // 背景説明

  QuizQuestion({
    required this.eventId,
    required this.eventTitle,
    required this.eventYear,
    required this.quizQuestion,
    required this.options,
    this.quizContext,
  });

  // 正解選択肢を取得
  QuizOption? getCorrectOption() {
    try {
      return options.firstWhere((o) => o.correct);
    } catch (e) {
      return null;
    }
  }

  // 選択肢テキストから QuizOption を検索
  QuizOption? findOptionByText(String text) {
    try {
      return options.firstWhere((o) => o.text == text);
    } catch (e) {
      return null;
    }
  }
}

/// クイズスコアボード（週間・月間統計）
class QuizStatistics {
  final int totalAttempted;
  final int totalCorrect;
  final int totalIncorrect;
  final int consecutiveDays;
  final int longestStreak;

  QuizStatistics({
    required this.totalAttempted,
    required this.totalCorrect,
    required this.totalIncorrect,
    required this.consecutiveDays,
    required this.longestStreak,
  });

  double get correctRate => totalAttempted > 0
      ? (totalCorrect / totalAttempted * 100)
      : 0.0;

  String get displayString =>
      '正答率: ${correctRate.toStringAsFixed(1)}% ($totalCorrect/$totalAttempted)';
}
