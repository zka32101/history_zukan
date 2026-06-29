import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:history_zukan/providers/progress_provider.dart';

class ProgressWidget extends ConsumerWidget {
  const ProgressWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final discoveryPct = ref.watch(discoveryPercentageProvider);
    final medals = ref.watch(unlockedMedalsProvider);

    return Container(
      color: Colors.blue.shade50,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Discovery percentage
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '発見度 ${(discoveryPct * 100).toStringAsFixed(0)}%',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              Text(
                '${(discoveryPct * 200).toStringAsFixed(0).split('.')[0]}/200',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: discoveryPct,
              minHeight: 8,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation(Colors.blue.shade400),
            ),
          ),
          const SizedBox(height: 12),

          // Medal badges
          if (medals.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'メダル (${medals.length}個)',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: medals.take(5).map((medal) {
                    return Chip(
                      avatar: const Icon(Icons.emoji_events,
                          size: 16, color: Colors.amber),
                      label: Text(_medalLabel(medal)),
                      backgroundColor: Colors.amber.shade100,
                    );
                  }).toList(),
                ),
              ],
            ),
        ],
      ),
    );
  }

  String _medalLabel(String medalId) {
    if (medalId == 'find_100_cards') return '100カード発見';
    if (medalId == 'complete_encyclopedia') return '完全図鑑';
    if (medalId.startsWith('complete_era_')) return '${medalId.split('_').last}時代';
    if (medalId.startsWith('theme_master_')) return 'テーママスター';
    return medalId;
  }
}
