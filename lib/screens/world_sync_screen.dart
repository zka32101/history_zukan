import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:history_zukan/constants/app_constants.dart';
import 'package:history_zukan/models/index.dart';
import 'package:history_zukan/providers/firestore_provider.dart';

class WorldSyncScreen extends ConsumerStatefulWidget {
  const WorldSyncScreen({super.key});

  @override
  ConsumerState<WorldSyncScreen> createState() => _WorldSyncScreenState();
}

class _WorldSyncScreenState extends ConsumerState<WorldSyncScreen> {
  late int _selectedYear;

  @override
  void initState() {
    super.initState();
    _selectedYear = DateTime.now().year;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('世界同時パノラマ'),
      ),
      body: Column(
        children: [
          // Year slider
          _buildYearSlider(),

          // Event count display
          _buildEventCountDisplay(),

          // Events by region
          Expanded(
            child: _buildEventsByRegion(),
          ),
        ],
      ),
    );
  }

  /// Year selection slider (-1000 to 2000)
  Widget _buildYearSlider() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '時代スライダー',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                _selectedYear.toString() + '年',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Slider(
            value: _selectedYear.toDouble(),
            min: -1000,
            max: 2000,
            divisions: 3000,
            label: _selectedYear.toString(),
            onChanged: (value) {
              setState(() {
                _selectedYear = value.toInt();
              });
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '-1000年',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                '2000年',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Event count for selected year
  Widget _buildEventCountDisplay() {
    final countAsync = ref.watch(eventCountByYearProvider(_selectedYear));

    return countAsync.when(
      data: (count) {
        return Container(
          color: Colors.blue.shade50,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_selectedYear}年の世界',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              Chip(
                label: Text('$count個の歴史事象'),
                backgroundColor: Colors.blue.shade200,
              ),
            ],
          ),
        );
      },
      loading: () => Container(
        color: Colors.blue.shade50,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: const CircularProgressIndicator(),
      ),
      error: (err, stack) => Container(
        color: Colors.red.shade50,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Text('エラー: $err'),
      ),
    );
  }

  /// Events grouped by world region
  Widget _buildEventsByRegion() {
    final eventsAsync = ref.watch(synchronousWorldProvider(_selectedYear));

    return eventsAsync.when(
      data: (events) {
        if (events.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history, size: 64, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                Text(
                  '${_selectedYear}年のデータはまだありません',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          );
        }

        // Group events by region
        final groupedByRegion = <String, List<HistoryEvent>>{};
        for (final event in events) {
          final region = event.regionWorld;
          groupedByRegion.putIfAbsent(region, () => []).add(event);
        }

        return ListView(
          children: groupedByRegion.entries.map((entry) {
            final region = entry.key;
            final regionEvents = entry.value;

            return _buildRegionSection(region, regionEvents);
          }).toList(),
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (err, stack) => Center(
        child: Text('エラー: $err'),
      ),
    );
  }

  /// Region section with events
  Widget _buildRegionSection(String region, List<HistoryEvent> events) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '🗺 $region',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(width: 8),
              Chip(
                label: Text('${events.length}個'),
                backgroundColor: Colors.orange.shade200,
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...events.take(5).map((event) {
            // Show top 5 events per region
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildEventCard(event),
            );
          }),
          if (events.length > 5)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: TextButton(
                onPressed: () {
                  // TODO: Show all events for this region
                },
                child: Text('他${events.length - 5}件を表示'),
              ),
            ),
        ],
      ),
    );
  }

  /// Single event card
  Widget _buildEventCard(HistoryEvent event) {
    return Card(
      child: ListTile(
        title: Text(event.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              event.yearDisplay,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 2),
            Text(
              event.regionJp,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.of(context).pushNamed(
            '/event-detail',
            arguments: event.id,
          );
        },
      ),
    );
  }
}
