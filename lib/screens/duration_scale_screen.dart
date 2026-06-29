import 'package:flutter/material.dart';

class DurationScaleScreen extends StatefulWidget {
  const DurationScaleScreen({super.key});

  @override
  State<DurationScaleScreen> createState() => _DurationScaleScreenState();
}

class _DurationScaleScreenState extends State<DurationScaleScreen> {
  late ScrollController _scrollController;
  late List<Era> _eras;
  double _scrollProgress = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_updateScrollProgress);
    _eras = _getSampleEras();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _updateScrollProgress() {
    setState(() {
      if (_scrollController.position.maxScrollExtent > 0) {
        _scrollProgress = _scrollController.offset /
            _scrollController.position.maxScrollExtent;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('時代の長さ体感'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'スクロール体感'),
              Tab(text: '比較'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildScrollExperienceTab(),
            _buildComparisonTab(),
          ],
        ),
      ),
    );
  }

  /// Scroll experience mode (B2)
  Widget _buildScrollExperienceTab() {
    final selectedEra = _eras.isNotEmpty ? _eras[0] : null;

    return selectedEra == null
        ? const Center(child: Text('データがありません'))
        : Column(
            children: [
              // Era header
              Container(
                color: Colors.teal.shade50,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selectedEra.name,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '約 ${selectedEra.durationYears.toStringAsFixed(0)}年間',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.teal,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'スクロールして時間の重みを感じてください',
                      style: Theme.of(context).textTheme.bodySmall,
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
                          '進捗',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          '${(_scrollProgress * 100).toStringAsFixed(1)}%',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: _scrollProgress,
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
              ),

              // Scrollable timeline
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: 100, // Simulate time passage
                  itemBuilder: (context, index) {
                    final percent = index / 100;
                    final year = (percent * selectedEra.durationYears).toInt();

                    // Show key events at intervals
                    final showEvent = index % 20 == 0;

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (showEvent) ...[
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.amber.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '⭐ ${selectedEra.startYear + year}年頃',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _getEventDescription(
                                      selectedEra.name,
                                      year,
                                    ),
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                          Container(
                            height: 2,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 8),
                          if (index == 99)
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.teal.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${selectedEra.endEra}へ移行',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
  }

  /// Comparison mode
  Widget _buildComparisonTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '時代の長さを比較',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ..._eras.take(5).map((era) {
              final maxDuration =
                  _eras.map((e) => e.durationYears).reduce((a, b) => a > b ? a : b);
              final barWidth = (era.durationYears / maxDuration) * 300;

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          era.name,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          '${era.durationYears}年',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 24,
                      width: barWidth,
                      decoration: BoxDecoration(
                        color: Colors.teal,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Center(
                        child: era.durationYears > 1000
                            ? Text(
                                '━━',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Colors.white,
                                    ),
                              )
                            : const SizedBox.shrink(),
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '💡 時代の長さの感覚',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '縄文時代は昭和時代の約156倍の長さです。教科書では気づけない「時間の重み」がここにあります。',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getEventDescription(String era, int year) {
    final descriptions = {
      '縄文時代': [
        '火の使用を覚える',
        '土器が発明される',
        '狩猟採集文化の発展',
        '集落の形成',
      ],
      '弥生時代': [
        '稲作が伝わる',
        '弥生式土器が使われる',
        '階級社会へ',
      ],
      '奈良時代': [
        '平城京が築かれる',
        '班田収授法',
      ],
      '江戸時代': [
        '平和の時代へ',
        '文化の発展',
        '商業の活発化',
      ],
    };

    final eraDescriptions = descriptions[era] ?? [];
    if (eraDescriptions.isEmpty) return '歴史が進む...';
    return eraDescriptions[year % eraDescriptions.length];
  }

  List<Era> _getSampleEras() {
    return [
      Era(
        name: '縄文時代',
        startYear: -14000,
        endYear: -300,
        endEra: '弥生時代',
      ),
      Era(
        name: '弥生時代',
        startYear: -300,
        endYear: 250,
        endEra: '古墳時代',
      ),
      Era(
        name: '平安時代',
        startYear: 794,
        endYear: 1185,
        endEra: '鎌倉時代',
      ),
      Era(
        name: '江戸時代',
        startYear: 1603,
        endYear: 1868,
        endEra: '明治時代',
      ),
      Era(
        name: '昭和時代',
        startYear: 1926,
        endYear: 1989,
        endEra: '平成時代',
      ),
    ];
  }
}

class Era {
  final String name;
  final int startYear;
  final int endYear;
  final String endEra;

  Era({
    required this.name,
    required this.startYear,
    required this.endYear,
    required this.endEra,
  });

  int get durationYears => endYear - startYear;
}
