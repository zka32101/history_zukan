import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:history_zukan/constants/design_system.dart';
import 'package:history_zukan/models/index.dart';
import 'package:history_zukan/providers/index.dart';

class PuzzleScreen extends ConsumerStatefulWidget {
  const PuzzleScreen({super.key});

  @override
  ConsumerState<PuzzleScreen> createState() => _PuzzleScreenState();
}

class _PuzzleScreenState extends ConsumerState<PuzzleScreen> {
  late TextEditingController _answerController;

  @override
  void initState() {
    super.initState();
    _answerController = TextEditingController();
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final puzzleAsync = ref.watch(todayPuzzleProvider);
    final progress = ref.watch(puzzleProgressNotifierProvider);

    return puzzleAsync.when(
      data: (puzzle) {
        if (progress.submitted) {
          return _buildResultView(context, puzzle);
        } else {
          return _buildPuzzleView(context, puzzle);
        }
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, st) => Scaffold(
        appBar: AppBar(
          title: const Text('人物の絆'),
          backgroundColor: AppColors.puzzleTeal,
          foregroundColor: Colors.white,
        ),
        body: Center(child: Text('エラー: $err')),
      ),
    );
  }

  Widget _buildPuzzleView(BuildContext context, PersonRelationPuzzle puzzle) {
    final progress = ref.watch(puzzleProgressNotifierProvider);
    final hint = ref.watch(puzzleHintProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 130,
            pinned: true,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              title: const Text(
                '人物の絆',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
              ),
              background: Container(
                decoration: const BoxDecoration(gradient: AppGradients.puzzle),
                child: SafeArea(
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20, bottom: 44),
                      child: AppBadge(
                        label: getPuzzleDifficultyLabel(puzzle.difficulty),
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(AppSpacing.md),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // テーマ
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: AppRadius.smRadius,
                    boxShadow: AppShadows.card,
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: AppColors.puzzleTeal),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          puzzle.theme,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // クイズテキスト
                Text(
                  puzzle.clueText,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.lg),

                // 人物カード
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: puzzle.personIds.asMap().entries.map((entry) {
                    return Container(
                      width: 82,
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.puzzleTeal.withValues(alpha: 0.12),
                            AppColors.puzzleCyan.withValues(alpha: 0.06),
                          ],
                        ),
                        borderRadius: AppRadius.smRadius,
                        border: Border.all(
                          color: AppColors.puzzleTeal.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('👤', style: TextStyle(fontSize: 30)),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              'ID ${entry.key + 1}',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.puzzleTeal,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppSpacing.lg),

                // 回答入力欄
                TextField(
                  controller: _answerController,
                  decoration: InputDecoration(
                    hintText: '答えを入力してください',
                    filled: true,
                    fillColor: Theme.of(context).cardColor,
                    border: OutlineInputBorder(
                      borderRadius: AppRadius.smRadius,
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: AppRadius.smRadius,
                      borderSide: const BorderSide(color: AppColors.puzzleTeal, width: 2),
                    ),
                    prefixIcon: Icon(Icons.edit, color: AppColors.puzzleTeal),
                  ),
                  onChanged: (value) {
                    ref.read(puzzleProgressNotifierProvider.notifier).setAnswer(value);
                  },
                ),
                const SizedBox(height: AppSpacing.md),

                // ヒントボタン
                if (puzzle.hints.isNotEmpty)
                  OutlinedButton.icon(
                    onPressed: () {
                      ref.read(puzzleProgressNotifierProvider.notifier).toggleHint();
                    },
                    icon: const Icon(Icons.lightbulb_outline),
                    label: const Text('ヒントを見る'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.gachaGold,
                      side: BorderSide(color: AppColors.gachaGold.withValues(alpha: 0.5)),
                      shape: RoundedRectangleBorder(borderRadius: AppRadius.smRadius),
                    ),
                  ),

                // ヒント表示
                if (hint != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.gachaGold.withValues(alpha: 0.1),
                        border: Border.all(color: AppColors.gachaGold.withValues(alpha: 0.35)),
                        borderRadius: AppRadius.smRadius,
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.lightbulb, color: AppColors.gachaGold),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              hint,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: AppSpacing.md),

                // 送信ボタン
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: progress.answer.isEmpty
                        ? null
                        : () {
                            ref.read(puzzleProgressNotifierProvider.notifier).submit();
                          },
                    icon: const Icon(Icons.check),
                    label: const Text('答える'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.puzzleTeal,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey.shade300,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: AppRadius.smRadius),
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultView(
    BuildContext context,
    PersonRelationPuzzle puzzle,
  ) {
    final resultAsync = ref.watch(
      submitPuzzleAnswerProvider(
        ref.watch(puzzleProgressNotifierProvider).answer,
      ),
    );

    return resultAsync.when(
      data: (result) {
        final accent = result.isCorrect ? const Color(0xFF43A047) : AppColors.gachaGold;

        return Scaffold(
          appBar: AppBar(
            title: const Text('パズル結果'),
            centerTitle: true,
            backgroundColor: AppColors.puzzleTeal,
            foregroundColor: Colors.white,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                // 結果アイコン
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accent.withValues(alpha: 0.12),
                    boxShadow: AppShadows.soft(accent),
                  ),
                  child: Text(
                    result.isCorrect ? '✓' : '?',
                    style: TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.w800,
                      color: accent,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // フィードバック
                Text(
                  result.feedback,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),

                // 共通点
                AppBadge(label: puzzle.commonTrait, color: AppColors.puzzleTeal),
                const SizedBox(height: AppSpacing.lg),

                // 説明
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: AppRadius.mdRadius,
                    boxShadow: AppShadows.card,
                  ),
                  child: Text(
                    result.explanation,
                    style: const TextStyle(fontSize: 14, height: 1.5),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // 次のステップ
                if (result.nextSteps.isNotEmpty)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '次のステップ',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        ...result.nextSteps.map((step) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                            child: InkWell(
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('$step に移動します')),
                                );
                              },
                              child: Row(
                                children: [
                                  Icon(Icons.arrow_forward, size: 16, color: AppColors.puzzleTeal),
                                  const SizedBox(width: AppSpacing.xs),
                                  Text(
                                    step,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.puzzleTeal,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              ref.read(puzzleProgressNotifierProvider.notifier).reset();
            },
            backgroundColor: AppColors.puzzleTeal,
            icon: const Icon(Icons.refresh),
            label: const Text('リセット'),
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, st) => Scaffold(
        body: Center(child: Text('エラー: $err')),
      ),
    );
  }
}
