import 'package:hive_flutter/hive_flutter.dart';

part 'diagnosis_models.g.dart';

// =========================================
// Personality Diagnosis Models
// =========================================

/// 週ごとの診断テーマ設定 (Firestore: personality_quiz/config)
class PersonalityQuiz {
  final int weekNumber;
  final String theme; // 「戦国武将」「思想家」など
  final String themeDescription;
  final List<DiagnosisQuestion> questions; // 10問
  final DateTime startDate;

  PersonalityQuiz({
    required this.weekNumber,
    required this.theme,
    required this.themeDescription,
    required this.questions,
    required this.startDate,
  });

  factory PersonalityQuiz.fromJson(Map<String, dynamic> json) => PersonalityQuiz(
        weekNumber: json['weekNumber'] as int,
        theme: json['theme'] as String,
        themeDescription: json['themeDescription'] as String,
        questions: (json['questions'] as List<dynamic>)
            .map((q) => DiagnosisQuestion.fromJson(q as Map<String, dynamic>))
            .toList(),
        startDate: DateTime.parse(json['startDate'] as String),
      );

  Map<String, dynamic> toJson() => {
        'weekNumber': weekNumber,
        'theme': theme,
        'themeDescription': themeDescription,
        'questions': questions.map((q) => q.toJson()).toList(),
        'startDate': startDate.toIso8601String(),
      };
}

/// 診断の問題 (Firestore: personality_quiz/config内の配列)
class DiagnosisQuestion {
  final String id;
  final String text;
  final List<DiagnosisOption> options; // 4択

  DiagnosisQuestion({
    required this.id,
    required this.text,
    required this.options,
  });

  factory DiagnosisQuestion.fromJson(Map<String, dynamic> json) =>
      DiagnosisQuestion(
        id: json['id'] as String,
        text: json['text'] as String,
        options: (json['options'] as List<dynamic>)
            .map((o) => DiagnosisOption.fromJson(o as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'options': options.map((o) => o.toJson()).toList(),
      };
}

/// 診断の選択肢
class DiagnosisOption {
  final String text;
  final List<String> personIds; // マッチする人物ID群

  DiagnosisOption({
    required this.text,
    required this.personIds,
  });

  factory DiagnosisOption.fromJson(Map<String, dynamic> json) =>
      DiagnosisOption(
        text: json['text'] as String,
        personIds: List<String>.from(json['personIds'] as List<dynamic>),
      );

  Map<String, dynamic> toJson() => {
        'text': text,
        'personIds': personIds,
      };
}

/// 診断の進行状態（UI用）
class DiagnosisProgress {
  final int currentQuestion; // 0-9
  final List<DiagnosisOption> answers; // 回答済みの選択肢群

  DiagnosisProgress({
    required this.currentQuestion,
    required this.answers,
  });

  bool get isComplete => answers.length == 10;
  int get progressPercent => ((answers.length) * 100 ~/ 10).clamp(0, 100);
}

/// 診断の結果 (Hive: diagnosis_results)
@HiveType(typeId: 22)
class PersonalityDiagnosisResult {
  @HiveField(0)
  final String resultPersonId; // マッチした人物ID

  @HiveField(1)
  final String resultName;

  @HiveField(2)
  final int weekNumber;

  @HiveField(3)
  final String theme;

  @HiveField(4)
  final Map<String, int> scoreBreakdown; // personId -> point

  @HiveField(5)
  final DateTime completedDate;

  @HiveField(6)
  final String shareToken; // SNS シェア用（オプション）

  PersonalityDiagnosisResult({
    required this.resultPersonId,
    required this.resultName,
    required this.weekNumber,
    required this.theme,
    required this.scoreBreakdown,
    required this.completedDate,
    this.shareToken = '',
  });

  factory PersonalityDiagnosisResult.fromJson(Map<String, dynamic> json) =>
      PersonalityDiagnosisResult(
        resultPersonId: json['resultPersonId'] as String,
        resultName: json['resultName'] as String,
        weekNumber: json['weekNumber'] as int,
        theme: json['theme'] as String,
        scoreBreakdown: Map<String, int>.from(
          json['scoreBreakdown'] as Map<String, dynamic>,
        ),
        completedDate: DateTime.parse(json['completedDate'] as String),
        shareToken: json['shareToken'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'resultPersonId': resultPersonId,
        'resultName': resultName,
        'weekNumber': weekNumber,
        'theme': theme,
        'scoreBreakdown': scoreBreakdown,
        'completedDate': completedDate.toIso8601String(),
        'shareToken': shareToken,
      };
}

/// 診断スコア詳細（上位3人）
class DiagnosisScoreDetail {
  final String personId;
  final String personName;
  final int score;
  final double percentage; // スコアの % 表示

  DiagnosisScoreDetail({
    required this.personId,
    required this.personName,
    required this.score,
    required this.percentage,
  });
}

/// 週番号を取得（年の開始からの週数）
int getWeekNumber(DateTime date) {
  final yearStart = DateTime(date.year, 1, 1);
  final daysIntoYear = date.difference(yearStart).inDays;
  return (daysIntoYear ~/ 7) + 1;
}

/// 週がリセットされたかチェック
bool isDiagnosisWeekChanged(
  PersonalityDiagnosisResult? previous,
  DateTime currentDate,
) {
  if (previous == null) return true;
  final previousDate = DateTime(
    previous.completedDate.year,
    previous.completedDate.month,
    previous.completedDate.day,
  );
  final daysDiff = currentDate.difference(previousDate).inDays;
  return daysDiff >= 7; // 1週間以上経過
}
