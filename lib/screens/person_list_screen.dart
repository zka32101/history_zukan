import 'package:flutter/material.dart';
import 'package:history_zukan/models/history_person.dart';
import 'package:history_zukan/utils/seed_data.dart';
import 'package:history_zukan/widgets/person_card.dart';
import 'package:history_zukan/widgets/gradient_app_bar.dart';
import 'person_detail_screen.dart';

class PersonListScreen extends StatefulWidget {
  const PersonListScreen({super.key});

  @override
  State<PersonListScreen> createState() => _PersonListScreenState();
}

class _PersonListScreenState extends State<PersonListScreen> {
  late List<HistoryPerson> _allPersons;
  late List<HistoryPerson> _filteredPersons;
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  String _selectedCountry = 'All';
  String _selectedTheme = 'All';
  String _sortBy = 'name'; // 'name', 'year_birth', 'year_death'

  @override
  void initState() {
    super.initState();
    _allPersons = SeedData.generateSamplePersons();
    _filteredPersons = List.from(_allPersons);
    _searchController.addListener(_filterAndSort);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // キーボード非表示（スクロール時）
    if (_scrollController.position.userScrollDirection == ScrollDirection.down) {
      FocusScope.of(context).unfocus();
    }
  }

  void _filterAndSort() {
    final query = _searchController.text.toLowerCase();

    List<HistoryPerson> result = _allPersons.where((person) {
      final matchSearch = person.name.toLowerCase().contains(query) ||
          person.nameReading.toLowerCase().contains(query) ||
          person.description.toLowerCase().contains(query);

      final matchCountry = _selectedCountry == 'All' || person.country == _selectedCountry;
      final matchTheme = _selectedTheme == 'All' || person.themeIds.contains(_selectedTheme);

      return matchSearch && matchCountry && matchTheme;
    }).toList();

    // ソート
    switch (_sortBy) {
      case 'year_birth':
        result.sort((a, b) {
          final aYear = int.tryParse(a.birthYear ?? '0') ?? 0;
          final bYear = int.tryParse(b.birthYear ?? '0') ?? 0;
          return aYear.compareTo(bYear);
        });
        break;
      case 'year_death':
        result.sort((a, b) {
          final aYear = int.tryParse(a.deathYear ?? '0') ?? 0;
          final bYear = int.tryParse(b.deathYear ?? '0') ?? 0;
          return aYear.compareTo(bYear);
        });
        break;
      case 'name':
      default:
        result.sort((a, b) => a.name.compareTo(b.name));
    }

    setState(() {
      _filteredPersons = result;
    });
  }

  List<String> _getCountries() {
    final countries = _allPersons.map((p) => p.country).toSet().toList();
    countries.sort();
    return ['All', ...countries];
  }

  List<String> _getThemes() {
    const themes = ['All', 'politics', 'culture', 'arts', 'science', 'economics', 'military', 'religion', 'education', 'social'];
    return themes;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(title: '人物図鑑'),
      body: Column(
        children: [
          // 検索ボックス
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '人物を検索...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _filterAndSort();
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // フィルターボタン
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                // 国フィルター
                PopupMenuButton(
                  child: Chip(
                    label: Text('国: $_selectedCountry'),
                    avatar: const Icon(Icons.location_on, size: 16),
                  ),
                  onSelected: (value) {
                    setState(() => _selectedCountry = value);
                    _filterAndSort();
                  },
                  itemBuilder: (context) => _getCountries()
                      .map((c) => PopupMenuItem(value: c, child: Text(c)))
                      .toList(),
                ),
                const SizedBox(width: 8),

                // テーマフィルター
                PopupMenuButton(
                  child: Chip(
                    label: Text('テーマ: $_selectedTheme'),
                    avatar: const Icon(Icons.palette, size: 16),
                  ),
                  onSelected: (value) {
                    setState(() => _selectedTheme = value);
                    _filterAndSort();
                  },
                  itemBuilder: (context) => _getThemes()
                      .map((t) => PopupMenuItem(value: t, child: Text(t)))
                      .toList(),
                ),
                const SizedBox(width: 8),

                // ソート
                PopupMenuButton(
                  child: Chip(
                    label: const Text('並び順'),
                    avatar: const Icon(Icons.sort, size: 16),
                  ),
                  onSelected: (value) {
                    setState(() => _sortBy = value);
                    _filterAndSort();
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'name', child: Text('名前順')),
                    const PopupMenuItem(value: 'year_birth', child: Text('誕生年順')),
                    const PopupMenuItem(value: 'year_death', child: Text('没年順')),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // 結果カウント
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              '${_filteredPersons.length}人の人物',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),

          const SizedBox(height: 8),

          // グリッド
          Expanded(
            child: _filteredPersons.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_off, size: 48, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        const Text('該当する人物が見つかりません'),
                      ],
                    ),
                  )
                : GridView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(12),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.65,
                    ),
                    itemCount: _filteredPersons.length,
                    itemBuilder: (context, index) {
                      final person = _filteredPersons[index];
                      return Hero(
                        tag: person.id,
                        child: PersonCard(
                          person,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => PersonDetailScreen(personId: person.id),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
