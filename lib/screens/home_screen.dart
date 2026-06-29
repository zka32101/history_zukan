import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:history_zukan/widgets/index.dart';
import 'package:history_zukan/models/history_person.dart';
import 'package:history_zukan/utils/seed_data.dart';
import 'package:history_zukan/providers/theme_provider.dart';
import 'card_detail_screen.dart';
import 'my_timeline_screen.dart';
import 'world_sync_screen.dart';
import 'duration_scale_screen.dart';
import 'nearby_history_screen.dart';
import 'bedtime_screen.dart';
import 'person_detail_screen.dart';
import 'person_list_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 56),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF6A1B9A),
                const Color(0xFF8E24AA),
                const Color(0xFF9C27B0),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6A1B9A).withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              AppBar(
                title: const Text(
                  'たくさん知りたくなる歴史図鑑',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                backgroundColor: Colors.transparent,
                elevation: 0,
                actions: [
                  IconButton(
                    icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
                    tooltip: isDarkMode ? 'ライトモード' : 'ダークモード',
                    onPressed: () {
                      ref.read(themeModeProvider.notifier).toggle();
                    },
                  ),
                ],
              ),
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: '世界同時', icon: Icon(Icons.public, size: 18)),
                  Tab(text: '自分年表', icon: Icon(Icons.person, size: 18)),
                  Tab(text: 'タイムライン', icon: Icon(Icons.timeline, size: 18)),
                  Tab(text: '図鑑', icon: Icon(Icons.library_books, size: 18)),
                  Tab(text: '地図', icon: Icon(Icons.map, size: 18)),
                  Tab(text: 'テーマ', icon: Icon(Icons.palette, size: 18)),
                  Tab(text: 'お気に入り', icon: Icon(Icons.favorite, size: 18)),
                ],
                isScrollable: true,
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.3),
                      Colors.white.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          // C1: Progress Widget (always visible)
          const ProgressWidget(),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab 0: 世界同時パノラマ (A1)
                _buildWorldSyncTab(),

                // Tab 1: 自分年表 (B1)
                _buildMyTimelineTab(),

                // Tab 2: タイムライン
                _buildTimelineTab(),

                // Tab 3: 図鑑
                _buildEncyclopediaTab(),

                // Tab 4: 地図
                _buildMapTab(),

                // Tab 5: テーマ
                _buildThemeTab(),

                // Tab 6: お気に入り (C3 Bedtime button here)
                _buildFavoritesTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorldSyncTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.public, size: 64, color: Colors.blue),
          const SizedBox(height: 16),
          const Text('世界同時パノラマ'),
          const SizedBox(height: 8),
          const Text('複数の時代、世界中の歴史を同時に見る', style: TextStyle(fontSize: 12)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const WorldSyncScreen(),
                ),
              );
            },
            child: const Text('開く'),
          ),
        ],
      ),
    );
  }

  Widget _buildMyTimelineTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.person_outline, size: 64, color: Colors.green),
          const SizedBox(height: 16),
          const Text('自分年表'),
          const SizedBox(height: 8),
          const Text('あなたの人生と歴史を重ねて見る', style: TextStyle(fontSize: 12)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const MyTimelineScreen(),
                ),
              );
            },
            child: const Text('開く'),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.timeline, size: 64, color: Colors.orange),
          const SizedBox(height: 16),
          const Text('タイムライン'),
          const SizedBox(height: 8),
          const Text('時代順に歴史を眺める', style: TextStyle(fontSize: 12)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const DurationScaleScreen(),
                ),
              );
            },
            child: const Text('時代の長さを体感'),
          ),
        ],
      ),
    );
  }

  Widget _buildEncyclopediaTab() {
    return const PersonListScreen();
  }

  Widget _buildMapTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.map, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          const Text('地図'),
          const SizedBox(height: 8),
          const Text('場所から歴史を発見', style: TextStyle(fontSize: 12)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const NearbyHistoryScreen(),
                ),
              );
            },
            child: const Text('近くの歴史を探す'),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.category, size: 64, color: Colors.brown),
          const SizedBox(height: 16),
          const Text('テーマ'),
          const SizedBox(height: 8),
          const Text('テーマ別に歴史を掘り下げる', style: TextStyle(fontSize: 12)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('テーマ選択画面（実装予定）')),
              );
            },
            child: const Text('開く'),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.favorite, size: 64, color: Colors.pink),
          const SizedBox(height: 16),
          const Text('お気に入り'),
          const SizedBox(height: 8),
          const Text('保存した歴史を一覧表示', style: TextStyle(fontSize: 12)),
          const SizedBox(height: 24),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF3D1A00),
              foregroundColor: const Color(0xFFFFB347),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const BedtimeScreen(),
                ),
              );
            },
            icon: const Text('🌙', style: TextStyle(fontSize: 18)),
            label: const Text(
              '寝る前に聞く',
              style: TextStyle(fontSize: 16),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'ゆっくり読み上げ・10分で自動停止',
            style: TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
