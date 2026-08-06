import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:history_zukan/models/index.dart';

// =========================================
// Diagnosis Providers
// =========================================

/// Hive diagnosis_results ボックスプロバイダー
final diagnosisResultBoxProvider =
    Provider<Box<PersonalityDiagnosisResult>>((ref) {
  return Hive.box<PersonalityDiagnosisResult>('diagnosis_results');
});

/// 今週のクイズ設定プロバイダー
final currentWeeklyQuizProvider = FutureProvider<PersonalityQuiz>((ref) async {
  // TODO: Firestore から personality_quiz/config を取得
  // 暫定版: ダミーデータを返す
  return PersonalityQuiz(
    weekNumber: getWeekNumber(DateTime.now()),
    theme: '戦国武将タイプ',
    themeDescription: '10個の質問に答えると、あなたは何の戦国武将タイプかが判定されます。',
    questions: _generateDummyQuestions(),
    startDate: DateTime.now(),
  );
});

/// 診断進行操作用 StateNotifier
class DiagnosisProgressNotifier extends StateNotifier<DiagnosisProgress> {
  DiagnosisProgressNotifier() : super(DiagnosisProgress(
    currentQuestion: 0,
    answers: [],
  ));

  void selectAnswer(DiagnosisOption option) {
    if (state.answers.isEmpty || state.answers.length <= state.currentQuestion) {
      state = DiagnosisProgress(
        currentQuestion: state.currentQuestion,
        answers: [...state.answers, option],
      );
    } else {
      final newAnswers = [...state.answers];
      newAnswers[state.currentQuestion] = option;
      state = DiagnosisProgress(
        currentQuestion: state.currentQuestion,
        answers: newAnswers,
      );
    }
  }

  void nextQuestion() {
    if (state.currentQuestion < 9) {
      state = DiagnosisProgress(
        currentQuestion: state.currentQuestion + 1,
        answers: state.answers,
      );
    }
  }

  void previousQuestion() {
    if (state.currentQuestion > 0) {
      state = DiagnosisProgress(
        currentQuestion: state.currentQuestion - 1,
        answers: state.answers,
      );
    }
  }

  void reset() {
    state = DiagnosisProgress(
      currentQuestion: 0,
      answers: [],
    );
  }
}

final diagnosisProgressNotifierProvider =
    StateNotifierProvider<DiagnosisProgressNotifier, DiagnosisProgress>((ref) {
  return DiagnosisProgressNotifier();
});

/// 前回の診断結果プロバイダー
final previousDiagnosisResultProvider =
    FutureProvider<PersonalityDiagnosisResult?>((ref) async {
  final box = ref.watch(diagnosisResultBoxProvider);
  if (box.isEmpty) return null;

  // completedDate が最新のエントリを取得
  final results = box.values.toList()
    ..sort((a, b) => b.completedDate.compareTo(a.completedDate));
  return results.first;
});

/// スコア計算プロバイダー
final diagnosisScoreProvider =
    FutureProvider<PersonalityDiagnosisResult>((ref) async {
  final quiz = await ref.watch(currentWeeklyQuizProvider.future);
  final progress = ref.watch(diagnosisProgressNotifierProvider);

  // スコア計算: 各回答の personIds をカウント
  final scoreMap = <String, int>{};
  for (final answer in progress.answers) {
    for (final personId in answer.personIds) {
      scoreMap[personId] = (scoreMap[personId] ?? 0) + 1;
    }
  }

  // 最高スコアの人物を特定
  if (scoreMap.isEmpty) {
    throw Exception('No answers recorded');
  }

  final topPersonId =
      scoreMap.entries.reduce((a, b) => a.value > b.value ? a : b).key;

  // TODO: Firestore から topPersonId の person 情報を取得して resultName を設定
  return PersonalityDiagnosisResult(
    resultPersonId: topPersonId,
    resultName: 'タイプ $topPersonId', // プレースホルダー
    weekNumber: quiz.weekNumber,
    theme: quiz.theme,
    scoreBreakdown: scoreMap,
    completedDate: DateTime.now(),
  );
});

/// 診断送信プロバイダー
final submitDiagnosisProvider =
    FutureProvider<String>((ref) async {
  final result = await ref.watch(diagnosisScoreProvider.future);

  // Hive に保存
  final box = ref.read(diagnosisResultBoxProvider);
  await box.add(result);

  // TODO: Firestore に結果を保存（オプション）

  return result.resultPersonId;
});

// =========================================
// Helper Functions
// =========================================

/// ダミー問題生成（テスト用）
List<DiagnosisQuestion> _generateDummyQuestions() {
  return List.generate(10, (index) {
    return DiagnosisQuestion(
      id: 'q_${index + 1}',
      text: 'テスト問題 ${index + 1}：あなたのリーダーシップスタイルは？',
      options: [
        DiagnosisOption(
          text: '強力なカリスマで引っ張るタイプ',
          personIds: ['person_j010', 'person_j020'], // 織田信長タイプ
        ),
        DiagnosisOption(
          text: '慎重で計算高いタイプ',
          personIds: ['person_j025', 'person_j030'], // 徳川家康タイプ
        ),
        DiagnosisOption(
          text: '柔軟で人心掌握に長けたタイプ',
          personIds: ['person_j015', 'person_j035'], // 豊臣秀吉タイプ
        ),
        DiagnosisOption(
          text: '温厚で調和重視のタイプ',
          personIds: ['person_j005', 'person_j040'], // 聖徳太子タイプ
        ),
      ],
    );
  });
}
