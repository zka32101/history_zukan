import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:history_zukan/constants/app_constants.dart';
import 'package:history_zukan/widgets/index.dart';
import 'package:history_zukan/providers/theme_provider.dart';
import 'card_detail_screen.dart';
import 'my_timeline_screen.dart';
import 'world_sync_screen.dart';
import 'duration_scale_screen.dart';
import 'nearby_history_screen.dart';
import 'bedtime_screen.dart';
import 'person_detail_screen.dart';
import 'person_list_screen.dart';
import 'help_screen.dart';
import 'whats_new_screen.dart';
import 'feedback_screen.dart';

class ImprovedHomeScreen extends ConsumerStatefulWidget {
  const ImprovedHomeScreen({super.key});

  @override
  ConsumerState<ImprovedHomeScreen> createState() => _ImprovedHomeScreenState();
}

class _ImprovedHomeScreenState extends ConsumerState<ImprovedHomeScreen> {
  int _selectedIndex = 3; // デフォルトは図鑑

  @override
  void initState() {
    super.initState();
    // ビルド中のNavigator操作を避けるため、初回フレーム後に判定する
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeShowWhatsNew());
  }

  Future<void> _maybeShowWhatsNew() async {
    final lastSeen = AppMetaStorage.lastSeenVersion;
    if (lastSeen == AppConstants.appVersion) return;

    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const WhatsNewScreen()),
    );

    await AppMetaStorage.markVersionSeen(AppConstants.appVersion);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF6A1B9A),
                const Color(0xFF8E24AA),
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
          child: AppBar(
            title: const Text(
              'たくさん知りたくなる歴史図鑑',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              Tooltip(
                message: isDarkMode ? 'ライトモード' : 'ダークモード',
                child: IconButton(
                  icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
                  onPressed: () {
                    ref.read(themeModeProvider.notifier).toggle();
                  },
                  tooltip: isDarkMode ? 'ライトモードに切り替え' : 'ダークモードに切り替え',
                ),
              ),
              IconButton(
                icon: const Icon(Icons.help_outline),
                tooltip: '使い方ガイド',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const HelpScreen()),
                  );
                },
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                tooltip: 'その他',
                onSelected: (value) {
                  switch (value) {
                    case 'whats_new':
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const WhatsNewScreen()),
                      );
                      break;
                    case 'feedback':
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const FeedbackScreen()),
                      );
                      break;
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: 'whats_new',
                    child: ListTile(
                      leading: Icon(Icons.campaign_outlined),
                      title: Text('アップデート情報'),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'feedback',
                    child: ListTile(
                      leading: Icon(Icons.feedback_outlined),
                      title: Text('ご意見・不具合報告'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildWorldSyncScreen(),
          _buildMyTimelineScreen(),
          _buildNearbyScreen(),
          _buildEncyclopediaScreen(),
          _buildThemesScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() => _selectedIndex = index);
          },
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.public),
              label: '世界同時',
              tooltip: '世界の出来事を同時表示',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person),
              label: '自分年表',
              tooltip: 'あなたの人生と歴史を重ねて表示',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.location_on),
              label: '近場',
              tooltip: '近くの歴史的建造物を検索',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.library_books),
              label: '図鑑',
              tooltip: '300人の歴史人物を検索',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.palette),
              label: 'テーマ',
              tooltip: 'テーマ別に歴史を学ぶ',
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const BedtimeScreen(),
            ),
          );
        },
        icon: const Icon(Icons.bedtime),
        label: const Text('寝る前歴史'),
        tooltip: 'TTS付きで寝る前に歴史を聞く',
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildWorldSyncScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.public, size: 64, color: Colors.blue),
          const SizedBox(height: 16),
          const Text('世界同時パノラマ'),
          const SizedBox(height: 8),
          const Text('時間軸で世界の出来事を同時表示', style: TextStyle(fontSize: 12)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const WorldSyncScreen(),
                ),
              );
            },
            icon: const Icon(Icons.arrow_forward),
            label: const Text('開く'),
          ),
        ],
      ),
    );
  }

  Widget _buildMyTimelineScreen() {
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
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const MyTimelineScreen(),
                ),
              );
            },
            icon: const Icon(Icons.arrow_forward),
            label: const Text('開く'),
          ),
        ],
      ),
    );
  }

  Widget _buildNearbyScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.location_on, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          const Text('近場の歴史'),
          const SizedBox(height: 8),
          const Text('あなたの周りの歴史的建造物', style: TextStyle(fontSize: 12)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const NearbyHistoryScreen(),
                ),
              );
            },
            icon: const Icon(Icons.arrow_forward),
            label: const Text('開く'),
          ),
        ],
      ),
    );
  }

  Widget _buildEncyclopediaScreen() {
    return const PersonListScreen();
  }

  Widget _buildThemesScreen() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'テーマ別に学ぶ',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            _buildThemeCard('政治', Icons.account_balance, Colors.blue),
            const SizedBox(height: 12),
            _buildThemeCard('文化', Icons.palette, Colors.purple),
            const SizedBox(height: 12),
            _buildThemeCard('科学', Icons.science, Colors.cyan),
            const SizedBox(height: 12),
            _buildThemeCard('芸術', Icons.brush, Colors.pink),
            const SizedBox(height: 12),
            _buildThemeCard('経済', Icons.trending_up, Colors.orange),
            const SizedBox(height: 12),
            _buildThemeCard('軍事', Icons.shield, Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeCard(String label, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$label のテーマを選択しました')),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$label に関連する歴史を学ぶ',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward, color: color),
            ],
          ),
        ),
      ),
    );
  }
}
