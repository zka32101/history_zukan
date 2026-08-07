import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:history_zukan/models/index.dart';
import 'package:history_zukan/providers/firestore_provider.dart';
import 'package:history_zukan/providers/seed_data_provider.dart';

class CausalChainScreen extends ConsumerStatefulWidget {
  final String chainId;

  const CausalChainScreen({
    super.key,
    required this.chainId,
  });

  @override
  ConsumerState<CausalChainScreen> createState() =>
      _CausalChainScreenState();
}

class _CausalChainScreenState extends ConsumerState<CausalChainScreen> {
  late int _currentStepIndex;

  @override
  void initState() {
    super.initState();
    _currentStepIndex = 0;
  }

  @override
  Widget build(BuildContext context) {
    final chainAsync = ref.watch(causalChainProvider(widget.chainId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('因果ドミノ'),
      ),
      body: chainAsync.when(
        data: (chain) {
          if (chain == null) {
            return const Center(
              child: Text('チェーンが見つかりません'),
            );
          }
          return _buildChainContent(chain);
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (err, stack) => Center(
          child: Text('エラー: $err'),
        ),
      ),
    );
  }

  /// Main chain content
  Widget _buildChainContent(CausalChain chain) {
    final stepCount = chain.eventIdsInOrder.length;
    final isLastStep = _currentStepIndex == stepCount - 1;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            color: Colors.purple.shade50,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  chain.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  chain.description,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 12),
                Chip(
                  label: Text(
                    '約${chain.estimatedReadMinutes}分で読める',
                  ),
                  backgroundColor: Colors.purple.shade200,
                ),
              ],
            ),
          ),

          // Progress indicator
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'ステップ ${_currentStepIndex + 1}/$stepCount',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    if (!isLastStep)
                      Text(
                        '次へ →',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.blue,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: (_currentStepIndex + 1) / stepCount,
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),

          // Current step content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildStepContent(
              stepIndex: _currentStepIndex,
              chain: chain,
            ),
          ),

          // Navigation buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: _buildNavigationButtons(stepCount),
          ),

          // Share button
          if (isLastStep)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('このストーリーをお気に入りに保存しました'),
                    ),
                  );
                },
                icon: const Icon(Icons.favorite),
                label: const Text('このストーリーをお気に入りに'),
              ),
            ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  /// Single step content
  Widget _buildStepContent({
    required int stepIndex,
    required CausalChain chain,
  }) {
    final eventId = chain.eventIdsInOrder[stepIndex];
    // NOTE: this used to only display the raw internal event ID string
    // ("イベント ID: event_j001") instead of resolving it — look up the
    // actual event so the step shows real title/year/description.
    final event = ref.watch(seedEventByIdProvider(eventId));
    final explanation = stepIndex < chain.explanations.length
        ? chain.explanations[stepIndex]
        : '';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Step title
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.purple.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ステップ ${stepIndex + 1}',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.purple,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    event != null
                        ? '${event.title}（${event.yearDisplay}）'
                        : 'イベントが見つかりません',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

            if (event != null) ...[
              const SizedBox(height: 12),
              Text(
                event.description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],

            const SizedBox(height: 16),

            // Explanation
            Text(
              '📖 ここで何が起きたか',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Text(
              explanation.isEmpty
                  ? 'この段階の説明はまだありません'
                  : explanation,
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            // If not last step, show "next" hint
            if (stepIndex < chain.eventIdsInOrder.length - 1) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  border: Border.all(color: Colors.amber),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '⏭ 次に何が起きたか',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ここをタップして次のステップに進みましょう',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Navigation buttons
  Widget _buildNavigationButtons(int stepCount) {
    final isFirstStep = _currentStepIndex == 0;
    final isLastStep = _currentStepIndex == stepCount - 1;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Previous button
        if (!isFirstStep)
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _currentStepIndex--;
              });
            },
            icon: const Icon(Icons.arrow_back),
            label: const Text('戻る'),
          )
        else
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.4,
          ),

        // Next button
        if (!isLastStep)
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _currentStepIndex++;
              });
            },
            icon: const Icon(Icons.arrow_forward),
            label: const Text('次へ'),
          )
        else
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('完了'),
          ),
      ],
    );
  }
}
