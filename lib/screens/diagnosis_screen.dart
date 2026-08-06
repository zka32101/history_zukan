import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:history_zukan/constants/design_system.dart';
import 'package:history_zukan/models/index.dart';
import 'package:history_zukan/providers/index.dart';

class DiagnosisScreen extends ConsumerStatefulWidget {
  const DiagnosisScreen({super.key});

  @override
  ConsumerState<DiagnosisScreen> createState() => _DiagnosisScreenState();
}

class _DiagnosisScreenState extends ConsumerState<DiagnosisScreen> {
  @override
  Widget build(BuildContext context) {
    final quizAsync = ref.watch(currentWeeklyQuizProvider);

    return quizAsync.when(
      data: (quiz) {
        final previousResult = ref.watch(previousDiagnosisResultProvider);
        final hasCompletedThisWeek = previousResult.valueOrNull != null &&
            previousResult.valueOrNull!.weekNumber == getWeekNumber(DateTime.now());

        if (hasCompletedThisWeek) {
          return _buildResultView(context, previousResult.valueOrNull!);
        } else {
          return _buildStartView(context, quiz);
        }
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, st) => Scaffold(
        body: Center(child: Text('エラー: $err')),
      ),
    );
  }

  Widget _buildStartView(BuildContext context, PersonalityQuiz quiz) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('あなたは誰タイプ？'),
        centerTitle: true,
        backgroundColor: AppColors.diagnosisPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            // テーマ画像・説明
            GradientPanel(
              gradient: AppGradients.diagnosis,
              backgroundImage: AppAssets.diagnosisBgForThemeName(quiz.theme),
              child: Column(
                children: [
                  AppBadge(label: '今週のテーマ', color: Colors.white, icon: Icons.psychology),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    quiz.theme,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    quiz.themeDescription,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // 診断内容説明
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: AppRadius.mdRadius,
                boxShadow: AppShadows.card,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, size: 18, color: AppColors.diagnosisPurple),
                      const SizedBox(width: AppSpacing.sm),
                      const Text(
                        '診断について',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  const Text(
                    '10個の質問に答えると、あなたがどのような歴史人物のタイプかが判定されます。',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '毎週異なるテーマで新しい診断が利用可能になります。',
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.diagnosisPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: AppRadius.smRadius),
                      ),
                      onPressed: () {
                        _startDiagnosis(context, quiz);
                      },
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('診断を開始'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultView(
    BuildContext context,
    PersonalityDiagnosisResult result,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('診断結果'),
        centerTitle: true,
        backgroundColor: AppColors.diagnosisPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            // 結果表示
            GradientPanel(
              gradient: AppGradients.diagnosis,
              child: Column(
                children: [
                  Text(
                    'あなたは',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    result.resultName,
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'のようなタイプです',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // スコア詳細
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: AppRadius.mdRadius,
                boxShadow: AppShadows.card,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.bar_chart, size: 18, color: AppColors.diagnosisPurple),
                      const SizedBox(width: AppSpacing.sm),
                      const Text(
                        'スコア詳細（上位3人）',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _buildScoreList(result.scoreBreakdown),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // シェアボタン
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _shareResult(result);
                    },
                    icon: const Icon(Icons.share),
                    label: const Text('シェア'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.diagnosisIndigo,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: AppRadius.smRadius),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // 詳細画面へ遷移
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('詳細表示機能準備中')),
                      );
                    },
                    icon: const Icon(Icons.info_outline),
                    label: const Text('詳細'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreList(Map<String, int> scoreBreakdown) {
    final sorted = scoreBreakdown.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      children: sorted.take(3).map((entry) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'ID: ${entry.key}', // TODO: 実装時に人物名に変更
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              AppBadge(label: '${entry.value}点', color: AppColors.diagnosisIndigo),
            ],
          ),
        );
      }).toList(),
    );
  }

  void _startDiagnosis(BuildContext context, PersonalityQuiz quiz) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DiagnosisQuizScreen(quiz: quiz),
      ),
    );
  }

  void _shareResult(PersonalityDiagnosisResult result) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('シェア: 私の診断結果は ${result.resultName} です！'),
      ),
    );
  }
}

// ======== 診断クイズ画面 ========

class DiagnosisQuizScreen extends ConsumerStatefulWidget {
  final PersonalityQuiz quiz;

  const DiagnosisQuizScreen({required this.quiz, super.key});

  @override
  ConsumerState<DiagnosisQuizScreen> createState() =>
      _DiagnosisQuizScreenState();
}

class _DiagnosisQuizScreenState extends ConsumerState<DiagnosisQuizScreen> {
  @override
  Widget build(BuildContext context) {
    final progress = ref.watch(diagnosisProgressNotifierProvider);

    if (progress.isComplete) {
      return _buildResultsPage(context);
    }

    final currentQuestion = widget.quiz.questions[progress.currentQuestion];

    return Scaffold(
      appBar: AppBar(
        title: Text('Q${progress.currentQuestion + 1}/10'),
        centerTitle: true,
        backgroundColor: AppColors.diagnosisPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // プログレスバー
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress.progressPercent / 100,
                minHeight: 8,
                backgroundColor: AppColors.diagnosisPurple.withValues(alpha: 0.12),
                valueColor: const AlwaysStoppedAnimation(AppColors.diagnosisPurple),
              ),
            ),
            const SizedBox(height: 24),

            // 問題文
            Text(
              currentQuestion.text,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // 選択肢
            Column(
              children: currentQuestion.options.asMap().entries.map((entry) {
                final index = entry.key;
                final option = entry.value;
                final isSelected =
                    progress.answers.length > progress.currentQuestion &&
                    progress.answers[progress.currentQuestion] == option;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GestureDetector(
                    onTap: () {
                      _selectAnswer(option);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.diagnosisPurple.withValues(alpha: 0.1)
                            : Theme.of(context).cardColor,
                        border: Border.all(
                          color: isSelected
                              ? AppColors.diagnosisPurple
                              : Colors.grey.withValues(alpha: 0.25),
                          width: isSelected ? 2 : 1,
                        ),
                        borderRadius: AppRadius.smRadius,
                        boxShadow: isSelected ? AppShadows.card : [],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: isSelected ? AppGradients.diagnosis : null,
                              color: isSelected ? null : Colors.grey.shade400,
                            ),
                            child: Center(
                              child: Text(
                                String.fromCharCode(65 + index), // A, B, C, D
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              option.text,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),

            // ナビゲーションボタン
            Row(
              children: [
                if (progress.currentQuestion > 0)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ref.read(diagnosisProgressNotifierProvider.notifier)
                            .previousQuestion();
                      },
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('戻る'),
                    ),
                  ),
                if (progress.currentQuestion > 0) const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: progress.answers.isEmpty ? null : () {
                      _nextQuestion(context);
                    },
                    icon: const Icon(Icons.arrow_forward),
                    label: Text(
                      progress.currentQuestion == 9 ? '完了' : '次へ',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _selectAnswer(DiagnosisOption option) {
    ref.read(diagnosisProgressNotifierProvider.notifier).selectAnswer(option);
  }

  void _nextQuestion(BuildContext context) {
    final progress = ref.read(diagnosisProgressNotifierProvider);

    if (progress.currentQuestion == 9) {
      // 最後の質問なので結果計算
      _submitAnswers(context);
    } else {
      ref.read(diagnosisProgressNotifierProvider.notifier).nextQuestion();
    }
  }

  void _submitAnswers(BuildContext context) {
    // 結果計算と保存（省略、実装時に完成させる）
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('診断結果を計算中...')),
    );
  }

  Widget _buildResultsPage(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('診断結果'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text('診断完了！結果を計算中です...'),
      ),
    );
  }
}
