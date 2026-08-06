import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:history_zukan/constants/design_system.dart';
import 'package:history_zukan/models/index.dart';
import 'package:history_zukan/providers/gacha_provider.dart';

class GachaScreen extends ConsumerStatefulWidget {
  const GachaScreen({super.key});

  @override
  ConsumerState<GachaScreen> createState() => _GachaScreenState();
}

class _GachaScreenState extends ConsumerState<GachaScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _spinController;
  late Animation<double> _scaleAnimation;
  bool _isSpinning = false;

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.15), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.15, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _spinController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _spinController.dispose();
    super.dispose();
  }

  void _executeGacha() async {
    if (_isSpinning) return;

    setState(() => _isSpinning = true);
    await _spinController.forward(from: 0);
    await ref.read(gachaExecutorProvider.notifier).executeGacha();
    setState(() => _isSpinning = false);
  }

  @override
  Widget build(BuildContext context) {
    final availability = ref.watch(todayGachaAvailableProvider);
    final gachaResult = ref.watch(gachaExecutorProvider);

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
                '今日の偉人',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
              ),
              background: Container(
                decoration: const BoxDecoration(gradient: AppGradients.gacha),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(AppSpacing.md),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                availability.when(
                  data: (available) => _buildGachaButton(available),
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (err, st) => Text('エラー: $err'),
                ),
                const SizedBox(height: AppSpacing.lg),
                gachaResult.when(
                  data: (result) => _buildGachaResult(result),
                  loading: () => const SizedBox.shrink(),
                  error: (err, st) => const SizedBox.shrink(),
                ),
                const SizedBox(height: AppSpacing.lg),
                _buildStatistics(),
                const SizedBox(height: AppSpacing.lg),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGachaButton(GachaAvailability availability) {
    final canGacha = availability.canGacha;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: AppRadius.lgRadius,
        boxShadow: AppShadows.card,
      ),
      child: Column(
        children: [
          Text(
            canGacha ? '🎉 今日のガチャ、引ける！' : '⏰ 明日また来てね',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: AppSpacing.lg),
          GestureDetector(
            onTap: canGacha && !_isSpinning ? _executeGacha : null,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: canGacha
                      ? AppGradients.gacha
                      : LinearGradient(
                          colors: [Colors.grey.shade400, Colors.grey.shade300],
                        ),
                  boxShadow: canGacha
                      ? AppShadows.soft(AppColors.gachaGold)
                      : [],
                ),
                child: Center(
                  child: Text(
                    '🎴',
                    style: TextStyle(fontSize: canGacha ? 76 : 56),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (!canGacha && availability.remainingTime > 0)
            AppBadge(
              label: _formatRemainingTime(availability.remainingTime),
              color: AppColors.textMuted,
              icon: Icons.schedule,
            ),
        ],
      ),
    );
  }

  Widget _buildGachaResult(GachaResult result) {
    return GradientPanel(
      gradient: AppGradients.rarity(result.person.rarity),
      child: Column(
        children: [
          AppBadge(
            label: result.rarityLabel,
            color: Colors.white,
            icon: result.person.rarity == 4 ? Icons.star : null,
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: 120,
            height: 120,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Image.asset(
                  AppAssets.gachaFrame(result.person.rarity),
                  errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                ),
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white.withValues(alpha: 0.25),
                  child: const Icon(Icons.person, color: Colors.white, size: 30),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            result.person.name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            result.person.country,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 13,
            ),
          ),
          if (result.isDuplicate) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: AppRadius.smRadius,
              ),
              child: const Text(
                '🔄 重複入手です',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatistics() {
    final statistics = ref.watch(gachaStatisticsProvider);

    return statistics.when(
      data: (stats) => Container(
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
                Icon(Icons.collections_bookmark, color: AppColors.gachaGold, size: 20),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'コレクション進捗',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: stats.completionPercent / 100,
                minHeight: 10,
                backgroundColor: AppColors.gachaGold.withValues(alpha: 0.12),
                valueColor: const AlwaysStoppedAnimation(AppColors.gachaGold),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '${stats.completionPercent}% 完成（${stats.totalObtained - stats.totalDuplicates}/300）',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildRarityBadge('SSR', stats.ssrCount, AppColors.raritySSR),
                _buildRarityBadge('SR', stats.srCount, AppColors.raritySR),
                _buildRarityBadge('R', stats.rCount, AppColors.rarityR),
                _buildRarityBadge('N', stats.nCount, AppColors.rarityN),
              ],
            ),
          ],
        ),
      ),
      loading: () => const SizedBox.shrink(),
      error: (err, st) => Text('エラー: $err'),
    );
  }

  Widget _buildRarityBadge(String label, int count, Color color) {
    return Column(
      children: [
        AppBadge(label: label, color: color),
        const SizedBox(height: AppSpacing.xs),
        Text(
          '$count',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }

  String _formatRemainingTime(int milliseconds) {
    final hours = milliseconds ~/ (1000 * 60 * 60);
    final minutes = (milliseconds ~/ (1000 * 60)) % 60;
    return '次のガチャまで $hours時間$minutes分';
  }
}
