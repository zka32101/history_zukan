import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:history_zukan/constants/design_system.dart';
import 'package:history_zukan/models/index.dart';
import 'package:history_zukan/providers/login_streak_provider.dart';

class LoginStreakScreen extends ConsumerStatefulWidget {
  const LoginStreakScreen({super.key});

  @override
  ConsumerState<LoginStreakScreen> createState() => _LoginStreakScreenState();
}

class _LoginStreakScreenState extends ConsumerState<LoginStreakScreen> {
  @override
  void initState() {
    super.initState();
    // アプリ起動時にログイン処理
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(loginProcessorProvider.notifier).processLogin();
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentStreak = ref.watch(currentLoginStreakProvider);
    final eraProgress = ref.watch(eraProgressProvider);
    final daysUntilNext = ref.watch(daysUntilNextEraProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              title: const Text(
                '歴史の旅',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
              ),
              background: Container(
                decoration: const BoxDecoration(gradient: AppGradients.streak),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(AppSpacing.md),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                currentStreak.when(
                  data: (streak) {
                    if (streak == null) {
                      return const Center(child: Text('ログイン情報がありません'));
                    }
                    return _buildStreakCard(streak);
                  },
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (err, st) => Text('エラー: $err'),
                ),
                const SizedBox(height: AppSpacing.md),
                daysUntilNext.when(
                  data: (days) => _buildNextEraBanner(days),
                  loading: () => const SizedBox.shrink(),
                  error: (err, st) => const SizedBox.shrink(),
                ),
                const SizedBox(height: AppSpacing.lg),
                eraProgress.when(
                  data: (eras) => _buildEraTimeline(eras),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, st) => Text('エラー: $err'),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakCard(LoginStreak streak) {
    return GradientPanel(
      gradient: AppGradients.streak,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.local_fire_department, color: Colors.white, size: 20),
              const SizedBox(width: 6),
              Text(
                '連続ログイン',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${streak.consecutiveDays}',
                style: const TextStyle(
                  fontSize: 64,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '日',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          AppBadge(
            label: '現在の時代: ${streak.currentEra}',
            color: Colors.white,
            icon: Icons.temple_buddhist,
          ),
        ],
      ),
    );
  }

  Widget _buildNextEraBanner(int days) {
    if (days == 0) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: AppRadius.mdRadius,
          boxShadow: AppShadows.card,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              AppAssets.mascot('celebrating'),
              width: 40,
              height: 40,
              errorBuilder: (context, error, stackTrace) =>
                  const Text('🎉', style: TextStyle(fontSize: 20)),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              '最後の時代に到達しました！',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md, horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: AppRadius.mdRadius,
        boxShadow: AppShadows.card,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '次の時代まで',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            '$days日',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.streakOrange,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildEraTimeline(List<EraProgress> eras) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.timeline, color: AppColors.streakOrange, size: 20),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'タイムライン',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: eras.length,
          itemBuilder: (context, index) {
            final era = eras[index];
            return _buildEraCard(era, isLast: index == eras.length - 1);
          },
        ),
      ],
    );
  }

  Widget _buildEraCard(EraProgress eraProgress, {required bool isLast}) {
    final reached = eraProgress.reached;
    final era = eraProgress.era;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // タイムラインの縦線 + アイコン
          Column(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: reached ? AppGradients.streak : null,
                  color: reached ? null : Colors.grey.shade300,
                  boxShadow: reached ? AppShadows.soft(AppColors.streakOrange) : [],
                ),
                child: Center(
                  child: reached
                      ? Padding(
                          padding: const EdgeInsets.all(6),
                          child: Image.asset(
                            AppAssets.eraIcon(era.id),
                            errorBuilder: (context, error, stackTrace) =>
                                const Text('🏛️', style: TextStyle(fontSize: 18)),
                          ),
                        )
                      : const Icon(Icons.lock, color: Colors.white70, size: 18),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 2),
                    color: reached
                        ? AppColors.streakOrange.withValues(alpha: 0.4)
                        : Colors.grey.shade300,
                  ),
                ),
            ],
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.md),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: reached
                    ? AppColors.streakOrange.withValues(alpha: 0.08)
                    : Theme.of(context).cardColor,
                borderRadius: AppRadius.smRadius,
                border: Border.all(
                  color: reached
                      ? AppColors.streakOrange.withValues(alpha: 0.25)
                      : Colors.grey.withValues(alpha: 0.15),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        era.japaneseName,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: reached ? AppColors.streakOrange : null,
                            ),
                      ),
                      const Spacer(),
                      Text(
                        '${era.daysToReach}日',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textMuted,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    era.description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textMuted,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
