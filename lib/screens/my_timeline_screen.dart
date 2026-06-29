import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:history_zukan/models/user_profile.dart';

class MyTimelineScreen extends ConsumerStatefulWidget {
  const MyTimelineScreen({super.key});

  @override
  ConsumerState<MyTimelineScreen> createState() => _MyTimelineScreenState();
}

class _MyTimelineScreenState extends ConsumerState<MyTimelineScreen> {
  late UserProfile userProfile;
  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();
    userProfile = UserProfile.empty();
    selectedDate = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    // Check if user has set birth date (would come from Hive in real app)
    if (userProfile.uid.isEmpty) {
      return _buildBirthDateSetupScreen();
    }

    return _buildTimelineDisplay();
  }

  /// Birth date setup screen (first time)
  Widget _buildBirthDateSetupScreen() {
    return Scaffold(
      appBar: AppBar(title: const Text('自分年表セットアップ')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cake, size: 80, color: Colors.pink),
            const SizedBox(height: 24),
            const Text(
              'あなたの生年月日を教えてください',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              '历史と自分の人生を重ねて見るために使います',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 48),
            ElevatedButton.icon(
              onPressed: () => _showDatePicker(),
              icon: const Icon(Icons.calendar_today),
              label: Text(
                selectedDate.year == DateTime.now().year &&
                        selectedDate.month == 1 &&
                        selectedDate.day == 1
                    ? '生年月日を選択'
                    : '${selectedDate.year}年${selectedDate.month}月${selectedDate.day}日',
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: selectedDate.year < DateTime.now().year
                  ? () {
                      // Save birth date to Hive
                      setState(() {
                        userProfile = UserProfile(
                          uid: 'anonymous',
                          birthDate: selectedDate,
                          showMyTimelineMode: true,
                        );
                      });
                    }
                  : null,
              child: const Text('設定'),
            ),
          ],
        ),
      ),
    );
  }

  /// Date picker dialog
  Future<void> _showDatePicker() async {
    final picked = await showDatePicker(
      context: context,
      initialDate:
          DateTime(DateTime.now().year - 15), // Default to 15 years old
      firstDate: DateTime(1950),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 5)), // Min 5 years old
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  /// Main timeline display
  Widget _buildTimelineDisplay() {
    final now = DateTime.now();
    final birthYear = userProfile.birthDate.year;
    final birthMonth = userProfile.birthDate.month;
    final birthDay = userProfile.birthDate.day;

    return Scaffold(
      appBar: AppBar(
        title: const Text('自分年表'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              setState(() {
                userProfile = UserProfile.empty();
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Birth date summary
            Container(
              color: Colors.blue.shade50,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${userProfile.birthDate.year}年${userProfile.birthDate.month}月${userProfile.birthDate.day}日 生まれ',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '現在の年齢: ${userProfile.ageAtCurrentDate}歳',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),

            // Timeline entries
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTimelineEntry(
                    year: userProfile.birthDate.year,
                    age: 0,
                    userEvent: '👶 生まれる',
                    historyEvent:
                        '${userProfile.birthDate.year}年${userProfile.birthDate.month}月${userProfile.birthDate.day}日の日本・世界の歴史イベント',
                  ),
                  _buildTimelineEntry(
                    year: userProfile.birthDate.year + 5,
                    age: 5,
                    userEvent: '🎓 幼稚園',
                    historyEvent: '同じ年: ${userProfile.birthDate.year + 5}年の重要な歴史事象',
                  ),
                  _buildTimelineEntry(
                    year: userProfile.birthDate.year + 12,
                    age: 12,
                    userEvent: '📚 中学1年生',
                    historyEvent: '${userProfile.birthDate.year + 12}年: 世界の動き',
                  ),
                  _buildTimelineEntry(
                    year: now.year,
                    age: userProfile.ageAtCurrentDate,
                    userEvent: '⭐ 今',
                    historyEvent: '${now.year}年の今を生きている',
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      border: Border.all(color: Colors.amber),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '📸 自分年表をシェアしよう！',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '「織田信長と同じ年に生まれた」など、発見を友達と共有できます。',
                          style: TextStyle(fontSize: 12),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'スクリーンショット共有機能は Phase 1.5 で実装予定'),
                              ),
                            );
                          },
                          child: const Text('スクリーンショットをシェア'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Single timeline entry
  Widget _buildTimelineEntry({
    required int year,
    required int age,
    required String userEvent,
    required String historyEvent,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline dot
          Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    '●',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
              if (year < userProfile.birthDate.year + 50)
                Container(
                  width: 2,
                  height: 40,
                  color: Colors.blue.shade200,
                ),
            ],
          ),
          const SizedBox(width: 16),

          // Content
          Expanded(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$year年',
                          style:
                              Theme.of(context).textTheme.titleSmall,
                        ),
                        Text(
                          '年齢: $age歳',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      userEvent,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        historyEvent,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
