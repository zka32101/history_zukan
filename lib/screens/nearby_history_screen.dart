import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';

class NearbyHistoryScreen extends ConsumerStatefulWidget {
  const NearbyHistoryScreen({super.key});

  @override
  ConsumerState<NearbyHistoryScreen> createState() =>
      _NearbyHistoryScreenState();
}

class _NearbyHistoryScreenState extends ConsumerState<NearbyHistoryScreen> {
  bool _locationPermissionGranted = false;
  double? _userLat;
  double? _userLng;
  String? _userLocation;

  // Mock nearby events (would come from Firestore in real app)
  final List<NearbyEvent> _mockNearbyEvents = [
    NearbyEvent(
      id: 'event_001',
      title: '本能寺跡',
      description: '1582年: 本能寺の変が起きた場所',
      lat: 34.6776,
      lng: 135.7626,
      distanceKm: 0.3,
      category: 'Historic Site',
    ),
    NearbyEvent(
      id: 'event_002',
      title: '清水寺',
      description: '1633年: 重要な寺院建築',
      lat: 34.9948,
      lng: 135.7829,
      distanceKm: 2.1,
      category: 'Temple',
    ),
    NearbyEvent(
      id: 'event_003',
      title: '伏見稲荷大社',
      description: '856年: 稲荷信仰の中心地',
      lat: 34.8674,
      lng: 135.7293,
      distanceKm: 3.8,
      category: 'Shrine',
    ),
    NearbyEvent(
      id: 'event_004',
      title: '京都御所',
      description: '794年: 平安京遷都',
      lat: 35.0251,
      lng: 135.7577,
      distanceKm: 4.5,
      category: 'Imperial Palace',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }

  Future<void> _requestLocationPermission() async {
    // In real app, use geolocator plugin
    // For now, show permission dialog with mock location
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('位置情報へのアクセス'),
        content: const Text(
          '近くの歴史を探すために位置情報へのアクセスが必要です。',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _locationPermissionGranted = false;
              });
            },
            child: const Text('許可しない'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _setMockLocation();
            },
            child: const Text('許可する'),
          ),
        ],
      ),
    );
  }

  void _setMockLocation() {
    // Mock location: Kyoto, Japan
    setState(() {
      _locationPermissionGranted = true;
      _userLat = 34.9749;
      _userLng = 135.7681;
      _userLocation = '京都府京都市中京区';
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_locationPermissionGranted) {
      return Scaffold(
        appBar: AppBar(title: const Text('ここ歴史')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_off, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text('位置情報へのアクセスが必要です'),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _requestLocationPermission,
                icon: const Icon(Icons.location_on),
                label: const Text('位置情報を有効にする'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('ここ歴史'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Current location
            Container(
              color: Colors.blue.shade50,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'あなたの位置',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Text(
                              _userLocation ?? '不明',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(color: Colors.blue),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_userLat != null && _userLng != null)
                    Text(
                      '緯度 ${_userLat!.toStringAsFixed(4)}, 経度 ${_userLng!.toStringAsFixed(4)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                ],
              ),
            ),

            // Radius filter tabs
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '検索範囲',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildRadiusChip('500m', 0.5),
                        const SizedBox(width: 8),
                        _buildRadiusChip('2km', 2.0),
                        const SizedBox(width: 8),
                        _buildRadiusChip('5km', 5.0),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Events by distance
            ..._buildEventSections(),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildRadiusChip(String label, double radius) {
    return ActionChip(
      label: Text(label),
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$radius km以内の歴史を検索中...'),
          ),
        );
      },
    );
  }

  List<Widget> _buildEventSections() {
    final sections = <String, List<NearbyEvent>>{
      '500m以内': _mockNearbyEvents.where((e) => e.distanceKm <= 0.5).toList(),
      '2km以内': _mockNearbyEvents.where((e) => e.distanceKm <= 2.0).toList(),
      '5km以内': _mockNearbyEvents.where((e) => e.distanceKm <= 5.0).toList(),
    };

    return sections.entries
        .where((e) => e.value.isNotEmpty)
        .map((entry) => _buildRadiusSection(entry.key, entry.value))
        .toList();
  }

  Widget _buildRadiusSection(String radiusLabel, List<NearbyEvent> events) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '📍 $radiusLabel',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(width: 8),
              Chip(
                label: Text('${events.length}件'),
                backgroundColor: Colors.orange.shade200,
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...events.map((event) => _buildEventCard(event)),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildEventCard(NearbyEvent event) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    event.title,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                Chip(
                  label: Text('${event.distanceKm.toStringAsFixed(1)}km'),
                  backgroundColor: Colors.blue.shade200,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              event.description,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Chip(
                  label: Text(event.category),
                  backgroundColor: Colors.grey.shade200,
                ),
                TextButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${event.title}の詳細ページへ'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.chevron_right, size: 16),
                  label: const Text('詳細'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class NearbyEvent {
  final String id;
  final String title;
  final String description;
  final double lat;
  final double lng;
  final double distanceKm;
  final String category;

  NearbyEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.lat,
    required this.lng,
    required this.distanceKm,
    required this.category,
  });
}
